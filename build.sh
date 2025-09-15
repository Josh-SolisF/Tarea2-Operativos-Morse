#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Porfavor ingrese la ruta archivo nasm o la ruta hacia el USB."
    exit 1
fi

nasm -f win64 $1 -o BOOTX64.obj
lld-link /subsystem:efi_application /entry:efi_main /machine:x64 /nodefaultlib /out:BOOTX64.efi BOOTX64.obj
sudo mkdir -p $2/EFI/BOOT
sudo cp BOOTX64.efi $2/EFI/BOOT

echo "El archivo BOOTX64.efi se ha transferido a la USB"
