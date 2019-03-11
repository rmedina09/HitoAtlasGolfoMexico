begin
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

;--- Ruta base ---
;BASE = "/KRAKEN/DATOS3/" ; para la version-3 del re-analisis
BASE = "/CHACMOOL/DATOS/" ; para la version-4 del re-analisis

PREFIX_FILE_C1H = "wrfout_c1h_d01_"

;Nombres de los meses del año
MES = (/"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"/)

;Numero de dias de cada mes 
num_dias_mes = (/31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31/)

;Constantes para calcular GLW_neta
epsilon = 0.96
delta = 0.0000000567

; ----------------------------------------;
; Se craran las matrices donde se guardaran los maximos por año para todo el dominio
; ---- Inicializar las variables en 0 ----;

; Desde 1979 hasta 2017
ANIOS = 39

; --- Magnitud del Viento a 10 M ----
;MAGNITUD_VIENTO_TOTAL = new ((/ANIOS, 348, 617/), float)

; --- U10 Viento a 10 M ----
;U10_TOTAL = new ((/ANIOS, 348, 617/), float)

; --- V10 Veinto a 10 M ----
;V10_TOTAL = new ((/ANIOS, 348, 617/), float)

; --- Temperatura del aire a 2 mts por mes ----
;T2_TOTAL = new ((/ANIOS, 348, 617/), float)

; --- PREC2 Precipitación  acumulada ---
PREC2_TOTAL = new ((/ANIOS, 348, 617/), float)

; --- SWDOWN ---
;SWDOWN_TOTAL = new ((/ANIOS, 348, 617/), float)

; --- GLW ---
;GLW_TOTAL = new ((/ANIOS, 348, 617/), float)

; --- PBLH ---
;PBLH_TOTAL = new ((/ANIOS, 348, 617/), float)

; --- QFX ---
;QFX_TOTAL = new ((/ANIOS, 348, 617/), float)

; --- Humedad Relativa 2m ----
;RH_TOTAL = new ((/ANIOS, 348, 617/), float)

;---------------------------------------------

;Indice del mes que le corresponde procesar
mes = mes_i

;Se crean las martices donde se almacenaran las maximas de diarias del mes correspondiente
;MAG_VIENTO_MAX_DIA = new((/num_dias_mes(mes), 348, 617/),float)
;U10_MAX_DIA = new((/num_dias_mes(mes), 348, 617/),float)
;V10_MAX_DIA = new((/num_dias_mes(mes), 348, 617/),float)
;T2_MAX_DIA = new((/num_dias_mes(mes), 348, 617/),float)
;PREC2_MAX_DIA = new((/num_dias_mes(mes), 348, 617/),float)
;SWDOWN_MAX_DIA = new((/num_dias_mes(mes), 348, 617/),float)
;GLW_MAX_DIA = new((/num_dias_mes(mes), 348, 617/),float)
;PBLH_MAX_DIA = new((/num_dias_mes(mes), 348, 617/),float)
;QFX_MAX_DIA = new((/num_dias_mes(mes), 348, 617/),float)
;RH_MAX_DIA = new((/num_dias_mes(mes), 348, 617/),float)

;Indice que corresponde al año que se esta procesando
pos_anio = 0

print("Procesando mes " + MES(mes) + "...")    

