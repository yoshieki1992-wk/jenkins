#!/bin/sh
yum update -y

#Instalacion Docker
curl -sSL https://get.docker.com/ | sh
systemctl enable containerd 
systemctl start containerd
systemctl enable docker
systemctl start docker

#Post-Configuration
groupadd docker
usermod -aG docker $(whoami)

#Creacion de docker bridge
docker network create jenkins

#Generamos Dockerfile 
cat <<EOF > Dockerfile
FROM jenkins/jenkins:2.289.2-lts-centos7
USER root
RUN yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
RUN  yum update && yum install -y yum-utils docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean:1.24.7 docker-workflow:1.26"
EOF

#Generamos docker image
docker build -t myjenkins-blueocean:1.1 .

#Ejecutamos
docker run \
  --name jenkins-blueocean \
  --rm \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --env JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  --publish 8080:8080 \
  --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean:1.1 
