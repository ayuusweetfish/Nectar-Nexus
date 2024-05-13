# BOON=~/Downloads/boon-macos-amd64/boon RCEDIT=~/Downloads/rcedit-x64.exe sh misc/build_local.sh

rm -rf release
mkdir release

# Generate icon
SQUARE_ICON="convert img_raw/蜜蜂元件/蜜蜂元件/待机-侧面/侧面待机-12.png -crop 120x120+358+200 +repage"
${SQUARE_ICON} -scale 256x256 release/nectar.ico

mkdir release/nectar.iconset
${SQUARE_ICON} -scale 16x16     release/nectar.iconset/icon_16x16.png
${SQUARE_ICON} -scale 32x32     release/nectar.iconset/icon_16x16@2x.png
${SQUARE_ICON} -scale 32x32     release/nectar.iconset/icon_32x32.png
${SQUARE_ICON} -scale 64x64     release/nectar.iconset/icon_32x32@2x.png
${SQUARE_ICON} -scale 64x64     release/nectar.iconset/icon_64x64.png
${SQUARE_ICON} -scale 128x128   release/nectar.iconset/icon_64x64@2x.png
${SQUARE_ICON} -scale 128x128   release/nectar.iconset/icon_128x128.png
${SQUARE_ICON} -scale 256x256   release/nectar.iconset/icon_128x128@2x.png
${SQUARE_ICON} -scale 256x256   release/nectar.iconset/icon_256x256.png
${SQUARE_ICON} -scale 512x512   release/nectar.iconset/icon_256x256@2x.png
${SQUARE_ICON} -scale 512x512   release/nectar.iconset/icon_512x512.png
${SQUARE_ICON} -scale 1024x1024 release/nectar.iconset/icon_512x512@2x.png
iconutil -c icns release/nectar.iconset -o release/nectar.icns

# Generate
${BOON} build . --target all

# Replace icons
# win32
unzip release/Nectar-Nexus-win32.zip -d release/Nectar-Nexus-win32
rm release/Nectar-Nexus-win32.zip
wine ${RCEDIT} release/Nectar-Nexus-win32/Nectar_Nexus.exe --set-icon release/nectar.ico
# win64
unzip release/Nectar-Nexus-win64.zip -d release/Nectar-Nexus-win64
rm release/Nectar-Nexus-win64.zip
wine ${RCEDIT} release/Nectar-Nexus-win64/Nectar_Nexus.exe --set-icon release/nectar.ico
# macos
cp release/nectar.icns release/Nectar-Nexus.app/Contents/Resources/OS\ X\ AppIcon.icns
rm -rf release/Nectar-Nexus.app/Contents/Resources/_CodeSignature
rm release/Nectar-Nexus.app/Contents/Resources/Assets.car
rm release/Nectar-Nexus.app/Contents/Resources/GameIcon.icns
perl -0777 -pi -e 's/\s<key>CFBundleIconName<\/key>\n\s+<string>OS X AppIcon<\/string>\n//g' release/Nectar-Nexus.app/Contents/Info.plist

zip release/Nectar-Nexus-win32.zip -r release/Nectar-Nexus-win32 -9
zip release/Nectar-Nexus-win64.zip -r release/Nectar-Nexus-win64 -9
zip release/Nectar-Nexus.app.zip -r release/Nectar-Nexus.app -9

rm -rf release/nectar.ico release/nectar.iconset release/nectar.icns
