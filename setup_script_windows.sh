#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\e[36m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
NC='\033[0m'
CLEAR_LINE='\r\033[K'
BOLD='\e[1m'
NORMAL='\e[21m'

function aptupdate() {
	#check for updates
	sudo apt-get update
}

function installpipandpython() {
	#install pip
	sudo apt-get install python-pip
	pip --version
	alias python=python3
	python --version
}

function changeubuntupath() {
	# changes default path of Ubunutu 
	printf "What is your Windows Username? (This is case sensitive):  \n"
	read WINDOWSUSERNAME

	if [[ $WINDOWSUSERNAME = *[[:space:]]* ]]; then
		WINDOWSUSERNAME_NOSPACE=`echo "$WINDOWSUSERNAME" | sed 's/\\ /\\\ /g'` 
	fi	

	DEFAULT_PATH="cd /mnt/c/Users/$WINDOWSUSERNAME_NOSPACE/" 
	printf "\n#changes default Ubunutu path\n$DEFAULT_PATH \n\n" >> ~/.bashrc 
}

function customlscommand() {
	#changes ls command and formatting
	
	TEXT=(
		"#Custom ls command and formatting"
		"LS_COLORS=\$LS_COLORS:'tw=1;44:ow=1;44:di=01;35:ln=90:fi=35:ex=33'"
		"export LS_COLORS" 
		"CUSTOMLS=\"command ls --human-readable --group-directories-first --color=auto -I NTUSER.DAT\* -I ntuser.dat\*\"" 
		"alias ls=\$CUSTOMLS"
	)
	printf '%s\n' "${TEXT[@]}" >> ~/.bashrc 
	source ~/.bashrc

}

INTRO_TEXT=(
	"Running this script will download some new software and get your computer setup up for the class."
	"Some of the steps may take a while to complete."
	"If you get stuck or have any questions, ask an instructor."

)

INTRO_PASSWORD_TEXT=(
	" The setup may ask for your password."
	" As a security measure, you won't see any characters when you type it in."
)
printf "${BLUE}--- Welcome to the MIMS Python Bootcamp setup script! ---\n"

printf '%s\n' "${INTRO_TEXT[@]}"
printf '\n'
printf "${BLUE}**Note: ${NC}\n"

printf '%s\n' "${INTRO_PASSWORD_TEXT[@]}"
printf '\n'
printf "${BLUE}-- Ready to begin? ${NC}\n"

read -p "(Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
printf '\n-------------------------------\n'

printf "${BLUE}--- Updating...${NC}\n"
aptupdate

printf "${BLUE}--- Installing pip and Python...${NC}\n"
installpipandpython

printf "${BLUE}--- Updating bash profile...${NC}\n"
changeubuntupath
customlscommand



