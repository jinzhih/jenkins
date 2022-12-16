#!/bin/sh
sudo docker compose run --rm -d jenkins
sudo docker compose exec jenkins echo "1"
if [ $? -ne 0 ]; then
    sudo chown -R 1000:1000 jenkins-data
fi
sudo docker compose stop jenkins || true
sudo docker compose up
