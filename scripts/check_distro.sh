#!/usr/bin/env bash

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
