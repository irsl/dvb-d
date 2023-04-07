#stage1
FROM ghcr.io/anacrolix/dms:latest AS dms

#stage2
FROM ubuntu AS dvb
RUN apt update -y; apt install -y dvb-apps

#stage3
FROM alpine
LABEL org.opencontainers.image.source="https://github.com/irsl/dvb-d"

COPY --from=dms /dms /
WORKDIR /dmsdir
COPY --from=dvb /usr/share/dvb /usr/share/dvb

RUN apk add --no-cache v4l-utils-dvbv5 python3 py3-unidecode ffmpeg bash
ADD dvb-d.sh dvb_channels_to_dms.py stream.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/dvb-d.sh"]
