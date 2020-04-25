FROM openjdk:8u212-jre-alpine

RUN apk add --no-cache -U \
  openssl \
  imagemagick \
  lsof \
  su-exec \
  shadow \
  bash \
  curl iputils wget \
  git \
  jq \
  mysql-client \
  tzdata \
  rsync \
  nano

HEALTHCHECK --start-period=1m CMD mc-monitor status --host localhost --port $SERVER_PORT

RUN addgroup -g 1000 minecraft \
  && adduser -Ss /bin/false -u 1000 -G minecraft -h /home/minecraft minecraft \
  && mkdir -m 777 /data \
  && chown minecraft:minecraft /data /home/minecraft

EXPOSE 25565

ADD https://github.com/itzg/easy-add/releases/download/0.7.1/easy-add_linux_amd64 /usr/bin/easy-add
RUN chmod +x /usr/bin/easy-add

RUN easy-add --file mc-monitor --from https://github.com/itzg/mc-monitor/releases/download/0.5.0/mc-monitor_0.5.0_linux_arm64.tar.gz
RUN easy-add --file mc-server-runner --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_{{.os}}_{{.arch}}.tar.gz

COPY mcstatus /usr/local/bin

VOLUME ["/data"]
COPY server.properties /tmp/server.properties
COPY log4j2.xml /tmp/log4j2.xml
WORKDIR /data

ENTRYPOINT [ "/start" ]

ENV UID=1000 GID=1000 \
  JVM_XX_OPTS="-XX:+UseG1GC" MEMORY="1G" \
  LEVEL=world \
  PVP=true DIFFICULTY=easy \
  LEVEL_TYPE=DEFAULT SERVER_PORT=25565 ONLINE_MODE=TRUE SERVER_NAME="Dedicated Server" \
  REPLACE_ENV_VARIABLES="FALSE" ENV_VARIABLE_PREFIX="CFG_"

COPY start* /
RUN dos2unix /start* && chmod +x /start*
