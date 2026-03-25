#!/bin/bash
# Build script for BPS Data Uploader Windows executable
# Run this script to create the .exe file

echo "=========================================="
echo "BPS DATA UPLOADER - BUILD SCRIPT"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "requirements.txt" ]; then
    echo "❌ Error: requirements.txt not found!"
    echo "Please run this script from the bps-data-uploader directory"
    exit 1
fi

echo "📦 Step 1: Installing dependencies..."
pip install -r requirements.txt

echo ""
echo "🔧 Step 2: Creating executable..."

# Create build directory
mkdir -p build dist

# Build with PyInstaller
pyinstaller \
    --name "BPS_Data_Uploader" \
    --onefile \
    --windowed \
    --icon "NONE" \
    --add-data "src/*:src" \
    --clean \
    --distpath ./dist \
    --workpath ./build \
    src/main.py

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📁 Output file: dist/BPS_Data_Uploader.exe"
    echo ""
    echo "Next steps:"
    echo "1. Test the .exe file"
    echo "2. Create installer with Inno Setup (optional)"
    echo "3. Distribute to BPS staff"
else
    echo ""
    echo "❌ Build failed!"
    echo "Check error messages above"
    exit 1
fi
