print("Hora de inicio :  " + systemfunc ("date"))

;--- Ruta base ---
BASE = "/ServerData/KRAKEN-CFSR_Met_v2/"
PREFIX_FILE_C3H = "wrfout_c3h_d01_"
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
total_c3h = new(12, float)

ANIOS =  9

total_c3h(0) = 31 * ANIOS        ; Enero 
total_c3h(1) = 28 * 6 + 29 * 3   ; Febreo     
total_c3h(2) = 31 * ANIOS        ; Marzo     
total_c3h(3) = 30 * ANIOS        ; Abril
total_c3h(4) = 31 * ANIOS        ; Mayo      
total_c3h(5) = 30 * ANIOS        ; Junio
total_c3h(6) = 31 * ANIOS        ; Julio     
total_c3h(7) = 31 * ANIOS        ; Agosto     
total_c3h(8) = 30 * ANIOS        ; Septiembre
total_c3h(9) = 31 * ANIOS        ; Octubre
total_c3h(10) = 30 * ANIOS       ; Noviembre
total_c3h(11) = 31 * ANIOS       ; Diciembre

; ----------------------------------------;
; ---- Inicializar las variables en 0 ----;

; --- Viento U ----
U = new ((/12, 8, 29, 348, 618/), float)
U(:,:,:,:,:) = 0.0

; --- Viento V ---
V = new ((/12, 8, 29, 349, 617/), float)
V(:,:,:,:,:) = 0.0

; --- Cobertura de nubes ---
QCLOUD = new ((/12, 8, 29, 348, 617/), float)
QCLOUD(:,:,:,:,:) = 0.0

nTotal = dimsizes(total_c3h)

time_readFolders = get_cpu_time()

folders = systemfunc("ls " + BASE)

nFolders = dimsizes(folders) - 1

nombres_anios = limpiaNombreAnios(nFolders, folders)

; -- Recorremos las carpetas por Año ----;
do anio = 3, 11;(nFolders - 1)    
    print("Año  :  " + nombres_anios(anio))

    do mes = 0, (nTotal - 1)

        nombres_archivo_mes := PREFIX_FILE_C3H + nombres_anios(anio) + "-" + sprintf("%02g",mes + 1)
       
        ruta_archivos_mes := BASE + folders(anio) + "/" + nombres_archivo_mes

        archivos_X_mes := systemfunc("ls " + ruta_archivos_mes + "*")        
               
        num_archivos_mes := dimsizes(archivos_X_mes)

        do dia = 0, (num_archivos_mes - 1)
            
            ;--- carga el archivo --- 
            archivo := addfile(archivos_X_mes(dia), "r")
            
            U_actual := archivo->U
            V_actual := archivo->V
            QCLOUD_actual := archivo->QCLOUD

            U(mes,:,:,:,:) = U(mes,:,:,:,:) + (U_actual(:,:,:,:) / total_c3h(mes))               
            V(mes,:,:,:,:) = V(mes,:,:,:,:) + (V_actual(:,:,:,:) / total_c3h(mes))
            QCLOUD(mes,:,:,:,:) = QCLOUD(mes,:,:,:,:) + (QCLOUD_actual(:,:,:,:) / total_c3h(mes))

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

lat@standard_name =  "latitude"
lat@long_name     =  "Latitude"
lat@units         =  "degrees_north"

;-------------------------------------
;  Obtenemos la dimension de Longitud 
;-------------------------------------
lonAux = archivo_dimensiones->XLONG
lon = lonAux(0,1,:)
delete_VarAtts(lon,-1)

lon@standard_name =  "longitude"
lon@long_name     =  "Longitude"
lon@units         =  "degrees_east"

;----------------------------------------
;   Obtenemos la dimension de Latitud U
;----------------------------------------
latAuxU = archivo_dimensiones->XLAT_U
latU = latAuxU(0,:,0)
delete_VarAtts(latU,-1)

latU@standard_name =  "latitude"
latU@long_name     =  "Latitude U"
latU@units         =  "degrees_north"

;-------------------------------------
;  Obtenemos la dimension de Longitud U
;-------------------------------------
lonAuxU = archivo_dimensiones->XLONG_U
lonU = lonAuxU(0,0,:)
delete_VarAtts(lonU,-1)

lonU@standard_name =  "longitude"
lonU@long_name     =  "Longitude U"
lonU@units         =  "degrees_east"

;----------------------------------------
;   Obtenemos la dimension de Latitud V
;----------------------------------------
latAuxV = archivo_dimensiones->XLAT_V
latV = latAuxV(0,:,0)
delete_VarAtts(latV,-1)

latV@standard_name =  "latitude"
latV@long_name     =  "Latitude V"
latV@units         =  "degrees_north"

;-------------------------------------
;  Obtenemos la dimension de Longitud V
;-------------------------------------
lonAuxV = archivo_dimensiones->XLONG_V
lonV = lonAuxV(0,0,:)
delete_VarAtts(lonV,-1)

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

;============================================================
; Funcion que crea 12 archivos que representan los 12 meses,
; para alguna variable
;============================================================
function creaArchivosPorMes(u, v, qcloud, lat, lon, latU, lonU, latV, lonV)
begin
    nlat  = dimsizes(lat)
    nlon  = dimsizes(lon)
    nlatU = dimsizes(latU)
    nlonU = dimsizes(lonU)
    nlatV = dimsizes(latV)
    nlonV = dimsizes(lonV)

    do mes = 0, 11
        print("Creando archivos  de " + MES(mes) + " ....")
        ; --- Viento U ----
        U := u(mes,:,:,:,:)
        
        ; --- Viento V ---
        V := v(mes,:,:,:,:)

        ; --- Cobertura de nubes ---
        QCLOUD := qcloud(mes,:,:,:,:)
        
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

        ;----------------------------------
        ;  Creamos la dimension tiempo 
        ;----------------------------------
        time = createArray0(8)
        time@standard_name = "time"
        time@long_name     = "Time"
        time@units         = "hours since 2000-"+ sprintf("%02g",mes + 1) +"-01 00:00:00"
        time@calendar      = "gregorian"
        time@axis          = "T"

        ;------------------------------------------
        ;  Creamos el archivo de salida 
        ;------------------------------------------
        diro = "/ServerData/OutTempRaul/promediosHorariosXmes/C3H/" ; Output directory
        ;diro = "/home/raul/Hito/out/horariosXmes/"         ; Output directory
        filo = "Promedios_Mes_c3h_bat_" + MES(mes) + ".nc"             ; Output file
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
        filevarattdef(fout, "U"          , U     )   ;copia los atributos de U
        filevarattdef(fout, "V"          , V  )      ;copia los atributos de V
        filevarattdef(fout, "QCLOUD"     , QCLOUD )  ;copia los atributos de QCLOUD

        ;------------------------------------------------
        ;  Obtenemos unicamente los valores de los datos 
        ;------------------------------------------------
        fout->time      = (/time/)
        fout->Latitude  = (/lat/)
        fout->Longitude = (/lon/)
        fout->Depth = (/depth/)
        
        fout->Latitude_U  = (/latU/)
        fout->Longitude_U = (/lonU/)
        fout->Latitude_V  = (/latV/)
        fout->Longitude_V = (/lonV/)
        fout->U         = (/U/)
        fout->V         = (/V/)
        fout->QCLOUD    = (/QCLOUD/)

    end do

    return True

end

;---------------------------------------
; Creamos los 12 archivos de salida
;--------------------------------------
valor = creaArchivosPorMes(U, V, QCLOUD, lat, lon, latU, lonU, latV, lonV)

print("Hora de termino :  " + systemfunc("date"))

