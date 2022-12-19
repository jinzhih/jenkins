#!/bin/sh
mkdir -p jenkins-data
sudo chown -R 1000:1000 jenkins-data
sudo docker compose stop jenkins || true
