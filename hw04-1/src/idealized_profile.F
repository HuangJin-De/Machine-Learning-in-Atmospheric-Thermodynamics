program idealized_profile
implicit none

integer, parameter :: nz=101
integer :: i,j,k,m,n,o
real :: dum1,qv_sat
real, dimension(nz) :: z
real, dimension(nz,10) :: th, t, rh, qv, pi
real, dimension(10) :: H_scale, z_thinv, s_thinv, e_thsta, T0, &
                                z_rhinv, s_rhinv, e_rhsta

H_scale=0.05
! th
e_thsta=(/20., 35., 20.,  20., 35., 20., 40.,  20., 20., 35./)
z_thinv=(/ 2.,  2.,  2., 1.25, 1.2, 2.6,  1., 1.75, 0.8, 1.2/)
s_thinv=(/ 0.,  0.,  0.,   2.,  0., 2.0, 0.7,   6., 4.5, 1.5/)
T0=    (/300.,290.,300., 300.,290.,300.,295., 300.,300.,295./)
T0=T0-5.
! rh
e_rhsta=(/0.4, 0.4, 0.8,  0.4,  0.4, 0.8, 0.6,  0.4,  0.4, 0.6/)
z_rhinv=(/ 2.,  2.,  2., 1.22,  2.2, 0.5,  1.,  1.8, 0.85, 1.0/)
s_rhinv=(/ 0.,  0.,  0., 0.25, 0.25,  0., 0.2,  0.4, 0.15, 0.2/)
s_rhinv=-s_rhinv

! height coordinate
z(1)=0.05
do k=2,nz
  z(k)=z(k-1)+0.1
enddo

! set the profile
do n=1,10
  do k=1,nz
    th(k,n)=e_thsta(n)*(1.-exp(2.5-z(k))/(1.+exp(2.5-z(k))))+T0(n)
    th(k,n)=th(k,n)+s_thinv(n)*exp((z(k)-z_thinv(n))/H_scale(n))/(1.+exp((z(k)-z_thinv(n))/H_scale(n)))
    rh(k,n)=e_rhsta(n)*exp(2.5-z(k))/(1.+exp(2.5-z(k)))+(0.95-e_rhsta(n))
    rh(k,n)=rh(k,n)+s_rhinv(n)*exp((z(k)-z_rhinv(n))/H_scale(n))/(1.+exp((z(k)-z_rhinv(n))/H_scale(n)))
  enddo
  if (n>8) then
    z_thinv(n)=3.75
    if (n==9) z_thinv(n)=2.6
    z_rhinv(n)=3.7
    if (n==9) z_rhinv(n)=2.6
    s_thinv(n)=6.
    if (n==9) s_thinv(n)=2.5
    s_rhinv(n)=-0.
    if (n==9) s_rhinv(n)=-0.1
    do k=1,nz
      th(k,n)=th(k,n)+s_thinv(n)*exp((z(k)-z_thinv(n))/H_scale(n))/(1.+exp((z(k)-z_thinv(n))/H_scale(n)))
      rh(k,n)=rh(k,n)+s_rhinv(n)*exp((z(k)-z_rhinv(n))/H_scale(n))/(1.+exp((z(k)-z_rhinv(n))/H_scale(n)))
    enddo
  endif

  k=1
  pi(k,n)=1.
  t(k,n)=th(k,n)*pi(k,n)
  dum1=1e5*pi(k,n)**(7./2.)
  m=0
  if (t(k,n)<=273.15) m=1
  qv(k,n)=rh(k,n)*qv_sat(t(k,n),dum1,m)
  do k=2,nz
    pi(k,n)=pi(k-1,n)-9.8/(1004.5*0.5*(th(k,1)+th(k-1,1)))*100.
    t(k,n)=th(k,n)*pi(k,n)
    dum1=1e5*pi(k,n)**(7./2.)
    !write(*,*) k,pi(k,n), dum1
    m=0
    if (t(k,n)<=273.15) m=1
    qv(k,n)=rh(k,n)*qv_sat(t(k,n),dum1,m)
  enddo
enddo

write(*,*) nz/2
open(10,file="../data/ideal_inver_data.dat",access="direct",recl=nz/2*4*4)
do n=1,10
  write(10,rec=n) th(1:nz/2,n),t(1:nz/2,n),rh(1:nz/2,n),qv(1:nz/2,n)
enddo
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


