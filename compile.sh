#!/bin/bash

if [ $# -ne 2 ]; then
    echo "No se ingresó ningún archivo nasm o no se ingresó la ruta hacia el USB."
    exit 1
fi


nasm -f bin $1 -o BOOTX64.EFI
mkdir -p $2/EFI/BOOT
cp BOOTX64.EFI $2/EFI/BOOT

echo "Archivo BOOTX86.EFI creado exitosamente y enviado a tu USB en EFI/BOOT."
