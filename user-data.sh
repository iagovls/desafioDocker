#!/bin/bash

#Atualizar o sistema
sudo yum update -y

#Instalar o Docker
sudo yum install docker -y

#Preparar o caminho para o download do Docker Compose
sudo mkdir -p /usr/local/lib/docker/cli-plugins

#Baixar o Docker Compose 
curl -L https://github.com/docker/compose/releases/download/v2.30.3/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose

#Modificar a permissão do diretório
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
