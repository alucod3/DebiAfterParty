#!/bin/bash

# Funções de cores
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Este script precisa ser executado como root. Por favor, execute-o com sudo.${NC}"
    exit 1
fi

# Função para ativar os repositórios non-free no Debian
enable_nonfree_repos() {
    echo "${GREEN}Ativando repositórios non-free...${NC}"

    # Adiciona os repositórios non-free ao arquivo sources.list
    echo "" >> /etc/apt/sources.list
    echo "# Repositórios non-free" >> /etc/apt/sources.list
    echo "deb http://deb.debian.org/debian/ $(lsb_release -cs) main non-free contrib" >> /etc/apt/sources.list
    echo "deb-src http://deb.debian.org/debian/ $(lsb_release -cs) main non-free contrib" >> /etc/apt/sources.list

    echo "${GREEN}Repositórios ativados com sucesso!${NC}"
}

# Função para imprimir ASCII art colorido
print_ascii_art() {
    echo -e "${CYAN}"
    cat << "EOF"
┳┓  ┓ •┏┓┏     ┏┓       
┃┃┏┓┣┓┓┣┫╋╋┏┓┏┓┃┃┏┓┏┓╋┓┏
┻┛┗ ┗┛┗┛┗┛┗┗ ┛ ┣┛┗┻┛ ┗┗┫
                       ┛
                       by alucod3
EOF
    echo -e "${NC}"
}

# Imprime ASCII art
print_ascii_art

# Função para detectar a placa de vídeo
detect_graphics_card() {
    echo -e "${GREEN}Detectando placa de vídeo...${NC}"
    if lspci | grep -i 'nvidia\|amd' > /dev/null; then
        if lspci | grep -i 'nvidia' > /dev/null; then
            echo -e "${GREEN}Placa NVIDIA detectada.${NC}"
            install_nvidia_drivers
        elif lspci | grep -i 'amd' > /dev/null; then
            echo -e "${GREEN}Placa AMD detectada.${NC}"
            install_amd_drivers
        else
            echo -e "${YELLOW}Placa de vídeo detectada, mas não é NVIDIA nem AMD.${NC}"
        fi
    else
        echo -e "${YELLOW}Nenhuma placa de vídeo NVIDIA ou AMD detectada.${NC}"
    fi
}

# Função para instalar drivers NVIDIA
install_nvidia_drivers() {
    echo -e "${GREEN}Instalando drivers NVIDIA...${NC}"

    # Pré-requisitos e atualização do sistema
    echo -e "${GREEN}Instalando pré-requisitos e atualizando o sistema...${NC}"
    apt update && apt upgrade -y || { echo -e "${RED}Erro ao atualizar pacotes. Abortando.${NC}" >&2; exit 1; }

    # Remoção de instalações anteriores (se necessário)
    echo -e "${GREEN}Removendo instalações anteriores do NVIDIA...${NC}"
    apt purge nvidia* -y

    # Instalação de pacotes necessários
    echo -e "${GREEN}Instalando pacotes necessários...${NC}"
    apt install -y nvidia-driver firmware-misc-nonfree nvidia-cuda-dev nvidia-cuda-toolkit

    echo 'GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX nvidia-drm.modeset=1"' > /etc/default/grub.d/nvidia-modeset.cfg

    update-grub
}

# Função para instalar drivers AMD (PRECISA AJUSTAR)
install_amd_drivers() {
    echo -e "${GREEN}Instalando drivers AMD...${NC}"

    # Atualiza a lista de pacotes e atualiza o sistema
    apt update && apt upgrade -y || { echo -e "${RED}Erro ao atualizar pacotes. Abortando.${NC}" >&2; exit 1; }

    # Remoção de instalações anteriores (se necessário)
    echo -e "${GREEN}Removendo instalações anteriores do AMD...${NC}"
    apt purge amd* -y

    # Instalação de pacotes necessários
    echo -e "${GREEN}Instalando pacotes necessários...${NC}"
    apt install -y firmware-amd-graphics amdgpu-pro mesa-utils mesa-vdpau-drivers

    echo 'GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX amdgpu.runpm=0"' > /etc/default/grub.d/amdgpu-options.cfg

    update-grub
}

