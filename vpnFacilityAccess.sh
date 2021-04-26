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

ARGS="$1"
USER="$2"
STARTCOLOR="\e[1;32m"
ENDCOLOR="\e[0m"

OLDIFS="$IFS"
IFS="$"

declare LIST=($(grep "$ARGS" /etc/openvpn/openvpn* |\
        awk -F ':|,' '{print $2 " " $3}' |\
        grep -E "^(([0-9]{1,3}.){3})" |\
        cat -A)
        )

IFS="$OLDIFS"

ExtractUserIpPass() {

    IP=$(
        echo "$1" | \
        awk '{print $1}'
    )

    GAR=$(
        echo "$1" | \
        awk '{print $2}'
    )
    PASSWORD=$($HOME/vpn/dblib.sh $GAR)

    if [ -z "$USER" ]; then

        USER="root"

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

$HOME/vpn/expect.exp $USER $IP $PASSWORD