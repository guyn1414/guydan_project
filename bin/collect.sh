#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

DATE=$(date -u +%Y-%m-%d)
TIME=$(date -u +%H%M)

mkdir -p "raw/$DATE"
OUTPUT="raw/$DATE/$TIME.json"

if [ -e "$OUTPUT" ]; then
    echo "File already exists: $OUTPUT"
    exit 1
fi

TEMP_DIR=$(mktemp -d "raw/$DATE/.collect.XXXXXX")
trap 'rm -r "$TEMP_DIR"' EXIT

curl -fsS --max-time 30 \
'https://api.tfl.gov.uk/Occupancy/BikePoints/BikePoints_1,BikePoints_2' \
> "$TEMP_DIR/bikes.json"

curl -fsS --max-time 30 \
'https://api.tfl.gov.uk/line/mode/tube/status' \
> "$TEMP_DIR/tube.json"

curl -fsS --max-time 30 \
'https://api.open-meteo.com/v1/forecast?latitude=51.51&longitude=-0.13&current=temperature_2m,precipitation,wind_speed_10m' \
> "$TEMP_DIR/weather.json"

curl -fsS --max-time 30 \
'https://api.tfl.gov.uk/Road/all/Status' \
> "$TEMP_DIR/roads.json"

jq -n \
--slurpfile bikes "$TEMP_DIR/bikes.json" \
--slurpfile tube "$TEMP_DIR/tube.json" \
--slurpfile weather "$TEMP_DIR/weather.json" \
--slurpfile roads "$TEMP_DIR/roads.json" \
'{
    bikes: $bikes[0],
    tube: $tube[0],
    weather: $weather[0],
    roads: $roads[0]
}' > "$TEMP_DIR/sample.json"

jq -e '
    (.bikes | type == "array" and length == 2) and
    (.tube | type == "array" and length == 11) and
    (.roads | type == "array" and length > 0) and
    (.weather.current | type == "object")
' "$TEMP_DIR/sample.json" > /dev/null

mv "$TEMP_DIR/sample.json" "$OUTPUT"

echo "Saved: $OUTPUT"
