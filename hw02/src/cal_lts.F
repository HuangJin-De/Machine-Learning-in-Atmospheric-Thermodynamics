program cal_lts
use netcdf
implicit none

integer, parameter :: nlon=121, nlat=161, nlev=27
integer :: i,j,k,m,n,o,t
integer :: ts,te
integer :: yr,mo,da
integer, dimension(12) :: da_mo
integer :: ierr,ncid1,ncid2,varid1,varid2
real :: dum1,dum2,dum3
real, dimension(nlon) :: lon
real, dimension(nlat) :: lat
real, dimension(nlev) :: lev
real, dimension(:,:,:,:,:), allocatable :: var, pr, tmp
character(300) :: path,filen

integer, parameter :: ncri=30
real, dimension(ncri+1) :: cri
real, dimension(ncri) :: con
real, dimension(:,:,:), allocatable :: var_pr


write(*,*) "program starts"

path="/data/der0318/work/thermoML/hw02/ERA5_EAsia_00z/"
write(filen,'(A,A)') trim(path),"ERA5_EAsia_hourly_1980_00Z.nc"
ierr = nf90_open(trim(filen),NF90_NOWRITE,ncid1)
IF (ierr/=nf90_noerr) WRITE(*,*) "open fail"
ierr = nf90_inq_varid(ncid1,"longitude",varid1)
IF (ierr/=nf90_noerr) WRITE(*,*) "var_inq fail"
ierr = nf90_get_var(ncid1,varid1,lon,start=(/ 1,1,1,1 /),count=(/ nlon,1,1,1 /))
IF (ierr/=nf90_noerr) WRITE(*,*) "read fail"
ierr = nf90_inq_varid(ncid1,"latitude",varid1)
IF (ierr/=nf90_noerr) WRITE(*,*) "var_inq fail"
ierr = nf90_get_var(ncid1,varid1,lat,start=(/ 1,1,1,1 /),count=(/ nlat,1,1,1 /))
IF (ierr/=nf90_noerr) WRITE(*,*) "read fail"
ierr = nf90_inq_varid(ncid1,"level",varid1)
IF (ierr/=nf90_noerr) WRITE(*,*) "var_inq fail"
ierr = nf90_get_var(ncid1,varid1,lev,start=(/ 1,1,1,1 /),count=(/ nlev,1,1,1 /))
IF (ierr/=nf90_noerr) WRITE(*,*) "read fail"
ierr = nf90_close(ncid1)

!write(*,*) lev(16),lev(nlev)
!write(*,*) lon
!write(*,*) lat

do j=1,nlat-1
  if (lat(j+1)<=24.3 .and. lat(j)>24.3) n=j
enddo
do i=1,nlon-1
  if (lon(i)<=124.2 .and. lon(i+1)>124.2) m=i
enddo

cri(1)=0.
do i=2,ncri
  cri(i)=cri(i-1)+1.
enddo
cri(ncri+1)=100.

con=0.

write(*,*) lon(m),lat(n)

do yr=1980,2020
da_mo=(/31,28,31,30,31,30,31,31,30,31,30,31/)
if (mod(yr,4)==0) da_mo(2)=29
t=sum(da_mo(1:4),1)+sum(da_mo(9:12),1)

allocate(var(1,1,nlev,t,1))

write(filen,'(A,A,I4.4,A)') trim(path),"ERA5_EAsia_hourly_",yr,"_00Z.nc"
ierr = nf90_open(trim(filen),NF90_NOWRITE,ncid1)
IF (ierr/=nf90_noerr) WRITE(*,*) "open fail"
ierr = nf90_inq_varid(ncid1,"t",varid1)
IF (ierr/=nf90_noerr) WRITE(*,*) "var_inq fail"
ts=1
te=sum(da_mo(1:4),1)
ierr = nf90_get_var(ncid1,varid1,var(:,:,:,ts:te,:),start=(/ m,n,1,ts /),count=(/ 1,1,nlev,te-ts+1 /))
IF (ierr/=nf90_noerr) WRITE(*,*) "read fail",nf90_strerror(ierr)
ts=sum(da_mo(1:8),1)+1
te=sum(da_mo(1:12),1)
ierr = nf90_get_var(ncid1,varid1,var(:,:,:,t-(te-ts+1)+1:t,:),start=(/ m,n,1,ts /),count=(/ 1,1,nlev,te-ts+1 /))
IF (ierr/=nf90_noerr) WRITE(*,*) "read fail"
ierr = nf90_get_att(ncid1, varid1, "scale_factor", dum1)
ierr = nf90_get_att(ncid1, varid1, "add_offset", dum2)
ierr = nf90_close(ncid1)

var=var*dum1+dum2

