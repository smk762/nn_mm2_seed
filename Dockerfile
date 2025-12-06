FROM komodoofficial/komodo-defi-framework:dev-latest
LABEL maintainer="smk@komodoplatform.com"

ARG DEBIAN_FRONTEND=noninteractive 
ARG GROUP_ID
ARG USER_ID
RUN addgroup --gid ${GROUP_ID:-1000} komodian
RUN adduser --disabled-password --gecos '' --uid ${USER_ID:-1000} --gid ${GROUP_ID:-1000} komodian

RUN apt update && apt install curl nano jq wget htop sqlite3 -y

ENV MM2_CONF_PATH=/home/komodian/kdf/MM2.json
ENV MM_COINS_PATH=/home/komodian/kdf/coins
ENV MM_LOG=/home/komodian/kdf/kdf.log
ENV USERPASS=RPC_UserP@SSW0RD

WORKDIR /home/komodian/kdf
COPY ./ /home/komodian/kdf

RUN PATH=/usr/local/bin/:$PATH
RUN chown -R komodian:komodian /home/komodian
USER komodian
EXPOSE 7783 42855