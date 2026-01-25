# 1. List the video devices and their capabilities <sup>[[source]](https://wiki.st.com/stm32mpu/wiki/STM32MP13_V4L2_camera_overview#How_to_use_the_framework)</sup>

List all the available video devices using --list-devices option:
```bash
v4l2-ctl --list-devices
```

<details>
  <summary>
    click to show the output
  </summary>

```
ipu4p (PCI:pci:intel-ipu):
        /dev/video0
        /dev/video1
        /dev/video2
        /dev/video3
        /dev/video4
        /dev/video5
        /dev/video6
        /dev/video7
        /dev/video8
        /dev/video9
        /dev/video10
        /dev/video11
        /dev/video12
        /dev/video13
        /dev/video14
        /dev/video15
        /dev/video16
        /dev/video17
        /dev/video18
        /dev/video19
        /dev/video20
        /dev/video21
        /dev/video22
        /dev/video23
        /dev/video24
        /dev/video25
        /dev/video26
        /dev/video27
        /dev/video28
        /dev/video29
        /dev/video30
        /dev/video31
        /dev/video32
        /dev/video33
        /dev/video34
        /dev/video35
        /dev/video36
        /dev/video37
        /dev/video38
        /dev/video39
        /dev/video40
        /dev/video41
        /dev/video42
        /dev/video43
        /dev/video44
        /dev/video45
        /dev/video46
        /dev/video47
        /dev/video48
        /dev/video49
        /dev/video50
        /dev/video51
        /dev/video52
        /dev/video53
        /dev/video54

ipu4p (pci:intel-ipu):
        /dev/media0
```
</details></br>

If several devices are available, use `-d` option after any `v4l2-ctl` commands to target a specific device. If -d option is not specified, `/dev/video0` is targeted by default.

In order to have information on a specific device, use `-D` option:

```bash
v4l2-ctl -d /dev/video0 -D
```

<details>
  <summary>
    click to show the output
  </summary>

```
VIDIOC_QUERYCAP: ok
Driver Info:
        Driver name      : intel-ipu4-isys
        Card type        : ipu4p
        Bus info         : PCI:pci:intel-ipu
        Driver version   : 6.1.159
        Capabilities     : 0xa4a03001
                Video Capture
                Video Capture Multiplanar
                Video Output Multiplanar
                Metadata Capture
                I/O MC
                Streaming
                Extended Pix Format
                Device Capabilities
        Device Caps      : 0x24a01000
                Video Capture Multiplanar
                Metadata Capture
                I/O MC
                Streaming
                Extended Pix Format
```
</details></br>

# 2. Get the topology of camera subsystem

Print the topology of camera subsystem using `-p` media-ctl option:

```bash
media-ctl -p
```

<details>
  <summary>
    click to show the output
  </summary>

