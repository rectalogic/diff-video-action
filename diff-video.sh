#!/usr/bin/env bash
# Copyright (C) 2023 Andrew Wason
# SPDX-License-Identifier: GPL-3.0-or-later
usage="$0 <reference-video> <current-video> <output.nut>"
reference_video=${1:?$usage}
current_video=${2:?$usage}
output_video=${3:?$usage}

# Test if videos have audio stream, if not we need to use the anullsrc stream.
# So we adjust the stream indexes here
HAS_AUDIO=${BASH_SOURCE%/*}/has-audio.sh
if "${HAS_AUDIO}" "${reference_video}"; then
    A1=0
else
    A1=2
fi
if "${HAS_AUDIO}" "${current_video}"; then
    A2=1
else
    A2=2
fi

# https://superuser.com/questions/1529573/ignore-audio-stream-if-it-is-not-found-in-filter-complex-of-ffmpeg
# https://superuser.com/questions/854543/how-to-compare-the-difference-between-2-videos-color-in-ffmpeg
read -r -d '' FILTER <<EOF
[$A1:a]asplit[ref1a][ref2a];
[ref1a]showwaves=s=320x100:mode=line:rate=25[refwaveform];
[0:v]pad=iw+max(320-iw\,0):ih+100[pad],[pad][refwaveform]overlay=0:H-100,split[ref1v][ref2v];
[$A2:a]asplit[cur1a][cur2a];
[cur1a]showwaves=s=320x100:mode=line:rate=25[curwaveform];
[1:v]pad=iw+max(320-iw\,0):ih+100[pad],[pad][curwaveform]overlay=0:H-100,split[cur1v][cur2v];
[ref1v][cur1v]blend=all_mode=grainextract[blendv];
[ref2a][cur2a]amix;
[ref2v][cur2v][blendv]vstack=inputs=3
EOF

# Stream indexes are: 0=reference_video 1=current_video 2=anullsrc
${FFMPEG_PATH} -hide_banner -i "${reference_video}" -i "${current_video}" -f lavfi -t 0.1 -i anullsrc -filter_complex "$FILTER" -f nut -codec:a pcm_f32le -codec:v ffv1 -flags bitexact -g 1 -level 3 -pix_fmt rgb32 -fflags bitexact -y "${output_video}"
