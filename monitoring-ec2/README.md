## K6 명령어
cd monitoring-ec2
k6 run \
  --out influxdb=http://localhost:8086/myk6db \
  script.js

## Grafana 대시보드 import 번호
K6 & influxDB : 2587
ECS : 551
DynamoDB : 17741
CloudWatch logs : 11266

## EC2 사용자 데이터
``` bash
#!/bin/bash
### Update the system
sudo apt update -y
sudo apt upgrade -y

### Install Docker dependencies
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

# Update again to include the Docker repository
sudo apt update -y

# Install Docker
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add the current user to the docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install k6
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt update -y
sudo apt install -y k6
```