;------------------------------------------------------------------
; --- Funcion que crea un arreglo de una dimension ---
function createArray(size)
begin
    myarray = new(size,float)
    do n=0,size-1
        myarray(n) = n 
    end do 
    return myarray
end

;Numero de anios a ejecutar
ANIOS = 39

;--- Ruta base ---
;BASE = "/KRAKEN/DATOS3/"
BASE = "/CHACMOOL/DATOS/"  ; version 4

;--- Prefijo ---
PREFIX_FILE_C1H = "wrfout_c1h_d01_"
;--- Numero de DATOS de todos los años por cada dia
TOTAL_DATOS = 24 * ANIOS

;Constantes para calcular GLW_neta
epsilon = 0.96
delta = 0.0000000567

; ----------------------------------------;
; ---- Inicializar las variables en 0 ----;

; --- Magnitud del Viento a 10 M ----
MAGNITUD_VIENTO = new ((/365, 348, 617/), float)
MAGNITUD_VIENTO = 0.0

; --- U10 Viento a 10 M ----
U10 = new ((/365, 348, 617/), float)
U10 = 0.0 

; --- V10 Viento a 10 M ---
V10 = new ((/365, 348, 617/), float)
V10 = 0.0

; --- Temperatura del aire a 2 mts ----
T2 = new ((/365, 348, 617/), float)
T2 = 0.0 

; --- RAINC Precipitación  acumulada ---
PREC2 = new ((/365, 348, 617/), float)
PREC2 = 0.0

; --- SWDOWN ---
SWDOWN = new ((/365, 348, 617/), float)
SWDOWN = 0.0

; --- GLW ---
GLW = new ((/365, 348, 617/), float)
GLW= 0.0

; --- PBLH ---
;PBLH = new ((/365, 348, 617/), float)
;PBLH = 0.0

; --- QFX (Evaporación)---
QFX = new ((/365, 348, 617/), float)
QFX = 0.0

; --- Humedad Relativa a 2 mts ----
RH = new ((/365, 348, 617/), float)
RH = 0.0

; -- Recorremos las carpetas por Año ----;
do anio = 1979, 2017    
    print("Año  :  " + anio)
    
    ruta_archivos_anio := BASE + "a" + anio + "/salidas/" + PREFIX_FILE_C1H + anio
    archivos_X_anio := systemfunc("ls " + ruta_archivos_anio + "*")
    num_archivos_anio := dimsizes(archivos_X_anio)
    
    ; ---- Indice para iterar sobre la matriz resultado ---
    j := 0


    do dia = 0, (num_archivos_anio - 1)
        
        ; Como no se encuentra en las salidas el archivo correspondiente al 01-01-1979 comenzamos en el 02-01-1979
        if((dia .eq. 0) .and. (anio .eq. 1979)) then
            j = j + 1
        end if

        ; No consideramos el 29 de Febrero para los años bisisestos
        if(dia .eq. 59 .and. num_archivos_anio .gt. 365) then            
            dia = dia + 1            
        end if
        
        ;--- carga el archivo --- 
        archivo := addfile(archivos_X_anio(dia), "r")
        ; Cargamos las variables
        
        ;Obtenemos la componente U10
        U10_actual := archivo->U10
        ;Obtenemos la componente V10
        U10_sum = dim_sum_n(U10_actual, 0)
        
        ;Obtenemos la componente V10
        V10_actual := archivo->V10            
        V10_sum = dim_sum_n(V10_actual, 0)

        ;Calclamos la magnitud del viento (wind speed) para el dia actual.
        VIENTO_actual := sqrt((U10_actual^2) + (V10_actual^2))
        VIENTO_sum = dim_sum_n(VIENTO_actual, 0)

        ;Obtenemos T2
        T2_actual := archivo->T2
        ;Hacemos la conversion de Kelvin a Celsius
        T2_actual = T2_actual - 273.15
        ;Sumamos sobre la dimension de las horas (dim_sum_n(T2(time, lat, lon), 0) --> T2(lat, lon))
        T2_sum = dim_sum_n(T2_actual, 0)

        RAINC_actual := archivo->RAINC
        RAINNC_actual := archivo->RAINNC
        
        SWDOWN_actual := archivo->SWDOWN
        SWDOWN_sum = dim_sum_n(SWDOWN_actual, 0)

        GLW_actual := archivo->GLW
        ;Se utiliza para calcular GLW neta
        TSK_actual := archivo->TSK

        ;PBLH_actual := archivo->PBLH
        ;PBLH_sum = dim_sum_n(PBLH_actual, 0)

        QFX_actual := archivo->QFX
        QFX_sum = dim_sum_n(QFX_actual, 0)
        
        ;Obtenemos la precipitacion acumulada por dia
        PREC2(j,:,:) = PREC2(j,:,:) + (RAINC_actual(23,:,:) + RAINNC_actual(23,:,:) - (RAINC_actual(0,:,:) + RAINNC_actual(0,:,:)))
        
        ;Obtenemos la radiacionde onda larga neta
        GLW_neta := (GLW_actual - (epsilon * delta * (TSK_actual^4)))
        GLW_sum = dim_sum_n(GLW_neta, 0)

        ;Obtenemos RH para los puntos solicitados
        RH_actual := wrf_user_getvar(archivo, "rh2", -1)
        RH_sum = dim_sum_n(RH_actual, 0)
        
        ; ====================== Sumamos las lecturas del dia correspondiente al total ==========
        T2(j,:,:) = T2(j,:,:) + T2_sum
        U10(j,:,:) = U10(j,:,:) + U10_sum            
        V10(j,:,:) = V10(j,:,:) + V10_sum
        MAGNITUD_VIENTO(j,:,:) = MAGNITUD_VIENTO(j,:,:) + VIENTO_sum
        SWDOWN(j,:,:) = SWDOWN(j,:,:) + SWDOWN_sum
        GLW(j,:,:) = GLW(j,:,:) + GLW_sum
        ;PBLH(j,:,:) = PBLH(j,:,:) + PBLH_sum   
        QFX(j,:,:) = QFX(j,:,:) + QFX_sum 
        RH(j,:,:) = RH(j,:,:) + RH_sum
        
        j = (j + 1)

    end do
 
    print("Termino año ..." + anio)

