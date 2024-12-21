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



### 2. Criar os Grupos de Segurança na AWS
- Habilitar as seguintes regras de entrada:
- **Portas Necessárias:**
  - TCP 80 (HTTP)
  - TCP 443 (HTTPS)
  - TCP 22 (SSH)
  - TCP 2049 (NFS)
  - TCP 3306 (MYSQL)

---

### 3. Criar e Configurar um EFS
1. **Escolha a opção de EFS personalizado.**
2. **Etapa 1:**
   - Opcionalmente, nomeie o EFS.
   - Mantenha todas as outras opções nos valores padrão.
3. **Etapa 2:**
   - Selecione as sub-redes privadas 
   - Atribua o grupo de segurança criado anteriormente a cada zona de disponibilidade.
5. **Etapa 3:**
   - Não modifique a política do sistema de arquivos.
6. **Finalize a configuração.**

---

### 4. Criar e Configurar o Banco de Dados
- **Detalhes de Configuração:**
  1. **Método de Criação:**
     - Escolha o método padrão.
  2. **Opções do Mecanismo:**
     - MySQL.
  3. **Modelos:**
     - Nível gratuito.
  4. **Configuração da Instância:**
     - Classe da instância: `db.t3.micro`.
  5. **Conectividade:**
     - Atribua o grupo de segurança criado anteriormente.
     - Não se conectar a um recurso de computação do EC2
     - Acesso Público: não
  6. **Configuração adicional:**
     - Nome do banco de dados
  7. **Guardar a senha do DB**
---

### 5. Iniciar duas Instâncias EC2
- **Detalhes da Configuração das Instâncias:**

  1. **Tags:**
     - `Name: PB - Nov 2024`
     - `CostCenter: C092000024`
     - `Project: PB - Nov 2024`

  2. **AMI (Amazon Machine Image):**
     - Selecione o Amazon Linux.

  3. **Tipo de Instância:**
     - `t2.micro`.

  4. **Par de Chaves:**
     - Caso não tenha, crie um novo par de chaves `.pem` e salve o arquivo com segurança. Armazene-o em um local seguro com acesso restrito e use-o para conexões SSH, especificando o arquivo de chave ao se conectar (por exemplo, usando o comando `-i` com `ssh`).

  5. **Configurações de Rede:**
     - Escolha a PVC
     - Atribua o grupo de segurança criado anteriormente.
     - Escolha subnets privadas diferentes para cada instância

  7. **Script de Dados do Usuário:**
     - Adicione o script de inicializaçõa na seção **Dados do Usuário** em **Detalhes avançados**:

---

### 6. Caso precise acessar a Instância, crie um IP elástico e associe à Instância
- Para a instância ter um ip público. Você pode desassociar o IP elástico a qualquer momento.

### 7. Crie um Target Group
- Tipo de destino: Instâncias
- Especifique um nome
- Escolha a PVC
- Deixe as outras opções em default e avance para a etapa 2: Registrar Destinos
- Selecione as duas Instâncias e clique em Incluir como pendente abaixo

### 8. Crie o Load Balancer
- Selecione Application Load Balancer
- Escolha a PVC
- Selecione as duas zonas de disponibilidade públicas
- Selecione o grupo de segurança
- Em Listeners e roteamento, deixe na porta 80 e selecione o Target Group criado anteriormente
- As outras opções, deixe em default

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