```
Media controller API version 6.1.159

Media device information
------------------------
driver          intel-ipu4-isys
model           ipu4p
serial          
bus info        pci:intel-ipu
hw revision     0x0
driver version  6.1.159

Device topology
- entity 1: Intel IPU4 CSI-2 0 (6 pads, 41 links, 0 routes)
            type V4L2 subdev subtype Unknown flags 0
            device node name /dev/v4l-subdev0
	pad0: Sink
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
	pad1: Source
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		-> "Intel IPU4 CSI-2 0 capture 0":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad2: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 0 capture 1":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad3: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 0 capture 2":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad4: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 0 capture 3":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad5: Source
		-> "Intel IPU4 CSI-2 0 meta":0 []

- entity 8: Intel IPU4 CSI-2 0 capture 0 (1 pad, 1 link)
            type Node subtype V4L flags 0
            device node name /dev/video0
	pad0: Sink
		<- "Intel IPU4 CSI-2 0":1 []

- entity 14: Intel IPU4 CSI-2 0 capture 1 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video1
	pad0: Sink
		<- "Intel IPU4 CSI-2 0":2 []

- entity 20: Intel IPU4 CSI-2 0 capture 2 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video2
	pad0: Sink
		<- "Intel IPU4 CSI-2 0":3 []

- entity 26: Intel IPU4 CSI-2 0 capture 3 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video3
	pad0: Sink
		<- "Intel IPU4 CSI-2 0":4 []

- entity 32: Intel IPU4 CSI-2 0 meta (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video4
	pad0: Sink
		<- "Intel IPU4 CSI-2 0":5 []

- entity 38: Intel IPU4 CSI-2 1 (6 pads, 41 links, 0 routes)
             type V4L2 subdev subtype Unknown flags 0
             device node name /dev/v4l-subdev1
	pad0: Sink
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
	pad1: Source
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		-> "Intel IPU4 CSI-2 1 capture 0":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad2: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 1 capture 1":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad3: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 1 capture 2":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad4: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 1 capture 3":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad5: Source
		-> "Intel IPU4 CSI-2 1 meta":0 []

- entity 45: Intel IPU4 CSI-2 1 capture 0 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video5
	pad0: Sink
		<- "Intel IPU4 CSI-2 1":1 []

- entity 51: Intel IPU4 CSI-2 1 capture 1 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video6
	pad0: Sink
		<- "Intel IPU4 CSI-2 1":2 []

- entity 57: Intel IPU4 CSI-2 1 capture 2 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video7
	pad0: Sink
		<- "Intel IPU4 CSI-2 1":3 []

- entity 63: Intel IPU4 CSI-2 1 capture 3 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video8
	pad0: Sink
		<- "Intel IPU4 CSI-2 1":4 []

- entity 69: Intel IPU4 CSI-2 1 meta (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video9
	pad0: Sink
		<- "Intel IPU4 CSI-2 1":5 []

- entity 75: Intel IPU4 CSI-2 2 (6 pads, 41 links, 0 routes)
             type V4L2 subdev subtype Unknown flags 0
             device node name /dev/v4l-subdev2
	pad0: Sink
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
	pad1: Source
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		-> "Intel IPU4 CSI-2 2 capture 0":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad2: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 2 capture 1":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad3: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 2 capture 2":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad4: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 2 capture 3":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad5: Source
		-> "Intel IPU4 CSI-2 2 meta":0 []

- entity 82: Intel IPU4 CSI-2 2 capture 0 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video10
	pad0: Sink
		<- "Intel IPU4 CSI-2 2":1 []

- entity 88: Intel IPU4 CSI-2 2 capture 1 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video11
	pad0: Sink
		<- "Intel IPU4 CSI-2 2":2 []

- entity 94: Intel IPU4 CSI-2 2 capture 2 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video12
	pad0: Sink
		<- "Intel IPU4 CSI-2 2":3 []

- entity 100: Intel IPU4 CSI-2 2 capture 3 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video13
	pad0: Sink
		<- "Intel IPU4 CSI-2 2":4 []

- entity 106: Intel IPU4 CSI-2 2 meta (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video14
	pad0: Sink
		<- "Intel IPU4 CSI-2 2":5 []

- entity 112: Intel IPU4 CSI-2 3 (6 pads, 42 links, 0 routes)
              type V4L2 subdev subtype Unknown flags 0
              device node name /dev/v4l-subdev3
	pad0: Sink
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		<- "ov8865 2-0010":0 []
	pad1: Source
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		-> "Intel IPU4 CSI-2 3 capture 0":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad2: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 3 capture 1":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad3: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 3 capture 2":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad4: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 3 capture 3":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad5: Source
		-> "Intel IPU4 CSI-2 3 meta":0 []

- entity 119: Intel IPU4 CSI-2 3 capture 0 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video15
	pad0: Sink
		<- "Intel IPU4 CSI-2 3":1 []

- entity 125: Intel IPU4 CSI-2 3 capture 1 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video16
	pad0: Sink
		<- "Intel IPU4 CSI-2 3":2 []

- entity 131: Intel IPU4 CSI-2 3 capture 2 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video17
	pad0: Sink
		<- "Intel IPU4 CSI-2 3":3 []

- entity 137: Intel IPU4 CSI-2 3 capture 3 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video18
	pad0: Sink
		<- "Intel IPU4 CSI-2 3":4 []

- entity 143: Intel IPU4 CSI-2 3 meta (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video19
	pad0: Sink
		<- "Intel IPU4 CSI-2 3":5 []

- entity 149: Intel IPU4 CSI-2 4 (6 pads, 41 links, 0 routes)
              type V4L2 subdev subtype Unknown flags 0
              device node name /dev/v4l-subdev4
	pad0: Sink
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
	pad1: Source
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		-> "Intel IPU4 CSI-2 4 capture 0":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad2: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 4 capture 1":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad3: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 4 capture 2":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad4: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 4 capture 3":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad5: Source
		-> "Intel IPU4 CSI-2 4 meta":0 []

- entity 156: Intel IPU4 CSI-2 4 capture 0 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video20
	pad0: Sink
		<- "Intel IPU4 CSI-2 4":1 []

- entity 162: Intel IPU4 CSI-2 4 capture 1 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video21
	pad0: Sink
		<- "Intel IPU4 CSI-2 4":2 []

- entity 168: Intel IPU4 CSI-2 4 capture 2 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video22
	pad0: Sink
		<- "Intel IPU4 CSI-2 4":3 []

- entity 174: Intel IPU4 CSI-2 4 capture 3 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video23
	pad0: Sink
		<- "Intel IPU4 CSI-2 4":4 []

- entity 180: Intel IPU4 CSI-2 4 meta (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video24
	pad0: Sink
		<- "Intel IPU4 CSI-2 4":5 []

- entity 186: Intel IPU4 CSI-2 5 (6 pads, 41 links, 0 routes)
              type V4L2 subdev subtype Unknown flags 0
              device node name /dev/v4l-subdev5
	pad0: Sink
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
	pad1: Source
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		-> "Intel IPU4 CSI-2 5 capture 0":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad2: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 5 capture 1":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad3: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 5 capture 2":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad4: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 5 capture 3":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad5: Source
		-> "Intel IPU4 CSI-2 5 meta":0 []

- entity 193: Intel IPU4 CSI-2 5 capture 0 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video25
	pad0: Sink
		<- "Intel IPU4 CSI-2 5":1 []

- entity 199: Intel IPU4 CSI-2 5 capture 1 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video26
	pad0: Sink
		<- "Intel IPU4 CSI-2 5":2 []

- entity 205: Intel IPU4 CSI-2 5 capture 2 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video27
	pad0: Sink
		<- "Intel IPU4 CSI-2 5":3 []

- entity 211: Intel IPU4 CSI-2 5 capture 3 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video28
	pad0: Sink
		<- "Intel IPU4 CSI-2 5":4 []

- entity 217: Intel IPU4 CSI-2 5 meta (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video29
	pad0: Sink
		<- "Intel IPU4 CSI-2 5":5 []

- entity 223: Intel IPU4 CSI-2 6 (6 pads, 41 links, 0 routes)
              type V4L2 subdev subtype Unknown flags 0
              device node name /dev/v4l-subdev6
	pad0: Sink
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
	pad1: Source
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		-> "Intel IPU4 CSI-2 6 capture 0":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad2: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 6 capture 1":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad3: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 6 capture 2":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad4: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 6 capture 3":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad5: Source
		-> "Intel IPU4 CSI-2 6 meta":0 []

- entity 230: Intel IPU4 CSI-2 6 capture 0 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video30
	pad0: Sink
		<- "Intel IPU4 CSI-2 6":1 []

- entity 236: Intel IPU4 CSI-2 6 capture 1 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video31
	pad0: Sink
		<- "Intel IPU4 CSI-2 6":2 []

- entity 242: Intel IPU4 CSI-2 6 capture 2 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video32
	pad0: Sink
		<- "Intel IPU4 CSI-2 6":3 []

- entity 248: Intel IPU4 CSI-2 6 capture 3 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video33
	pad0: Sink
		<- "Intel IPU4 CSI-2 6":4 []

- entity 254: Intel IPU4 CSI-2 6 meta (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video34
	pad0: Sink
		<- "Intel IPU4 CSI-2 6":5 []

- entity 260: Intel IPU4 CSI-2 7 (6 pads, 42 links, 0 routes)
              type V4L2 subdev subtype Unknown flags 0
              device node name /dev/v4l-subdev7
	pad0: Sink
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		<- "ov5693 1-0036":0 []
	pad1: Source
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		-> "Intel IPU4 CSI-2 7 capture 0":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad2: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 7 capture 1":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad3: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 7 capture 2":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad4: Source
		[stream:0 fmt:unknown/0x0]
		-> "Intel IPU4 CSI-2 7 capture 3":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]
	pad5: Source
		-> "Intel IPU4 CSI-2 7 meta":0 []

- entity 267: Intel IPU4 CSI-2 7 capture 0 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video35
	pad0: Sink
		<- "Intel IPU4 CSI-2 7":1 []

- entity 273: Intel IPU4 CSI-2 7 capture 1 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video36
	pad0: Sink
		<- "Intel IPU4 CSI-2 7":2 []

- entity 279: Intel IPU4 CSI-2 7 capture 2 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video37
	pad0: Sink
		<- "Intel IPU4 CSI-2 7":3 []

- entity 285: Intel IPU4 CSI-2 7 capture 3 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video38
	pad0: Sink
		<- "Intel IPU4 CSI-2 7":4 []

- entity 291: Intel IPU4 CSI-2 7 meta (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video39
	pad0: Sink
		<- "Intel IPU4 CSI-2 7":5 []

- entity 297: Intel IPU4 TPG 0 (1 pad, 10 links, 0 routes)
              type V4L2 subdev subtype Sensor flags 0
              device node name /dev/v4l-subdev8
	pad0: Source
		[stream:0 fmt:SBGGR8_1X8/4096x3072 field:none]
		-> "Intel IPU4 TPG 0 capture":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]

- entity 299: Intel IPU4 TPG 0 capture (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video40
	pad0: Sink
		<- "Intel IPU4 TPG 0":0 []

- entity 305: Intel IPU4 TPG 1 (1 pad, 10 links, 0 routes)
              type V4L2 subdev subtype Sensor flags 0
              device node name /dev/v4l-subdev9
	pad0: Source
		[stream:0 fmt:SBGGR8_1X8/4096x3072 field:none]
		-> "Intel IPU4 TPG 1 capture":0 []
		-> "Intel IPU4 CSI2 BE":0 []
		-> "Intel IPU4 CSI2 BE SOC":0 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":1 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":2 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":3 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":4 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":5 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":6 [DYNAMIC]
		-> "Intel IPU4 CSI2 BE SOC":7 [DYNAMIC]

- entity 307: Intel IPU4 TPG 1 capture (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video41
	pad0: Sink
		<- "Intel IPU4 TPG 1":0 []

- entity 313: Intel IPU4 CSI2 BE SOC (16 pads, 280 links, 0 routes)
              type V4L2 subdev subtype Unknown flags 0
              device node name /dev/v4l-subdev10
	pad0: Sink
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		<- "Intel IPU4 CSI-2 0":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":4 [DYNAMIC]
		<- "Intel IPU4 TPG 0":0 [DYNAMIC]
		<- "Intel IPU4 TPG 1":0 [DYNAMIC]
	pad1: Sink
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		<- "Intel IPU4 CSI-2 0":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":4 [DYNAMIC]
		<- "Intel IPU4 TPG 0":0 [DYNAMIC]
		<- "Intel IPU4 TPG 1":0 [DYNAMIC]
	pad2: Sink
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		<- "Intel IPU4 CSI-2 0":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":4 [DYNAMIC]
		<- "Intel IPU4 TPG 0":0 [DYNAMIC]
		<- "Intel IPU4 TPG 1":0 [DYNAMIC]
	pad3: Sink
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		<- "Intel IPU4 CSI-2 0":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":4 [DYNAMIC]
		<- "Intel IPU4 TPG 0":0 [DYNAMIC]
		<- "Intel IPU4 TPG 1":0 [DYNAMIC]
	pad4: Sink
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		<- "Intel IPU4 CSI-2 0":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":4 [DYNAMIC]
		<- "Intel IPU4 TPG 0":0 [DYNAMIC]
		<- "Intel IPU4 TPG 1":0 [DYNAMIC]
	pad5: Sink
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		<- "Intel IPU4 CSI-2 0":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":4 [DYNAMIC]
		<- "Intel IPU4 TPG 0":0 [DYNAMIC]
		<- "Intel IPU4 TPG 1":0 [DYNAMIC]
	pad6: Sink
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		<- "Intel IPU4 CSI-2 0":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":4 [DYNAMIC]
		<- "Intel IPU4 TPG 0":0 [DYNAMIC]
		<- "Intel IPU4 TPG 1":0 [DYNAMIC]
	pad7: Sink
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		<- "Intel IPU4 CSI-2 0":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 0":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 1":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 2":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 3":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 4":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 5":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 6":4 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":1 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":2 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":3 [DYNAMIC]
		<- "Intel IPU4 CSI-2 7":4 [DYNAMIC]
		<- "Intel IPU4 TPG 0":0 [DYNAMIC]
		<- "Intel IPU4 TPG 1":0 [DYNAMIC]
	pad8: Source
		[stream:0 fmt:unknown/0x0
		 crop:(0,0)/0x0]
		-> "Intel IPU4 BE SOC capture 0":0 [DYNAMIC]
	pad9: Source
		[stream:0 fmt:unknown/0x0
		 crop:(0,0)/0x0]
		-> "Intel IPU4 BE SOC capture 1":0 [DYNAMIC]
	pad10: Source
		[stream:0 fmt:unknown/0x0
		 crop:(0,0)/0x0]
		-> "Intel IPU4 BE SOC capture 2":0 [DYNAMIC]
	pad11: Source
		[stream:0 fmt:unknown/0x0
		 crop:(0,0)/0x0]
		-> "Intel IPU4 BE SOC capture 3":0 [DYNAMIC]
	pad12: Source
		[stream:0 fmt:unknown/0x0
		 crop:(0,0)/0x0]
		-> "Intel IPU4 BE SOC capture 4":0 [DYNAMIC]
	pad13: Source
		[stream:0 fmt:unknown/0x0
		 crop:(0,0)/0x0]
		-> "Intel IPU4 BE SOC capture 5":0 [DYNAMIC]
	pad14: Source
		[stream:0 fmt:unknown/0x0
		 crop:(0,0)/0x0]
		-> "Intel IPU4 BE SOC capture 6":0 [DYNAMIC]
	pad15: Source
		[stream:0 fmt:unknown/0x0
		 crop:(0,0)/0x0]
		-> "Intel IPU4 BE SOC capture 7":0 [DYNAMIC]

- entity 330: Intel IPU4 BE SOC capture 0 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video42
	pad0: Sink
		<- "Intel IPU4 CSI2 BE SOC":8 [DYNAMIC]

- entity 336: Intel IPU4 BE SOC capture 1 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video43
	pad0: Sink
		<- "Intel IPU4 CSI2 BE SOC":9 [DYNAMIC]

- entity 342: Intel IPU4 BE SOC capture 2 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video44
	pad0: Sink
		<- "Intel IPU4 CSI2 BE SOC":10 [DYNAMIC]

- entity 348: Intel IPU4 BE SOC capture 3 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video45
	pad0: Sink
		<- "Intel IPU4 CSI2 BE SOC":11 [DYNAMIC]

- entity 354: Intel IPU4 BE SOC capture 4 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video46
	pad0: Sink
		<- "Intel IPU4 CSI2 BE SOC":12 [DYNAMIC]

- entity 360: Intel IPU4 BE SOC capture 5 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video47
	pad0: Sink
		<- "Intel IPU4 CSI2 BE SOC":13 [DYNAMIC]

- entity 366: Intel IPU4 BE SOC capture 6 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video48
	pad0: Sink
		<- "Intel IPU4 CSI2 BE SOC":14 [DYNAMIC]

- entity 372: Intel IPU4 BE SOC capture 7 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video49
	pad0: Sink
		<- "Intel IPU4 CSI2 BE SOC":15 [DYNAMIC]

- entity 378: Intel IPU4 CSI2 BE (2 pads, 36 links, 0 routes)
              type V4L2 subdev subtype Unknown flags 0
              device node name /dev/v4l-subdev11
	pad0: Sink
		[stream:0 fmt:SBGGR14_1X14/4096x3072 field:none]
		<- "Intel IPU4 CSI-2 0":1 []
		<- "Intel IPU4 CSI-2 0":2 []
		<- "Intel IPU4 CSI-2 0":3 []
		<- "Intel IPU4 CSI-2 0":4 []
		<- "Intel IPU4 CSI-2 1":1 []
		<- "Intel IPU4 CSI-2 1":2 []
		<- "Intel IPU4 CSI-2 1":3 []
		<- "Intel IPU4 CSI-2 1":4 []
		<- "Intel IPU4 CSI-2 2":1 []
		<- "Intel IPU4 CSI-2 2":2 []
		<- "Intel IPU4 CSI-2 2":3 []
		<- "Intel IPU4 CSI-2 2":4 []
		<- "Intel IPU4 CSI-2 3":1 []
		<- "Intel IPU4 CSI-2 3":2 []
		<- "Intel IPU4 CSI-2 3":3 []
		<- "Intel IPU4 CSI-2 3":4 []
		<- "Intel IPU4 CSI-2 4":1 []
		<- "Intel IPU4 CSI-2 4":2 []
		<- "Intel IPU4 CSI-2 4":3 []
		<- "Intel IPU4 CSI-2 4":4 []
		<- "Intel IPU4 CSI-2 5":1 []
		<- "Intel IPU4 CSI-2 5":2 []
		<- "Intel IPU4 CSI-2 5":3 []
		<- "Intel IPU4 CSI-2 5":4 []
		<- "Intel IPU4 CSI-2 6":1 []
		<- "Intel IPU4 CSI-2 6":2 []
		<- "Intel IPU4 CSI-2 6":3 []
		<- "Intel IPU4 CSI-2 6":4 []
		<- "Intel IPU4 CSI-2 7":1 []
		<- "Intel IPU4 CSI-2 7":2 []
		<- "Intel IPU4 CSI-2 7":3 []
		<- "Intel IPU4 CSI-2 7":4 []
		<- "Intel IPU4 TPG 0":0 []
		<- "Intel IPU4 TPG 1":0 []
	pad1: Source
		[stream:0 fmt:SBGGR14_1X14/4096x3072 field:none
		 crop:(0,0)/4096x3072]
		-> "Intel IPU4 CSI2 BE capture":0 []
		-> "Intel IPU4 ISA":0 []

- entity 381: Intel IPU4 CSI2 BE capture (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video50
	pad0: Sink
		<- "Intel IPU4 CSI2 BE":1 []

- entity 387: Intel IPU4 ISA (5 pads, 5 links, 0 routes)
              type V4L2 subdev subtype Unknown flags 0
              device node name /dev/v4l-subdev12
	pad0: Sink
		[stream:0 fmt:SBGGR14_1X14/4096x3072 field:none]
		<- "Intel IPU4 CSI2 BE":1 []
	pad1: Source
		[stream:0 fmt:SBGGR12_1X12/4096x3072 field:none
		 crop:(0,0)/4096x3072]
		-> "Intel IPU4 ISA capture":0 []
	pad2: Sink
		[stream:0 fmt:FIXED/0x0]
		<- "Intel IPU4 ISA config":0 []
	pad3: Source
		[stream:0 fmt:FIXED/0x0]
		-> "Intel IPU4 ISA 3A stats":0 []
	pad4: Source
		[stream:0 fmt:SBGGR12_1X12/4096x3072 field:none
		 crop:(0,0)/4096x3072
		 compose:(0,0)/4096x3072]
		-> "Intel IPU4 ISA scaled capture":0 []

- entity 393: Intel IPU4 ISA capture (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video51
	pad0: Sink
		<- "Intel IPU4 ISA":1 []

- entity 399: Intel IPU4 ISA config (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video52
	pad0: Source
		-> "Intel IPU4 ISA":2 []

- entity 405: Intel IPU4 ISA 3A stats (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video53
	pad0: Sink
		<- "Intel IPU4 ISA":3 []

- entity 411: Intel IPU4 ISA scaled capture (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video54
	pad0: Sink
		<- "Intel IPU4 ISA":4 []

- entity 1057: ov8865 2-0010 (1 pad, 1 link, 0 routes)
               type V4L2 subdev subtype Sensor flags 0
               device node name /dev/v4l-subdev13
	pad0: Source
		[stream:0 fmt:SBGGR10_1X10/3264x2448 field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range
		 crop.bounds:(16,40)/3264x2448
		 crop:(16,40)/3264x2448]
		-> "Intel IPU4 CSI-2 3":0 []

- entity 1063: ov5693 1-0036 (1 pad, 1 link, 0 routes)
               type V4L2 subdev subtype Sensor flags 0
               device node name /dev/v4l-subdev14
	pad0: Source
		[stream:0 fmt:SBGGR10_1X10/2592x1944
		 crop.bounds:(16,6)/2592x1944
		 crop:(16,6)/2592x1944]
		-> "Intel IPU4 CSI-2 7":0 []

- entity 1069: dw9719 2-000c (0 pad, 0 link, 0 routes)
               type V4L2 subdev subtype Lens flags 0
               device node name /dev/v4l-subdev15
```
</details></br>

