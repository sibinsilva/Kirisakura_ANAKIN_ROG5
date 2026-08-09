#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZIP_NAME="Kirisakura-ANAKIN-ROG5-KSU-Next-v3.3.0-legacy-susfs.zip"

echo
echo "========================================="
echo "  Kirisakura Kernel - Package & Upload"
echo "========================================="
echo

# ── 1. Verify build outputs exist ────────────────────────────────────────────
echo "→ Checking build outputs..."
if [ ! -f "$SCRIPT_DIR/out_cfi/arch/arm64/boot/Image.gz" ]; then
    echo "✗ ERROR: Image.gz not found! Run ./build_kirisakura.sh first."
    exit 1
fi
echo "✓ Image.gz found"

# ── 2. Copy fresh build outputs into AnyKernel3 ──────────────────────────────
echo "→ Copying fresh kernel image and modules..."
cp "$SCRIPT_DIR/out_cfi/arch/arm64/boot/Image.gz" \
   "$SCRIPT_DIR/AnyKernel3/Image.gz"

cp "$SCRIPT_DIR/out_cfi/drivers/input/misc/sx932x_2nd.ko" \
   "$SCRIPT_DIR/AnyKernel3/modules/vendor/lib/modules/sx932x_2nd.ko"

cp "$SCRIPT_DIR/out_cfi/drivers/input/touchscreen/ROG5_TP2/focaltech_fts_rog2.ko" \
   "$SCRIPT_DIR/AnyKernel3/modules/vendor/lib/modules/focaltech_fts_rog2.ko"

echo "✓ Copied Image.gz, sx932x_2nd.ko, focaltech_fts_rog2.ko"

# ── 3. Remove old zip and create fresh one ───────────────────────────────────
echo "→ Packaging flashable zip..."
rm -f "$SCRIPT_DIR/$ZIP_NAME"
cd "$SCRIPT_DIR/AnyKernel3"
zip -r9 "$SCRIPT_DIR/$ZIP_NAME" . \
    -x "*.git*" "*README*" "*LICENSE*" "*patch*" \
    > /dev/null
cd "$SCRIPT_DIR"
echo "✓ Created $ZIP_NAME ($(du -sh $ZIP_NAME | cut -f1))"

# ── 4. Upload to Litterbox (72 hours) ────────────────────────────────────────
echo "→ Uploading to Litterbox..."
UPLOAD_URL=$(curl -s \
    -F "reqtype=fileupload" \
    -F "time=72h" \
    -F "fileToUpload=@$SCRIPT_DIR/$ZIP_NAME" \
    https://litterbox.catbox.moe/resources/internals/api.php)

if [[ "$UPLOAD_URL" == https://* ]]; then
    echo
    echo "========================================="
    echo "  ✓ Upload successful!"
    echo "  Download: $UPLOAD_URL"
    echo "========================================="
    echo
else
    echo "✗ Upload failed: $UPLOAD_URL"
    echo "  Zip is available locally at: $SCRIPT_DIR/$ZIP_NAME"
    exit 1
fi
