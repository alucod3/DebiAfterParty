#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script precisa ser executado como root. Por favor, execute-o com sudo."
    exit 1
fi

# Função para detectar a placa de vídeo
detect_graphics_card() {
    echo "Detectando placa de vídeo..."
    if lspci | grep -i 'nvidia\|amd' > /dev/null; then
        if lspci | grep -i 'nvidia' > /dev/null; then
            echo "Placa NVIDIA detectada."
            install_nvidia_drivers
        elif lspci | grep -i 'amd' > /dev/null; then
            echo "Placa AMD detectada."
            install_amd_drivers
        else
            echo "Placa de vídeo detectada, mas não é NVIDIA nem AMD."
        fi
    else
        echo "Nenhuma placa de vídeo NVIDIA ou AMD detectada."
    fi
}

# Função para instalar drivers NVIDIA
install_nvidia_drivers() {
    echo "Instalando drivers NVIDIA..."

        # Pré-requisitos e atualização do sistema
    echo "Instalando pré-requisitos e atualizando o sistema..."
    apt update
    apt upgrade -y
    
    # Remoção de instalações anteriores (se necessário)
    echo "Removendo instalações anteriores do NVIDIA..."
    apt purge nvidia* -y
    
    # Instalação de pacotes necessários
    echo "Instalando pacotes necessários..."
    apt install -y nvidia-driver firmware-misc-nonfree nvidia-cuda-dev nvidia-cuda-toolkit
    
    echo 'GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX nvidia-drm.modeset=1"' > /etc/default/grub.d/nvidia-modeset.cfg
    
    update-grub
}

# Função para instalar drivers AMD
install_amd_drivers() {
    echo "Instalando drivers AMD..."
    # Adicionar os comandos para instalação dos drivers AMD
}

# Variáveis de configuração
LV_BRANCH='release-1.4/neovim-0.9'
DROID_FONT_URL='https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/DroidSansMono/DroidSansMNerdFont-Regular.otf'
JETBRAINS_FONT_URL='https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/JetBrainsMono/JetBrains%20Mono%20Nerd%20Font%20Complete.otf'
GO_DOWNLOAD_URL='https://go.dev/dl/go1.22.4.linux-amd64.tar.gz'

# Início da mensagem de carregamento
echo "Iniciando instalação..."

# Atualiza a lista de pacotes e atualiza o sistema
apt update && apt upgrade -y

# Verifica e instala os drivers de vídeo conforme necessário
detect_graphics_card

# Instala ferramentas básicas
apt install -y \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg-agent \
    build-essential

# Baixa e instala a versão mais recente do Go
curl -LO "$GO_DOWNLOAD_URL"
tar -C /usr/local -xzf go*.linux-amd64.tar.gz
rm go*.linux-amd64.tar.gz

# Configuração das variáveis de ambiente para Go
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
source ~/.profile

# Instalações via flatpak
flatpak install flathub com.bitwarden.desktop

# Instalação do i3 e dependências
apt install -y i3 i3status i3lock xbacklight feh

# Instalação do Neovim e LunarVim
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

# Limpeza e finalização
apt autoremove -y
apt clean

# Instalação do Zsh e Oh My Zsh
apt install -y zsh curl git
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Define o Zsh como o shell padrão para o usuário atual
# chsh -s $(which zsh)

# Fim da instalação
echo "Instalação concluída. Por favor, faça logout e login novamente para aplicar as alterações do Zsh e Neovim."