This gives the current links between camera subdevices, and each subdevice current pads configuration such as, format, resolution, framerate.

This topology can also be displayed in a human readable graphical form thanks to `--print-dot` option:

```bash
media-ctl -d /dev/media0 --print-dot | dot -Tpng > media0-graph.png
```

![image](/assets/media0-graph.png)

# 3. Camera subsystem setup

In order to be able to capture frames from video device node with v4l2-ctl, GStreamer or any other V4L2 application, the camera subsystem must be first configured. To do so use `media-ctl --set-v4l2` command giving the subdevice name & pad, the desired format, resolution and framerate:

```bash
media-ctl -V '"ov8865 2-0010":0 [fmt:SBGGR10_1X10/3264x2448 field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range crop:(16,40)/3264x2448]'
```

The configuration must be done from source to sink. Below is a configuration allowing to capture SBGGR10 3264x2448 frames:

```bash
RESOLUTION=3264x2448
FMT=SBGGR10_1X10

media-ctl -V "\"ov8865 2-0010\":0 [fmt:$FMT/$RESOLUTION field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range]"

media-ctl -V "\"Intel IPU4 CSI-2 3\":0 [fmt:$FMT/$RESOLUTION field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range]"

media-ctl -V "\"Intel IPU4 CSI-2 3\":1 [fmt:$FMT/$RESOLUTION field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range]"
```

