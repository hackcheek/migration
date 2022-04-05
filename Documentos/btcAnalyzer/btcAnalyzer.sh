#!/bin/bash

trap ctrl_c INT

# Colores
declare -r greenColor="\e[0;32m\033[1m"
declare -r endColor="\033[0m\e[0m"
declare -r redColor="\e[0;31m\033[1m"
declare -r blueColor="\e[0;34m\033[1m"
declare -r yellowColor="\e[0;33m\033[1m"
declare -r purpleColor="\e[0;35m\033[1m"
declare -r turquoiseColor="\e[0;36m\033[1m"
declare -r grayColor="\e[0;37m\033[1m"

# Armado de la tabla
function printTable(){

    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function removeEmptyLines(){

    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString(){

    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString(){

    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString(){

    local -r string="${1}"
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}

# Comienzo del programa

# Variables
unconfirmed_transactions="https://www.blockchain.com/btc/unconfirmed-transactions"
inspect_transactions='https://www.blockchain.com/es/btc/tx'
inspect_address='https://www.blockchain.com/es/btc/address'

# Funciones

# Panel de ayuda
function helpPanel(){
    echo -e ${redColor}'\n\t[!] Uso de btcAnalyzer'${endColor}
    for i in {1..80}; do echo -ne '-'; done
    echo -e '\n\n\t'${yellowColor}'[-e]'${endColor}' '${grayColor}'Modo exploracion'${endColor}''
    echo -e ''${blueColor}'\t\tunconfirmed_transactions:'${endColor}'\t '${blueColor}'Listar transacciones no confirmadas'${endColor}''
    echo -e ''${blueColor}'\t\tinspect:\t\t\t'${endColor}''${blueColor}' Inspeccionar una transaccion entradas y salidas'${endColor}''
    echo -e ''${blueColor}'\t\taddress:\t\t\t'${endColor}''${blueColor}' Inspeccionar '${endColor}''
    echo -e ''${yellowColor}'\n\t[-n]'${grayColor}' Limitar la cantidad de transacciones mostradas'${endColor}''
    echo -e ''${yellowColor}'\n\t[-i]'${grayColor}' Inspeccionar una direccion especifica (-e inspect/address)'${endColor}''
    echo -e ''${blueColor}'\t\tEjemplo: ... -i 8bb6487faab452a2c723fd4593428dd88ad5cd1c4e40d04ae93130b1795d21ef'${endColor}''
    echo -e ''${yellowColor}'\n\t[-h]'${grayColor}' Mostrar este panel de ayuda\n'${endColor}''

	  tput cnorm; exit 1
}

# Accion control_c
function ctrl_c(){
    echo -e "[!]Saliendo..."
    tput cnorm; exit 1
    rm *.tmp
}

# Muestreo de transacciones no confirmadas
function unconfirmedTransactions(){

    number_output=$1

    echo '' > ut.tmp

    while [ $(cat ut.tmp | wc -l) == 1 ]; do

        curl "$unconfirmed_transactions" | html2text > ut.tmp

    done

    hashes=$(cat ut.tmp | grep 'Hash' -A 1 | grep -v -E 'Hash|Time|\-' | head -n $number_output)

    echo 'Hash_Dolar_Bitcoin_Tiempo' > utTable.tmp

    for hash in $hashes; do

        echo "${hash}_$(cat ut.tmp | grep $hash -A 6 | tail -n 1 | cut -d ' ' -f 1)_$(cat ut.tmp | grep $hash -A 4 | tail -n 1 | cut -d ' ' -f 1)_$(cat ut.tmp | grep $hash -A 2 | tail -n 1 | cut -d ' ' -f 1)" >> utTable.tmp

    done

    cat utTable.tmp  | tr '_' ' ' | awk '{print $2}' | grep -v 'Dolar' | tr -d '$' | sed 's/\..*//g' | tr -d ',' > totalMoney.tmp

    totalMoney=0; cat totalMoney.tmp | while read money_in_line; do
        let totalMoney+=money_in_line
        echo $totalMoney > totalMoney.tmp
    done


    if [ "echo $(cat ut.tmp | wc -l)" != "0" ]; then
        echo -ne ${blueColor}
        printTable '_' "$(cat utTable.tmp)"
        echo -ne ${endColor}
        echo "\nCantidad total_\$$(printf "%'.d\n" $(cat totalMoney.tmp))" >> totalTable.tmp
        echo -ne ${greenColor}
        printTable '_' "$(cat totalTable.tmp)"
        echo -ne ${endColor}
    fi

    rm -r *.tmp

    tput cnorm
}
# Inspeccionar una transaccion
inspectTransactions(){

# Almacenar datos
    inspect_url=$(echo "$inspect_transactions/$input_hash")
    echo "$(curl -s "$inspect_url" | html2text)" > inspect.tmp

# Entradas
    echo 'Entradas_Cantidad' > inspect_inputs.tmp
    echo $(cat inspect.tmp | grep 'Desde' -A 500 | grep '^A$' -B 500 | grep -v -E 'Desde|abcd' | awk 'NR%2{printf "%s_",$0;next;}1' >> inspect_inputs.tmp)
# Salidas
    echo 'Salidas_Cantidad' > inspect_outputs.tmp
    echo $(cat inspect.tmp | grep '^A$' -A 500 | grep 'Esta transacci' -B 500 | grep -v -E 'Esta transacci|^A$' | awk 'NR%2{printf "%s_",$0;next;}1' >> inspect_outputs.tmp)

# Muestreo
    echo -e ''${grayColor}'\n    Detalles de la transaccion'${endColor}''
    echo -en ${blueColor}
    printTable '_' "$(cat inspect_inputs.tmp)"
    echo -en ${redColor}
    printTable '_' "$(cat inspect_outputs.tmp)"
    echo -en ${endColor}

    rm *.tmp
    tput cnorm
}
inspectAddress(){
# Almacenar datos
    curl "$inspect_address/$input_hash" | html2text > address.tmp
    echo "Hash_$input_hash" > addressTable.tmp
    echo "Transacciones_$(cat address.tmp | grep 'Transacciones' -A 1 | awk 'NR==2')" >> addressTable.tmp
    echo -e "Total recibido_$(cat address.tmp | grep 'Total recibido' -A 1 | tail -n 1) | \$$(cat address.tmp | grep 'ha enviado' | awk '{print $7}' | tr -d '(' | sed 's/,.*//')" >> addressTable.tmp
    echo -e "Total enviado_$(cat address.tmp | grep 'Total enviado' -A 1 | tail -n 1) | \$$(cat address.tmp | grep '.El valor actual' | awk '{print $6}' | tr -d '(' | sed 's/,.*//' )" >> addressTable.tmp
    echo -e "Saldo final_$(cat address.tmp | grep 'Saldo final' -A 1 | tail -n 1) | \$$(cat address.tmp | grep 'esta direcci' | awk '{print $6}' | tr -d '(' | sed 's/,.*//')" >> addressTable.tmp

    echo -e ''${grayColor}'\n    Detalles de la wallet'${endColor}''
    printTable '_' "$(cat addressTable.tmp)"

    rm *.tmp
    tput cnorm
}

# Parametros e inputs
parameter_counter=0; while getopts 'e:n:i:h:' arg; do

    case $arg in

		    e) exploration_mode=$OPTARG; let parameter_counter+=1;;
        n) number_output=$OPTARG; let parameter_counter+=1;;
        i) input_hash=$OPTARG; let parameter_counter+=1;;
		    h) helpPanel;;

	  esac

done

tput civis

if [ $parameter_counter == 0 ]; then

	  helpPanel

else
    if [ "$(echo $exploration_mode)" == "unconfirmed_transactions" ]; then
        if [ ! "$number_output" ]; then
            number_output=100
            unconfirmedTransactions $number_output
        else
            unconfirmedTransactions $number_output
        fi
    elif [ "$(echo $exploration_mode)" == "inspect" ];then
        inspectTransactions $input_hash

    elif [ "$(echo $exploration_mode)" == "address" ]; then
        inspectAddress $input_hash
    fi
fi
