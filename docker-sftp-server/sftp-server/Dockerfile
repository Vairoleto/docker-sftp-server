FROM alpine:3.10
RUN apk update && \
    apk add openssh  && \
    apk add iptables && \
    apk add rsyslog
COPY files/sshd_config /etc/ssh/sshd_config
COPY files/start.sh /
COPY files/addUser.sh /
COPY files/rsyslog.conf /etc/rsyslog.conf
RUN chmod +x /start.sh
RUN chmod +x /addUser.sh
EXPOSE 22
CMD /start.sh