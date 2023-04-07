#!/bin/bash

channel_name="$1"
audio_pid="$2"

if [ -z "$FFMPEG_PROBESIZE" ]; then
   FFMPEG_PROBESIZE=1000000
fi

while :; do
  if ! pkill -f dvbv5; then
     break
  fi
  echo "some dvbv5 commands are running"
  sleep 1
done

args=( "-p" "-o" "-" "-c" "./dvb_channel.conf" )
if [ -n "$audio_pid" ]; then
  args+=( "-A" "$audio_pid" )
fi
args+=( "$channel_name" )

set -x
exec dvbv5-zap "${args[@]}" | ffmpeg -re -probesize $FFMPEG_PROBESIZE $FFMPEG_INPUT_PARAMS -f mpegts -i - -c:v copy -c:a copy  -movflags +faststart+frag_keyframe+empty_moova $FFMPEG_OUTPUT_PARAMS -f matroska -
