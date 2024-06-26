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
! !ROUTINE: noah32_map_snow
! \label{noah32_map_snow}
!
! !REVISION HISTORY:
! 27Feb2005: Sujay Kumar; Initial Specification
! 25Jun2006: Sujay Kumar: Updated for the ESMF design
!  02 Mar 2010: Sujay Kumar; Modified for Noah 3.1
! 20 Aug 2013: Yuqiong Liu; Modified to combine the two DI approaches,
!   i.e., 'standard' - Rodell & House (2004, JHM) and 'customized' - Liu et al. (2013, AWR)
!
! !INTERFACE:
subroutine noah32_map_snow(n,OBS_State,LSM_Incr_State)
! !USES:
  use ESMF
  use LIS_coreMod, only : LIS_rc, LIS_domain
  use LIS_constantsMod, only  : LIS_CONST_TKFRZ
  use LIS_logMod,   only  : LIS_logunit, LIS_verify
  use noah32_lsmMod
  use ANSASCFsnow_Mod, only : ANSASCFsnow_struc

  implicit none
! !ARGUMENTS: 
  integer, intent(in)      :: n
  type(ESMF_State)         :: OBS_State
  type(ESMF_State)         :: LSM_Incr_State
! !DESCRIPTION:
!
!  This subroutine directly maps the observation state to the corresponding 
!  variables in the LSM state for SCA data assimilation.
!  
!  The arguments are: 
!  \begin{description}
!  \item[n] index of the nest \newline
!  \item[OBS\_State] ESMF State for observations \newline
!  \item[LSM\_State] ESMF State for LSM state variables \newline
!  \end{description}
!
!EOP
  type(ESMF_Field)         :: sweincrField
  type(ESMF_Field)         :: obs_sca_field
  real, allocatable        :: sweincr(:)
  type(ESMF_Field)         :: snodincrField
  real, allocatable        :: snodincr(:)
  real, allocatable        :: scaobs(:)
  integer                  :: t
  integer                  :: status
  integer                  :: obs_state_count
  character*100,allocatable   :: obs_state_objs(:)
  real                     :: sndens !snow density
  real                     :: melt_rate
  real, allocatable        :: swe(:)
  real, allocatable        :: snod(:)

  call ESMF_StateGet(LSM_Incr_State,"SWE",sweincrField,rc=status)
  call LIS_verify(status)

  call ESMF_FieldGet(sweincrField,localDE=0,farrayPtr=sweincr,rc=status)
  call LIS_verify(status)
  
  call ESMF_StateGet(LSM_Incr_State,"Snowdepth",snodincrField,rc=status)
  call LIS_verify(status)
  
  call ESMF_FieldGet(snodincrField,localDE=0,farrayPtr=snodincr,rc=status)
  call LIS_verify(status)

  call ESMF_StateGet(OBS_State,itemCount=obs_state_count,rc=status)
  call LIS_verify(status)
  allocate(obs_state_objs(obs_state_count))
  
  call ESMF_StateGet(OBS_State,itemNameList=obs_state_objs,rc=status)
  call LIS_verify(status)
  
  call ESMF_StateGet(OBS_State,obs_state_objs(1),obs_sca_field,&
       rc=status)
  call LIS_verify(status)
  call ESMF_FieldGet(obs_sca_field,localDE=0,farrayPtr=scaobs,rc=status)
  call LIS_verify(status)
  
  do t=1,LIS_rc%npatch(n,LIS_rc%lsm_index)
     swe(t)  = noah32_struc(n)%noah(t)%sneqv
     snod(t) = noah32_struc(n)%noah(t)%snowh
  enddo

  do t=1,LIS_rc%npatch(n,LIS_rc%lsm_index)

     ! Based on observed SCA, we update the SWE based on the rules defined below
     if(scaobs(LIS_domain(n)%tile(t)%index).ne.-9999.0) then 

        ! If observation shows snow and model doesn't
        ! add a layer of snow with predefined thickness
        if((scaobs(LIS_domain(n)%tile(t)%index).ge.ANSASCFsnow_struc(n)%di_scaobs1).and.&
             (swe(t)*1000.0.lt.ANSASCFsnow_struc(n)%di_swemod)) then 
           swe(t) = swe(t)+ANSASCFsnow_struc(n)%di_addswe/1000.0

        ! If model shows snow and observation doesn't, 
        ! remove snow according to swe-dependent melt rate 
        elseif((scaobs(LIS_domain(n)%tile(t)%index).lt.ANSASCFsnow_struc(n)%di_scaobs2).and.&
          (swe(t)*1000.0.gt.0.0)) then 
            !if only a thin layer of SWE from model, remove completely (Rodell & Houser, 2004)
            if (swe(t) .le. ANSASCFsnow_struc(n)%di_minswe/1000.) then 
                swe(t) = 0.0
            else !otherwise, 
                if (ANSASCFsnow_struc(n)%di_opt .eq. 'customized') then 
                   !compute melt rate based on predefined melt period (# of days, Liu et al., 2013) 
                   melt_rate = min(ANSASCFsnow_struc(n)%di_maxmelt/1000, swe(t)/ANSASCFsnow_struc(n)%di_ndaymelt)  
                   swe(t) = max(0.0, swe(t)-melt_rate) ! remove snow based on melt rate
                endif
            endif
        endif

        if (swe(t).le.0.0) then 
            snod(t) = 0.0
        else 
            ! get snow density computed by Noah.3.3
            sndens = noah32_struc(n)%noah(t)%sndens
            if (sndens.lt.0.05) sndens=0.05
            if (sndens.gt.0.4)  sndens=0.4
            snod(t) = swe(t)/sndens 
        endif
     endif
  enddo

  do t=1,LIS_rc%npatch(n,LIS_rc%lsm_index)
     sweincr(t)  = swe(t)  - noah32_struc(n)%noah(t)%sneqv
     snodincr(t) = snod(t) - noah32_struc(n)%noah(t)%snowh
  enddo 
  deallocate(obs_state_objs)
  deallocate(swe)
  deallocate(snod)
end subroutine noah32_map_snow
   
