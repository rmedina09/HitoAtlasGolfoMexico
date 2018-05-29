#!/bin/bash

########################################################
# Centro de Ciencias de la Atmosfera
# Raúl Medina Peña
# raulmp@ciencias.unam.mx
# Script que ejecuta en paralelo los codigos ncl que 
# calculan el histograma para un mes en específico 
# (T2,PREC,V).
# La variable 'N' determina el número de días según el mes
# que se quiera calcular deteerminado por la variable 'M'
# que va de 0 a 11 (0->Enero, 1->Febrero, ... , 11->Diciembre)
#######################################################

#SBATCH -J N_histo_mensual_paralelo 
#SBATCH -p workq2
#SBATCH -N 1 # Numero de Nodos 
#SBATCH --ntasks-per-node 44 # Número de tareas por nodo
#SBATCH -t 0-24:00 # Tiempo (D­HH:MM) 
#SBATCH -o slurm.%x.%j.out # STDOUT Salida estandar (tag name,id)
#SBATCH -e slurm.%x.%j.err # STDERR Error estándar (tag name,id)

##DEBUG##
export NCARG_ROOT=/opt/librerias/pgi/ncl-6.4.0
export PATH=/opt/librerias/pgi/ncl-6.4.0/bin:$PATH

N=28
MES=1
for i in $(seq 1 $N);do
	time srun --exclusive -N1 -n1 ncl M=$MES n_dia=$i histo_mensual_paralelo_N.ncl &
done

wait
