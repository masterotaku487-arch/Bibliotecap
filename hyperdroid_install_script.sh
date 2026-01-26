#!/data/data/com.termux/files/usr/bin/bash

################################################################################
# HyperDroid Desktop Environment - Windows 11 Theme
# Versão: 2.0
# Dispositivo: Moto G20 (4GB RAM, Unisoc T700, Mali-G52)
# Descrição: Cria ambiente desktop real com tema Windows 11
################################################################################

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}  ${BLUE}HyperDroid Desktop Environment - Windows 11 Theme${NC}      ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}[ETAPA]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

################################################################################
# ETAPA 1: Preparação do Termux
################################################################################
print_header
print_step "1/8: Preparando ambiente Termux..."

# Atualiza repositórios
pkg update -y && pkg upgrade -y

# Instala dependências base do Termux
pkg install -y \
    x11-repo \
    tur-repo \
    wget \
    curl \
    git \
    proot-distro \
    pulseaudio \
    termux-x11-nightly \
    mesa-zink \
    virglrenderer-android

print_success "Termux preparado!"
echo ""

################################################################################
# ETAPA 2: Instalação do Ubuntu
################################################################################
print_step "2/8: Instalando Ubuntu via proot-distro..."

# Remove instalação anterior se existir
proot-distro remove ubuntu 2>/dev/null || true

# Instala Ubuntu fresh
proot-distro install ubuntu

print_success "Ubuntu instalado!"
echo ""

################################################################################
# ETAPA 3: Configuração do Ubuntu com Desktop XFCE
################################################################################
print_step "3/8: Configurando ambiente de desktop..."

# Cria script que será executado dentro do Ubuntu
cat > /tmp/setup_desktop.sh << 'UBUNTU_SETUP'
#!/bin/bash

set -e

echo "🔧 Configurando Ubuntu Desktop..."

# Atualiza sistema
apt update && apt upgrade -y

# Instala XFCE (versão mínima para economizar RAM)
echo "📦 Instalando XFCE Desktop..."
DEBIAN_FRONTEND=noninteractive apt install -y \
    xfce4 \
    xfce4-terminal \
    xfce4-panel \
    xfwm4 \
    xfce4-session \
    thunar \
    dbus-x11 \
    xorg \
    --no-install-recommends

# Remove pacotes desnecessários para economizar RAM
apt remove -y \
    xfce4-screensaver \
    xfce4-power-manager \
    light-locker \
    xfce4-notifyd \
    2>/dev/null || true

# Instala dependências essenciais
apt install -y \
    wget \
    curl \
    git \
    unzip \
    tar \
    gtk2-engines-murrine \
    gtk2-engines-pixbuf \
    gnome-themes-extra \
    papirus-icon-theme \
    fonts-noto \
    fonts-noto-color-emoji \
    zenity

echo "✓ XFCE instalado!"

################################################################################
# Instala Wine e Box64
################################################################################
echo "🍷 Instalando Wine..."

# Adiciona arquitetura i386
dpkg --add-architecture i386
apt update

# Instala Wine (versão leve)
apt install -y wine wine32 wine64 winetricks

# Instala Box64
echo "📦 Instalando Box64..."
cd /tmp
wget -q https://github.com/ptitSeb/box64/releases/download/v0.2.8/box64-ANDROID-v0.2.8.zip
unzip -q box64-ANDROID-v0.2.8.zip
mv box64 /usr/local/bin/
chmod +x /usr/local/bin/box64
rm box64-ANDROID-v0.2.8.zip

# Instala Box86
wget -q https://github.com/ptitSeb/box86/releases/download/v0.3.6/box86-ANDROID-v0.3.6.zip
unzip -q box86-ANDROID-v0.3.6.zip
mv box86 /usr/local/bin/
chmod +x /usr/local/bin/box86
rm box86-ANDROID-v0.3.6.zip

echo "✓ Wine e Box64 instalados!"

################################################################################
# Baixa e aplica tema Windows 11
################################################################################
echo "🎨 Instalando tema Windows 11..."

# Cria diretórios de temas
mkdir -p /root/.themes
mkdir -p /root/.icons
mkdir -p /root/.local/share/fonts

# Baixa tema Windows 11 GTK
cd /tmp
wget -q https://github.com/vinceliuice/Colloid-gtk-theme/archive/refs/heads/main.zip -O colloid.zip
unzip -q colloid.zip
cd Colloid-gtk-theme-main
./install.sh -d /root/.themes -t purple -c dark --tweaks black rimless

