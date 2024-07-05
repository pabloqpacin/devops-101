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

Hemos preparado [el script `vagrant_vbox_env.sh`](/vagrant/vagrant_vbox_env.sh) para realizar varias tareas importantes.

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
echo -e "\nsource ~/devops_101/vagrant/vagrant_vbox_env.sh" >> ~/.zshrc || \
echo -e "\nsource ~/devops_101/vagrant/vagrant_vbox_env.sh" >> ~/.bashrc
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

<!-- ### Proyecto 2. Terraform -->
<!-- ### Proyecto 3. Kubernetes + CI/CD -->
