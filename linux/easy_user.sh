#!/bin/bash
# Autor: Percio Andrade
# Objetivo: Entrega de projeto para o fundamento de Linux da DIO
# Criação usando array de associação para evitar repetição de codigo
# Modularização com funções
# E algumas praticas de shell script, além de umas pinceladas no código kkk

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"

echo -e "
_______               _   _               
|  ___|              | | | |              
| |__  __ _ ___ _   _| | | |___  ___ _ __ 
|  __|/ _' / __| | | | | | / __|/ _ \ '__|
| |__| (_| \__ \ |_| | |_| \__ \  __/ |   
\____/\__,_|___/\__, |\___/|___/\___|_|   
                 __/ |                    
                |___/                     

Desafio do projeto fundamentos em Linux:
https://web.dio.me/project/infraestrutura-como-codigo-script-de-criacao-de-estrutura-de-usuarios-diretorios-e-permissoes/learning/
"
echo -e "\nEste script executará em ${GREEN}5 segundos${ENDCOLOR}, caso queira cancelar aperte control+c\n"
sleep 5

# Declara uma associação de array para os usuários
declare -A userGroups=(
    ["carlos"]="GRP_ADM"
    ["maria"]="GRP_SEC"
    ["joao"]="GRP_ADM"
    ["debora"]="GRP_VEN"
    ["sebastiana"]="GRP_SEC"
    ["roberto"]="GRP_ADM"
    ["josefina"]="GRP_VEN"
    ["amanda"]="GRP_SEC"
    ["rogerio"]="GRP_VEN"
)

userDirectory=('publico' 'adm' 'ven' 'sec')
directoryPath="/home"

# Inicia as verificicações
function checkInitial(){
    echo -e "${YELLOW}[-]${ENDCOLOR}: Iniciando script de geração de usuários."
    echo -e "${YELLOW}[-]${ENDCOLOR}: Fazendo verificações iniciais..."

    # Verifica se está executando como root
    if [[ $(whoami) != "root" ]]; then
        echo -e "${RED}[!]${ENDCOLOR}: Por favor, execute como usuário root."
        exit 1
    fi

    # Verifica arquivos do sistema
    if [[ ! -f "/etc/passwd" || ! -f "/etc/group" ]]; then
        echo -e "${RED}[!]${ENDCOLOR}: Arquivos do sistema não foram encontrados. O script não poderá continuar"
        exit 1
    fi

    # Verifica se as variáveis estão preenchidas
    if [[ ${#userGroups[@]} -eq 0 || ${#userDirectory[@]} -eq 0 ]]; then
        echo -e "${RED}[!]${ENDCOLOR}: Valores não podem ficar em branco."
        exit 1
    fi
}

# Verifica cada usuário no array
function checkUser(){
    echo -e "${YELLOW}[-]${ENDCOLOR}: Verificando usuários..."
    for user in "${!userGroups[@]}"; do
        getUsers=$(grep -io "^${user}" /etc/passwd)
        if [[ -n $getUsers ]]; then
            userdel -f -r "${user}" 2>/dev/null || echo -e "${RED}[!]${ENDCOLOR}: Falha ao remover usuário '${user}'."
        fi
    done
}

# Verifica cada grupo no array
function checkGroups(){
    echo -e "${YELLOW}[-]${ENDCOLOR}: Verificando grupos..."
    # Create array of unique groups
    declare -A uniqueGroups
    for group in "${userGroups[@]}"; do
        uniqueGroups[$group]=1
    done
    
    for group in "${!uniqueGroups[@]}"; do
        getGroup=$(grep -i "^${group}:" /etc/group)
        if [[ -n $getGroup ]]; then
            groupdel -f "${group}"
        fi
    done
}

# Verifica cada diretorio no array
function checkDir(){
    echo -e "${YELLOW}[-]${ENDCOLOR}: Verificando diretorios..."
    for dir in "${userDirectory[@]}"; do
        if [[ -d "${directoryPath}/${dir}" ]]; then
            rmdir "${directoryPath}/${dir}" 2>/dev/null || echo -e "${RED}[!]${ENDCOLOR}: Falha ao remover '${directoryPath}/${dir}'. Verifique se está vazio."
        fi
    done
}

# Cria os grupos do array
function createGroups() {
    echo -e "${YELLOW}[-]${ENDCOLOR}: Iniciando criação de grupos."
    # Cria array temporário para armazenar grupos únicos
    declare -A uniqueGroups
    for group in "${userGroups[@]}"; do
        uniqueGroups[$group]=1
    done

    # Cria cada grupo único
    for group in "${!uniqueGroups[@]}"; do
        groupadd "${group}"
        echo -e "${GREEN}[+]${ENDCOLOR}: Grupo ${group} criado com sucesso."
    done
}

# Inicia a criação dos diretorios e a correção de permissão para o root
function createDir() {
    echo -e "${YELLOW}[-]${ENDCOLOR}: Iniciando a criação de diretorios."
    for dir in "${userDirectory[@]}"; do
        mkdir "${directoryPath}/${dir}" 2>/dev/null || echo -e "${RED}[!]${ENDCOLOR}: Falha ao criar '${directoryPath}/${dir}'. Verifique se está vazio."
        echo -e "${GREEN}[+]${ENDCOLOR}: Diretório criado ${dir}."
        echo -e "${YELLOW}[!]${ENDCOLOR}: Alterando permissão de diretórios."
        
        # Alterando permissões gerais
        chmod 770 "${directoryPath}/${dir}"

        # Elemento (índice 1) /adm
        if [[ $i -eq 1 ]]; then
            chown root:GRP_ADM "${directoryPath}/${dir}"
        fi

        # Elemento (índice 2) /ven
        if [[ $i -eq 2 ]]; then
            chown root:GRP_VEN "${directoryPath}/${dir}"
        fi

        # Elemento (índice 3) /sec
        if [[ $i -eq 3 ]]; then
            chown root:GRP_SEC "${directoryPath}/${dir}"
        fi

        # Elemento (índice 0)
        if [[ $i -eq 0 ]]; then
            chmod 777 "${directoryPath}/${dir}"
            chown root:root "${directoryPath}/${dir}"
        fi
    done
    echo -e "${GREEN}[+]${ENDCOLOR}: Diretórios criados com sucesso."
}

# Cria os usuários do array com seus respectivos grupos
function createUsers() {
    echo -e "${YELLOW}[-]${ENDCOLOR}: Iniciando criação de usuários."
    for user in "${!userGroups[@]}"; do
        # Novas versões do openssl não utilizam -crpy para criptografia // depreciado
        # No lugar de -crpy, utilizamos -6 para SHA
        # https://github.com/openssl/openssl/blob/master/CHANGES.md
        useradd -m -s /bin/bash -p $(openssl passwd -6 "Senha123") "${user}" -G "${userGroups[$user]}"
        echo -e "${GREEN}[+]${ENDCOLOR}: Usuário ${user} criado com sucesso com grupo ${userGroups[$user]}."
    done
}

checkInitial
checkUser
checkGroups
checkDir
createGroups
createDir
createUsers

echo -e "${YELLOW}[-]${ENDCOLOR} Script executado com sucesso! Dios mio!"