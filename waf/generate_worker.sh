#!/bin/bash

TEMPLATE="cv-proxy.template.js"
OUTPUT_DIR="generated"
OUTPUT="$OUTPUT_DIR/cv-proxy.js"
SERVERLESS_URL=$(make -C .. -s infra-url)

SERVERLESS_URL=$(echo "$SERVERLESS_URL" | tr -d '"' | tr -d "'")
SECRET_TOKEN=$(echo "$SECRET_TOKEN" | tr -d '"' | tr -d "'")

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

sed -e "s|{{SERVERLESS_URL}}|$SERVERLESS_URL|g" \
    -e "s|{{SECRET_TOKEN}}|$SECRET_TOKEN|g" \
    "$TEMPLATE" > "$OUTPUT"

echo "file $OUTPUT was successfully generated"