do o=1,t
  dum1=var(1,1,16,o,1)*(1000./700.)**(2./7.)-var(1,1,nlev,o,1)
  if ((dum1<cri(10) .or. dum1>cri(ncri-8)) .and. yr>=2016) then
    i=o
    if (o>sum(da_mo(1:4),1)) i=o-sum(da_mo(1:4),1)+sum(da_mo(1:8),1)
    write(*,*) yr,i,dum1 
  endif
  do i=1,ncri
    if (dum1>=cri(i) .and. dum1<cri(i+1)) then
      con(i)=con(i)+1
      goto 765
    endif
  enddo
  765 continue
enddo

deallocate(var)
!write(*,*) yr
enddo

dum2=sum(con,1)
!con=con/dum2

write(*,*) dum2

open(10,file="./data/freq_data.dat",access="direct",recl=ncri*4)
write(10,rec=1) con
close(10)

da=int(dum2)

allocate(var(1,1,nlev,da,4),pr(1,1,1,da,1),tmp(1,1,1,da,1))
var=0.
pr=0.
tmp=0.

o=0
do yr=1980,2020
da_mo=(/31,28,31,30,31,30,31,31,30,31,30,31/)
if (mod(yr,4)==0) da_mo(2)=29
t=sum(da_mo(1:4),1)+sum(da_mo(9:12),1)

write(filen,'(A,A,I4.4,A)') trim(path),"ERA5_EAsia_hourly_",yr,"_00Z.nc"
ierr = nf90_open(trim(filen),NF90_NOWRITE,ncid1)
IF (ierr/=nf90_noerr) WRITE(*,*) "open fail"

ierr = nf90_inq_varid(ncid1,"t",varid1)
IF (ierr/=nf90_noerr) WRITE(*,*) "var_inq fail"
ts=1
te=sum(da_mo(1:4),1)
ierr = nf90_get_var(ncid1,varid1,var(:,:,:,o+ts:o+te,1),start=(/ m,n,1,ts /),count=(/ 1,1,nlev,te-ts+1 /))
IF (ierr/=nf90_noerr) WRITE(*,*) "read fail",nf90_strerror(ierr)
ierr = nf90_get_att(ncid1, varid1, "scale_factor", dum1)
ierr = nf90_get_att(ncid1, varid1, "add_offset", dum2)
var(:,:,:,o+ts:o+te,1)=var(:,:,:,o+ts:o+te,1)*dum1+dum2
ts=sum(da_mo(1:8),1)+1
te=sum(da_mo(1:12),1)
ierr = nf90_get_var(ncid1,varid1,var(:,:,:,o+t-(te-ts+1)+1:o+t,1),start=(/ m,n,1,ts /),count=(/ 1,1,nlev,te-ts+1 /))
IF (ierr/=nf90_noerr) WRITE(*,*) "read fail"
var(:,:,:,o+t-(te-ts+1)+1:o+t,1)=var(:,:,:,o+t-(te-ts+1)+1:o+t,1)*dum1+dum2

ierr = nf90_inq_varid(ncid1,"q",varid1)
IF (ierr/=nf90_noerr) WRITE(*,*) "var_inq fail"
ts=1
te=sum(da_mo(1:4),1)
ierr = nf90_get_var(ncid1,varid1,var(:,:,:,o+ts:o+te,2),start=(/ m,n,1,ts /),count=(/ 1,1,nlev,te-ts+1 /))
IF (ierr/=nf90_noerr) WRITE(*,*) "read fail",nf90_strerror(ierr)
ierr = nf90_get_att(ncid1, varid1, "scale_factor", dum1)
ierr = nf90_get_att(ncid1, varid1, "add_offset", dum2)
var(:,:,:,o+ts:o+te,2)=var(:,:,:,o+ts:o+te,2)*dum1+dum2
ts=sum(da_mo(1:8),1)+1
te=sum(da_mo(1:12),1)
ierr = nf90_get_var(ncid1,varid1,var(:,:,:,o+t-(te-ts+1)+1:o+t,2),start=(/ m,n,1,ts /),count=(/ 1,1,nlev,te-ts+1 /))
IF (ierr/=nf90_noerr) WRITE(*,*) "read fail"
var(:,:,:,o+t-(te-ts+1)+1:o+t,2)=var(:,:,:,o+t-(te-ts+1)+1:o+t,2)*dum1+dum2