end do

T2 = (T2 / TOTAL_DATOS)            
U10 = (U10 / TOTAL_DATOS)            
V10 = (V10 / TOTAL_DATOS)
MAGNITUD_VIENTO = (MAGNITUD_VIENTO / TOTAL_DATOS)
PREC2 = (PREC2 / ANIOS)
SWDOWN = (SWDOWN / TOTAL_DATOS)
GLW = (GLW / TOTAL_DATOS)
;PBLH = (PBLH / TOTAL_DATOS)   
QFX = (QFX / TOTAL_DATOS)
RH = (RH / TOTAL_DATOS)

;Constante para hacer conversionde segundos a dias
FACTOR = 24*60*60   ; --> horas * minutos * segundos

;Hacemos la conversion de segundos a dias
QFX = QFX * FACTOR

; ================================================================================
;                           CREAMOS EL ARCHIVO DE SALIDA
; ================================================================================

;----------------------------------
;  Creamos la dimension tiempo 
;----------------------------------
time = createArray(365)
time@standard_name = "time"
time@long_name     = "Time"
time@units         = "days since 2018-01-01 00:00:00"
time@calendar      = "365_day"
time@axis          = "T"
ntime = dimsizes(time)

;------------------------------------------------------------------------------
; Cargamos el archivo donde se encuentran las dimensiones de latitud y longitud 
;------------------------------------------------------------------------------
;archivo_dimensiones := addfile("/KRAKEN/DATOS3/a2000/wrfout_c_anio_d01_2000-01-01_00:00:00.2000", "r")
archivo_dimensiones := addfile("/CHACMOOL/DATOS/a2000/salidas/wrfout_c_anio_d01_2000-01-01_00:00:00.a2000", "r")

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

;------------------------------------
;  Creamos los atributos para VIENTO
;------------------------------------
MAGNITUD_VIENTO@units         = "m s-1"
MAGNITUD_VIENTO@standard_name = "wind_speed"
MAGNITUD_VIENTO@long_name     = "Wind Speed"
MAGNITUD_VIENTO@description   = "Wind Speed at 10m"

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
;  Creamos los atributos para  PREC2
;-------------------------------------
PREC2@units         = "mm dia-1"
PREC2@standard_name = "precipitation"
PREC2@long_name     = "precipitation"
PREC2@description   = "Precipitation"

;-------------------------------------
;  Creamos los atributos para  SWDOWN
;-------------------------------------
SWDOWN@units         = "W m-2"
SWDOWN@standard_name = "shortwave radiation"
SWDOWN@long_name     = "Shortwave radiation"
SWDOWN@description   = "Downward short wave flux at ground surface"

;-------------------------------------
;  Creamos los atributos para GLW
;-------------------------------------
GLW@units         = "W m-2"
GLW@standard_name = "longwave radiation"
GLW@long_name     = "Longwave radiation"
GLW@description   = "Downward long wave flux at ground surface"

;-------------------------------------
;  Creamos los atributos para PBLH
;-------------------------------------
;PBLH@units         = "m"
;PBLH@standard_name = "atmosphere_boundary_layer_thickness"
;PBLH@long_name     = "Boundary layer height"
;PBLH@description   = "PBL Height"

;-------------------------------------
;  Creamos los atributos para QFX
;-------------------------------------
QFX@units         = "mm dia-1"
QFX@standard_name = "water_evaporation_flux"
QFX@long_name     = "Evaporation"
QFX@description   = "Upward Moisture Flux at the Surface"

