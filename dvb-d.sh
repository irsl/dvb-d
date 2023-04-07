#!/bin/sh
set -e
if ! test -f "dvb_channel.conf"; then
    echo "No channels file present."
	if [ -z "$DVB_SCAN_PARAMS" ]; then
	  echo Environment variable DVB_SCAN_PARAMS is unset. Please select one of:
	  find /usr/share/dvb/ -type f
	  echo Environment variable DVB_SCAN_PARAMS is unset. Please select one of the files above.
	  exit 1
	fi
	echo "Initiating a new scan"
	dvbv5-scan $DVB_SCAN_PARAMS
	if [ -n "$DVB_CHANNEL_CHARSET" ]; then
		echo "Converting character encoding to $DVB_CHANNEL_CHARSET"
		mv dvb_channel.conf dvb_channel.conf.tmp
		cat dvb_channel.conf.tmp | iconv -f $DVB_CHANNEL_CHARSET -t utf-8 > dvb_channel.conf
		rm dvb_channel.conf.tmp
	fi
fi
if ! test -d "dms"; then
    echo "Directory for DMS dynamic streams is missing."
	dvb_channels_to_dms.py dvb_channel.conf dms
fi

echo Starting DMS server
exec /dms -path /dmsdir/dms -allowDynamicStreams -noProbe -noTranscode "$@"
