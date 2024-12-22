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
<link para anexar o sistema de arquivos EFS>

# Cria e edita o arquivo docker-compose.yml
cat <<EOF > /home/ec2-user/docker-compose.yml

services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress
    restart: always
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: "<endpoint do banco de dados>:3306"
      WORDPRESS_DB_USER: "<usuário do banco de dados>"
      WORDPRESS_DB_PASSWORD: "<senha do banco de dados>"
      WORDPRESS_DB_NAME: "<nome do banco de dados>"
    volumes:
      - /efs/wordpress:/var/www/html

EOF

cd /home/ec2-user

# Executa o arquivo docker-compose.yml
sudo docker compose up -d
