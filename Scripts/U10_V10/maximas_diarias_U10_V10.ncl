;--- Ruta base ---
BASE = "/ServerData/KRAKEN-CFSR_Met_v2/"
;--- Prefijo ---
PREFIX_FILE_C1H = "wrfout_c1h_d01_"

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

; --- U10 Viento a 10 M ----
U10_TOTAL = new ((/9, 365, 348, 617/), float)

; --- V10 Viento a 10 M  ----
V10_TOTAL = new ((/9, 365, 348, 617/), float)

;---------------------------------------------

time_readFolders = get_cpu_time()

folders = systemfunc("ls " + BASE)

nFolders = dimsizes(folders) - 1

nombres_anios = limpiaNombreAnios(nFolders, folders)
pos_anio = 0

; -- Recorremos las carpetas por Año ----;
do anio = 3, 11 ;(nFolders - 1)    
    print("Año  :  " + nombres_anios(anio))

    ruta_archivos_anio := BASE + folders(anio) + "/" + PREFIX_FILE_C1H
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

        U10_actual := archivo->U10
        V10_actual := archivo->V10
                
        U10_TOTAL(pos_anio,j,:,:) = dim_max_n(U10_actual, 0)    
        V10_TOTAL(pos_anio,j,:,:) = dim_max_n(V10_actual, 0)    
        
        j = (j + 1)

    end do

    print("Termino ...")
    pos_anio = (pos_anio + 1)

end do

;------ Calcula los maximos entre todos los años  ------

U10 = dim_max_n(U10_TOTAL, 0)
V10 = dim_max_n(V10_TOTAL, 0)

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

;==========================================
; Definimos el archivo de salida 
;==========================================

;------------------------------------------
;  Creamos el archivo de salida 
;------------------------------------------
diro = "/ServerData/OutTempRaul/maximasDiarias/"                     ; Output directory
filo = "maximas_diarias_2000-2008_U10_V10.nc"             ; Output file
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
filevardef(fout, "U10"      , typeof(U10) , (/"time", "Latitude", "Longitude"/)) ;Viento U a 10 M
filevardef(fout, "V10"      , typeof(V10) , (/"time", "Latitude", "Longitude"/)) ;Viento V a 10 M

;----------------------------------------------------------------------
;  Copiar atributos asociados con cada variable a el archivo de salida
;----------------------------------------------------------------------
filevarattdef(fout, "time"     , time)  ;copia los atributosdel tiempo
filevarattdef(fout, "Latitude" , lat )  ;copia los atributos de latitud
filevarattdef(fout, "Longitude", lon )  ;copia los atributos de longitud
filevarattdef(fout, "U10"      , U10 )  ;copia los atributos de U10
filevarattdef(fout, "V10"      , V10 )  ;copia los atributos de V10

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

