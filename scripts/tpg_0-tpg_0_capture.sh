RESOLUTION=1920x1080
FMT=SBGGR8_1X8
VFMT=SBGGR8
 
media-ctl -r

v4l2-ctl -d $(media-ctl -e "Intel IPU4 TPG 0") -c test_pattern=2 # or 0

media-ctl -V "\"Intel IPU4 TPG 0\":0 [fmt:$FMT/${RESOLUTION}]"
 
media-ctl -l '"Intel IPU4 TPG 0":0 -> "Intel IPU4 TPG 0 capture":0 [1]'
 
CAPTURE_DEV=$(media-ctl -e "Intel IPU4 TPG 0 capture")
yavta -c1 ${CAPTURE_DEV} -I -s${RESOLUTION} -Fframe.bin -f$VFMT
