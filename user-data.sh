#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -L https://github.com/docker/compose/releases/download/v2.30.3/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo mkdir -p /efs
cd /
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-07247bdde1bb0f1a1.efs.us-east-1.amazonaws.com:/ efs

cat <<EOF > /home/ec2-user/docker-compose.yml

services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress
    restart: always
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: "database-1.cx406gsimskz.us-east-1.rds.amazonaws.com:3306"
      WORDPRESS_DB_USER: "admin"
      WORDPRESS_DB_PASSWORD: "e2bd6AY5GFN8vjA17I53"
      WORDPRESS_DB_NAME: "database_1"
    volumes:
      - /efs/wordpress:/var/www/html

  db:
    image: mysql:5.7
    container_name: mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: "e2bd6AY5GFN8vjA17I53"
      MYSQL_DATABASE: "database_1"
      MYSQL_USER: "admin"
      MYSQL_PASSWORD: "e2bd6AY5GFN8vjA17I53"
    volumes:
      - /efs/mysql:/var/lib/mysql

volumes:
  wordpress_data:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=fs-07247bdde1bb0f1a1.efs.us-east-1.amazonaws.com,rw,nfsvers=4.1"
      device: ":/wordpress"
  mysql_data:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=fs-07247bdde1bb0f1a1.efs.us-east-1.amazonaws.com,rw,nfsvers=4.1"
      device: ":/mysql"

EOF

cd /home/ec2-user
sudo docker compose up -d
