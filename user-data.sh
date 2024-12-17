#!/bin/bash

# Atualiza o sistema
sudo yum update -y

# Instala o docker
sudo yum install docker -y

# Cria o diretório para o download do Docker compose
sudo mkdir -p /usr/local/lib/docker/cli-plugins

# Download do Docker Compose
sudo curl -L https://github.com/docker/compose/releases/download/v2.30.3/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose

# Altera a permissão do docker-compose 
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Inicia o Docker
sudo systemctl start docker

# Configura para o Docker ser iniciado junto com o sistema
sudo systemctl enable docker

# Cria o diretório efs 
sudo mkdir -p /efs

#  Monta um sistema de arquivos da Amazon Elastic File System (EFS) no Linux
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-078e758228282bd37.efs.us-east-1.amazonaws.com:/ efs

# Cria e edita o arquivo docker-compose.yml
# Alterar as configurações sobre o DB e o EFS conforme como foi criado na AWS
cat <<EOF > /home/ec2-user/docker-compose.yml

services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress
    restart: always
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: "database-2.cx406gsimskz.us-east-1.rds.amazonaws.com:3306"
      WORDPRESS_DB_USER: "admin"
      WORDPRESS_DB_PASSWORD: "2xdLLFuFwpKVtgff5plw"
      WORDPRESS_DB_NAME: "database_2"
    volumes:
      - /efs/wordpress:/var/www/html

  db:
    image: mysql:5.7
    container_name: mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: "2xdLLFuFwpKVtgff5plw"
      MYSQL_DATABASE: "database_2"
      MYSQL_USER: "admin"
      MYSQL_PASSWORD: "2xdLLFuFwpKVtgff5plw"
    volumes:
      - /efs/mysql:/var/lib/mysql

volumes:
  wordpress_data:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=fs-078e758228282bd37.efs.us-east-1.amazonaws.com,rw,nfsvers=4.1"
      device: ":/wordpress"
  mysql_data:
    driver: local
    driver_opts:
      type: "nfs"
      o: "addr=fs-078e758228282bd37.efs.us-east-1.amazonaws.com,rw,nfsvers=4.1"
      device: ":/mysql"

EOF

cd /home/ec2-user

# Executa o arquivo docker-compose.yml
sudo docker compose up -d