; -- Recorremos las carpetas por Año ----;
do anio = 1979, 2017
    
    print("Procesando año " + anio + "...")    

    nombres_archivo_mes := PREFIX_FILE_C1H + anio + "-" + sprintf("%02g",mes + 1)
    
    ruta_archivos_mes := BASE + "a" + anio + "/salidas/" + nombres_archivo_mes

    archivos_X_mes := systemfunc("ls " + ruta_archivos_mes + "*")        
               
    num_archivos_mes := dimsizes(archivos_X_mes) 

    ;================ Obtenemos la precipitacion acumulada por mes =====================
    ;Cargamos el archivo del primer dia del mes
    archivo_p := addfile(archivos_X_mes(0), "r")
    RAINC_actual_p := archivo_p->RAINC
    RAINNC_actual_p := archivo_p->RAINNC

    ;Cargamos el archivo del ultimo dia del mes
    archivo_u := addfile(archivos_X_mes(num_archivos_mes - 1), "r")
    RAINC_actual_u := archivo_u->RAINC
    RAINNC_actual_u := archivo_u->RAINNC

    PREC2_TOTAL(pos_anio,:,:) = ((RAINC_actual_u(23,:,:) + RAINNC_actual_u(23,:,:)) - (RAINC_actual_p(0,:,:) + RAINNC_actual_p(0,:,:)))
    ;===================================================================================

    ;MAG_VIENTO_MAX_DIA = 0.0
    ;U10_MAX_DIA = 0.0
    ;V10_MAX_DIA = 0.0
    ;T2_MAX_DIA = 0.0
    ;PREC2_MAX_DIA = 0.0
    ;SWDOWN_MAX_DIA = 0.0
    ;GLW_MAX_DIA = 0.0
    ;PBLH_MAX_DIA = 0.0
    ;QFX_MAX_DIA = 0.0
    ;RH_MAX_DIA = 0.0

;    do dia = 0, (num_archivos_mes - 1)
            
        ;--- carga el archivo --- 
;        archivo := addfile(archivos_X_mes(dia), "r")

        ;Obtenemos la humedad relativa
;        RH_actual := wrf_user_getvar(archivo, "rh2", -1)
        
        ;Obtenemos las componentes U10 y V10 del viento    
;        U10_actual := archivo->U10
;        V10_actual := archivo->V10

        ;Calclamos la magnitud del viento (wind speed) para el dia actual.
;        VIENTO_actual := sqrt((U10_actual^2) + (V10_actual^2))

        ;Obtenemos la temperatura a 2m.
;        T2_actual := archivo->T2

        ;Obtenemos las variables para calcular la precipitacion acumulada por dia
;        RAINC_actual := archivo->RAINC
;        RAINNC_actual := archivo->RAINNC

        ;Obtenemos la variable de la radiacion de onda corta
;        SWDOWN_actual := archivo->SWDOWN

        ;Obtenemos la variable de radicaion de onda larga
;        GLW_actual := archivo->GLW
        ;Se utiliza para calcular GLW neta
;        TSK_actual := archivo->TSK
        ;Calculamos la radiacion neta de onda larga
;        GLW_neta := (GLW_actual - (epsilon * delta * TSK_actual^4))

        ;Obtenemos la variable de capa limite
        ;PBLH_actual := archivo->PBLH
        
        ;Obtenemos la variable de evaporacion 
;        QFX_actual := archivo->QFX

        ;Se obtiene la precipitacion acumulada del dia
;        PREC2_MAX_DIA(dia,:,:) = (RAINC_actual(23,:,:) + RAINNC_actual(23,:,:)) - (RAINC_actual(0,:,:) + RAINNC_actual(0,:,:))

        ;Se obtiene la lectura maxima para cada dia de entre sus 24 lecturas horarias
;        MAG_VIENTO_MAX_DIA(dia,:,:) = dim_max_n(VIENTO_actual, 0)
;        U10_MAX_DIA(dia,:,:) = dim_max_n(U10_actual, 0)
;        V10_MAX_DIA(dia,:,:) = dim_max_n(V10_actual, 0)
;        T2_MAX_DIA(dia,:,:) = dim_max_n(T2_actual, 0)        
;        SWDOWN_MAX_DIA(dia,:,:) = dim_max_n(SWDOWN_actual, 0)        
;        GLW_MAX_DIA(dia,:,:) = dim_max_n(GLW_neta, 0)
        ;PBLH_MAX_DIA(dia,:,:) = dim_max_n(PBLH_actual, 0)
;        QFX_MAX_DIA(dia,:,:) = dim_max_n(QFX_actual, 0)
;        RH_MAX_DIA(dia,:,:) = dim_max_n(RH_actual, 0)

;    end do

    ;Se guarda la maxima del mes correspondiente para cada año
    ;Al final se obtienen las maximas mensuales para cada año