Any application that read frames from V4L2 video device node can be executed:
> [!WARNING]
> Application must configure V4L2 device node with exactly the same format, resolution and framerate that the ones being set at camera subsystem setup!

```bash
gst-launch-1.0 v4l2src ! video/x-raw, format=SBGGR10P, width=3264,height=2448, framerate=30/1 ! queue ! waylandsink fullscreen=true
```

# 4. Controlling camera sensor

In order to control camera sensor, its corresponding entity device node must be found in the topology. To do so, the first entity of the graph must be found, ie the entity having no sink pad:

```
- entity 1057: ov8865 2-0010 (1 pad, 1 link, 0 routes)
               type V4L2 subdev subtype Sensor flags 0
               device node name /dev/v4l-subdev13
	pad0: Source
		[stream:0 fmt:SBGGR10_1X10/3264x2448 field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range
		 crop.bounds:(16,40)/3264x2448
		 crop:(16,40)/3264x2448]
		-> "Intel IPU4 CSI-2 3":0 []
```
Here it is `/dev/v4l-subdev13`.

Use then `v4l2-ctl` with `-L` option to get the list of supported controls:

> [!NOTE]
> "value=" field returns the current value of the control

```bash
v4l2-ctl -d /dev/v4l-subdev13 -L
```

<details>
  <summary>
    click to show the output
  </summary>

