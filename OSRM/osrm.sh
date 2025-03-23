#!/bin/sh

set -e

echo "Fixing apt sources for old Debian release..."
sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list
sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

echo "Updating apt & installing netcat..."
apt update && apt install -y netcat

OSM_FILE="/data/turkey-latest.osm.pbf"
HOST="download.geofabrik.de"
PATH_URL="/europe/turkey-latest.osm.pbf"

if [ ! -f "$OSM_FILE" ]; then
  echo "Downloading Turkey OSM data with netcat..."
  
  # Send HTTP GET request and clean headers
  echo -e "GET $PATH_URL HTTP/1.1\r\nHost: $HOST\r\nConnection: close\r\n\r\n" | \
    nc $HOST 80 | \
    awk 'BEGIN {header=1} /^\r$/ {header=0; next} {if (header==0) print}' > $OSM_FILE
  
  echo "Download complete."
else
  echo "Turkey OSM data already downloaded."
fi

if [ ! -f /data/turkey-latest.osrm ]; then
  echo "Extracting OSM data..."
  osrm-extract -p /opt/car.lua /data/turkey-latest.osm.pbf

  echo "Partitioning OSM data..."
  osrm-partition /data/turkey-latest.osrm

  echo "Customizing OSM data..."
  osrm-customize /data/turkey-latest.osrm
else
  echo "OSRM data already processed."
fi

echo "Starting OSRM server..."
osrm-routed --algorithm mld /data/turkey-latest.osrm
