[Discussion](https://github.com/linux-surface/linux-surface/discussions/1353?sort=new) | 
[Wiki](https://github.com/linux-surface/linux-surface/wiki/Camera-Support) | 
[Downstream IPU4/IPU4P driver](https://github.com/intel/linux-intel-lts/tree/lts-v5.15.195-android_t-251103T063840Z/drivers/media/pci/intel)

# Intel IPU4P

Build Linux kernel with IPU4P support on top of the upstream IPU6/IPU7 driver.

https://docs.kernel.org/admin-guide/quickly-build-trimmed-linux.html

## Requirements

Fedora 44

## Build dependencies

```bash
sudo dnf --setopt=install_weak_deps=FALSE install \
    binutils \
    /usr/include/{libelf.h,openssl/pkcs7.h} \
    /usr/bin/{b4,bc,bison,flex,gcc,git,openssl,make,perl,pahole}
```

For RPM packaging:

```bash
sudo dnf --setopt=install_weak_deps=FALSE install \
    rpm-build rsync perl elfutils-devel
```

## Kernel source and patches

```bash
git clone --depth=1 --single-branch -b next \
    https://gitlab.freedesktop.org/linux-media/media-committers linux

git clone -b upstream https://github.com/ruslanbay/ipu4-drivers

cd linux

git checkout 27285b099fbc5cb2ae3aef20f3bbd7b3c88b3005

git am ../ipu4-drivers/patches/00*.patch
```

## Kernel configuration

Start from Fedora's x86_64 kernel configuration:

```bash
curl -L -o .config \
    https://src.fedoraproject.org/rpms/kernel/raw/f44/f/kernel-x86_64-fedora.config

make olddefconfig
```

Optional: reduce the build to modules currently used by this machine:

```bash
make localmodconfig
```

**Warning:** `localmodconfig` is host-specific. It uses the modules currently loaded on the build machine and may disable drivers for hardware or features that are not currently in use. Do not use the resulting configuration as a general-purpose Fedora kernel configuration.

Enable the IPU stack:

```bash
./scripts/config --enable CONFIG_MEDIA_SUPPORT
./scripts/config --enable CONFIG_MEDIA_PCI_SUPPORT
./scripts/config --enable CONFIG_MEDIA_CAMERA_SUPPORT
./scripts/config --module CONFIG_VIDEO_INTEL_IPU6
./scripts/config --enable CONFIG_VIDEO_INTEL_IPU6_IPU7
./scripts/config --module CONFIG_IPU_BRIDGE

./scripts/config --module CONFIG_VIDEO_OV5693
./scripts/config --module CONFIG_VIDEO_OV7251
./scripts/config --module CONFIG_VIDEO_OV8865
./scripts/config --module CONFIG_VIDEO_OV9734

make olddefconfig
```

Verify the important options:

```bash
./scripts/config --state CONFIG_VIDEO_INTEL_IPU6        # m
./scripts/config --state CONFIG_VIDEO_INTEL_IPU6_IPU7   # y
./scripts/config --state CONFIG_IPU_BRIDGE              # m
./scripts/config --state CONFIG_ACPI                    # y
./scripts/config --state CONFIG_I2C                     # y
./scripts/config --state CONFIG_VIDEO_INTEL_IPU         # undef
```

Disable debug information to keep the RPMs small:

```bash
./scripts/config --disable DEBUG_INFO
./scripts/config --disable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
./scripts/config --disable DEBUG_INFO_DWARF4
./scripts/config --disable DEBUG_INFO_DWARF5
./scripts/config --enable DEBUG_INFO_NONE

make olddefconfig
```

## Build and install

```bash
make -j"$(nproc --all)" binrpm-pkg 2>&1 | tee /tmp/ipu-build.log
```

Install the resulting packages:

```bash
sudo dnf install rpmbuild/RPMS/x86_64/*.rpm
```

## IPU4P firmware

Download the Intel camera driver package for:

https://www.catalog.update.microsoft.com/Search.aspx?q=42.18362.3.16827

Extract the CAB file with an archive tool of your choice.

Install the firmware:

```bash
sudo install -Dm644 \
    <extracted-directory>/cpd_component_signed.bin \
    /usr/lib/firmware/intel/ipu/ipu4p_fw.bin
```

Verify the firmware:

```bash
sha256sum /usr/lib/firmware/intel/ipu/ipu4p_fw.bin
```

Expected SHA-256:

```text
ff2c36cc81a5c726508b22970c2e2538ff06107dc5a72c93401403c227e5157f
```

Reboot into the new kernel.

## Verify IPU4P

Check the kernel log:

```bash
journalctl -b | grep -Ei \
    'ipu|ov5693|INT33BE|ov8865|dw9719|INT347'

Oct 29 09:14:37 mac kernel: intel-ipu6 0000:00:05.0: enabling device (0000 -> 0002)
Oct 29 09:14:37 mac kernel: intel-ipu6 0000:00:05.0: Found supported sensor INT33BE:00 (\_SB.PCI0.I2C2.CAMF)
Oct 29 09:14:37 mac kernel: intel-ipu6 0000:00:05.0: Found supported sensor INT347A:00 (\_SB.PCI0.I2C3.CAMR)
Oct 29 09:14:37 mac kernel: intel-ipu6 0000:00:05.0: Connected 2 cameras
Oct 29 09:14:37 mac kernel: intel-ipu6 0000:00:05.0: Sending BOOT_LOAD to CSE
Oct 29 09:14:37 mac kernel: intel-ipu6 0000:00:05.0: Sending AUTHENTICATE_RUN to CSE
Oct 29 09:14:37 mac kernel: intel-ipu6 0000:00:05.0: CSE authenticate_run done
Oct 29 09:14:37 mac kernel: intel-ipu6 0000:00:05.0: IPU0-v0[8a19] hardware version 1
Oct 29 09:14:37 mac kernel: ov5693 i2c-INT33BE:00: supply dovdd not found, using dummy regulator
Oct 29 09:14:37 mac kernel: ov5693 i2c-INT33BE:00: supply dvdd not found, using dummy regulator
Oct 29 09:14:37 mac kernel: ov8865 i2c-INT347A:00: supply dvdd not found, using dummy regulator
Oct 29 09:14:37 mac kernel: ov8865 i2c-INT347A:00: supply dovdd not found, using dummy regulator
Oct 29 09:14:37 mac kernel: ov8865 i2c-INT347A:00: Instantiated dw9719 VCM
```

Check loaded modules:

```bash
lsmod | grep -Ei \
    'ipu|ov5693|ov8865|dw9719|INT347'

lsmod | grep -Ei 'ipu|ov5693|ov8865|dw9719|INT347'
intel_ipu6_isys       241664  0
videobuf2_dma_sg       24576  1 intel_ipu6_isys
videobuf2_v4l2         45056  1 intel_ipu6_isys
videobuf2_common      106496  4 videobuf2_v4l2,intel_ipu6_isys,videobuf2_dma_sg,videobuf2_memops
intel_skl_int3472_tps68470    32768  0
ov5693                 24576  1
intel_skl_int3472_discrete    28672  4
ov8865                 40960  1
v4l2_cci               12288  1 ov5693
intel_skl_int3472_common    16384  2 intel_skl_int3472_tps68470,intel_skl_int3472_discrete
intel_ipu6            155648  1 intel_ipu6_isys
ipu_bridge             40960  2 intel_ipu6,intel_ipu6_isys
```

Inspect the media graph:

```bash
sudo dnf --setopt=install_weak_deps=FALSE install \
    v4l-utils graphviz

media-ctl -p
```

[`media-ctl -p` output](assets/media-ctl-p.txt)

```bash
media-ctl -d /dev/media0 --print-dot | dot -Tpng > media0-graph.png
```

![image](assets/media0-graph.png)

For libcamera testing:

```bash
sudo dnf --setopt=install_weak_deps=FALSE install \
    libcamera-qcam libcamera-ipa libcamera-tools

cam -l
```

Enable additional IPU6 ISYS debug output:

```bash
echo 'module intel_ipu6_isys +pfl' |
    sudo tee /sys/kernel/debug/dynamic_debug/control
```

In a separate terminal:

```bash
journalctl -f
```

- [ov5693 journalctl log](assets/journalctl-ov5693.txt)
- [ov8865 journalctl log](assets/journalctl-ov8865.txt)

Copy Libcamera tuning files:

```bash
cp ../ipu4-drivers/configs/usr/share/libcamera/ipa/simple/ov5693.yaml /usr/share/libcamera/ipa/simple/ov5693.yaml

cp ../ipu4-drivers/configs/usr/share/libcamera/ipa/simple/ov8865.yaml /usr/share/libcamera/ipa/simple/ov8865.yaml
```

Capture a test frame:

```bash
LIBCAMERA_LOG_LEVELS=*:DEBUG \
    cam -c 1 --capture=10 --file=/tmp/ipu4p-#.raw

ls -lh /tmp/ipu4p-*
```

- [ov5693 libcamera log](assets/libcamera-ov5693.txt)
- [ov8865 libcamera log](assets/libcamera-ov8865.txt)

Disable the additional IPU6 ISYS debug output when finished:

```bash
echo 'module intel_ipu6_isys -p' |
    sudo tee /sys/kernel/debug/dynamic_debug/control
```

## Uninstall packages

To review the transactions performed by DNF:

```bash
dnf history list
```

Identify the transaction you want to reverse, then:

```bash
sudo dnf history undo <ID>
```

`history undo` reverses the package operations performed by that specific transaction.

## (Optional) Checks

### Check Patches

```bash
git format-patch -12
0001-media-ipu6-Add-IPU4P-hardware-identification.patch
0002-media-ipu6-Add-IPU4P-MMU-support.patch
0003-media-ipu6-Add-IPU4P-buttress-support.patch
0004-media-ipu6-Add-IPU4P-ISYS-firmware-ABI-definitions.patch
0005-media-ipu6-Support-DMEM-based-SysCom-in-ipu6-fw-com.patch
0006-media-ipu6-Add-firmware-specific-ISYS-response-dispa.patch
0007-media-ipu6-Add-IPU4P-ISYS-firmware-operations.patch
0008-media-ipu6-Add-IPU4P-CSI-2-register-definitions.patch
0009-media-ipu6-Add-IPU4P-ISYS-ISR-handling.patch
0010-media-ipu6-Add-IPU4P-CSI-PHY-driver.patch
0011-media-ipu6-Work-around-IPU4P-CSI-2-port-2-timing.patch
0012-media-ipu6-Enable-IPU4P-PCI-device.patch
```

```bash
pip install gitpython

./scripts/checkpatch.pl --strict --no-signoff --terse 0*.patch
```

`--no-signoff` skips sign-off checks. Remove this option when validating patches intended for upstream submission.

```bash
0004-media-ipu6-Add-IPU4P-ISYS-firmware-ABI-definitions.patch:16: WARNING: added, moved or deleted file(s), does MAINTAINERS need updating?
total: 0 errors, 1 warnings, 0 checks, 398 lines checked
0007-media-ipu6-Add-IPU4P-ISYS-firmware-operations.patch:41: WARNING: added, moved or deleted file(s), does MAINTAINERS need updating?
total: 0 errors, 1 warnings, 0 checks, 1370 lines checked
0008-media-ipu6-Add-IPU4P-CSI-2-register-definitions.patch:16: WARNING: added, moved or deleted file(s), does MAINTAINERS need updating?
total: 0 errors, 1 warnings, 0 checks, 22 lines checked
0010-media-ipu6-Add-IPU4P-CSI-PHY-driver.patch:36: WARNING: added, moved or deleted file(s), does MAINTAINERS need updating?
total: 0 errors, 1 warnings, 0 checks, 266 lines checked
```

### Compare two builds to make sure there are no new warnings introduced

Baseline

```bash
git reset --hard d7e7bca7169873b46e857c025c10f3336c1258d8

make clean && make W=12 -j1 drivers/media/pci/intel/ipu6/ 2>&1 | tee /tmp/ipu-d7e7bca7169873b46e857c025c10f3336c1258d8.log

Candidate

git reset --hard c62084abd5e427ca08290ac093aef0994aafea19

make clean &&  make W=12 -j1 drivers/media/pci/intel/ipu6/ 2>&1 | tee /tmp/ipu-c62084abd5e427ca08290ac093aef0994aafea19.log

Compare Baseline vs Candidate

diff -y --suppress-common-lines \
        /tmp/ipu-d7e7bca7169873b46e857c025c10f3336c1258d8.log \
        /tmp/ipu-c62084abd5e427ca08290ac093aef0994aafea19.log
```