!-----------------------BEGIN NOTICE -- DO NOT EDIT-----------------------
! NASA Goddard Space Flight Center
! Land Information System Framework (LISF)
! Version 7.5
!
! Copyright (c) 2024 United States Government as represented by the
! Administrator of the National Aeronautics and Space Administration.
! All Rights Reserved.
!-------------------------END NOTICE -- DO NOT EDIT-----------------------
!BOP
! !ROUTINE: timeinterp_gfs
! \label{timeinterp_gfs}
!
! !REVISION HISTORY:
!  16 Mar 2008: Sujay Kumar; Initial specification
!  10 Oct 2006: Sujay Kumar: Switched to using ESMF_State for storing
!               forcing data. 
! !INTERFACE:
subroutine timeinterp_gfs(n,findex)
! !USES:
  use ESMF
  use LDT_coreMod,       only  : LDT_rc, LDT_domain
  use LDT_FORC_AttributesMod 
  use LDT_timeMgrMod,    only  : LDT_time2date, LDT_tick
  use LDT_constantsMod,  only  : LDT_CONST_SOLAR
  use LDT_metforcingMod, only  : LDT_forc, LDT_FORC_Base_State
  use LDT_logMod,        only  : LDT_logunit, LDT_verify, LDT_endrun
  use gfs_forcingMod,    only  : gfs_struc

  implicit none
! !ARGUMENTS: 
  integer, intent(in) :: n
  integer, intent(in) :: findex
