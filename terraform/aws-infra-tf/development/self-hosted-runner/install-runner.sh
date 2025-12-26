#!/bin/bash
set -e

# Install dependencies
sudo apt-get update -y
sudo apt-get install -y awscli curl jq tar unzip git sudo software-properties-common

# Install Node.js (required by GitHub Actions actions)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Create a runner user if not exists
if ! id "runner" &>/dev/null; then
  sudo useradd -m -s /bin/bash runner
  echo "runner ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/runner
fi

# Set permissions
sudo chown -R runner:runner /home/runner

# Switch to runner user to install GitHub Actions runner
sudo -i -u runner bash <<'EOF'
cd ~

# Download a compatible GitHub Actions runner version (avoids GLIBC issues)
curl -L -o actions-runner.tar.gz https://github.com/actions/runner/releases/download/v2.308.0/actions-runner-linux-x64-2.308.0.tar.gz
tar xzf actions-runner.tar.gz

# Install runtime dependencies if needed
./bin/installdependencies.sh

# Configure the runner (replace these with actual values)
./config.sh \
  --url https://github.com/aws-infra-tf \
  --token 1234567890qwety \
  --name self-hosted-eks-runner \
  --labels eks-private \
  --unattended \
  --replace

# Start the runner in the background
./run.sh &
EOF
