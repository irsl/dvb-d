#!/usr/bin/env python3

import sys
import json
import configparser
import re
import os
import pathlib
from unidecode import unidecode
from collections import namedtuple

Channel = namedtuple('Channel', ["name", "name_and_pid", "audio_pid"])

def eprint(*args, **kwargs):
    print(*args, **kwargs, file=sys.stderr)

def normalize_name(s):
    n = unidecode(s)
    return re.sub(r"-{2,}", "-", re.sub(r"[^\w\d-]+", "-", n))

def get_quoted(name):
    apostrophe = "'" in name
    quotation_mark = '"' in name
    if apostrophe and quotation_mark:
        # this is not supported
        return
    if apostrophe:
        return f'"{name}"'
    return f"'{name}'"

def parse_channels(path_channels):
    config = configparser.ConfigParser()
    config.read(path_channels)
    re = []
    # dvbv5-zap does not support including all audio pids into the same transport stream.
    # as a temporary workaround, we expose all audio channels as a separate item in the DLNA content directory.
    for channel_name in config.sections():
        eprint("channel", channel_name)
        audio_pids = config[channel_name].get('audio_pid')
        if not audio_pids:
            # some weird channels may have 
            re.append(Channel(channel_name, channel_name, None))
            continue
        audio_pids_arr = audio_pids.split(" ")
        for audio_pid in audio_pids_arr:
            eprint("audio_pid", audio_pid)
            a_channel_name = channel_name
            if len(audio_pids_arr) > 1:
                a_channel_name += f" [{audio_pid}]"
            re.append(Channel(channel_name, a_channel_name, audio_pid))
    return re

def write_dms(path_dmsdir, channels):
    for channel in channels:
        q_channel_name = get_quoted(channel.name)
        if not q_channel_name:
            # have to skip, dms couldn't parse
            continue
        f_channel_name = normalize_name(channel.name_and_pid)
        with open(os.path.join(path_dmsdir, f_channel_name+".dms.json"), "w") as f:
            audio_sel = channel.audio_pid if channel.audio_pid else ""
            cmd = f"stream.sh {q_channel_name} {audio_sel}"
            i = {"Title": channel.name_and_pid, "Resources": [{
                "MimeType": "video/x-matroska",
                "Command": cmd,
            }]}
            f.write(json.dumps(i))

def do_the_job(path_channels, path_dmsdir):
    channels = parse_channels(path_channels)
    pathlib.Path(path_dmsdir).mkdir(parents=True, exist_ok=True)
    write_dms(path_dmsdir, channels)

if __name__ == "__main__":
    do_the_job(*sys.argv[1:])
