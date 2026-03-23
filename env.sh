#!/bin/sh

# Generate config.js from environment variables at runtime
# This script runs when the container starts, allowing the same image
# to be used in multiple environments (staging, production, etc.)

set -e

CONFIG_FILE="/usr/share/nginx/html/config.js"

echo "Generating runtime configuration..."

# Start the config.js file
echo "window.ENV = {" > $CONFIG_FILE

# Iterate over all environment variables starting with VITE_
env | grep ^VITE_ | while IFS='=' read -r key value; do
  # Remove VITE_ prefix for the property name
  prop_name="${key#VITE_}"
  # Write as JavaScript property, escaping quotes in value
  escaped_value=$(echo "$value" | sed 's/"/\\"/g')
  echo "  $prop_name: \"$escaped_value\"," >> $CONFIG_FILE
done

# Close the object
echo "};" >> $CONFIG_FILE

echo "Runtime configuration generated:"
cat $CONFIG_FILE
