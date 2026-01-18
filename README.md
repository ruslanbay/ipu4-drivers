[Discussion](https://github.com/linux-surface/linux-surface/discussions/1353?sort=new) | 
[Wiki](https://github.com/linux-surface/linux-surface/wiki/Camera-Support) | 
[Source](https://github.com/intel/linux-intel-lts/tree/lts-v5.15.195-android_t-251103T063840Z/drivers/media/pci/intel)

# How to build an Upstream Linux kernel

## Requirements

* Ubuntu 25.10
* ~30GB free storage space

## 1. Enable devices in UEFI <sup>[ref](https://learn.microsoft.com/en-us/surface/manage-surface-uefi-settings)</sup>

If you plan to use a device-specific kernel configuration, make sure **all hardware devices are enabled in UEFI**:

1. Power off the device and wait ~10 seconds.
2. Press and hold **Volume Up**, then press and release **Power**.
3. Keep holding **Volume Up** until the UEFI menu appears.
4. Open **Devices** and ensure all devices are enabled.

This step is required for cameras and related controllers to be detected.

![image](assets/manage-surface-uefi.png)

## 2. Install required packages

Install build dependencies:

```bash
sudo apt update && \
    sudo apt build-dep -y linux linux-image-unsigned-$(uname -r) && \
    sudo apt install -y fakeroot llvm libncurses-dev dwarves
```

Optional but recommended packages:

```bash
sudo apt install -y git gawk flex bison openssl libssl-dev dkms autoconf \
    libelf-dev libudev-dev libpci-dev libiberty-dev
```

## 3. Clone the ipu4-next repo

```bash
git clone -b upstream-6.1 \
    https://github.com/ruslanbay/ipu4-next
```

This repository contains the IPU4 patch set.

## 4. Download the Linux kernel source

```bash
git clone -b v6.1.159 --single-branch --depth=1 \
    https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git linux
```

Use the kernel version that matches the patch set.

## 5. Apply patches

```bash
cd linux

git am ../ipu4-next/patches/kernel/v6.1.159/*.patch
```

## 6. Kernel Configuration

### 6.1. Copy Base Configuration

`cp ../ipu4-next/configs/config-6.1.159-0601159-generic ./.config`

### 6.2 Set Cryptographic Keys

Clear system trusted and revocation keys in the configuration to prevent common build errors:

```bash
./scripts/config --set-str CONFIG_SYSTEM_TRUSTED_KEYS ""
./scripts/config --set-str CONFIG_SYSTEM_REVOCATION_KEYS ""
```

### 6.3. (Optional) Optimize Build Time

#### 6.3.1 Optimize for the Current Host Only

Optimize the kernel to include only modules enabled on the machine you are building from. The resulting kernel will only work correctly on this specific hardware.

`make localmodconfig`

#### 6.3.2 Disable Debug Packages

Prevent the creation of the large -dbg debug information packages during make bindeb-pkg or make deb-pkg runs.

```bash
# Disable generic debug info flags
./scripts/config --disable DEBUG_INFO
./scripts/config --disable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
./scripts/config --disable DEBUG_INFO_DWARF4
./scripts/config --disable DEBUG_INFO_DWARF5

# Explicitly enable "No Debug Information"
./scripts/config --enable DEBUG_INFO_NONE
```

### 6.4. Enable IPU and Sensor Drivers

Launch the interactive configuration menu to enable necessary drivers:

`make menuconfig`

IPU related options:

```
Device Drivers >
  Multimedia support >
    Media drivers >
	  Media PCI Adapters

<M> Intel IPU Bridge
<M> Intel IPU driver
      intel ipu generation type (Compile for IPU4 driver)
        (X) Compile for IPU4P driver
      intel ipu hardware platform type (Compile for SOC)
        (X) Compile for SOC
<M> Compile firmware library
```

Camera sensors:

```
Device Drivers >
  Multimedia support >
    Media ancillary drivers >
	  Camera sensor devices

<M> OmniVision OV5693 sensor support
<M> OmniVision OV7251 sensor support
<M> OmniVision OV8865 sensor support
<M> OmniVision OV9734 sensor support
```

INT3472 (camera power controller):

```
Device Drivers >
  X86 Platform Specific Device Drivers

<M> Intel SkyLake ACPI INT3472 Driver
```

## 7. Build the kernel

```bash
make clean && \
    make -j$(nproc) bindeb-pkg LOCALVERSION=-surface
```

If the build succeeds, `.deb` packages will appear in the parent directory.

## 8. Install the new kernel

Install all generated packages and reboot:

```bash
sudo apt install ../linux-headers-*.deb ../linux-image-*.deb

sudo reboot
```

## 9. Install IPU4 firmware

Copy one firmware blob to `/usr/lib/firmware/ipu4p_cpd.bin`

|Name|Source|Notes|
|-|-|-|
|[ipu4-20170209.bin](https://media.githubusercontent.com/media/ruslanbay/ipu4-next/refs/heads/main/firmware/ipu4-20170209.bin)|[Intel-5xx-Camera/intel-camera-adaptation](https://github.com/Intel-5xx-Camera/intel-camera-adaptation)|untested, [virustotal](https://www.virustotal.com/gui/file/0a9bf4ea62f1538c43f0ced511778a200f3d08b4c8d0f3c8fbe214d3f3f338d1/details)|
|[ipu4-20180316.bin](https://media.githubusercontent.com/media/ruslanbay/ipu4-next/refs/heads/main/firmware/ipu4-20180316.bin)|[RajmohanMani/ipu4pfw](https://github.com/RajmohanMani/ipu4pfw)|untested, [virustotal](https://www.virustotal.com/gui/file/c3e545014e984237c82ddd55183ae14b242c2ba05d6955f8fa110e8d3dc9759e/details)|
|[ipu4-20190407.bin](https://media.githubusercontent.com/media/ruslanbay/ipu4-next/refs/heads/main/firmware/ipu4-20190407.bin)|[Intel - Camera - 42.17134.3.10471](https://www.catalog.update.microsoft.com/Search.aspx?q=42.17134.3.10471)|tested, [virustotal](https://www.virustotal.com/gui/file/ee534f37f979dfc20e1cb4681bae47c9ec57639f3a2d032b79d77b3097b74d97/details)|
|[ipu4-20191030.bin](https://media.githubusercontent.com/media/ruslanbay/ipu4-next/refs/heads/main/firmware/ipu4-20191030.bin)|[Intel - Camera - 42.18362.3.16827](https://www.catalog.update.microsoft.com/Search.aspx?q=42.18362.3.16827)|tested, [virustotal](https://www.virustotal.com/gui/file/ff2c36cc81a5c726508b22970c2e2538ff06107dc5a72c93401403c227e5157f/details)|
|[ipu4-20200609.bin](https://media.githubusercontent.com/media/ruslanbay/ipu4-next/refs/heads/main/firmware/ipu4-20200609.bin)|[intel/ipu4-cam-hal](https://github.com/intel/ipu4-cam-hal/tree/main/IPU_binary/lib/firmware)|tested, [virustotal](https://www.virustotal.com/gui/file/9829f9a592365aa8295e394aa2b350e5e72f818c3e667225b2b31564b3827824/details)|

```
sudo cp ../ipu4-next/firmware/ipu4-20191030.bin /usr/lib/firmware/ipu4p_cpd.bin

sudo reboot
```

## 10. Known issues and workarounds

### 10.1. Moduledata and library version mismatch

Issue:

```
journalctl -b | grep -i "ipu"

[    4.074538] intel-ipu4 intel-ipu: Moduledata and library version mismatch (20191030 != 20181222)
[    4.074652] intel-ipu4 intel-ipu: Invalid moduledata
[    4.074713] intel-ipu4 intel-ipu: Failed to validate cpd
[    4.074909] intel-ipu4: probe of intel-ipu failed with error -22
```

Workaround:

```bash
echo "options intel_ipu4p fw_version_check=0" | sudo tee /etc/modprobe.d/ipu4.conf

sudo systemctl reboot
```

### 10.2. No media graph when the user-facing camera is enabled

Workaround:

1. Open the Devices section in the UEFI Menu
2. Disable all sensors except the rear camera
3. If the issue persists, test different combinations (e.g., only front camera, or front + IR cameras) until the system recognizes the hardware.

## 11. Test the IPU4 driver

`media-ctl -d /dev/media0 --print-dot | dot -Tpng > media0-graph.png`

![image](assets/media0-graph.png)

<details>
  <summary>
    <strong>
      journalctl -b | grep -Ei "ipu|ov5693|INT33BE|ov8865|dw9719|INT347"
    </strong>
  </summary>

```
Dec 20 20:20:19 pc kernel: intel-ipu4 intel-ipu: enabling device (0000 -> 0002)
Dec 20 20:20:19 pc kernel: intel-ipu4 intel-ipu: Device 0x8a19 (rev: 0x3)
Dec 20 20:20:19 pc kernel: intel-ipu4 intel-ipu: physical base address 0x6000000000
Dec 20 20:20:19 pc kernel: intel-ipu4 intel-ipu: mapped as: 0x0000000074592112
Dec 20 20:20:19 pc kernel: intel-ipu4 intel-ipu: update security control register failed
Dec 20 20:20:19 pc kernel: intel-ipu4 intel-ipu: Unable to set secure mode!
Dec 20 20:20:19 pc kernel: intel-ipu4 intel-ipu: IPU in secure mode
Dec 20 20:20:19 pc kernel: intel-ipu4 intel-ipu: cpd file name: ipu4p_cpd.bin
Dec 20 20:20:19 pc kernel: intel-ipu4 intel-ipu: Moduledata version: 20191030, library version: 20181222
Dec 20 20:20:19 pc kernel: intel-ipu4 intel-ipu: CSS release: 20181222
Dec 20 20:20:19 pc kernel: acpi INT347A:00: _PLD call failed, using default orientation
Dec 20 20:20:19 pc kernel: intel-ipu4 intel-ipu: Found supported sensor INT347A:00
Dec 20 20:20:19 pc kernel: intel-ipu4 intel-ipu: Connected 1 cameras
Dec 20 20:20:19 pc kernel: intel-ipu4 intel-ipu: IPU driver verion 1.0
Dec 20 20:20:19 pc kernel: intel-ipu4-mmu intel-ipu4-mmu0: MMU: 1, allocated page for trash: 0x0000000080980377
Dec 20 20:20:19 pc kernel: intel-ipu4-mmu intel-ipu4-mmu0: mmu is not ready yet. skipping.
Dec 20 20:20:19 pc kernel: intel-ipu4-mmu intel-ipu4-mmu1: MMU: 0, allocated page for trash: 0x000000004cab7b66
Dec 20 20:20:19 pc kernel: ov8865 i2c-INT347A:00: supply dvdd not found, using dummy regulator
Dec 20 20:20:19 pc kernel: ov8865 i2c-INT347A:00: supply dovdd not found, using dummy regulator
Dec 20 20:20:20 pc kernel: intel-ipu4-mmu intel-ipu4-mmu0: mmu is not ready yet. skipping.
Dec 20 20:20:20 pc kernel: intel-ipu4-mmu intel-ipu4-mmu0: iova trash buffer for MMUID: 1 is 4286578688
Dec 20 20:20:20 pc kernel: intel-ipu4-isys intel-ipu4-isys0: isys probe 000000005b7be633 000000005b7be633
Dec 20 20:20:20 pc kernel: intel-ipu4-isys intel-ipu4-isys0: Entity type for entity Intel IPU4 CSI-2 0 was not initialized!
Dec 20 20:20:20 pc kernel: intel-ipu4-isys intel-ipu4-isys0: Entity type for entity Intel IPU4 CSI-2 1 was not initialized!
Dec 20 20:20:20 pc kernel: intel-ipu4-isys intel-ipu4-isys0: Entity type for entity Intel IPU4 CSI-2 2 was not initialized!
Dec 20 20:20:20 pc kernel: intel-ipu4-isys intel-ipu4-isys0: Entity type for entity Intel IPU4 CSI-2 3 was not initialized!
Dec 20 20:20:20 pc kernel: intel-ipu4-isys intel-ipu4-isys0: Entity type for entity Intel IPU4 CSI-2 4 was not initialized!
Dec 20 20:20:20 pc kernel: intel-ipu4-mmu intel-ipu4-mmu1: mmu is not ready yet. skipping.
Dec 20 20:20:20 pc kernel: intel-ipu4 intel-ipu: Sending BOOT_LOAD to CSE
Dec 20 20:20:20 pc kernel: intel-ipu4-isys intel-ipu4-isys0: Entity type for entity Intel IPU4 CSI2 BE SOC was not initialized!
Dec 20 20:20:20 pc kernel: intel-ipu4-isys intel-ipu4-isys0: Entity type for entity Intel IPU4 CSI2 BE was not initialized!
Dec 20 20:20:20 pc kernel: intel-ipu4-isys intel-ipu4-isys0: Entity type for entity Intel IPU4 ISA was not initialized!
Dec 20 20:20:20 pc kernel: intel-ipu4-isys intel-ipu4-isys0: no subdevice info provided
Dec 20 20:20:20 pc kernel: ov8865 i2c-INT347A:00: Consider updating driver ov8865 to match on endpoints
Dec 20 20:20:20 pc kernel: intel-ipu4-mmu intel-ipu4-mmu1: iova trash buffer for MMUID: 0 is 4286578688
Dec 20 20:20:20 pc kernel: intel-ipu4-psys intel-ipu4-psys0: pkg_dir entry count:12
Dec 20 20:20:25 pc kernel: ov8865 i2c-INT347A:00: Instantiated dw9719 VCM
Dec 20 20:20:25 pc kernel: intel-ipu4-isys intel-ipu4-isys0: FW authentication failed
Dec 20 20:20:25 pc kernel: intel-ipu4 intel-ipu: Sending BOOT_LOAD to CSE
Dec 20 20:20:25 pc kernel: intel-ipu4 intel-ipu: expected resp: 0x1, IPC response: 0x220 
Dec 20 20:20:25 pc kernel: intel-ipu4 intel-ipu: CSE boot_load failed
Dec 20 20:20:25 pc kernel: intel-ipu4-isys intel-ipu4-isys0: FW authentication failed
Dec 20 20:20:25 pc kernel: intel-ipu4 intel-ipu: Sending BOOT_LOAD to CSE
Dec 20 20:20:25 pc kernel: intel-ipu4 intel-ipu: Sending AUTHENTICATE_RUN to CSE
Dec 20 20:20:25 pc kernel: intel-ipu4-psys intel-ipu4-psys0: psys probe minor: 0
Dec 20 20:20:25 pc kernel: dw9719 i2c-INT347A:00-VCM: supply vdd not found, using dummy regulator
```
</details></br>

<details>
  <summary>
    <strong>
      v4l2-ctl --list-devices
    </strong>
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

ipu4p (pci:intel-ipu):
	/dev/media0
```
</details></br>

<details>
  <summary>
    <strong>
      modinfo intel_ipu4p
    </strong>
  </summary>

```
filename:       /lib/modules/6.1.158-sp7/kernel/drivers/media/pci/intel/ipu4/intel-ipu4p.ko
description:    Intel ipu pci driver
license:        GPL
author:         Intel
author:         Kun Jiang <kun.jiang@intel.com>
author:         Xia Wu <xia.wu@intel.com>
author:         Leifu Zhao <leifu.zhao@intel.com>
author:         Zaikuo Wang <zaikuo.wang@intel.com>
author:         Yunliang Ding <yunliang.ding@intel.com>
author:         Bingbu Cao <bingbu.cao@intel.com>
author:         Renwei Wu <renwei.wu@intel.com>
author:         Tianshu Qiu <tian.shu.qiu@intel.com>
author:         Jianxu Zheng <jian.xu.zheng@intel.com>
author:         Samu Onkalo <samu.onkalo@intel.com>
author:         Antti Laakso <antti.laakso@intel.com>
author:         Jouni Högander <jouni.hogander@intel.com>
author:         Sakari Ailus <sakari.ailus@linux.intel.com>
import_ns:      INTEL_IPU_BRIDGE
description:    Intel ipu mmu driver
license:        GPL
author:         Samu Onkalo <samu.onkalo@intel.com>
author:         Sakari Ailus <sakari.ailus@linux.intel.com>
description:    Intel ipu trace support
license:        GPL
author:         Samu Onkalo <samu.onkalo@intel.com>
description:    Intel ipu fw comm library
license:        GPL
srcversion:     6D37483DC828509F35346DE
alias:          pci:v00008086d00008A19sv*sd*bc*sc*i*
depends:        ipu-bridge
retpoline:      Y
intree:         Y
name:           intel_ipu4p
vermagic:       6.1.158-sp7 SMP preempt mod_unload modversions 
sig_id:         PKCS#7
signer:         Build time autogenerated kernel key
sig_key:        3F:01:26:01:F4:91:0C:F1:76:15:5C:19:A4:0E:0B:15:48:04:19:64
sig_hashalgo:   sha512
signature:      68:D7:72:A9:1A:A2:E5:A7:F9:05:A8:E6:B2:13:04:FD:B1:49:6A:2F:
		36:BF:93:E7:50:82:76:72:0D:FB:8F:2B:36:29:06:73:08:61:87:58:
		21:F9:80:3A:9D:F8:C1:C3:FD:EA:C3:65:EA:6D:A9:A2:A6:39:E5:A1:
		C5:3B:DD:C5:C6:2B:C4:A6:B4:DF:D2:6A:F5:FC:BA:E2:3A:12:4B:73:
		58:13:0A:73:AE:7D:39:E8:AF:EE:EF:F6:02:17:23:FD:D1:D7:8D:17:
		FA:7A:63:59:59:8D:86:53:84:53:7A:31:FD:00:C1:27:15:F1:2E:53:
		2E:22:5C:46:17:FE:A2:23:C8:DD:1A:91:40:51:FC:B6:97:46:34:AA:
		D0:C5:84:F2:44:56:99:18:B6:0A:D1:5F:B0:81:3C:1A:80:3A:88:94:
		8B:92:8A:D4:94:26:FE:69:63:43:37:84:F7:33:5E:30:2E:7D:4C:F4:
		08:B1:BD:F3:3F:72:74:26:89:5E:DF:19:61:A5:72:5A:94:B8:61:D5:
		AB:19:4E:37:95:37:5F:3C:75:53:60:4E:53:B3:4B:6B:82:23:1B:C5:
		A9:84:47:B0:64:72:D9:41:71:C0:69:47:FD:61:88:C8:16:5F:26:10:
		AD:A2:88:67:AC:07:EE:E8:63:EB:DC:41:AF:16:8F:64:C9:8F:DD:7C:
		64:92:9D:D3:AF:AC:E6:76:AE:EC:0D:56:C6:50:0B:3B:DF:5E:D1:70:
		DA:16:9F:FC:FE:8B:5E:45:41:51:C7:71:39:62:AD:12:CC:A2:34:FF:
		7C:35:6F:34:66:6E:F7:59:8A:ED:2F:5A:47:FB:29:DC:E7:FB:18:E9:
		E9:43:5C:64:99:25:3B:19:FA:D9:58:2B:8B:24:9D:D8:F1:F1:9F:AA:
		D2:99:B3:C5:13:30:43:DA:4C:B2:A5:06:12:D4:AE:E2:2E:D2:32:F1:
		23:50:31:CC:0C:6D:1F:6B:36:18:A1:FA:92:6F:85:8D:DE:3B:FB:0D:
		C4:E7:14:00:1C:F3:25:AC:D7:64:E5:86:28:2A:9A:65:29:F0:E7:9C:
		64:EE:F4:A6:BD:30:06:B2:EF:5A:07:E8:D1:D5:8F:CD:3F:57:9A:9C:
		EC:5A:CC:F7:C4:83:A3:0D:D5:A1:EE:27:A1:6E:70:AC:CE:C6:05:FA:
		4E:94:7C:23:FF:37:65:1E:23:99:4A:9F:AE:64:2E:24:F7:96:37:6A:
		37:04:83:C3:F9:29:61:7B:4D:D4:FA:92:3F:54:93:B4:F4:CE:25:1A:
		5C:AE:2E:92:18:E1:5A:89:5D:FE:0A:BC:77:42:65:10:2C:D8:9B:4A:
		FE:28:22:44:E8:23:4C:58:6B:4B:27:F6
parm:           fw_version_check:enable/disable checking firmware version (bool)
parm:           secure_mode_enable:bool
parm:           secure_mode:IPU secure mode enable
```
</details></br>

<details>
  <summary>
    <strong>
      lsmod | grep -Ei "ipu|ov5693|INT33BE|ov8865|dw9719|INT347"
    </strong>
  </summary>

```
dw9719                 16384  1
v4l2_cci               16384  1 dw9719
intel_ipu4p_psys       65536  0
intel_ipu4p_psys_csslib   147456  1 intel_ipu4p_psys
intel_ipu4p_isys      172032  0
videobuf2_dma_contig    24576  1 intel_ipu4p_isys
intel_ipu4p_isys_csslib    65536  1 intel_ipu4p_isys
intel_skl_int3472_tps68470    20480  0
videobuf2_v4l2         32768  1 intel_ipu4p_isys
videobuf2_common       81920  4 videobuf2_dma_contig,videobuf2_v4l2,intel_ipu4p_isys,videobuf2_memops
ov8865                 32768  1
v4l2_fwnode            32768  2 intel_ipu4p_isys,ov8865
v4l2_async             28672  4 v4l2_fwnode,dw9719,intel_ipu4p_isys,ov8865
videodev              286720  6 v4l2_async,videobuf2_v4l2,videobuf2_common,dw9719,intel_ipu4p_isys,ov8865
mc                     77824  7 v4l2_async,videodev,videobuf2_v4l2,videobuf2_common,dw9719,intel_ipu4p_isys,ov8865
intel_skl_int3472_discrete    24576  1
intel_skl_int3472_common    16384  2 intel_skl_int3472_tps68470,intel_skl_int3472_discrete
intel_ipu4p           110592  4 intel_ipu4p_psys,intel_ipu4p_isys
ipu_bridge             20480  2 intel_ipu4p_isys,intel_ipu4p
```
</details></br>

<details>
  <summary>
    <strong>
      media-ctl -p
    </strong>
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
	pad0: SINK,MUST_CONNECT,0x8
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
	pad1: SOURCE
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
	pad2: SOURCE
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
	pad3: SOURCE
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
	pad4: SOURCE
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
	pad5: SOURCE
		-> "Intel IPU4 CSI-2 0 meta":0 []

- entity 8: Intel IPU4 CSI-2 0 capture 0 (1 pad, 1 link)
            type Node subtype V4L flags 0
            device node name /dev/video0
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 0":1 []

- entity 14: Intel IPU4 CSI-2 0 capture 1 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video1
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 0":2 []

- entity 20: Intel IPU4 CSI-2 0 capture 2 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video2
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 0":3 []

- entity 26: Intel IPU4 CSI-2 0 capture 3 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video3
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 0":4 []

- entity 32: Intel IPU4 CSI-2 0 meta (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video4
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 0":5 []

- entity 38: Intel IPU4 CSI-2 1 (6 pads, 41 links, 0 routes)
             type V4L2 subdev subtype Unknown flags 0
             device node name /dev/v4l-subdev1
	pad0: SINK,MUST_CONNECT,0x8
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
	pad1: SOURCE
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
	pad2: SOURCE
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
	pad3: SOURCE
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
	pad4: SOURCE
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
	pad5: SOURCE
		-> "Intel IPU4 CSI-2 1 meta":0 []

- entity 45: Intel IPU4 CSI-2 1 capture 0 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video5
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 1":1 []

- entity 51: Intel IPU4 CSI-2 1 capture 1 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video6
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 1":2 []

- entity 57: Intel IPU4 CSI-2 1 capture 2 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video7
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 1":3 []

- entity 63: Intel IPU4 CSI-2 1 capture 3 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video8
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 1":4 []

- entity 69: Intel IPU4 CSI-2 1 meta (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video9
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 1":5 []

- entity 75: Intel IPU4 CSI-2 2 (6 pads, 41 links, 0 routes)
             type V4L2 subdev subtype Unknown flags 0
             device node name /dev/v4l-subdev2
	pad0: SINK,MUST_CONNECT,0x8
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
	pad1: SOURCE
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
	pad2: SOURCE
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
	pad3: SOURCE
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
	pad4: SOURCE
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
	pad5: SOURCE
		-> "Intel IPU4 CSI-2 2 meta":0 []

- entity 82: Intel IPU4 CSI-2 2 capture 0 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video10
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 2":1 []

- entity 88: Intel IPU4 CSI-2 2 capture 1 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video11
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 2":2 []

- entity 94: Intel IPU4 CSI-2 2 capture 2 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video12
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 2":3 []

- entity 100: Intel IPU4 CSI-2 2 capture 3 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video13
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 2":4 []

- entity 106: Intel IPU4 CSI-2 2 meta (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video14
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 2":5 []

- entity 112: Intel IPU4 CSI-2 3 (6 pads, 42 links, 0 routes)
              type V4L2 subdev subtype Unknown flags 0
              device node name /dev/v4l-subdev3
	pad0: SINK,MUST_CONNECT,0x8
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
		<- "ov8865 1-0010":0 []
	pad1: SOURCE
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
	pad2: SOURCE
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
	pad3: SOURCE
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
	pad4: SOURCE
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
	pad5: SOURCE
		-> "Intel IPU4 CSI-2 3 meta":0 []

- entity 119: Intel IPU4 CSI-2 3 capture 0 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video15
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 3":1 []

- entity 125: Intel IPU4 CSI-2 3 capture 1 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video16
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 3":2 []

- entity 131: Intel IPU4 CSI-2 3 capture 2 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video17
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 3":3 []

- entity 137: Intel IPU4 CSI-2 3 capture 3 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video18
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 3":4 []

- entity 143: Intel IPU4 CSI-2 3 meta (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video19
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 3":5 []

- entity 149: Intel IPU4 CSI-2 4 (6 pads, 41 links, 0 routes)
              type V4L2 subdev subtype Unknown flags 0
              device node name /dev/v4l-subdev4
	pad0: SINK,MUST_CONNECT,0x8
		[stream:0 fmt:Y10_1X10/4096x3072 field:none]
	pad1: SOURCE
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
	pad2: SOURCE
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
	pad3: SOURCE
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
	pad4: SOURCE
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
	pad5: SOURCE
		-> "Intel IPU4 CSI-2 4 meta":0 []

- entity 156: Intel IPU4 CSI-2 4 capture 0 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video20
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 4":1 []

- entity 162: Intel IPU4 CSI-2 4 capture 1 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video21
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 4":2 []

- entity 168: Intel IPU4 CSI-2 4 capture 2 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video22
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 4":3 []

- entity 174: Intel IPU4 CSI-2 4 capture 3 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video23
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 4":4 []

- entity 180: Intel IPU4 CSI-2 4 meta (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video24
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI-2 4":5 []

- entity 186: Intel IPU4 TPG 0 (1 pad, 10 links, 0 routes)
              type V4L2 subdev subtype Sensor flags 0
              device node name /dev/v4l-subdev5
	pad0: SOURCE
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

- entity 188: Intel IPU4 TPG 0 capture (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video25
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 TPG 0":0 []

- entity 194: Intel IPU4 TPG 1 (1 pad, 10 links, 0 routes)
              type V4L2 subdev subtype Sensor flags 0
              device node name /dev/v4l-subdev6
	pad0: SOURCE
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

- entity 196: Intel IPU4 TPG 1 capture (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video26
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 TPG 1":0 []

- entity 202: Intel IPU4 CSI2 BE SOC (16 pads, 184 links, 0 routes)
              type V4L2 subdev subtype Unknown flags 0
              device node name /dev/v4l-subdev7
	pad0: SINK
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
		<- "Intel IPU4 TPG 0":0 [DYNAMIC]
		<- "Intel IPU4 TPG 1":0 [DYNAMIC]
	pad1: SINK
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
		<- "Intel IPU4 TPG 0":0 [DYNAMIC]
		<- "Intel IPU4 TPG 1":0 [DYNAMIC]
	pad2: SINK
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
		<- "Intel IPU4 TPG 0":0 [DYNAMIC]
		<- "Intel IPU4 TPG 1":0 [DYNAMIC]
	pad3: SINK
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
		<- "Intel IPU4 TPG 0":0 [DYNAMIC]
		<- "Intel IPU4 TPG 1":0 [DYNAMIC]
	pad4: SINK
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
		<- "Intel IPU4 TPG 0":0 [DYNAMIC]
		<- "Intel IPU4 TPG 1":0 [DYNAMIC]
	pad5: SINK
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
		<- "Intel IPU4 TPG 0":0 [DYNAMIC]
		<- "Intel IPU4 TPG 1":0 [DYNAMIC]
	pad6: SINK
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
		<- "Intel IPU4 TPG 0":0 [DYNAMIC]
		<- "Intel IPU4 TPG 1":0 [DYNAMIC]
	pad7: SINK
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
		<- "Intel IPU4 TPG 0":0 [DYNAMIC]
		<- "Intel IPU4 TPG 1":0 [DYNAMIC]
	pad8: SOURCE
		[stream:0 fmt:unknown/0x0
		 crop:(0,0)/0x0]
		-> "Intel IPU4 BE SOC capture 0":0 [DYNAMIC]
	pad9: SOURCE
		[stream:0 fmt:unknown/0x0
		 crop:(0,0)/0x0]
		-> "Intel IPU4 BE SOC capture 1":0 [DYNAMIC]
	pad10: SOURCE
		[stream:0 fmt:unknown/0x0
		 crop:(0,0)/0x0]
		-> "Intel IPU4 BE SOC capture 2":0 [DYNAMIC]
	pad11: SOURCE
		[stream:0 fmt:unknown/0x0
		 crop:(0,0)/0x0]
		-> "Intel IPU4 BE SOC capture 3":0 [DYNAMIC]
	pad12: SOURCE
		[stream:0 fmt:unknown/0x0
		 crop:(0,0)/0x0]
		-> "Intel IPU4 BE SOC capture 4":0 [DYNAMIC]
	pad13: SOURCE
		[stream:0 fmt:unknown/0x0
		 crop:(0,0)/0x0]
		-> "Intel IPU4 BE SOC capture 5":0 [DYNAMIC]
	pad14: SOURCE
		[stream:0 fmt:unknown/0x0
		 crop:(0,0)/0x0]
		-> "Intel IPU4 BE SOC capture 6":0 [DYNAMIC]
	pad15: SOURCE
		[stream:0 fmt:unknown/0x0
		 crop:(0,0)/0x0]
		-> "Intel IPU4 BE SOC capture 7":0 [DYNAMIC]

- entity 219: Intel IPU4 BE SOC capture 0 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video27
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI2 BE SOC":8 [DYNAMIC]

- entity 225: Intel IPU4 BE SOC capture 1 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video28
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI2 BE SOC":9 [DYNAMIC]

- entity 231: Intel IPU4 BE SOC capture 2 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video29
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI2 BE SOC":10 [DYNAMIC]

- entity 237: Intel IPU4 BE SOC capture 3 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video30
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI2 BE SOC":11 [DYNAMIC]

- entity 243: Intel IPU4 BE SOC capture 4 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video31
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI2 BE SOC":12 [DYNAMIC]

- entity 249: Intel IPU4 BE SOC capture 5 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video32
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI2 BE SOC":13 [DYNAMIC]

- entity 255: Intel IPU4 BE SOC capture 6 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video33
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI2 BE SOC":14 [DYNAMIC]

- entity 261: Intel IPU4 BE SOC capture 7 (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video34
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI2 BE SOC":15 [DYNAMIC]

- entity 267: Intel IPU4 CSI2 BE (2 pads, 24 links, 0 routes)
              type V4L2 subdev subtype Unknown flags 0
              device node name /dev/v4l-subdev8
	pad0: SINK,MUST_CONNECT
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
		<- "Intel IPU4 TPG 0":0 []
		<- "Intel IPU4 TPG 1":0 []
	pad1: SOURCE
		[stream:0 fmt:SBGGR14_1X14/4096x3072 field:none
		 crop:(0,0)/4096x3072]
		-> "Intel IPU4 CSI2 BE capture":0 []
		-> "Intel IPU4 ISA":0 []

- entity 270: Intel IPU4 CSI2 BE capture (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video35
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 CSI2 BE":1 []

- entity 276: Intel IPU4 ISA (5 pads, 5 links, 0 routes)
              type V4L2 subdev subtype Unknown flags 0
              device node name /dev/v4l-subdev9
	pad0: SINK,MUST_CONNECT
		[stream:0 fmt:SBGGR14_1X14/4096x3072 field:none]
		<- "Intel IPU4 CSI2 BE":1 []
	pad1: SOURCE
		[stream:0 fmt:SBGGR12_1X12/4096x3072 field:none
		 crop:(0,0)/4096x3072]
		-> "Intel IPU4 ISA capture":0 []
	pad2: SINK,MUST_CONNECT
		[stream:0 fmt:FIXED/0x0]
		<- "Intel IPU4 ISA config":0 []
	pad3: SOURCE
		[stream:0 fmt:FIXED/0x0]
		-> "Intel IPU4 ISA 3A stats":0 []
	pad4: SOURCE
		[stream:0 fmt:SBGGR12_1X12/4096x3072 field:none
		 crop:(0,0)/4096x3072
		 compose:(0,0)/4096x3072]
		-> "Intel IPU4 ISA scaled capture":0 []

- entity 282: Intel IPU4 ISA capture (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video36
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 ISA":1 []

- entity 288: Intel IPU4 ISA config (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video37
	pad0: SOURCE,MUST_CONNECT
		-> "Intel IPU4 ISA":2 []

- entity 294: Intel IPU4 ISA 3A stats (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video38
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 ISA":3 []

- entity 300: Intel IPU4 ISA scaled capture (1 pad, 1 link)
              type Node subtype V4L flags 0
              device node name /dev/video39
	pad0: SINK,MUST_CONNECT
		<- "Intel IPU4 ISA":4 []

- entity 724: ov8865 1-0010 (1 pad, 1 link, 0 routes)
              type V4L2 subdev subtype Sensor flags 0
              device node name /dev/v4l-subdev10
	pad0: SOURCE
		[stream:0 fmt:SBGGR10_1X10/3264x2448 field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range
		 crop.bounds:(16,40)/3264x2448
		 crop:(16,40)/3264x2448]
		-> "Intel IPU4 CSI-2 3":0 []

- entity 730: dw9719 1-000c (0 pad, 0 link, 0 routes)
              type V4L2 subdev subtype Lens flags 0
              device node name /dev/v4l-subdev11
```
</details>

## 12. Build and install `libcamera` <sup>[repo](https://github.com/libcamera-org/libcamera)</sup>

```bash
sudo apt install meson clang libevent-dev # add libtiff-dev and qt6-base-dev for qcam

git clone https://git.libcamera.org/libcamera/libcamera.git -b v0.6.0 ../libcamera

cd ../libcamera

git am ../ipu4-next/patches/libcamera/v0.6.0/*.patch

meson setup build \
    -Dcpp_args="-Wno-c99-designator" \
    -Ddocumentation=disabled \
    -Dcam=enabled \
    -Dipas=simple \
    -Dpipelines=simple \
    -Dv4l2=enabled
	#-Dqcam=enabled

ninja -C build install
```

## 13. Test libcamera

<details>
  <summary>
    <strong>
      LIBCAMERA_LOG_LEVELS=DEBUG /usr/local/bin/cam -l
    </strong>
  </summary>

```
[0:07:19.026544876] [4419] DEBUG IPAModule ipa_module.cpp:333 ipa_soft_simple.so: IPA module /usr/local/lib/x86_64-linux-gnu/libcamera/ipa/ipa_soft_simple.so is signed
[0:07:19.026782043] [4419] DEBUG IPAManager ipa_manager.cpp:239 Loaded IPA module '/usr/local/lib/x86_64-linux-gnu/libcamera/ipa/ipa_soft_simple.so'
[0:07:19.026976206] [4419]  INFO Camera camera_manager.cpp:340 libcamera v0.0.0+32-fa79da73
[0:07:19.027153107] [4420] DEBUG Camera camera_manager.cpp:74 Starting camera manager
[0:07:19.041873178] [4420] DEBUG DeviceEnumerator device_enumerator.cpp:267 New media device "intel-ipu4-isys" created from /dev/media0
[0:07:19.042182646] [4420] DEBUG DeviceEnumerator device_enumerator_udev.cpp:96 Defer media device /dev/media0 due to 52 missing dependencies
[0:07:19.047704570] [4420] DEBUG DeviceEnumerator device_enumerator_udev.cpp:322 All dependencies for media device /dev/media0 found
[0:07:19.047720869] [4420] DEBUG DeviceEnumerator device_enumerator.cpp:295 Added device /dev/media0: intel-ipu4-isys
[0:07:19.048180263] [4420] DEBUG Camera camera_manager.cpp:143 Found registered pipeline handler 'simple'
[0:07:19.048529314] [4420] DEBUG DeviceEnumerator device_enumerator.cpp:355 Successful match for media device "intel-ipu4-isys"
[0:07:19.048647942] [4420] DEBUG SimplePipeline simple.cpp:1797 Sensor found for /dev/media0
[0:07:19.048937179] [4420] DEBUG SimplePipeline simple.cpp:492 Found capture device Intel IPU4 TPG 0 capture
[0:07:19.049016877] [4420] DEBUG CameraSensor camera_sensor_raw.cpp:211 Intel IPU4 TPG 0: unsupported number of sinks (0) or sources (1)
[0:07:19.049159433] [4420] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 0': Control: Store CSI-2 Headers (0x00981982)
[0:07:19.049386063] [4420] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 0': Control: Frame Length Lines (0x00982951)
[0:07:19.049418110] [4420] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 0': Control: Line Length Pixels (0x00982952)
[0:07:19.049436214] [4420] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 0': Control: Vertical Blanking (0x009e0901)
[0:07:19.049451375] [4420] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 0': Control: Horizontal Blanking (0x009e0902)
[0:07:19.049466488] [4420] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 0': Control: Pixel Rate (0x009f0902)
[0:07:19.049481104] [4420] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 0': Control: Test Pattern (0x009f0903)
[0:07:19.049604840] [4420] ERROR CameraSensor camera_sensor_legacy.cpp:223 'Intel IPU4 TPG 0': No image format found
[0:07:19.049704157] [4420] ERROR CameraSensor camera_sensor.cpp:483 Failed to create sensor for 'Intel IPU4 TPG 0: -22
[0:07:19.049759993] [4420] ERROR SimplePipeline simple.cpp:1812 No valid pipeline for sensor 'Intel IPU4 TPG 0', skipping
[0:07:19.049870640] [4420] DEBUG SimplePipeline simple.cpp:492 Found capture device Intel IPU4 TPG 1 capture
[0:07:19.049884359] [4420] DEBUG CameraSensor camera_sensor_raw.cpp:211 Intel IPU4 TPG 1: unsupported number of sinks (0) or sources (1)
[0:07:19.049918060] [4420] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 1': Control: Store CSI-2 Headers (0x00981982)
[0:07:19.049945584] [4420] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 1': Control: Frame Length Lines (0x00982951)
[0:07:19.049962712] [4420] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 1': Control: Line Length Pixels (0x00982952)
[0:07:19.049977765] [4420] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 1': Control: Vertical Blanking (0x009e0901)
[0:07:19.049992186] [4420] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 1': Control: Horizontal Blanking (0x009e0902)
[0:07:19.050020640] [4420] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 1': Control: Pixel Rate (0x009f0902)
[0:07:19.050034184] [4420] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 1': Control: Test Pattern (0x009f0903)
[0:07:19.050072114] [4420] ERROR CameraSensor camera_sensor_legacy.cpp:223 'Intel IPU4 TPG 1': No image format found
[0:07:19.050101590] [4420] ERROR CameraSensor camera_sensor.cpp:483 Failed to create sensor for 'Intel IPU4 TPG 1: -22
[0:07:19.050117091] [4420] ERROR SimplePipeline simple.cpp:1812 No valid pipeline for sensor 'Intel IPU4 TPG 1', skipping
[0:07:19.050170614] [4420] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 CSI-2 3': Control: Store CSI-2 Headers (0x00981982)
[0:07:19.050263111] [4420] DEBUG SimplePipeline simple.cpp:492 Found capture device Intel IPU4 CSI-2 3 capture 0
[0:07:19.050278157] [4420] DEBUG CameraSensor camera_sensor_raw.cpp:211 ov8865 1-0010: unsupported number of sinks (0) or sources (1)
[0:07:19.050307726] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Red Balance (0x0098090e)
[0:07:19.050333040] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Blue Balance (0x0098090f)
[0:07:19.050349969] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Exposure (0x00980911)
[0:07:19.050364715] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Horizontal Flip (0x00980914)
[0:07:19.050379939] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Vertical Flip (0x00980915)
[0:07:19.050396042] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Camera Orientation (0x009a0922)
[0:07:19.050417629] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Camera Sensor Rotation (0x009a0923)
[0:07:19.050436005] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Vertical Blanking (0x009e0901)
[0:07:19.050456212] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Horizontal Blanking (0x009e0902)
[0:07:19.050475658] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Analogue Gain (0x009e0903)
[0:07:19.050492506] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Link Frequency (0x009f0901)
[0:07:19.050511124] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Pixel Rate (0x009f0902)
[0:07:19.050530268] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Test Pattern (0x009f0903)
[0:07:19.051979532] [4420] DEBUG CameraSensor camera_sensor_legacy.cpp:547 'ov8865 1-0010': Test pattern mode 1 ignored
[0:07:19.052042346] [4420] DEBUG CameraSensor camera_sensor_legacy.cpp:547 'ov8865 1-0010': Test pattern mode 3 ignored
[0:07:19.052052775] [4420] DEBUG CameraSensor camera_sensor_legacy.cpp:547 'ov8865 1-0010': Test pattern mode 4 ignored
[0:07:19.052061027] [4420] DEBUG CameraSensor camera_sensor_legacy.cpp:547 'ov8865 1-0010': Test pattern mode 5 ignored
[0:07:19.124690228] [4420] DEBUG V4L2 v4l2_device.cpp:742 'dw9719 1-000c': Control: Focus, Absolute (0x009a090a)
[0:07:19.124993676] [4420] DEBUG CameraSensor camera_sensor_legacy.cpp:1028 'ov8865 1-0010': Apply test pattern mode 0
[0:07:19.125058729] [4420] DEBUG CameraSensor camera_sensor.cpp:476 Entity 'ov8865 1-0010' matched by CameraSensorLegacy
[0:07:19.125093567] [4420]  WARN CameraSensor camera_sensor_legacy.cpp:502 'ov8865 1-0010': No sensor delays found in static properties. Assuming unverified defaults.
[0:07:19.125196186] [4420] DEBUG DelayedControls delayed_controls.cpp:99 Set a delay of 2 and priority write flag 0 for Exposure
[0:07:19.125221073] [4420] DEBUG DelayedControls delayed_controls.cpp:99 Set a delay of 1 and priority write flag 0 for Analogue Gain
[0:07:19.125320534] [4420] DEBUG SimplePipeline simple.cpp:566 Found pipeline: [ov8865 1-0010|0] -> [0|Intel IPU4 CSI-2 3|1] -> [0|Intel IPU4 CSI-2 3 capture 0]
[0:07:19.125429500] [4420] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 CSI-2 3': Control: Store CSI-2 Headers (0x00981982)
[0:07:19.144092814] [4420] DEBUG V4L2 v4l2_videodevice.cpp:633 /dev/video15[14:cap]: Opened device PCI:pci:intel-ipu: intel-ipu4-isys: ipu4p
[0:07:19.144558552] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Red Balance (0x0098090e)
[0:07:19.144695053] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Blue Balance (0x0098090f)
[0:07:19.144746896] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Exposure (0x00980911)
[0:07:19.144802890] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Horizontal Flip (0x00980914)
[0:07:19.144860020] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Vertical Flip (0x00980915)
[0:07:19.144955328] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Camera Orientation (0x009a0922)
[0:07:19.145051651] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Camera Sensor Rotation (0x009a0923)
[0:07:19.145150180] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Vertical Blanking (0x009e0901)
[0:07:19.145237319] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Horizontal Blanking (0x009e0902)
[0:07:19.145251075] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Analogue Gain (0x009e0903)
[0:07:19.145365091] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Link Frequency (0x009f0901)
[0:07:19.145419513] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Pixel Rate (0x009f0902)
[0:07:19.145433667] [4420] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Test Pattern (0x009f0903)
[0:07:19.145656407] [4420] DEBUG DmaBufAllocator dma_buf_allocator.cpp:106 Failed to open /dev/dma_heap/linux,cma: No such file or directory
[0:07:19.145673682] [4420] DEBUG DmaBufAllocator dma_buf_allocator.cpp:106 Failed to open /dev/dma_heap/reserved: No such file or directory
[0:07:19.145682039] [4420] DEBUG DmaBufAllocator dma_buf_allocator.cpp:106 Failed to open /dev/dma_heap/system: Permission denied
[0:07:19.145733447] [4420] DEBUG DmaBufAllocator dma_buf_allocator.cpp:112 Using /dev/udmabuf
[0:07:19.157689946] [4420] DEBUG IPAManager ipa_manager.cpp:309 IPA module /usr/local/lib/x86_64-linux-gnu/libcamera/ipa/ipa_soft_simple.so signature is valid
[0:07:19.157972042] [4420] DEBUG IPAProxy soft_ipa_proxy.cpp:44 initializing soft proxy in thread: loading IPA from /usr/local/lib/x86_64-linux-gnu/libcamera/ipa/ipa_soft_simple.so
[0:07:19.158894640] [4420]  WARN IPAProxy ipa_proxy.cpp:192 Configuration file 'ov8865.yaml' not found for IPA module 'simple', falling back to '/usr/local/share/libcamera/ipa/simple/uncalibrated.yaml'
[0:07:19.159613774] [4420] DEBUG IPASoft soft_simple.cpp:126 IPASoft: Tuning file version 1
[0:07:19.159697175] [4420] DEBUG IPAModuleAlgo module.h:103 IPASoft: Instantiated algorithm 'BlackLevel'
[0:07:19.159786695] [4420] DEBUG IPAModuleAlgo module.h:103 IPASoft: Instantiated algorithm 'Awb'
[0:07:19.159843264] [4420] DEBUG IPAModuleAlgo module.h:103 IPASoft: Instantiated algorithm 'Lut'
[0:07:19.159872809] [4420] DEBUG IPAModuleAlgo module.h:103 IPASoft: Instantiated algorithm 'Agc'
[0:07:19.160045426] [4420] DEBUG MediaDevice media_device.cpp:854 /dev/media0[intel-ipu4-isys]: 'ov8865 1-0010'[0] -> 'Intel IPU4 CSI-2 3'[0]: 1
[0:07:19.160080677] [4420] DEBUG MediaDevice media_device.cpp:854 /dev/media0[intel-ipu4-isys]: 'Intel IPU4 CSI-2 3'[1] -> 'Intel IPU4 CSI-2 3 capture 0'[0]: 1
[0:07:19.181732892] [4420] DEBUG SimplePipeline simple.cpp:861 Link 'ov8865 1-0010'[0] -> 'Intel IPU4 CSI-2 3'[0]: configured with format 800x600-SBGGR10_1X10/RAW
[0:07:19.181784075] [4420] DEBUG SimplePipeline simple.cpp:861 Link 'Intel IPU4 CSI-2 3'[1] -> 'Intel IPU4 CSI-2 3 capture 0'[0]: configured with format 800x600-SBGGR10_1X10/Unset
[0:07:19.181912272] [4420] DEBUG SimplePipeline simple.cpp:707 Adding configuration for 800x600 in pixel formats [ BG10, bV0E ]
[0:07:19.203343640] [4420] DEBUG SimplePipeline simple.cpp:861 Link 'ov8865 1-0010'[0] -> 'Intel IPU4 CSI-2 3'[0]: configured with format 1632x1224-SBGGR10_1X10/RAW
[0:07:19.203386910] [4420] DEBUG SimplePipeline simple.cpp:861 Link 'Intel IPU4 CSI-2 3'[1] -> 'Intel IPU4 CSI-2 3 capture 0'[0]: configured with format 1632x1224-SBGGR10_1X10/Unset
[0:07:19.203461807] [4420] DEBUG SimplePipeline simple.cpp:707 Adding configuration for 1632x1224 in pixel formats [ BG10, bV0E ]
[0:07:19.224694913] [4420] DEBUG SimplePipeline simple.cpp:861 Link 'ov8865 1-0010'[0] -> 'Intel IPU4 CSI-2 3'[0]: configured with format 3264x1836-SBGGR10_1X10/RAW
[0:07:19.224732406] [4420] DEBUG SimplePipeline simple.cpp:861 Link 'Intel IPU4 CSI-2 3'[1] -> 'Intel IPU4 CSI-2 3 capture 0'[0]: configured with format 3264x1836-SBGGR10_1X10/Unset
[0:07:19.224806453] [4420] DEBUG SimplePipeline simple.cpp:707 Adding configuration for 3264x1836 in pixel formats [ BG10, bV0E ]
[0:07:19.246022320] [4420] DEBUG SimplePipeline simple.cpp:861 Link 'ov8865 1-0010'[0] -> 'Intel IPU4 CSI-2 3'[0]: configured with format 3264x2448-SBGGR10_1X10/RAW
[0:07:19.246063585] [4420] DEBUG SimplePipeline simple.cpp:861 Link 'Intel IPU4 CSI-2 3'[1] -> 'Intel IPU4 CSI-2 3 capture 0'[0]: configured with format 3264x2448-SBGGR10_1X10/Unset
[0:07:19.246122965] [4420] DEBUG SimplePipeline simple.cpp:707 Adding configuration for 3264x2448 in pixel formats [ BG10, bV0E ]
[0:07:19.246255163] [4420] DEBUG SimplePipeline simple.cpp:665 Using frameStart signal from 'Intel IPU4 CSI-2 3'
[0:07:19.246442168] [4420]  INFO Camera camera_manager.cpp:223 Adding camera '\_SB_.PCI0.I2C3.CAMR' for pipeline handler simple
[0:07:19.246485738] [4420] DEBUG SimplePipeline simple.cpp:1921 Matched on device: /dev/media0
[0:07:19.246496708] [4420] DEBUG Camera camera_manager.cpp:164 Pipeline handler "simple" matched
Available cameras:
1: External camera 'ov8865' (\_SB_.PCI0.I2C3.CAMR)
```
</details></br>

<details>
  <summary>
    <strong>
      LIBCAMERA_LOG_LEVELS=DEBUG /usr/local/bin/cam -c 1 --capture=1 --file=test#.png --stream role=raw,width=3264,height=2448,pixelformat=SBGGR10
    </strong>
  </summary>

```
[0:08:06.971095111] [4427] DEBUG IPAModule ipa_module.cpp:333 ipa_soft_simple.so: IPA module /usr/local/lib/x86_64-linux-gnu/libcamera/ipa/ipa_soft_simple.so is signed
[0:08:06.971278231] [4427] DEBUG IPAManager ipa_manager.cpp:239 Loaded IPA module '/usr/local/lib/x86_64-linux-gnu/libcamera/ipa/ipa_soft_simple.so'
[0:08:06.971370111] [4427]  INFO Camera camera_manager.cpp:340 libcamera v0.0.0+32-fa79da73
[0:08:06.971554159] [4428] DEBUG Camera camera_manager.cpp:74 Starting camera manager
[0:08:06.983860311] [4428] DEBUG DeviceEnumerator device_enumerator.cpp:267 New media device "intel-ipu4-isys" created from /dev/media0
[0:08:06.984091488] [4428] DEBUG DeviceEnumerator device_enumerator_udev.cpp:96 Defer media device /dev/media0 due to 52 missing dependencies
[0:08:06.989593484] [4428] DEBUG DeviceEnumerator device_enumerator_udev.cpp:322 All dependencies for media device /dev/media0 found
[0:08:06.989610993] [4428] DEBUG DeviceEnumerator device_enumerator.cpp:295 Added device /dev/media0: intel-ipu4-isys
[0:08:06.989997712] [4428] DEBUG Camera camera_manager.cpp:143 Found registered pipeline handler 'simple'
[0:08:06.990172593] [4428] DEBUG DeviceEnumerator device_enumerator.cpp:355 Successful match for media device "intel-ipu4-isys"
[0:08:06.990278713] [4428] DEBUG SimplePipeline simple.cpp:1797 Sensor found for /dev/media0
[0:08:06.990581365] [4428] DEBUG SimplePipeline simple.cpp:492 Found capture device Intel IPU4 TPG 0 capture
[0:08:06.990619825] [4428] DEBUG CameraSensor camera_sensor_raw.cpp:211 Intel IPU4 TPG 0: unsupported number of sinks (0) or sources (1)
[0:08:06.990747063] [4428] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 0': Control: Store CSI-2 Headers (0x00981982)
[0:08:06.990874811] [4428] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 0': Control: Frame Length Lines (0x00982951)
[0:08:06.990903441] [4428] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 0': Control: Line Length Pixels (0x00982952)
[0:08:06.990920212] [4428] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 0': Control: Vertical Blanking (0x009e0901)
[0:08:06.990933387] [4428] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 0': Control: Horizontal Blanking (0x009e0902)
[0:08:06.990947321] [4428] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 0': Control: Pixel Rate (0x009f0902)
[0:08:06.990961562] [4428] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 0': Control: Test Pattern (0x009f0903)
[0:08:06.991077491] [4428] ERROR CameraSensor camera_sensor_legacy.cpp:223 'Intel IPU4 TPG 0': No image format found
[0:08:06.991168957] [4428] ERROR CameraSensor camera_sensor.cpp:483 Failed to create sensor for 'Intel IPU4 TPG 0: -22
[0:08:06.991219384] [4428] ERROR SimplePipeline simple.cpp:1812 No valid pipeline for sensor 'Intel IPU4 TPG 0', skipping
[0:08:06.991307242] [4428] DEBUG SimplePipeline simple.cpp:492 Found capture device Intel IPU4 TPG 1 capture
[0:08:06.991319560] [4428] DEBUG CameraSensor camera_sensor_raw.cpp:211 Intel IPU4 TPG 1: unsupported number of sinks (0) or sources (1)
[0:08:06.991348504] [4428] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 1': Control: Store CSI-2 Headers (0x00981982)
[0:08:06.991372710] [4428] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 1': Control: Frame Length Lines (0x00982951)
[0:08:06.991387639] [4428] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 1': Control: Line Length Pixels (0x00982952)
[0:08:06.991401294] [4428] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 1': Control: Vertical Blanking (0x009e0901)
[0:08:06.991413927] [4428] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 1': Control: Horizontal Blanking (0x009e0902)
[0:08:06.991427200] [4428] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 1': Control: Pixel Rate (0x009f0902)
[0:08:06.991439986] [4428] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 TPG 1': Control: Test Pattern (0x009f0903)
[0:08:06.991474126] [4428] ERROR CameraSensor camera_sensor_legacy.cpp:223 'Intel IPU4 TPG 1': No image format found
[0:08:06.991497678] [4428] ERROR CameraSensor camera_sensor.cpp:483 Failed to create sensor for 'Intel IPU4 TPG 1: -22
[0:08:06.991511016] [4428] ERROR SimplePipeline simple.cpp:1812 No valid pipeline for sensor 'Intel IPU4 TPG 1', skipping
[0:08:06.991558014] [4428] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 CSI-2 3': Control: Store CSI-2 Headers (0x00981982)
[0:08:06.991626772] [4428] DEBUG SimplePipeline simple.cpp:492 Found capture device Intel IPU4 CSI-2 3 capture 0
[0:08:06.991639242] [4428] DEBUG CameraSensor camera_sensor_raw.cpp:211 ov8865 1-0010: unsupported number of sinks (0) or sources (1)
[0:08:06.991664973] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Red Balance (0x0098090e)
[0:08:06.991724198] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Blue Balance (0x0098090f)
[0:08:06.991739959] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Exposure (0x00980911)
[0:08:06.991753892] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Horizontal Flip (0x00980914)
[0:08:06.991768202] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Vertical Flip (0x00980915)
[0:08:06.991783019] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Camera Orientation (0x009a0922)
[0:08:06.991803053] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Camera Sensor Rotation (0x009a0923)
[0:08:06.991821071] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Vertical Blanking (0x009e0901)
[0:08:06.991846402] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Horizontal Blanking (0x009e0902)
[0:08:06.991869933] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Analogue Gain (0x009e0903)
[0:08:06.991891928] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Link Frequency (0x009f0901)
[0:08:06.991916821] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Pixel Rate (0x009f0902)
[0:08:06.991939090] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Test Pattern (0x009f0903)
[0:08:06.992940567] [4428] DEBUG CameraSensor camera_sensor_legacy.cpp:547 'ov8865 1-0010': Test pattern mode 1 ignored
[0:08:06.992962754] [4428] DEBUG CameraSensor camera_sensor_legacy.cpp:547 'ov8865 1-0010': Test pattern mode 3 ignored
[0:08:06.992972520] [4428] DEBUG CameraSensor camera_sensor_legacy.cpp:547 'ov8865 1-0010': Test pattern mode 4 ignored
[0:08:06.992982847] [4428] DEBUG CameraSensor camera_sensor_legacy.cpp:547 'ov8865 1-0010': Test pattern mode 5 ignored
[0:08:07.077937620] [4428] DEBUG V4L2 v4l2_device.cpp:742 'dw9719 1-000c': Control: Focus, Absolute (0x009a090a)
[0:08:07.078228372] [4428] DEBUG CameraSensor camera_sensor_legacy.cpp:1028 'ov8865 1-0010': Apply test pattern mode 0
[0:08:07.078290458] [4428] DEBUG CameraSensor camera_sensor.cpp:476 Entity 'ov8865 1-0010' matched by CameraSensorLegacy
[0:08:07.078323365] [4428]  WARN CameraSensor camera_sensor_legacy.cpp:502 'ov8865 1-0010': No sensor delays found in static properties. Assuming unverified defaults.
[0:08:07.078422987] [4428] DEBUG DelayedControls delayed_controls.cpp:99 Set a delay of 2 and priority write flag 0 for Exposure
[0:08:07.078446597] [4428] DEBUG DelayedControls delayed_controls.cpp:99 Set a delay of 1 and priority write flag 0 for Analogue Gain
[0:08:07.078541846] [4428] DEBUG SimplePipeline simple.cpp:566 Found pipeline: [ov8865 1-0010|0] -> [0|Intel IPU4 CSI-2 3|1] -> [0|Intel IPU4 CSI-2 3 capture 0]
[0:08:07.078647763] [4428] DEBUG V4L2 v4l2_device.cpp:742 'Intel IPU4 CSI-2 3': Control: Store CSI-2 Headers (0x00981982)
[0:08:07.096856171] [4428] DEBUG V4L2 v4l2_videodevice.cpp:633 /dev/video15[14:cap]: Opened device PCI:pci:intel-ipu: intel-ipu4-isys: ipu4p
[0:08:07.097160965] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Red Balance (0x0098090e)
[0:08:07.097245205] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Blue Balance (0x0098090f)
[0:08:07.097261885] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Exposure (0x00980911)
[0:08:07.097275829] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Horizontal Flip (0x00980914)
[0:08:07.097288903] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Vertical Flip (0x00980915)
[0:08:07.097302435] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Camera Orientation (0x009a0922)
[0:08:07.097324455] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Camera Sensor Rotation (0x009a0923)
[0:08:07.097339526] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Vertical Blanking (0x009e0901)
[0:08:07.097432834] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Horizontal Blanking (0x009e0902)
[0:08:07.097447147] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Analogue Gain (0x009e0903)
[0:08:07.097460841] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Link Frequency (0x009f0901)
[0:08:07.097475405] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Pixel Rate (0x009f0902)
[0:08:07.097488960] [4428] DEBUG V4L2 v4l2_device.cpp:742 'ov8865 1-0010': Control: Test Pattern (0x009f0903)
[0:08:07.097591685] [4428] DEBUG DmaBufAllocator dma_buf_allocator.cpp:106 Failed to open /dev/dma_heap/linux,cma: No such file or directory
[0:08:07.097610018] [4428] DEBUG DmaBufAllocator dma_buf_allocator.cpp:106 Failed to open /dev/dma_heap/reserved: No such file or directory
[0:08:07.097619294] [4428] DEBUG DmaBufAllocator dma_buf_allocator.cpp:106 Failed to open /dev/dma_heap/system: Permission denied
[0:08:07.097630980] [4428] DEBUG DmaBufAllocator dma_buf_allocator.cpp:112 Using /dev/udmabuf
[0:08:07.102127219] [4428] DEBUG IPAManager ipa_manager.cpp:309 IPA module /usr/local/lib/x86_64-linux-gnu/libcamera/ipa/ipa_soft_simple.so signature is valid
[0:08:07.102442368] [4428] DEBUG IPAProxy soft_ipa_proxy.cpp:44 initializing soft proxy in thread: loading IPA from /usr/local/lib/x86_64-linux-gnu/libcamera/ipa/ipa_soft_simple.so
[0:08:07.103089772] [4428]  WARN IPAProxy ipa_proxy.cpp:192 Configuration file 'ov8865.yaml' not found for IPA module 'simple', falling back to '/usr/local/share/libcamera/ipa/simple/uncalibrated.yaml'
[0:08:07.103568859] [4428] DEBUG IPASoft soft_simple.cpp:126 IPASoft: Tuning file version 1
[0:08:07.103662777] [4428] DEBUG IPAModuleAlgo module.h:103 IPASoft: Instantiated algorithm 'BlackLevel'
[0:08:07.103721982] [4428] DEBUG IPAModuleAlgo module.h:103 IPASoft: Instantiated algorithm 'Awb'
[0:08:07.103786656] [4428] DEBUG IPAModuleAlgo module.h:103 IPASoft: Instantiated algorithm 'Lut'
[0:08:07.103839640] [4428] DEBUG IPAModuleAlgo module.h:103 IPASoft: Instantiated algorithm 'Agc'
[0:08:07.104060654] [4428] DEBUG MediaDevice media_device.cpp:854 /dev/media0[intel-ipu4-isys]: 'Intel IPU4 CSI-2 3'[1] -> 'Intel IPU4 CSI-2 3 capture 0'[0]: 0
[0:08:07.104084465] [4428] DEBUG MediaDevice media_device.cpp:854 /dev/media0[intel-ipu4-isys]: 'Intel IPU4 CSI-2 3'[1] -> 'Intel IPU4 CSI-2 3 capture 0'[0]: 1
[0:08:07.125673726] [4428] DEBUG SimplePipeline simple.cpp:861 Link 'ov8865 1-0010'[0] -> 'Intel IPU4 CSI-2 3'[0]: configured with format 800x600-SBGGR10_1X10/RAW
[0:08:07.125725154] [4428] DEBUG SimplePipeline simple.cpp:861 Link 'Intel IPU4 CSI-2 3'[1] -> 'Intel IPU4 CSI-2 3 capture 0'[0]: configured with format 800x600-SBGGR10_1X10/Unset
[0:08:07.125835454] [4428] DEBUG SimplePipeline simple.cpp:707 Adding configuration for 800x600 in pixel formats [ BG10, bV0E ]
[0:08:07.146956798] [4428] DEBUG SimplePipeline simple.cpp:861 Link 'ov8865 1-0010'[0] -> 'Intel IPU4 CSI-2 3'[0]: configured with format 1632x1224-SBGGR10_1X10/RAW
[0:08:07.146998434] [4428] DEBUG SimplePipeline simple.cpp:861 Link 'Intel IPU4 CSI-2 3'[1] -> 'Intel IPU4 CSI-2 3 capture 0'[0]: configured with format 1632x1224-SBGGR10_1X10/Unset
[0:08:07.147058580] [4428] DEBUG SimplePipeline simple.cpp:707 Adding configuration for 1632x1224 in pixel formats [ BG10, bV0E ]
[0:08:07.168255171] [4428] DEBUG SimplePipeline simple.cpp:861 Link 'ov8865 1-0010'[0] -> 'Intel IPU4 CSI-2 3'[0]: configured with format 3264x1836-SBGGR10_1X10/RAW
[0:08:07.168299259] [4428] DEBUG SimplePipeline simple.cpp:861 Link 'Intel IPU4 CSI-2 3'[1] -> 'Intel IPU4 CSI-2 3 capture 0'[0]: configured with format 3264x1836-SBGGR10_1X10/Unset
[0:08:07.168362304] [4428] DEBUG SimplePipeline simple.cpp:707 Adding configuration for 3264x1836 in pixel formats [ BG10, bV0E ]
[0:08:07.189750936] [4428] DEBUG SimplePipeline simple.cpp:861 Link 'ov8865 1-0010'[0] -> 'Intel IPU4 CSI-2 3'[0]: configured with format 3264x2448-SBGGR10_1X10/RAW
[0:08:07.189794716] [4428] DEBUG SimplePipeline simple.cpp:861 Link 'Intel IPU4 CSI-2 3'[1] -> 'Intel IPU4 CSI-2 3 capture 0'[0]: configured with format 3264x2448-SBGGR10_1X10/Unset
[0:08:07.189931598] [4428] DEBUG SimplePipeline simple.cpp:707 Adding configuration for 3264x2448 in pixel formats [ BG10, bV0E ]
[0:08:07.190091254] [4428] DEBUG SimplePipeline simple.cpp:665 Using frameStart signal from 'Intel IPU4 CSI-2 3'
[0:08:07.190337361] [4428]  INFO Camera camera_manager.cpp:223 Adding camera '\_SB_.PCI0.I2C3.CAMR' for pipeline handler simple
[0:08:07.190415909] [4428] DEBUG SimplePipeline simple.cpp:1921 Matched on device: /dev/media0
[0:08:07.190425701] [4428] DEBUG Camera camera_manager.cpp:164 Pipeline handler "simple" matched
[0:08:07.191040689] [4428] DEBUG SimplePipeline simple.cpp:1140 Largest stream size is 3260x2448
[0:08:07.191059620] [4428] DEBUG SimplePipeline simple.cpp:1193 Picked 3264x2448-SBGGR10_1X10/Unset -> 3264x2448-SBGGR10 for max stream size 3260x2448
[0:08:07.191090568] [4428] DEBUG SimplePipeline simple.cpp:1260 Unspecified color space set to sRGB
[0:08:07.191115588] [4428] DEBUG SimplePipeline simple.cpp:1324 Adjusting bufferCount from 0 to 4
[0:08:07.191242456] [4427] DEBUG Camera camera.cpp:1150 streams configuration: (0) 3260x2448-ABGR8888/sRGB
[0:08:07.191278748] [4427] DEBUG SimplePipeline simple.cpp:1140 Largest stream size is 3264x2448
[0:08:07.191289717] [4427] DEBUG SimplePipeline simple.cpp:1193 Picked 3264x2448-SBGGR10_1X10/Unset -> 3264x2448-SBGGR10 for max stream size 3264x2448
[0:08:07.191301423] [4427] DEBUG SimplePipeline simple.cpp:1227 Adjusting pixel format from SBGGR10 to RGB888
[0:08:07.191314109] [4427] DEBUG SimplePipeline simple.cpp:1282 Adjusting size from 3264x2448 to 3260x2448
Camera configuration adjusted
Using camera \_SB_.PCI0.I2C3.CAMR as cam0
[0:08:07.191340778] [4427] DEBUG SimplePipeline simple.cpp:1140 Largest stream size is 3260x2448
[0:08:07.191348975] [4427] DEBUG SimplePipeline simple.cpp:1193 Picked 3264x2448-SBGGR10_1X10/Unset -> 3264x2448-SBGGR10 for max stream size 3260x2448
[0:08:07.191362594] [4427]  INFO Camera camera.cpp:1215 configuring streams: (0) 3260x2448-RGB888/sRGB
[0:08:07.191453543] [4428] DEBUG MediaDevice media_device.cpp:854 /dev/media0[intel-ipu4-isys]: 'Intel IPU4 CSI-2 3'[1] -> 'Intel IPU4 CSI-2 3 capture 0'[0]: 0
[0:08:07.191468552] [4428] DEBUG MediaDevice media_device.cpp:854 /dev/media0[intel-ipu4-isys]: 'Intel IPU4 CSI-2 3'[1] -> 'Intel IPU4 CSI-2 3 capture 0'[0]: 1
[0:08:07.192420326] [4428] DEBUG SimplePipeline simple.cpp:861 Link 'ov8865 1-0010'[0] -> 'Intel IPU4 CSI-2 3'[0]: configured with format 3264x2448-SBGGR10_1X10/RAW
[0:08:07.192436556] [4428] DEBUG SimplePipeline simple.cpp:861 Link 'Intel IPU4 CSI-2 3'[1] -> 'Intel IPU4 CSI-2 3 capture 0'[0]: configured with format 3264x2448-SBGGR10_1X10/Unset
[0:08:07.192492948] [4428] DEBUG SimplePipeline simple.cpp:1432 format.code == pipeConfig->code; videoFormat = BG10; pipeConfig->captureFormat = SBGGR10
[0:08:07.192511336] [4428] DEBUG SimplePipeline simple.cpp:1466 captureFormat.fourcc = Y10 ; videoFormat = BG10
[0:08:07.192518707] [4428] DEBUG SimplePipeline simple.cpp:1469 captureFormat.size = 3264x2448; pipeConfig->captureSize = 3264x2448
[0:08:07.192527749] [4428] ERROR SimplePipeline simple.cpp:1472 Unable to configure capture in 3264x2448-BG10 (got 3264x2448-Y10 /RAW)
Failed to configure camera
Failed to start camera session
```
</details></br>

# Dynamic debugging <sup>[ref](https://docs.kernel.org/admin-guide/dynamic-debug-howto.html)</sup>

You can utilize the standard debugfs control interface for managing kernel messages.

Check for Dynamic Debug support:
```bash
ls /sys/kernel/debug/dynamic_debug/control
```

List available IPU and sensor modules:
```bash
lsmod | grep -Ei "ipu|ov5693|INT33BE|ov8865|dw9719|INT347"
```

Enable dynamic debugging for the intel_ipu4p_isys module:
```bash
echo 'module intel_ipu4p_isys +p' | sudo tee /sys/kernel/debug/dynamic_debug/control
```

Enable for a specific source file:
```bash 
echo 'file mc-entity.c +p' | sudo tee /sys/kernel/debug/dynamic_debug/control
```

Enable with additional decorators (optional)
To include function names (f) and line numbers (l) in the output, use:
```bash
echo 'module intel_ipu4p_isys +pfl' | sudo tee /sys/kernel/debug/dynamic_debug/control
```

Disable dynamic debugging:
```bash
echo 'module intel_ipu4p_isys -p' | sudo tee /sys/kernel/debug/dynamic_debug/control
```

```bash 
echo 'file mc-entity.c -p' | sudo tee /sys/kernel/debug/dynamic_debug/control
```

# In-kernel memory-mapped I/O tracing

- https://www.infradead.org/~mchehab/rst_features/trace/mmiotrace.html
- https://www.kernel.org/doc/Documentation/trace/mmiotrace.txt

Make sure debugfs is mounted to /sys/kernel/debug. If not (requires root privileges):
```bash
sudo mount -t debugfs debugfs /sys/kernel/debug
```

Activate mmiotrace (requires root privileges):
```bash
echo mmiotrace | sudo tee /sys/kernel/debug/tracing/current_tracer
```

Print the trace to standard output:
```bash
sudo tail -f /sys/kernel/debug/tracing/trace_pipe
```

or store the trace with a ‘cat’ running (sleeping) in the background:
```bash
sudo cat /sys/kernel/debug/tracing/trace_pipe > mydump.txt &
```

Load the driver you want to trace and use it. Mmiotrace will only catch MMIO accesses to areas that are ioremapped while mmiotrace is active.

During tracing you can place comments (markers) into the trace by `echo 'X is up' | sudo tee /sys/kernel/debug/tracing/trace_marker` This makes it easier to see which part of the (huge) trace corresponds to which action. It is recommended to place descriptive markers about what you do.

Shut down mmiotrace:
```bash
echo nop | sudo tee /sys/kernel/debug/tracing/current_tracer
```

# Some IPU4 devices

## Difference between IPU4 and IPU4P specifications

The Intel Image Processing Units (IPU4 and IPU4P) differ primarily by their associated hardware platforms and PCI Device IDs. The IPU4 (`8086:5a88`) is used in Celeron N3350/Pentium N4200/Atom E3900 series systems, while the IPU4P (`8086:8a19`) addresses all other compatible devices utilizing that specific ID. You can verify which unit you have by running `lspci -vvv -k -n`.

- IPU4 (PCI 8086:5a88): Celeron N3350/Pentium N4200/Atom E3900 Series Imaging Unit
- IPU4P (PCI 8086:8a19): For every other IPU4 devices with PCI Device ID 8a19


## Microsoft Surface Devices

||Pro 7|Book 3 13"|Book 3 15"|Laptop 3|
|-|-|-|-|-|
|Image Signal Processor|IPU4P||||
|PCI Device ID|8086:8a19||||
|&nbsp;|
|PMIC|INT3472|INT3472|INT3472||
|&nbsp;|
|Front Sensor|OV5693|OV5693|OV5693|OV9734|
|Front Sensor ACPI ID|INT33BE|INT33BE|INT33BE|OVTI9734|
|Front Module|MSHW0190|MSHW0210|MSHW0200||
|&nbsp;|
|Rear Sensor|OV8865|OV8865|OV8865||
|Rear Sensor ACPI ID|INT347A|INT347A|INT347A||
|Rear Module|MSHW0191|MSHW0211|MSHW0201||
|&nbsp;|
|IR Sensor|OV7251|OV7251|OV7251|OV7251|
|IR Sensor ACPI ID|INT347E|INT347E|INT347E|INT347E|
|IR Module|MSHW0192|MSHW0212|MSHW0202||

```bash
lspci -vvv -k

00:05.0 Multimedia controller: Intel Corporation Image Signal Processor (rev 03)
	Subsystem: Intel Corporation Image Signal Processor
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at 6000000000 (64-bit, non-prefetchable) [size=16M]
	Capabilities: <access denied>
	Kernel modules: intel_ipu4p, intel_ipu4p_isys, intel_ipu4p_psys
```

```bash
lspci -vvv -k -n

00:05.0 0480: 8086:8a19 (rev 03)
	Subsystem: 8086:7270
```

## Dell XPS 13 7390 2-in-1

|||
|-|-|
|Image Signal Processor|IPU4P|
|PCI Device ID|8086:8a19|
|Front Sensor|OV5693|
|Front Sensor ACPI ID|INT33BE|

# Extract ACPI Tables

    [!WARNING] ACPI tables can contain sensitive hardware-specific data. Redact or exclude msdm.dat: It contains your unique Windows OEM Product Key. Check for Identifiers: Files like dsdt.dsl may contain your system Serial Number or Asset Tag. tpm2.dat can expose Secure Boot and platform-bound identifiers. Always audit .dsl files for personal information before sharing them.

Install the ACPICA tools and dump the firmware tables:
```bash
sudo apt update && sudo apt install acpica-tools -y
mkdir acpi_dump && cd acpi_dump
sudo acpidump > acpi_tables.dat
mkdir dat && cd dat
acpixtract -a ../acpi_tables.dat
```

## Decompile the DSDT
The Differentiated System Description Table (DSDT) contains the camera definitions. Decompile the .dat file into a human-readable .dsl format:
```bash
iasl -d *.dat
cd ../ && mkdir -p dsl
mv dat/*.dsl dsl/
```

## Extract Port and Lane Data
Search for the SSDB buffer pattern. On Intel platforms, the hardware configuration is typically found on the line starting with offset 0018.
```bash
grep ' 0018 ' dsl/dsdt.dsl
```

## Understanding the Output
The output contains 8 hex columns. The 5th column is the CSI-2 Port, and the 6th column is the number of MIPI Lanes. Any line showing 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 represents an unassigned or empty sensor slot and can be ignored.
```
                                        Port  Lanes
                                         ↓     ↓
/* 0018 */  0x00, 0x00, 0x00, 0x00,     0x07, 0x02,    0x00, 0x00,
```

Based on the DSDT extraction, the Surface Pro 7 utilizes the following configuration:

|Sensor|Device |Port (5th Col)|Lanes (6th Col)|
|-|-|-|-|
|OV5693 (Front)|CAMF|0x07 (Port 7)|0x02 (2 Lanes)|
|OV7251 (IR)|CAM3|0x06 (Port 6)|0x01 (1 Lane)|
|OV8865 (Rear)|CAMR|0x03 (Port 3)|0x04 (4 Lanes)|

# Links

1. https://github.com/intel/ipu4-cam-hal
2. https://github.com/intel/ipu4-icamerasrc
3. https://github.com/intel/intel-camera-drivers

---

4. https://github.com/linux-surface/linux-surface/wiki/Camera-Support
5. https://wiki.ubuntu.com/Dell/XPS/XPS-13-7390-2-in-1#Camera
6. https://github.com/endeavour/DellXps7390-2in1-Manjaro-Linux-Fixes/issues/6

---

7. https://github.com/linux-surface/linux-surface/issues/91
8. https://github.com/linux-surface/linux-surface/discussions/1353?sort=new

---

9. https://github.com/Kleist/ipu4-driver
10. https://github.com/intel/ipu6-drivers
11. https://github.com/intel/linux-intel-lts/tree/lts-v5.15.195-android_t-251103T063840Z/drivers/media/pci/intel
