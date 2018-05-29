;--- Ruta base ---
BASE = "/KRAKEN/DATOS3/"
;Prefijo del archivo que se quiere leer
PREFIX_FILE_C1H = "wrfout_c1h_d01_"


;-- creamos el arreglo que contiene el numero total de archivos por mes ---
total = new(12, float)

total(0) = 24*31         ; Enero 
;Depende si el año es bisiesto el numero de dias para Febrero
m = mod(anio_i, 4)
if m .eq. 0
    total(1) = 24*29
else
    total(1) = 24*28
end if

total(2) = 24*31         ; Marzo
total(3) = 24*30         ; Abril
total(4) = 24*31         ; Mayo 
total(5) = 24*30         ; Junio
total(6) = 24*31         ; Julio
total(7) = 24*31         ; Agosto
total(8) = 24*30         ; Septiembre
total(9) = 24*31         ; Octubre
total(10) = 24*30        ; Noviembre
total(11) = 24*31        ; Diciembre

; ----------------------------------------;
; ---- Inicializar las variables en 0 ----;

; --- U10 ----
U10 = new ((/12, 348, 617/), float)
U10(:,:,:) = 0.0

; --- V10 ----
V10 = new ((/12, 348, 617/), float)
V10(:,:,:) = 0.0

; --- Temperatura del aire a 2 mts por mes ----
T2 = new ((/12, 348, 617/), float)
T2(:,:,:) = 0.0

; --- PREC2 Precipitación  acumulada ---
PREC2 = new ((/12, 348, 617/), float)
PREC2(:,:,:) = 0.0

;-------------------------------------
; Numero total de meses
nTotal = dimsizes(total)

;El año correspondiente que tiene que procesar
anio = anio_i

; -- Recorremos los archivos por mes de la carpeta del Año que le corresponde ----;
print("Procesando año " + anio + "...")
do mes = 0, (nTotal - 1)
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
        U10_actual := archivo->U10
        V10_actual := archivo->V10
        T2_actual := archivo->T2
        RAINC_actual := archivo->RAINC
        RAINNC_actual := archivo->RAINNC
        
        ;Calculamos la precipitacion acumulada por dia            
        PREC2(mes,:,:) = PREC2(mes,:,:) + ((RAINC_actual(23,:,:) + RAINNC_actual(23,:,:) - (RAINC_actual(0,:,:) + RAINNC_actual(0,:,:))) / total(mes))
        
        ;Iteramos sobre las 24 horas            
        do hora = 0, 23
                
            U10(mes,:,:) = U10(mes,:,:) + (U10_actual(hora,:,:) / total(mes)) 
            V10(mes,:,:) = V10(mes,:,:) + (V10_actual(hora,:,:) / total(mes))
            T2(mes,:,:) = T2(mes,:,:) + ((T2_actual(hora,:,:) - 273.15 )/ total(mes))               
                
        end do

    end do

end do

print("Termino ...")

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

;--------------------------------
;  Creamos los atributos para U10
;--------------------------------
U10@units         = "m s-1"
U10@standard_name = "eastward_wind"
U10@long_name     = "eastward_wind"
U10@description   = "U"

;--------------------------------
;  Creamos los atributos para V10
;--------------------------------
V10@units         = "m s-1"
V10@standard_name = "northward_wind"
V10@long_name     = "northward_wind"
V10@description   = "V"

;--------------------------------
;  Creamos los atributos para T2 
;--------------------------------
T2@units         = "C"
T2@standard_name = "air_temperature"
T2@long_name     = "Air temperature"
T2@description   = "TEMP at 2 M"

;-------------------------------------
;  Creamos los atributos para  
;-------------------------------------
PREC2@units         = "mm"
PREC2@standard_name = "Precipitation"
PREC2@long_name     = "Precipitation"
PREC2@description   = "Precipitation"

;==========================================
; Definimos el archivo de salida 
;==========================================

;------------------------------------------
;  Creamos el archivo de salida 
;------------------------------------------
diro = "/home/rmedina/out/promediosMesAnio/"   ; Output directory
filo = "Promedios_Mes_Anio_" + anio + ".nc"                  ; Output file
system("rm -f " + diro + filo)             ; remove if exists
fout  = addfile (diro + filo, "c")         ; open output file

;-----------------------------------------
;  Creamos las variables globales 
;-----------------------------------------
fAtt               = True            ; asignamos atributos al archivo
fAtt@title         = "Promedios Mensuales por Año (" + anio + ")"  
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

filevardef(fout, "U10"      , typeof(U10) , (/"time", "Latitude", "Longitude"/)) ;Viento U a 10 M
filevardef(fout, "V10"      , typeof(V10) , (/"time", "Latitude", "Longitude"/)) ;Viento V a 10 M
filevardef(fout, "T2"       , typeof(T2)     , (/"time", "Latitude", "Longitude"/))        ;Temperatura del aire a 2m
filevardef(fout, "PREC2"    , typeof(PREC2)  , (/"time", "Latitude", "Longitude"/))        ;Precipitacion

;----------------------------------------------------------------------
;  Copiar atributos asociados con cada variable a el archivo de salida
;----------------------------------------------------------------------
filevarattdef(fout, "time"     , time)  ;copia los atributosdel tiempo
filevarattdef(fout, "Latitude" , lat )  ;copia los atributos de latitud
filevarattdef(fout, "Longitude", lon )  ;copia los atributos de longitud

filevarattdef(fout, "U10"      , U10 )  ;copia los atributos de U10
filevarattdef(fout, "V10"      , V10 )  ;copia los atributos de V10
filevarattdef(fout, "T2"       , T2     )  ;copia los atributos de T2
filevarattdef(fout, "PREC2"    , PREC2  )  ;copia los atributos de RAINC

;------------------------------------------------
;  Obtenemos unicamente los valores de los datos 
;------------------------------------------------
fout->time      = (/time/)
print("copiamos time ....")
fout->Latitude  = (/lat/)
print("copiamos lat ...")
fout->Longitude = (/lon/)
print("Copiamos lon ...")

fout->U10        = (/U10/)
print("Copiamos U10 ...")
fout->V10     = (/V10/)
print("Copiamos V10 ...")
fout->T2        = (/T2/)
print("Copiamos T2 ...")
fout->PREC2     = (/PREC2/)
print("Copiamos PREC2 ...")
