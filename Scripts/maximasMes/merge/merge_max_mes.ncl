begin
;--- Ruta base ---
RUTA = "/home/rmedina/out/maximasMes/prec/"
PREFIJO = "Maximas_Mes_Rv4_PREC-ACC-MES_"
EXT = ".nc"

MES = (/"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"/)

; ----------------------------------------;
; ---- Inicializar las variables en 0 ----;

; --- Magnitud del Viento a 10 M ----
;MAGNITUD_VIENTO_MAX = new ((/12, 348, 617/), float)
;MAGNITUD_VIENTO_MAX = 0.0

; --- U10 Viento a 10 M ----
;U10_MAX = new ((/12, 348, 617/), float)
;U10_MAX = 0.0

; --- V10 Veinto a 10 M ----
;V10_MAX = new ((/12, 348, 617/), float)
;V10_MAX = 0.0

; --- Temperatura del aire a 2 mts por mes ----
;T2_MAX = new ((/12, 348, 617/), float)
;T2_MAX = 0.0

; --- PREC2 Precipitación  acumulada ---
;PREC2_MAX = new ((/12, 348, 617/), float)
;PREC2_MAX = 0.0

; --- PREC2 Precipitación  acumulada por mes ---
PREC2_MAX_MES = new ((/12, 348, 617/), float)
PREC2_MAX_MES = 0.0

; --- PBLH Altura de capa limite ----
;PBLH_MAX = new ((/12, 348, 617/), float)
;PBLH_MAX = 0.0

; --- QFX Evaporacion ----
;QFX_MAX = new ((/12, 348, 617/), float)
;QFX_MAX = 0.0

; --- SWDOWN Radiacion de Onda Corta ----
;SWDOWN_MAX= new ((/12, 348, 617/), float)
;SWDOWN_MAX = 0.0

; --- GLW Radiacion de Onda Larga ----
;GLW_MAX = new ((/12, 348, 617/), float)
;GLW_MAX = 0.0

; --- RH Humedad Relativa ----
;RH_MAX = new ((/12, 348, 617/), float)
;RH_MAX = 0.0

; --- Magnitud del Viento a 10 M ----
;MAGNITUD_VIENTO_PROM_MAX = new ((/12, 348, 617/), float)
;MAGNITUD_VIENTO_PROM_MAX = 0.0

; --- U10 Viento a 10 M ----
;U10_PROM_MAX = new ((/12, 348, 617/), float)
;U10_PROM_MAX = 0.0

; --- V10 Veinto a 10 M ----
;V10_PROM_MAX = new ((/12, 348, 617/), float)
;V10_PROM_MAX = 0.0

; --- Temperatura del aire a 2 mts por mes ----
;T2_PROM_MAX = new ((/12, 348, 617/), float)
;T2_PROM_MAX = 0.0

; --- PREC2 Precipitación  acumulada ---
;PREC2_PROM_MAX = new ((/12, 348, 617/), float)
;PREC2_PROM_MAX = 0.0

; --- PBLH Altura de capa limite ----
;PBLH_PROM_MAX = new ((/12, 348, 617/), float)
;PBLH_PROM_MAX = 0.0

; --- QFX Evaporacion ----
;QFX_PROM_MAX = new ((/12, 348, 617/), float)
;QFX_PROM_MAX = 0.0

; --- SWDOWN Radiacion de Onda Corta ----
;SWDOWN_PROM_MAX = new ((/12, 348, 617/), float)
;SWDOWN_PROM_MAX = 0.0

; --- GLW Radiacion de Onda Larga ----
;GLW_PROM_MAX = new ((/12, 348, 617/), float)
;GLW_PROM_MAX = 0.0

; --- RH Humedad Relativa ----
;RH_PROM_MAX = new ((/12, 348, 617/), float)
;RH_PROM_MAX = 0.0

