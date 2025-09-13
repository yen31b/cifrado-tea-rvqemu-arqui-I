# Implementación de Cifrado TEA usando C y Ensamblador RISC-V en QEMU
Proyecto individual del curso Arquitectura de Computadores I, IIS 2025

---

- [Implementación de Cifrado TEA usando C y Ensamblador RISC-V en QEMU](#implementación-de-cifrado-tea-usando-c-y-ensamblador-risc-v-en-qemu)
    - [Compilación y ejecución del programa](#compilación-y-ejecución-del-programa)
    - [Paso 1: Construir el contenedor](#paso-1-construir-el-contenedor)
    - [Paso 2: Se utiliza examples/c-asm](#paso-2-se-utiliza-examplesc-asm)
    - [Paso 3: Ejecutar con QEMU y depurar](#paso-3-ejecutar-con-qemu-y-depurar)
    - [Detalles de implementación](#detalles-de-implementación)
    - [Resultados](#resultados)
      - [Link de Jira Project](#link-de-jira-project)

### Compilación y ejecución del programa 

Se utilizó el mismo flujo del ejemplo del repositorio del profesor:
https://gitlab.com/jgonzalez.tec/rvqemu

### Paso 1: Construir el contenedor
```bash
chmod +x run.sh
./run.sh
```
### Paso 2: Se utiliza examples/c-asm
```bash
# C + ensamblador
cd /examples/c-asm
./build.sh
```

### Paso 3: Ejecutar con QEMU y depurar
```bash
# En una terminal: iniciar QEMU con servidor GDB
./run-qemu.sh

# En otra terminal: conectar GDB
docker exec -it rvqemu /bin/bash
cd /home/rvqemu-dev/workspace/examples/[ejemplo-elegido]
gdb-multiarch [archivo-elf]

#Al iniciar se ingresa el comando para conectarse :

(gdb) target remote :1234

#resultado
Remote debugging using :1234
0x00001000 in ?? ()

#se agregan los breakpoints a las funciones de ASM y al main de C
(gdb) break tea_encrypt_asm 
Breakpoint 1 at 0x80000cf4: file tea_asm.s, line 6.
(gdb) break tea_decrypt_asm 
Breakpoint 2 at 0x80000da4: file tea_asm.s, line 69.
(gdb) break main
Breakpoint 3 at 0x800008d0: file example.c, line 227.

#Se ejecuta continue hasta terminar los breakpoints y esto va mostrando la ejecucion en esta terminal
(gdb) continue

#---------Los resultados se muestran en la primera terminal usada---------#

#Para ver los registros se ejecuta

(gdb) info registers

#para salir de gdb se ejecuta

(gdb) Quit
```



### Detalles de implementación
- Se decidió utilizar WSL2 ya que la version 2 tiene una compatibilidad mayor con Docker ya que es más sencillo de instalar para esta versión.

- Para realizar las funciones de cifrado TEA, se decidió implementarlas primero en el lenguaje C en el archivo tea.c, y agregar la compilación del archivo en el build.sh. Lo anterior se hizo para comprender de mejor manera el algoritmo TEA y entender bien los pasos del flujo de integración entre el build.sh donde se realiza la compilación de los archivos, el programa principal example.c, el uso de QEMU y GDB.

-Posteriormente se realizó la re-implementación de las funciones de cifrado en ensamblador. En esta versión inicial del programa la clave se carga en registros temporales desde la memoria en cada iteracion que se realiza en el loop de cada funcion, tea_encrypt_asm y tea_decrypt_asm, por lo que se hacen muchos accesos a memoria realizando lo mismo. También al utilizar la magic constant o DELTA con valor 0x9e3779b9, cargada tambien en cada iteracion. 

-Para optimizar más el uso de los registros y minimizar los accesos a memoria, se analizó la versión inicial y se decidió cambiar tea_asm.s con lo siguiente:
  -Se cargaron las claves (key[n]) en los registros antes del loop para evitar accesos repetidos a memoria dentro de cada iteracion, ya que dichas claves no cambian durante este procesado de cifrado, así que se cargan una sola vez en registros de temporales t2-t5.

  -La constante DELTA ahora se carga una sola vez en un registro antes del loop y se reutiliza en cada iteración de las funciones. DELTA se guarda en t6.

  -Se usaron los registros temporales para realizar calculos intermedios, esto para mantener los valores de clave y datos, minimizando el uso de la pila y accesos a memoria. Por ejemplo, en operaciones que se realizan para calcular las sumas al obtener v[0] (en t0) o v[1] (en t1) ('v0 += ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1])'). Se decidió usar a2 y a3 para cálculos también porque ya se estaban utilizando todos los registros t.


---


### Resultados
![Resultados mostrados en la terminal](https://cdn.discordapp.com/attachments/764741709627916288/1416275004135571537/image.png?ex=68c64062&is=68c4eee2&hm=092928288faa074442e56550041868c39889d028181f5f105faf5e9f56b92cee)

En la impresión de los resultados se decidió mostrar el proceso paso a paso de cada bloque que conforma el mensaje original. Primero se muestra el mensaje original ingresado, se interpreta este como un bloque en hexadecimal de 64 bits (8 bytes), se muestra el resultado del proceso de encriptado y luego el de desencriptado. Finalmente se muestra el resultado final de  todo el bloque. 

Si el bloque mide más de 8 bytes, entonces se divide en varios bloques y se procesan, tomando en cuenta que si algun bloque ya no completa los 8 bytes, se utiliza la tecnica de padding que rellena con 0x00 el resto del bloque y en los resultados de desencriptado se muestran con el caracter '_'. El resultado final muestra el mensaje original completo, permitiendo verificar que el cifrado y descifrado funcionan correctamente para cadenas de distinta longitud.

Para la Prueba 1 de bloque único:

Entrada: "HOLA1234"
Clave: {0x12345678, 0x9ABCDEF0, 0xFEDCBA98, 0x76543210}

El string tiene 8 caracteres, cabe en un solo bloque de 64 bits (8 bytes) sin tener que recurrir a la tecnica de padding.
El bloque se muestra en hexadecimal, luego se cifra el bloque usando la función tea_encrypt_asm, mostrando el resultado cifrado en hexadecimal.
Luego, se descifra el bloque con tea_decrypt_asm, mostrando el resultado en texto.


Para la Prueba 2 de bloques multiples:

Entrada: "Mensaje de prueba para TEA"
Clave: {0xA1B2C3D4, 0x1A2B3C4D, 0xDEADBEEF, 0xCAFEBABE}

Para este caso como el string tiene más de 8 caracteres, se divide en varios bloques de 8 bytes.
Cada bloque se procesa individualmente, se muestra en hexadecimal, se cifra, se muestra el cifrado, se descifra y se muestra el texto, se muestran _ si hay padding en alguno de los bloques divididos.
Al final, se muestran todos los bloques cifrados juntos y luego todos los bloques descifrados juntos, reconstruyendo el mensaje original (con _ en los lugares donde hubo padding)

Luego de estas pruebas se muestran resultados de otros bloques que se utilizaron para probar durante el proceso de implementacion.

#### Link de Jira Project
https://yendry-badilla.atlassian.net/jira/software/projects/KAN/boards/1?atlOrigin=eyJpIjoiNjFkZWZkMGY5ZmY1NGExZGJmMmJkMDQzOTdhMWYwNDMiLCJwIjoiaiJ9