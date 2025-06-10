#!/usr/bin/env bash
# Copyright (C) 2025 Andrew Wason
# SPDX-License-Identifier: GPL-3.0-or-later

usage="$0 <video>"

${FFMPEG_PATH} -loglevel quiet -i "${1:?$usage}" -map 0:a -c copy -f null -
exit $?
