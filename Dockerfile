FROM alpine:3.6

RUN apk add --no-cache openssh socat tini gnupg

ADD sshd_config /etc/ssh/sshd_config

RUN mkdir /root/.ssh && \
    chmod 700 /root/.ssh

EXPOSE 22

VOLUME ["/gpg-agent"]

ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]

CMD ["/usr/sbin/sshd", "-D"]

COPY docker-entrypoint.sh /
