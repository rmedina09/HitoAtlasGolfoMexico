begin
;--- Ruta base ---
;BASE = "/KRAKEN/DATOS3/" ; para la version-3 del re-analisis
BASE = "/CHACMOOL/DATOS/" ; para la version-4 del re-analisis

PREFIX_FILE_C1H = "wrfout_c1h_d01_"
epsilon = 0.96
delta = 0.0000000567

;-- creamos el arreglo que contiene el numero total de archivos pr mes ---
total = new(12, float)

;Numero de anios a ejecutar
ANIOS =  39

total(0) = 24*31*ANIOS         ; Enero 
total(1) = (24*28*29) + (24*29*10)   ; Febreo
total(2) = 24*31*ANIOS         ; Marzo
total(3) = 24*30*ANIOS         ; Abril
total(4) = 24*31*ANIOS         ; Mayo 
total(5) = 24*30*ANIOS         ; Junio
total(6) = 24*31*ANIOS         ; Julio
total(7) = 24*31*ANIOS         ; Agosto
total(8) = 24*30*ANIOS         ; Septiembre
total(9) = 24*31*ANIOS         ; Octubre
total(10) = 24*30*ANIOS        ; Noviembre
total(11) = 24*31*ANIOS        ; Diciembre

; ----------------------------------------;
; ---- Inicializar las variables en 0 ----;

; --- Magnitud del Viento a 10 M ----
;MAGNITUD_VIENTO = new ((/12, 348, 617/), float)
;MAGNITUD_VIENTO = 0.0

; --- U10 ----
;U10 = new ((/12, 348, 617/), float)
;U10 = 0.0

; --- V10 ----
;V10 = new ((/12, 348, 617/), float)
;V10 = 0.0

; --- Temperatura del aire a 2 mts por mes ----
;T2 = new ((/12, 348, 617/), float)
;T2 = 0.0

; --- PREC2 Precipitación  acumulada ---
;PREC2 = new ((/12, 348, 617/), float)
;PREC2 = 0.0

; --- SWDOWN ---
;SWDOWN = new ((/12, 348, 617/), float)
;SWDOWN = 0.0

; --- GLW ---
;GLW = new ((/12, 348, 617/), float)
;GLW = 0.0

; --- PBLH ---
;PBLH = new ((/12, 348, 617/), float)
;PBLH = 0.0

; --- QFX ---
QFX = new ((/12, 348, 617/), float)
QFX = 0.0

; --- Presion superficial ---
;PSFC = new ((/12, 348, 617/), float)
;PSFC = 0.0

; --- Temperatura superficial del mar ----
;SST = new ((/12, 348, 617/), float)
;SST = 0.0

; --- Humedad Relativa 2m ----
;RH = new ((/12, 348, 617/), float)
;RH = 0.0
;-------------------------------------

nTotal = dimsizes(total)

; -- Recorremos las carpetas por Año ----;

