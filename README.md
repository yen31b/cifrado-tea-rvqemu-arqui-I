# Implementaciónn de Cifrado TEA usando C y Ensamblador RISC-V en QEMU
Proyecto individual del curso Arquitectura de Computadores I, IIS 2025

---

### Detalles de implementación
- Se decidió utilizar WSL2 ya que la version 2 tiene una compatibilidad mayor con Docker ya que es más sencillo de instalar para esta versión.

- Para realizar las funciones de cifrado TEA, se decidió implementarlas primero en el lenguaje C en el archivo tea.c, y agregar la compilación del archivo en el build.sh. Lo anterior se hizo para comprender de mejor manera el algoritmo TEA y entender bien los pasos del flujo de integración entre el build.sh donde se realiza la compilación de los archivos, el programa principal example.c, el uso de QEMU.

-Posteriormente se realizó la implementación de 

-Para optimizar más el uso de los registros y minimizar los accesos a memoria, se decidió cambiar la primera versión del programa tea_asm.s:
  -Se cargan las claves (key[n]) en registros antes del loop para evitar accesos repetidos a memoria dentro de cada iteracion. Las claves no cambian durante el cifrado, así que se cargan una sola vez en registros de t2-t5. Esto hace que se den 4 accesos a memoria menos por ronda (128 accesos menos en total).

-Usar los registros temporales t0-t6 para realizar calculos intermedios, esto para mantener los valores de clave y datos, minimizando el uso de la pila y accesos a memoria.

-Se eliminaron instrucciones que eran redundantes como recalcular o recargar el valor DELTA que no cambia dentro del loop.

---
#### Link de Jira Project
https://yendry-badilla.atlassian.net/jira/software/projects/KAN/boards/1?atlOrigin=eyJpIjoiNjFkZWZkMGY5ZmY1NGExZGJmMmJkMDQzOTdhMWYwNDMiLCJwIjoiaiJ9
