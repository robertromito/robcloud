FROM alpine:latest

RUN apk add --no-cache \
    bash \
    httpie \
    jq 

WORKDIR /vaccinebot

COPY bot.sh .

RUN chmod 755 bot.sh

ENTRYPOINT [ "./bot.sh" ]