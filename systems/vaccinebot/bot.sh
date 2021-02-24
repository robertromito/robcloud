#!/usr/bin/env bash

# Some good advice on bash scripting
#   https://kvz.io/bash-best-practices.html
#   https://medium.com/better-programming/best-practices-for-bash-scripts-17229889774d

set -o errexit
set -o nounset
set -o pipefail

getValue() {
    http GET http://localhost:8500/v1/kv/${1} | jq -r .[0].Value | base64 -d
}

echo "Fetching config values"
notify_list=$(getValue 'vaccinebot/notify_list')
aa_token=$(getValue 'vaccinebot/chat/aa_token')
nac_token=$(getValue 'vaccinebot/chat/nac_token')
twilio_account_id=$(getValue 'vaccinebot/twilio/account_id')
twilio_account_token=$(getValue 'vaccinebot/twilio/account_token')
twilio_from_number=$(getValue 'vaccinebot/twilio/from_number')

notifyChat() {
    postTo='https://chat.home/webapi/entry.cgi?api=SYNO.Chat.External&method=incoming&version=2&token='

    http --ignore-stdin --verify=no -f POST \
        "https://chat.home/webapi/entry.cgi?api=SYNO.Chat.External&method=incoming&version=2&token=${1}" \
        payload="{\"text\": \"${2}\"}"
}

notifySms() {
    http --ignore-stdin 
        -a ${twilio_account_id}:${twilio_account_token} \
        -f POST \
        https://api.twilio.com/2010-04-01/Accounts/${twilio_account_id}/Messages.json \
        From=+${twilio_from_number} \
        To=+1${1} \
        Body="There are available vaccine appointments in Buffalo. Go schedule now!"
}

while true; do

    sleep_time=20
    echo "--- $(date) ---"

    results=$(http GET https://am-i-eligible.covid19vaccine.health.ny.gov/api/list-providers | jq '.providerList[] | select(.providerName | startswith("University at Buffalo"))')
    echo "${results}"

    if $(echo $results | grep -q "AA"); then
        echo "Appointments are available"
        notifyChat $aa_token "$(date) There are appoinments available"
        if ([[ ! -e appt_text_sent ]] || [[ $(find appt_text_sent -mmin +720) ]]); then
            echo "Sending text messages"
            for i in ${notify_list}; do
                echo "Sending text message to ${i}"
                notifyChat $aa_token "$(date) Sending text message to ${i}"
                notifySms ${i}
            done
            touch appt_text_sent
        else
            echo "Not sending text messages since one was sent in the last 12 hours"
        fi
        sleep_time=600
    else
        echo "No appts available"
        if ([[ ! -e no_appt_available ]] || [[ $(find no_appt_available -mmin +30) ]]); then
            notifyChat $nac_token "$(date) There are no appoinments available"
            touch no_appt_available
        else
            echo "Muting no appt available notification"
        fi
        sleep_time=20
    fi

    echo "--- sleeping ${sleep_time} seconds ---"
    sleep ${sleep_time}
done
