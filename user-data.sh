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

#Iniciar docker
sudo systemctl start docker

#Configurar para iniciar automaticamente na iniialização do sistema
sudo systemctl enable docker


#Criar o diretório efs 
sudo mkdir -p /efs

#Conectar no AWS EFS pelo link disponibilizado 
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0fdad736ffd266e41.efs.us-east-1.amazonaws.com:/ efs
