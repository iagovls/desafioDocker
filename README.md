# Configuração do WordPress na AWS VPC com Docker

## Objetivo do Projeto
Este projeto é uma atividade prática solicitada pela equipe de estágio da Compass.UOL. O objetivo é configurar um site WordPress dentro de uma Virtual Private Cloud (VPC) na AWS, utilizando duas instâncias EC2 com Docker e um banco de dados externo.

---

## Etapas para Implantar o Projeto

### 1. Criar um VPC e as sub-redes

### 2. Criar um Grupo de Segurança na AWS
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
   - Atribua o grupo de segurança criado anteriormente a cada zona de disponibilidade.
4. **Etapa 3:**
   - Não modifique a política do sistema de arquivos.
5. **Finalize a configuração.**

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
     - Crie um novo par de chaves `.pem` e salve o arquivo com segurança. Armazene-o em um local seguro com acesso restrito e use-o para conexões SSH, especificando o arquivo de chave ao se conectar (por exemplo, usando o comando `-i` com `ssh`).

  5. **Configurações de Rede:**
     - Escolha a PVC
     - Atribua o grupo de segurança criado anteriormente.
     - Escolha subnets diferentes para cada instância

  7. **Script de Dados do Usuário:**
     - Adicione o script de inicializaçõa na seção **Dados do Usuário** em **Detalhes avançados**:

---

### 6. Crie um IP elástico e associe a uma Instância
- Para a instância ter um ip público temporariamente caso precise fazer algum ajuste

### 7. Crie um Target Group
- Tipo de destino: Instâncias
- Especifique um nome
- Escolha a PVC
- Deixe as outras opções em default e avance para a etapa 2: Registrar Destinos
- Selecione as duas Instâncias e clique em Incluir como pendente abaixo

### 8. Crie o Load Balancer
- Selecione Application Load Balancer
- Escolha a PVC
- Selecione as duas zonas de disponibilidade
- Selecione o grupo de segurança
- Em Listeners e roteamento, deixe na porta 80 e selecione o Target Group criado anteriormente
- As outras opções, deixe em default

---

## Tags do Projeto
- AWS
- WordPress
- Docker
- VPC
- Banco de Dados MySQL


