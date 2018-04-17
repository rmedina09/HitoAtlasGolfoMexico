print("Tiempo inicial : "  + get_cpu_time() + "                     -")
print("------------------------------------------------------------")

;--- Ruta base ---
BASE = "/ServerData/KRAKEN-CFSR_Met_v2/"
;--- Prefijo ---
PREFIX_FILE_C1H = "wrfout_c1h_d01_"
;--- Numero de DATOS de todos los años por cada dia
TOTAL_DATOS = 24 * 9

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
function createArray(size)
begin
    myarray = new(size,float)
    do n=0,size-1
        myarray(n) = n 
    end do 
    return myarray
end

; ----------------------------------------;
; ---- Inicializar las variables en 0 ----;
;***
;* NOTA: SOLO SE CALCULA LA VARIABLE DE PRECIPITACION, POR LO QUE SE  
;*       COMENTARAN LAS DEMAS VARIABLES.
;***
; --- U10 Viento a 10 M ----
;U10 = new ((/365, 348, 617/), float)
;U10(:,:,:) = 0.0 

; --- V10 Viento a 10 M ---
;V10 = new ((/365, 348, 617/), float)
;V10(:,:,:) = 0.0

; --- Temperatura del aire a 2 mts ----
;T2 = new ((/365, 348, 617/), float)
;T2(:,:,:) = 0.0 

; --- RAINC Precipitación  acumulada ---
PREC2 = new ((/365, 348, 617/), float)
PREC2(:,:,:) = 0.0

; --- SWDOWN ---
;SWDOWN = new ((/365, 348, 617/), float)
;SWDOWN(:,:,:) = 0.0

; --- GLW ---
;GLW = new ((/365, 348, 617/), float)
;GLW(:,:,:) = 0.0

; --- PBLH ---
;PBLH = new ((/365, 348, 617/), float)
;PBLH(:,:,:) = 0.0

; --- QFX ---
;QFX = new ((/365, 348, 617/), float)
;QFX(:,:,:) = 0.0

;-------------------------------------

time_readFolders = get_cpu_time()

folders = systemfunc("ls " + BASE)

nFolders = dimsizes(folders) - 1

nombres_anios = limpiaNombreAnios(nFolders, folders)

; -- Recorremos las carpetas por Año ----;
do anio = 3, 11;(nFolders - 1)    
    print("Año  :  " + nombres_anios(anio))
    tiempo_anio = get_cpu_time()

    ruta_archivos_anio := BASE + folders(anio) + "/" + PREFIX_FILE_C1H
    archivos_X_anio := systemfunc("ls " + ruta_archivos_anio + "*")
    num_archivos_anio := dimsizes(archivos_X_anio)

    ; ---- Indice para iterar sobre la matriz resultado ---
    j := 0

    do dia = 0, (num_archivos_anio - 1)
        ;print("Dia ... " + j)
        if(dia .eq. 59 .and. num_archivos_anio .eq. 366) then
            dia = dia + 1
            ;print("-------- NO es Año Bisiesto   " + nombres_anios(anio))
        end if
        
        ;--- carga el archivo --- 
        archivo := addfile(archivos_X_anio(dia), "r")
        
        ;U10_actual := archivo->U10
        ;V10_actual := archivo->V10            
        ;T2_actual := archivo->T2
        RAINC_actual := archivo->RAINC
        RAINNC_actual := archivo->RAINNC
        ;SWDOWN_actual := archivo->SWDOWN
        ;GLW_actual := archivo->GLW
        ;PBLH_actual := archivo->PBLH
        ;QFX_actual := archivo->QFX

        if(dia .eq. 0) then
            PREC2(j,:,:) = PREC2(j,:,:) + ((RAINC_actual(23,:,:) + RAINNC_actual(23,:,:)) / TOTAL_DATOS)
        else
            dia_anterior := addfile(archivos_X_anio(dia - 1), "r")     
            RAINC_anterior := dia_anterior->RAINC
            RAINNC_anterior := dia_anterior->RAINNC
            PREC2(j,:,:) = PREC2(j,:,:) + ((RAINC_actual(23,:,:) + RAINNC_actual(23,:,:)) - (RAINC_anterior(23,:,:) + RAINNC_anterior(23,:,:)) / TOTAL_DATOS)
        end if
        
        ;do hora = 0, 23
                
            ;T2(j,:,:) = T2(j,:,:) + ((T2_actual(hora,:,:) - 273.15 ) / TOTAL_DATOS)            
            ;SWDOWN(j,:,:) = SWDOWN(j,:,:) + (SWDOWN_actual(hora,:,:) / TOTAL_DATOS)
            ;GLW(j,:,:) = GLW(j,:,:) + (GLW_actual(hora,:,:) / TOTAL_DATOS)
            ;PBLH(j,:,:) = PBLH(j,:,:) + (PBLH_actual(hora,:,:) / TOTAL_DATOS)   
            ;QFX(j,:,:) = QFX(j,:,:) + (QFX_actual(hora,:,:) / TOTAL_DATOS)
            ;U10(j,:,:) = U10(j,:,:) + (U10_actual(hora,:,:) / TOTAL_DATOS)            
            ;V10(j,:,:) = V10(j,:,:) + (V10_actual(hora,:,:) / TOTAL_DATOS)

        ;end do
        
        j = (j + 1)

    end do
 
    print("Termino ...")

end do