```
User Controls

                    red_balance 0x0098090e (int)    : min=1 max=32767 step=1 default=1024 value=1024 flags=slider
                   blue_balance 0x0098090f (int)    : min=1 max=32767 step=1 default=1024 value=1024 flags=slider
                       exposure 0x00980911 (int)    : min=2 max=2462 step=1 default=32 value=32
                horizontal_flip 0x00980914 (bool)   : default=0 value=0
                  vertical_flip 0x00980915 (bool)   : default=0 value=0

Camera Controls

             camera_orientation 0x009a0922 (menu)   : min=0 max=2 default=2 value=2 (External) flags=read-only
                                0: Front
                                1: Back
                                2: External
         camera_sensor_rotation 0x009a0923 (int)    : min=180 max=180 step=1 default=180 value=180 flags=read-only

Image Source Controls

              vertical_blanking 0x009e0901 (int)    : min=4 max=63087 step=1 default=22 value=22
            horizontal_blanking 0x009e0902 (int)    : min=624 max=624 step=1 default=624 value=624 flags=read-only
                  analogue_gain 0x009e0903 (int)    : min=128 max=2048 step=128 default=128 value=128

Image Processing Controls

                 link_frequency 0x009f0901 (intmenu): min=0 max=0 default=0 value=0 (360000000 0x15752a00) flags=read-only
                                0: 360000000 (0x15752a00)
                     pixel_rate 0x009f0902 (int64)  : min=1 max=2147483647 step=1 default=1 value=288000000 flags=read-only
                   test_pattern 0x009f0903 (menu)   : min=0 max=5 default=0 value=0 (Disabled)
                                0: Disabled
                                1: Random data
                                2: Color bars
                                3: Color bars with rolling bar
                                4: Color squares
                                5: Color squares with rolling bar
```
</details></br>

