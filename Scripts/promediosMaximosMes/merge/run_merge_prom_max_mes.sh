#!/bin/bash

#############################################
# Centro de Ciencias de la Atmosfera
# Raúl Medina Peña
# raulmp@ciencias.unam.mx
# Script que une los archivos de los promedios de 
# maximas por mes, en un solo netCDF.
#############################################

#SBATCH -J merge_prom_MaxMes_NCL
#SBATCH -p workq2
#SBATCH -N 1 # Numero de Nodos 
#SBATCH --ntasks-per-node 1 # Número de tareas por nodo
#SBATCH -t 0-3:00 # Tiempo (D­HH:MM) 
#SBATCH -o slurm.%x.%j.out # STDOUT Salida estandar (tag name,id)
#SBATCH -e slurm.%x.%j.err # STDERR Error estándar (tag name,id)

##DEBUG##
export NCARG_ROOT=/opt/librerias/pgi/ncl-6.4.0
export PATH=/opt/librerias/pgi/ncl-6.4.0/bin:$PATH

time srun -N1 -n1 --exclusive ncl merge_prom_max_mes.ncl &

wait