;    MAGNITUD_VIENTO_TOTAL(pos_anio,:,:) = dim_max_n(MAG_VIENTO_MAX_DIA, 0)
;    U10_TOTAL(pos_anio,:,:) = dim_max_n(U10_MAX_DIA, 0)
;    V10_TOTAL(pos_anio,:,:) = dim_max_n(V10_MAX_DIA, 0)
;    T2_TOTAL(pos_anio,:,:) = dim_max_n(T2_MAX_DIA, 0)
    ;PREC2_TOTAL(pos_anio,:,:) = dim_max_n(PREC2_MAX_DIA, 0)
;    SWDOWN_TOTAL(pos_anio,:,:) = dim_max_n(SWDOWN_MAX_DIA, 0)
;    GLW_TOTAL(pos_anio,:,:) = dim_max_n(GLW_MAX_DIA, 0)
    ;PBLH_TOTAL(pos_anio,:,:) = dim_max_n(PBLH_MAX_DIA, 0)
;    QFX_TOTAL(pos_anio,:,:) = dim_max_n(QFX_MAX_DIA, 0)
;    RH_TOTAL(pos_anio,:,:) = dim_max_n(RH_MAX_DIA, 0)

    print("Termino ...")
    pos_anio = (pos_anio + 1)

end do

;=========================================================================================
;Se inicializan las matrices donde se guarda el resultado final para las Maximas Absolutas
;Y se obtiene la maxima absoluta de todo el periodo
;=========================================================================================

;MAGNITUD_VIENTO_MAX = new ((/1, 348, 617/), float)
;MAGNITUD_VIENTO_MAX(0,:,:) = dim_max_n(MAGNITUD_VIENTO_TOTAL, 0)

;U10_MAX = new ((/1, 348, 617/), float)
;U10_MAX(0,:,:) = dim_max_n(U10_TOTAL, 0)

;V10_MAX= new ((/1, 348, 617/), float)
;V10_MAX(0,:,:) = dim_max_n(V10_TOTAL, 0)

;T2_MAX = new ((/1, 348, 617/), float)
;T2_MAX(0,:,:) = dim_max_n(T2_TOTAL, 0)

PREC2_MAX_MES = new ((/1, 348, 617/), float)
PREC2_MAX_MES(0,:,:) = dim_max_n(PREC2_TOTAL, 0)

;PBLH_MAX = new ((/1, 348, 617/), float)
;PBLH_MAX(0,:,:) = dim_max_n(PBLH_TOTAL, 0)

;QFX_MAX = new ((/1, 348, 617/), float)
;QFX_MAX(0,:,:) = dim_max_n(QFX_TOTAL, 0)

;SWDOWN_MAX = new ((/1, 348, 617/), float)
;SWDOWN_MAX(0,:,:) = dim_max_n(SWDOWN_TOTAL, 0)

;GLW_MAX = new ((/1, 348, 617/), float)
;GLW_MAX(0,:,:) = dim_max_n(GLW_TOTAL, 0)

;RH_MAX = new ((/1, 348, 617/), float)
;RH_MAX(0,:,:) = dim_max_n(RH_TOTAL, 0)

;=============================================================================================
;Se inicializan las matrices donde se guarda el resultado final para los Promedios de Maximas 
;Obtenemos el Promedio de Maximas Mensuales de cada variable
;=============================================================================================

;MAGNITUD_VIENTO_PROM_MAX = new ((/1, 348, 617/), float)
;MAGNITUD_VIENTO_PROM_MAX(0,:,:) = (dim_sum_n(MAGNITUD_VIENTO_TOTAL, 0) / ANIOS)

;U10_PROM_MAX = new ((/1, 348, 617/), float)
;U10_PROM_MAX(0,:,:) = (dim_sum_n(U10_TOTAL, 0) / ANIOS)

;V10_PROM_MAX= new ((/1, 348, 617/), float)
;V10_PROM_MAX(0,:,:) = (dim_sum_n(V10_TOTAL, 0) / ANIOS)

