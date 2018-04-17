print("Hora de inicio :  " + systemfunc ("date"))

;--- Ruta base ---
BASE = "/ServerData/KRAKEN-CFSR_Met_v2/"
PREFIX_FILE_C1H = "wrfout_c1h_d01_"
MES = (/"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"/)

; --- funcion que limpia los nombres de los años ---
function limpiaNombreAnios(tamanio, original)
begin
    miArreglo = new(tamanio,string)
    do n=0,tamanio-1        
        miArreglo(n) = str_split(original(n), "a")
    end do 
    return miArreglo
end

;------------------------------------------------------------------
; --- Funcion que crea un arreglo de una dimension ---
function createArray0(size)
begin
    myarray = new(size,float)
    do n=0,size-1
        myarray(n) = n
    end do 
    return myarray
end

;-- creamos el arreglo que contiene el numero total de archivos pr mes ---
total = new(12, float)

ANIOS =  9

total(0) = 31 * ANIOS               ; Enero 
total(1) = 28 * 6 + 29 * 3   ; Febreo
total(2) = 31 * ANIOS               ; Marzo
total(3) = 30 * ANIOS               ; Abril
total(4) = 31 * ANIOS               ; Mayo 
total(5) = 30 * ANIOS               ; Junio
total(6) = 31 * ANIOS               ; Julio
total(7) = 31 * ANIOS               ; Agosto
total(8) = 30 * ANIOS               ; Septiembre
total(9) = 31 * ANIOS               ; Octubre
total(10) = 30 * ANIOS              ; Noviembre
total(11) = 31 * ANIOS              ; Diciembre

; ----------------------------------------;
; ---- Inicializar las variables en 0 ----;

; --- U10 ----
U10 = new ((/12, 24, 348, 617/), float)
U10(:,:,:,:) = 0.0 

; --- V10 ----
V10 = new ((/12, 24, 348, 617/), float)
V10(:,:,:,:) = 0.0

; --- Temperatura del aire a 2 mts por mes ----
T2 = new ((/12, 24, 348, 617/), float)
T2(:,:,:,:) = 0.0 

; --- PREC2 Precipitación  acumulada ---
PREC2 = new ((/12, 24, 348, 617/), float)
PREC2(:,:,:,:) = 0.0

; --- SWDOWN ---
SWDOWN = new ((/12, 24, 348, 617/), float)
SWDOWN(:,:,:,:) = 0.0

; --- GLW ---
GLW = new ((/12, 24, 348, 617/), float)
GLW(:,:,:,:) = 0.0

; --- PBLH ---
PBLH = new ((/12, 24, 348, 617/), float)
PBLH(:,:,:,:) = 0.0

; --- QFX ---
QFX = new ((/12, 24, 348, 617/), float)
QFX(:,:,:) = 0.0

;-------------------------------------

nTotal = dimsizes(total)

time_readFolders = get_cpu_time()

folders = systemfunc("ls " + BASE)

nFolders = dimsizes(folders) - 1

nombres_anios = limpiaNombreAnios(nFolders, folders)