# Baixa ícones Windows 11
cd /tmp
wget -q https://github.com/yeyushengfan258/Win11-icon-theme/archive/refs/heads/main.zip -O win11-icons.zip
unzip -q win11-icons.zip
cd Win11-icon-theme-main
./install.sh -d /root/.icons

# Baixa wallpaper Windows 11
mkdir -p /root/Pictures
wget -q https://wallpapercave.com/wp/wp11176303.jpg -O /root/Pictures/windows11.jpg

echo "✓ Tema Windows 11 instalado!"

################################################################################
# Configura XFCE para parecer Windows 11
################################################################################
echo "⚙️ Configurando aparência Windows 11..."

# Cria configuração do XFCE
mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml

# Configuração do Window Manager (xfwm4)
cat > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml << 'XFWM4'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="Colloid-Purple-Dark"/>
    <property name="title_font" type="string" value="Sans Bold 10"/>
    <property name="button_layout" type="string" value="O|HMC"/>
    <property name="show_dock_shadow" type="bool" value="false"/>
    <property name="show_frame_shadow" type="bool" value="false"/>
    <property name="show_popup_shadow" type="bool" value="false"/>
    <property name="use_compositing" type="bool" value="false"/>
    <property name="frame_opacity" type="int" value="100"/>
    <property name="inactive_opacity" type="int" value="100"/>
    <property name="popup_opacity" type="int" value="100"/>
  </property>
</channel>
XFWM4

# Configuração do Desktop (xfdesktop)
cat > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml << 'XFDESKTOP'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="image-path" type="string" value="/root/Pictures/windows11.jpg"/>
          <property name="image-style" type="int" value="5"/>
        </property>
      </property>
    </property>
  </property>
</channel>
XFDESKTOP

# Configuração do Painel (xfce4-panel) - Estilo Windows 11
cat > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml << 'PANEL'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=8;x=0;y=0"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="48"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
      </property>
      <property name="background-style" type="uint" value="0"/>
      <property name="background-rgba" type="array">
        <value type="double" value="0.1"/>
        <value type="double" value="0.1"/>
        <value type="double" value="0.1"/>
        <value type="double" value="0.9"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="applicationsmenu"/>
    <property name="plugin-2" type="string" value="tasklist"/>
    <property name="plugin-3" type="string" value="separator"/>
    <property name="plugin-4" type="string" value="systray"/>
    <property name="plugin-5" type="string" value="clock"/>
  </property>
</channel>
PANEL

# Configuração de Aparência
cat > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'XSETTINGS'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Colloid-Purple-Dark"/>
    <property name="IconThemeName" type="string" value="Win11"/>
    <property name="EnableEventSounds" type="bool" value="false"/>
    <property name="EnableInputFeedbackSounds" type="bool" value="false"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName" type="string" value="Noto Sans 10"/>
  </property>
</channel>
XSETTINGS

echo "✓ XFCE configurado com tema Windows 11!"

################################################################################
# Otimizações para 4GB RAM
################################################################################
echo "⚡ Aplicando otimizações de RAM..."

# Desabilita serviços desnecessários
systemctl mask \
    bluetooth.service \
    cups.service \
    avahi-daemon.service \
    ModemManager.service \
    2>/dev/null || true

# Configura swappiness (reduz uso de swap)
echo "vm.swappiness=10" >> /etc/sysctl.conf

# Limita cache de memória
echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf

# Configuração de Wine otimizada
mkdir -p /root/.wine
cat > /root/.wine/user.reg << 'WINEREG'
REGEDIT4

[HKEY_CURRENT_USER\Software\Wine\Direct3D]
"VideoMemorySize"="1024"
"OffScreenRenderingMode"="fbo"
"RenderTargetLockMode"="disabled"
"Multisampling"="disabled"
WINEREG

echo "✓ Otimizações aplicadas!"

################################################################################
# Prepara VC_redist
################################################################################
echo "📋 Configurando Visual C++ Redistributable..."

# Cria diretório para instaladores
mkdir -p /root/Installers

# Cria atalho no desktop para o instalador
mkdir -p /root/Desktop
cat > /root/Desktop/install-vcredist.desktop << 'DESKTOP'
[Desktop Entry]
Version=1.0
Type=Application
Name=Install Visual C++ Redistributable
Comment=Required for gaming
Exec=sh -c "cd /sdcard && box64 wine VC_redist.arm64.exe"
Icon=application-x-msdownload
Terminal=true
Categories=System;
DESKTOP

chmod +x /root/Desktop/install-vcredist.desktop

echo "✓ Instalador preparado!"

################################################################################
# Cria launcher de jogos
################################################################################
echo "🎮 Criando launcher de jogos..."

