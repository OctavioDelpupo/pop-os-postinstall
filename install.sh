#!/bin/bash
#
# pos-os-postinstall.sh - Instalar e configura programas no Pop!_OS (20.04 LTS ou superior)
#
# Autor:         Octavio Delpupo
#
# ------------------------------------------------------------------------ #
#
# COMO USAR?
#   $ ./install.sh
#
# ----------------------------- VARIÁVEIS ----------------------------- #
set -e

##URLS
URL_VSCODE="https://code.visualstudio.com/thank-you?dv=linux64_deb"

##DIRETÓRIOS E ARQUIVOS
DIRETORIO_DOWNLOADS="$HOME/Downloads/programas"

#CORES

VERMELHO='\e[1;91m'
VERDE='\e[1;92m'
SEM_COR='\e[0m'

#FUNÇÕES

# Atualizando repositório e fazendo atualização do sistema

apt_update(){
  sudo apt update && sudo apt dist-upgrade -y
}

apt_update


## finalização

  echo -e "${VERDE}[INFO] - Script finalizado, instalação concluída! :)${SEM_COR}"
