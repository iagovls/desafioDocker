# Configuração do WordPress na AWS VPC com Docker

## Objetivo do Projeto
Este projeto é uma atividade prática solicitada pela equipe de estágio da Compass.UOL. O objetivo é configurar um site WordPress dentro de uma Virtual Private Cloud (VPC) na AWS, utilizando duas instâncias EC2 com Docker e um banco de dados externo.

---

## Etapas para Implantar o Projeto

### 1. Criar um Grupo de Segurança na AWS
- **Portas Necessárias:**
  - TCP 80 (HTTP)
  - TCP 443 (HTTPS)
  - TCP 22 (SSH)
  - TCP 2049 (NFS)

---

### 2. Criar e Configurar um EFS
1. **Escolha a opção de EFS personalizado.**
2. **Etapa 1:**
   - Opcionalmente, nomeie o EFS.
   - Mantenha todas as outras opções nos valores padrão.
3. **Etapa 2:**
   - Atribua o grupo de segurança criado anteriormente a cada zona de disponibilidade.
4. **Etapa 3:**
   - Não modifique a política do sistema de arquivos.
5. **Finalize a configuração.**

---

### 3. Criar e Configurar o Banco de Dados
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

---

### 4. Iniciar uma Instância EC2
- **Detalhes da Configuração da Instância:**

  1. **Tags:**
     - `Name: PB - Nov 2024`
     - `CostCenter: C092000024`
     - `Project: PB - Nov 2024`

  2. **AMI (Amazon Machine Image):**
     - Selecione o Amazon Linux.

  3. **Tipo de Instância:**
     - `t2.micro`.

  4. **Par de Chaves:**
     - Crie um novo par de chaves `.pem` e salve o arquivo com segurança. Armazene-o em um local seguro com acesso restrito e use-o para conexões SSH, especificando o arquivo de chave ao se conectar (por exemplo, usando o comando `-i` com `ssh`).

  5. **Configurações de Rede:**
     - Atribua o grupo de segurança criado anteriormente.

  6. **Script de Dados do Usuário:**
     - Adicione o seguinte script na seção **Detalhes Avançados**:

```bash
#!/bin/bash

# Atualizar o sistema
sudo yum update -y

# Instalar o Docker
sudo yum install docker -y

# Preparar o caminho para o download do Docker Compose
sudo mkdir -p /usr/local/lib/docker/cli-plugins

# Baixar o Docker Compose
curl -L https://github.com/docker/compose/releases/download/v2.30.3/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose

# Modificar permissões do diretório
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Criar o diretório EFS
sudo mkdir -p /efs

# Montar o AWS EFS usando o link fornecido
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0fdad736ffd266e41.efs.us-east-1.amazonaws.com:/ efs

# Dica: Certifique-se de que as instâncias podem acessar o EFS corretamente. Verifique a conectividade caso a montagem falhe.
```

---

### 5. Iniciar a Segunda Instância EC2
- Repita os passos da **Etapa 4** para iniciar uma segunda instância EC2 com configurações idênticas.

---

## Notas
- Certifique-se de que ambas as instâncias EC2 estejam configuradas corretamente para se comunicar com o banco de dados e compartilhar o armazenamento EFS.
- Use o Docker Compose para configurar os containers do WordPress, apontando para o endpoint do banco de dados e para o EFS como armazenamento persistente.

---

## Tags do Projeto
- AWS
- WordPress
- Docker
- VPC
- Banco de Dados MySQL


