program get_stn_th
use netcdf
implicit none

integer :: yr, mo, da, inv
integer :: index
integer :: i,j,n,o
integer :: idum1,idum2
integer :: ierr, ncid1,varid1
integer :: mo_da(12)
real :: dum1,dum2
real :: t(27), p(27), qv(27), qc(27), qr(27), lon(5), lat(5)
character :: path*300, filen*300, tdum1*500


path="/data/der0318/work/thermoML/hw03-2/"

yr=2000
write(filen,'(A,A,I4.4,A)') trim(path),"/era5_ish/ERA5_ish_",yr,".nc"
ierr=nf90_open(trim(filen),nf90_nowrite,ncid1)
if (ierr/=0) write(*,*) "open fails,", trim(filen)
ierr=nf90_inq_varid(ncid1,'level',varid1)
if (ierr/=0) write(*,*) "inq fails, level" 
ierr=nf90_get_var(ncid1,varid1,p)
if (ierr/=0) write(*,*) "read fails, level" 
ierr=nf90_inq_varid(ncid1,'longitude',varid1)
if (ierr/=0) write(*,*) "inq fails, lon" 
ierr=nf90_get_var(ncid1,varid1,lon)
if (ierr/=0) write(*,*) "read fails, lon" 
ierr=nf90_inq_varid(ncid1,'latitude',varid1)
if (ierr/=0) write(*,*) "inq fails, lat" 
ierr=nf90_get_var(ncid1,varid1,lat)
if (ierr/=0) write(*,*) "read fails, lat" 
ierr=nf90_close(ncid1)

!write(*,*) p(12:27)

i=minloc(abs(lon-124.16),1)
j=minloc(abs(lat-24.33),1)

write(*,*) i,j, lon(i), lat(j)

!stop

filen=trim(path)//"/data/era5_stn_thl_qt.dat"
open(20,file=filen,access="direct",recl=(2*16+1)*4)
o=1

filen=trim(path)//"/data/inversion_LTS.47918.csv"
open(10,file=trim(filen))
read(10,*) 
do 
  read(10,'(A)',iostat=ierr) tdum1
  if (ierr/=0) exit
  !write(*,*) trim(tdum1)

  ! cut yr
  idum1=index(tdum1,'/')
  read(tdum1(1:idum1-1),'(I)') yr
  tdum1=tdum1(idum1+1:500)

  ! cut mo
  idum1=index(tdum1,'/')
  read(tdum1(1:idum1-1),'(I)') mo
  tdum1=tdum1(idum1+1:500)

  ! cut da
  idum1=index(tdum1,',')
  read(tdum1(1:idum1-1),'(I)') da
  tdum1=tdum1(idum1+1:500)

  ! cut inv
  do idum2=1,4
    idum1=index(tdum1,',')
    tdum1=tdum1(idum1+1:500)
  enddo
  read(tdum1,'(I)') inv


  mo_da=(/ 31,28,31,30,31,30,31,31,30,31,30,31 /)
  if (mod(yr,4)==0) mo_da(2)=mo_da(2)+1
  n=sum(mo_da(1:mo-1),1)+da

  !write(*,*) yr,mo,da,n
  
  write(filen,'(A,A,I4.4,A)') trim(path),"/era5_ish/ERA5_ish_",yr,".nc"
  !write(*,*) trim(filen)
  ierr=nf90_open(trim(filen),nf90_nowrite,ncid1)
  if (ierr/=0) write(*,*) "open fails,", trim(filen)
  ierr=nf90_inq_varid(ncid1,'t',varid1)
  if (ierr/=0) write(*,*) "inq fails, T" 
  ierr=nf90_get_var(ncid1,varid1,t,start=(/i,j,1,n/),count=(/1,1,27,1/))
  if (ierr/=0) write(*,*) "read fails, T"
  ierr = nf90_get_att(ncid1, varid1, "scale_factor", dum1)
  ierr = nf90_get_att(ncid1, varid1, "add_offset", dum2) 
  t=t*dum1+dum2
  ierr=nf90_inq_varid(ncid1,'q',varid1)
  if (ierr/=0) write(*,*) "inq fails, Qv"
  ierr=nf90_get_var(ncid1,varid1,qv,start=(/i,j,1,n/),count=(/1,1,27,1/))
  if (ierr/=0) write(*,*) "read fails, Qv"
  ierr = nf90_get_att(ncid1, varid1, "scale_factor", dum1)
  ierr = nf90_get_att(ncid1, varid1, "add_offset", dum2)
  qv=qv*dum1+dum2
  ierr=nf90_inq_varid(ncid1,'clwc',varid1)
  if (ierr/=0) write(*,*) "inq fails, Qc"
  ierr=nf90_get_var(ncid1,varid1,qc,start=(/i,j,1,n/),count=(/1,1,27,1/))
  if (ierr/=0) write(*,*) "read fails, Qc"
  ierr = nf90_get_att(ncid1, varid1, "scale_factor", dum1)
  ierr = nf90_get_att(ncid1, varid1, "add_offset", dum2)
  qc=qc*dum1+dum2
  ierr=nf90_inq_varid(ncid1,'crwc',varid1)
  if (ierr/=0) write(*,*) "inq fails, Qr"
  ierr=nf90_get_var(ncid1,varid1,qr,start=(/i,j,1,n/),count=(/1,1,27,1/))
  if (ierr/=0) write(*,*) "read fails, Qr"
  ierr = nf90_get_att(ncid1, varid1, "scale_factor", dum1)
  ierr = nf90_get_att(ncid1, varid1, "add_offset", dum2)
  qr=qr*dum1+dum2
  ierr=nf90_close(ncid1)
 
  t=t*((1000./p)**(2./7.))*exp(-(qc+qr)*2.5e6/(1004.5*t))
  qv=qv+qc+qr

  write(20,rec=o) t(12:27),qv(12:27),real(inv)
  o=o+1
enddo

close(20)
write(*,*) o-1

end program get_stn_th