!
! !DESCRIPTION:
!  Temporally interpolates the forcing data to the current model 
!  timestep. Downward shortwave radiation is interpolated using a
!  zenith-angled based approach. Precipitation and longwave radiation
!  are not temporally interpolated, and the previous 3 hourly value
!  is used. All other variables are linearly interpolated between 
!  the 3 hourly blocks. 
!
!  The arguments are: 
!  \begin{description}
!  \item[n]
!   index of the nest
!  \end{description}
! 
!  The routines invoked are: 
!  \begin{description}
!   \item[LDT\_time2date](\ref{LDT_time2date}) \newline
!    converts the time to a date format
!   \item[LDT\_tick](\ref{LDT_tick}) \newline
!    advances or retracts time by the specified amount
!   \item[zterp](\ref{zterp}) \newline
!    zenith-angle based interpolation
!  \end{description}
!EOP
  integer :: t,zdoy,idoy,iyr,imo,ida,ihr,imn,its,iss
  integer :: index1
  integer :: bdoy,byr,bmo
  integer :: bda,bhr,bmn
  real*8 :: btime,inittime
  real :: wt1,wt2,czb,cze,czm,gmt1,gmt2,igmt
  real :: zw1,zw2
  integer            :: status
  type(ESMF_Field)   :: tmpField,q2Field,uField,vField,swdField,lwdField
  type(ESMF_Field)   :: psurfField,pcpField,cpcpField
  real,pointer       :: tmp(:),q2(:),uwind(:),vwind(:)
  real,pointer       :: swd(:),lwd(:),psurf(:),pcp(:),cpcp(:)

  btime=gfs_struc(n)%gfstime1
  call LDT_time2date(btime,bdoy,gmt1,byr,bmo,bda,bhr,bmn)
  btime=gfs_struc(n)%gfstime2
  call LDT_time2date(btime,bdoy,gmt2,byr,bmo,bda,bhr,bmn)
  
  wt1 = (gfs_struc(n)%gfstime2-LDT_rc%time) / & 
       (gfs_struc(n)%gfstime2-gfs_struc(n)%gfstime1)
  wt2 = 1.0 - wt1

  call ESMF_StateGet(LDT_FORC_Base_State(n,findex),trim(LDT_FORC_Tair%varname(1)),tmpField,&
       rc=status)
  call LDT_verify(status, 'Error: Enable Tair in the forcing variables list')

  call ESMF_StateGet(LDT_FORC_Base_State(n,findex),trim(LDT_FORC_Qair%varname(1)),q2Field,&
       rc=status)
  call LDT_verify(status, 'Error: Enable Qair in the forcing variables list')

  call ESMF_StateGet(LDT_FORC_Base_State(n,findex),trim(LDT_FORC_SWdown%varname(1)),swdField,&
       rc=status)
  call LDT_verify(status, 'Error: Enable SWdown in the forcing variables list')

  call ESMF_StateGet(LDT_FORC_Base_State(n,findex),trim(LDT_FORC_LWdown%varname(1)),lwdField,&
       rc=status)
  call LDT_verify(status, 'Error: Enable LWdown in the forcing variables list')

  call ESMF_StateGet(LDT_FORC_Base_State(n,findex),trim(LDT_FORC_Wind_E%varname(1)),uField,&
       rc=status)
  call LDT_verify(status, 'Error: Enable Wind_E in the forcing variables list')

  call ESMF_StateGet(LDT_FORC_Base_State(n,findex),trim(LDT_FORC_Wind_N%varname(1)),vField,&
       rc=status)
  call LDT_verify(status, 'Error: Enable Wind_N in the forcing variables list')

  call ESMF_StateGet(LDT_FORC_Base_State(n,findex),trim(LDT_FORC_Psurf%varname(1)),psurfField,&
       rc=status)
  call LDT_verify(status, 'Error: Enable Psurf in the forcing variables list')

  call ESMF_StateGet(LDT_FORC_Base_State(n,findex),trim(LDT_FORC_Rainf%varname(1)),pcpField,&
       rc=status)
  call LDT_verify(status, 'Error: Enable Rainf in the forcing variables list')

  call ESMF_StateGet(LDT_FORC_Base_State(n,findex),trim(LDT_FORC_CRainf%varname(1)),cpcpField,&
       rc=status)
  call LDT_verify(status, 'Error: Enable CRainf in the forcing variables list')

  
  call ESMF_FieldGet(swdField,localDE=0, farrayPtr=swd,rc=status)
  call LDT_verify(status)
  
  call ESMF_FieldGet(lwdField,localDE=0, farrayPtr=lwd,rc=status)
  call LDT_verify(status)
        
  call ESMF_FieldGet(pcpField,localDE=0, farrayPtr=pcp,rc=status)
  call LDT_verify(status)

  call ESMF_FieldGet(cpcpField,localDE=0, farrayPtr=cpcp,rc=status)
  call LDT_verify(status)

  call ESMF_FieldGet(tmpField,localDE=0, farrayPtr=tmp,rc=status)
  call LDT_verify(status)

  call ESMF_FieldGet(q2Field,localDE=0, farrayPtr=q2,rc=status)
  call LDT_verify(status)

  call ESMF_FieldGet(uField,localDE=0, farrayPtr=uwind,rc=status)
  call LDT_verify(status)

  call ESMF_FieldGet(vField,localDE=0, farrayPtr=vwind,rc=status)
  call LDT_verify(status)

  call ESMF_FieldGet(psurfField,localDE=0, farrayPtr=psurf,rc=status)
  call LDT_verify(status)

  pcp  = 0.0
  cpcp = 0.0
  
  do t = 1, LDT_rc%ntiles(n)
     index1 = LDT_domain(n)%tile(t)%index
     zdoy = LDT_rc%doy
     call zterp( 0, LDT_domain(n)%grid(index1)%lat,&
          LDT_domain(n)%grid(index1)%lon, gmt1, gmt2, & 
          LDT_rc%gmt,zdoy,zw1,zw2,czb,cze,czm,LDT_rc)
     swd(t) = zw1 * LDT_forc(n,findex)%metdata2(3,index1)
     if (swd(t) < 0) then
        write(LDT_logunit,*) '2 warning!!!  SW radiation is negative!!'
        write(LDT_logunit,*) 'sw=', swd(t), '... negative'
        write(LDT_logunit,*) 'gfs2=', LDT_forc(n,findex)%metdata2(3,index1)
        call LDT_endrun
     end if
     
     if (swd(t).gt.LDT_CONST_SOLAR) then
        swd(t)=LDT_forc(n,findex)%metdata2(3,index1)
     endif
  end do
  do t = 1, LDT_rc%ntiles(n)     
     index1 = LDT_domain(n)%tile(t)%index
     lwd(t) = LDT_forc(n,findex)%metdata2(4,index1)     
     pcp(t) = LDT_forc(n,findex)%metdata2(8,index1)    
     cpcp(t) = LDT_forc(n,findex)%metdata2(9,index1)     
     tmp(t) = wt1 * LDT_forc(n,findex)%metdata1(1,index1) & 
          + wt2 *LDT_forc(n,findex)%metdata2(1,index1)
     q2(t) = wt1 * LDT_forc(n,findex)%metdata1(2,index1) & 
          + wt2 *LDT_forc(n,findex)%metdata2(2,index1)
     uwind(t) = wt1 * LDT_forc(n,findex)%metdata1(5,index1) & 
          + wt2 *LDT_forc(n,findex)%metdata2(5,index1)
     vwind(t) = wt1 * LDT_forc(n,findex)%metdata1(6,index1) & 
          + wt2 *LDT_forc(n,findex)%metdata2(6,index1)
     psurf(t) = wt1 * LDT_forc(n,findex)%metdata1(7,index1) & 
          + wt2 *LDT_forc(n,findex)%metdata2(7,index1)
  end do

end subroutine timeinterp_gfs
