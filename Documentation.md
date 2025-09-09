Introducción:
En las lecciones en clase hemos introducido conceptos clave como es el UEFI (Unified Extensible Firmware Interface) es una especificación que define una interfaz de software entre el sistema operativo y el firmware de la plataforma. Lo hemos visto mucho en teoría pero es necesario comprenderlo en la práctica.
La presente tarea aborda la necesidad de realmente comprender el comportamiento de estos programas de una manera pre sistema operativo, específicamente a través la implementación de un programa que recibe un prompt y lo traduce a código morse.
La herramienta está desarrollada en nasm64 y este programa implementa una aplicación UEFI. La aplicación lee caracteres del teclado mediante el protocolo ConIn de UEFI, los almacena en un búfer, y al presionar enter, convierte toda la línea ingresada a código Morse utilizando el protocolo ConOut para la salida. El programa se ensambla utilizando NASM para Win64 (dado que UEFI utiliza código de 64 bits) y se enlaza con lld-link para generar un ejecutable EFI:

```
nasm -f win64 programa.asm -o BOOTX64.obj
lld-link /subsystem:efi_application /entry:efi_main /machine:x64 /nodefaultlib /out:BOOTX64.efi BOOTX64.obj
````

El archivo BOOTX64.efi resultante debe copiarse a una unidad USB formateada en FAT32. Luego, se puede arrancar desde el firmware UEFI seleccionando la unidad USB como dispositivo de arranque.

---

## Ambiente de desarrollo:

* **Sistema Operativo:** Linux (Ubuntu)

* **Arquitectura:** x86\_64

* **Lenguaje de programación:** Nasm64 (2.16.01)

* **Editor/IDE:** Text editor y VScode

* **Bibliotecas principales:**
  El programa no utiliza bibliotecas externas, ya que interactúa directamente con los protocolos UEFI (ConIn y ConOut) proporcionados por el firmware.

* **Herramientas:**

  * NASM: Ensamblador para compilar el código fuente.
  * lld-link: Enlazador de LLVM para generar el ejecutable EFI.

---

## Estructuras de datos:

* **búfer\_tecla:** Reserva espacio para 2 palabras (4 bytes) para almacenar la estructura que contiene:

  * `ScanCode (UINT16)`: Código de escaneo de la tecla
  * `UnicodeChar (UINT16)`: Carácter Unicode de la tecla

* **búfer\_línea:** Búfer de tamaño MAX\_BUF (512 caracteres UTF-16, 1024 bytes) para almacenar la línea de texto ingresada por el usuario. Cada carácter se almacena en formato UTF-16 (2 bytes por carácter).

* **Cadenas UTF-16:**

  * `cadena_inicio`: Mensaje de bienvenida `"Palabra morse!!:"`
  * `caracter_punto`: Carácter `.` para representar puntos Morse
  * `caracter_raya`: Carácter `-` para representar rayas Morse
  * `caracter_espacio`: Carácter `' '` para separar símbolos Morse
  * `cadena_prompt`: Prompt `"// "` para indicar entrada
  * `cadena_nueva_linea`: Secuencia de retorno de carro y nueva línea

---

## Funciones principales:

* **efi\_main:** Función principal de entrada punto del programa UEFI. Coordina todo el proceso de:

  * Inicialización de protocolos UEFI (ConIn y ConOut)
  * Configuración de consolas de entrada y salida
  * Gestión del bucle principal de lectura de teclas
  * Procesamiento de líneas completas
  * Conversión a código Morse
  * Gestión de la salida del programa

* **Subrutinas principales dentro de efi\_main:**

  * `.prompt`: Muestra el prompt `"// "` para indicar al usuario que puede ingresar texto.
  * `.bucle_lectura`: Lee teclas del servicio de entrada UEFI (ConIn) utilizando la función `ReadKeyStroke`. Maneja el ENTER y otros caracteres imprimibles
  * `.procesar_linea`: Procesa una línea completa cuando se presiona ENTER:

    * Añade el terminador nulo a la cadena
    * Imprime la línea ingresada para retroalimentación
    * Llama al proceso de conversión a Morse
  * `.bucle_iteracion`: Itera sobre cada carácter en el búfer de línea y llama a la rutina de conversión Morse correspondiente.

---

## Macros especiales:

* **REPRODUCIR\_PUNTO:** Macro que imprime un punto (.) utilizando el protocolo de salida UEFI
* **REPRODUCIR\_RAYA:** Macro que imprime una raya (-) utilizando el protocolo de salida UEFI

---

## Ejecución del programa:

### Compilación:

```bash
nasm -f win64 $1 -o BOOTX64.obj
```

### Enlace del ejecutable EFI:

```bash
lld-link /subsystem:efi_application /entry:efi_main /machine:x64 /nodefaultlib /out:BOOTX64.efi BOOTX64.obj
```

### Preparación USB:

```bash
sudo mkdir -p $2/EFI/BOOT
sudo cp BOOTX64.efi $2/EFI/BOOT
```

### Configuración de BIOS/UEFI:

1. Conectar la unidad USB al sistema objetivo
2. Acceder a la configuración del firmware (UEFI) durante el arranque
3. Desactivar Secure Boot si está habilitado
4. Seleccionar la unidad USB como dispositivo de arranque prioritario

### Ejecución:

Al arrancar desde la unidad USB, el firmware UEFI cargará automáticamente `BOOTX64.efi`.
El programa mostrará el mensaje `"Palabra morse!!"`.
El usuario puede escribir texto y presionar ENTER para convertirlo a Morse.

---

## Bitácora del estudiante:

| Estudiante | Actividad                                                                                  | Horas | Fecha     |
| ---------- | ------------------------------------------------------------------------------------------ | ----- | --------- |
| Josh Lis   | Desarrollo de programa nasm 64 para linux para tener una idea de como ejecutar el programa | 4     | 5/09/2025 |
| Josh Lis   | Desarrollo inicial de UEFI                                                                 | 3     | 6/09/2025 |
| Josh Lis   | Investigación de como bootear desde una llave                                              | 4     | 8/09/2025 |
| Josh Lis   | Desarrollo del programa en UEFI                                                            | 6     | 8/09/2025 |
| Josh Lis   | Refactor y limpieza                                                                        | 2     | 9/09/2025 |
| Josh Lis   | Documentación                                                                              | 3     | 9/09/2025 |

**Total: 22 horas**

---

## Autoevaluación:

### Estado final del programa:

El programa UEFI de conversión a Morse funciona correctamente como aplicación independiente sin sistema operativo, pero presenta algunas limitaciones en su funcionalidad.

**Funcionalidades implementadas:**

* Interfaz UEFI nativa
* Lectura de entrada por teclado
* Soporte para caracteres alfanuméricos (A-Z, a-z, 0-9)
* Manejo de búfer de entrada (512 caracteres)
* Visualización de Morse con puntos y rayas
* Salida con protocolo ConOut

**Problemas encontrados:**

* Falta de sonido real
* Soporte limitado de caracteres (sin signos de puntuación)
* Dependencia de firmware UEFI
* Solo funciona en sistemas con UEFI x86-64
* Requiere desactivar Secure Boot
* Visualización básica
* No hay persistencia de datos
* Tamaño de búfer limitado

---

## Lecciones aprendidas:

1. El desarrollo de aplicaciones UEFI requiere conocimiento de bajo nivel y documentación específica.
2. NASM x86-64 difiere de ensamblador para sistemas operativos.
3. Los servicios UEFI son útiles pero limitados frente a APIs de un SO completo.
4. La gestión de memoria en UEFI es más restrictiva.
5. El proceso de compilación y despliegue difiere del de aplicaciones convencionales.

**Recomendaciones a futuros estudiantes:**

* Estudiar UEFI y sus servicios antes de programar.
* Conocer convenciones de llamadas en x86-64.
* Empezar con ejemplos simples.
* Probar en QEMU y hardware real.

---

## Bibliografía:

* 12. Protocols — Console Support — UEFI Specification 2.9A documentation.” https://uefi.org/specs/UEFI/2.9_A/12_Protocols_Console_Support.html

* “uefi - Rust.” https://docs.rs/uefi/latest/uefi/
* “@depletionmode - 2 of 1; half a nybble of another - Understanding modern UEFI-based platform boot.” https://depletionmode.com/uefi-boot.html
* “*-unknown-uefi - The rustc book.” https://doc.rust-lang.org/beta/rustc/platform-support/unknown-uefi.html
* [ptrace man page](https://man7.org/linux/man-pages/man2/ptrace.2.html)
* “How to create an UEFI bootable USB stick from an ISO,” Super User, Nov. 01, 2012. https://superuser.com/questions/497672/how-to-create-an-uefi-bootable-usb-stick-from-an-iso
* H. O. Store, “What is UEFI? A complete guide to BIOS vs UEFI | HP® Tech Takes - Hong Kong,” hp, Feb. 14, 2025. https://www.hp.com/hk-en/shop/tech-takes/post/what-is-uefi
* Wikipedia contributors, “UTF-16,” Wikipedia, Aug. 27, 2025. https://en.wikipedia.org/wiki/UTF-16

```