The control value can be changed thanks to --set-ctrl option, for example:

```bash
v4l2-ctl -d /dev/v4l-subdev13 --set-ctrl test_pattern=5
```

The control value can be changed dynamically. In the following example, the color bar is enabled/disabled while preview is running:

Start preview in background:
```bash
gst-launch-1.0 v4l2src ! "video/x-raw, format=SBGGR10P, width=3264, height=2448, framerate=(fraction)30/1" ! queue ! waylandsink fullscreen=true -e &
```

Horizontal/vertical flip can also be changed while preview is running:
```bash
v4l2-ctl -d /dev/v4l-subdev13 --set-ctrl horizontal_flip=1
sleep 2
v4l2-ctl -d /dev/v4l-subdev13 --set-ctrl horizontal_flip=0
sleep 2
v4l2-ctl -d /dev/v4l-subdev13 --set-ctrl vertical_flip=1
sleep 2
v4l2-ctl -d /dev/v4l-subdev13 --set-ctrl vertical_flip=0
killall gst-launch-1.0
```

# 5. Set the camera sensor pixel format, resolution and framerate

Camera sensor only supports a discrete set of formats, resolutions and framerates that can be get thanks to v4l2-ctl options `--list-subdev-mbus-codes`, `--list-subdev-framesizes` and `--list-subdev-frameintervals`:

```bash
v4l2-ctl -d /dev/v4l-subdev13 --list-subdev-mbus-codes

ioctl: VIDIOC_SUBDEV_ENUM_MBUS_CODE (pad=0,stream=0)
        0x3007: MEDIA_BUS_FMT_SBGGR10_1X10
```

Frame size might depend on frame format, so precise it when asking for frame size:

```bash
v4l2-ctl -d /dev/v4l-subdev13 --list-subdev-framesizes pad=0,code=0x3007

ioctl: VIDIOC_SUBDEV_ENUM_FRAME_SIZE (pad=0,stream=0)
        Size Range: 3264x2448 - 3264x2448
        Size Range: 3264x1836 - 3264x1836
        Size Range: 1632x1224 - 1632x1224
        Size Range: 800x600 - 800x600
```

## Frame interval configuration <sup>[[source]](https://www.kernel.org/doc/html/latest/userspace-api/media/drivers/camera-sensor.html#frame-interval-configuration)</sup>

There are two different methods for obtaining possibilities for different frame intervals as well as configuring the frame interval. Which one to implement depends on the type of the device.

### USB cameras etc. devices

USB video class hardware, as well as many cameras offering a similar higher level interface natively, generally use the concept of frame interval (or frame rate) on device level in firmware or hardware. This means lower level controls implemented by raw cameras may not be used on uAPI (or even kAPI) to control the frame interval on these devices.

