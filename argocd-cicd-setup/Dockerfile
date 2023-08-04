FROM ubuntu:latest
LABEL name="Johnson Flourish"
LABEL email="johnson@clessence.com"
ENV UBUNTU_HOME=/var/www/html/
RUN apt update -y
ENV DEBIAN_FRONTEND noninteractive	
RUN apt -y install tzdata
RUN apt install apache2 -y
WORKDIR UBUNTU_HOME
COPY argocd-cicd-setup/script/index.html ${UBUNTU_HOME}
EXPOSE 80
CMD ["apachectl" , "-D","FOREGROUND"]