;T2_PROM_MAX = new ((/1, 348, 617/), float)
;T2_PROM_MAX(0,:,:) = (dim_sum_n(T2_TOTAL, 0) / ANIOS)

;PREC2_PROM_MAX = new ((/1, 348, 617/), float)
;PREC2_PROM_MAX(0,:,:) = (dim_sum_n(PREC2_TOTAL, 0) / ANIOS)

;PBLH_PROM_MAX = new ((/1, 348, 617/), float)
;PBLH_PROM_MAX(0,:,:) = (dim_max_n(PBLH_TOTAL, 0) / ANIOS)

;QFX_PROM_MAX = new ((/1, 348, 617/), float)
;QFX_PROM_MAX(0,:,:) = (dim_sum_n(QFX_TOTAL, 0) / ANIOS)

;SWDOWN_PROM_MAX = new ((/1, 348, 617/), float)
;SWDOWN_PROM_MAX(0,:,:) = (dim_sum_n(SWDOWN_TOTAL, 0) / ANIOS)

;GLW_PROM_MAX = new ((/1, 348, 617/), float)
;GLW_PROM_MAX(0,:,:) = (dim_sum_n(GLW_TOTAL, 0) / ANIOS)

;RH_PROM_MAX = new ((/1, 348, 617/), float)
;RH_PROM_MAX(0,:,:) = (dim_sum_n(RH_TOTAL, 0) / ANIOS)


; =========================================
;  Cambio de unidades
; =========================================
;Cambiamos las unidades de Klevin a Celsius
;T2_MAX = T2_MAX - 273.15 
;T2_PROM_MAX = T2_PROM_MAX - 273.15 

;Constante para hacer conversionde segundos a dias de QFX
;FACTOR = 24*60*60   ; --> horas * minutos * segundos
;Cambiamos las unidades de QFX de segundos a meses
;QFX_MAX = QFX_MAX * FACTOR 
;QFX_PROM_MAX = QFX_PROM_MAX * FACTOR 

; ================================================================================
;                           CREAMOS EL ARCHIVO DE SALIDA
; ================================================================================

;----------------------------------
;  Creamos la dimension tiempo 
;----------------------------------
time = createArray(1)
time@standard_name = "time"
time@long_name     = "Time"
time@units         = "months since 2018-"+ sprintf("%02g",mes + 1) +"-01 00:00:00"
time@calendar      = "noleap"
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

;--------------------------------
;  Creamos los atributos para VIENTO
;--------------------------------
;MAGNITUD_VIENTO_MAX@units         = "m s-1"
;MAGNITUD_VIENTO_MAX@standard_name = "wind_speed"
;MAGNITUD_VIENTO_MAX@long_name     = "Wind Speed"
;MAGNITUD_VIENTO_MAX@description   = "Wind Speed at 10m"

;--------------------------------
;  Creamos los atributos para VIENTO
;--------------------------------
;MAGNITUD_VIENTO_PROM_MAX@units         = "m s-1"
;MAGNITUD_VIENTO_PROM_MAX@standard_name = "wind_speed"
;MAGNITUD_VIENTO_PROM_MAX@long_name     = "Wind Speed"
;MAGNITUD_VIENTO_PROM_MAX@description   = "Wind Speed at 10m"

;--------------------------------
;  Creamos los atributos para U10
;--------------------------------
;U10_MAX@units         = "m s-1"
;U10_MAX@standard_name = "eastward_wind"
;U10_MAX@long_name     = "eastward_wind"
;U10_MAX@description   = "U"

;--------------------------------
;  Creamos los atributos para U10
;--------------------------------
;U10_PROM_MAX@units         = "m s-1"
;U10_PROM_MAX@standard_name = "eastward_wind"
;U10_PROM_MAX@long_name     = "eastward_wind"
;U10_PROM_MAX@description   = "U"

;--------------------------------
;  Creamos los atributos para V10
;--------------------------------
;V10_MAX@units         = "m s-1"
;V10_MAX@standard_name = "northward_wind"
;V10_MAX@long_name     = "northward_wind"
;V10_MAX@description   = "V"

