#!/bin/bash

echo "🔍 Verifying tools installation..."
echo ""

tools=("docker" "kubectl" "kind" "flux" "terraform" "ansible" "helm")

all_ok=true

for tool in "${tools[@]}"; do
    if command -v $tool &> /dev/null; then
        echo "✅ $tool"
    else
        echo "❌ $tool - NOT FOUND"
        all_ok=false
    fi
done

echo ""

if [ "$all_ok" = true ]; then
    echo "🎉 All tools are installed!"
    exit 0
else
    echo "⚠️  Some tools are missing. Please run install-tools.sh"
    exit 1
fi
