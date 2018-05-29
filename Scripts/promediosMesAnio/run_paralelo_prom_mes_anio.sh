#!/bin/bash

#############################################
# Centro de Ciencias de la Atmosfera
# Raúl Medina Peña
# raulmp@ciencias.unam.mx
# Script que ejecuta en paralelo los codigos 
# ncl que calculan los promedios mensuales 
# por año (T2,PREC,V)
#############################################

#SBATCH -J prueba_prom_mes_anio 
#SBATCH -p workq2
#SBATCH -N 1 # Numero de Nodos 
#SBATCH --ntasks-per-node 44 # Número de tareas por nodo
#SBATCH -t 0-24:00 # Tiempo (D­HH:MM) 
#SBATCH -o slurm.%x.%j.out # STDOUT Salida estandar (tag name,id)
#SBATCH -e slurm.%x.%j.err # STDERR Error estándar (tag name,id)

##DEBUG##
export NCARG_ROOT=/opt/librerias/pgi/ncl-6.4.0
export PATH=/opt/librerias/pgi/ncl-6.4.0/bin:$PATH

N=2016
for i in $(seq 1983 $N);do
	time srun -N1 -n1 --exclusive ncl anio_i=$i paralelo_prom_mes_anio.ncl &
done

wait
