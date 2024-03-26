data "aws_ami" "amazon-linux-2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_network_interface" "interface" {
  subnet_id       = "subnet-0eb6f821151103f98"
  security_groups = [aws_security_group.sg.id]
}

resource "aws_instance" "ec2" {
  depends_on    = [aws_network_interface.interface]
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = local.instance_type
  user_data     = <<EOF
        #!/bin/bash

       ####### INSTALL JENKINS #######
       sudo yum update –y
       sudo wget -O /etc/yum.repos.d/jenkins.repo \
       https://pkg.jenkins.io/redhat-stable/jenkins.repo
       sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
       sudo yum upgrade
       amazon-linux-extras install java-openjdk11 -y
       yum install jenkins git jq docker -y
       sudo yum install jenkins -y
       sudo systemctl enable jenkins
       sudo systemctl start jenkins


       ############ DOCKER ############
       yum install -y docker
       systemctl start docker
       usermod -aG docker jenkins
       systemctl start jenkins


       ############# Kubectl #############
       curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
       sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
       chmod +x kubectl
       mkdir -p ~/.local/bin
       mv ./kubectl ~/.local/bin/kubectl

       ############# Helm #############
       curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
       chmod 700 get_helm.sh
       ./get_helm.sh
       

       #####KIND######
       [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
       chmod +x ./kind
       sudo mv ./kind /usr/local/bin/kind
       aws s3 cp s3://tedo-dev-ops-project/kind.yaml /var/lib/jenkis
       kind create cluster --config=/var/lib/jenkins/kind.yaml
       mkdir -p /var/lib/jenkis/ 
       kubectl get kubeconfig --name=kind ? /var/lib/jenkins/.kube/config
       chown -R jenkins: /var/lib/jenkins/.kube/
       EOF

  iam_instance_profile = aws_iam_instance_profile.profile.name
  network_interface {
    network_interface_id = aws_network_interface.interface.id
    device_index         = 0
  }
  tags = {
    Name = "Jenkins"
  }
}





# This is now in S3 storage because it didn't work any other way

#echo -n'
#    apiVersion: kind.x-k8s.io/v1aplha4
#   kind: Cluster
#  nodes:
# - role: control-plane
#  extraPortMappings:
# - containerPort: 30000
#  hostPort: 30000
# listendAddress: "0.0.0.0" # Optional, defaults to "0.0.0.0
#protocol: tcp # Optional, defaults to tcp' > kind.yaml 
           