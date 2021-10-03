FROM ubuntu:latest

ENV TZ Europe/Paris

RUN apt-get update && apt-get -uy upgrade
RUN apt -y install ca-certificates && update-ca-certificates 
RUN apt -y install bind9-utils dnsutils
RUN apt -y install net-tools
RUN mkdir -p /etc/coredns

ADD coredns /coredns

EXPOSE 53 53/udp
EXPOSE 53 53/tcp

ENTRYPOINT [ "/coredns" ]