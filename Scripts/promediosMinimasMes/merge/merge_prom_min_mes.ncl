;--- Ruta base ---
RUTA = "/home/rmedina/out/promediosMinimasMes/meses/"
PREFIJO = "Promedio_Minimas_Mes_"
EXT = ".nc"

MES = (/"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"/)

; ----------------------------------------;
; ---- Inicializar las variables en 0 ----;

; --- Temperatura del aire a 2 mts por mes ----
T2 = new ((/12, 348, 617/), float)
T2(:,:,:) = 0.0

do i = 0 , 11
    ; Se carga el archivo del  mes correspondiente
    ruta_archivo = RUTA + PREFIJO + MES(i) + EXT    
    archivo := addfile(ruta_archivo, "r")

    ;Se cargan las variables del archivo 
    T2_actual := archivo->T2

    ;Copiamos las variables del mes
    T2(i,:,:) = T2_actual(0,:,:)

end do

; ================================================================================
;                           CREAMOS EL ARCHIVO DE SALIDA
; ================================================================================

;----------------------------------
;  Creamos la dimension tiempo 
;----------------------------------
;time = createArray(1)
time = (/0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334/)
time@standard_name = "time"
time@long_name     = "Time"
time@units         = "days since 0-01-01 00:00:00"
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
diro = "/home/rmedina/out/promediosMinimasMes/"  ; Output directory
filo = "Promedios_Minimas_Mes.nc"              ; Output file
system("rm -f " + diro + filo)    ; remove if exists
fout  = addfile (diro + filo, "c")  ; open output file

;-----------------------------------------
;  Creamos las variables globales 
;-----------------------------------------
fAtt               = True            ; asignamos atributos al archivo
fAtt@title         = "Promedios Minimas por Mes "  
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