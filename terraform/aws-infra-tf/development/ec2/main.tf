resource "aws_security_group" "vpn_sg" {
  name        = "vpn_sg"
  description = "Security group for the VPN instance"
  vpc_id      =  data.terraform_remote_state.vpc.outputs.vpc_id
  // Ingress rule for ssh and http access (0.0.0.0/0 allows all inbound traffic)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 14143
    to_port     = 14143
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // Egress rule for internet access (0.0.0.0/0 allows all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vpn" {
  ami           = "ami-06e89bbb5f88b3a34"
  instance_type = "t3.medium"
  subnet_id     = data.terraform_remote_state.vpc.outputs.public_subnets[0]

  vpc_security_group_ids = [aws_security_group.vpn_sg.id]

  user_data = <<-EOF
#!/bin/bash
sudo tee /etc/apt/sources.list.d/pritunl.list << EOL
deb http://repo.pritunl.com/stable/apt jammy main
EOL

# Import signing key from keyserver
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
# Alternative import from download if keyserver offline
curl https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc | sudo apt-key add -

sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list << EOL
deb https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse
EOL

wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -

sudo apt update
sudo apt --assume-yes upgrade

# WireGuard server support
sudo apt -y install wireguard wireguard-tools

sudo ufw disable

sudo apt -y install pritunl mongodb-org
sudo systemctl enable mongod pritunl
sudo systemctl start mongod pritunl
EOF

  tags = {
    Terraform = true
    Name      = "dev-vpn-main"
  }
}
