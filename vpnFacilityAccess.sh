#!/bin/bash

################################################################
#/root/vpn.sh                                                  #
#Possui um alias (/root/.bashrc) para inicar o script pelo     #
#comando: 'vpn' 'argumento'                                    #
#                                                              #
#Objetivo:                                                     #
#Conexao agilizada das VPN's                                   #
#                                                              #
#Funcionamento:                                                #
#Lê um argumento de entrada e verifica se existe um vpn valida.#
#                                                              #
#Felipe Franca, Mar 2021                                       #
#                                                              #
#22/04/20 - Melhorias no codigo, interface e vaidacao do indice#
# inserido para prevenir erros                                 #
#                                                              #
################################################################

ARGS1="$1"
ARGS2="$2"
ARGS3="$3"
STARTCOLOR="\e[1;32m"
ENDCOLOR="\e[0m"

# adiciona a lib dblib ( gerenciador do banco textual )
source $HOME/vpn/dblib.sh || {
    echo -e "Erro no gerenciador ou arquivo não encotrado.\n"
    return 1;
}

# Valida qual operacao sera realizada. se não atender segue o fluxo.
case "$ARGS1" in
    "-i")
        if [ "$2" -a "$3" ]; then
            echo -e "Adding vpn '$2' with pass '$3'."
            insertLine "$2" "$3"
            exit 0;
        else
            echo "Missing data."
            exit 1;
        fi
    ;;

    "-d")
        if [ "$2" ]; then
            echo "Removing vpn '$2'."
            deleteLine $2
            exit 0;
        else
            echo "Missing data."
            exit 1;
        fi
    ;;
esac

# declarar array com as vpn's encontradas por intermedio do parametro passado.
# variavel $IFS alterada para pode incluir espaças nas intacias o array.
OLDIFS="$IFS"
IFS="$"

declare LIST=($(grep "$ARGS1" /etc/openvpn/openvpn-* |\
        awk -F ':|,' '{print $2 " " $3}' |\
        grep -E "^(([0-9]{1,3}.){3})" |\
        cat -A)
        )

IFS="$OLDIFS"

# função para extrai ip e unidade do array
ExtractUserIpPass() {
    IP=$( echo "$1" | \
        awk '{print $1}'
    )

    GAR=$( echo "$1" | \
        awk '{print $2}'
    )
    
    exportPass $GAR

    if [ -z "$ARGS2" ]; then

        ARGS2="root"

    fi
}

clear

echo "+-----+---------------------------------------------------------+"
echo -e "| IDX |\t\tGARAGE"
echo "+-----+---------------------------------------------------------+"

for ((i=0; i<${#LIST[@]}; i++)) do
    if [ $i -le 8 ]; then
        COLUMN="  |"
    elif [ $i -gt 8 -a $i -le 98 ]; then
        COLUMN=" |"
    else
        COLUMN="|"
    fi

    echo -e "|" $(expr $i + 1)  "$COLUMN" "${STARTCOLOR}" ${LIST[$i]} "${ENDCOLOR}"
    echo "+-----+---------------------------------------------------------+"
done

if [ "${#LIST[@]}" -gt 1 ]; then
    read -rp "Enter INDEX number: " INDEX

    re="^[0-9]{1,}+$"

    while ! [[ "${INDEX}" =~ ${re} ]]; do
        read -rp "Invalid character. Try again: " INDEX
    done

    if [ $INDEX -gt ${#LIST[@]} ]; then
        echo "Index $INDEX out of range."
        exit 1
    elif [ $INDEX -ne 0 ]; then
        INDEX=$(expr $INDEX - 1)
    fi

    clear
    echo -e "Conneting to" "$STARTCOLOR" ${LIST[$INDEX]} "$ENDCOLOR"

    ExtractUserIpPass "${LIST[$INDEX]}"
else
    INDEX=0

    ExtractUserIpPass "${LIST[$INDEX]}"
fi

$HOME/vpn/expect.exp $ARGS2 $IP $PASSWORDKEY