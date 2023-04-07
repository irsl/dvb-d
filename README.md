# DVB-D (DVB over DLNA)

Yes, of course this is not anything official and especially not a standard. But it allows you accessing DVB channels over Wifi without any cables or antennas :)

## How to use it?

This is a solution to share a DVB tuner over DLNA.
It is based on the dynamic streams feature of the [DMS](https://pkg.go.dev/github.com/anacrolix/dms) DLNA server.
The work directory of this container will contain the channels config and their corresponding `.dms.json` files.
The container will take care of DVB scanning when `dvb_channel.conf` is not present. You can control the parameters
of `dvbv5-scan` via the `DVB_SCAN_PARAMS` environment variable. When it is missing, the tool will emit the list of
available initial scan files you can choose from.
If you see charset related exceptions in the log output, you need to configure the `DVB_CHANNEL_CHARSET` environment
variable to reflect the encoding of the channel names (e.g. you may set it to iso-8859-2).
The dms subdirectory will host the `.dms.json` files. If the directory is missing, the channels to dms.json conversion
will be started automatically.

If you need to rescan, restart the container with an empty workdir.
If you need to regenerate the `.dms.json` files, restart the container without the `dms` subdir in the workdir.
You may edit the either the `.dms.json` files according to your needs or the `dvb_channel.conf` file (e.g. delete undesired audio channels).

Parameters given to this container are relayed to the `dms` executable, so you can fine tune things like port and friendlyName.

## Example

Typical usage would look like this:

```
docker run --name dvb-d -d --network host -v /my/stuffs/dvb-d:/dmsdir --device /dev/dvb -e DVB_CHANNEL_CHARSET=iso-8859-2 -e DVB_SCAN_PARAMS="/usr/share/dvb/dvb-c/hu-Digikabel" ghcr.io/irsl/dvb-d:latest -friendlyName DIGI -http :1339
```