;--------------------------------
;  Creamos los atributos para V10
;--------------------------------
;V10_PROM_MAX@units         = "m s-1"
;V10_PROM_MAX@standard_name = "northward_wind"
;V10_PROM_MAX@long_name     = "northward_wind"
;V10_PROM_MAX@description   = "V"

;--------------------------------
;  Creamos los atributos para T2 
;--------------------------------
;T2_MAX@units         = "C"
;T2_MAX@standard_name = "air_temperature"
;T2_MAX@long_name     = "Air temperature"
;T2_MAX@description   = "TEMP at 2 M"

;--------------------------------
;  Creamos los atributos para T2 
;--------------------------------
;T2_PROM_MAX@units         = "C"
;T2_PROM_MAX@standard_name = "air_temperature"
;T2_PROM_MAX@long_name     = "Air temperature"
;T2_PROM_MAX@description   = "TEMP at 2 M"

;-------------------------------------
;  Creamos los atributos para  
;-------------------------------------
;PREC2_MAX@units         = "mm dia-1"
;PREC2_MAX@standard_name = "Precipitation"
;PREC2_MAX@long_name     = "Precipitation"
;PREC2_MAX@description   = "Precipitation"

;-------------------------------------
;  Creamos los atributos para  
;-------------------------------------
PREC2_MAX_MES@units         = "mm mes-1"
PREC2_MAX_MES@standard_name = "Precipitation"
PREC2_MAX_MES@long_name     = "Precipitation"
PREC2_MAX_MES@description   = "monthly accumulated precipitation"

;-------------------------------------
;  Creamos los atributos para  
;-------------------------------------
;PREC2_PROM_MAX@units         = "mm dia-1"
;PREC2_PROM_MAX@standard_name = "Precipitation"
;PREC2_PROM_MAX@long_name     = "Precipitation"
;PREC2_PROM_MAX@description   = "Precipitation"

;-------------------------------------
;  Creamos los atributos para  
;-------------------------------------
;SWDOWN_MAX@units         = "W m-2"
;SWDOWN_MAX@standard_name = "shortwave radiation"
;SWDOWN_MAX@long_name     = "Shortwave radiation"
;SWDOWN_MAX@description   = "Downward short wave flux at ground surface"

;-------------------------------------
;  Creamos los atributos para  
;-------------------------------------
;SWDOWN_PROM_MAX@units         = "W m-2"
;SWDOWN_PROM_MAX@standard_name = "shortwave radiation"
;SWDOWN_PROM_MAX@long_name     = "Shortwave radiation"
;SWDOWN_PROM_MAX@description   = "Downward short wave flux at ground surface"

;-------------------------------------
;  Creamos los atributos para  
;-------------------------------------
;GLW_MAX@units         = "W m-2"
;GLW_MAX@standard_name = "longwave radiation"
;GLW_MAX@long_name     = "Longwave radiation"
;GLW_MAX@description   = "Downward long wave flux at ground surface"

;-------------------------------------
;  Creamos los atributos para  
;-------------------------------------
;GLW_PROM_MAX@units         = "W m-2"
;GLW_PROM_MAX@standard_name = "longwave radiation"
;GLW_PROM_MAX@long_name     = "Longwave radiation"
;GLW_PROM_MAX@description   = "Downward long wave flux at ground surface"

;-------------------------------------
;  Creamos los atributos para  
;-------------------------------------
;PBLH_MAX@units         = "m"
;PBLH_MAX@standard_name = "atmosphere_boundary_layer_thickness"
;PBLH_MAX@long_name     = "Boundary layer height"
;PBLH_MAX@description   = "PBL Height"

;-------------------------------------
;  Creamos los atributos para  
;-------------------------------------
;PBLH_PROM_MAX@units         = "m"
;PBLH_PROM_MAX@standard_name = "atmosphere_boundary_layer_thickness"
;PBLH_PROM_MAX@long_name     = "Boundary layer height"
;PBLH_PROM_MAX@description   = "PBL Height"

