#!/bin/bash
FTP="ftp://hmwr829gr.cr.chiba-u.ac.jp/gridded/FD/V20190123"
FTP4KM="ftp://hmwr829gr.cr.chiba-u.ac.jp/gridded/FD/V20190123"
#### Set DATE
for YYYY in  2018 ; do      # Year (from 2015)
        for MM in 01  ; do        # Month
    for DD in   14    ; do  # Day
      for HH in 00   ; do  #01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 \
                #19 20 21 22 23 ; do   # Hour
      for MN in 00 ; do     # 00 10 20 30 40 50 # Minute
#### Set band type
      for CHN in EXT VIS ;do  #VIS TIR SIR EXT;do
      for NUM in 1 2 3;do  #2 3 4 5 6 7 8 9 10 ;do #band number
## -------------------------------------------------------
## Quick reference list (Released gridded data and Himawari8 band)
## [EXT] 01:Band03 
## [VIS] 01:Band01 02:Band02 03:Band04
## [SIR] 01:Band05 02:Band06
## [TIR] 01:Band13 02:Band14 03:Band15 04:Band16 05:Band07
##       06:Band08 07:Band09 08:Band10 09:Band11 10:Band12
## -------------------------------------------------------
## stop loop when there is no band is specific CHN 
      if [ ${CHN} = "VIS" ] && [ ${NUM} -gt 3 ];then
         break
      elif [ ${CHN} = "EXT" ] && [ ${NUM} -gt 1 ]; then
         break
      fi
      if [ ${NUM} -lt 10 ];then
         NUM=0${NUM}
      fi
#### download file
#      echo "Download file"
      echo "${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.geoss.bz2"
      wget ${FTP}/${YYYY}${MM}/${CHN}/${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.geoss.bz2
#### no file recording
      if [ ! \( -e ${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.geoss.bz2 \) ] ; then
         echo "trouble get file"
         echo "${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.geoss.bz2"
         echo "${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.geoss.bz2" >> test_nofile.txt
      else
#### unzip file
         echo "Extract file"
         bunzip2 ${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.geoss.bz2
         echo "Convert byte order"
         dd if=${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.geoss of=little.geoss conv=swab
         para=`echo ${YYYY}${MM}${DD}${HH}${MN}.${CHN,,}.${NUM}.fld.geoss | cut -c 14-19`
         echo ${para}
#### process downloaded data 
         echo "Convert count to albedo"
         if [ ${CHN} = "VIS" ];then
            ./vis.x little.geoss ${para}
            resolution="0.01"
            if [ ${NUM} -eq 1 ]; then
             mv grid10.dat ${YYYY}${MM}${DD}${HH}${MN}_band01.dat
            fi
            if [ ${NUM} -eq 2 ]; then
             mv grid10.dat ${YYYY}${MM}${DD}${HH}${MN}_band02.dat
            fi
            if [ ${NUM} -eq 3 ]; then
             mv grid10.dat ${YYYY}${MM}${DD}${HH}${MN}_band04.dat
            fi
            python true_color_thermo_vis.py
            rm little.geoss
         elif [ ${CHN} = "EXT" ];then
            dd if=little.geoss of=01.geoss bs=576000000 count=1
            ./ext.x 01.geoss ${para} && mv grid05.dat grid05_1.dat
            dd if=little.geoss of=02.geoss bs=576000000 skip=1
            ./ext.x 02.geoss ${para} && mv grid05.dat grid05_2.dat
            cat grid05_1.dat grid05_2.dat > grid05.dat
            resolution="0.005"
            mv grid05.dat ${YYYY}${MM}${DD}${HH}${MN}_band03.dat
            python true_color_thermo_ext.py
            rm 01.geoss 02.geoss grid05_1.dat grid05_2.dat
         fi
         rm *.geoss
         rm *.dat
#######################

         fi #file exist
      done
      done
#### geo information
         for GEO in sun.azm sun.zth sat.azm sat.zth lat lng ;do
          echo ${YYYY}${MM}${DD}${HH}${MN}.${GEO}.fld.4km.bin.bz2
          wget ${FTP4KM}/${YYYY}${MM}/4KM/${YYYY}${MM}${DD}/${YYYY}${MM}${DD}${HH}${MN}.${GEO}.fld.4km.bin.bz2
          bunzip2 ${YYYY}${MM}${DD}${HH}${MN}.${GEO}.fld.4km.bin.bz2
         done
         python true_color_thermo_geo_process.py
         rm *.bin
####
         python true_color_thermo_rgb.py
         rm *band0*.pkl
         rm *geo.pkl
         #python true_color_thermo_draw.py
         echo "one file finished"
      done
      done
    done
  done
done

