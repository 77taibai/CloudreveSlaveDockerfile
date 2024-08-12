FROM ubuntu:18.04

WORKDIR /cloudreve

COPY . .

RUN tar -zxvf ./cloudreve_3.8.3_linux_amd64.tar.gz \
	&& chmod +x ./start.sh \
	&& apt update \
	&& apt install aria2 -y \
	&& touch /cloudreve/aria2.session \
	&& chmod 777 /cloudreve/aria2.session \
	&& mkdir /cloudreve/aria2

EXPOSE 5212

ENTRYPOINT ["/cloudreve/start.sh"]
