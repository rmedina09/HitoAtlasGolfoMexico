;--- Ruta base ---
BASE = "/KRAKEN/DATOS3/"
;Prefijo del archivo que se quiere leer
PREFIX_FILE_C1H = "wrfout_c1h_d01_"

;Ruta base de los percentiles Mensuales
BASE_PERCENTIL = "/home/rmedina/out/percentilesMensuales/"
;Prefijo del archivo del percentil mensual qu ese quiere leer
PREFIX_PERCENTIL = "Percentiles_Mes_"
;Extensión del archivo
EXT = ".nc"

;-- creamos el arreglo que contiene el numero total de archivos por mes ---
total = new(12, float)

total(0) = 31         ; Enero 
;Depende si el año es bisiesto el numero de dias para Febrero
m = mod(anio_i, 4)
if m .eq. 0
    total(1) = 29
else
    total(1) = 28
end if

total(2) = 31         ; Marzo
total(3) = 30         ; Abril
total(4) = 31         ; Mayo 
total(5) = 30         ; Junio
total(6) = 31         ; Julio
total(7) = 31         ; Agosto
total(8) = 30         ; Septiembre
total(9) = 31         ; Octubre
total(10) = 30        ; Noviembre
total(11) = 31        ; Diciembre

;Arreglo de los nombres de los meses del año
MES = (/"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"/)

; Arreglo de valores de los percentiles
PERCENTILES = (/0.1, 1, 5, 10/)
dimPERC = dimsizes(PERCENTILES)

; Malla con todos los percentiles
T2_TOTAL_PER = new((/dimPERC, 12, 348, 617/), float)
T2_TOTAL_PER(:,:,:,:) = 0.0

; Malla con todos los percentiles
PREC_TOTAL_PER = new((/dimPERC, 12, 348, 617/), float)
PREC_TOTAL_PER(:,:,:,:) = 0.0

; Malla con todos los percentiles
VIENTO_TOTAL_PER = new((/dimPERC, 12, 348, 617/), float)
VIENTO_TOTAL_PER(:,:,:,:) = 0.0

;-------------------------------------
; Numero total de meses
nTotal = dimsizes(total)

;El año correspondiente que tiene que procesar
anio = anio_i

print("Procesando año " + anio + "...")