# Chamada da função para detectar placa de vídeo
detect_graphics_card

# Função para escolher se deseja instalar via Flatpak
choose_flatpak_installation() {
    while true; do
        read -p "Deseja instalar aplicativos via Flatpak? (S/N): " choice
        case "$choice" in
            [Ss]* )
                apt install flatpak -y
                flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                break
                ;;
            [Nn]* )
                echo "Você optou por não instalar via Flatpak."
                break
                ;;
            * )
                echo "Por favor, responda com S (Sim) ou N (Não)."
                ;;
        esac
    done
}

###
# REPOSITORIOS
###

# Variáveis de configuração
LV_BRANCH='release-1.4/neovim-0.9'
DROID_FONT_URL='https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/DroidSansMono/DroidSansMNerdFont-Regular.otf'
JETBRAINS_FONT_URL='https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/JetBrainsMono/JetBrains%20Mono%20Nerd%20Font%20Complete.otf'

# Início da mensagem de carregamento
echo -e "${GREEN}Iniciando instalação...${NC}"

# Atualiza a lista de pacotes e atualiza o sistema
apt update && apt upgrade -y || { echo -e "${RED}Erro ao atualizar pacotes. Abortando.${NC}" >&2; exit 1; }

# Instalação de ferramentas básicas com feedback colorido
echo -e "${GREEN}=====================${NC}"
echo -e "${GREEN}|       Basics      |${NC}"
echo -e "${GREEN}=====================${NC}"

apt install -y \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg-agent

# Instalação de Go Lang e C/C++ com feedback colorido
echo -e "${GREEN}======================${NC}"
echo -e "${GREEN}|   Go Lang + C/C++  |${NC}"
echo -e "${GREEN}======================${NC}"

apt install -y \
    build-essential \
    golang \

# Configuração das variáveis de ambiente para Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Instalação do i3 e dependências com feedback colorido
echo -e "${GREEN}======================${NC}"
echo -e "${GREEN}|  i3 + Dependencies |${NC}"
echo -e "${GREEN}======================${NC}"

apt install -y i3 i3status i3lock xbacklight feh

# Instalação do Neovim, LunarVim e Fonts com feedback colorido
echo -e "${GREEN}===============================${NC}"
echo -e "${GREEN}|  NeoVim + LunarVim + Fonts  |${NC}"
echo -e "${GREEN}===============================${NC}"

# Instalação do Neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod 755 nvim.appimage
chown root:root nvim.appimage
mv nvim.appimage /usr/local/bin/nvim

# Instalação do LunarVim
bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/$LV_BRANCH/utils/installer/install.sh)

# Instalação das fontes Nerd Fonts
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && {
    curl -fLO "$DROID_FONT_URL"
    curl -fLO "$JETBRAINS_FONT_URL"
}

# Atualiza o cache de fontes
fc-cache -f -v

# Instalação do Zsh e Oh My Zsh
echo -e "${GREEN}=======================${NC}"
echo -e "${GREEN}|   Zsh + Oh My Zsh   |${NC}"
echo -e "${GREEN}=======================${NC}"

apt install -y zsh curl git
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Limpeza e finalização
apt update && apt upgrade && apt autoremove -y
apt clean

# Define o Zsh como o shell padrão para o usuário atual
chsh -s $(which zsh)

# Fim da instalação
echo -e "${GREEN}Instalação concluída. Por favor, faça logout e login novamente para aplicar as alterações do Zsh e Neovim.${NC}"

# Reinicialização opcional com feedback colorido
while true; do
    read -p "${GREEN}Recomendamos que reinicie para aplicar efeito na placa de vídeo. Deseja reiniciar? (S/N): ${NC}" choice
    case "$choice" in
        [Ss]* )
            reboot
            break
            ;;
        [Nn]* )
            echo -e "${YELLOW}Você optou por não reiniciar.${NC}"
            break
            ;;
        * )
            echo -e "${YELLOW}Por favor, responda com S (Sim) ou N (Não).${NC}"
            ;;
    esac
done