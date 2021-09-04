VERSION="beta-1.30.63-1"
LINK="https://github.com/brave/brave-browser/releases/download/v1.30.63/brave-browser-beta-1.30.63-linux-amd64.zip"

function logo() {
cat << EOF
 ▄▀▀▀▀▄     ▄▀▀█▀▄   ▄▀▀▀▀▄   ▄▀▀▄ ▀▄      ▄▀▀█▀▄    ▄▀▀▄ ▀▄  ▄▀▀▀▀▄  ▄▀▀▀█▀▀▄  ▄▀▀█▄   ▄▀▀▀▀▄    ▄▀▀▀▀▄     ▄▀▀█▄▄▄▄  ▄▀▀▄▀▀▀▄ 
█    █     █   █  █ █      █ █  █ █ █     █   █  █  █  █ █ █ █ █   ▐ █    █  ▐ ▐ ▄▀ ▀▄ █    █    █    █     ▐  ▄▀   ▐ █   █   █ 
▐    █     ▐   █  ▐ █      █ ▐  █  ▀█     ▐   █  ▐  ▐  █  ▀█    ▀▄   ▐   █       █▄▄▄█ ▐    █    ▐    █       █▄▄▄▄▄  ▐  █▀▀█▀  
    █          █    ▀▄    ▄▀   █   █          █       █   █  ▀▄   █     █       ▄▀   █     █         █        █    ▌   ▄▀    █  
  ▄▀▄▄▄▄▄▄▀ ▄▀▀▀▀▀▄   ▀▀▀▀   ▄▀   █        ▄▀▀▀▀▀▄  ▄▀   █    █▀▀▀    ▄▀       █   ▄▀    ▄▀▄▄▄▄▄▄▀ ▄▀▄▄▄▄▄▄▀ ▄▀▄▄▄▄   █     █   
  █        █       █         █    ▐       █       █ █    ▐    ▐      █         ▐   ▐     █         █         █    ▐   ▐     ▐   
  ▐        ▐       ▐         ▐            ▐       ▐ ▐                ▐                   ▐         ▐         ▐                  

EOF
}

function makeInstall() {
	mkdir -p /opt/brave
	cd /opt/brave

	if [[ $1 != "c" -o $1 != "C" ]] || [[ $1 != "w" -o $1 != "W" ]]
	then
		echo "Entrada inválida"
	fi

	if [[ $1 == "c" ]] || [[ $1 == "C" ]]
	then
		echo "Baixando com curl..."
		curl -s -L -o brave.zip $LINK
	elif [[ $1 == "w" ]] || [[ $1 == "W" ]]
	then
		echo "Baixando com wget"
		wget -O brave.zip $LINK
	fi
	
	clear
	unzip brave.zip
	rm brave.zip
}

function makeDesktop() {
	cd /usr/share/applications/
	echo "[Desktop Entry]
	Encoding=UTF-8
	Version=$VERSION
	Type=Application
	Terminal=false
	Exec=/opt/brave/brave
	Name=Brave Browser
	Icon=/opt/brave/product_logo_128.beta.png" > brave.desktop && cd
}


WHOAM=$(whoami)
if [[ $WHOAM != "root" ]]
then
	echo "Você precisa ser root para fazer esse processo."
	exit
fi

logo
echo "Eu irei instalar o brave na versão: $VERSION"

echo -e "\nDeseja instalar o Brave mesmo sabendo que se trata de uma versão instável [S/n]"
read -p "[lion-installer]-> " userInputInstall

if [[ -z $userInputInstall ]]
then
	clear
	userInputInstall="s"
elif [[ $userInputInstall == 'n' ]] || [[ $userInputInstall == 'N' ]]
then
	clear
	exit
fi

logo
echo "Averiguando comandos disponíveis..."
WGETCOMMAND=$(wget --help 2> /dev/null)
CURLCOMMAND=$(curl --help 2> /dev/null)
UNZIPCOMMAND=$(unzip --help 2> /dev/null)

if [[ -z $WGETCOMMAND ]] && [[ -z $CURLCOMMAND ]] || [[ -z $UNZIPCOMMAND ]]
then
	clear
	logo
	echo "[ - ] Você não possui wget nem curl ou lhe falta o comando unzip, por gentileza instale um dos dois ou, se já os possui, instale o unzip para fazer a instalação [ - ]"
	exit
elif [[ ! -z $WGETCOMMAND ]] && [[ ! -z $CURLCOMMAND ]] 
then
	clear
	logo
	echo "[ - ] Você possui o comando wget e o comando curl, qual eu devo usar? [ - ]"
	read -p "[C]url/[w]get -> " curlOrWget
	
	if [[ -z $curlOrWget ]]
	then
		curlOrWget="C"
	fi

	makeInstall $curlOrWget
	makeDesktop
	clear
	logo
	echo "[ - ] Instalação terminada [ - ]"
	exit

elif [[ -z $WGETCOMMAND ]] && [[ ! -z $CURLCOMMAND ]]
then
	echo "[ - ] Você possui apenas o comando curl, iremos usa-lo [ - ]"
	makeInstall "c"
	makeDesktop
	clear
	logo
	echo "[ - ] Instalação terminada [ - ]"
	exit

elif [[ ! -z $WGETCOMMAND ]] && [[ -z $CURLCOMMAND ]]
then
	echo "[ - ] Você possui apenas o comando wget, iremos usa-lo [ - ]"
	sleep 3
	makeInstall "wget"
	makeDesktop
	clear
	logo
	echo "[ - ] Instalação terminada [ - ]"
	exit
fi

