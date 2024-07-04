# Vagrant 101

- [Vagrant 101](#vagrant-101)
  - [Sobre este laboratorio](#sobre-este-laboratorio)
  - [Sobre Vagrant](#sobre-vagrant)
    - [Almacenamiento](#almacenamiento)
  - [archwiki](#archwiki)
  - [LABS](#labs)
    - [Proyecto 1](#proyecto-1)


## Sobre este laboratorio

- Provisionar X VMs con X sistemas en X ubicación/entorno mediante el proveedor X.
  - [ ] 1 VM -- Ubuntu 24.04 -- Acer EX2511 (/media/pabloqpacin/foo) -- VirtualBox
  - [ ] 1 VM -- Arch Linux -- MSI GL76 (/media/pabloqpacin/foo) -- VirtualBox
  - [ ] 1 VM -- Ubuntu 22.04 -- MSI GL76 (/media/pabloqpacin/foo) -- VirtualBox
- Hacer lo mínimo con Vagrant y realizar la configuración mediante Ansible
- [ ] Probar en otros proveedores...


## Sobre Vagrant


### Almacenamiento

La idea es decidir donde almacenar las VMs. En mi caso, quiero que sea en `/media/pabloqpacin/<particion>/<directorio>/<VM>`

```bash
VBoxManage list systemproperties | grep "Default machine folder"
VBoxManage setproperty machinefolder /path/to/new/location
```

```vagrantfile
Vagrant.configure("2") do |config|
  # Specify the base box to use
  config.vm.box = "ubuntu/bionic64"

  # First provisioning step to set the default machine folder
  config.vm.provision "shell", inline: <<-SHELL
    VBoxManage setproperty machinefolder /media/foo/VMs
  SHELL

  # Customize the VM
  config.vm.provider "virtualbox" do |vb|
    vb.name = "custom_vm_name" # Name your VM
    vb.memory = "1024"         # Allocate memory
    vb.cpus = 2                # Number of CPUs
  end
end
```


Otras movidas sobre el almacenamiento:

1. https://developer.hashicorp.com/vagrant/docs/disks/usage
2. https://developer.hashicorp.com/vagrant/docs/disks/configuration
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

## [archwiki](https://wiki.archlinux.org/title/Vagrant)

> Best Hipervisor support: VirtualBox

1. Install the vagrant package

```bash
# sudo pacman -Syu vagrant
    # +52 pkgs, mucho ruby

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant


vagrant --help
vagrant list-commands

{
    VBoxManage list systemproperties | grep "Default machine folder"
    # VBoxManage setproperty machinefolder /run/media/$USER/LAB
    VBoxManage setproperty machinefolder /media/$USER/LAB/VBox
}

```

2. Vagrant is configured with [environment variables](https://wiki.archlinux.org/title/Environment_variables).
   - [ ] See the full list of options in [the official documentation](https://developer.hashicorp.com/vagrant/docs/other/environmental-variables)

<!-- ```bash
echo -e "\nsource ~/vagrant_init.sh" >> ~/.zshrc || \
echo -e "\nsource ~/vagrant_init.sh" >> ~/.bashrc

cat <<EOF || tee ~/vagrant_init.sh
case $VAGRANT_HOME in
    '~/.vagrant.d') VAGRANT_HOME=
    'media/$USER/;;
    *) echo "Unknown state"
esac
EOF
``` -->

```bash
echo -e "\nsource ~/vagrant_env.sh" >> ~/.zshrc || \
echo -e "\nsource ~/vagrant_env.sh" >> ~/.bashrc

cat <<EOF | tee ~/vagrant_env.sh
if command -v vagrant &>/dev/null; then
    case \$VAGRANT_HOME in
        "/media/\$USER/devops-101")
            # echo "La variable VAGRANT_HOME ya es media/\$USER/devops-101"
            ;;
        '' | '~/.vagrant.d' | *)
            # export VAGRANT_HOME="/media/\$USER/devops-101/vagrant.d"
            export VAGRANT_HOME="/media/\$USER/LAB/vagrant.d"
            # echo "Variable VAGRANT_HOME cambiada"
            ;;
    esac
fi

EOF
```

3. [Plugins](https://www.vagrantup.com/docs/plugins/) as middleware for Hipervisors
   - [ ] Ojo: `vagrant-libvirt`, `vagrant-lxc`

```bash
vagrant plugin update

vagrant plugin install \
    # vagrant-share \
    vagrant-vbguest

vagrant plugin list
```

...


## LABS

### Proyecto 1

Primero preparamos nuestro host X:
- partición dedicada *foo*
- instalamos las movidas
- provisionamos las nuevas movidas


```bash
# Importante haber definido la carpeta por defecto de VirtualBox...

mkdir ~/vagrant-1 && cd $_
touch Vagrantfile
```

```Vagrantfile
Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/jammy64"
    config.vm.hostname = "vag-ubu2204"

    # config.vm.provision "shell", inline: <<-SHELL
    #     VBoxManage setproperty machinefolder /media/$USER/LAB/VBox
    # SHELL

    # config.vm.network "private_network", type: "dhcp"
    config.vm.network "public_network", bridge: "enp2s0"

    config.vm.provider "virtualbox" do |vb|
        vb.name = "vag-ubu2204"
        vb.memory = "2048"
        vb.cpus = 2
        # vb.customize ["movevm", :id, "--folder", "/media/pabloqpacin/LAB/VBox"] # solo funciona la primera vez...
        # vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
        # vb.customize ["modifyvm", :id, "--uartmode1", "file", File::NULL]
    end
 
    config.vm.synced_folder ".", "vagrant", disabled: true
    # config.vm.synced_folder '/host/path', '/guest/path', SharedFoldersEnableSymlinksCreate: false
end
```

```bash
vagrant up

# vagrant ssh
    # sudo apt update && sudo apt install neofetch --no-install-recommends && neofetch

vagrant halt

# vagrant destroy
```

Podemos volver a conectarnos yendo al directorio del proyecto y lanzando `vagrant up && vagrant ssh`.

También podemos hacerlo directamente mediante la GUI de VirtualBox. Para el login, las credenciales serán usuario==vagrant y contraseña==vagrant.
