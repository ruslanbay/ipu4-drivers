RESOLUTION=2592x1944
FMT=SBGGR10_1X10
VFMT=SBGGR10

media-ctl -r

media-ctl -V "\"ov5693 1-0036\":0 [fmt:$FMT/$RESOLUTION]"
media-ctl -V "\"Intel IPU4 CSI-2 7\":0 [fmt:$FMT/$RESOLUTION]"
media-ctl -V "\"Intel IPU4 CSI-2 7\":1 [fmt:$FMT/$RESOLUTION]"
media-ctl -V "\"Intel IPU4 CSI2 BE\":0 [fmt:$FMT/$RESOLUTION]"
media-ctl -V "\"Intel IPU4 CSI2 BE\":1 [fmt:$FMT/$RESOLUTION]"

media-ctl -l '"ov5693 1-0036":0 -> "Intel IPU4 CSI-2 7":0 [1]'
media-ctl -l '"Intel IPU4 CSI-2 7":1 -> "Intel IPU4 CSI2 BE":0 [1]'
media-ctl -l '"Intel IPU4 CSI2 BE":1 -> "Intel IPU4 CSI2 BE capture":0 [1]'

CAPTURE_DEV=$(media-ctl -e "Intel IPU4 CSI2 BE capture")

yavta -c1 ${CAPTURE_DEV} -s${RESOLUTION} -Fframe-a-#.bin -f$VFMT
