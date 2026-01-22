RESOLUTION=3264x2448
FMT=SBGGR10_1X10
VFMT=SBGGR12

media-ctl -r

media-ctl -V "\"ov8865 2-0010\":0 [fmt:$FMT/$RESOLUTION]"
media-ctl -V "\"Intel IPU4 CSI-2 3\":0 [fmt:$FMT/$RESOLUTION]"
media-ctl -V "\"Intel IPU4 CSI-2 3\":1 [fmt:$FMT/$RESOLUTION]"
media-ctl -V "\"Intel IPU4 CSI2 BE\":0 [fmt:$FMT/$RESOLUTION]"
media-ctl -V "\"Intel IPU4 CSI2 BE\":1 [fmt:$FMT/$RESOLUTION]"
media-ctl -V "\"Intel IPU4 ISA\":0 [fmt:$FMT/$RESOLUTION]"
media-ctl -V "\"Intel IPU4 ISA\":1 [fmt:SBGGR12_1X12/$RESOLUTION]"

media-ctl -l '"ov8865 2-0010":0 -> "Intel IPU4 CSI-2 3":0 [1]'
media-ctl -l '"Intel IPU4 CSI-2 3":1 -> "Intel IPU4 CSI2 BE":0 [1]'
media-ctl -l '"Intel IPU4 CSI2 BE":1 -> "Intel IPU4 ISA":0 [1]'
media-ctl -l '"Intel IPU4 ISA":1 -> "Intel IPU4 ISA capture":0 [1]'
media-ctl -l '"Intel IPU4 ISA config":0 -> "Intel IPU4 ISA":2 [1]'
media-ctl -l '"Intel IPU4 ISA":3 -> "Intel IPU4 ISA 3A stats":0 [1]'

CAPTURE_DEV=$(media-ctl -e "Intel IPU4 ISA capture")

yavta -c1 ${CAPTURE_DEV} -s${RESOLUTION} -Fframe-a-#.bin -f$VFMT
