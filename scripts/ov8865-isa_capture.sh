RESOLUTION=800x600
FMT=SBGGR10_1X10
VFMT=SBGGR10

media-ctl -r

media-ctl -V "\"ov8865 1-0010\":0 [fmt:$FMT/${RESOLUTION}]"
media-ctl -V "\"Intel IPU4 CSI-2 3\":0 [fmt:$FMT/${RESOLUTION}]"
media-ctl -V "\"Intel IPU4 CSI-2 3\":1 [fmt:$FMT/${RESOLUTION}]"
media-ctl -V "\"Intel IPU4 CSI2 BE\":0 [fmt:$FMT/${RESOLUTION}]"
media-ctl -V "\"Intel IPU4 CSI2 BE\":1 [fmt:$FMT/${RESOLUTION}]"
media-ctl -V "\"Intel IPU4 ISA\":0 [fmt:$FMT/${RESOLUTION}]"
media-ctl -V "\"Intel IPU4 ISA\":1 [fmt:$FMT/${RESOLUTION}]"

media-ctl -l '"ov8865 1-0010":0 -> "Intel IPU4 CSI-2 3":0 [1]'
media-ctl -l '"Intel IPU4 CSI-2 3":1 -> "Intel IPU4 CSI2 BE":0 [1]'
media-ctl -l '"Intel IPU4 CSI2 BE":1 -> "Intel IPU4 ISA":0 [1]'
media-ctl -l '"Intel IPU4 ISA config":0 -> "Intel IPU4 ISA":2 [1]'
media-ctl -l '"Intel IPU4 ISA":1 -> "Intel IPU4 ISA capture":0 [1]'

CAPTURE_DEV=$(media-ctl -e "Intel IPU4 ISA capture")
yavta -c1 ${CAPTURE_DEV} -I -s${RESOLUTION} -Fframe-a-#.bin -f$VFMT