do anio = 1979, 2017
    print("Procesando año " + anio + "...")

    do mes = 0, (nTotal - 1)

        nombres_archivo_mes := PREFIX_FILE_C1H + anio + "-" + sprintf("%02g",mes + 1)
       
        ruta_archivos_mes := BASE + "a" + anio + "/salidas/" + nombres_archivo_mes
        ;ruta_archivos_mes := BASE + "a" + anio + "/" + nombres_archivo_mes

        archivos_X_mes := systemfunc("ls " + ruta_archivos_mes + "*")        
              
        num_archivos_mes := dimsizes(archivos_X_mes)

        ;Cargamos el archivo del primer dia del mes
        ;archivo_p := addfile(archivos_X_mes(0), "r")
        ;RAINC_actual_p := archivo_p->RAINC
        ;RAINNC_actual_p := archivo_p->RAINNC

        ;Cargamos el archivo del ultimo dia del mes
        ;archivo_u := addfile(archivos_X_mes(num_archivos_mes - 1), "r")
        ;RAINC_actual_u := archivo_u->RAINC
        ;RAINNC_actual_u := archivo_u->RAINNC

        ;PREC2(mes,:,:) = PREC2(mes,:,:) + (((RAINC_actual_u(23,:,:) + RAINNC_actual_u(23,:,:)) - (RAINC_actual_p(0,:,:) + RAINNC_actual_p(0,:,:))) / ANIOS)

        do dia = 0, (num_archivos_mes - 1)
            
            ;--- carga el archivo --- 
            archivo := addfile(archivos_X_mes(dia), "r")

            ; Calculamos la humedad relativa
            ;RH_actual := wrf_user_getvar(archivo, "rh2", -1)
            ;RH_sum = dim_sum_n(RH_actual, 0)

            ;Obtenemos la componente U10
            ;U10_actual := archivo->U10
            ;U10_sum = dim_sum_n(U10_actual, 0)
        
            ;Obtenemos la componente V10
            ;V10_actual := archivo->V10            
            ;V10_sum = dim_sum_n(V10_actual, 0)

            ;Calclamos la magnitud del viento (wind speed) para el dia actual.
            ;VIENTO_actual := sqrt((U10_actual^2) + (V10_actual^2))
            ;VIENTO_sum = dim_sum_n(VIENTO_actual, 0)

            ;Obtenemos T2
            ;T2_actual := archivo->T2
            ;Sumamos sobre la dimension de las horas (dim_sum_n(T2(time, lat, lon), 0) --> T2(lat, lon))
            ;T2_sum = dim_sum_n(T2_actual, 0)
            ;Cambiamos las unidades de Klevin a Celsius
            ;T2_actual = T2_actual - 273.15 

            ;Obtenemos SWDOWN
            ;SWDOWN_actual := archivo->SWDOWN
            ;SWDOWN_sum = dim_sum_n(SWDOWN_actual, 0)

            ;Obtenemos GLW
            ;GLW_actual := archivo->GLW
            ;Se utiliza para calcular GLW neta
            ;TSK_actual := archivo->TSK

            ;Obtenemos altura de capa limite (PBLH)
            ;PBLH_actual := archivo->PBLH
            ;PBLH_sum = dim_sum_n(PBLH_actual, 0)
            
            ;Obtenemos la evaporacion (QFX)
            QFX_actual := archivo->QFX
            QFX_sum = dim_sum_n(QFX_actual, 0)

            ;Calculamos la longitud de onda larga
            ;GLW_neta := (GLW_actual - (epsilon * delta * (TSK_actual^4)))
            ;GLW_sum = dim_sum_n(GLW_neta, 0)

            ;SST_actual := archivo->SST
            ;SST_sum = dim_sum_n(SST_actual, 0)

            ;PSFC_actual := archivo->PSFC
            ;PSFC_sum = dim_sum_n(PSFC_actual, 0)
            
            ; ====================== Sumamos las lecturas del dia correspondiente al total ==========
                            
            ;RH(mes,:,:) = RH(mes,:,:) + (RH_sum / total(mes)) 
            ;MAGNITUD_VIENTO(mes,:,:) = MAGNITUD_VIENTO(mes,:,:) + (VIENTO_sum / total(mes))
            ;U10(mes,:,:) = U10(mes,:,:) + (U10_sum / total(mes)) 
            ;V10(mes,:,:) = V10(mes,:,:) + (V10_sum / total(mes))
            ;T2(mes,:,:) = T2(mes,:,:) + (T2_sum / total(mes))               
            ;SWDOWN(mes,:,:) = SWDOWN(mes,:,:) + (SWDOWN_sum / total(mes))
            ;GLW(mes,:,:) = GLW(mes,:,:) + (GLW_sum / total(mes))
            ;PBLH(mes,:,:) = PBLH(mes,:,:) + (PBLH_sum / total(mes))
            ;QFX(mes,:,:) = QFX(mes,:,:) + (QFX_sum / total(mes))            
            ;SST(mes,:,:) = SST(mes,:,:) + (SST_sum / total(mes)) 
            ;PSFC(mes,:,:) = PSFC(mes,:,:) + (PSFC_sum / total(mes)) 

        end do

    end do

    print("Termino ...")

end do

;Cambiamos las unidades de Klevin a Celsius
;T2 = T2 - 273.15 

;Cambiamos las unidades de Klevin a Celsius
;SST = SST - 273.15

;Cambiamos las unidades de Pa a hPa, dividiendo entre 100
;PSFC = (PSFC / 100)

;Constante para hacer conversionde segundos a dias de QFX
;FACTOR = 24.0*60.0*60.0   ; --> horas * minutos * segundos

; Arreglo qu econtiene el numero de dias por mes
;num_dias_mes = (/31.0, 28.0, 31.0, 30.0, 31.0, 30.0, 31.0, 31.0, 30.0, 31.0, 30.0, 31.0/)

