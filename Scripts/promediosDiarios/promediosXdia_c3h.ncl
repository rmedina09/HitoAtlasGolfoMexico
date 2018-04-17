print("Hora de inicio :  " + systemfunc ("date"))
;--- Ruta base ---
BASE = "/ServerData/KRAKEN-CFSR_Met_v2/"
;--- Prefijo ---
PREFIX_FILE_C3h = "wrfout_c3h_d01_"
;--- Numero de DATOS de todos los años por cada dia
ANIOS = 9
TOTAL_DATOS = 8 * ANIOS

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
U = new ((/365, 29, 348, 618/), float)
U(:,:,:,:) = 0.0

; --- Viento V ---
V = new ((/365, 29, 349, 617/), float)
V(:,:,:,:) = 0.0

; --- Cobertura de nubes ---
QCLOUD = new ((/365, 29, 348, 617/), float)
QCLOUD(:,:,:,:) = 0.0

;-----------------------------------------

time_readFolders = get_cpu_time()

folders = systemfunc("ls " + BASE)

nFolders = dimsizes(folders) - 1

nombres_anios = limpiaNombreAnios(nFolders, folders)



; -- Recorremos las carpetas por Año ----;
do anio = 3, 11 ;(nFolders - 1)    
    print("Año  :  " + nombres_anios(anio))
    tiempo_anio = get_cpu_time()

    ruta_archivos_anio := BASE + folders(anio) + "/" + PREFIX_FILE_C3h

    archivos_X_anio := systemfunc("ls " + ruta_archivos_anio + "*")        
               
    num_archivos_anio := dimsizes(archivos_X_anio)

    ; ---- Indice para iterar sobre la matriz resultado ---
    j := 0

    do dia = 0, (num_archivos_anio - 1)

        if(dia .eq. 59 .and. num_archivos_anio .eq. 366) then
            dia = dia + 1
        end if
        
        ;--- carga el archivo --- 
        archivo := addfile(archivos_X_anio(dia), "r")
            
        U_actual := archivo->U
        V_actual := archivo->V
        QCLOUD_actual := archivo->QCLOUD
       
        do hora = 0, 7
                
            U(j,:,:,:) = U(j,:,:,:) + (U_actual(hora,:,:,:) / TOTAL_DATOS)               
            V(j,:,:,:) = V(j,:,:,:) + (V_actual(hora,:,:,:) / TOTAL_DATOS)
            QCLOUD(j,:,:,:) = QCLOUD(j,:,:,:) + (QCLOUD_actual(hora,:,:,:) / TOTAL_DATOS)

        end do
        
        j = (j + 1)

    end do

    print("Termino ...")

end do

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
U@standard_name = "eastward_wind"
U@long_name     = "eastward_wind"
U@description   = "U"

;-------------------------------------
;  Creamos los atributos para  V
;-------------------------------------
V@units         = "m s-1"
V@standard_name = "northward_wind"
V@long_name     = "northward_wind"
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
diro = "/ServerData/OutTempRaul/promediosXdia/" ; Output directory
;diro = "/home/raul/Hito/out/dia/"
filo = "Promedios_Dia_c3h_bat.nc"                   ; Output file
system("rm -f " + diro + filo)                  ; remove if exists
fout  = addfile (diro + filo, "c")              ; open output file

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
filevardef(fout, "time"     , typeof(time) , "time")   ;Dimension tiempo
filevardef(fout, "Latitude" , typeof(lat)  , "Latitude") ;Dimension latitud
filevardef(fout, "Longitude", typeof(lon)  , "Longitude") ;Dimension longitud
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