; -- Recorremos las carpetas por Año ----;
do anio = 3, 11;(nFolders - 1)    
    print("Año  :  " + nombres_anios(anio))

    do mes = 0, (nTotal - 1)

        nombres_archivo_mes := PREFIX_FILE_C1H + nombres_anios(anio) + "-" + sprintf("%02g",mes + 1)
       
        ruta_archivos_mes := BASE + folders(anio) + "/" + nombres_archivo_mes

        archivos_X_mes := systemfunc("ls " + ruta_archivos_mes + "*")        
               
        num_archivos_mes := dimsizes(archivos_X_mes)

        do dia = 0, (num_archivos_mes - 1)
            
            ;--- carga el archivo --- 
            archivo := addfile(archivos_X_mes(dia), "r")
            
            U10_actual := archivo->U10
            V10_actual := archivo->V10
            T2_actual := archivo->T2
            RAINC_actual := archivo->RAINC
            RAINNC_actual := archivo->RAINNC
            SWDOWN_actual := archivo->SWDOWN
            GLW_actual := archivo->GLW
            PBLH_actual := archivo->PBLH
            QFX := archivo->QFX

            U10(mes,:,:,:) = U10(mes,:,:,:) + (U10_actual(:,:,:) / total(mes))
            V10(mes,:,:,:) = V10(mes,:,:,:) + (V10_actual(:,:,:) / total(mes))
            T2(mes,:,:,:) = T2(mes,:,:,:) + ((T2_actual(:,:,:) - 273.15 ) / total(mes))
            PREC2(mes,:,:,:) = PREC2(mes,:,:,:) + ((RAINC_actual(:,:,:) + RAINNC_actual(:,:,:))/ total(mes))
            SWDOWN(mes,:,:,:) = SWDOWN(mes,:,:,:) + (SWDOWN_actual(:,:,:) / total(mes))
            GLW(mes,:,:,:) = GLW(mes,:,:,:) + (GLW_actual(:,:,:) / total(mes))
            PBLH(mes,:,:,:) = PBLH(mes,:,:,:) + (PBLH_actual(:,:,:) / total(mes))
            QFX(mes,:,:,:) = QFX(mes,:,:,:) + (QFX_actual(:,:,:) / total(mes))

        end do

    end do

end do

print("-----------------------------------------------------------")
print("Tiempo total : "  + (get_cpu_time() - time_readFolders) + "                     -")
print("------------------------------------------------------------")

;------------------------------------------------------------------------------
; Cargamos el archivo donde se encuentran las dimensiones de latitud y longitud 
;------------------------------------------------------------------------------
archivo_dimensiones := addfile("/ServerData/KRAKEN-CFSR_Met_v2/a2000/wrfout_c_anio_d01_2000-01-01_00:00:00.2000", "r")

;----------------------------------------
;   Obtenemos la dimension de Latitud 
;----------------------------------------
latAux = archivo_dimensiones->XLAT
lat = latAux(0,:,1)
delete_VarAtts(lat,-1)
nlat = dimsizes(lat)

lat@standard_name =  "latitude"
lat@long_name     =  "Latitude"
lat@units         =  "degrees_north"

;-------------------------------------
;  Obtenemos la dimension de Longitud 
;-------------------------------------
lonAux = archivo_dimensiones->XLONG
lon = lonAux(0,1,:)
delete_VarAtts(lon,-1)
nlon = dimsizes(lon)

lon@standard_name =  "longitude"
lon@long_name     =  "Longitude"
lon@units         =  "degrees_east"

