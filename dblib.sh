#!/bin/bash

# lib de controle do banco de dados textual

SEP=";"
TEMP=temp.$$
DATABASE="$HOME/vpn/garages.csv"

[ "$DATABASE" ] || {
    echo "Base de dados nao encontrado."

    return 1;
}

#Verifica se a chave $1(parametro passado) esta na base de dados;
haveKey() {
    grep -iq "$1" "$DATABASE" # usar -q para quiet retornara true or false
}

#exporta o password / chamada default
exportPass(){
    haveKey "$1" || return # nao retorna nada caso não ache e exit code = 1;
    PASSWORDKEY=$(grep -i "$1" "$DATABASE" |\
                cut -d "$SEP" -f2)

    echo "$PASSWORDKEY";
}

# apaga registro no banco textual / chamar com -d
deleteLine() {
    haveKey "$1" || return # nao retorna nada caso não ache e exit code = 1;
    grep -i -v "$1$SEP" "$DATABASE" > "$TEMP"
    mv --force "$TEMP" "$DATABASE"

    echo "Registro '$1' foi apagado";
}

#insere nova linha $* na base de dados / chamar com -i
insertLine() {
    if [ "$1" -a "$2" ]; then
        if haveKey "$1"; then
            echo "A chave '$1' ja esta cadastrada na base de dados."
            return 1;
        else
            echo "$1$SEP$2" >> "$DATABASE"
            echo "Registro de '$1' cadastrada com sucesso"
        fi
    else
        echo "Dados ausentes."
        return 1;
    fi

    return 0;
}