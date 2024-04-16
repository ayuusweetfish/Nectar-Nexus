rm Nectar_Nexus.love
zip Nectar_Nexus.love -r main.lua src img -9

rm -rf Nectar-Nexus-web
~/Downloads/node-v20.12.2-darwin-x64/bin/node ~/Downloads/lovejs-11/love.js/index.js --title "Nectar Nexus" Nectar_Nexus.love -m 134217728 -c Nectar-Nexus-web
cp misc/build/index.html Nectar-Nexus-web
rm -rf Nectar-Nexus-web/theme