;Cambiamos las unidades de QFX de segundos a meses
;do i  = 0, 11
;    QFX(i,:,:) = QFX(i,:,:) * FACTOR * num_dias_mes(i)
;end do

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
archivo_dimensiones := addfile("/CHACMOOL/DATOS/a2000/salidas/wrfout_c_anio_d01_2000-01-01_00:00:00.a2000", "r")
;archivo_dimensiones := addfile("/KRAKEN/DATOS3/a2000/wrfout_c_anio_d01_2000-01-01_00:00:00.2000", "r")
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
;MAGNITUD_VIENTO@units         = "m s-1"
;MAGNITUD_VIENTO@standard_name = "wind_speed"
;MAGNITUD_VIENTO@long_name     = "Wind Speed"
;MAGNITUD_VIENTO@description   = "Wind Speed at 10m"

;--------------------------------
;  Creamos los atributos para U10
;--------------------------------
;U10@units         = "m s-1"
;U10@standard_name = "eastward_wind"
;U10@long_name     = "eastward_wind"
;U10@description   = "U"

;--------------------------------
;  Creamos los atributos para V10
;--------------------------------
;V10@units         = "m s-1"
;V10@standard_name = "northward_wind"
;V10@long_name     = "northward_wind"
;V10@description   = "V"

;--------------------------------
;  Creamos los atributos para T2 
;--------------------------------
;T2@units         = "C"
;T2@standard_name = "air_temperature"
;T2@long_name     = "Air temperature"
;T2@description   = "TEMP at 2 M"

;-------------------------------------
;  Creamos los atributos para  
;-------------------------------------
;PREC2@units         = "mm mes-1"
;PREC2@standard_name = "precipitation_amount"
;PREC2@long_name     = "Accumulated precipitation"
;PREC2@description   = "Precipitation"

;-------------------------------------
;  Creamos los atributos para  
;-------------------------------------
;SWDOWN@units         = "W m-2"
;SWDOWN@standard_name = "shortwave radiation"
;SWDOWN@long_name     = "Shortwave radiation"
;SWDOWN@description   = "Downward short wave flux at ground surface"

;-------------------------------------
;  Creamos los atributos para  
;-------------------------------------
;GLW@units         = "W m-2"
;GLW@standard_name = "longwave radiation"
;GLW@long_name     = "Longwave radiation"
;GLW@description   = "Downward long wave flux at ground surface"

;-------------------------------------
;  Creamos los atributos para  
;-------------------------------------
;PBLH@units         = "m"
;PBLH@standard_name = "atmosphere_boundary_layer_thickness"
;PBLH@long_name     = "Boundary layer height"
;PBLH@description   = "PBL Height"

;-------------------------------------
;  Creamos los atributos para QFX
;-------------------------------------
QFX@units         = "mm mes-1"
QFX@standard_name = "Evaporation"
QFX@long_name     = "Evaporation"
QFX@description   = "Upward Moisture Flux at the Surface"

;--------------------------------
;  Creamos los atributos para PSFC
;--------------------------------
;PSFC@units         = "hPa"
;PSFC@standard_name = "sfc pressure"
;PSFC@long_name     = "sfc pressure"
;PSFC@description   = "Surface Pressure"

;--------------------------------
;  Creamos los atributos para SST
;--------------------------------
;SST@units         = "C"
;SST@standard_name = "sea_surface_temperature"
;SST@long_name     = "sea_surface_temperature"
;SST@description   = "Sea Surface Temperature"

;--------------------------------
;  Creamos los atributos para U 
;--------------------------------
;RH@units         = "%"
;RH@standard_name = "relative_humidity"
;RH@long_name     = "relative_humidity"
;RH@description   = "Relative Humidity"

;==========================================
; Definimos el archivo de salida 
;==========================================

;------------------------------------------
;  Creamos el archivo de salida 
;------------------------------------------
diro = "/home/rmedina/out/verificacion_PromMes/"   ; Output directory
filo = "Promedios_Mes_Rv4_MAG_QFX_4_sindividir.nc"        ; Output file
system("rm -f " + diro + filo)             ; remove if exists
fout  = addfile (diro + filo, "c")         ; open output file

;-----------------------------------------
;  Creamos las variables globales 
;-----------------------------------------
fAtt               = True            ; asignamos atributos al archivo
fAtt@title         = "Promedios mensuales"  
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

