💼 Corporate DevOps Platform
Plataforma completa de DevOps corporativo para aprendizado prático de Infraestrutura como Código (IaC), Configuração Automatizada, GitOps e CI/CD moderno, utilizando ferramentas open source e práticas recomendadas de SRE.

📂 Estrutura do Projeto

corporate-devops-platform/
├── 00-setup/           # Scripts para instalação e verificação de ferramentas
├── 01-infrastructure/  # Código Terraform para provisionamento do cluster Kind
├── 02-configuration/   # Playbooks Ansible para configuração do cluster (Ingress, Cert-Manager, Monitoramento)
├── 03-kubernetes/      # (Reservado para recursos Kubernetes adicionais)
├── 04-gitops/          # Manifests e configurações do FluxCD para GitOps
├── 05-applications/    # Aplicações gerenciadas via GitOps (ex: hello-app)
├── 06-observability/   # Configurações e dashboards para monitoramento
├── 07-cicd/            # Pipelines GitHub Actions para build, push e deploy automatizado
├── clusters/           # Configurações específicas do cluster para FluxCD
├── docs/               # Documentação complementar
└── scripts/            # Scripts auxiliares para deploy e validação

🧰 Tecnologias e Ferramentas Utilizadas
🧱 Terraform: Provisionamento do cluster Kubernetes local (Kind)
🤖 Ansible: Configuração automatizada do cluster e componentes essenciais
🔁 FluxCD: GitOps para sincronização contínua do estado do cluster com o repositório Git
⚙️ GitHub Actions: Pipeline CI/CD para build e push de imagens Docker e atualização automática do GitOps
🐳 Docker Hub: Registro de imagens Docker
☸️ Kubernetes (Kind): Orquestração de containers local via Kind
📊 Prometheus & Grafana: Monitoramento e visualização (configurado via Ansible)
🌐 Ingress NGINX & Cert-Manager: Gerenciamento de tráfego e certificados TLS
🔄 Fluxo de Trabalho
🏗 Provisionamento: Terraform cria o cluster Kind local.
🔧 Configuração: Ansible instala e configura ingress, monitoramento e outros componentes.
🚦 GitOps: FluxCD monitora o repositório Git e aplica automaticamente as configurações e aplicações no cluster.
🚀 CI/CD: GitHub Actions builda a imagem Docker do app, faz push para o Docker Hub e atualiza o manifesto Kubernetes no Git, disparando o FluxCD para atualizar o cluster.

🚀 Como Usar:
✅ Pré-requisitos
🐳 Docker instalado e rodando
🪟 WSL2 (para ambiente Linux no Windows)
🔐 Conta no Docker Hub e GitHub com tokens configurados nos secrets do repositório
📦 Git instalado

🧭 Passos principais

# Clone o repositório
git clone https://github.com/seu-usuario/corporate-devops-platform.git
cd corporate-devops-platform

# Execute os scripts de setup para instalar ferramentas
./00-setup/install-tools.sh
./00-setup/verify-tools.sh

# Provisionar o cluster com Terraform
cd 01-infrastructure/kind-cluster
terraform init
terraform apply

# Configurar o cluster com Ansible
cd ../../02-configuration/ansible
ansible-playbook playbook.yml -i inventory.ini

# Verificar status do FluxCD
flux get all -n flux-system

# Deploy da aplicação via GitHub Actions
# (pipeline automático ao dar push nas pastas 05-applications)

📈 Próximos Passos
📌 Módulo 8: Estratégias avançadas de deployment (Canary, Blue-Green) com Flagger
🛡 Módulo 9: Segurança e políticas com Kyverno/OPA
♻️ Módulo 10: Disaster Recovery e resiliência via GitOps

📬 Contato:
💡 Para dúvidas, sugestões ou contribuições:
Abra uma issue
Envie um pull request
Este projeto é parte de um laboratório prático de DevOps e SRE, focado em automação, confiabilidade e práticas modernas de entrega contínua.