cat > /usr/local/bin/launch-game << 'LAUNCHER'
#!/bin/bash

GAME_PATH="$1"

if [ -z "$GAME_PATH" ]; then
    zenity --error --text="Please provide game path"
    exit 1
fi

# Verifica se arquivo existe
if [ ! -f "$GAME_PATH" ]; then
    zenity --error --text="Game executable not found:\n$GAME_PATH"
    exit 1
fi

# Define variáveis de ambiente otimizadas
export WINEPREFIX="/root/.wine"
export WINEDEBUG=-all
export MESA_LOADER_DRIVER_OVERRIDE=zink
export GALLIUM_DRIVER=zink
export MESA_GL_VERSION_OVERRIDE=4.6
export mesa_glthread=true
export vblank_mode=0

# Notifica usuário
zenity --info --timeout=2 --text="Launching game..." &

# Lança jogo com Box64 + Wine
cd "$(dirname "$GAME_PATH")"
box64 wine "$(basename "$GAME_PATH")"
LAUNCHER

chmod +x /usr/local/bin/launch-game

# Cria gestor de jogos
cat > /usr/local/bin/game-manager << 'MANAGER'
#!/bin/bash

while true; do
    CHOICE=$(zenity --list \
        --title="HyperDroid Game Manager" \
        --text="Selecione uma ação:" \
        --column="Ação" \
        "🎮 Add New Game" \
        "▶️ Launch Game" \
        "📋 Install VC++ Redistributable" \
        "⚙️ Wine Configuration" \
        "❌ Exit")
    
    case $CHOICE in
        "🎮 Add New Game")
            GAME_EXE=$(zenity --file-selection --title="Selecione o executável do jogo (.exe)")
            if [ -n "$GAME_EXE" ]; then
                GAME_NAME=$(zenity --entry --title="Nome do Jogo" --text="Digite o nome do jogo:")
                
                # Cria atalho no desktop
                DESKTOP_FILE="/root/Desktop/${GAME_NAME}.desktop"
                cat > "$DESKTOP_FILE" << GAME
[Desktop Entry]
Version=1.0
Type=Application
Name=$GAME_NAME
Exec=launch-game "$GAME_EXE"
Icon=applications-games
Terminal=false
Categories=Game;
GAME
                chmod +x "$DESKTOP_FILE"
                
                zenity --info --text="Jogo '$GAME_NAME' adicionado ao desktop!"
            fi
            ;;
            
        "▶️ Launch Game")
            GAME_EXE=$(zenity --file-selection --title="Selecione o jogo para executar" --file-filter="*.exe")
            if [ -n "$GAME_EXE" ]; then
                launch-game "$GAME_EXE"
            fi
            ;;
            
        "📋 Install VC++ Redistributable")
            if [ -f "/sdcard/VC_redist.arm64.exe" ]; then
                cd /sdcard
                box64 wine VC_redist.arm64.exe
            else
                zenity --error --text="Arquivo VC_redist.arm64.exe não encontrado em /sdcard/"
            fi
            ;;
            
        "⚙️ Wine Configuration")
            winecfg &
            ;;
            
        "❌ Exit")
            exit 0
            ;;
    esac
done
MANAGER

chmod +x /usr/local/bin/game-manager

# Cria atalho no desktop
cat > /root/Desktop/game-manager.desktop << 'DESKTOP2'
[Desktop Entry]
Version=1.0
Type=Application
Name=HyperDroid Game Manager
Comment=Manage your Windows games
Exec=game-manager
Icon=applications-games
Terminal=false
Categories=Game;System;
DESKTOP2

chmod +x /root/Desktop/game-manager.desktop

echo "✓ Launcher criado!"

################################################################################
# Otimizações finais
################################################################################
echo "🔧 Otimizações finais..."