print("-----------------------------------------------------------")
print("Tiempo final : "  + get_cpu_time() + "                     -")
print("------------------------------------------------------------")



; ================================================================================
;                           CREAMOS EL ARCHIVO DE SALIDA
; ================================================================================

;----------------------------------
;  Creamos la dimension tiempo 
;----------------------------------
time = createArray(365)
time@standard_name = "time"
time@long_name     = "Time"
time@units         = "days since 2000-01-01 00:00:00"
time@calendar      = "365_day"
time@axis          = "T"
ntime = dimsizes(time)

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

;=============================================
; Definimos los atributos para cada variable 
;=============================================

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
;  Creamos los atributos para  PREC2
;-------------------------------------
PREC2@units         = "mm"
PREC2@standard_name = "Precipitation"
PREC2@long_name     = "Precipitation"
PREC2@description   = "Precipitation"

;-------------------------------------
;  Creamos los atributos para  SWDOWN
;-------------------------------------
;SWDOWN@units         = "W m-2"
;SWDOWN@standard_name = "shortwave radiation"
;SWDOWN@long_name     = "Shortwave radiation"
;SWDOWN@description   = "Downward short wave flux at ground surface"

;-------------------------------------
;  Creamos los atributos para GLW
;-------------------------------------
;GLW@units         = "W m-2"
;GLW@standard_name = "longwave radiation"
;GLW@long_name     = "Longwave radiation"
;GLW@description   = "Downward long wave flux at ground surface"

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
;QFX@units         = "kg m-2 s-1"
;QFX@standard_name = "Evaporation"
;QFX@long_name     = "Evaporation"
;QFX@description   = "Upward Moisture Flux at the Surface"

;==========================================
; Definimos el archivo de salida QFX
;==========================================

;------------------------------------------
;  Creamos el archivo de salida 
;------------------------------------------
diro = "/home/raul/Hito/out/dia/"                     ; Output directory
filo = "Promedios_Dia_2000-2008_PREC2.nc"             ; Output file
system("rm -f " + diro + filo)    ; remove if exists
fout  = addfile (diro + filo, "c")  ; open output file

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
;filevardef(fout, "U10"      , typeof(U10) , (/"time", "Latitude", "Longitude"/)) ;Viento U a 10 M
;filevardef(fout, "V10"      , typeof(V10) , (/"time", "Latitude", "Longitude"/)) ;Viento V a 10 M
;filevardef(fout, "T2"       , typeof(T2)     , (/"time", "Latitude", "Longitude"/))        ;Temperatura del aire a 2m
filevardef(fout, "PREC2"    , typeof(PREC2)  , (/"time", "Latitude", "Longitude"/))        ;Precipitacion
;filevardef(fout, "SWDOWN"   , typeof(SWDOWN) , (/"time", "Latitude", "Longitude"/))        ;Radiación de onda corta
;filevardef(fout, "GLW"      , typeof(GLW)    , (/"time", "Latitude", "Longitude"/))        ;Radiación de onda larga
;filevardef(fout, "PBLH"     , typeof(PBLH)   , (/"time", "Latitude", "Longitude"/))        ;Altura de capa límite
;filevardef(fout, "QFX"      , typeof(QFX)    , (/"time", "Latitude", "Longitude"/))        ;Evaporacion

;----------------------------------------------------------------------
;  Copiar atributos asociados con cada variable a el archivo de salida
;----------------------------------------------------------------------
filevarattdef(fout, "time"     , time)  ;copia los atributosdel tiempo
filevarattdef(fout, "Latitude" , lat )  ;copia los atributos de latitud
filevarattdef(fout, "Longitude", lon )  ;copia los atributos de longitud
;filevarattdef(fout, "U10"      , U10 )  ;copia los atributos de U10
;filevarattdef(fout, "V10"      , V10 )  ;copia los atributos de V10
;filevarattdef(fout, "T2"       , T2     )  ;copia los atributos de T2
filevarattdef(fout, "PREC2"    , PREC2  )  ;copia los atributos de RAINC
;filevarattdef(fout, "SWDOWN"   , SWDOWN )  ;copia los atributos de SWDOWN
;filevarattdef(fout, "GLW"      , GLW    )  ;copia los atributos de GLW
;filevarattdef(fout, "PBLH"     , PBLH   )  ;copia los atributos de PBLH
;filevarattdef(fout, "QFX"      , QFX    )  ;copia los atributos de QFX

;------------------------------------------------
;  Obtenemos unicamente los valores de los datos 
;------------------------------------------------
fout->time      = (/time/)
print("copiamos time ....")
fout->Latitude  = (/lat/)
print("copiamos lat ...")
fout->Longitude = (/lon/)
print("Copiamos lon ...")
;fout->T2        = (/T2/)
;print("Copiamos T2 ...")
;fout->U10       = (/U10/)
;print("Copiamos U10 ...")
;fout->V10       = (/V10/)
;print("Copiamos V10 ...")
fout->PREC2     = (/PREC2/)
print("Copiamos PREC2 ...")
;fout->SWDOWN    = (/SWDOWN/)
;print("Copiamos SWDOWN ...")
;fout->GLW       = (/GLW/)
;print("Copiamos GLW ... ")
;fout->PBLH      = (/PBLH/)
;print("Copiamos PBLH ... ")
;fout->QFX       = (/QFX/)
;print("Copiamos QFX ... ")