;============================================================
; Funcion que crea 12 archivos que representan los 12 meses,
; para alguna variable
;============================================================
function creaArchivosPorMes(u10, v10, t2, prec2, swdown, glw, pblh, qfx, lat, lon)
begin
    nlat = dimsizes(lat)
    nlon = dimsizes(lon)

    do mes = 0, 11
        print("Creando archivos  de " + MES(mes) + " ....")

        ; --- U10 ----
        U10 := u10(mes,:,:,:)

        ; --- V10 ----
        V10 := v10(mes,:,:,:)

        ; --- Temperatura del aire a 2 mts por mes ----
        T2 := t2(mes,:,:,:)
        
        ; --- PREC2 Precipitación  acumulada ---
        PREC2 := prec2(mes,:,:,:)

        ; --- SWDOWN ---
        SWDOWN := swdown(mes,:,:,:)

        ; --- GLW ---
        GLW := glw(mes,:,:,:)

        ; --- PBLH ---
        PBLH := pblh(mes,:,:,:) 

        ; --- QFX ---
        QFX := qfx(mes,:,:,:)

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

        ;printVarSummary(T2)

        ;-------------------------------------
        ;  Creamos los atributos para  
        ;-------------------------------------
        PREC2@units         = "mm"
        PREC2@standard_name = "Precipitation"
        PREC2@long_name     = "Precipitation"
        PREC2@description   = "Precipitation"

        ;-------------------------------------
        ;  Creamos los atributos para  
        ;-------------------------------------
        SWDOWN@units         = "W m-2"
        SWDOWN@standard_name = "shortwave radiation"
        SWDOWN@long_name     = "Shortwave radiation"
        SWDOWN@description   = "Downward short wave flux at ground surface"

        ;-------------------------------------
        ;  Creamos los atributos para  
        ;-------------------------------------
        GLW@units         = "W m-2"
        GLW@standard_name = "longwave radiation"
        GLW@long_name     = "Longwave radiation"
        GLW@description   = "Downward long wave flux at ground surface"

        ;-------------------------------------
        ;  Creamos los atributos para  
        ;-------------------------------------
        PBLH@units         = "m"
        PBLH@standard_name = "atmosphere_boundary_layer_thickness"
        PBLH@long_name     = "Boundary layer height"
        PBLH@description   = "PBL Height"

        ;-------------------------------------
        ;  Creamos los atributos para QFX
        ;-------------------------------------
        QFX@units         = "kg m-2 s-1"
        QFX@standard_name = "Evaporation"
        QFX@long_name     = "Evaporation"
        QFX@description   = "Upward Moisture Flux at the Surface"

        ;----------------------------------
        ;  Creamos la dimension tiempo 
        ;----------------------------------
        time = createArray0(24)
        time@standard_name = "time"
        time@long_name     = "Time"
        time@units         = "hours since 2000-"+ sprintf("%02g",mes + 1) +"-01 00:00:00"
        time@calendar      = "gregorian"
        time@axis          = "T"

        ;------------------------------------------
        ;  Creamos el archivo de salida 
        ;------------------------------------------
        diro = "/ServerData/OutTempRaul/promediosHorariosXmes/"         ; Output directory
        filo = "Promedios_Mes_" + MES(mes) + ".nc"             ; Output file
        system("rm -f " + diro + filo)    ; remove if exists
        fout  = addfile (diro + filo, "c")  ; open output file

        ;-----------------------------------------
        ;  Creamos las variables globales 
        ;-----------------------------------------
        fAtt               = True            ; asignamos atributos al archivo
        fAtt@title         = "Promedios horarios de " + MES(mes)  
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
        filevardef(fout, "SWDOWN"   , typeof(SWDOWN) , (/"time", "Latitude", "Longitude"/))        ;Radiación de onda corta
        filevardef(fout, "GLW"      , typeof(GLW)    , (/"time", "Latitude", "Longitude"/))        ;Radiación de onda larga
        filevardef(fout, "PBLH"     , typeof(PBLH)   , (/"time", "Latitude", "Longitude"/))        ;Altura de capa límite
        filevardef(fout, "QFX"      , typeof(QFX)    , (/"time", "Latitude", "Longitude"/))        ;Evaporacion

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
        filevarattdef(fout, "SWDOWN"   , SWDOWN )  ;copia los atributos de SWDOWN
        filevarattdef(fout, "GLW"      , GLW    )  ;copia los atributos de GLW
        filevarattdef(fout, "PBLH"     , PBLH   )  ;copia los atributos de PBLH
        filevarattdef(fout, "QFX"      , QFX    )  ;copia los atributos de QFX

        ;------------------------------------------------
        ;  Obtenemos unicamente los valores de los datos 
        ;------------------------------------------------
        fout->time      = (/time/)
        fout->Latitude  = (/lat/)
        fout->Longitude = (/lon/)
        fout->U10       = (/U10/)
        fout->V10       = (/V10/)
        fout->T2        = (/T2/)
        fout->PREC2     = (/PREC2/)
        fout->SWDOWN    = (/SWDOWN/)
        fout->GLW       = (/GLW/)
        fout->PBLH      = (/PBLH/)
        fout->QFX       = (/QFX/)

    end do

    return True

end

;---------------------------------------
; Creamos los 12 archivos de salida
;--------------------------------------
valor = creaArchivosPorMes(U10, V10, T2, PREC2, SWDOWN, GLW, PBLH, QFX, lat, lon)

print("Hora de termino :  " + systemfunc("date"))