ierr = nf90_inq_varid(ncid1,"w",varid1)
IF (ierr/=nf90_noerr) WRITE(*,*) "var_inq fail"
ts=1
te=sum(da_mo(1:4),1)
ierr = nf90_get_var(ncid1,varid1,var(:,:,:,o+ts:o+te,3),start=(/ m,n,1,ts /),count=(/ 1,1,nlev,te-ts+1 /))
IF (ierr/=nf90_noerr) WRITE(*,*) "read fail",nf90_strerror(ierr)
ierr = nf90_get_att(ncid1, varid1, "scale_factor", dum1)
ierr = nf90_get_att(ncid1, varid1, "add_offset", dum2)
var(:,:,:,o+ts:o+te,3)=var(:,:,:,o+ts:o+te,3)*dum1+dum2
ts=sum(da_mo(1:8),1)+1
te=sum(da_mo(1:12),1)
ierr = nf90_get_var(ncid1,varid1,var(:,:,:,o+t-(te-ts+1)+1:o+t,3),start=(/ m,n,1,ts /),count=(/ 1,1,nlev,te-ts+1 /))
IF (ierr/=nf90_noerr) WRITE(*,*) "read fail"
var(:,:,:,o+t-(te-ts+1)+1:o+t,3)=var(:,:,:,o+t-(te-ts+1)+1:o+t,3)*dum1+dum2

ierr = nf90_inq_varid(ncid1,"cc",varid1)
IF (ierr/=nf90_noerr) WRITE(*,*) "var_inq fail"
ts=1
te=sum(da_mo(1:4),1)
ierr = nf90_get_var(ncid1,varid1,var(:,:,:,o+ts:o+te,4),start=(/ m,n,1,ts /),count=(/ 1,1,nlev,te-ts+1 /))
IF (ierr/=nf90_noerr) WRITE(*,*) "read fail",nf90_strerror(ierr)
ierr = nf90_get_att(ncid1, varid1, "scale_factor", dum1)
ierr = nf90_get_att(ncid1, varid1, "add_offset", dum2)
var(:,:,:,o+ts:o+te,4)=var(:,:,:,o+ts:o+te,4)*dum1+dum2
ts=sum(da_mo(1:8),1)+1
te=sum(da_mo(1:12),1)
ierr = nf90_get_var(ncid1,varid1,var(:,:,:,o+t-(te-ts+1)+1:o+t,4),start=(/ m,n,1,ts /),count=(/ 1,1,nlev,te-ts+1 /))
IF (ierr/=nf90_noerr) WRITE(*,*) "read fail"
var(:,:,:,o+t-(te-ts+1)+1:o+t,4)=var(:,:,:,o+t-(te-ts+1)+1:o+t,4)*dum1+dum2

ierr = nf90_close(ncid1)
o=o+t
write(*,*) yr
enddo


do k=1,nlev
  var(1,1,k,:,1)=var(1,1,k,:,1)*(1000./lev(k))**(2./7.)
enddo
pr(1,1,1,:,1)=var(1,1,16,:,1)-var(1,1,nlev,:,1)


do k=1,nlev-1
  tmp=pr
  call quicksort(tmp(1,1,1,:,1),var(1,1,k,:,1),var(1,1,k,:,2),var(1,1,k,:,3),var(1,1,k,:,4),1,da)
enddo
k=nlev
call quicksort(pr(1,1,1,:,1),var(1,1,k,:,1),var(1,1,k,:,2),var(1,1,k,:,3),var(1,1,k,:,4),1,da)

deallocate(tmp)

j=20
allocate(var_pr(j,nlev,4))

n=int(da/j)
do i=1,j
  ts=(i-1)*n+1
  te=i*n
  if (i==j) te=da
  var_pr(i,:,:)=sum(var(1,1,:,ts:te,:),2)/real(te-ts+1)
enddo

open(10,file="./data/lts_ranking_data.dat",access="direct",recl=j*nlev*4)
do i=1,4
write(10,rec=i) var_pr(:,:,i)
enddo
close(10)

end program cal_lts


recursive subroutine quicksort(a,b,c,d,e, first, last)
  implicit none
! quicksort.f -*-f90-*-
! Author: t-nissie
! License: GPLv3
! Gist: https://gist.github.com/t-nissie/479f0f16966925fa29ea
  real  a(*),b(*),c(*),d(*),e(*), x, t
  integer first, last
  integer i, j


  x = a( (first+last) / 2 )
  i = first
  j = last
  do
     do while (a(i) < x)
        i=i+1
     end do
     do while (x < a(j))
        j=j-1
     end do
     if (i >= j) exit
     t = a(i);  a(i) = a(j);  a(j) = t
     t = b(i);  b(i) = b(j);  b(j) = t
     t = c(i);  c(i) = c(j);  c(j) = t
     t = d(i);  d(i) = d(j);  d(j) = t
     t = e(i);  e(i) = e(j);  e(j) = t
     i=i+1
     j=j-1
  end do
  if (first < i-1) call quicksort(a,b,c,d,e, first, i-1)
  if (j+1 < last)  call quicksort(a,b,c,d,e, j+1, last)
end subroutine quicksort
