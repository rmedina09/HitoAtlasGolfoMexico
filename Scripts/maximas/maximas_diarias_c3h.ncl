print("Hora de inicio :  " + systemfunc ("date"))
;--- Ruta base ---
BASE = "/ServerData/KRAKEN-CFSR_Met_v2/"
;--- Prefijo ---
PREFIX_FILE_C3H = "wrfout_c3h_d01_"

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

; --- Viento U ----
U_TOTAL = new ((/9, 365, 29, 348, 618/), float)

; --- Viento V ---
V_TOTAL = new ((/9, 365, 29, 349, 617/), float)

; --- Cobertura de nubes ---
QCLOUD_TOTAL = new ((/9, 365, 29, 348, 617/), float)

;---------------------------------------

time_readFolders = get_cpu_time()

folders = systemfunc("ls " + BASE)

nFolders = dimsizes(folders) - 1

nombres_anios = limpiaNombreAnios(nFolders, folders)
pos_anio = 0
; -- Recorremos las carpetas por Año ----;
do anio = 3, 11 ;(nFolders - 1)    
    print("Año  :  " + nombres_anios(anio))

    tiempo_anio = get_cpu_time()

    ruta_archivos_anio := BASE + folders(anio) + "/" + PREFIX_FILE_C3H
    archivos_X_anio := systemfunc("ls " + ruta_archivos_anio + "*")        
    num_archivos_anio := dimsizes(archivos_X_anio)
    ; ---- Indice para iterar sobre la matriz resultado ---
    j := 0

    do dia = 0, (num_archivos_anio - 1)

        ;--- carga el archivo --- 
        if(dia .eq. 59 .and. num_archivos_anio .eq. 366) then
            dia = dia + 1
        end if

        archivo := addfile(archivos_X_anio(dia), "r")

        U_actual := archivo->U
        V_actual := archivo->V
        QCLOUD_actual := archivo->QCLOUD
        
        U_TOTAL(pos_anio,j,:,:,:) = dim_max_n(U_actual, 0)    
        V_TOTAL(pos_anio,j,:,:,:) = dim_max_n(V_actual, 0)
        QCLOUD_TOTAL(pos_anio,j,:,:,:) = dim_max_n(QCLOUD_actual, 0)        

        j = (j + 1)

    end do

    print("Termino ...")
    pos_anio = (pos_anio + 1)

end do

;------ Calcula los maximos entre todos los años
U = dim_max_n(U_TOTAL, 0)
V = dim_max_n(V_TOTAL, 0)
QCLOUD = dim_max_n(QCLOUD_TOTAL, 0)
print("Termino de calcular ...")

print("-----------------------------------------------------------")
print("Tiempo total : "  + (get_cpu_time() - time_readFolders) + "                     -")
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
;------------------------------------------------------------------------------
; Cargamos el archivo donde se encuentran las dimensiones de la profundidad 
;------------------------------------------------------------------------------
archivo_dim_depth := addfile("/ServerData/KRAKEN-CFSR_Met_v2/a2000/wrfout_c15d_d01_2000-01-01_00:00:00.2000", "r")

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

;----------------------------------------
;   Obtenemos la dimension de Latitud U
;----------------------------------------
latAuxU = archivo_dimensiones->XLAT_U
latU = latAuxU(0,:,0)
delete_VarAtts(latU,-1)
nlatU = dimsizes(latU)

latU@standard_name =  "latitude"
latU@long_name     =  "Latitude U"
latU@units         =  "degrees_north"

;-------------------------------------
;  Obtenemos la dimension de Longitud U
;-------------------------------------
lonAuxU = archivo_dimensiones->XLONG_U
lonU = lonAuxU(0,0,:)
delete_VarAtts(lonU,-1)
nlonU = dimsizes(lonU)

lonU@standard_name =  "longitude"
lonU@long_name     =  "Longitude U"
lonU@units         =  "degrees_east"

;----------------------------------------
;   Obtenemos la dimension de Latitud V
;----------------------------------------
latAuxV = archivo_dimensiones->XLAT_V
latV = latAuxV(0,:,0)
delete_VarAtts(latV,-1)
nlatV = dimsizes(latV)

latV@standard_name =  "latitude"
latV@long_name     =  "Latitude V"
latV@units         =  "degrees_north"

;-------------------------------------
;  Obtenemos la dimension de Longitud V
;-------------------------------------
lonAuxV = archivo_dimensiones->XLONG_V
lonV = lonAuxV(0,0,:)
delete_VarAtts(lonV,-1)
nlonV = dimsizes(lonV)

lonV@standard_name =  "longitude"
lonV@long_name     =  "Longitude V"
lonV@units         =  "degrees_east"

;-------------------------------------
;  Obtenemos la dimension Depth (bottom_top)
;-------------------------------------
depthAux = archivo_dim_depth->ZNU
depth = depthAux(0,:)
delete_VarAtts(depth,-1)
ndepth = dimsizes(depth)

depth@standard_name =  "depth"
depth@long_name     =  "depth ZNU"
depth@units         =  ""
depth@axis          =  "Z"

