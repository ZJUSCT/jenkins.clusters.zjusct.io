FROM ubuntu/squid

RUN sed -i 's/archive.ubuntu.com/mirrors.zju.edu.cn/' /etc/apt/sources.list.d/ubuntu.sources
RUN sed -i 's/security.ubuntu.com/mirrors.zju.edu.cn/' /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y squid-openssl
RUN apt-get clean

# https://support.kaspersky.com/kwts/6.1/zh-HantTW/166244.htm
RUN mkdir -p /var/lib/squid \
    && rm -rf /var/lib/squid/ssl_db \
    && /usr/lib/squid/security_file_certgen -c -s /var/lib/squid/ssl_db -M 20MB \
    && chown -R proxy:proxy /var/lib/squid

ENV TZ="Asia/Shanghai"
