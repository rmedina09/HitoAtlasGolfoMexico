;--- Ruta base ---
RUTA = "/home/rmedina/out/promediosMesAnio/"
PREFIJO = "Promedios_Mes_Anio_"
EXT = ".nc"

;Ruta de los promedios mensuales totales
RUTA_ARCHIVOS_PROM_MES = "/home/rmedina/out/promediosMes/Promedios_Mes.nc"

; ----------------------------------------;
; ---- Inicializar las variables en 0 ----;

;Cargamos el archivo con los promedios mensules de todo el periodo
archivo_promedios_mes = addfile(RUTA_ARCHIVOS_PROM_MES, "r")

;Obtenemos las variables
U10_prom = archivo_promedios_mes->U10
V10_prom = archivo_promedios_mes->V10
T2_prom = archivo_promedios_mes->T2
PREC2_prom = archivo_promedios_mes->PREC2

do anio=1980, 2016

    ;Construimos la ruta para el año correspondiente
    ruta_archivo := RUTA + PREFIJO + anio + EXT
    print(ruta_archivo)
    ;Cargamos el archivo 
    archivo := addfile(ruta_archivo, "r")

    ;Obtenemos las variables
    U10_actual := archivo->U10
    V10_actual := archivo->V10
    T2_actual := archivo->T2
    PREC2_actual := archivo->PREC2    

    U10 := U10_actual(:,:,:) - U10_prom(:,:,:)
    V10 := V10_actual(:,:,:) - V10_prom(:,:,:) 
    T2 := T2_actual(:,:,:) - T2_prom(:,:,:) 
    PREC2 := PREC2_actual(:,:,:) - PREC2_prom(:,:,:) 

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
    diro = "/home/rmedina/out/anomalias/"   ; Output directory
    filo = "Anomalias_Anio_" + anio + ".nc"                  ; Output file
    system("rm -f " + diro + filo)             ; remove if exists
    fout  = addfile (diro + filo, "c")         ; open output file

    ;-----------------------------------------
    ;  Creamos las variables globales 
    ;-----------------------------------------
    fAtt               = True            ; asignamos atributos al archivo
    fAtt@title         = "Anomalias del Año " + anio + ""  
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



end do

