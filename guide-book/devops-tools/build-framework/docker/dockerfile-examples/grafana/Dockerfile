
FROM	amazonlinux:latest

LABEL   name="sre ladon grafana image" \
		maintainer="traiana sre team <sre@traiana.com>" \
		vendor="traiana-sre" \
		build-date="20180229" \
		version="2.0.0.0"

# INSTALL PACKAGES
RUN 	curl https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-5.2.4-1.x86_64.rpm  --output grafana.rpm && \
        yum -y update && \
        yum -y install aws-cli findutils bind-utils git && \
        yum -y localinstall grafana.rpm && \
        rm grafana.rpm && \
        yum clean all

EXPOSE 3000 3000

CMD	["sh","init.sh"]
ADD     src/* ./