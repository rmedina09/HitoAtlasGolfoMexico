#!/bin/bash

########################################################
# Centro de Ciencias de la Atmosfera
# Raúl Medina Peña
# raulmp@ciencias.unam.mx
# Script que ejecuta en paralelo los codigos ncl que 
# calculan los histogramas mensuales (T2,PREC,V)
#######################################################

#SBATCH -J 12_histo_mensual_paralelo 
#SBATCH -p workq2
#SBATCH -N 1 # Numero de Nodos 
#SBATCH --ntasks-per-node 22 # Número de tareas por nodo
#SBATCH -t 2-00:00 # Tiempo (D­HH:MM) 
#SBATCH -o slurm.%x.%j.out # STDOUT Salida estandar (tag name,id)
#SBATCH -e slurm.%x.%j.err # STDERR Error estándar (tag name,id)

##DEBUG##
export NCARG_ROOT=/opt/librerias/pgi/ncl-6.4.0
export PATH=/opt/librerias/pgi/ncl-6.4.0/bin:$PATH

N=11
for i in $(seq 0 $N);do
	time srun --exclusive -N1 -n1 ncl mes_i=$i histo_mensual_paralelo.ncl &
done

wait
