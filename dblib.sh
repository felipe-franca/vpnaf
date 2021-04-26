#!/bin/bash

SEP=";"
TEMP=temp.$$
DATABASE="$HOME/vpn/garages.csv"

[ "$DATABASE" ] || {

    echo "Base de dados nao encontrada. Use a variavel DATABASE."

    return 1
}

#Verifica se a chave $1 esta no DATABASE

haveKey() {

    KEYWORD=$(grep -i "$1" "$DATABASE" |\
        cut -d "$SEP" -f1)
}

#exporta o password
exportKey(){

    PASSWORDKEY=$(grep -i "$1" "$DATABASE" |\
        cut -d "$SEP" -f2)
    echo "$PASSWORDKEY";
}

deleteLine() {

    haveKey "$1" || return
    grep -i -v "$1$SEP" "$DATABASE" >"$TEMP"
    mv "$TEMP" "$DATABASE"

    echo "Registro '$1' foi apagado"
}

#insere nova linha $* no DATABASE

insertLine() {

    local key=$(echo "$2")

    if haveKey "$key"; then
        echo "A chave '$key' ja esta cadastrada no DATABASE"
        return 1
    else

         echo "$2$SEP$3" >>"$DATABASE"
        echo "Registro de '$key' cadastrada com sucesso"
    fi

    return 0
}


if [ -z "$*" ] && [ "$1" = "-i" ]; then

    insertLine $2 $3;

elif [ -z "$*" ] && [ "$1" = "-d" ]; then

    deleteLine $2;

else

  exportKey $1;

fi