!-----------------------BEGIN NOTICE -- DO NOT EDIT-----------------------
! NASA Goddard Space Flight Center
! Land Information System Framework (LISF)
! Version 7.5
!
! Copyright (c) 2024 United States Government as represented by the
! Administrator of the National Aeronautics and Space Administration.
! All Rights Reserved.
!-------------------------END NOTICE -- DO NOT EDIT-----------------------

subroutine top_pdm_to_tile(n, t)
  use top_pdm 
  use jules51_lsmMod
  implicit none 
  integer :: n, t

  jules51_struc(n)%jules51(t)%fexp                  = fexp_soilt(1,1)          ! Decay factor in Sat. Conductivity in water table layer
  jules51_struc(n)%jules51(t)%gamtot                = gamtot_soilt(1,1)        ! integrated complete gamma function dbc gamtot doesn't need to be in a module in this version, but left there for now for compatability.
  jules51_struc(n)%jules51(t)%ti_mean               = ti_mean_soilt(1,1)       ! Mean topographic index
  jules51_struc(n)%jules51(t)%ti_sig                = ti_sig_soilt(1,1)        ! Standard dev. of topographic index
  jules51_struc(n)%jules51(t)%fsat                  = fsat_soilt(1,1)          ! Surface saturation fraction
  jules51_struc(n)%jules51(t)%fwetl                 = fwetl_soilt(1,1)         ! Wetland fraction
  jules51_struc(n)%jules51(t)%zw                    = zw_soilt(1,1)            ! Water table depth (m)
  jules51_struc(n)%jules51(t)%drain                 = drain_soilt(1,1)         ! Drainage out of bottom (nshyd) soil layer (kg m-2/s)
  jules51_struc(n)%jules51(t)%dun_roff              = dun_roff_soilt(1,1)      ! Dunne part of sfc runoff (kg m-2/s)
  jules51_struc(n)%jules51(t)%qbase                 = qbase_soilt(1,1)         ! Base flow (kg m-2/s)
  jules51_struc(n)%jules51(t)%qbase_zw              = qbase_zw_soilt(1,1)      ! Base flow from ZW layer (kg m-2/s)
  jules51_struc(n)%jules51(t)%fch4_wetl             = fch4_wetl_soilt(1,1)     ! Scaled wetland methane flux (10^-9 kg C/m2/s)
  jules51_struc(n)%jules51(t)%fch4_wetl_cs_soilt    = fch4_wetl_cs_soilt(1,1)
  jules51_struc(n)%jules51(t)%fch4_wetl_npp_soilt   = fch4_wetl_npp_soilt(1,1)
  jules51_struc(n)%jules51(t)%fch4_wetl_resps_soilt = fch4_wetl_resps_soilt(1,1)
  jules51_struc(n)%jules51(t)%inlandout_atm         = inlandout_atm_gb(1) ! TRIP inland basin outflow (for land points only)(kg m-2/s)
  jules51_struc(n)%jules51(t)%sthzw                 = sthzw_soilt(1,1)         ! soil moist fraction in deep (water table) layer.
  jules51_struc(n)%jules51(t)%a_fsat                = a_fsat_soilt(1,1)        ! Fitting parameter for Fsat in LSH model
  jules51_struc(n)%jules51(t)%c_fsat                = c_fsat_soilt(1,1)        ! Fitting parameter for Fsat in LSH model
  jules51_struc(n)%jules51(t)%a_fwet                = a_fwet_soilt(1,1)        ! Fitting parameter for Fwet in LSH model
  jules51_struc(n)%jules51(t)%c_fwet                = c_fwet_soilt(1,1)        ! Fitting parameter for Fwet in LSH model
end subroutine top_pdm_to_tile
