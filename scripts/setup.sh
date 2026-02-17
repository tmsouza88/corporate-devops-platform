# Criar script de setup
cat > 00-setup/install-tools.sh << 'EOF'
#!/bin/bash

set -e

echo "🚀 Installing DevOps Tools..."

# Detectar OS
OS=$(uname -s)

# Docker
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    if [ "$OS" = "Linux" ]; then
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker $USER
    elif [ "$OS" = "Darwin" ]; then
        echo "Please install Docker Desktop from https://www.docker.com/products/docker-desktop"
        exit 1
    fi
else
    echo "✅ Docker already installed"
fi

# kubectl
if ! command -v kubectl &> /dev/null; then
    echo "📦 Installing kubectl..."
    if [ "$OS" = "Linux" ]; then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
    elif [ "$OS" = "Darwin" ]; then
        brew install kubectl
    fi
else
    echo "✅ kubectl already installed"
fi

# kind
if ! command -v kind &> /dev/null; then
    echo "📦 Installing kind..."
    if [ "$OS" = "Linux" ]; then
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
        chmod +x ./kind
        sudo mv ./kind /usr/local/bin/kind
    elif [ "$OS" = "Darwin" ]; then
        brew install kind
    fi
else
    echo "✅ kind already installed"
fi

# Flux CLI
if ! command -v flux &> /dev/null; then
    echo "📦 Installing Flux CLI..."
    curl -s https://fluxcd.io/install.sh | sudo bash
else
    echo "✅ Flux CLI already installed"
fi

# Terraform
if ! command -v terraform &> /dev/null; then
    echo "📦 Installing Terraform..."
    if [ "$OS" = "Linux" ]; then
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install terraform
    elif [ "$OS" = "Darwin" ]; then
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
    fi
else
    echo "✅ Terraform already installed"
fi

# Ansible
if ! command -v ansible &> /dev/null; then
    echo "📦 Installing Ansible..."
    if [ "$OS" = "Linux" ]; then
        sudo apt update
        sudo apt install -y software-properties-common
        sudo add-apt-repository --yes --update ppa:ansible/ansible
        sudo apt install -y ansible
    elif [ "$OS" = "Darwin" ]; then
        brew install ansible
    fi
else
    echo "✅ Ansible already installed"
fi

# Helm
if ! command -v helm &> /dev/null; then
    echo "📦 Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
    echo "✅ Helm already installed"
fi

# k9s (opcional mas útil)
if ! command -v k9s &> /dev/null; then
    echo "📦 Installing k9s..."
    if [ "$OS" = "Linux" ]; then
        curl -sS https://webinstall.dev/k9s | bash
    elif [ "$OS" = "Darwin" ]; then
        brew install k9s
    fi
else
    echo "✅ k9s already installed"
fi

echo ""
echo "✅ All tools installed successfully!"
echo ""
echo "📋 Installed versions:"
echo "  - Docker: $(docker --version)"
echo "  - kubectl: $(kubectl version --client --short 2>/dev/null || echo 'N/A')"
echo "  - kind: $(kind --version)"
echo "  - Flux: $(flux --version)"
echo "  - Terraform: $(terraform --version | head -n1)"
echo "  - Ansible: $(ansible --version | head -n1)"
echo "  - Helm: $(helm version --short)"
echo "  - k9s: $(k9s version --short 2>/dev/null || echo 'N/A')"
echo ""
echo "🎉 You're ready to start!"
EOF

chmod +x 00-setup/install-tools.sh

# Executar instalação
./00-setup/install-tools.sh