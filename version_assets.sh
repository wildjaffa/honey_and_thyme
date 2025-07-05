#!/bin/bash

# Generate version string in format similar to PowerShell: d-h-m-s-fff
# Using date format: day-hour-minute-second-millisecond
VERSION_STRING=$(date +"%d-%H-%M-%S-%3N")

# Replace main.dart.js with versioned main.dart.js in index.html
sed -i "s/main\.dart\.js/main.dart.js?v=${VERSION_STRING}/g" build/web/index.html

echo "Versioned main.dart.js with timestamp: ${VERSION_STRING}" 