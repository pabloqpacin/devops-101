# devops_101

> ***DevOps for the Desperate**. A Hands-On Survival Guide*. [Libro](https://nostarch.com/devops-desperate), [repo](https://github.com/bradleyd/devops_for_the_desperate).

- [devops\_101](#devops_101)
  - [Entornos de desarrollo y operaciones](#entornos-de-desarrollo-y-operaciones)
  - [Objetivos](#objetivos)
  - [Proyectos](#proyectos)
    - [Proyecto 1. Vagrant + Ansible](#proyecto-1-vagrant--ansible)
      - [1.1 Instalación de Vagrant y Ansible](#11-instalación-de-vagrant-y-ansible)
      - [1.2 Configuración de Vagrant y del hardware (script `vagrant_vbox_env.sh`)](#12-configuración-de-vagrant-y-del-hardware-script-vagrant_vbox_envsh)
      - [1.3 Implementación del `Vagrantfile`](#13-implementación-del-vagrantfile)


## Entornos de desarrollo y operaciones

Nuestro hardware:

| Máquina       | CPU                       | RAM   | Almacenamiento                            | OS            | ¿Multiboot?
| ---           | ---                       | ---   | ---                                       | ---           | ---
| Acer EX2511   | i5-4210U (4) @ 2.70 GHz   | 16 GB | 1x240GB SSD<br> 1x480 SSD                 | Pop!_OS 22.04 | Sí, con Arch Linux
| **MSI GL76**  | i7-11800H (16) @ 4.60 GHz | 32 GB | 1x2TB NVMe<br> 1x1TB NVMe<br> 1x1TB HDD   | Pop!_OS 22.04 | No
| **Pi 5**      | ...                       | ...   | ...                                       | ...           | No
 

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

Directamente clonamos este repo remoto en nuestra máquina de operaciones:

```bash
git clone https://github.com/pabloqpacin/devops_101.git $HOME/devops_101
```

### Proyecto 1. Vagrant + Ansible

<!-- - [ ] [/vagrant](/vagrant/)
- [ ] [/ansible](/ansible/) -->

Nuestro entorno es la máquina *Acer EX2511*. Pilota el sistema *Pop!_OS* (derivado de Ubuntu). Nos conectaremos a esta máquina desde nuestra máquina principal *MSI GL76* mediante `ssh`.

No queremos almacenar las VMs en la partición `/` (en `/dev/sdb1`) sino en otra partición (`/dev/sdb2`), que montaremos según su *label* `LAB` en el directorio `/media/$USER/LAB`. Actualmente el montaje se realiza mediante el comando `gio mount -d /dev/sdb2` que por desgracia requiere iniciar una sesión gráfica, por lo que para entornos remotos (sin GUI) habría que revisar este procedimiento de montaje.


#### 1.1 Instalación de Vagrant y Ansible

Primero de todo, instalamos **Vagrant** (Ubuntu/Debian).

<!--
```bash
install_vagrant(){
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
}

install_vagrant
```
-->

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
```

No es necesario instalar **Ansible** para operar con Vagrant, pero dado que nuestro `Vagrantfile` hace uso de Ansible, mejor instalarlo ya (Ubuntu/Debian). Si no lo instalamos, habrá que comentar las líneas relevantes del `Vagrantfile`.

```bash
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
```


#### 1.2 Configuración de Vagrant y del hardware (script `vagrant_vbox_env.sh`)

Hemos preparado [un script](/vagrant/vagrant_vbox_env.sh) que se asegura de que el hardware/almacenamiento de las VMs está montado y la variable `$VAGRANT_HOME` tiene el valor `/var/vagrant.d` (donde se almacenarán los archivos de configuración de **Vagrant**).

<!-- Primero descargamos el script y lo guardamos como `~/vagrant_vbox_env.sh`. Si hemos clonado el repositorio también podríamos copiarlo o hacer un symlink en local.

```bash
curl -so ~/vagrant_vbox_env.sh \
    https://raw.githubusercontent.com/pabloqpacin/devops-101/main/vagrant/vagrant_vbox_env_sh
``` -->


Si la configuración de hardware/particiones es distinta o simplemente queremos cambiar el directorio por defecto donde **VirtualBox** almacenará las VMs, habrá que modificar este comando del script y verificar que se monta tal directorio/partición.

```bash
# VBoxManage list systemproperties | grep "Default machine folder" 
VBoxManage setproperty machinefolder ...
```

Para aseguramos de que el script será ejecutado cada vez que iniciemos la shell, introducimos este comando que añadirá la línea `source ~/vagrant_vbox_env.sh` a nuestro `~/.zshrc` o `~/.bashrc`.

```bash
echo -e "\nsource ~/repos/devops_101/vagrant/vagrant_vbox_env.sh\n" >> ~/.zshrc || \
echo -e "\nsource ~/repos/devops_101/vagrant/vagrant_vbox_env.sh\n" >> ~/.bashrc
```

Con todo preparado, podemos iniciar una nueva shell e instalar los plugins necesarios para este proyecto.

```bash
# watch tree $VAGRANT_HOME

vagrant plugin update
vagrant plugin install vagrant-vbguest
# vagrant plugin install vagrant-share vagrant-disksize
```


#### 1.3 Implementación del `Vagrantfile`

Nos vamos al repositorio

```bash

```


<!-- ### Proyecto 2. Terraform -->
<!-- ### Proyecto 3. Kubernetes + CI/CD -->
