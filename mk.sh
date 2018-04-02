#!/bin/sh
xcodebuild -sdk iphonesimulator11.3 -configuration Debug
cp build/Debug-iphonesimulator/libpluginTest.dylib ~/iosruntimes/
codesign -f -s - ~/iosruntimes/libpluginTest.dylib

