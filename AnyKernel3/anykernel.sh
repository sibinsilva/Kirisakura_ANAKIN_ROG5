### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=Kirisakura-Kernel (SuKiSU Ultra Edition)
do.devicecheck=1
do.modules=1
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=ZS673KS
device.name2=ROG5
device.name3=I005D
device.name4=I005DA
device.name5=ASUS_I005_1
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot files attributes
boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
set_perm 0 0 755 $RAMDISK/ksud;
} # end attributes

# boot shell variables
BLOCK=/dev/block/bootdevice/by-name/boot;
IS_SLOT_DEVICE=auto;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
dump_boot; # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk

write_boot; # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
## end boot install


## init_boot files attributes
#init_boot_attributes() {
#set_perm_recursive 0 0 755 644 $RAMDISK/*;
#set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
#} # end attributes

# init_boot shell variables
#BLOCK=init_boot;
#IS_SLOT_DEVICE=1;
#RAMDISK_COMPRESSION=auto;
#PATCH_VBMETA_FLAG=auto;

# reset for init_boot patching
#reset_ak;

# init_boot install
#dump_boot; # unpack ramdisk since it is the new first stage init ramdisk where overlay.d must go

#write_boot;
## end init_boot install


## vendor_kernel_boot shell variables
#BLOCK=vendor_kernel_boot;
#IS_SLOT_DEVICE=1;
#RAMDISK_COMPRESSION=auto;
#PATCH_VBMETA_FLAG=auto;

# reset for vendor_kernel_boot patching
#reset_ak;

# vendor_kernel_boot install
#split_boot; # skip unpack/repack ramdisk, e.g. for dtb on devices with hdr v4 and vendor_kernel_boot

#flash_boot;
## end vendor_kernel_boot install


## vendor_boot files attributes
#vendor_boot_attributes() {
#set_perm_recursive 0 0 755 644 $RAMDISK/*;
#set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
#} # end attributes

# vendor_boot shell variables
#BLOCK=vendor_boot;
#IS_SLOT_DEVICE=1;
#RAMDISK_COMPRESSION=auto;
#PATCH_VBMETA_FLAG=auto;

# reset for vendor_boot patching
#reset_ak;

# vendor_boot install
#dump_boot; # use split_boot to skip ramdisk unpack, e.g. for dtb on devices with hdr v4 but no vendor_kernel_boot

#write_boot; # use flash_boot to skip ramdisk repack, e.g. for dtb on devices with hdr v4 but no vendor_kernel_boot
## end vendor_boot install

# ── Clean up previous systemless Tuxera modules ─────────────────────────
mount /data 2>/dev/null || true
if [ -d /data/adb/modules/kirisakura_tuxera ] || [ -d /data/adb/modules_update/kirisakura_tuxera ]; then
    ui_print " ";
    ui_print "→ Removing old systemless Tuxera module...";
    rm -rf /data/adb/modules/kirisakura_tuxera
    rm -rf /data/adb/modules_update/kirisakura_tuxera
    # For SuKiSU Ultra, we must make sure KSU detects the update
    if [ -d /data/adb/ksu ]; then
        touch /data/adb/ksu/update
    fi
    ui_print "✓ Removed old module.";
    ui_print " ";
fi

# ── Install automatic Tuxera module loader at boot ──────────────────────
ui_print "→ Setting up Tuxera OTG Support...";
mkdir -p /data/adb/service.d
cat << 'EOF' > /data/adb/service.d/load_tuxera.sh
#!/system/bin/sh
# Wait until vendor partition is mounted and files are available
for i in $(seq 1 10); do
    if [ -f /vendor/lib/modules/texfat.ko ]; then
        break
    fi
    sleep 2
done

insmod /vendor/lib/modules/texfat.ko
insmod /vendor/lib/modules/tntfs.ko
EOF

chmod 755 /data/adb/service.d/load_tuxera.sh
chown 0:0 /data/adb/service.d/load_tuxera.sh
ui_print "✓ Tuxera OTG Support script installed.";
ui_print " ";



