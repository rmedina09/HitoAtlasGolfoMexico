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

;------------------------------------------------------------------
;--- Ruta base ---
BASE = "/KRAKEN/DATOS3/"
PREFIX_FILE_C1H = "wrfout_c1h_d01_"
;--- Total de años ---
TOTAL_ANIOS = 37
;Nombre de los meses
MES = (/"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"/)

; ----------------------------------------;
; ---- Inicializar las variables en 0 ----;

; --- Temperatura del aire a 2 mts por mes ----
T2_TOTAL = new ((/TOTAL_ANIOS, 348, 617/), float)

;---------------------------------------------

folders = systemfunc("ls " + BASE)

nFolders = dimsizes(folders)

nombres_anios = limpiaNombreAnios(nFolders, folders)

mes = mes_i

pos_anio = 0

; -- Recorremos las carpetas por Año ----;
do anio = 1, (nFolders - 2)    
    print("Procesando año " + nombres_anios(anio) + "...")
    
    ;Se obtiene los nombres de los archivos del año y mes correspondiente
    nombres_archivo_mes := PREFIX_FILE_C1H + nombres_anios(anio) + "-" + sprintf("%02g",mes + 1)

    ;es la ruta completa para cargar los archivos
    ruta_archivos_mes := BASE + folders(anio) + "/" + nombres_archivo_mes

    ;El arreglo que contiene las rutas de los archivos 
    archivos_X_mes := systemfunc("ls " + ruta_archivos_mes + "*")        
    
    ;El numero total de archivos para el mes correspondiente           
    num_archivos_mes := dimsizes(archivos_X_mes)
    
    ;Se crean las matrices donde se almacenaran las maximas para cada
    ;dia del mes correspondiente        
    T2_MIN_DIA := new((/num_archivos_mes, 348, 617/),float)
    
    ;Iteramos sobre los archivos que representan las lecturas 
    ;de cada dia del mes correspondiente
    do dia = 0, (num_archivos_mes - 1)
            
        ;--- carga el archivo --- 
        archivo := addfile(archivos_X_mes(dia), "r")
            
        T2_actual := archivo->T2
        
        ;Obtenemos la temperatura minima de cada dia del mes correspondiente
        T2_MIN_DIA(dia,:,:) = dim_min_n(T2_actual, 0)
        
    end do
    
    ;Almacenamos las maximas mensuales en su año correspondiente
    T2_TOTAL(pos_anio,:,:) = dim_min_n(T2_MIN_DIA, 0)
    
    print("Termino ...")
    pos_anio = (pos_anio + 1)

end do

;--- Declaramos las variables de salida ---

; --- Temperatura del aire a 2 mts ----
T2 = new ((/1, 348, 617/), float)
T2(:,:,:) = 0.0

;------ Calcula el promedio de los maximos de todos los años
do anio_i = 0, (TOTAL_ANIOS - 1)

    T2(0,:,:) = T2(0,:,:) + (T2_TOTAL(anio_i,:,:) / TOTAL_ANIOS)
    
end do

; Convertimos de grados kelvin a celsius
T2 = T2(:,:,:) - 273.15 

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
archivo_dimensiones := addfile("/KRAKEN/DATOS3/a2000/wrfout_c_anio_d01_2000-01-01_00:00:00.2000", "r")

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
;  Creamos los atributos para T2 
;--------------------------------
T2@units         = "C"
T2@standard_name = "air_temperature"
T2@long_name     = "Air temperature"
T2@description   = "TEMP at 2 M"

;==========================================
; Definimos el archivo de salida 
;==========================================

;------------------------------------------
;  Creamos el archivo de salida 
;------------------------------------------
diro = "/home/rmedina/out/promediosMinimasMes/"         ; Output directory
filo = "Promedio_Minimas_Mes_" + MES(mes) + ".nc"  ; Output file
system("rm -f " + diro + filo)    ; remove if exists
fout  = addfile (diro + filo, "c")  ; open output file

;-----------------------------------------
;  Creamos las variables globales 
;-----------------------------------------
fAtt               = True            ; asignamos atributos al archivo
fAtt@title         = "Promedios Minimos por Mes ( " + MES(mes) + " )"  
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

filevardef(fout, "T2"       , typeof(T2)     , (/"time", "Latitude", "Longitude"/))        ;Temperatura del aire a 2m

;----------------------------------------------------------------------
;  Copiar atributos asociados con cada variable a el archivo de salida
;----------------------------------------------------------------------
filevarattdef(fout, "time"     , time)  ;copia los atributosdel tiempo
filevarattdef(fout, "Latitude" , lat )  ;copia los atributos de latitud
filevarattdef(fout, "Longitude", lon )  ;copia los atributos de longitud

filevarattdef(fout, "T2"       , T2     )  ;copia los atributos de T2

;------------------------------------------------
;  Obtenemos unicamente los valores de los datos 
;------------------------------------------------
fout->time      = (/time/)
print("copiamos time ....")
fout->Latitude  = (/lat/)
print("copiamos latitud ....")
fout->Longitude = (/lon/)
print("copiamos longitud ....")

fout->T2        = (/T2/)
print("copiamos T2 ....")
