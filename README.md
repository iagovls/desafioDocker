<h1 align="center"> Desafio Compass PB </h1>
<div align="center">  
  
  [![My Skills](https://skillicons.dev/icons?i=wordpress,docker,aws)](https://skillicons.dev)
  
</div>
<h1 align="center">
  Configuração do WordPress com Docker em um VPC na AWS
</h1>

## 🚀Objetivo do Projeto
Este projeto é uma atividade prática solicitada pela equipe de estágios da Compass.UOL. O objetivo é configurar um site WordPress através do Docker dentro de uma Virtual Private Cloud (VPC) na AWS, utilizando duas instâncias EC2 um banco de dados externo também da AWS.

## Índice
* [Layout do projeto](https://github.com/iagovls/desafioDocker/blob/main/README.md#%EF%B8%8F-layout-do-projeto)
* [Introdução](https://github.com/iagovls/desafioDocker/blob/main/README.md#-introdu%C3%A7%C3%A3o)
* [Etapas para Implantar o Projeto](https://github.com/iagovls/desafioDocker/blob/main/README.md#-etapas-para-implantar-o-projeto)
1. [Criar VPC](https://github.com/iagovls/desafioDocker/blob/main/README.md#1-criar-vpc)
2. [Criar os Grupos de Segurança](https://github.com/iagovls/desafioDocker/blob/main/README.md#2-criar-os-grupos-de-seguran%C3%A7a)
3. [Criar o sistema de arquivos EFS](https://github.com/iagovls/desafioDocker/blob/main/README.md#3-criar-o-sistema-de-arquivos-efs)
4. [Criar banco de dados RDS](https://github.com/iagovls/desafioDocker/blob/main/README.md#4-criar-banco-de-dados-rds)
5. [Criar um modelo de execução](https://github.com/iagovls/desafioDocker/edit/main/README.md#5-criar-um-modelo-de-execu%C3%A7%C3%A3o)
6. [Criar as instâncias EC2](https://github.com/iagovls/desafioDocker/edit/main/README.md#6-criar-as-inst%C3%A2ncias-ec2)
7. [Acessar a uma instância via SSH](https://github.com/iagovls/desafioDocker/edit/main/README.md#7-acessar-a-uma-inst%C3%A2ncia-via-ssh)
8. [Criar o Classic Load Balancer](https://github.com/iagovls/desafioDocker/edit/main/README.md#8-criar-o-classic-load-balancer
)
9. [Criar o Auto Scaling](https://github.com/iagovls/desafioDocker/edit/main/README.md#9-criar-o-auto-scaling)
* [Tags do Projeto](https://github.com/iagovls/desafioDocker/edit/main/README.md#tags-do-projeto)
* [Agradecimentos](https://github.com/iagovls/desafioDocker/edit/main/README.md#agradecimentos
)

<div align="center">
  <h2>✒️ Layout do projeto</h2>
  <img src="https://github.com/iagovls/desafioDocker/blob/main/imagens/layout1.png">
</div>

<div align="center">
  <h2>📃 Introdução</h2>
  <div align="justify"> 
    <p>A arquitetura do projeto precisa conter uma <strong>VPC (Virtual Private Cloud)</strong> com uma <strong>subnet pública e uma subnet privada em uma AZ (Zona de Disponibilidade)</strong> e mais uma subnet pública e uma subnet privada em outra AZ. Cada subnet privada precisa hospedar uma <strong>instância EC2 executando uma imagem Docker do WordPress</strong> conectada a um <strong>sistema de arquivos EFS compartilhado e um banco de dados RDS para armazenamento persistente.</strong> As subnets privadas precisam estar conectadas a um <strong>NAT Gateway</strong> localizado em uma subnet pública para ter acesso à internet e com isso possibilitar acesso à internet para atualizações e dependências. As subnets públicas precisam estar conectadas a um <strong>Internet Gateaway</strong> para comunicação externa. É preciso haver também um <strong>Classic Load Balancer</strong> para gerenciar o tráfego e distribuir as requisições entre as instâncias EC2. O Classic Load Balancer precisa estar integrado a um <strong>Auto Scaling Group</strong> para adicionar e remover instâncias automaticamente conforme a demanda para garantir disponibilidade e escalabilidade do ambiente.</p>
  </div>

</div>

<br/>

---

<br/>

## 📝 Etapas para Implantar o Projeto

### 1. Criar VPC

<img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTb5Y99MlSJ0cO3qSpWYKJ5g69-DvYlwxheuw&s" width="100">

#### O VPC (Virtual Private Cloud) permite criar uma rede virtual privada. Você pode definir sub-redes, configurar tabelas de roteamento, gateways de internet e outras funcionalidades de rede.

`As opções não especificadas aqui, deixar em default.`

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

<img src="https://github.com/iagovls/desafioDocker/blob/main/imagens/previsualizacaoVPC.png">

<br/>

---

<br/>

### 2. Criar os Grupos de Segurança

<img src="https://songsofsyx.com/wiki/images/9/9e/Lock_icon.png?20210530185635" width="100">

#### Os grupos de segurança são firewalls virtuais que controlam o tráfego de entrada e saída de recursos. Eles permitem definir regras baseadas em IP, protocolos e portas.

`As opções não especificadas aqui, deixar em default.`

  Portas Necessárias para este projeto: <br/>
  - TCP 80 (HTTP)  <br/>
  - TCP 22 (SSH) <br/>
  - TCP 2049 (NFS) <br/>
  - TCP 3306 (MYSQL) <br/>

`Serão necessários grupos de segurança para as Instâncias, RDS, EFS e Load Balancer.`

`Para este projeto será apenas necessário ajustar as regras de entrada.`

`Para cada grupo de segurança, selecionar o VPC deste projeto.`

<details open>
<summary> 
  Passo a passo

</summary>
<br>
<table>
  <thead>
    <th>Grupo de segurança</th>
    <th>Portas</th>
    <th>Códigos</th>
  </thead>
  <tbody>
    <tr>
      <td>Instâncias</td>
      <td>HTTP, SSH, NFS, MYSQL</td>
      <td>80, 22, 2049, 3306</td>
    </tr>
    <tr>
      <td>Sistema de arquivos EFS</td>
      <td>NFS e SSH</td>
      <td>2049 e 22</td>      
    </tr>
    <tr>
      <td>Banco de Dados RDS</td>
      <td>MYSQL</td>
      <td>3306</td>      
    </tr>   
    <tr>
      <td>Load Balancer</td>
      <td>HTTP</td>
      <td>80</td>      
    </tr>   
  </tbody>
</table>
</details>

<br/>

---

<br/>

### 3. Criar o sistema de arquivos EFS



<img src="https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcQS3jIJ-_cuOOAx3db4DIJBgp4ndqZhhYFLXOXM-cImBNC57fPC" width="100">

#### O Amazon EFS (Elastic File System) é um serviço de sistema de arquivos escalável e elástico fornecido pela Amazon Web Services (AWS). Ele permite que múltiplas instâncias do Amazon EC2 (ou outros serviços) acessem simultaneamente um sistema de arquivos compartilhado, com alta disponibilidade e baixa latência.

`As opções não especificadas aqui, deixar em default.`

`Ao iniciar a criação do EFS, selecionar Personalizar.`

`Para este projeto, é necessário editar apenas a etapa 2.`

`Escolher um nome para o sistema de arquivos é opcional.`



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

<br/>

---

<br/>

### 4. Criar banco de dados RDS

<img src="https://cloud-icons.onemodel.app/aws/Architecture-Service-Icons_01312023/Arch_Database/64/Arch_Amazon-RDS_64.svg" width="100">

#### O Amazon RDS é um serviço gerenciado de banco de dados na nuvem. Ele oferece backups automatizados, alta disponibilidade e escalabilidade.

`As opções não especificadas aqui, deixar em default.`



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

<br/>

---

<br/>





**Obs 1: Você encontrará o comando para conectar a instância EC2 com o sistema de arquivos EFS, selecionando o seu sistema de arquivos EFS (criado anteriormente) e clicando em Anexar.**  

<img src="https://github.com/iagovls/desafioDocker/blob/main/imagens/anexarButton.png">

<img src="https://github.com/iagovls/desafioDocker/blob/main/imagens/linkEFS.png">

**Obs 2: Você encontrará o link DNS selecionando seu banco de dados (criado anteriormente).**

<img src="https://github.com/iagovls/desafioDocker/blob/main/imagens/endpointDB.png">

<br/>

---

<br/>

### 5. Criar um modelo de execução

<img src="https://www.trianz.com/sites/default/files/inline-images/Amazon-EC2.png" width="100">


  `As opções não especificadas aqui, deixar em default.`

  `Esta configuração serve para agilizar a criação das instâncias EC2 e também será necessário pra a configuração do Auto Scaling Group`  


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
      <td>Firewall (grupos de segurança)</td>
      <td>Selecionar grupo de segurança existente</td>
      <td></td>      
    </tr>
    <tr>
      <td>Grupos de segurança</td>
      <td>Selecionar o grupo de segurança para Instâncias</td>
      <td></td>      
    </tr>
   

  </tbody>
</table>


`Na seção Tags de recurso, utilizar as seguintes tags`

|Tag de recurso|Valor     |Chave        |
|---           |---       |---          |
|1             |Name      |PB - Nov 2024|
| 2            |CostCenter| C092000024  |
| 3            |Project   |PB - Nov 2024|

#### Configurar o user-data.sh

<img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTcvwNuFBWblL4fAMRHAeRwetIcMM9yTcuRcQ&s" width="100">

 O User-Data.sh é um script que pode ser executado automaticamente na inicialização de uma instância EC2 e assim automatizar configurações, atualizações, executar comandos entre outras funcionalidades. 

`
  Esse código é para ser anexado na seção Dados do usuário.
  Esta seção está localizada no final das configurações na criação da instância EC2.
`

```sh
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
</details>

<br/>

---

<br/>

### 6. Criar as instâncias EC2

<img src="https://www.trianz.com/sites/default/files/inline-images/Amazon-EC2.png" width="100">

#### O Amazon EC2 fornece capacidade de computação na nuvem. Ele permite criar e usar máquinas virtuais com diferentes sistemas operacionais.


 ` As opções não especificadas aqui, deixar em default.` 
  
  `Selecionar a opção executar instância a partir de modelo e selecionar o modelo criado anteriormente.`

  `Todas as configurações serão ajustadas automaticamente conforme o modelo, será necessário ajustar somente as sub-redes.`


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

<br/>

---

<br/>

### 7. Acessar a uma instância via SSH

<img src="https://www.trianz.com/sites/default/files/inline-images/Amazon-EC2.png" width="100">

#### Você pode precisar acessar às instâncias eventualmente. Considenrando que as instâncias das sub-redes privadas estão configuradas corretamente ao EFS, qualquer alteração em no diretório EFS das instâncias das sub-redes públicas terá efeito nas instâncias nas sub-redes privadas. 

`Passo a passo para acessar a instância na sub-rede pública via SSH.`

`Não é recomendado haver uma instância em uma sub-rede púbica com ip público. Estas instâncias precisam ser temporárias. Logo, encerre estas instâncias quando não precisar delas.`

<details open>
<summary> 
  Passo a passo

</summary>

1. Crie uma nova instância com as mesmas configurações do [tópico 5](https://github.com/iagovls/desafioDocker?tab=readme-ov-file#5-criar-um-modelo-de-execu%C3%A7%C3%A3o)

2.  Em **Configurações de rede** clique em **Editar**.

3. Em **Sub-rede** selecione uma sub-rede pública.

4. Em **Atribuir IP público automaticamente** selecione **Habilitar**.

5. Execute a instância.

6. Acesse um terminal.

7. Acesse o diretório onde está localizado a chave de acesso da instância.

8. Execute o seguinte comando abaixo substituindo o ``nome da chave de acesso`` e o ``IP público`` da instância.

```sh
ssh -i <chaveDeAcesso>.pem ec2-user@<ipPublicoDaInstância>
```

</details>

<br/>

---

<br/>

### 8. Criar o Classic Load Balancer

<img src="https://www.kirznerdobrasil.com.br/blog/wp-content/uploads/2019/12/load-balance.png" width="100">

#### O Classic Load Balancer é um serviço que distribui automaticamente o tráfego de entrada entre várias instâncias EC2 em uma ou mais zonas de disponibilidade.

`As opções não especificadas aqui, deixar em default.`

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

#### Após a criação do Load Balancer, o link DNS estará disponivel. 

<img src="https://github.com/iagovls/desafioDocker/blob/main/imagens/linkDNS-LB.png">

#### Acesse-o pelo navegador e você deve esperar a página inicial de configuração do WordPress como na imagem abaixo.

<img src="https://github.com/iagovls/desafioDocker/blob/main/imagens/pagina-inicial-WP.png">

<br/>

---

<br/>

### 9. Criar o Auto Scaling

#### O Auto Scaling ajusta automaticamente a quantidade de instâncias EC2 com base na demanda de tráfego ou desempenho.


  `As opções não especificadas aqui, deixar em default. `

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
      <td>Nome do grupo do Auto Scaling</td>
      <td>Opcional</td>
      <td></td>
    </tr>
    <tr>
      <td>Modelo de execução</td>
      <td>Selecionar o modelo de execução criado anteriormente</td>
      <td></td>      
    </tr>
    <tr>
      <td>VPC</td>
      <td>Selecionar o VPC deste projeto</td>
      <td></td>      
    </tr>
    <tr>
      <td>Zonas de disponibilidade e sub-redes</td>
      <td>Selecionar as duas sub-redes públicas</td>
      <td>O Auto Scaling vai distribuir as novas instâncias entre as duas sub-redes</td>      
    </tr>
    <tr>
      <td>Balanceamento de carga</td>
      <td>Anexar a um balanceador de carga existente</td>
      <td></td>      
    </tr>
    <tr>
      <td>Anexar a um balanceador de carga existente</td>
      <td>Escolher entre Classic Load Balancers</td>
      <td>Selecione o Classic Load Balancer criado anteriormente</td>      
    </tr>
      <tr>
      <td>Capacidade desejada </td>
      <td>0</td>
      <td>Inicialmente haverá apenas as duas instâncias criadas anteriormente</td>      
    </tr>
      <tr>
      <td>Capacidade mínima desejada</td>
      <td>0</td>
      <td>Inicialmente haverá apenas as duas instâncias criadas anteriormente</td>      
    </tr>
      <tr>
      <td>Capacidade máxima desejada</td>
      <td>Opcional</td>
      <td>Ajustar conforme a necessidade futura</td>      
    </tr>
  </tbody>
</table>
</details>
        
---

## Tags do Projeto
- AWS
- WordPress
- Docker
- VPC
- Banco de Dados MySQL

## 🤝Agradecimentos

Obrigado Ana Soares Nunes pela parceria.
Obrigado pelo auxílio, Davi Santos Cardoso da Silva e Paulo Henrique Nunes Silva.