;=============================================
; Definimos los atributos para cada variable 
;=============================================

;--------------------------------
;  Creamos los atributos para U 
;--------------------------------
U@units         = "m s-1"
U@standard_name = "U"
U@long_name     = "U"
U@description   = "U"

;-------------------------------------
;  Creamos los atributos para  V
;-------------------------------------
V@units         = "m s-1"
V@standard_name = "V"
V@long_name     = "V"
V@description   = "V"

;-------------------------------------
;  Creamos los atributos para  QCLOUD
;-------------------------------------
QCLOUD@units         = "kg kg-1"
QCLOUD@standard_name = "cloud_liquid_water_mixing_ratio"
QCLOUD@long_name     = "cloud_liquid_water_mixing_ratio"
QCLOUD@description   = "Cloud coverage"

;==========================================
; Definimos el archivo de salida 
;==========================================

;------------------------------------------
;  Creamos el archivo de salida 
;------------------------------------------
diro = "/home/raul/Hito/out/dia/"                     ; Output directory
filo = "maximas_diarias_c3h.nc"             ; Output file
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
dimNames = (/"time", "Latitude", "Longitude", "Depth", "Latitude_U", "Longitude_U", "Latitude_V", "Longitude_V" /)
dimSizes = (/  -1  ,  nlat     ,  nlon      ,  ndepth,  nlatU      ,  nlonU       ,  nlatV      ,  nlonV /)
dimUnLim = (/ True ,  False    ,  False     ,  False ,  False      ,  False       ,  False      ,  False /)
filedimdef(fout, dimNames, dimSizes, dimUnLim)

;----------------------------------------------------------------------
;  Pre-cargamos las variables que se escribiran en el archivo de salida 
;----------------------------------------------------------------------
filevardef(fout, "time"     , typeof(time), "time")   ;Dimension tiempo
filevardef(fout, "Latitude" , typeof(lat) , "Latitude") ;Dimension latitud
filevardef(fout, "Longitude", typeof(lon) , "Longitude") ;Dimension longitud
filevardef(fout, "Depth"    , typeof(depth), "Depth")     ;Dimension profundidad

filevardef(fout, "Latitude_U" , typeof(lat)    , "Latitude_U") ;Dimension latitud U
filevardef(fout, "Longitude_U", typeof(lon)    , "Longitude_U") ;Dimension longitud U
filevardef(fout, "Latitude_V" , typeof(lat)    , "Latitude_V") ;Dimension latitud V
filevardef(fout, "Longitude_V", typeof(lon)    , "Longitude_V") ;Dimension longitud V
filevardef(fout, "U"          , typeof(U)      , (/"time", "Depth", "Latitude_U", "Longitude_U"/))        ;Viento U
filevardef(fout, "V"          , typeof(V)      , (/"time", "Depth", "Latitude_V", "Longitude_V"/))        ;Viento V
filevardef(fout, "QCLOUD"     , typeof(QCLOUD) , (/"time", "Depth", "Latitude", "Longitude"/))            ;Cobertura de nubes

;----------------------------------------------------------------------
;  Copiar atributos asociados con cada variable a el archivo de salida
;----------------------------------------------------------------------
filevarattdef(fout, "time"     , time)  ;copia los atributosdel tiempo
filevarattdef(fout, "Latitude" , lat )  ;copia los atributos de latitud
filevarattdef(fout, "Longitude", lon )  ;copia los atributos de longitud
filevarattdef(fout, "Depth"    , depth) ;copia los atributos de profundidad

filevarattdef(fout, "Latitude_U" , latU )    ;copia los atributos de latitud U
filevarattdef(fout, "Longitude_U", lonU )    ;copia los atributos de longitud U
filevarattdef(fout, "Latitude_V" , latV )    ;copia los atributos de latitud V
filevarattdef(fout, "Longitude_V", lonV )    ;copia los atributos de longitud V
filevarattdef(fout, "U"          , U     )   ;copia los atributos de T2
filevarattdef(fout, "V"          , V  )      ;copia los atributos de RAINC
filevarattdef(fout, "QCLOUD"     , QCLOUD )  ;copia los atributos de SWDOWN

;------------------------------------------------
;  Obtenemos unicamente los valores de los datos 
;------------------------------------------------
fout->time      = (/time/)
print("copiamos time ....")

fout->Latitude  = (/lat/)
print("copiamos lat ...")

fout->Longitude = (/lon/)
print("copiamos lon ...")

fout->Depth = (/depth/)
print("copiamos depth")

fout->Latitude_U  = (/latU/)
print("copiamos latitud U....")

fout->Longitude_U = (/lonU/)
print("copiamos longitud U....")

fout->Latitude_V  = (/latV/)
print("copiamos latitud V....")

fout->Longitude_V = (/lonV/)
print("copiamos longitud V....")

fout->U         = (/U/)
print("copiamos U ....")

fout->V         = (/V/)
print("copiamos V....")

fout->QCLOUD    = (/QCLOUD/)
print("copiamos QCLOUD....")

print("Hora de termino :  " + systemfunc("date"))