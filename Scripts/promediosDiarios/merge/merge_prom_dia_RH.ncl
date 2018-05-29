;-----------------------------------------------------
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
RUTA = "/home/rmedina/out/promediosDiarios/rh/"
PREFIJO = "Promedios_Dia_c3h_RH_"
EXT = ".nc"

; Se cargan en los archivos
ARCHIVOS := systemfunc("ls " + RUTA + "*")
; Número de archivos
num_archivos := dimsizes(ARCHIVOS)

; ----------------------------------------;
; ---- Inicializar las variables en 0 ----;

; --- Humedad Relativa RH ----
RH = new ((/365, 348, 617/), float)
RH(:,:,:) = 0.0

; Se iteran sobre todos los archivos 
do i=0 , (num_archivos - 1)
    ;Se carga el archivo 
    ruta_archivo := RUTA + PREFIJO + i + EXT 
    archivo := addfile(ruta_archivo, "r")

    ;Se obtiene la variable RH
    RH_actual := archivo->RH
    
    do j = 0, 4
        ;Se calcula la posicion inicial
        posicion := (i*5) + j
        
        ;Se copia los valores de la matriz con 5 dias a la matriz total
        RH(posicion,:,:) = RH_actual(j,:,:)
    end do
    
end do

; ================================================================================
;                           CREAMOS EL ARCHIVO DE SALIDA
; ================================================================================

;----------------------------------
;  Creamos la dimension tiempo 
;----------------------------------
time = createArray(365)
time@standard_name = "time"
time@long_name     = "Time"
time@units         = "days since 2018-01-01 00:00:00"
time@calendar      = "365_day"
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
;  Creamos los atributos para U 
;--------------------------------
RH@units         = "%"
RH@standard_name = "relative_humidity"
RH@long_name     = "relative_humidity"
RH@description   = "Relative Humidity"

;==========================================
; Definimos el archivo de salida 
;==========================================

;------------------------------------------
;  Creamos el archivo de salida 
;------------------------------------------
diro = "/home/rmedina/out/promediosDiarios/merge/" ; Output directory
filo = "Promedios_Dia_RH"  + ".nc"                   ; Output file
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
dimNames = (/"time", "Latitude", "Longitude"/)
dimSizes = (/  -1  ,  nlat     ,  nlon  /)
dimUnLim = (/ True ,  False    ,  False /)
filedimdef(fout, dimNames, dimSizes, dimUnLim)

;----------------------------------------------------------------------
;  Pre-cargamos las variables que se escribiran en el archivo de salida 
;----------------------------------------------------------------------
filevardef(fout, "time"     , typeof(time) , "time")   ;Dimension tiempo
filevardef(fout, "Latitude" , typeof(lat)  , "Latitude") ;Dimension latitud
filevardef(fout, "Longitude", typeof(lon)  , "Longitude") ;Dimension longitud

filevardef(fout, "RH"       , typeof(RH)   , (/"time", "Latitude", "Longitude"/))        ;Humedad Relativa

;----------------------------------------------------------------------
;  Copiar atributos asociados con cada variable a el archivo de salida
;----------------------------------------------------------------------
filevarattdef(fout, "time"     , time)  ;copia los atributosdel tiempo
filevarattdef(fout, "Latitude" , lat )  ;copia los atributos de latitud
filevarattdef(fout, "Longitude", lon )  ;copia los atributos de longitud

filevarattdef(fout, "RH"       , RH  )   ;copia los atributos de Humedad Relativa

;------------------------------------------------
;  Obtenemos unicamente los valores de los datos 
;------------------------------------------------
fout->time      = (/time/)
print("copiamos time ....")

fout->Latitude  = (/lat/)
print("copiamos lat ...")

fout->Longitude = (/lon/)
print("copiamos lon ...")

fout->RH  = (/RH/)
print("copiamos RH ....")