;Iteramos sobre los umbrales de los percentiles que se quieren calcular
do p = 0, (dimPERC - 1)    
    print("Procesando PERCENTIL " + PERCENTILES(p) + "...")
    ; -- Recorremos los archivos por mes de la carpeta del Año que le corresponde ----;
    do mes = 0, (nTotal - 1)
        
        ;===== OBTENEMOS EL PERCENTIL ACTUAL PARA EL MES ACTUAL ===============================================
        ;Cargamos el archivo con el percentil 90 para cada variable
        if(p .eq. 0) then
            ;Contruimos la ruta del archivo de percentiles para el mes correspondiente
            ruta_archivo_percentil := BASE_PERCENTIL + PREFIX_PERCENTIL + MES(mes) + EXT
            ;Cargamos el archivo de percentiles
            archivo_percentil = addfile(ruta_archivo_percentil, "r")
            ;Cargamos el percentil correspodiente para las varibles
            t2_percentil := archivo_percentil->T2_0_1
            prec_percentil := archivo_percentil->PREC_0_1
            viento_percentil := archivo_percentil->VIENTO_0_1
        end if

        ;Cargamos el archivo con el percentil 95 para cada variable
        if(p .eq. 1) then
            ;Contruimos la ruta del archivo de percentiles para el mes correspondiente
            ruta_archivo_percentil := BASE_PERCENTIL + PREFIX_PERCENTIL + MES(mes) + EXT
            ;Cargamos el archivo de percentiles
            archivo_percentil = addfile(ruta_archivo_percentil, "r")
            ;Cargamos el percentil correspodiente para las varibles
            t2_percentil := archivo_percentil->T2_1
            prec_percentil := archivo_percentil->PREC_1
            viento_percentil := archivo_percentil->VIENTO_1
        end if

        ;Cargamos el archivo con el percentil 99 para cada variable
        if(p .eq. 2) then
            ;Contruimos la ruta del archivo de percentiles para el mes correspondiente
            ruta_archivo_percentil := BASE_PERCENTIL + PREFIX_PERCENTIL + MES(mes) + EXT
            ;Cargamos el archivo de percentiles
            archivo_percentil = addfile(ruta_archivo_percentil, "r")
            ;Cargamos el percentil correspodiente para las varibles
            t2_percentil := archivo_percentil->T2_5
            prec_percentil := archivo_percentil->PREC_5
            viento_percentil := archivo_percentil->VIENTO_5
        end if

        ;Cargamos el archivo con el percentil 99.9 para cada variable
        if(p .eq. 3) then
            ;Contruimos la ruta del archivo de percentiles para el mes correspondiente
            ruta_archivo_percentil := BASE_PERCENTIL + PREFIX_PERCENTIL + MES(mes) + EXT
            ;Cargamos el archivo de percentiles
            archivo_percentil = addfile(ruta_archivo_percentil, "r")
            ;Cargamos el percentil correspodiente para las varibles
            t2_percentil := archivo_percentil->T2_10
            prec_percentil := archivo_percentil->PREC_10
            viento_percentil := archivo_percentil->VIENTO_10
        end if

        ;======================================================================================================

        ;Construimos el prefijo para obtener los archivos del mes correspondiente
        nombres_archivo_mes := PREFIX_FILE_C1H + anio + "-" + sprintf("%02g",mes + 1)
        ;Contruimos la ruta absoluta de los archivos para el mes corresṕondiente       
        ruta_archivos_mes := BASE + "a" + anio + "/" + nombres_archivo_mes
        ;Obtenemos las rutas absolutas de los archivos del mes y lo alamacenamos en un arreglo
        archivos_X_mes := systemfunc("ls " + ruta_archivos_mes + "*")        
        ;Obtenemos el numero de archivos para el mes              
        num_archivos_mes := dimsizes(archivos_X_mes)

        ; Recorremos los dias del mes 
        do dia = 0, (num_archivos_mes - 1)
            
            ;--- carga el archivo --- 
            archivo := addfile(archivos_X_mes(dia), "r")
        
            ;Obtenemos las variables    
            T2_actual := archivo->T2
            
            ;Hacemos la conversión a grados Celsius
            T2_aux := T2_actual - 273.15
            ;Obtenemos la temperatura maxima para ese dia en cada punto de la malla
            T2_min_dia := dim_min_n(T2_aux, 0)
            
            ;Iteramos sobre todo el dominio de la malla
            do i = 0, 347
                
                do j = 0, 616
                    ;TEMPERATURA
                    if(T2_min_dia(i,j) .lt. t2_percentil(i,j)) then
                        T2_TOTAL_PER(p,mes,i,j) = T2_TOTAL_PER(p,mes,i,j) + (1.0 / total(mes))  
                    end if

                end do

            end do
            
        end do

    end do

end do

print("Termino ...")
;Copiamos los umbrales mensuales de T2
T2_UMBRAL_MIN_0_1 = T2_TOTAL_PER(0,:,:,:)
T2_UMBRAL_MIN_1 = T2_TOTAL_PER(1,:,:,:)
T2_UMBRAL_MIN_5 = T2_TOTAL_PER(2,:,:,:)
T2_UMBRAL_MIN_10 = T2_TOTAL_PER(3,:,:,:)

; ================================================================================
;                           CREAMOS EL ARCHIVO DE SALIDA
; ================================================================================

;----------------------------------
;  Creamos la dimension tiempo 
;----------------------------------
time = (/0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334/)
time@standard_name = "time"
time@long_name     = "Time"
time@units         = "days since "+ anio + "-01-01 00:00:00"
time@calendar      = "noleap"
time@axis          = "T"
ntime = dimsizes(time)

