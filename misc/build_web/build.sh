mkdir -p release
rm -f release/Nectar_Nexus.love
t=$(mktemp -d)
wd=$PWD
cp -pr main.lua aud img src "$t/"
(
  cd "$t/" || exit
  pwd
  if [ "$1" = "min" ]; then
    for i in $(find . -type f -name '*.lua'); do
      node "$wd/misc/build_web/luamin-env/node_modules/luamin/bin/luamin" -f "$i" > "$t/_tmp"
      mv "$t/_tmp" "$i"
    done
  fi
  find . -exec touch -t 198001010000 {} +
  find . -type f -print | sort | zip "$wd/release/Nectar_Nexus.love" -X -@ -9
  echo "$wd/release/Nectar_Nexus.love"
  sha1sum "$wd/release/Nectar_Nexus.love"
)
rm -rf "$t"

LOVEJS_INDEX=misc/build_web/lovejs-env/node_modules/love.js/index.js

rm -rf release/Nectar-Nexus-web
node ${LOVEJS_INDEX} --title "Nectar Nexus" release/Nectar_Nexus.love -m 134217728 -c release/Nectar-Nexus-web
cp misc/build_web/index.html release/Nectar-Nexus-web
rm -rf release/Nectar-Nexus-web/theme
