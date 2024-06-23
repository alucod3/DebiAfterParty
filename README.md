# DebiAfterParty

## Script de Instalação Automatizada para Linux
Este script Bash foi criado para automatizar o processo de instalação e configuração de software em sistemas Linux, otimizando o setup inicial após uma nova instalação do sistema operacional.

## Requisitos
Sistema operacional Linux (testado em distribuições baseadas em Debian/Ubuntu)
- Acesso de superusuário (root)

## Funcionalidades
- Detecta automaticamente se o sistema possui uma placa de vídeo NVIDIA ou AMD.
- Instala os drivers correspondentes e realiza as configurações necessárias para otimização de desempenho.
- Instalação de ferramentas básicas como curl, wget, git, unzip, entre outros.
- Configuração do ambiente de desenvolvimento com build-essential e pacotes relacionados.
### Configuração de Ambiente de Desenvolvimento:
- Instalação do Go (Golang) e configuração de variáveis de ambiente.
- Configuração do ambiente de desenvolvimento para Go.
### Instalação de Aplicações e Utilitários:
- Instalação via Flatpak do Bitwarden Desktop.
- Instalação do ambiente de janelas i3, i3status, i3lock, feh para gerenciamento de janelas.
- Instalação do Neovim e LunarVim para edição avançada de textos.

### Personalização do Ambiente:

- Instalação e configuração de fontes Nerd Fonts para personalização do terminal.
- Atualização do cache de fontes para aplicação imediata das mudanças.

## Configuração do Shell:

- Instalação do Zsh e Oh My Zsh para uma experiência de terminal mais personalizável.

## Uso

### Execute o script como superusuário (root):

```
git clone https://github.com/alucod3/DebiAfterParty
cd DebiAfterParty
bash install.sh
```

Após a conclusão, faça logout e login novamente para aplicar as configurações do Zsh e Neovim.

## Notas
Certifique-se de estar conectado à internet durante a execução do script para baixar e instalar pacotes necessários.
O script pode ser personalizado conforme necessário, adicionando ou removendo pacotes e configurações de acordo com suas preferências ou requisitos específicos.
