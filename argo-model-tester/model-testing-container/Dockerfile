FROM alpine

WORKDIR /home
RUN apk --no-cache add curl
COPY test.sh .
COPY img.png .

ENTRYPOINT [ "/home/test.sh" ]