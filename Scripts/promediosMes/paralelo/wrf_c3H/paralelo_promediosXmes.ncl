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

;--- Ruta base ---
BASE = "/KRAKEN/DATOS3/"
PREFIX_FILE_C3h = "wrfout_c3h_d01_"
PREFIX_FILE_C15d = "wrfout_c15d_d01_"

MES = (/"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"/)


;-- creamos el arreglo que contiene el numero total de archivos pr mes ---
total = new(12, float)

;Numero de anios a ejecutar
ANIOS =  37

total(0) = 8*31*ANIOS         ; Enero 
total(1) = 8*28*27 + 24*29*10   ; Febreo
total(2) = 8*31*ANIOS         ; Marzo
total(3) = 8*30*ANIOS         ; Abril
total(4) = 8*31*ANIOS         ; Mayo 
total(5) = 8*30*ANIOS         ; Junio
total(6) = 8*31*ANIOS         ; Julio
total(7) = 8*31*ANIOS         ; Agosto
total(8) = 8*30*ANIOS         ; Septiembre
total(9) = 8*31*ANIOS         ; Octubre
total(10) = 8*30*ANIOS        ; Noviembre
total(11) = 8*31*ANIOS        ; Diciembre

; ----------------------------------------;
; ---- Inicializar las variables en 0 ----;

; --- RH HUmedad Relativa ---
RH = new ((/1, 348, 617/), float)
RH(:,:,:) = 0.0

;-------------------------------------

nTotal = dimsizes(total)

folders = systemfunc("ls " + BASE)

nFolders = dimsizes(folders)

nombres_anios = limpiaNombreAnios(nFolders, folders)

mes = mes_i

; -- Recorremos las carpetas por Año ----;

do anio = 1, (nFolders - 2)    
    print("Procesando año " + nombres_anios(anio) + "...")

     ;======  Se genera la ruta para el archivo de donde se lee PB =========

    ; Ruta del archivo para obtener las variables PB 
    ruta_archivo_PB := BASE + folders(anio) + "/" + PREFIX_FILE_C15d + nombres_anios(anio) + "-01-01_00:00:00." + nombres_anios(anio)

    ; Se carga el archivo para obtener PB
    archivo_PB := addfile(ruta_archivo_PB, "r")

    PB := archivo_PB->PB

    ;======================================================================

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
        
        ; Se obtiene solo RH para la altura en la posicion 2 de bottom_top
        RH_aux := RH_actual(:,1,:,:)

        do hora = 0, 7
                
            RH(0,:,:) = RH(0,:,:) + (RH_aux(hora,:,:) / total(mes))

        end do

    end do

    print("Termino ...")

end do

; ================================================================================
;                           CREAMOS EL ARCHIVO DE SALIDA
; ================================================================================

;------------------------------------------------------------------------------
; Cargamos el archivo donde se encuentran las dimensiones de latitud y longitud 
;------------------------------------------------------------------------------
archivo_dimensiones := addfile("/KRAKEN/DATOS3/a2000/wrfout_c_anio_d01_2000-01-01_00:00:00.2000", "r")

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
;  Creamos los atributos para RH 
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
diro = "/home/rmedina/out/promediosMes/rh/"   ; Output directory
filo = "Promedios_Mes_RH_" + MES(mes) + ".nc"                 ; Output file
system("rm -f " + diro + filo)             ; remove if exists
fout  = addfile (diro + filo, "c")         ; open output file

;-----------------------------------------
;  Creamos las variables globales 
;-----------------------------------------
fAtt               = True            ; asignamos atributos al archivo
fAtt@title         = "Promedios mensuales(" + MES(mes) + ")"  
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

filevardef(fout, "RH"      , typeof(RH)    , (/"time", "Latitude", "Longitude"/))        ;Humedad Relativa

;----------------------------------------------------------------------
;  Copiar atributos asociados con cada variable a el archivo de salida
;----------------------------------------------------------------------
filevarattdef(fout, "time"     , time)  ;copia los atributosdel tiempo
filevarattdef(fout, "Latitude" , lat )  ;copia los atributos de latitud
filevarattdef(fout, "Longitude", lon )  ;copia los atributos de longitud

filevarattdef(fout, "RH"      , RH    )  ;copia los atributos de RH

;------------------------------------------------
;  Obtenemos unicamente los valores de los datos 
;------------------------------------------------
fout->time      = (/time/)
print("copiamos time ....")
fout->Latitude  = (/lat/)
print("copiamos lat ...")
fout->Longitude = (/lon/)
print("Copiamos lon ...")

fout->RH       = (/RH/)
print("copiamos RH ....")