[Discussion](https://github.com/linux-surface/linux-surface/discussions/1353?sort=new) | 
[Wiki](https://github.com/linux-surface/linux-surface/wiki/Camera-Support) | 
[Downstream IPU4/IPU4P driver](https://github.com/intel/linux-intel-lts/tree/lts-v5.15.195-android_t-251103T063840Z/drivers/media/pci/intel)

# Intel IPU4P

Build Linux `v7.3-rc6` with IPU4P support on top of the upstream IPU6/IPU7 driver.

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
git clone --depth=1 --single-branch -b v7.3-rc6 \
    https://github.com/torvalds/linux

git clone -b upstream https://github.com/ruslanbay/ipu4-drivers

cd linux

git config --local user.name "Your Name"
git config --local user.email "you@example.com"

b4 shazam \
    https://lore.kernel.org/all/20260907113004.2489993-1-sakari.ailus@linux.intel.com/

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

https://www.catalog.update.microsoft.com/Search.aspx?q=42.17134.3.10471

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
ee534f37f979dfc20e1cb4681bae47c9ec57639f3a2d032b79d77b3097b74d97
```

Reboot into the new kernel.

## Verify IPU4P

Check the kernel log:

```bash
journalctl -b | grep -Ei \
    'ipu|ov5693|INT33BE|ov8865|dw9719|INT347'

Oct 11 12:12:41 mac kernel: intel-ipu6 0000:00:05.0: enabling device (0000 -> 0002)
Oct 11 12:12:41 mac kernel: intel-ipu6 0000:00:05.0: Found supported sensor INT33BE:00
Oct 11 12:12:41 mac kernel: intel-ipu6 0000:00:05.0: Found supported sensor INT347A:00
Oct 11 12:12:41 mac kernel: intel-ipu6 0000:00:05.0: Connected 2 cameras
Oct 11 12:12:41 mac kernel: intel-ipu6 0000:00:05.0: Sending BOOT_LOAD to CSE
Oct 11 12:12:41 mac kernel: intel-ipu6 0000:00:05.0: Sending AUTHENTICATE_RUN to CSE
Oct 11 12:12:41 mac kernel: intel-ipu6 0000:00:05.0: CSE authenticate_run done
Oct 11 12:12:41 mac kernel: intel-ipu6 0000:00:05.0: IPU0-v0[8a19] hardware version 64
Oct 11 12:12:41 mac kernel: ov5693 i2c-INT33BE:00: supply dovdd not found, using dummy regulator
Oct 11 12:12:41 mac kernel: ov5693 i2c-INT33BE:00: supply dvdd not found, using dummy regulator
Oct 11 12:12:41 mac kernel: ov8865 i2c-INT347A:00: supply dvdd not found, using dummy regulator
Oct 11 12:12:41 mac kernel: ov8865 i2c-INT347A:00: supply dovdd not found, using dummy regulator
Oct 11 12:12:42 mac kernel: ov8865 i2c-INT347A:00: Instantiated dw9719 VCM
Oct 11 12:12:42 mac kernel: dw9719 i2c-INT347A:00-VCM: supply vdd not found, using dummy regulator
```

Check loaded modules:

```bash
lsmod | grep -Ei \
    'ipu|ov5693|ov8865|dw9719|INT347'

dw9719                 12288  1
intel_ipu6_isys       233472  0
videobuf2_dma_sg       24576  1 intel_ipu6_isys
videobuf2_v4l2         45056  1 intel_ipu6_isys
videobuf2_common      106496  4 videobuf2_v4l2,intel_ipu6_isys,videobuf2_dma_sg,videobuf2_memops
intel_skl_int3472_tps68470    24576  0
ov5693                 24576  1
ov8865                 40960  1
v4l2_cci               12288  2 ov5693,dw9719
v4l2_fwnode            40960  3 ov5693,intel_ipu6_isys,ov8865
v4l2_async             36864  5 v4l2_fwnode,ov5693,intel_ipu6_isys,dw9719,ov8865
intel_skl_int3472_discrete    28672  4
videodev              450560  7 v4l2_async,v4l2_fwnode,videobuf2_v4l2,ov5693,intel_ipu6_isys,dw9719,ov8865
intel_skl_int3472_common    16384  2 intel_skl_int3472_tps68470,intel_skl_int3472_discrete
mc                     98304  8 v4l2_async,videodev,videobuf2_v4l2,ov5693,intel_ipu6_isys,videobuf2_common,dw9719,ov8865
intel_ipu6            143360  1 intel_ipu6_isys
ipu_bridge             28672  2 intel_ipu6,intel_ipu6_isys
```

Inspect the media graph:

```bash
sudo dnf --setopt=install_weak_deps=FALSE install \
    v4l-utils graphviz

media-ctl -p
media-ctl -d /dev/media0 --print-dot | dot -Tpng > media0-graph.png
```

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

Capture a test frame:

```bash
LIBCAMERA_LOG_LEVELS=*:DEBUG \
    cam -c 1 --capture=10 --file=/tmp/ipu4p-#.raw

ls -lh /tmp/ipu4p-*
```

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
