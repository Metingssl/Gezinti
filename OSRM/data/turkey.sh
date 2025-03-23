#!/bin/bash

# Harita verisinin indirilmesi
echo "Türkiye haritası indiriliyor..."
mkdir -p data
wget -O data/turkey-latest.osm.pbf https://download.geofabrik.de/europe/turkey-latest.osm.pbf

# OSRM için gerekli işlemlerin yapılması
echo "OSRM işlemleri başlatılıyor..."
docker run --rm -v $(pwd)/data:/data osrm/osrm-backend osrm-extract -p /opt/car.lua /data/turkey-latest.osm.pbf
docker run --rm -v $(pwd)/data:/data osrm/osrm-backend osrm-partition /data/turkey-latest.osrm
docker run --rm -v $(pwd)/data:/data osrm/osrm-backend osrm-customize /data/turkey-latest.osrm

echo "Türkiye haritası hazır!"