;--------------------------------
;  Creamos los atributos para RH
;--------------------------------
RH@units         = "%"
RH@standard_name = "relative_humidity"
RH@long_name     = "relative_humidity"
RH@description   = "Relative Humidity"

;==========================================
; Definimos el archivo de salida QFX
;==========================================

;------------------------------------------
;  Creamos el archivo de salida 
;------------------------------------------
diro = "/home/rmedina/out/promediosDiarios/" ; Output directory
filo = "Promedios_Dia_Rv4.nc"    ; Output file
system("rm -f " + diro + filo)               ; remueve el archivo si es que ya existe
fout  = addfile (diro + filo, "c")           ; agrega el archivo de salida

;-----------------------------------------
;  Creamos las variables globales 
;-----------------------------------------
fAtt               = True            ; asignamos atributos al archivo
fAtt@title         = "Promedios diarios"  
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

filevardef(fout, "MAGNITUD_VIENTO" , typeof(MAGNITUD_VIENTO) , (/"time", "Latitude", "Longitude"/)) ;Magnitud del viento m/s
filevardef(fout, "U10"      , typeof(U10) , (/"time", "Latitude", "Longitude"/)) ;Viento U a 10 M
filevardef(fout, "V10"      , typeof(V10) , (/"time", "Latitude", "Longitude"/)) ;Viento V a 10 M
filevardef(fout, "T2"       , typeof(T2)     , (/"time", "Latitude", "Longitude"/))        ;Temperatura del aire a 2m
filevardef(fout, "PREC2"    , typeof(PREC2)  , (/"time", "Latitude", "Longitude"/))        ;Precipitacion
filevardef(fout, "SWDOWN"   , typeof(SWDOWN) , (/"time", "Latitude", "Longitude"/))        ;Radiación de onda corta
filevardef(fout, "GLW"      , typeof(GLW)    , (/"time", "Latitude", "Longitude"/))        ;Radiación de onda larga
;filevardef(fout, "PBLH"     , typeof(PBLH)   , (/"time", "Latitude", "Longitude"/))        ;Altura de capa límite
filevardef(fout, "QFX"      , typeof(QFX)    , (/"time", "Latitude", "Longitude"/))        ;Evaporacion
filevardef(fout, "RH"      , typeof(RH)    , (/"time", "Latitude", "Longitude"/))        ;Humedad Relativa

;----------------------------------------------------------------------
;  Copiar atributos asociados con cada variable a el archivo de salida
;----------------------------------------------------------------------
filevarattdef(fout, "time"     , time)  ;copia los atributosdel tiempo
filevarattdef(fout, "Latitude" , lat )  ;copia los atributos de latitud
filevarattdef(fout, "Longitude", lon )  ;copia los atributos de longitud

filevarattdef(fout, "MAGNITUD_VIENTO" , MAGNITUD_VIENTO  )  ;copia los atributos de la Magnitud del Viento
filevarattdef(fout, "U10"      , U10    )  ;copia los atributos de U10
filevarattdef(fout, "V10"      , V10    )  ;copia los atributos de V10
filevarattdef(fout, "T2"       , T2     )  ;copia los atributos de T2
filevarattdef(fout, "PREC2"    , PREC2  )  ;copia los atributos de RAINC
filevarattdef(fout, "SWDOWN"   , SWDOWN )  ;copia los atributos de SWDOWN
filevarattdef(fout, "GLW"      , GLW    )  ;copia los atributos de GLW
;filevarattdef(fout, "PBLH"     , PBLH   )  ;copia los atributos de PBLH
filevarattdef(fout, "QFX"      , QFX    )  ;copia los atributos de QFX
filevarattdef(fout, "RH"       , RH     )  ;copia los atributos de RH

;------------------------------------------------
;  Obtenemos unicamente los valores de los datos 
;------------------------------------------------
fout->time      = (/time/)
print("copiamos time ....")
fout->Latitude  = (/lat/)
print("copiamos lat ...")
fout->Longitude = (/lon/)
print("Copiamos lon ...")

fout->MAGNITUD_VIENTO  = (/MAGNITUD_VIENTO/)
print("Copiamos MAGNITUD_VIENTO ...")
fout->T2        = (/T2/)
print("Copiamos T2 ...")
fout->U10       = (/U10/)
print("Copiamos U10 ...")
fout->V10       = (/V10/)
print("Copiamos V10 ...")
fout->PREC2     = (/PREC2/)
print("Copiamos PREC2 ...")
fout->SWDOWN    = (/SWDOWN/)
print("Copiamos SWDOWN ...")
fout->GLW       = (/GLW/)
print("Copiamos GLW ... ")
;fout->PBLH      = (/PBLH/)
;print("Copiamos PBLH ... ")
fout->QFX       = (/QFX/)
print("Copiamos QFX ... ")
fout->RH       = (/RH/)
print("Copiamos RH ... ")
