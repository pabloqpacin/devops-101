# devops_101

> ***DevOps for the Desperate**. A Hands-On Survival Guide*. [Libro](https://nostarch.com/devops-desperate), [repo](https://github.com/bradleyd/devops_for_the_desperate).

- [devops\_101](#devops_101)
  - [Entornos de desarrollo y operaciones](#entornos-de-desarrollo-y-operaciones)
  - [Objetivos](#objetivos)
  - [Proyectos](#proyectos)
    - [Proyecto 1. Vagrant + Ansible](#proyecto-1-vagrant--ansible)
      - [1.1 (Ch. 1) Instalación de Vagrant y Ansible](#11-ch-1-instalación-de-vagrant-y-ansible)
      - [1.2 Configuraciones: hardware, VirtualBox, Vagrant](#12-configuraciones-hardware-virtualbox-vagrant)
      - [1.3 Implementación del `Vagrantfile`](#13-implementación-del-vagrantfile)
      - [1.4 Ansible: `site.yml`](#14-ansible-siteyml)
      - [1.5 (Ch. 2) Ansible: usuarios, grupos y contraseñas](#15-ch-2-ansible-usuarios-grupos-y-contraseñas)
        - [`pam_pwquality.yml`](#pam_pwqualityyml)
        - [`user_and_group.yml`](#user_and_groupyml)
        - [Demo: usuarios y permisos](#demo-usuarios-y-permisos)
      - [1.6 (Ch. 3) Ansible: ssh and 2FA](#16-ch-3-ansible-ssh-and-2fa)
        - [Generar claves ssh y `authorized_keys.yml`](#generar-claves-ssh-y-authorized_keysyml)
        - [`two_factor.yml` y `google_authenticator`](#two_factoryml-y-google_authenticator)
      - [1.7 (Ch. 4) Webapp \& sudoers (con Jinja)](#17-ch-4-webapp--sudoers-con-jinja)
        - [`web_application.yml`, `greeting.service`, `greeting.py` y `wsgi.py`](#web_applicationyml-greetingservice-greetingpy-y-wsgipy)
        - [`sudoers.yml` y `templates/developers.j2` (Jinja2)](#sudoersyml-y-templatesdevelopersj2-jinja2)
        - [*Provisioning the VM*](#provisioning-the-vm)
      - [1.8 (Ch. 5)  `ufw` firewall](#18-ch-5--ufw-firewall)
        - [`firewall.yml`](#firewallyml)
    - [Proyecto 2. Docker (en *Minikube*), Kubernetes y CI/CD pipelines](#proyecto-2-docker-en-minikube-kubernetes-y-cicd-pipelines)
        - [2.1 (Ch. 6) Instalación de minikube y docker-client](#21-ch-6-instalación-de-minikube-y-docker-client)
        - [2.2 Imagen Docker de aplicación `telnet-server`](#22-imagen-docker-de-aplicación-telnet-server)
        - [2.3 Demo de aplicación `telnet-server` (en Docker), revisión de logs](#23-demo-de-aplicación-telnet-server-en-docker-revisión-de-logs)
        - [2.4 (Ch. 7) Kubernetes: `deployment.yaml` y `service.yaml`](#24-ch-7-kubernetes-deploymentyaml-y-serviceyaml)
        - [2.5 (Ch. 8) Desplegando y testeando código (Skaffold CI/CD)](#25-ch-8-desplegando-y-testeando-código-skaffold-cicd)


## Entornos de desarrollo y operaciones

Nuestro hardware:

| Máquina       | Procesador                    | RAM   | Almacenamiento                            | OS            | ¿Multiboot?
| ---           | ---                           | ---   | ---                                       | ---           | ---
| Acer EX2511   | i5-4210U (4)<br> @ 2.70 GHz   | 16GB | 1x240GB SSD<br> 1x480 SSD                  | Pop!_OS 22.04 | Arch Linux
| **MSI GL76**  | i7-11800H (16)<br> @ 4.60 GHz | 32GB | 1x2TB NVMe<br> 1x1TB NVMe<br> 1x1TB HDD    | Pop!_OS 22.04 | No
| **Pi 5**      | ...                           | ...   | ...                                       | ...           | No
 

<!--
Cloud IaaS:

<table>
<thead>
<tr>
  <th>Provider
  <th>Cuenta
  <th>Servicios
  <th>Integración
</tr>
</thead>
<tbody>
<tr>
    <td rowspan=3>AWS
    <td>pq2
    <td>VM + IP fija
    <td>DonDominio: pabloqpacin.com
</tr>
<tr>
    <td>pqp
    <td colspan=2>...
</tr>
<tr>
    <td>p.q
    <td colspan=2>...
</tr>
<tr>
    <td rowspan=2>Trevenque
    <td colspan=3>... vSphere, Plesk...
</tr>
<tr>
    <td colspan=3>...
</tr>
<tr>
    <td>GCP
    <td colspan=3>...
</tr>
</tbody>
</table>
 -->


## Objetivos

Tecnologías que queremos aprender:

<table>
<thead>
<tr>
    <th>Proyecto
    <th colspan=2>Tecnologías
    <th>Entorno/
    <th>Plataforma
</thead>
<tbody>
<tr>
    <td>1
    <td><b>Vagrant
    <td><b>Ansible
    <td>Local (Acer EX2511)
    <td>VirtualBox
<tr>
    <td>2
    <td colspan=2>Terraform
    <td>Remoto
    <td>AWS
<tr>
    <td>3
    <td>Kubernetes
    <td>CI/CD
    <td>...
    <td>...
</tbody>
</table>


## Proyectos

**IMPORTANTE**: <u>clonar el repo</u> para manejar los archivos de los proyectos.

```bash
git clone https://github.com/pabloqpacin/devops_101.git $HOME/devops_101
```

### Proyecto 1. Vagrant + Ansible

<!-- - [ ] [/vagrant](/vagrant/)
- [ ] [/ansible](/ansible/) -->

Nos conectamos con `ssh` desde nuestra máquina de desarrollo *MSI GL76*  a la de operaciones *Acer EX2511*. Ambas están en nuestra red local y pilotan el sistema operativo *Pop!_OS* (derivado de Ubuntu).

La máquina *EX2511* tiene el OS instalado en `/dev/sdb1` (esta sería la partición *root* o `/`). Previamente hemos creado la partición `/dev/sdb2` con idea de almacenar VMs. Aunque no es necesario, decidimos dar persistencia al montaje de particiones con los siguientes comandos.

```bash
sudo mkdir -p /media/$USER/LAB
UUID=$(blkid /dev/sdb2 | awk '{print $3}' | awk -F '=' '{print $2}' | tr -d '"')
echo "UUID=$UUID /media/$USER/LAB ext4 defaults 0  2" | \
    sudo tee -a /etc/fstab
sudo mount -a
# df -h | grep /media/$USER/LAB
```


#### 1.1 (Ch. 1) Instalación de Vagrant y Ansible

Instalamos **Vagrant** (Ubuntu/Debian).

<!--
```bash
if command -v vagrant &>/dev/null; then
    echo "Vagrant is already installed."
else
    DISTRO=$(grep 'ID_LIKE' /etc/os-release | awk -F '=' '{print $2}' | tr -d '"')
    case $DISTRO in
        'ubuntu debian' | 'ubuntu' | 'debian')
            wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
            sudo apt update && sudo apt install vagrant
            ;;
        *)
            echo "Distro not supported. Terminating script."
            exit 1
            ;;
    esac
fi
```
-->

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
```

Instalar **Ansible** no es necesario para operar con Vagrant, pero dado que nuestro `Vagrantfile` hace uso de Ansible, mejor instalarlo ya (Ubuntu/Debian). Si no lo hacemos, habría que comentar las líneas relevantes del `Vagrantfile`.

```bash
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
```


#### 1.2 Configuraciones: hardware, VirtualBox, Vagrant

Hemos preparado [el script `vagrant_vbox_env.sh`](/scripts/vagrant_vbox_env.sh) para realizar varias tareas importantes.

1. Asignar a la variable de entorno `$VAGRANT_HOME` el valor `/var/vagrant.d` (por defecto sería `~/.vagrant.d`). Aquí se almacenarán varios archivos de configuración de **Vagrant**. Cada imagen o *box* que descarguemos pesará medio GB así que puede llegar a pesar mucho y preferimos dejar este tipo de *bloat* fuera de `/home`.

<!-- Primero descargamos el script y lo guardamos como `~/vagrant_vbox_env.sh`. Si hemos clonado el repositorio también podríamos copiarlo o hacer un symlink en local.

```bash
curl -so ~/vagrant_vbox_env.sh \
    https://raw.githubusercontent.com/pabloqpacin/devops-101/main/vagrant/vagrant_vbox_env_sh
``` -->

2. Queremos almacenar las VMs en la **partición** `/dev/sdb2` montada como `/media/$USER/LAB` de forma persistente. Igualmente verificamos que la partición está montada y si no es así se intenta mediante con el comando `gio mount -d /dev/sdb2`. Desafortunadamente este comando requiere iniciar la sesión gráfica de escritorio tipo Gnome, Cosmic..., por eso la persistencia.

3. Finalmente, revisamos y definimos el directorio donde **VirtualBox** almacenará por defecto las VMs. 

```bash
# VBoxManage list systemproperties | grep "Default machine folder" 
VBoxManage setproperty machinefolder /media/$USER/LAB/VBox
```

Hacemos que la shell (*zsh* o *bash*) ejecute nuestro script verificador al iniciarse.

```bash
echo -e "\nsource ~/devops_101/scripts/vagrant_vbox_env.sh" >> ~/.zshrc || \
echo -e "\nsource ~/devops_101/scripts/vagrant_vbox_env.sh" >> ~/.bashrc
```

Con todo preparado, podemos iniciar una nueva shell e instalar los plugins necesarios para este proyecto.

```bash
# watch tree $VAGRANT_HOME

vagrant plugin update
vagrant plugin install vagrant-vbguest
# vagrant plugin install vagrant-share vagrant-disksize
vagrant plugin list
```


#### 1.3 Implementación del `Vagrantfile`

Nos vamos al directorio `vagrant` de nuestro repositorio.

```bash
cd ~/devops_101/vagrant
```

Repasamos [nuestro `Vagrantfile`](/vagrant/Vagrantfile).

```Vagrantfile
Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/jammy64"
    config.vm.hostname = "vagrant-ubuntu-2204"

    config.vm.network "public_network", bridge: "enp2s0"

    config.vbguest.auto_update = false

    config.vm.provider "virtualbox" do |vb|
        vb.name = "vagrant-ubuntu-2204"
        vb.memory = "2048"
        vb.cpus = 2
    end

    config.vm.synced_folder ".", "vagrant", disabled: true

    config.vm.provision "ansible" do |ansible|
        ansible.playbook = "../ansible/site.yml"
        ansible.compatibility_mode = "2.0"
    end

end
```

<!-- - [ ] ¿Guardar VM en grupo de VBox? -->
<!-- - [ ] `config.disksize.size = '50GB'` -->
<!-- - [ ] ¿Desactivar primera interfaz NAT? -->
<!-- - [ ] Asignar interfaz a red NAT -->

Verificamos que el `Vagrantfile` está correcto, iniciamos y verificamos la implantación.

> **NOTA**: el comando `vagrant` solo tiene en cuenta las VMs asociadas al `Vagrantfile` del directorio actual en la shell (`pwd`).


```bash
# vagrant list-commands
vagrant validate
vagrant up
# vagrant up --debug
vagrant status
```

Podemos ejecutar comandos en la VM y conectarnos a la nueva VM. Podemos detener/apagar la VM, y eliminarla. También podemos verificar las imágenes/*boxes*.

```bash
vagrant ssh -c "sudo apt update && sudo apt install neofetch --no-install-recommends && neofetch"
# vagrant ssh

vagrant halt
# vagrant destroy

vagrant box list
```

> **NOTA**: si abrimos la GUI de VirtualBox podremos ver las nuevas VMs y es posible conectarse a ellas. Para el login, el usuario y la contraseña son `vagrant`.


#### 1.4 Ansible: `site.yml`

Con **Ansible** ya instalado, nos aseguramos de que nuestro `Vagrantfile` contiene estas líneas:

```Vagrantfile
config.vm.provision "ansible" do |ansible|
    ansible.playbook = "../ansible/site.yml"
    ansible.compatibility_mode = "2.0"
end
```

Este código cargará nuestro *playbook* (archivo de configuración) de Ansible principal para este proyecto. Será necesario ir modificando este archivo `site.yml` para implementar cosas. El resto de esta documentación/proyecto tratará en detalle el resto de archivos `.yml` y las operaciones con Ansible.

Este sería nuestro `site.yml` actualmente.

```yaml
---
- name: Provision VM
  hosts: all
  become: true
  become_method: sudo
  remote_user: ubuntu
  tasks:
    #  - import_tasks: chapter2/pam_pwquality.yml
    #  - import_tasks: chapter2/user_and_group.yml
    #  - import_tasks: chapter3/authorized_keys.yml
    #  - import_tasks: chapter3/two_factor.yml
    #  - import_tasks: chapter4/web_application.yml
    #  - import_tasks: chapter4/sudoers.yml
    #  - import_tasks: chapter5/firewall.yml
  handlers:
    #  - import_tasks: handlers/restart_ssh.yml
```

Al levantar la VM con **Vagrant**, se ejecutará este *playbook* con éxito, si bien al no tener tareas específicas (los *playbooks* que las llevarán a cabo están comentados) no se hará ningún *provisioning* en la VM.

> Decidimos que los archivos sean `.yml` y no `.yaml` por seguir el estilo de la documentación oficial (eg. [Ansible YAML file syntax and structure](https://developers.redhat.com/learning/learn:ansible:yaml-essentials-ansible/resource/resources:ansible-yaml-file-syntax-and-structure)), además de que es el estilo propuesto en el libro. Igualmente cambiamos la línea `become: yes` por `become: true`.


#### 1.5 (Ch. 2) Ansible: usuarios, grupos y contraseñas

Iremos creando los archivos `.yml` con las tareas en el directorio `ansible/chapter2/`. Para operar con ellos habrá que descomentar las líneas relevantes en `ansible/site.yml`.

Si la VM ya existe (ya hicimos `vagrant up`) usaremos este comando para aplicar **Ansible** <!--según se define en nuestro `Vagrantfile`-->.

```bash
# vagrant up
vagrant provision
# vagrant provision --debug
```


##### `pam_pwquality.yml`

En esta primera tarea se instala el paquete `libpam-pwquality` y se edita el archivo de configuración `/etc/pam.d/common-password` para imponer las siguientes restricciones en la creación de contraseñas:

- Un mínimo de 12 caracteres
- Una letra minúscula
- Una letra mayúscula
- Un caracter numérico
- Un caracter no alfanumérico
- Tres intentos
- Desactivar invalidación de root

```yaml
---
- name: Install libpam-pwquality
  package:
    name: "libpam-pwquality"
    state: present

- name: Configure pam_pwquality
  lineinfile:
    path: "/etc/pam.d/common-password"
    regexp: "pam_pwquality.so"
    line: "password required pam_pwquality.so minlen=12 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1 retry=3 enforce_for_root"
    state: present

    #- name: Limit Password Reuse
    #  lineinfile:
    #    dest: "/etc/pam.d/common-password"
    #    regexp: "remember=5"
    #    line: "password sufficient pam_unix.so use_authtok remember=5"
    #    state: present
```

<!-- - [ ] ¿Cómo se instala? Supongo que `apt install foo` pero bueno, en otros casos podría ser `snap install bar`... -->

##### `user_and_group.yml`

> **IMPORTANTE**: es insecuro tener contraseñas o llaves en un repo público. Implementar [**Ansible Vault**](https://docs.ansible.com/ansible/latest/vault_guide/index.html)... <!--https://docs.ansible.com/ansible/2.9/user_guide/vault.html-->


En nuestra máquina (no la VM) vamos a necesitar los programas `pwgen` para generar contraseñas seguras y `mkpasswd` para generar los *hashes* de estas contraseñas. Escribiremos el *hash* en el siguiente archivo `.yml`. <!--Aunque la contraseña no nos hace falta, podemos guardarla en nuestro **gestor de contraseñas** favorito, KeePassXC.-->

```bash
sudo apt update
sudo apt install pwgen whois

pass=$(pwgen --secure --capitalize --numerals --symbols 12 1)

echo $pass | mkpasswd --stdin --method=sha-512; echo $pass
    # $6$QJmzvbMhlt7C.qOO$uSkIZs/nINf2HFR/.nerO3qfRzIOR53BwZVwJspkkKdrO1KLOzIcW7hG7UWAhGTh/VJVvxhbZO7qloGqGs30E/
    # ]aR8WG{/yqG}
```


Este es el archivo, y con estas tareas conseguimos lo siguiente:

- crear el grupo *developers*
- crear el usuario *bender*
- añadir a *bender* al grupo *developers*
- crear el directorio `/opt/engineering`
- crear un archivo en el nuevo directorio

```yaml
- name: Ensure group 'developers' exists
  group:
    name: developers
    state: present

- name: Create the user 'bender'
  user:
    name: bender
    shell: /bin/bash
    password: $6$QJmzvbMhlt7C.qOO$uSkIZs/nINf2HFR/.nerO3qfRzIOR53BwZVwJspkkKdrO1KLOzIcW7hG7UWAhGTh/VJVvxhbZO7qloGqGs30E/

- name: Assign 'bender' to the 'developers' group
  user:
    name: bender
    groups: developers
    append: yes

- name: Create a directory named 'engineering'
  file:
    path: /opt/engineering
    state: directory
    mode: 0750
    group: developers

- name: Create a file in the engineering directory
  file:
    path: "/opt/engineering/private.txt"
    state: touch
    mode: 0770
    group: developers
```

<!-- - [ ] en principio solo local, ¿y en carpeta compartida (tema Vagrant)? -->

Este es un buen momento para editar el `site.yml` y ejecutar `vagrant provision`.

##### Demo: usuarios y permisos

Nos logueamos en la VM. Nuestro usuario debería ser `vagrant`.

```bash
cd ~/devops_101/vagrant
# vagrant ssh -c "whoami"
vagrant ssh
```

Verificamos que existen el usuario *bender* y el grupo *developers*.

```bash
getent passwd bender
    # bender:x:1002:1003::/home/bender:/bin/bash

getent group developers bender
    # developers:x:1002:bender
    # bender:x:1003:
```

Para el archivo, primero comprobamos que *vagrant* no tiene acceso, luego nos logueamos como *bender* y comprobamos que tenemos acceso.

```bash
ls -la /opt/engineering/
    # ls: cannot open directory '/opt/engineering/': Permission denied

# su bender
    # ]aR8WG{/yqG}

sudo su - bender

# groups
    # bender developers

ls -la /opt/engineering/
    # drwxr-x--- 2 root developers 4096 Jul  6 14:54 .
    # drwxr-xr-x 3 root root       4096 Jul  6 14:54 ..
    # -rwxrwx--- 1 root developers    4 Jul  6 15:07 private.txt
```

#### 1.6 (Ch. 3) Ansible: ssh and 2FA

Para el usuario *bender* de nuestra VM. Desactivaremos el acceso por ssh con contraseña y habilitaremos 2FA con **llaves ssh** y *google authenticator*.

##### Generar claves ssh y `authorized_keys.yml`

En nuestra máquina de operaciones generamos nuevas claves **ssh** (privada y pública). El siguiente comando nos pedirá una *passphrase*, que debemos guardar en un gestor de contraseñas o similar.

```bash
ssh-keygen -t rsa -f ~/.ssh/dftd -C dftd

# read -p "Passphrase para las llaves 'dftd': " passphrase
# ssh-keygen -t rsa -f ~/.ssh/dftd -C dftd -N "$passphrase"
```

Ahora podemos editar nuestro `site.yml` para incluir el archivo `ansible/chapter3/authorized_keys.yml`.

```yaml
---
- name: Set authorized key file from local user
  authorized_key:
    user: bender 
    state: present
    key: "{{ lookup('file', lookup('env','HOME') + '/.ssh/dftd.pub') }}"
```


##### `two_factor.yml` y `google_authenticator`

<!--
For this example, you’ll use a *time-based one-time password (TOTP)* to
satisfy the “something you have” portion, along with your public key for
access. You’ll use the `Google Authenticator` package to configure your VM to
use TOTP tokens for logging in. These TOTP tokens are usually generated
from an application like `oathtool` (*https://www.nongnu.org/oath-toolkit/*) and
are valid for only a short period of time. I have taken the liberty of creating
10 TOTP tokens that Ansible will use for you, but I will also show you how
to use oathtool (more on this later).
-->

El segundo factor de autenticación va a ser **TOTP** (*Time-based one-time password*) mediante `GoogleAuthenticator`. Lo ideal sería, teniendo preparada la app de Android **Google Authenticator**, acceder como *bender* a la VM tras instalar el paquete `libpam-google-authenticate` (1ª tarea a continuación), ejecutarlo de la siguiente forma, escanear el QR con el móvil e introducir en la terminal el código que salga en la app.

```bash
google-authenticator -f -t -d -r 3 -R 30 -w 17 -e 10
    # Warning: pasting the following URL into your browser exposes the OTP secret to Google:
    #   https://www.google.com/chart?chs=200x200&chld=M|0&cht=qr&chl=otpauth://totp/vagrant@vagrant-ubuntu-2204%3Fsecret%3DX5AH<...>JT7Q%26issuer%3Dvagrant-ubuntu-2204
    # <QR>
    # Your new secret key is: X5AH<...>JT7Q
    # Enter code from app (-1 to skip): 972935

    # Code confirmed
    # Your emergency scratch codes are:
    #   11880927
    #   35111193
    #   32810950
    #   87502136
    #   81456931
    #   79721071
    #   31977925
    #   28440037
    #   12366122
    #   65260038
```

Al completarse el proceso, se crea el archivo `~/.google_authenticator`. En este caso en lugar de generar todo esto, vamos a copiar un archivo proporcionado por el autor del **libro** (2ª tarea). Habrá que revisar esto, tema `oathtool` etc.

> **IMPORTANTE**: de nuevo, no hay seguridad si publicamos en internet los tokens y las llaves secretas; lo suyo sería usar ***Ansible Vault***, [*HashiCorp's Vault*](https://www.vaultproject.io/) o algo similar.


En definitiva, el archivo `.yml` de este apartado cumplirá los siguientes objetivos:
1. Instalar `libpam-google-authenticate`
2. Copiar un archivo de configuración de `GoogleAuthenticator` <!--OJO-->
3. Desactivar el login por contraseña para **ssh** (mediante *PAM*)
4. Configurar *PAM* para usar `GoogleAuthenticator` para el login de *bender* por **ssh**
5. Activar `ChallengeResponseAuthentication` en el `sshd_config`
6. Configurar Método de Autenticación para *bender*, *vagrant* y *ubuntu*
7. Incluir handler "Restart SSH Server"

<!-- > **NOTA**: diferencias frente al repo del autor: en el `Vagrantfile` hemos cambiado la *box* `focal64` por `jammy64`, Ubuntu 20.04 y 22.04 respectivamente. Esto ha supuesto que el paquete `ssh` tenga una versión más reciente y un **conclicto**, así que para la tarea *Set ChallengeResponseAuthentication to Yes* fue necesario cambiar la línea. -->

```yaml
- name: Install the libpam-google-authenticator package
  apt:
    name: "libpam-google-authenticator"
    update_cache: yes
    state: present

- name: Copy over Preconfigured GoogleAuthenticator config
  copy:
    src: ../ansible/chapter3/google_authenticator
    dest: /home/bender/.google_authenticator
    owner: bender
    group: bender
    mode: '0600'
  no_log: true

- name: Disable password authentication for SSH
  lineinfile:
    dest: "/etc/pam.d/sshd"
    regex: "@include common-auth"
    line: "#@include common-auth"

- name: Configure PAM to use GoogleAuthenticator for SSH logins
  ansible.builtin.blockinfile:
    path: "/etc/pam.d/sshd"
    prepend_newline: true
    insertafter: EOF
    block: |
        auth required pam_google_authenticator.so nullok"

- name: Set ChallengeResponseAuthentication to Yes
  lineinfile:
    dest: "/etc/ssh/sshd_config"
    regexp: "^KbdInteractiveAuthentication (yes|no)"
    line: "KbdInteractiveAuthentication yes"
    state: present

- name: Set Authentication Methods for bender, vagrant, and ubuntu
  blockinfile:
    path: "/etc/ssh/sshd_config"
    block: |
      Match User "ubuntu,vagrant"
          AuthenticationMethods publickey
      Match User "bender,!vagrant,!ubuntu"
          AuthenticationMethods publickey,keyboard-interactive
    state: present
  notify: "Restart SSH Server"
```

<!--
4ª (Configure PAM to use GoogleAuthenticator for SSH logins)

This task tells PAM about the Google Authenticator module. It uses the
Ansible lineinfile module again to edit the PAM sshd file. This time, you
just want to add the auth line to the bottom of the PAM file, which lets PAM
know it should use Google Authenticator as an authentication mechanism.
The nullok option at the end of the line tells PAM that this authentication
method is optional, which allows you to avoid locking out users until they
have successfully configured 2FA. In a production environment, you should
remove the nullok option once all users have enabled 2FA.
-->

<!-- 5ª -->
<!-- 6ª -->
<!-- 7ª -->

<!-- oathtool -->

> **OJO**: Ansible *handlers*...

Ahora deberíamos conectarnos a la VM como *bender* y se nos pedirá tanto la *passphrase* de nuestra llave **ssh** y  los tokens de *Google Authenticator* (al usar uno, se elimina automáticamente de `~/.google_authenticator`).


```bash
# # Tener en cuenta el puerto si hay varias VMs funcionando
# vagrant ssh-config
# PORT=$(vagrant ssh-config | grep 'Port' | awk '{print $2}')

# Conexión a la VM
ssh -i ~/.ssh/dftd -p 2222 bender@localhost

# # Si hay problemas
# vagrant ssh
# less /var/log/auth.log
# less /var/log/syslog
```

- [ ] Revisar el tema para hacerlo TOTP, incluso compatible con Android apps
- [ ] Curiosamente todavía podemos acceder con `vagrant ssh`... ¿No deberíamos caparlo?


#### 1.7 (Ch. 4) Webapp & sudoers (con Jinja)


##### `web_application.yml`, `greeting.service`, `greeting.py` y `wsgi.py`

- [ ] Why Nginx tho? Is it so that UFW can block connection attempts?

```yaml
---
- name: Install python3-flask, gunicorn3, and nginx
  apt:
    name:
      - python3-flask
      - gunicorn
      - nginx
    update_cache: yes

- name: Copy Flask Sample Application
  copy:
    src: "../ansible/chapter4/{{ item }}"
    dest: "/opt/engineering/{{ item }}"
    group: developers
    mode: '0750'
  loop:
    - greeting.py
    - wsgi.py

- name: Copy systemd Unit file for Greeting
  copy:
    src: "../ansible/chapter4/greeting.service"
    dest: "/etc/systemd/system/greeting.service"

- name: Start and enable Greeting Application
  systemd:
    name: greeting.service
    daemon_reload: yes
    state: started
    enabled: yes
```

##### `sudoers.yml` y `templates/developers.j2` (Jinja2)

```yaml
---
- set_fact:
    greeting_application_file: "/opt/engineering/greeting.py"

- name: Create sudoers file for developers group
  template:
    src: "../ansible/templates/developers.j2"
    dest: "/etc/sudoers.d/developers"
    validate: 'visudo -cf %s'
    owner: root
    group: root
    mode: 0440
```

```j2
# Command alias
Cmnd_Alias	START_GREETING    = /bin/systemctl start greeting , \
				    /bin/systemctl start greeting.service
Cmnd_Alias	STOP_GREETING     = /bin/systemctl stop greeting , \
				    /bin/systemctl stop greeting.service
Cmnd_Alias	RESTART_GREETING  = /bin/systemctl restart greeting , \
				    /bin/systemctl restart greeting.service

# Host Alias
Host_Alias      LOCAL_VM = {{ hostvars[inventory_hostname]['ansible_default_ipv4']['address'] }}
# User specification
%developers LOCAL_VM = (root) NOPASSWD: START_GREETING, STOP_GREETING, \
	    	       RESTART_GREETING, \
		       sudoedit {{ greeting_application_file }}

```

##### *Provisioning the VM*

```bash
vagrant provision

ssh -i ~/.ssh/dftd -p 2222 bender@localhost
```
```bash
curl http://localhost:5000

# # NO usar sudo, pide contraseña...
# sed -i 's/Greetings/Greetings and Salutations/' /opt/engineering/greeting.py

# Usamos sudoedit, según /etc/sudoers.d/developers
sudoedit /opt/engineering/greeting.py

sudo systemctl restart greeting
# sudo systemctl stop greeting
# curl -w "\n" http://localhost:5000
# sudo systemctl start greeting
curl -w "\n" http://localhost:5000

# No podremos, y ahora lo veremos revisando el propio log
sudo tail -f /var/log/auth.log
```

Para revisar los logs nos logueamos como *vagrant*. 

```bash
vagrant ssh

# less /var/log/auth.log
grep 'sudo' /var/log/auth.log | grep 'bender' | grep 'COMMAND'
```



#### 1.8 (Ch. 5)  `ufw` firewall

##### `firewall.yml`

- Whitelisting.

```yaml
---

- name: Turn Logging level to low
  ufw:
    logging: 'low'

- name: Allow SSH over port 22
  ufw:
    rule: allow
    port: '22'
    proto: tcp

- name: Allow all access to port 5000
  ufw:
    rule: allow
    port: '5000'
    proto: tcp

- name: Rate limit excessive abuse on port 5000
  ufw:
    rule: limit
    port: '5000'
    proto: tcp


- name: Drop all other traffic
  ufw:
    state: enabled
    policy: deny
    direction: incoming
```

```bash
vagrant provision && vagrant ssh
sudo sed -i 's/hitcount 6/hitcount 10/' /etc/ufw/user.rules

VM_IP=$(ip -4 -br a | tail -n 1 | awk '{print $3}')
  # 192.168.1.43/24
```

Desde un pc real de la red real escaneamos la VM:


```bash
nmap -F 192.168.1.43
  # Host seems down

nmap -Pn 192.168.1.43
  # Ports 22 & 5000

nmap -Pn -sV 192.168.1.43
  # OpenSSH 8.9
  # upnp?

for i in {1..6} ; do curl -w "\n" http://192.168.1.43:5000 ; done
  # A la sexta, Connection refused
```

Volvemos a loguearnos como admin para revisar logs:

```bash
vagrant ssh

sudo less /var/log/ufw.log
```


### Proyecto 2. Docker (en *Minikube*), Kubernetes y CI/CD pipelines

##### 2.1 (Ch. 6) Instalación de minikube y docker-client

En la misma máquina EX2511.

Valores por defecto de `minikube start`: `--cpus=2 --memory='3900m' --disk-size='20g'`


```bash
cd /tmp
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
# sudo dpkg -i minikube_latest_amd64.deb
cd -
```

Necesario iniciar minikube cada vez que queramos usarlo...

```bash
# minikube start --driver=virtualbox
minikube start
```
<!--
```log
pabloqpacin@pop-os ~$ minikube start
* minikube v1.33.1 on Debian bookworm/sid
* Automatically selected the virtualbox driver. Other choices: none, ssh
* Downloading VM boot image ...
    > minikube-v1.33.1-amd64.iso....:  65 B / 65 B [---------] 100.00% ? p/s 0s
    > minikube-v1.33.1-amd64.iso:  314.16 MiB / 314.16 MiB  100.00% 41.96 MiB p
* Starting "minikube" primary control-plane node in "minikube" cluster
* Downloading Kubernetes v1.30.0 preload ...
    > preloaded-images-k8s-v18-v1...:  342.90 MiB / 342.90 MiB  100.00% 38.13 M
* Creating virtualbox VM (CPUs=2, Memory=3900MB, Disk=20000MB) ...
* Preparing Kubernetes v1.30.0 on Docker 26.0.2 ...
  - Generating certificates and keys ...
  - Booting up control plane ...
  - Configuring RBAC rules ...
* Configuring bridge CNI (Container Networking Interface) ...
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: default-storageclass, storage-provisioner
* kubectl not found. If you need it, try: 'minikube kubectl -- get pods -A'
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```
 -->

```bash
sudo apt install docker-ce-cli

echo "eval $(minikube -p minikube docker-env)" >> ~/.zshrc || \
echo "eval $(minikube -p minikube docker-env)" >> ~/.bashrc

docker version
```

##### 2.2 Imagen Docker de aplicación `telnet-server`

Contenido del directorio `telnet-server/`:

```log
*[main][~/devops_101]$ tree telnet-server
 devops_101/telnet-server
├──  container-tests
│  └──  command-and-metadata-test.yaml
├──  kubernetes
│  ├──  deployment.yaml
│  └──  service.yaml
├──  metrics
│  └──  server.go
├──  telnet
│  ├──  banner.go
│  ├──  server.go
│  └──  server_test.go
├──  build.sh
├──  Dockerfile
├──  go.mod
├──  go.sum
├──  main.go
└──  skaffold.yaml
```

Dockerfile para ***multistage** build*:

```dockerfile
# Build stage
FROM golang:alpine AS build-env
ADD . /
RUN cd / && go build -o telnet-server

# final stage
FROM alpine:latest as final
WORKDIR /app
ENV TELNET_PORT 2323
ENV METRIC_PORT 9000
COPY --from=build-env /telnet-server /app/

ENTRYPOINT ["./telnet-server"]
```

Comandos para crear la imagen y ejecutar un contenedor:

```bash
# Crear la imagen
docker build -t dftd/telnet-server:v1 .

docker image ls dftd/telnet-server:v1
docker history dftd/telnet-server:v1

# Ejecutar contenedor (instancia de la imagen)
docker run -d --name telnet-server -p 2323:2323 dftd/telnet-server:v1
# docker container ls -f name=telnet-server
docker ps -f name=telnet-server
```

Otros comandos `docker` importantes:

```bash
docker exec telnet-server env
docker exec -it telnet-server /bin/sh

docker inspect telnet-server
  # State
  # NetworkSettings

docker stats --no-stream dftd/telnet-server
```

##### 2.3 Demo de aplicación `telnet-server` (en Docker), revisión de logs

Instalamos el cliente `telnet` si es necesario e iniciamos `minikube` y el contenedor si hemos apagado la máquina.

```bash
sudo apt install telnet

minikube start

docker ps -f name=telnet-server
docker start telnet-server
docker ps -f name=telnet-server
```

Nos conectamos al servidor telnet del contenedor.

```log
[pabloqpacin:~]$ telnet $(minikube ip) 2323
Trying 192.168.59.100...
Connected to 192.168.59.100.
Escape character is '^]'.

____________ ___________
|  _  \  ___|_   _|  _  \
| | | | |_    | | | | | |
| | | |  _|   | | | | | |
| |/ /| |     | | | |/ /
|___/ \_|     \_/ |___/

>d
Fri Jul 12 16:13:34 +0000 UTC 2024
>q
Good Bye!
Connection closed by foreign host.
[pabloqpacin:~]$
```

Revisamos los logs.

```logs
~ ᐅ docker logs telnet-server
telnet-server: 2024/07/11 18:44:41 telnet-server listening on [::]:2323
telnet-server: 2024/07/11 18:44:41 Metrics endpoint listening on :9000
telnet-server: 2024/07/12 16:10:42 Metrics endpoint listening on :9000
telnet-server: 2024/07/12 16:10:42 telnet-server listening on [::]:2323
telnet-server: 2024/07/12 16:11:45 [IP=192.168.59.1] New session
telnet-server: 2024/07/12 16:13:34 [IP=192.168.59.1] Requested command: d
telnet-server: 2024/07/12 16:13:37 [IP=192.168.59.1] User quit session

~ ᐅ docker logs --tail=2 telnet-server
~ ᐅ docker logs -f telnet-server
```


##### 2.4 (Ch. 7) Kubernetes: `deployment.yaml` y `service.yaml`


<details>
<summary>Archivos .yaml</summary>

`deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: telnet-server
  labels:
    app: telnet-server
spec:
  replicas: 2
  selector:
    matchLabels:
      app: telnet-server
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # how many pods we can add at a time
      maxUnavailable: 0  # maxUnavailable define how many pods can be unavailable
  template:
    metadata:
      labels:
        app: telnet-server
      annotations:
        prometheus.io/scrape: 'true'
        prometheus.io/port:   '9000'
    spec:
      containers:
      - image: dftd/telnet-server:v1
        imagePullPolicy: IfNotPresent
        name: telnet-server
        resources:
          requests:
            cpu: 0.1
            memory: 1M
          limits:
            cpu: 0.5
            memory: 100M
        ports:
        - containerPort: 2323
          name: telnet
        - containerPort: 9000
          name: metrics
```

`service.yaml`:

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: telnet-server
  labels:
    app: telnet-server
spec:
  ports:
  - port: 2323
    name: telnet
    protocol: TCP
    targetPort: 2323
  selector:
    app: telnet-server
  type: LoadBalancer
---
apiVersion: v1
kind: Service
metadata:
  name: telnet-server-metrics
  labels:
    app: telnet-server
  annotations:
      prometheus.io/scrape: 'true'
      prometheus.io/port:   '9000'

spec:
  ports:
  - name: metrics
    port: 9000
    protocol: TCP
    targetPort: 9000
  selector:
    app: telnet-server
  type: ClusterIP
```

</details>


Puesta en marcha:

```bash
# minikube start

minikube kubectl cluster-info
  # Kubernetes control plane is running at https://192.168.59.100:8443
  # CoreDNS is running at https://192.168.59.100:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
  # To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

minikube kubectl -- explain deployment.metadata.labels
```
```bash
minikube kubectl -- apply -f telnet-server/kubernetes/

minikube kubectl -- get deployments.apps telnet-server
minikube kubectl -- get pods -l app=telnet-server

minikube kubectl -- get services -l app=telnet-server
```

```bash
minikube tunnel
  # ...

minikube kubectl -- get services telnet-server
  # OJO con EXTERNAL-IP (10.105.23.82)

telnet 10.105.23.82 2323
  # d
  # q

# minikube kubectl -- get endpoints -l app=telnet-server
```

```bash
minikube kubectl -- get pods -l app=telnet-server
minikube kubectl -- delete pod <telnet-server-775769766-2bmd5>
minikube kubectl -- get pods -l app=telnet-server
```

```bash
# Para **escalar**: modificar los archivos bajo control de versiones y comando `apply`. Igualmente así se hace por comandos, pero mejor evitar esta práctica:
minikube kubectl -- scale deployment telnet-server --replicas=3
```

```bash
minikube kubectl -- logs
minikube kubectl -- logs -l app=telnet-server --all-containers=true --prefix=true
```


##### 2.5 (Ch. 8) Desplegando y testeando código (Skaffold CI/CD)

Primero instalamos **Skaffold**, **container-structure-test** y **Go**:

```bash
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
sudo install skaffold /usr/local/bin/

curl -LO https://github.com/GoogleContainerTools/container-structure-test/releases/latest/download/container-structure-test-linux-amd64 && \
chmod +x container-structure-test-linux-amd64 && \
sudo mv container-structure-test-linux-amd64 /usr/local/bin/container-structure-test

sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz
if echo $PATH | grep -qv /usr/local/go/bin; then
    echo -e "\nexport PATH=$PATH:/usr/local/go/bin" ~/.zshrc || \
    echo -e "\nexport PATH=$PATH:/usr/local/go/bin" ~/.bashrc
fi
```

Revisamos el archivo `telnet-server/skaffold.yaml`:

```yaml
apiVersion: skaffold/v2beta19
kind: Config
build:
  local: {}
  artifacts:
  - image: dftd/telnet-server
test:
- image: dftd/telnet-server
  custom:
  - command: go test ./... -v
  structureTests:
  - ./container-tests/command-and-metadata-test.yaml
deploy:
  kubectl:
    manifests:
    - kubernetes/*
```

Revisamos `telnet-server/container-tests/command-and-metadata-test.yaml`:

```yaml
schemaVersion: 2.0.0
commandTests:
  - name: "telnet-server"
    command: "./telnet-server"
    args: ["-i"]
    expectedOutput: ["telnet port :2323\nMetrics Port: :9000"]
metadataTest:
  envVars:
    - key: TELNET_PORT
      value: 2323
    - key: METRIC_PORT
      value: 9000
  entrypoint: ["./telnet-server"]
  workdir: "/app"
```

<!-- build.sh -->

Ponemos las herramientas a prueba:

```bash
cd telnet-server
skaffold dev --cleanup=false
  # Dejar la terminal abierta
```

<!--
```log
[telnet-server] skaffold dev --cleanup=false                                                              devel  ✱
Generating tags...
 - dftd/telnet-server -> dftd/telnet-server:064aa01-dirty
Checking cache...
 - dftd/telnet-server: Not found. Building
Starting build...
Found [minikube] context, using local docker daemon.
Building [dftd/telnet-server]...
Target platforms: [linux/amd64]
Sending build context to Docker daemon   29.7kB
Step 1/9 : FROM golang:alpine AS build-env
alpine: Pulling from library/golang
ec99f8b99825: Already exists
8bfb7f89ddd5: Already exists
32a2f51ff3dd: Already exists
935834aa092a: Already exists
4f4fb700ef54: Already exists
Digest: sha256:8c9183f715b0b4eca05b8b3dbf59766aaedb41ec07477b132ee2891ac0110a07
Status: Downloaded newer image for golang:alpine
 ... a60a31a97fdb
Step 2/9 : ADD . /
 ... 38b276ee5b5e
Step 3/9 : RUN cd / && go build -o telnet-server
 ... Running in cbcf9236a84d
go: downloading github.com/prometheus/client_golang v1.6.0
go: downloading github.com/beorn7/perks v1.0.1
go: downloading github.com/cespare/xxhash/v2 v2.1.1
go: downloading github.com/golang/protobuf v1.4.0
go: downloading github.com/prometheus/client_model v0.2.0
go: downloading github.com/prometheus/common v0.9.1
go: downloading github.com/prometheus/procfs v0.0.11
go: downloading google.golang.org/protobuf v1.21.0
go: downloading github.com/matttproud/golang_protobuf_extensions v1.0.1
go: downloading golang.org/x/sys v0.0.0-20200420163511-1957bb5e6d1f
 ... 3eab8907fb04
Step 4/9 : FROM alpine:latest as final
latest: Pulling from library/alpine
ec99f8b99825: Already exists
Digest: sha256:b89d9c93e9ed3597455c90a0b88a8bbb5cb7188438f70953fede212a0c4394e0
Status: Downloaded newer image for alpine:latest
 ... a606584aa9aa
Step 5/9 : WORKDIR /app
 ... Running in a78041e13836
 ... a5800a1d2290
Step 6/9 : ENV TELNET_PORT 2323
 ... Running in 8f25e7e7e30d
 ... 3480f217d941
Step 7/9 : ENV METRIC_PORT 9000
 ... Running in 74bf178e922a
 ... 1545c2369c8b
Step 8/9 : COPY --from=build-env /telnet-server /app/
 ... 5ff7451e75f3
Step 9/9 : ENTRYPOINT ["./telnet-server"]
 ... Running in 2d72c86cd620
 ... f64eee4f97d7
Successfully built f64eee4f97d7
Successfully tagged dftd/telnet-server:064aa01-dirty
Build [dftd/telnet-server] succeeded
Starting test...
Testing images...

=======================================================
====== Test file: command-and-metadata-test.yaml ======
=======================================================
=== RUN: Command Test: telnet-server
--- PASS
duration: 383.16803ms
stdout: telnet port :2323
Metrics Port: :9000

=== RUN: Metadata Test
--- PASS
duration: 0s

=======================================================
======================= RESULTS =======================
=======================================================
Passes:      2
Failures:    0
Duration:    383.16803ms
Total tests: 2

PASS
Running custom test command: "go test ./... -v"
go: downloading github.com/stretchr/testify v1.4.0
go: downloading github.com/davecgh/go-spew v1.1.1
go: downloading github.com/stretchr/objx v0.1.1
go: downloading gopkg.in/yaml.v2 v2.2.8
go: downloading github.com/pmezard/go-difflib v1.0.0
?       telnet-server   [no test files]
?       telnet-server/metrics   [no test files]
=== RUN   TestServerRun
Mocked charge notification function
    server_test.go:23: PASS:    Run()
--- PASS: TestServerRun (0.00s)
PASS
ok      telnet-server/telnet    0.006s
Command finished successfully.
Tags used in deployment:
 - dftd/telnet-server -> dftd/telnet-server:f64eee4f97d7a6e0c3dcd6daf4d6b103ea1d50e34eebfdaf5c192fd34e3d4f88
Starting deploy...
 - deployment.apps/telnet-server configured
 - service/telnet-server configured
 - service/telnet-server-metrics configured
Waiting for deployments to stabilize...
 - deployment/telnet-server is ready.
Deployments stabilized in 3.122 seconds
Listing files to watch...
 - dftd/telnet-server
Press Ctrl+C to exit
Watching for changes...
[telnet-server] telnet-server: 2024/07/18 15:15:04 Metrics endpoint listening on :9000
[telnet-server] telnet-server: 2024/07/18 15:15:04 telnet-server listening on [::]:2323
[telnet-server] telnet-server: 2024/07/18 15:15:06 telnet-server listening on [::]:2323
[telnet-server] telnet-server: 2024/07/18 15:15:06 Metrics endpoint listening on :9000
```
-->

Hacemos cambios en el código:

```bash
sed -i 's/colorGreen, b/colorYellow, b/' telnet-server/telnet/banner.go

kubectl get services telnet-server
  # 10.105.23.82 (EXTERNAL-IP)

telnet 10.105.23.82 2323

# AHORA SALE AMARILLO, se han actualizado los pods
```

Kubernetes rollout...

```bash
kubectl rollout history deployment
# kubectl rollout undo deployment telnet-server --to-revision=1
```






<!-- ##### 2.4 (Ch. 7) Kubernetes... -->


<!-- ### Proyecto 2. Terraform -->
<!-- ### Proyecto 3. Kubernetes + CI/CD -->
