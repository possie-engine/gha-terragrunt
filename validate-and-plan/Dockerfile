FROM alpine:latest

USER root
COPY ["scripts","/scripts/"]
RUN chmod +x /scripts/* \
	&& apk add --update --no-cache bash ca-certificates curl git jq openssh-client

ENTRYPOINT ["/scripts/main.sh"]
