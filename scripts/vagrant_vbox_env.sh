### Vagrant config files
if command -v vagrant &>/dev/null; then
    if [ ! -d /var/vagrant.d ]; then
        mkdir /var/vagrant.d
        sudo chmod o+rwx /var/vagrant.d
    fi

    case $VAGRANT_HOME in
        '/var/vagrant.d') echo "OK" > /dev/null ;;
        '' | '~/.vagrant.d' | *) export VAGRANT_HOME="/var/vagrant.d" ;;
    esac

    # TODO: check env. var. regarding syncfolders...
fi

### Hardware/VirtualBox VMs storage
if command -v vagrant &>/dev/null; then
    if lsblk -f | grep -q 'LAB' && [ ! -d /media/$USER/LAB/VBox ]; then
        # FIXME: necesario login en GUI por tema dbus... -- https://stackoverflow.com/questions/483460/how-to-mount-from-command-line-like-the-nautilus-does
        # DONE: hemos dado persistencia al montaje (ver ../README.md), con lo que este código no debería ejecutarse
        gio mount -d /dev/sdb2                                                  # gio mount -u /media/$USER/LAB
    fi

    VBOX_MACHINEFOLDER=$(VBoxManage list systemproperties | grep "Default machine folder" | awk -F ':' '{print $2}' | tr -d ' ')
    case $VBOX_MACHINEFOLDER in
        "/media/$USER/LAB/VBox") echo "OK" > /dev/null ;;
        *) VBoxManage setproperty machinefolder /media/$USER/LAB/VBox ;;
    esac
fi
