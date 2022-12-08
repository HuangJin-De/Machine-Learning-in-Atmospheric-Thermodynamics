program cal_inver
implicit none

integer :: i,j,k,m,n,o,t
integer, parameter :: nz=101,nt=9417, nvar=4
real, dimension(nz,nvar,nt) :: era, snd
real, dimension(nz) :: tmp, inver_era, inver_snd
real :: dum1,dum2,dum3,dum4
real :: qv_sat, rh_cri, th_cri

inquire(iolength=k) era
open(10,file="../data/era.dat",access="direct",recl=k)
read(10,rec=1) era
close(10)

inquire(iolength=k) snd
open(10,file="../data/snd.dat",access="direct",recl=k)
read(10,rec=1) snd
close(10)

era(:,1,:)=100.*era(:,1,:)
snd(:,1,:)=100.*snd(:,1,:)
era(:,3,:)=273.15+era(:,3,:)
snd(:,3,:)=273.15+snd(:,3,:)
era(:,4,:)=0.001*era(:,4,:)
snd(:,4,:)=0.001*snd(:,4,:)

rh_cri=-0.001
th_cri=0.002

inquire(iolength=k) era(:,1:3,1),snd(:,1:3,1)
open(20,file="../data/inver_data.dat",access="direct",recl=k)
o=1

do t=1,nt
  ! era rh
  do k=1,nz
    n=0
    tmp(k)=qv_sat(era(k,3,t),era(k,1,t),n)
  enddo
  era(:,4,t)=era(:,4,t)/tmp

  ! snd rh
  do k=1,nz
    n=0
    tmp(k)=qv_sat(snd(k,3,t),snd(k,1,t),n)
  enddo
  snd(:,4,t)=snd(:,4,t)/tmp

  ! era
  inver_era=0.
  do k=1,nz-1
    if (k==1) dum2=era(k,2,t)
    dum1=(era(k+1,4,t)-era(k,4,t))/100.
    if (dum1<=rh_cri) then
      i=max(k-5,1)
      j=min(k+5,nz-1)
      m=0
      do n=i,j
        dum3=(era(n,2,t)-dum2)/(100.*real(n-1))
        if (dum3<=th_cri) m=1
      enddo
      if (m==1) inver_era(k)=1
    endif
  enddo

  dum2=0.
  n=0
  do k=nz/2-1,nz/2-10,-1
    dum1=(era(k+1,2,t)-era(k,2,t))/100.
    if (dum1<=9.8e-3) then
      dum2=dum2+dum1
      n=n+1
    endif
  enddo 
  inver_era(nz)=dum2/real(n)

  ! snd
  inver_snd=0.
  do k=1,nz-1
    if (k==1) dum2=snd(k,2,t)
    dum1=(snd(k+1,4,t)-snd(k,4,t))/100.
    if (dum1<=rh_cri) then
      i=max(k-5,1)
      j=min(k+5,nz-1)
      m=0
      do n=i,j
        dum3=(snd(n,2,t)-dum2)/(100.*real(n-1))
        if (dum3<=th_cri) m=1
      enddo
      if (m==1) inver_snd(k)=1
    endif
  enddo

  dum2=0.
  n=0
  do k=nz/2-1,nz/2-10,-1
    dum1=(snd(k+1,2,t)-snd(k,2,t))/100.
    if (dum1<=9.8e-3) then
      dum2=dum2+dum1
      n=n+1
    endif
  enddo
  inver_snd(nz)=dum2/real(n)

  write(20,rec=o) era(:,2,t),era(:,4,t),inver_era,snd(:,2,t),snd(:,4,t),inver_snd
  o=o+1
enddo

close(20)

end program cal_inver

!===========================================================================================

 real function qv_sat(t_atm,p_atm,i_wrt)

!------------------------------------------------------------------------------------
! Calls p:lysvp1 to obtain the saturation vapor pressure, and then computes
! and returns the saturation mixing ratio, with respect to either liquid or ice,
! depending on value of 'i_wrt'
!------------------------------------------------------------------------------------

 implicit none

 !Calling parameters:
 real    :: t_atm  !temperature [K]
 real    :: p_atm  !pressure    [Pa]
 integer :: i_wrt  !index, 0 = w.r.t. liquid, 1 = w.r.t. ice

 !Local variables:
 real    :: e_pres         !saturation vapor pressure [Pa]
 real    :: ep_2
 real    :: polysvp1
 !------------------

 ep_2   = 0.622
 e_pres = polysvp1(t_atm,i_wrt)
 qv_sat = ep_2*e_pres/max(1.e-3,(p_atm-e_pres))

 return
 end function qv_sat
!===========================================================================================

 real function polysvp1(T,i_type)

!-------------------------------------------
!  COMPUTE SATURATION VAPOR PRESSURE
!  POLYSVP1 RETURNED IN UNITS OF PA.
!  T IS INPUT IN UNITS OF K.
!  i_type REFERS TO SATURATION WITH RESPECT TO LIQUID (0) OR ICE (1)
!-------------------------------------------

      implicit none

      real    :: DUM,T
      integer :: i_type

! REPLACE GOFF-GRATCH WITH FASTER FORMULATION FROM FLATAU ET AL. 1992, TABLE 4
! (RIGHT-HAND COLUMN)

! ice
      real a0i,a1i,a2i,a3i,a4i,a5i,a6i,a7i,a8i
      data a0i,a1i,a2i,a3i,a4i,a5i,a6i,a7i,a8i /&
        6.11147274, 0.503160820, 0.188439774e-1, &
        0.420895665e-3, 0.615021634e-5,0.602588177e-7, &
        0.385852041e-9, 0.146898966e-11, 0.252751365e-14/

! liquid
      real a0,a1,a2,a3,a4,a5,a6,a7,a8

! V1.7
      data a0,a1,a2,a3,a4,a5,a6,a7,a8 /&
        6.11239921, 0.443987641, 0.142986287e-1, &
        0.264847430e-3, 0.302950461e-5, 0.206739458e-7, &
        0.640689451e-10,-0.952447341e-13,-0.976195544e-15/
      real dt

!-------------------------------------------

      if (i_type.EQ.1 .and. T.lt.273.15) then
! ICE

!       Flatau formulation:
         dt       = max(-80.,t-273.16)
         polysvp1 = a0i + dt*(a1i+dt*(a2i+dt*(a3i+dt*&
                    (a4i+dt*(a5i+dt*(a6i+dt*(a7i+&
                    a8i*dt)))))))
         polysvp1 = polysvp1*100.

!       Goff-Gratch formulation:
!        POLYSVP1 = 10.**(-9.09718*(273.16/T-1.)-3.56654*                 &
!          log10(273.16/T)+0.876793*(1.-T/273.16)+                        &
!          log10(6.1071))*100.


      elseif (i_type.EQ.0 .or. T.ge.273.15) then
! LIQUID

!       Flatau formulation:
         dt       = max(-80.,t-273.16)
         polysvp1 = a0 + dt*(a1+dt*(a2+dt*(a3+dt*&
                    (a4+dt*(a5+dt*(a6+dt*(a7+a8*dt)))))))
         polysvp1 = polysvp1*100.

!       Goff-Gratch formulation:
!        POLYSVP1 = 10.**(-7.90298*(373.16/T-1.)+                         &
!             5.02808*log10(373.16/T)-                                    &
!             1.3816E-7*(10**(11.344*(1.-T/373.16))-1.)+                  &
!             8.1328E-3*(10**(-3.49149*(373.16/T-1.))-1.)+                &
!             log10(1013.246))*100.

         endif

 end function polysvp1

!===========================================================================================

