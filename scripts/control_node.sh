#!/usr/bin/env bash

# TODO: TEST/VERIFY
# PRE-REQUIREMENTS: VirtualBox

# ---

0_verificar_distro(){
    DISTRO=$(grep 'ID_LIKE' /etc/os-release | awk -F '=' '{print $2}' | tr -d '"')
    case $DISTRO in
        'ubuntu debian' | 'ubuntu' | 'debian')
            echo 'OK' > /dev/null
            ;;
        *)  echo "Distro not supported. Terminating script."
            exit 1
            ;;
    esac
    unset DISTRO
}

ch1_vagrant_and_ansible_installation(){
    if ! command -v vagrant &>/dev/null; then
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
            sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install vagrant
    fi

    if ! command -v ansible &>/dev/null; then
        sudo apt update
        sudo apt install software-properties-common
        sudo add-apt-repository --yes --update ppa:ansible/ansible
        sudo apt install -y ansible
    fi
}

ch1_vagrant_configuration(){
    if [ -d ~/devops_101 ]; then
        echo -e "\nsource ~/devops_101/scripts/vagrant_vbox_env.sh" >> ~/.zshrc || \
        echo -e "\nsource ~/devops_101/scripts/vagrant_vbox_env.sh" >> ~/.bashrc
        # echo "OJO: revisar la partición de almacenamiento de las VMs (leer README.md)"
    else
        echo "No se encuentra el repositorio '~/devops_101'. Terminando script."
        exit 1
    fi

    # TODO: verificar que <VAGRANT_HOME="/var/vagrant.d"> al instalar los plugins

    if command -v ansible &>/dev/null; then
        vagrant plugin update
        vagrant plugin install vagrant-vbguest
    fi
}

ch2_pass_and_hash_generation(){
    # sudo apt-get update
    sudo apt-get install pwgen whois
    
    # NOTE: esto nos da igual porque vamos a desactivar contras y usar 2FA (llaves ssh y TOTP)
    read -p "¿Cuántos usuarios? " NUM
    for ((i=1; i<=NUM; i++)); do
        # read -p "Username: " user
        pass=$(pwgen --secure --capitalize --numerals --symbols 12 1)
        {
            # echo $user
            echo $pass
            echo $pass | mkpasswd --stdin --method=sha-512
            echo ""
        } | tee -a ~/devops_101/ansible/chapter2/.password_hash.txt
        # unset user
        unset pass
    done
    unset NUM
}

ch3_ssh_keys_generation(){
    if [ ! -e ~/.ssh/dftd ]; then
        read -p "Enter a passphrase for the new 'dftd' ssh keys: " passphrase
        echo "Passphrase for '~/.ssh/dftd': $passphrase" | \
            tee -a ~/devops_101/ansible/chapter3/.ssh_passphrase.txt
        ssh-keygen -t rsa -f ~/.ssh/dftd -C dftd -N "$passphrase"
        unset $passphrase
    fi
}

# ch3_oathtool(){
#     # ...
# }


# ---

if true; then
    0_verificar_distro
    ch1_vagrant_and_ansible_installation
    ch1_vagrant_configuration
    ch2_pass_and_hash_generation
    ch3_ssh_keys_generation
fi






# ---


    # sshpass -p "1234" ssh-keygen -t rsa -f ~/.ssh/dftd2 -C dftd2 -N "1234"
