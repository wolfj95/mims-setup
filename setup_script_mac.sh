#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\e[34m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
NC='\033[0m'
CLEAR_LINE='\r\033[K'
UP='\033[1A'
BOLD='\e[1m'
NORMAL='\e[21m'


# Exit if any subcommand fails
#set -e

function set_ownership {
    printf "${CLEAR_LINE}🔍  ${BLUE}Giving user write permission local directory..."
    DIR=/usr/local/etc
    if [ -d "$DIR" ]; then
        #changing ownership of /usr/local/etc directories
        sudo chown -R $(whoami) $DIR
        #giving user write permission
        chmod u+w $DIR
    fi
}

function macos_version_check {
    # macOS version check, Hombrew require 10.12 or higher
    printf "${CLEAR_LINE}🔍  ${BLUE}Checking macOS version...${NC}"
    os_version=$( defaults read loginwindow SystemVersionStampAsString )
    vercomp $os_version $1 
    if [[ $? == 2 ]]; then
        printf "${CLEAR_LINE}$┌────── {RED}You are running macOS verion %s.\n" $os_version
        printf "│       ${RED}Installing Homebrew requires macOS version $1 or higher. Please ask an instructor for help. ${NC}"
        read -p "│       Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
        printf "🔍  ${BLUE}Checking system requiremets...${NC}"
        return 1
    fi
    return 0
}

function install_xcode  {
    printf "${CLEAR_LINE}💻  ${BLUE}Installing Xcode... (this may take a while)${NC}\n"
    printf "\n"
    printf "    ${BLUE}Note: This installation will begin in another window.\n"
    printf "    Please click \"Install\" and accept the license agreement.${NC}"
    CHECK=$((xcode-\select --install) 2>&1)
    STR="xcode-select: note: install requested for command line developer tools"
    while [[ "$CHECK" == "$STR" ]];
    do
        sleep 5
        CHECK=$((xcode-\select --install) 2>&1)
    done
    if ! command -v xcode-select > /dev/null; then
        printf "${CLEAR_LINE}${UP}${CLEAR_LINE}${UP}${CLEAR_LINE}${UP}${CLEAR_LINE}┌────── ${RED}Unexpected output from Xcode installation. Please ask an instructor for help. ${NC}"
        read -p "│       Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
        printf "💻  ${BLUE}Installing xcode command line tools...${NC}"
        return 1
    fi
    return 0
}

function install_homebrew {
    # Homebrew installation
    printf "${CLEAR_LINE}🍺  ${BLUE}Installing Homebrew... (this may take a while)${NC}"
    if ! command -v brew > /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &> /dev/null
    fi
    version=$( brew --version | sed -nEe 's/^[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p' | head -n 1 )
    vercomp $version $1 
    if [[ $? == 2 ]]; then
        brew update &> /dev/null
        version=$( brew --version | sed -nEe 's/^[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p' | head -n 1 )
        vercomp $version $1 
        if [[ $? == 2 ]]; then
            printf "${CLEAR_LINE}┌────── ${RED}Output from version request: %s${NC}\n" "$version"
            printf "│       ${RED}Unexpected output from Homebrew installation. Please ask an instructor for help. ${NC}"
            read -p "│       Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
            printf "🍺  ${BLUE}Installing homebrew...${NC}"
            return 1
        fi
    fi
    return 0
}

function install_brew_package {
    printf "${CLEAR_LINE}🔨  ${BLUE}Installing $1...${NC}"
    if ! command -v $1 > /dev/null; then
        if [[ -n $3 ]]; then
            brew install --cask $1 &> /dev/null
        else
            brew install $1 &> /dev/null
        fi
    fi
    version=$( $1 --version | sed -nEe 's/^[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p' | head -n 1 )
    vercomp $version $2 
    if [[ $? == 2 ]]; then
        if [[ -n $3 ]]; then
            brew upgrade --cask $1 &> /dev/null
        else
            brew upgrade $1 &> /dev/null
        fi
        version=$( $1 --version | sed -nEe 's/^[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p' | head -n 1 )
        vercomp $version $2 
        if [[ $? == 2 ]]; then
            printf "${CLEAR_LINE}┌────── ${YELLOW}Output from $1 version request: %s${NC}\n" "$version"
            printf "│       ${YELLOW}Expected version $2 or higher. Please ask an instructor for help. ${NC}\n"
            read -p "│       Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
            printf "🔨  ${BLUE}Installing $1...${NC}"
            return 1
        fi
    fi
    return 0
}

vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}
printf "┌── 👋\n"
printf "│   ${PURPLE}Welcome to the MIMS Python Bootcamp setup script! Running this script${NC}\n"
printf "│   ${PURPLE}will download some new software and get your computer setup up for${NC}\n"
printf "│   ${PURPLE}the course. Some of the steps may take a while to complete.${NC}\n"
printf "│   ${PURPLE}If you get stuck or have any questions, ask an instructor.${NC}\n"
printf "│\n"
printf "│   ${PURPLE}Note: the setup may ask for your password. As a security measure, you${NC}\n"
printf "│   ${PURPLE}won't see any characters when you type it in.${NC}\n"
read -p "│   Ready to begin? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
printf "\n"

printf "🔍  ${BLUE}Checking system requirements..."
set_ownership
if macos_version_check 10.12 ; then
printf "${CLEAR_LINE}👍  ${GREEN}System requirements passed!${NC}\n"
else
printf "${CLEAR_LINE}✋  ${YELLOW}System requirements not met.${NC}\n"
fi

printf "💻  ${BLUE}Installing Xcode command line tools...${NC}"
if install_xcode 2354 ; then
    printf "${CLEAR_LINE}${UP}${CLEAR_LINE}${UP}${CLEAR_LINE}${UP}${CLEAR_LINE}👍  ${GREEN}Xcode command line tools installed!${NC}\n"
else
    printf "${CLEAR_LINE}✋  ${YELLOW}Xcode command line tools may not have installed correctly!${NC}\n"
fi

printf "🍺  ${BLUE}Installing Homebrew...${NC}"
if install_homebrew 2.4.9 ; then
printf "${CLEAR_LINE}👍  ${GREEN}Homebrew installed!${NC}\n"
else
printf "${CLEAR_LINE}✋  ${YELLOW}Homebrew may not have installed correctly.${NC}\n"
fi

printf "🔨  ${BLUE}Installing brew packages...${NC}"
STATUS=0
if ! install_brew_package python3 3.8 ; then
    STATUS=1
fi
if ! install_brew_package git 2.28 ; then
    STATUS=1
fi
if [ $STATUS == 0 ] ; then
    printf "${CLEAR_LINE}👍  ${GREEN}Brew packages installed!${NC}\n"
else
    printf "${CLEAR_LINE}✋  ${YELLOW}Some Brew packages may not have installed properly.${NC}\n"
fi

printf "${PURPLE}Your computer is configured! Please restart Terminal. ${NC}\n"
exit 0