do i = 0 , 11
    ; Se carga el archivo del  mes correspondiente
    ruta_archivo = RUTA + PREFIJO + MES(i) + EXT
    print("Ruta : " + ruta_archivo)
    archivo := addfile(ruta_archivo, "r")

    ;====== Maximas Absolutas ===================
    ;Se cargan las variables del archivo 
    ;MAGNITUD_VIENTO_MAX_actual := archivo->MAGNITUD_VIENTO_MAX
    ;U10_MAX_actual := archivo->U10_MAX
    ;V10_MAX_actual := archivo->V10_MAX
    ;T2_MAX_actual := archivo->T2_MAX
    ;PREC2_MAX_actual := archivo->PREC2_MAX
    PREC2_MAX_MES_actual := archivo->PREC2_MAX_MES
    ;PBLH_actual := archivo->PBLH_MAX
    ;QFX_MAX_actual := archivo->QFX_MAX
    ;SWDOWN_MAX_actual := archivo->SWDOWN_MAX
    ;GLW_MAX_actual := archivo->GLW_MAX
    ;RH_MAX_actual := archivo->RH_MAX

    ;Copiamos las variables del mes
    ;MAGNITUD_VIENTO_MAX(i,:,:) = MAGNITUD_VIENTO_MAX_actual(0,:,:)
    ;U10_MAX(i,:,:) = U10_MAX_actual(0,:,:)
    ;V10_MAX(i,:,:) = V10_MAX_actual(0,:,:)
    ;T2_MAX(i,:,:) = T2_MAX_actual(0,:,:)
    ;PREC2_MAX(i,:,:) = PREC2_MAX_actual(0,:,:)
    PREC2_MAX_MES(i,:,:) = PREC2_MAX_MES_actual(0,:,:)
    ;PBLH_MAX(i,:,:) = PBLH_MAX_actual(0,:,:)
    ;QFX_MAX(i,:,:) = QFX_MAX_actual(0,:,:)
    ;SWDOWN_MAX(i,:,:) = SWDOWN_MAX_actual(0,:,:)
    ;GLW_MAX(i,:,:) = GLW_MAX_actual(0,:,:)
    ;RH_MAX(i,:,:) = RH_MAX_actual(0,:,:)

    ;======= Promedio de Maximas ==============
    ;MAGNITUD_VIENTO_PROM_MAX_actual := archivo->MAGNITUD_VIENTO_PROM_MAX
    ;U10_PROM_MAX_actual := archivo->U10_PROM_MAX
    ;V10_PROM_MAX_actual := archivo->V10_PROM_MAX
    ;T2_PROM_MAX_actual := archivo->T2_PROM_MAX
    ;PREC2_PROM_MAX_actual := archivo->PREC2_PROM_MAX
    ;PBLH_PROM_MAX_actual := archivo->PBLH_PROM_MAX
    ;QFX_PROM_MAX_actual := archivo->QFX_PROM_MAX
    ;SWDOWN_PROM_MAX_actual := archivo->SWDOWN_PROM_MAX
    ;GLW_PROM_MAX_actual := archivo->GLW_PROM_MAX
    ;RH_PROM_MAX_actual := archivo->RH_PROM_MAX
    
    ;MAGNITUD_VIENTO_PROM_MAX(i,:,:) = MAGNITUD_VIENTO_PROM_MAX_actual(0,:,:)
    ;U10_PROM_MAX(i,:,:) = U10_PROM_MAX_actual(0,:,:)
    ;V10_PROM_MAX(i,:,:) = V10_PROM_MAX_actual(0,:,:)
    ;T2_PROM_MAX(i,:,:) = T2_PROM_MAX_actual(0,:,:)
    ;PREC2_PROM_MAX(i,:,:) = PREC2_PROM_MAX_actual(0,:,:)
    ;PBLH_PROM_MAX(i,:,:) = PBLH_PROM_MAX_actual(0,:,:)
    ;QFX_PROM_MAX(i,:,:) = QFX_PROM_MAX_actual(0,:,:)
    ;SWDOWN_PROM_MAX(i,:,:) = SWDOWN_PROM_MAX_actual(0,:,:)
    ;GLW_PROM_MAX(i,:,:) = GLW_PROM_MAX_actual(0,:,:)
    ;RH_PROM_MAX(i,:,:) = RH_PROM_MAX_actual(0,:,:)

end do

; ================================================================================
;                           CREAMOS EL ARCHIVO DE SALIDA
; ================================================================================

;----------------------------------
;  Creamos la dimension tiempo 
;----------------------------------
time = (/0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334/)
time@standard_name = "time"
time@long_name     = "Time"
time@units         = "days since 2018-01-01 00:00:00"
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
diro = "/home/rmedina/out/maximasMes/"                     ; Output directory
;filo = "Maximas_Mes-Promedio_Maximas_Mes_Rv4.nc"              ; Output file
filo = "Maximas_Mes_Rv4_PREC-Acumulada-Mes.nc"              ; Output file
system("rm -f " + diro + filo)    ; remove if exists
fout  = addfile (diro + filo, "c")  ; open output file

;-----------------------------------------
;  Creamos las variables globales 
;-----------------------------------------
fAtt               = True            ; asignamos atributos al archivo
fAtt@title         = "Maximas absolutas por mes"  
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
filevardef(fout, "PREC2_MAX_MES" , typeof(PREC2_MAX_MES)  , (/"time", "Latitude", "Longitude"/))        ;Precipitacion acumulada mensual
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
filevarattdef(fout, "PREC2_MAX_MES" , PREC2_MAX_MES  )  ;copia los atributos de  PREC2 acumulada mensual
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
;print("copiamos PREC2_PROM_MAX ....")
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