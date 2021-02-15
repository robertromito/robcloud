#!/usr/bin/env bash
postTo='https://chat.home/webapi/entry.cgi?api=SYNO.Chat.External&method=incoming&version=2&token='
aa_token='%22UAQDrX1M46xDjfCeZWDbAr47Y0PiLqVsO3aE3zC06PyeO8vzbZowEgqglhN1Sql7%22'
nac_token='%22hfaPmNSR9Hlq0THisjmmsOfU66FxCus3NDcgKt7K6oGp60PK1moq5jnNRg1NRimL%22'
while true; do

    results=$(http https://am-i-eligible.covid19vaccine.health.ny.gov/api/list-providers | jq '.providerList[] | select(.address == "Buffalo, NY")')
    echo $results
    
    if $(echo $results | grep "AA"); then
        msg="There are appointments available"
        token=$aa_token
    else
        msg="There are no appoinments available"
        token=$nac_token
    fi

    http \
        --print=b --verify=no \
        -f POST "https://chat.home/webapi/entry.cgi?api=SYNO.Chat.External&method=incoming&version=2&token=${token}" \
        payload="{\"text\": \"${msg}\"}"

    sleep 15
done
