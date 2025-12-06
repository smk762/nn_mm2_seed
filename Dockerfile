FROM komodoofficial/komodo-defi-framework:dev-latest
LABEL maintainer="smk@komodoplatform.com"

ARG DEBIAN_FRONTEND=noninteractive 
ARG GROUP_ID
ARG USER_ID
# Install packages and create non-root user, supporting both Debian/Ubuntu (apt) and Alpine (apk) bases
RUN set -eux; \
	if command -v apt-get >/dev/null 2>&1; then \
		apt-get update; \
		apt-get install -y --no-install-recommends ca-certificates curl nano jq wget htop sqlite3 adduser; \
		rm -rf /var/lib/apt/lists/*; \
		addgroup --gid ${GROUP_ID:-1000} komodian || true; \
		adduser --disabled-password --gecos '' --uid ${USER_ID:-1000} --gid ${GROUP_ID:-1000} komodian || true; \
	elif command -v apk >/dev/null 2>&1; then \
		apk add --no-cache ca-certificates curl nano jq wget htop sqlite sqlite-libs shadow; \
		groupadd -g ${GROUP_ID:-1000} komodian || true; \
		useradd -m -u ${USER_ID:-1000} -g ${GROUP_ID:-1000} -s /bin/sh komodian || true; \
	else \
		echo "Unsupported base image: neither apt-get nor apk found" >&2; exit 1; \
	fi

ENV MM2_CONF_PATH=/home/komodian/kdf/MM2.json
ENV MM_COINS_PATH=/home/komodian/.kdf/coins
ENV MM_LOG=/home/komodian/kdf/kdf.log
ENV USERPASS=RPC_UserP@SSW0RD

WORKDIR /home/komodian/kdf
COPY ./ /home/komodian/kdf

RUN PATH=/usr/local/bin/:$PATH
RUN chown -R komodian:komodian /home/komodian
USER komodian
EXPOSE 7783 42855