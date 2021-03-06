#!/bin/bash

#############################################
# Centro de Ciencias de la Atmosfera
# Raúl Medina Peña
# raulmp@ciencias.unam.mx
# Script que ejecuta el archivo .ncl que 
# calcula promoedios diarios para HUmedad Relativa.
#############################################

#SBATCH -J Promedios_Dia_RH_Rmedina 
#SBATCH -p workq2
#SBATCH -N 1 # Numero de Nodos 
#SBATCH --ntasks-per-node 1 # Número de tareas por nodo
#SBATCH -t 3-00:00 # Tiempo (D­HH:MM) 
#SBATCH -o slurm.%x.%j.out # STDOUT Salida estandar (tag name,id)
#SBATCH -e slurm.%x.%j.err # STDERR Error estándar (tag name,id)

##DEBUG##
export NCARG_ROOT=/opt/librerias/pgi/ncl-6.4.0
export PATH=/opt/librerias/pgi/ncl-6.4.0/bin:$PATH

time srun -N1 -n1 --exclusive ncl promediosXdia_c3h.ncl &

wait
