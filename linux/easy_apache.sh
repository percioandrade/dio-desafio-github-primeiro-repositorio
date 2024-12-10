#!/bin/bash
# Autor: Percio Andrade
# Objetivo: Entrega de segundo projeto para o fundamento de Linux da DIO
# Modularização com funções
# E algumas praticas de shell script :)

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"

echo -e "

     e                                  888                
    d8b     888-~88e    /~~~8e   e88~~\ 888-~88e  e88~~8e  
   /Y88b    888  888b       88b d888    888  888 d888  88b 
  /  Y88b   888  8888  e88~-888 8888    888  888 8888__888 
 /____Y88b  888  888P C888  888 Y888    888  888 Y888    , 
/      Y88b 888-_88'   '88_-888  '88__/ 888  888  '88___/  
            888                                            

Desafio do projeto fundamentos em Linux:
https://web.dio.me/lab/infraestrutura-como-codigo-script-de-provisionamento-de-um-servidor-web-apache/learning/"

echo -e "\nEste script executará em ${GREEN}5 segundos${ENDCOLOR}, caso queira cancelar aperte control+c\n"
sleep 5

echo -e "${YELLOW}[-]:${ENDCOLOR} Verificando o sistema operacional"
echo -e "${YELLOW}[-]:${ENDCOLOR} Atualizando o sistema"
if [ -e "/usr/bin/yum" ]; then
   rhel=true
   echo -e "${YELLOW}[-]:${ENDCOLOR} Sistema RHEL Detectado"
else
   debian=true
   echo -e "${YELLOW}[-]:${ENDCOLOR} Sistema Debian detectado"
fi

function sysUpdate() { 
   echo -e "[!]:${ENDCOLOR} Atualizando o sistema"
   if [[ ${rhel} == true ]]; then
      yum update && yum upgrade
   else
      apt update && apt upgrade -y
   fi
}

function appInstall() {
   echo -e "${YELLOW}[-]:${ENDCOLOR} Iniciando a instalação dos Aplicativos"
   if [[ ${rhel} == true ]]; then
      yum install httpd -y 2>/dev/null || echo -e "${GREEN}[+]:${ENDCOLOR} apache Instalado."
      yum install unzip -y 2>/dev/null || echo -e "${GREEN}[+]:${ENDCOLOR} unzip Instalado."
      yum install wget -y 2>/dev/null || echo -e "${GREEN}[+]:${ENDCOLOR} wget Instalado."
   else
      apt install apache2 -y || echo -e "${GREEN}[+]:${ENDCOLOR} apache Instalado."
      apt install unzip -y || echo -e "${GREEN}[+]:${ENDCOLOR} unzip Instalado."
      apt install wget -y || echo -e "${GREEN}[+]:${ENDCOLOR} wget Instalado."
   fi
}

function copyFiles() {
   echo -e "[!]: Iniciando o download de arquivos."
   cd /tmp
   wget -O main.zip https://github.com/denilsonbonatti/linux-site-dio/archive/refs/heads/main.zip
   if [[ -e `pwd`/main.zip ]]; then
      echo -e "${GREEN}[+]:${ENDCOLOR} Download do arquivo feito com sucesso."
   else
      echo -e "[${RED}[!]:${ENDCOLOR} Houve uma falha ao baixar os arquivos, por favor tente novamente."
      exit 1;
   fi
   echo -e "${YELLOW}[-]:${ENDCOLOR} Extraindo arquivos."
   unzip main.zip
   echo -e "${GREEN}[-]:${ENDCOLOR} Arquivos extraidos."
   cd linux-site-dio-main
   echo -e "${YELLOW}[-]:${ENDCOLOR} Movendo arquivos."
   cp -Rf . /var/www/html/
   echo -e "${GREEN}[+]:${ENDCOLOR} Arquivos movidos."
   echo -e "${YELLOW}[-]:${ENDCOLOR} Script finalizado. DIOS MIO."
}

sysUpdate
appInstall
copyFiles