;-------------------------------------
;  Creamos los atributos para QFX
;-------------------------------------
;QFX_MAX@units         = "mm dia-1"
;QFX_MAX@standard_name = "Evaporation"
;QFX_MAX@long_name     = "Evaporation"
;QFX_MAX@description   = "Upward Moisture Flux at the Surface"

;-------------------------------------
;  Creamos los atributos para QFX
;-------------------------------------
;QFX_PROM_MAX@units         = "mm dia-1"
;QFX_PROM_MAX@standard_name = "Evaporation"
;QFX_PROM_MAX@long_name     = "Evaporation"
;QFX_PROM_MAX@description   = "Upward Moisture Flux at the Surface"

;--------------------------------
;  Creamos los atributos para U 
;--------------------------------
;RH_MAX@units         = "%"
;RH_MAX@standard_name = "relative_humidity"
;RH_MAX@long_name     = "relative_humidity"
;RH_MAX@description   = "Relative Humidity"

;--------------------------------
;  Creamos los atributos para U 
;--------------------------------
;RH_PROM_MAX@units         = "%"
;RH_PROM_MAX@standard_name = "relative_humidity"
;RH_PROM_MAX@long_name     = "relative_humidity"
;RH_PROM_MAX@description   = "Relative Humidity"

;==========================================
; Definimos el archivo de salida 
;==========================================

;------------------------------------------
;  Creamos el archivo de salida 
;------------------------------------------
diro = "/home/rmedina/out/maximasMes/prec/"  ; Output directory
filo = "Maximas_Mes_Rv4_PREC-ACC-MES_" + MES(mes) + ".nc"              ; Output file
system("rm -f " + diro + filo)    ; remove if exists
fout  = addfile (diro + filo, "c")  ; open output file

;-----------------------------------------
;  Creamos las variables globales 
;-----------------------------------------
fAtt               = True            ; asignamos atributos al archivo
fAtt@title         = "Maximas por mes (" + MES(mes) + ")"  
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

;filevardef(fout, "MAGNITUD_VIENTO_MAX" , typeof(MAGNITUD_VIENTO_MAX) , (/"time", "Latitude", "Longitude"/))  ;Magnitud del viento m/s
;filevardef(fout, "U10_MAX"      , typeof(U10_MAX)    , (/"time", "Latitude", "Longitude"/)) ;Viento U a 10 M
;filevardef(fout, "V10_MAX"      , typeof(V10_MAX)    , (/"time", "Latitude", "Longitude"/)) ;Viento V a 10 M
;filevardef(fout, "T2_MAX"       , typeof(T2_MAX)     , (/"time", "Latitude", "Longitude"/))        ;Temperatura del aire a 2m
;filevardef(fout, "PREC2_MAX"    , typeof(PREC2_MAX)  , (/"time", "Latitude", "Longitude"/))        ;Precipitacion
filevardef(fout, "PREC2_MAX_MES"    , typeof(PREC2_MAX_MES)  , (/"time", "Latitude", "Longitude"/))        ;Precipitacion acumulada mensual
;filevardef(fout, "SWDOWN_MAX"   , typeof(SWDOWN_MAX) , (/"time", "Latitude", "Longitude"/))        ;Radiación de onda corta
;filevardef(fout, "GLW_MAX"      , typeof(GLW_MAX)    , (/"time", "Latitude", "Longitude"/))        ;Radiación de onda larga
;filevardef(fout, "PBLH_MAX"     , typeof(PBLH_MAX)   , (/"time", "Latitude", "Longitude"/))        ;Altura de capa límite
;filevardef(fout, "QFX_MAX"      , typeof(QFX_MAX)    , (/"time", "Latitude", "Longitude"/))        ;Evaporacion
;filevardef(fout, "RH_MAX"       , typeof(RH_MAX)     , (/"time", "Latitude", "Longitude"/))        ;Humedad Relativa

