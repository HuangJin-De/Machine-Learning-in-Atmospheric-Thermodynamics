program idealized_profile
implicit none

integer, parameter :: nz=101

integer :: i,j,k,m,n,o
real :: qv_sat
real :: dum1,dum2,dum3,dum4,dum5
real, dimension(nz) :: z
real, dimension(nz,40,40,3) :: th, t, rh, qv, pi
real*4, dimension(nz,40,40,3) :: tho, to, rho, qvo
real :: H_scale, z_thinv, s_thinv, e_thsta, T0, &
                 z_rhinv, s_rhinv, e_rhsta

H_scale=0.05
T0=295.
e_thsta=30.
e_rhsta=0.2


! height coordinate
z(1)=0.05
do k=2,nz
  z(k)=z(k-1)+0.1
enddo

! set the profile
do m=1,3
  s_thinv=0.
  z_thinv=2.5
  s_rhinv=0.
  z_rhinv=2.5

  do j=1,40
  do i=1,40
    if (m==1) then
      s_rhinv=-real(i-1)*0.0125
      z_rhinv=real(j)*100./1000.
    elseif (m==2) then
      s_thinv=real(i-1)*0.25
      z_thinv=real(j)*100./1000.
    elseif (m==3) then
      s_thinv=real(i-1)*0.25
      z_thinv=real(j)*100./1000.
      s_rhinv=-0.2
      z_rhinv=0.7
      T0=290
    endif
   
    do k=1,nz
      th(k,i,j,m)=e_thsta*(1.-exp(2.5-z(k))/(1.+exp(2.5-z(k))))+T0
      th(k,i,j,m)=th(k,i,j,m)+s_thinv*exp((z(k)-z_thinv)/H_scale)/(1.+exp((z(k)-z_thinv)/H_scale))
      rh(k,i,j,m)=e_rhsta*exp(2.5-z(k))/(1.+exp(2.5-z(k)))+(0.95-e_rhsta)
      rh(k,i,j,m)=rh(k,i,j,m)+s_rhinv*exp((z(k)-z_rhinv)/H_scale)/(1.+exp((z(k)-z_rhinv)/H_scale))
    enddo
    
    k=1
    pi(k,i,j,m)=1.
    t(k,i,j,m)=th(k,i,j,m)*pi(k,i,j,m)
    dum1=1e5*pi(k,i,j,m)**(7./2.)
    n=0
    if (t(k,i,j,m)<=273.15) n=1
    qv(k,i,j,m)=rh(k,i,j,m)*qv_sat(t(k,i,j,m),dum1,n)
    do k=2,nz
      pi(k,i,j,m)=pi(k-1,i,j,m)-9.8/(1004.5*0.5*(th(k,1,1,1)+th(k-1,1,1,1)))*100.
      t(k,i,j,m)=th(k,i,j,m)*pi(k,i,j,m)
      dum1=1e5*pi(k,i,j,m)**(7./2.)
      !write(*,*) k,pi(k,n), dum1
      n=0
      if (t(k,i,j,m)<=273.15) n=1
      qv(k,i,j,m)=rh(k,i,j,m)*qv_sat(t(k,i,j,m),dum1,n)
    enddo
    
  enddo
  enddo
enddo

tho=th
to=t
rho=rh
qvo=qv

write(*,*) nz/2
open(10,file="../data/ideal_array_data.dat",access="direct",recl=nz/2*4*4)
n=1
do m=1,3
do j=1,40
do i=1,40
  write(10,rec=n) tho(1:nz/2,i,j,m),to(1:nz/2,i,j,m),rho(1:nz/2,i,j,m),qvo(1:nz/2,i,j,m)
  n=n+1
enddo
enddo
enddo
write(*,*) n-1
close(10)

end program idealized_profile


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


