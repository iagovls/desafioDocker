<h1 align="center"> Desafio Compass PB </h1>
<div
  align="center"
  >
  
[![My Skills](https://skillicons.dev/icons?i=wordpress,docker,aws)](https://skillicons.dev)
</div>
<h1 align="center">
Configuração do WordPress com Docker na AWS :hammer:
</h1>




## Objetivo do Projeto
Este projeto é uma atividade prática solicitada pela equipe de estágios da Compass.UOL. O objetivo é configurar um site WordPress através do Docker dentro de uma Virtual Private Cloud (VPC) na AWS, utilizando duas instâncias EC2 um banco de dados externo também da AWS.
<div align="center">

  

<h2>Layout do projeto</h2>
<img src="https://github.com/iagovls/desafioDocker/blob/main/Screenshot%202024-12-21%20091105.png">
</div>

<div align="center">
  <h2>Introdução</h2>
  <div align="justify"> 
    <p>A arquitetura do projeto precisa conter uma <strong>VPC (Virtual Private Cloud)</strong> com uma <strong>subnet pública e uma subnet privada em uma AZ (Zona de Disponibilidade)</strong> e mais uma subnet pública e uma subnet privada em outra AZ. Cada subnet privada precisa hospedar uma <strong>instância EC2 executando uma imagem Docker do WordPress</strong> conectada a um <strong>sistema de arquivos EFS compartilhado e um banco de dados RDS para armazenamento persistente.</strong> As subnets privadas precisam estar conectadas a um <strong>NAT Gateway</strong> localizado em uma subnet pública para ter acesso à internet e com isso possibilitar acesso à internet para atualizações e dependências. As subnets públicas precisam estar conectadas a um <strong>Internet Gateaway</strong> para comunicação externa. É preciso haver também um <strong>Classic Load Balancer</strong> para gerenciar o tráfego e distribuir as requisições entre as instâncias EC2. O Classic Load Balancer precisa estar integrado a um <strong>Auto Scaling Group</strong> para adicionar e remover instâncias automaticamente conforme a demanda para garantir disponibilidade e escalabilidade do ambiente.</p>
  </div>
  <img src="https://github.com/iagovls/desafioDocker/blob/main/inbound.png" width="700">
  <p>1 - O tráfego da Internet flui pelo DNS do Application Load Balancer.</p>
  <p>2 - O Load Balancer usa sua lógica interna para determinar a instância que vai receber o tráfego.</p>
  <p>3 e 4 - Rotas locais entre a instância, subnet privada, NAT Gateway e subnet pública.</p>
</div>

---

## Etapas para Implantar o Projeto

### 1. Criar VPC

<img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTb5Y99MlSJ0cO3qSpWYKJ5g69-DvYlwxheuw&s" width="100">
<blockquote> As opções não especificadas aqui, deixar em default.</blockquote>



<details open>
<summary> 
  Passo a passo

</summary>
<br>
<table>
  <thead>
    <th>Opção</th>
    <th>Selecionar</th>
    <th>Explicação</th>
  </thead>
  <tbody>
    <tr>
      <td>Recursos a serem criados</td>
      <td>VPC e muito mais</td>
      <td>Use essa opção apenas para agilizar o processo</td>
    </tr>
    <tr>
      <td>Geração automática da etiqueta de nome</td>
      <td>Ativar Gerar automaticamente</td>
      <td>Isso padroniza os nomes dos recursos</td>      
    </tr>
    <tr>
      <td>Número de zonas de disponibilidade (AZs)</td>
      <td>2</td>
      <td>Para este projeto só precisaremos de duas zonas</td>      
    </tr>
    <tr>
      <td>Número de sub-redes privadas</td>
      <td>2</td>
      <td>Cada sub-rede receberá uma instância</td>      
    </tr>
    <tr>
      <td>Gateways NAT (USD)</td>
      <td>Em 1 AZ</td>
      <td>Necessário para as instâncias terem acesso à internet mesmo em sub-redes privadas</td>      
    </tr>
  </tbody>
</table>
</details>

<img src="https://github.com/iagovls/desafioDocker/blob/main/Screenshot%202024-12-21%20113859.png">

### 2. Criar os Grupos de Segurança na AWS
- Habilitar as seguintes regras de entrada:
- **Portas Necessárias:**
  - TCP 80 (HTTP)
  - TCP 443 (HTTPS)
  - TCP 22 (SSH)
  - TCP 2049 (NFS)
  - TCP 3306 (MYSQL)



### 3. Criar o sistema de arquivos EFS

<img src="https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcQS3jIJ-_cuOOAx3db4DIJBgp4ndqZhhYFLXOXM-cImBNC57fPC" width="100">
<blockquote> 
  As opções não especificadas aqui, deixar em default. <br/>
  Ao iniciar a criação do EFS, selecionar Personalizar. <br/>
  Para este projeto, é necessário editar apenas a etapa 2. <br/>
  Escolher um nome para o sistema de arquivos é opcional.
</blockquote>



<details open>
<summary> 
  Passo a passo

</summary>
<br>
<table>
  <thead>
    <th>Opção</th>
    <th>Selecionar</th>
    <th>Explicação</th>
  </thead>
  <tbody>
    <tr>
      <td>VPC</td>
      <td>VPC criada anteriormente</td>
      <td>É necessário escolher a mesma VPC do projeto</td>
    </tr>
    <tr>
      <td>Destinos de montagem</td>
      <td>Selecionar as duas sub-redes privadas</td>
      <td>É importante selecionar a sub-rede privada 1 para a zona 1 e a sub-rede privada 2 para a zona 2</td>      
    </tr>
    <tr>
      <td>Grupos de segurança</td>
      <td>Grupo de segurança para NFS</td>
      <td>Selecionar o mesmo grupo de segurança para as duas zonas</td>      
    </tr>   
  </tbody>
</table>
</details>



### 4. Criar banco de dados RDS

<img src="https://cloud-icons.onemodel.app/aws/Architecture-Service-Icons_01312023/Arch_Database/64/Arch_Amazon-RDS_64.svg" width="100">
<blockquote> As opções não especificadas aqui, deixar em default.</blockquote>



<details open>
<summary> 
  Passo a passo

</summary>
<br>
<table>
  <thead>
    <th>Opção</th>
    <th>Selecionar</th>
    <th>Explicação</th>
  </thead>
  <tbody>
    <tr>
      <td>Opções do mecanismo</td>
      <td>MySQL</td>
      <td></td>
    </tr>
    <tr>
      <td>Modelos</td>
      <td>Nível gratuito</td>
      <td></td>      
    </tr>
    <tr>
      <td>Gerenciamento de credenciais</td>
      <td>Opcional</td>
      <td>Escolha uma senha forte ou ative Gerar senha automaticamente. Lembre-se de guardar a senha em um local seguro</td>      
    </tr>
    <tr>
      <td>Configuração da instância</td>
      <td>db.t3.micro</td>
      <td></td>      
    </tr>
    <tr>
      <td>Grupo de segurança de VPC (firewall)</td>
      <td>Selecionar o grupo de segurança para banco de dados</td>
      <td></td>      
    </tr>
    <tr>
      <td>Nome do banco de dados inicial</td>
      <td>Opcional</td>
      <td>Essa opção fica dentro de "Configuração adicional". Esse parâmetro será necessário para a conexão do WordPress </td>      
    </tr>
  </tbody>
</table>
</details>

### 5. Configurar o user-data.sh
<img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTcvwNuFBWblL4fAMRHAeRwetIcMM9yTcuRcQ&s" width="100">
<blockquote>
  Esse código é para ser anexado na seção Dados do usuário. <br/>
  Esta seção está localizada no final das configurações na criação da instância EC2. <br/>  
</blockquote>

```
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
```
**Obs 1: Você encontrará o comando para conectar a instância EC2 com o sistema de arquivos EFS, selecionando o seu sistema de arquivos EFS (criado anteriormente) e clicando em Anexar.**  

<img src="https://github.com/iagovls/desafioDocker/blob/main/Screenshot%202024-12-21%20154447.png">
<img src="https://github.com/iagovls/desafioDocker/blob/main/Screenshot%202024-12-21%20154859.png">

**Obs 2: Você encontrará o link DNS selecionando seu banco de dados (criado anteriormente).**

<img src="https://github.com/iagovls/desafioDocker/blob/main/Screenshot%202024-12-21%20155138.png">

### 6. Criar um modelo de execução
<blockquote>
  As opções não especificadas aqui, deixar em default. <br/>
  Esta configuração serve para agilizar a criação das instâncias EC2 e também será necessário pra a configuração do Auto Scaling Group <br/>  
</blockquote>

<details open>
<summary> 
  Passo a passo

</summary>
<br>
<table>
  <thead>
    <th>Opção</th>
    <th>Selecionar</th>
    <th>Explicação</th>
  </thead>
  <tbody>
    <tr>
      <td>Nome e descrição do modelo de execução</td>
      <td>Opcional</td>
      <td></td>
    </tr>
    <tr>
      <td>Imagens de aplicação e de sistema operacional</td>
      <td>Amazon Linux</td>
      <td>Essa documentação está sendo baseada nesta versão do Linux</td>      
    </tr>
    <tr>
      <td>Tipo de instância</td>
      <td>t2.micro</td>
      <td></td>      
    </tr>
    <tr>
      <td>Configuração da instância</td>
      <td>db.t3.micro</td>
      <td></td>      
    </tr>
    <tr>
      <td>Par de chaves</td>
      <td>Caso não tenha, é necessário criar um.</td>
      <td>Essa chave é necessária para o acesso à instância via SSH. Lembre-se de guardar em um local seguro.</td>      
    </tr>
    <tr>
      <td>Sub-rede</td>
      <td>Não incluir no modelo de execução</td>
      <td>Selecionar a sub-rede adequada apenas na criação da instância EC2</td>      
    </tr>
    <tr>
      <td>Tags de recurso</td>
      <td>Name</td>
      <td>PB - Nov 2024</td>      
    </tr>
    <tr>
      <td>Tags de recurso</td>
      <td>CostCenter</td>
      <td>C092000024</td>      
    </tr>
    <tr>
      <td>Tags de recurso</td>
      <td>Project</td>
      <td>PB - Nov 2024</td>      
    </tr>
    <tr>
      <td>Dados do usuário</td>
      <td>Colar o user-data.sh criado anteriormente</td>
      <td>Essa opção fica no fim da seção Detalhes adicionais</td>      
    </tr>
  </tbody>
</table>
</details>

### 7. Criar as instâncias EC2
<img src="https://www.trianz.com/sites/default/files/inline-images/Amazon-EC2.png" width="100">

<blockquote>
  As opções não especificadas aqui, deixar em default. <br/>
  Selecionar a opção executar instância a partir de modelo e selecionar o modelo criado anteriormente. <br/>  
</blockquote>

<details open>
<summary> 
  Passo a passo

</summary>
<br>
<table>
  <thead>
    <th>Opção</th>
    <th>Selecionar</th>
    <th>Explicação</th>
  </thead>
  <tbody>
    <tr>
      <td>Sub-rede</td>
      <td>Selecionar a sub-rede privada</td>
      <td>Para este projeto, é necessário ter uma instância em cada sub-rede privada. Selecionar a sub-rede privada 1 para uma instância e a sub-rede privada 2 para a segunda instância.</td>
    </tr>   
  </tbody>
</table>
</details>

### 8. Criar o Classic Load Balancer

<blockquote>
  As opções não especificadas aqui, deixar em default. <br/>
</blockquote>

<details open>
<summary> 
  Passo a passo

</summary>
<br>
<table>
  <thead>
    <th>Opção</th>
    <th>Selecionar</th>
    <th>Explicação</th>
  </thead>
  <tbody>
    <tr>
      <td>Nome do load balancer</td>
      <td>Opcional</td>
      <td></td>
    </tr>
    <tr>
      <td>VPC</td>
      <td>Selecionar a VPC deste projeto</td>
      <td></td>      
    </tr>
    <tr>
      <td>Zonas de disponibilidade</td>
      <td>Selecionar as duas zonas de disponibilidade e uma sub-rede pública para cada zona.</td>
      <td>Selecione a sub-rede pública 1 para a zona 1 e a sub-rede pública 2 para a zona 2</td>      
    </tr>
    <tr>
      <td>Grupos de segurança </td>
      <td>Selecionar o grupo  de segurança apropriado para o Load Balancer</td>
      <td></td>      
    </tr>
    <tr>
      <td>Verificações de integridade </td>
      <td>Em Caminho de ping, colocar: /wp-admin/install.php</td>
      <td>É preciso um caminho que retorne o código 200 para o Load Balancer</td>      
    </tr>
    
  </tbody>
</table>
</details>

---

### 8. Crie o Auto Scaling
1. **Etapa 1 -** Tenha um modelo de criação de instâncias e selecione-o
2. **Etapa 2 -** Selecione a VPC e as sub-redes públicas
3. **Etapa 3 -** Selecione Anexar a um balanceador de carga existente e selecione o grupo de destino
4. **Etapa 4 -**
- Capacidade desejada: deixar em zero
- Capacidade mínima: deixar em zero
- Capacidade máxima: opcional

- Nas outras etapas, deixar em defalut e todas as configurações não mencionadas, deixar em default

---

## Tags do Projeto
- AWS
- WordPress
- Docker
- VPC
- Banco de Dados MySQL


