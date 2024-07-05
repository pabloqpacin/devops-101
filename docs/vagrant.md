# Vagrant 101

- [Vagrant 101](#vagrant-101)
  - [Objetivo](#objetivo)
  - [Notas](#notas)
    - [Almacenamiento en la máquina de oepraciones](#almacenamiento-en-la-máquina-de-oepraciones)
    - [ArchWiki: Vagrant (guía)](#archwiki-vagrant-guía)


## Objetivo

- Provisionar X VMs con X sistemas en X ubicación/entorno mediante el proveedor X.
  - [x] 1 VM -- Ubuntu 22.04 -- *Acer EX2511* (/media/pabloqpacin/LAB) -- VirtualBox
  - [ ] 1 VM -- Ubuntu 24.04 -- MSI GL76 (/media/pabloqpacin/foo) -- VirtualBox
  - [ ] 1 VM -- Arch Linux -- MSI GL76 (/media/pabloqpacin/foo) -- VirtualBox
- Hacer lo mínimo con Vagrant y realizar la configuración mediante Ansible
<!-- - [ ] Probar con otros proveedores... -->

## Notas

### Almacenamiento en la máquina de oepraciones

Plantearse y decidir donde almacenar las VMs. En mi caso, quiero que sea en `/media/pabloqpacin/LAB/VBox`.

```bash
VBoxManage list systemproperties | grep "Default machine folder"
VBoxManage setproperty machinefolder /path/to/new/location
```

<!-- 
OJO

```vagrantfile
  # First provisioning step to set the default machine folder
  config.vm.provision "shell", inline: <<-SHELL
    VBoxManage setproperty machinefolder /media/foo/VMs
  SHELL
``` -->

Otras movidas sobre el almacenamiento:

1. https://developer.hashicorp.com/vagrant/docs/disks/configuration
2. https://developer.hashicorp.com/vagrant/docs/disks/usage
3. [vagrant-disksize](https://stackoverflow.com/questions/49822594/vagrant-how-to-specify-the-disk-size) (2019)

```bash
vagrant plugin install vagrant-disksize
```
```vagrantfile
vagrant.configure('2') do |config|
    config.vm.box = 'ubuntu/xenial64'
    config.disksize.size = '50GB'
end
```

### [ArchWiki: Vagrant](https://wiki.archlinux.org/title/Vagrant) (guía)

> Best Hipervisor support: VirtualBox

1. Install the vagrant package

<!-- ```bash
# sudo pacman -Syu vagrant
    # +52 pkgs, mucho ruby

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
``` -->

2. Vagrant is configured with [environment variables](https://wiki.archlinux.org/title/Environment_variables) (eg. `$VAGRANT_HOME`).
   - [x] See the full list of options in [the official documentation](https://developer.hashicorp.com/vagrant/docs/other/environmental-variables)
<!-- <br> -->
3. [Plugins](https://www.vagrantup.com/docs/plugins/) as middleware for Hipervisors
   - [ ] Ojo: `vagrant-libvirt`, `vagrant-lxc`

