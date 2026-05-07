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
URL_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
URL_VSCODE="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
URL_DBEAVER="https://dbeaver.io/files/dbeaver-ce-latest-linux-x86_64.deb"

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


## Adicionando/Confirmando arquitetura de 32 bits ##
add_archi386(){
sudo dpkg --add-architecture i386
}
## Atualizando o repositório ##
just_apt_update(){
sudo apt update -y
}

system_clean(){
apt_update -y
sudo apt autoclean -y
sudo apt autoremove -y
}

##DEB SOFTWARES TO INSTALL

PROGRAMAS_PARA_INSTALAR=(
  vlc
  git
)


install_debs(){
  # 1. Validação Inicial
  if [[ -z "$DIRETORIO_DOWNLOADS" ]]; then
    echo -e "${VERMELHO}[ERRO] - Variável DIRETORIO_DOWNLOADS não definida.${SEM_COR}"
    return 1
  fi

  # 2. Gestão do Diretório (Simplificada)
  if [[ ! -d "$DIRETORIO_DOWNLOADS" ]]; then
    echo -e "${VERDE}[INFO] - Criando pasta: $DIRETORIO_DOWNLOADS${SEM_COR}"
    mkdir -p "$DIRETORIO_DOWNLOADS"
  fi

  # 3. Downloads (Com correção de nomes)
  echo -e "${VERDE}[INFO] - Iniciando download dos pacotes...${SEM_COR}"


  wget -c "$URL_CHROME" -P "$DIRETORIO_DOWNLOADS"
  wget -c "$URL_DBEAVER" -P "$DIRETORIO_DOWNLOADS"
  wget -c "$URL_VSCODE" -O "$DIRETORIO_DOWNLOADS/vscode.deb"

  # 4. Instalação dos Pacotes .deb
  echo -e "${VERDE}[INFO] - Instalando pacotes .deb baixados${SEM_COR}"

  # Usamos nullglob para o loop não dar erro se a pasta estiver vazia
  shopt -s nullglob
  arquivos_deb=("$DIRETORIO_DOWNLOADS"/*.deb)
  shopt -u nullglob

  if [ ${#arquivos_deb[@]} -gt 0 ]; then
    sudo dpkg -i "$DIRETORIO_DOWNLOADS"/*.deb
    sudo apt install -f -y  # Corrige dependências
  else
    echo -e "${AMARELO}[AVISO] - Nenhum arquivo .deb encontrado.${SEM_COR}"
  fi

  # 5. Instalação dos Pacotes APT (Otimizada)
  echo -e "${VERDE}[INFO] - Verificando pacotes do repositório${SEM_COR}"

  programas_faltantes=()

  for nome_do_programa in "${PROGRAMAS_PARA_INSTALAR[@]}"; do
    # O grep fixo (-x) garante que estamos procurando o nome exato do pacote
    if dpkg -s "$nome_do_programa" >/dev/null 2>&1; then
      echo -e "${VERDE}[INSTALADO] - $nome_do_programa${SEM_COR}"
    else
      programas_faltantes+=("$nome_do_programa")
    fi
  done

  if [ ${#programas_faltantes[@]} -gt 0 ]; then
    echo -e "${AMARELO}[INFO] - Instalando: ${programas_faltantes[*]}${SEM_COR}"
    sudo apt update && sudo apt install "${programas_faltantes[@]}" -y
  else
    echo -e "${VERDE}[INFO] - Todos os pacotes APT já estão presentes.${SEM_COR}"
  fi

  # Instalar programas no apt
echo -e "${VERDE}[INFO] - Instalando pacotes apt do repositório${SEM_COR}"

for nome_do_programa in ${PROGRAMAS_PARA_INSTALAR[@]}; do
  if ! dpkg -l | grep -q $nome_do_programa; then # Só instala se já não estiver instalado
    sudo apt install "$nome_do_programa" -y
  else
    echo "[INSTALADO] - $nome_do_programa"
  fi
done
}

install_flatpaks(){

  echo -e "${VERDE}[INFO] - Instalando pacotes flatpak${SEM_COR}"

flatpak install flathub org.gimp.GIMP -y
flatpak install flathub com.spotify.Client -y
flatpak install flathub org.telegram.desktop -y
flatpak install flathub org.flameshot.Flameshot -y
}

deletar_downloads(){
  # Verifica se a variável não está vazia e se ela realmente é um diretório
  if [[ -n "$DIRETORIO_DOWNLOADS" && -d "$DIRETORIO_DOWNLOADS" ]]; then
    echo -e "${VERMELHO}[INFO] - Removendo pasta e arquivos: $DIRETORIO_DOWNLOADS${SEM_COR}"
    rm -rf "$DIRETORIO_DOWNLOADS"
  else
    echo -e "${AMARELO}[AVISO] - A pasta '$DIRETORIO_DOWNLOADS' não existe ou já foi removida.${SEM_COR}"
  fi
}

apt_update
add_archi386
just_apt_update
install_debs
install_flatpaks
apt_update
deletar_downloads
system_clean


## finalização
  echo -e "${VERDE}[INFO] - Script finalizado, instalação concluída! :)${SEM_COR}"