;------------------------------------------------------------------------------
; Cargamos el archivo donde se encuentran las dimensiones de latitud y longitud 
;------------------------------------------------------------------------------
archivo_dimensiones := addfile("/KRAKEN/DATOS3/a"+ anio + "/wrfout_c_anio_d01_" + anio + "-01-01_00:00:00." + anio , "r")

;----------------------------------------
;   Obtenemos la dimension de Latitud 
;----------------------------------------
latAux = archivo_dimensiones->XLAT
lat = latAux(0,:,0)
delete_VarAtts(lat,-1)
nlat = dimsizes(lat)

lat@standard_name =  "latitude"
lat@long_name     =  "Latitude"
lat@units         =  "degrees_north"

;-------------------------------------
;  Obtenemos la dimension de Longitud 
;-------------------------------------
lonAux = archivo_dimensiones->XLONG
lon = lonAux(0,0,:)
delete_VarAtts(lon,-1)
nlon = dimsizes(lon)

lon@standard_name =  "longitude"
lon@long_name     =  "Longitude"
lon@units         =  "degrees_east"

;=============================================
; Definimos los atributos para cada variable 
;=============================================

;-----------------------------------------
;  Creamos los atributos para T2_UMBRA_90
;-----------------------------------------
T2_UMBRAL_MIN_0_1@units         = "%"
T2_UMBRAL_MIN_0_1@standard_name = "Porcentaje de dias debajo del Percentil 0.1% (Temperatura a 2 mts)"
T2_UMBRAL_MIN_0_1@long_name     = "Porcentaje de dias debajo del Percentil 0.1% (Temperatura a 2 mts)"
T2_UMBRAL_MIN_0_1@description   = "Porcentaje de dias debajo del Percentil 0.1% (Temperatura a 2 mts)"

;-----------------------------------------
;  Creamos los atributos para T2_UMBRA_95
;-----------------------------------------
T2_UMBRAL_MIN_1@units         = "%"
T2_UMBRAL_MIN_1@standard_name = "Porcentaje de dias debajo del Percentil 1% (Temperatura a 2 mts)"
T2_UMBRAL_MIN_1@long_name     = "Porcentaje de dias debajo del Percentil 1% (Temperatura a 2 mts)"
T2_UMBRAL_MIN_1@description   = "Porcentaje de dias debajo del Percentil 1% (Temperatura a 2 mts)"

;-----------------------------------------
;  Creamos los atributos para T2_UMBRA_99
;-----------------------------------------
T2_UMBRAL_MIN_5@units         = "%"
T2_UMBRAL_MIN_5@standard_name = "Porcentaje de dias debajo del Percentil 5% (Temperatura a 2 mts)"
T2_UMBRAL_MIN_5@long_name     = "Porcentaje de dias debajo del Percentil 5% (Temperatura a 2 mts)"
T2_UMBRAL_MIN_5@description   = "Porcentaje de dias debajo del Percentil 5% (Temperatura a 2 mts)"

;-------------------------------------------
;  Creamos los atributos para T2_UMBRA_99.9
;-------------------------------------------
T2_UMBRAL_MIN_10@units         = "%"
T2_UMBRAL_MIN_10@standard_name = "Porcentaje de dias debajo del Percentil 10% (Temperatura a 2 mts)"
T2_UMBRAL_MIN_10@long_name     = "Porcentaje de dias debajo del Percentil 10% (Temperatura a 2 mts)"
T2_UMBRAL_MIN_10@description   = "Porcentaje de dias debajo del Percentil 10% (Temperatura a 2 mts)"

;==========================================================

;------------------------------------------
;  Creamos el archivo de salida 
;------------------------------------------
diro = "/home/rmedina/out/umbrales/minimos/"  ; Output directory
filo = "Umbrales_Mensuales_Min_T2_" + anio + ".nc"             ; Output file
system("rm -f " + diro + filo)               ; remove if exists
fout  = addfile (diro + filo, "c")           ; open output file