Framerate depends on resolution and format, so precise them when asking for frame intervals:

```bash
v4l2-ctl -d /dev/v4l-subdev13 --list-subdev-frameintervals pad=0,width=3264,height=2448,code=0x3007

ioctl: VIDIOC_SUBDEV_ENUM_FRAME_INTERVAL (pad=0,stream=0)
<empty because we are using a raw camera sensor>
```

### Raw camera sensors

Instead of a high level parameter such as frame interval, the frame interval is a result of the configuration of a number of camera sensor implementation specific parameters. Luckily, these parameters tend to be the same for more or less all modern raw camera sensors.

The frame interval is calculated using the following equation:

```
frame interval = (analogue crop width + horizontal blanking) *
                 (analogue crop height + vertical blanking) / pixel rate

Total Pixels per Line: 3264 + 624 = 3888
Total Lines per Frame: 2448 + 22 = 2470
Total Pixels per Frame: 3888 x 2470 = 9,603,360
Frame Interval: 9,603,360 / 288,000,000 = ~0.033345 seconds
Calculated Frame Rate (FPS): 1 / 0.033345 = ~29.99 fps
```

Now that camera sensor capabilities are known, the wanted configuration can be set following instructions described in the camera subsystem setup section.

```bash
RESOLUTION=3264x2448
FMT=SBGGR10_1X10

media-ctl -V "\"ov8865 2-0010\":0 [fmt:$FMT/$RESOLUTION field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range]"

media-ctl -V "\"Intel IPU4 CSI-2 3\":0 [fmt:$FMT/$RESOLUTION field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range]"

media-ctl -V "\"Intel IPU4 CSI-2 3\":1 [fmt:$FMT/$RESOLUTION field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range]"

gst-launch-1.0 v4l2src ! "video/x-raw, format=SBGGR10P, width=3264, height=2448, framerate=(fraction)30/1" ! queue ! waylandsink fullscreen=true 
```

> [!WARNING]
> Please note that GStreamer parameters must fit exactly the same format, resolution and framerate that the ones being set with `media-ctl`!

# 6. Downscale and crop

# 7. Grab a raw frame

# 8. Fullscreen preview

# 9. Take a picture in JPEG format

# 10. Preview in YUV422

# 11. Grab a raw-bayer frame

# 12. Raw-bayer capture with preview