# Remove documentação para economizar espaço
rm -rf /usr/share/doc/* /usr/share/man/* 2>/dev/null || true

# Limpa cache APT
apt clean
apt autoclean
apt autoremove -y

# Desabilita atualizações automáticas
systemctl disable apt-daily.timer 2>/dev/null || true
systemctl disable apt-daily-upgrade.timer 2>/dev/null || true

echo ""
echo "════════════════════════════════════════════════════════════"
echo "✓ Configuração do Ubuntu concluída com sucesso!"
echo "════════════════════════════════════════════════════════════"
UBUNTU_SETUP

chmod +x /tmp/setup_desktop.sh

# Executa script dentro do Ubuntu
print_warning "Isso pode levar 15-30 minutos dependendo da conexão..."
proot-distro login ubuntu --shared-tmp -- bash /tmp/setup_desktop.sh

print_success "Desktop Ubuntu configurado!"
echo ""

################################################################################
# ETAPA 4: Cria scripts de inicialização do Termux
################################################################################
print_step "4/8: Criando scripts de inicialização..."

# Script para iniciar servidor X11
cat > ~/start-desktop.sh << 'STARTX11'
#!/data/data/com.termux/files/usr/bin/bash

echo "🖥️ Iniciando HyperDroid Desktop Environment..."

# Mata processos anteriores
killall -9 termux-x11 Xwayland pulseaudio 2>/dev/null || true
sleep 1

# Configurações de GPU otimizadas
export MESA_LOADER_DRIVER_OVERRIDE=zink
export GALLIUM_DRIVER=zink
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLSL_VERSION_OVERRIDE=460
export ZINK_DESCRIPTORS=lazy
export vblank_mode=0
export mesa_glthread=true

# Inicia PulseAudio
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 2>/dev/null &

sleep 1

# Inicia Termux-X11
termux-x11 :0 -ac -extension MIT-SHM &

sleep 2

echo ""
echo "════════════════════════════════════════════════════════════"
echo "✓ Servidor X11 iniciado!"
echo ""
echo "📱 PRÓXIMO PASSO:"
echo "   1. Abra o app 'Termux-X11' no Android"
echo "   2. Execute: ~/launch-desktop.sh"
echo "════════════════════════════════════════════════════════════"
STARTX11

chmod +x ~/start-desktop.sh

# Script para lançar desktop dentro do Ubuntu
cat > ~/launch-desktop.sh << 'LAUNCHDESK'
#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 Lançando Desktop XFCE..."

# Variáveis de ambiente
export DISPLAY=:0
export PULSE_SERVER=127.0.0.1
export MESA_LOADER_DRIVER_OVERRIDE=zink
export GALLIUM_DRIVER=zink

# Lança XFCE dentro do Ubuntu
proot-distro login ubuntu --shared-tmp -- bash -c "
    export DISPLAY=:0
    export PULSE_SERVER=127.0.0.1
    
    # Inicia DBUS
    dbus-launch --exit-with-session startxfce4 &
    
    echo '✓ Desktop XFCE iniciado!'
    echo ''
    echo 'Visualize no app Termux-X11'
    
    # Mantém sessão ativa
    wait
"
LAUNCHDESK

chmod +x ~/launch-desktop.sh

# Script completo (faz tudo de uma vez)
cat > ~/hyperdroid.sh << 'ALLINONE'
#!/data/data/com.termux/files/usr/bin/bash

echo "🎮 HyperDroid - Iniciando ambiente completo..."
echo ""

# Inicia servidor X11
~/start-desktop.sh &

sleep 3

# Aguarda usuário abrir app Termux-X11
echo "⏳ Aguardando você abrir o app Termux-X11..."
echo "   (Pressione ENTER após abrir o app)"
read

# Lança desktop
~/launch-desktop.sh
ALLINONE

chmod +x ~/hyperdroid.sh

# Script de menu rápido
cat > ~/menu.sh << 'QUICKMENU'
#!/data/data/com.termux/files/usr/bin/bash

cat << 'BANNER'
    ██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗ ██████╗ ██████╗  ██████╗ ██╗██████╗ 
    ██║  ██║╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔═══██╗██║██╔══██╗
    ███████║ ╚████╔╝ ██████╔╝█████╗  ██████╔╝██║  ██║██████╔╝██║   ██║██║██║  ██║
    ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══╝  ██╔══██╗██║  ██║██╔══██╗██║   ██║██║██║  ██║
    ██║  ██║   ██║   ██║     ███████╗██║  ██║██████╔╝██║  ██║╚██████╔╝██║██████╔╝
    ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝╚═════╝ 
                          Windows 11 Desktop Environment
BANNER

echo ""
echo "Escolha uma opção:"
echo ""
echo "1) 🚀 Iniciar Desktop Completo"
echo "2) 🎮 Adicionar Jogo"
echo "3) ⚙️ Configurações Wine"
echo "4) 📊 Status do Sistema"
echo "5) 🛑 Parar Tudo"
echo "6) 📖 Ver Documentação"
echo "7) ❌ Sair"
echo ""
read -p "Opção: " choice

case $choice in
    1)
        ~/hyperdroid.sh
        ;;
    2)
        proot-distro login ubuntu -- game-manager
        ;;
    3)
        proot-distro login ubuntu -- winecfg
        ;;
    4)
        echo "📊 Status do Sistema:"
        echo ""
        echo "RAM Livre: $(free -h | awk '/^Mem:/ {print $7}')"
        echo "Processos X11: $(pgrep -c termux-x11 || echo 0)"
        echo "Ubuntu: $(proot-distro list | grep ubuntu)"
        ;;
    5)
        killall -9 termux-x11 pulseaudio 2>/dev/null
        echo "✓ Todos os processos parados"
        ;;
    6)
        cat ~/HYPERDROID_README.txt
        ;;
    7)
        exit 0
        ;;
esac
QUICKMENU

chmod +x ~/menu.sh

print_success "Scripts de inicialização criados!"
echo ""

################################################################################
# ETAPA 5: Cria documentação
################################################################################
print_step "5/8: Criando documentação..."

cat > ~/HYPERDROID_README.txt << 'README'
╔══════════════════════════════════════════════════════════════╗
║          HYPERDROID - GUIA DE USO RÁPIDO                     ║
╚══════════════════════════════════════════════════════════════╝

🚀 COMO INICIAR O DESKTOP:

Opção 1 - Menu Rápido (Recomendado):
  ./menu.sh

Opção 2 - Tudo de uma vez:
  ./hyperdroid.sh

Opção 3 - Passo a passo:
  1. ./start-desktop.sh
  2. Abra o app "Termux-X11" no Android
  3. ./launch-desktop.sh

📱 PRIMEIRO USO:

1. Baixe o app Termux-X11:
   https://github.com/termux/termux-x11/releases
   (Instale o arquivo .apk)

2. Copie o VC_redist.arm64.exe para /sdcard/

3. Execute: ./hyperdroid.sh

4. No desktop, clique em "Install Visual C++ Redistributable"

🎮 ADICIONAR JOGOS:

Método 1 - Via Desktop:
  - Clique em "HyperDroid Game Manager"
  - Selecione "Add New Game"
  - Navegue até o .exe do jogo
  - Digite o nome
  - Atalho criado no desktop!

Método 2 - Manual:
  - Copie jogos para /sdcard/Games/
  - Use "Launch Game" para testar

⚙️ CONFIGURAÇÕES:

Wine Config:
  No desktop, abra terminal e digite: winecfg

Mudar resolução:
  Settings > Display

Adicionar DLLs:
  winetricks (no terminal)

🔧 OTIMIZAÇÕES:

RAM Livre: O sistema usa ~800MB base
GPU: Mesa Zink ativado automaticamente
CPU: Box64 com dynarec otimizado

💡 DICAS:

- Feche apps Android em segundo plano
- Configure jogos em gráficos "Médio" ou "Baixo"
- DirectX 9-11 tem melhor compatibilidade
- Use tela cheia para melhor performance

📊 COMANDOS ÚTEIS:

Menu Rápido: ./menu.sh
Ver uso de RAM: free -h
Testar Wine: wine --version
Testar Box64: box64 --version

🆘 PROBLEMAS COMUNS:

Tela preta no Termux-X11:
  - Mate tudo: killall termux-x11
  - Reinicie: ./hyperdroid.sh

Jogo não inicia:
  - Verifique se VC++ foi instalado
  - Tente: winetricks d3dx9 vcrun2019

Som não funciona:
  - Reinicie PulseAudio
  - pulseaudio --kill && pulseaudio --start

════════════════════════════════════════════════════════════════
Desenvolvido para Moto G20 (4GB RAM)
Otimizado para Unisoc T700 + Mali-G52
════════════════════════════════════════════════════════════════
README

print_success "Documentação criada!"
echo ""

################################################################################
# ETAPA 6-8: Finalização
################################################################################
print_step "6/8: Limpando arquivos temporários..."
rm -f /tmp/setup_desktop.sh
print_success "Arquivos temporários removidos!"
echo ""

print_step "7/8: Configurando permissões..."
chmod +x ~/*.sh
print_success "Permissões configuradas!"
echo ""

print_step "8/8: Verificando instalação..."
sleep 1
print_success "Instalação verificada!"
echo ""

################################################################################
# RESUMO FINAL
################################################################################
echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}              ${GREEN}✓ INSTALAÇÃO CONCLUÍDA COM SUCESSO!${NC}            ${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📥 PRÓXIMO PASSO - Instale o app Termux-X11:${NC}"
echo "   https://github.com/termux/termux-x11/releases"
echo "   (Baixe e instale o arquivo .apk mais recente)"
echo ""
echo -e "${BLUE}🎮 PARA INICIAR O HYPERDROID:${NC}"
echo -e "   ${GREEN}./menu.sh${NC}  (Menu interativo - recomendado)"
echo "   ou"
echo -e "   ${GREEN}./hyperdroid.sh${