;filevardef(fout, "MAGNITUD_VIENTO" , typeof(MAGNITUD_VIENTO) , (/"time", "Latitude", "Longitude"/))  ;Magnitud del viento m/s
;filevardef(fout, "U10"      , typeof(U10) , (/"time", "Latitude", "Longitude"/)) ;Viento U a 10 M
;filevardef(fout, "V10"      , typeof(V10) , (/"time", "Latitude", "Longitude"/)) ;Viento V a 10 M
;filevardef(fout, "T2"       , typeof(T2)     , (/"time", "Latitude", "Longitude"/))        ;Temperatura del aire a 2m
;filevardef(fout, "PREC2"    , typeof(PREC2)  , (/"time", "Latitude", "Longitude"/))        ;Precipitacion
;filevardef(fout, "SWDOWN"   , typeof(SWDOWN) , (/"time", "Latitude", "Longitude"/))        ;Radiación de onda corta
;filevardef(fout, "GLW"      , typeof(GLW)    , (/"time", "Latitude", "Longitude"/))        ;Radiación de onda larga
;filevardef(fout, "PBLH"     , typeof(PBLH)   , (/"time", "Latitude", "Longitude"/))        ;Altura de capa límite
filevardef(fout, "QFX"      , typeof(QFX)    , (/"time", "Latitude", "Longitude"/))        ;Evaporacion
;filevardef(fout, "SST"      , typeof(SST)    , (/"time", "Latitude", "Longitude"/))        ;Temperatura superficial del mar
;filevardef(fout, "PSFC"      , typeof(PSFC)  , (/"time", "Latitude", "Longitude"/))        ;Presion superficie
;filevardef(fout, "RH"       , typeof(RH)   , (/"time", "Latitude", "Longitude"/))        ;Humedad Relativa

;----------------------------------------------------------------------
;  Copiar atributos asociados con cada variable a el archivo de salida
;----------------------------------------------------------------------
filevarattdef(fout, "time"     , time)  ;copia los atributosdel tiempo
filevarattdef(fout, "Latitude" , lat )  ;copia los atributos de latitud
filevarattdef(fout, "Longitude", lon )  ;copia los atributos de longitud

;filevarattdef(fout, "MAGNITUD_VIENTO"       , MAGNITUD_VIENTO     )  ;copia los atributos de Magnitud del Viento
;filevarattdef(fout, "U10"      , U10 )  ;copia los atributos de U10
;filevarattdef(fout, "V10"      , V10 )  ;copia los atributos de V10
;filevarattdef(fout, "T2"       , T2     )  ;copia los atributos de T2
;filevarattdef(fout, "PREC2"    , PREC2  )  ;copia los atributos de RAINC
;filevarattdef(fout, "SWDOWN"   , SWDOWN )  ;copia los atributos de SWDOWN
;filevarattdef(fout, "GLW"      , GLW    )  ;copia los atributos de GLW
;filevarattdef(fout, "PBLH"     , PBLH   )  ;copia los atributos de PBLH
filevarattdef(fout, "QFX"      , QFX    )  ;copia los atributos de QFX
;filevarattdef(fout, "SST"      , SST    )  ;copia los atributos de SST
;filevarattdef(fout, "PSFC"     , PSFC   )  ;copia los atributos de PSFC
;filevarattdef(fout, "RH"       , RH  )    ;copia los atributos de Humedad Relativa

;------------------------------------------------
;  Obtenemos unicamente los valores de los datos 
;------------------------------------------------
fout->time      = (/time/)
print("copiamos time ....")
fout->Latitude  = (/lat/)
print("copiamos lat ...")
fout->Longitude = (/lon/)
print("Copiamos lon ...")

;fout->MAGNITUD_VIENTO        = (/MAGNITUD_VIENTO/)
;print("Copiamos MAGNITUD_VIENTO ...")
;fout->U10        = (/U10/)
;print("Copiamos U10 ...")
;fout->V10     = (/V10/)
;print("Copiamos V10 ...")
;fout->T2        = (/T2/)
;print("Copiamos T2 ...")
;fout->PREC2     = (/PREC2/)
;print("Copiamos PREC2 ...")
;fout->SWDOWN    = (/SWDOWN/)
;print("Copiamos SWDOWN ...")
;fout->GLW       = (/GLW/)
;print("Copiamos GLW ... ")
;fout->PBLH      = (/PBLH/)
;print("Copiamos PBLH ... ")
fout->QFX       = (/QFX/)
print("Copiamos QFX ... ")
;fout->SST        = (/SST/)
;print("Copiamos SST ...")
;fout->PSFC        = (/PSFC/)
;print("Copiamos PSFC ...")
;fout->RH         = (/RH/)
;print("copiamos RH ....")

end