;-----------------------------------------
;  Creamos las variables globales 
;-----------------------------------------
fAtt               = True            ; asignamos atributos al archivo
fAtt@title         = "Umbrales Mensuales de " + anio + "(0.1, 1, 5, 10)"  
fAtt@institution   = "UNAM, Centro de Ciencias de la Atmósfera"  
fAtt@source        = "Synthetic data"  
fAtt@history       = "First version"  
fAtt@Conventions   = "CF-1.6"   
fAtt@creation_date = systemfunc ("date")        
fileattdef( fout, fAtt )            ; copiamos los atributos globales

;-------------------------------------------------------
;  Definimos las variables coordenadas y sus dimensiones
;-------------------------------------------------------
dimNames = (/"time", "Latitude", "Longitude"/)
dimSizes = (/  -1  ,  nlat     ,  nlon  /)
dimUnLim = (/ True ,  False    ,  False /)
filedimdef(fout, dimNames, dimSizes, dimUnLim)

;----------------------------------------------------------------------
;  Pre-cargamos las variables que se escribiran en el archivo de salida 
;----------------------------------------------------------------------
filevardef(fout, "time"     , typeof(time), "time")   ;Dimension tiempo
filevardef(fout, "Latitude" , typeof(lat) , "Latitude") ;Dimension latitud
filevardef(fout, "Longitude", typeof(lon) , "Longitude") ;Dimension longitud

filevardef(fout, "T2_UMBRAL_MIN_0_1" , typeof(T2_UMBRAL_MIN_0_1) , (/"time", "Latitude", "Longitude"/))      ;Percentil 90% Temperatura del aire a 2m
filevardef(fout, "T2_UMBRAL_MIN_1"   , typeof(T2_UMBRAL_MIN_1)   , (/"time", "Latitude", "Longitude"/))      ;Percentil 95% Temperatura del aire a 2m
filevardef(fout, "T2_UMBRAL_MIN_5"   , typeof(T2_UMBRAL_MIN_5)   , (/"time", "Latitude", "Longitude"/))      ;Percentil 99% Temperatura del aire a 2m
filevardef(fout, "T2_UMBRAL_MIN_10"  , typeof(T2_UMBRAL_MIN_10)  , (/"time", "Latitude", "Longitude"/))      ;Percentil 99.9% Temperatura del aire a 2m

;----------------------------------------------------------------------
;  Copiar atributos asociados con cada variable a el archivo de salida
;----------------------------------------------------------------------
filevarattdef(fout, "time"     , time)  ;copia los atributosdel tiempo
filevarattdef(fout, "Latitude" , lat )  ;copia los atributos de latitud
filevarattdef(fout, "Longitude", lon )  ;copia los atributos de longitud

filevarattdef(fout, "T2_UMBRAL_MIN_0_1", T2_UMBRAL_MIN_0_1     )  ;copia los atributos de T2_90
filevarattdef(fout, "T2_UMBRAL_MIN_1"  , T2_UMBRAL_MIN_1     )  ;copia los atributos de T2_95
filevarattdef(fout, "T2_UMBRAL_MIN_5"  , T2_UMBRAL_MIN_5     )  ;copia los atributos de T2_99
filevarattdef(fout, "T2_UMBRAL_MIN_10" , T2_UMBRAL_MIN_10     )  ;copia los atributos de T2_99_9

;------------------------------------------------
;  Obtenemos unicamente los valores de los datos 
;------------------------------------------------
fout->time      = (/time/)
print("copiamos time ....")
fout->Latitude  = (/lat/)
print("copiamos lat ...")
fout->Longitude = (/lon/)
print("copiamos lon ...")

fout->T2_UMBRAL_MIN_0_1     = (/T2_UMBRAL_MIN_0_1/)
fout->T2_UMBRAL_MIN_1       = (/T2_UMBRAL_MIN_1/)
fout->T2_UMBRAL_MIN_5       = (/T2_UMBRAL_MIN_5/)
fout->T2_UMBRAL_MIN_10      = (/T2_UMBRAL_MIN_10/)
print("copiamos umbrales para T2_* ...")
