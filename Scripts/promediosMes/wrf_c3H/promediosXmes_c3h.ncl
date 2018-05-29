load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;------------------------------------------------------------------
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
;-----------------------------------------------------------------

;--- Ruta base ---
BASE = "/KRAKEN/DATOS3/"
;--- Prefijo ---
PREFIX_FILE_C3h = "wrfout_c3h_d01_"
PREFIX_FILE_C15d = "wrfout_c15d_d01_"

;--- Numero de DATOS de todos los años por cada dia
ANIOS = 37

;-- creamos el arreglo que contiene el numero total de archivos pr mes ---
total_c3h = new(12, float)

total_c3h(0) = 8*31*ANIOS              ; Enero 
total_c3h(1) = 8*28*6 + 8*29*3    ; Febrero
total_c3h(2) = 8*31*ANIOS              ; Marzo
total_c3h(3) = 8*30*ANIOS               ; Abril
total_c3h(4) = 8*31*ANIOS               ; Mayo 
total_c3h(5) = 8*30*ANIOS               ; Junio
total_c3h(6) = 8*31*ANIOS               ; Julio
total_c3h(7) = 8*31*ANIOS               ; Agosto
total_c3h(8) = 8*30*ANIOS               ; Septiembre
total_c3h(9) = 8*31*ANIOS               ; Octubre
total_c3h(10) = 8*30*ANIOS              ; Noviembre
total_c3h(11) = 8*31*ANIOS              ; Diciembre

; ----------------------------------------;
; ---- Inicializar las variables en 0 ----;
; --- Humedad Relativa RH ----

RH = new ((/12, 348, 617/), float)
RH(:,:,:) = 0.0

;-------------------------------------------------

nTotal = dimsizes(total_c3h)

folders = systemfunc("ls " + BASE)

nFolders = dimsizes(folders)

nombres_anios = limpiaNombreAnios(nFolders, folders)

; -- Recorremos las carpetas por Año ----;
do anio = 1, (nFolders - 2)   

    print("Procesando año " + nombres_anios(anio) + "...")

    ; Ruta del archivo para obtener las variables PB 
    ruta_archivo_PB := BASE + folders(anio) + "/" + PREFIX_FILE_C15d + nombres_anios(anio) + "-01-01_00:00:00." + nombres_anios(anio)

    ; Se carga el archivo para obtener PB
    archivo_PB := addfile(ruta_archivo_PB, "r")

    PB := archivo_PB->PB

    do mes = 0, (nTotal - 1)

        nombres_archivo_mes := PREFIX_FILE_C3h + nombres_anios(anio) + "-" + sprintf("%02g",mes + 1)
       
        ruta_archivos_mes := BASE + folders(anio) + "/" + nombres_archivo_mes

        archivos_X_mes := systemfunc("ls " + ruta_archivos_mes + "*")        
               
        num_archivos_mes := dimsizes(archivos_X_mes)

        do dia = 0, (num_archivos_mes - 1)
            
            ;--- carga el archivo --- 
            archivo := addfile(archivos_X_mes(dia), "r")
            
            ;=========== Se calcula RH (Humedad Relativa) ===================
            QVAPOR := archivo->QVAPOR           ; se obtiene    QVAPOR
            P := archivo->P                     ; se obtiene perturbation

            ; Se calcula la presion total P = P + PB
            do i = 0, 7
                P(i,:,:,:) = P(i,:,:,:) + PB(0,:,:,:)
            end do

            theta := archivo->T                 ; Temperatura potencial de perturbacion
            theta := theta + 300

            TK := wrf_tk(P,theta)
            
            ; Se obtiene RH
            RH_actual := wrf_rh(QVAPOR,P,TK)

            ;==============================================================

            do hora = 0, 7
                
                RH(mes,:,:) = RH(mes,:,:) + (RH_actual(hora,1,:,:) / total_c3h(mes))               
                
            end do

        end do

    end do
    print("Termino ...")
end do

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
;  Creamos los atributos para U 
;--------------------------------
RH@units         = "1"
RH@standard_name = "relative_humidity"
RH@long_name     = "relative_humidity"
RH@description   = "Relative Humidity"

;==========================================
; Definimos el archivo de salida 
;==========================================

;------------------------------------------
;  Creamos el archivo de salida 
;------------------------------------------
diro = "/home/rmedina/out/promediosMes/"     ; Output directory
filo = "Promedios_Mes_c3h_RH.nc"             ; Output file
system("rm -f " + diro + filo)               ; remove if exists
fout  = addfile (diro + filo, "c")           ; open output file

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
filevardef(fout, "time"       , typeof(time)   , "time")   ;Dimension tiempo
filevardef(fout, "Latitude"   , typeof(lat)    , "Latitude") ;Dimension latitud
filevardef(fout, "Longitude"  , typeof(lon)    , "Longitude") ;Dimension longitud

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

fout->RH         = (/RH/)
print("copiamos RH ....")