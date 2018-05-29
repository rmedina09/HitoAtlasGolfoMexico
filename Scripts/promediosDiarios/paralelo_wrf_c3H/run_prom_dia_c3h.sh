#!/bin/bash

#############################################
# Centro de Ciencias de la Atmosfera
# Raúl Medina Peña
# raulmp@ciencias.unam.mx
# Script que ejecuta en paralelo los codigos 
# ncl que calculan la humedad relativa 
#############################################

#SBATCH -J paralelo_prom_dia_rh_rmedina 
#SBATCH -p workq2
#SBATCH -N 2 # Numero de Nodos 
#SBATCH --ntasks-per-node 44 # Número de tareas por nodo
#SBATCH -t 2-00:00 # Tiempo (D­HH:MM) 
#SBATCH -o slurm.%x.%j.out # STDOUT Salida estandar (tag name,id)
#SBATCH -e slurm.%x.%j.err # STDERR Error estándar (tag name,id)

##DEBUG##
export NCARG_ROOT=/opt/librerias/pgi/ncl-6.4.0
export PATH=/opt/librerias/pgi/ncl-6.4.0/bin:$PATH

N=72 
for i in $(seq 0 $N);do
	time srun -N1 -n1 --exclusive ncl nc=$i paralelo_prom_dia_c3h.ncl &
done

wait
