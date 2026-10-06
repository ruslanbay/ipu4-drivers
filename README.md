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
```

Check loaded modules:

```bash
lsmod | grep -Ei \
    'ipu|ov5693|ov8865|dw9719|INT347'
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

## Undo the DNF changes

To review the transactions performed by DNF:

```bash
dnf history list
```

Identify the transaction you want to reverse, then:

```bash
sudo dnf history undo <ID>
```

`history undo` reverses the package operations performed by that specific transaction.