;filevardef(fout, "MAGNITUD_VIENTO_PROM_MAX" , typeof(MAGNITUD_VIENTO_PROM_MAX) , (/"time", "Latitude", "Longitude"/))  ;Magnitud del viento m/s
;filevardef(fout, "U10_PROM_MAX"      , typeof(U10_PROM_MAX)    , (/"time", "Latitude", "Longitude"/)) ;Viento U a 10 M
;filevardef(fout, "V10_PROM_MAX"      , typeof(V10_PROM_MAX)    , (/"time", "Latitude", "Longitude"/)) ;Viento V a 10 M
;filevardef(fout, "T2_PROM_MAX"       , typeof(T2_PROM_MAX)     , (/"time", "Latitude", "Longitude"/))        ;Temperatura del aire a 2m
;filevardef(fout, "PREC2_PROM_MAX"    , typeof(PREC2_PROM_MAX)  , (/"time", "Latitude", "Longitude"/))        ;Precipitacion
;filevardef(fout, "SWDOWN_PROM_MAX"   , typeof(SWDOWN_PROM_MAX) , (/"time", "Latitude", "Longitude"/))        ;Radiación de onda corta
;filevardef(fout, "GLW_PROM_MAX"      , typeof(GLW_PROM_MAX)    , (/"time", "Latitude", "Longitude"/))        ;Radiación de onda larga
;filevardef(fout, "PBLH_PROM_MAX"     , typeof(PBLH_PROM_MAX)   , (/"time", "Latitude", "Longitude"/))        ;Altura de capa límite
;filevardef(fout, "QFX_PROM_MAX"      , typeof(QFX_PROM_MAX)    , (/"time", "Latitude", "Longitude"/))        ;Evaporacion
;filevardef(fout, "RH_PROM_MAX"       , typeof(RH_PROM_MAX)     , (/"time", "Latitude", "Longitude"/))        ;Humedad Relativa

;----------------------------------------------------------------------
;  Copiar atributos asociados con cada variable a el archivo de salida
;----------------------------------------------------------------------
filevarattdef(fout, "time"     , time)  ;copia los atributosdel tiempo
filevarattdef(fout, "Latitude" , lat )  ;copia los atributos de latitud
filevarattdef(fout, "Longitude", lon )  ;copia los atributos de longitud

;filevarattdef(fout, "MAGNITUD_VIENTO_MAX" , MAGNITUD_VIENTO_MAX )  ;copia los atributos de Magnitud del Viento
;filevarattdef(fout, "U10_MAX"      , U10_MAX    )  ;copia los atributos de U10
;filevarattdef(fout, "V10_MAX"      , V10_MAX    )  ;copia los atributos de V10
;filevarattdef(fout, "T2_MAX"       , T2_MAX     )  ;copia los atributos de T2
;filevarattdef(fout, "PREC2_MAX"    , PREC2_MAX  )  ;copia los atributos de PREC2
filevarattdef(fout, "PREC2_MAX_MES"    , PREC2_MAX_MES  )  ;copia los atributos de PREC2 acumulada mensual
;filevarattdef(fout, "SWDOWN_MAX"   , SWDOWN_MAX )  ;copia los atributos de SWDOWN
;filevarattdef(fout, "GLW_MAX"      , GLW_MAX    )  ;copia los atributos de GLW
;filevarattdef(fout, "PBLH_MAX"     , PBLH_MAX   )  ;copia los atributos de PBLH
;filevarattdef(fout, "QFX_MAX"      , QFX_MAX    )  ;copia los atributos de QFX
;filevarattdef(fout, "RH_MAX"       , RH_MAX     )    ;copia los atributos de Humedad Relativa

;filevarattdef(fout, "MAGNITUD_VIENTO_PROM_MAX" , MAGNITUD_VIENTO_PROM_MAX )  ;copia los atributos de Magnitud del Viento
;filevarattdef(fout, "U10_PROM_MAX"      , U10_PROM_MAX    )  ;copia los atributos de U10
;filevarattdef(fout, "V10_PROM_MAX"      , V10_PROM_MAX    )  ;copia los atributos de V10
;filevarattdef(fout, "T2_PROM_MAX"       , T2_PROM_MAX     )  ;copia los atributos de T2
;filevarattdef(fout, "PREC2_PROM_MAX"    , PREC2_PROM_MAX  )  ;copia los atributos de RAINC
;filevarattdef(fout, "SWDOWN_PROM_MAX"   , SWDOWN_PROM_MAX )  ;copia los atributos de SWDOWN
;filevarattdef(fout, "GLW_PROM_MAX"      , GLW_PROM_MAX    )  ;copia los atributos de GLW
;filevarattdef(fout, "PBLH_PROM_MAX"     , PBLH_PROM_MAX   )  ;copia los atributos de PBLH
;filevarattdef(fout, "QFX_PROM_MAX"      , QFX_PROM_MAX    )  ;copia los atributos de QFX
;filevarattdef(fout, "RH_PROM_MAX"       , RH_PROM_MAX     )    ;copia los atributos de Humedad Relativa

;------------------------------------------------
;  Obtenemos unicamente los valores de los datos 
;------------------------------------------------
fout->time      = (/time/)
print("copiamos time ....")
fout->Latitude  = (/lat/)
print("copiamos latitud ....")
fout->Longitude = (/lon/)
print("copiamos longitud ....")

;fout->MAGNITUD_VIENTO_MAX = (/MAGNITUD_VIENTO_MAX/)
;print("Copiamos MAGNITUD_VIENTO_MAX ...")
;fout->U10_MAX             = (/U10_MAX/)
;print("Copiamos U10_MAX ...")
;fout->V10_MAX             = (/V10_MAX/)
;print("Copiamos V10_MAX ...")
;fout->T2_MAX              = (/T2_MAX/)
;print("copiamos T2_MAX ....")
;fout->PREC2_MAX           = (/PREC2_MAX/)
;print("copiamos PREC2_MAX ....")
fout->PREC2_MAX_MES           = (/PREC2_MAX_MES/)
print("copiamos PREC2_MAX_MES ....")
;fout->SWDOWN_MAX          = (/SWDOWN_MAX/)
;print("copiamos SWDOWN_MAX ....")
;fout->GLW_MAX             = (/GLW_MAX/)
;print("copiamos GLW_MAX ....")
;fout->PBLH_MAX           = (/PBLH_MAX/)
;print("copiamos PBLH_MAX ....")
;fout->QFX_MAX             = (/QFX_MAX/)
;print("Copiamos QFX_MAX ... ")
;fout->RH_MAX              = (/RH_MAX/)
;print("copiamos RH_MAX ....")

;fout->MAGNITUD_VIENTO_PROM_MAX  = (/MAGNITUD_VIENTO_PROM_MAX/)
;print("Copiamos MAGNITUD_VIENTO_PROM_MAX ...")
;fout->U10_PROM_MAX              = (/U10_PROM_MAX/)
;print("Copiamos U10_PROM_MAX ...")
;fout->V10_PROM_MAX              = (/V10_PROM_MAX/)
;print("Copiamos V10_PROM_MAX ...")
;fout->T2_PROM_MAX               = (/T2_PROM_MAX/)
;print("copiamos T2_PROM_MAX ....")
;fout->PREC2_PROM_MAX            = (/PREC2_PROM_MAX/)
;print("copiamos PREC2_PROM_MAX| ....")
;fout->SWDOWN_PROM_MAX           = (/SWDOWN_PROM_MAX/)
;print("copiamos SWDOWN_PROM_MAX ....")
;fout->GLW_PROM_MAX              = (/GLW_PROM_MAX/)
;print("copiamos GLW_PROM_MAX ....")
;fout->PBLH_PROM_MAX            = (/PBLH_PROM_MAX/)
;print("copiamos PBLH_PROM_MAX ....")
;fout->QFX_PROM_MAX              = (/QFX_PROM_MAX/)
;print("Copiamos QFX_PROM_MAX ... ")
;fout->RH_PROM_MAX               = (/RH_PROM_MAX/)
;print("copiamos RH_PROM_MAX ....")

end
