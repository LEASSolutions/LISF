!-----------------------BEGIN NOTICE -- DO NOT EDIT-----------------------
! NASA Goddard Space Flight Center
! Land Information System Framework (LISF)
! Version 7.5
!
! Copyright (c) 2024 United States Government as represented by the
! Administrator of the National Aeronautics and Space Administration.
! All Rights Reserved.
!-------------------------END NOTICE -- DO NOT EDIT-----------------------

subroutine ancil_to_tile(n, t, pft)
  use ancil_info
  use jules5x_lsmMod
  implicit none 
  integer :: n, t, pft

  jules5x_struc(n)%jules5x(t)%ssi_pts                =  ssi_pts                !  Number of sea or sea-ice points
  jules5x_struc(n)%jules5x(t)%sea_pts                =  sea_pts                !  Number of sea points
  jules5x_struc(n)%jules5x(t)%sice_pts               =  sice_pts               !  Number of sea-ice points
  jules5x_struc(n)%jules5x(t)%ssi_index              =  ssi_index(1)              ! index of sea and sea-ice points
  jules5x_struc(n)%jules5x(t)%sea_index              =  sea_index(1)              ! index of sea points
  jules5x_struc(n)%jules5x(t)%sice_index             =  sice_index(1)             ! index of sea-ice points
  jules5x_struc(n)%jules5x(t)%sice_pts_ncat(:)       =  sice_pts_ncat(:)       ! number of points for each sea-ice category
  jules5x_struc(n)%jules5x(t)%sice_index_ncat(:)     =  sice_index_ncat(1, :)     ! index of points for each sea-ice category

  jules5x_struc(n)%jules5x(t)%soilt_pts              =  soilt_pts(1) 
  jules5x_struc(n)%jules5x(t)%soilt_index            =  soilt_index(1, 1)               !  indices of land points which include the nth surface type
  
  jules5x_struc(n)%jules5x(t)%l_soil_point           =  l_soil_point(1)        !  TRUE if a soil point  FALSE otherwise
  jules5x_struc(n)%jules5x(t)%l_lice_point           =  l_lice_point(1)        !  TRUE if a land ice point  FALSE otherwise
  jules5x_struc(n)%jules5x(t)%l_lice_surft(:)        =  l_lice_surft(:)        ! TRUE if a land ice (surface) tile, FALSE otherwise
  
  jules5x_struc(n)%jules5x(t)%fssi                   =  fssi_ij(1,1)                   !  Fraction of gridbox covered by sea or sea-ice
  jules5x_struc(n)%jules5x(t)%sea_frac               =  sea_frac(1)               !  Fraction of gridbox covered by sea (converted to single vector array)
  jules5x_struc(n)%jules5x(t)%sice_frac              =  sice_frac(1)              !  Fraction of gridbox covered by sea-ice converted to single vector array)
  jules5x_struc(n)%jules5x(t)%sice_frac_ncat(:)      =  sice_frac_ncat(1,:)      !  Fraction of gridbox covered by each sea-ice category (converted to single vector array)
  jules5x_struc(n)%jules5x(t)%frac_soilt             =  frac_soilt(1,1)        ! Fraction of gridbox for each soil tile
  
  jules5x_struc(n)%jules5x(t)%halo_i                 =  halo_i                 !  Size of halo in i direction
  jules5x_struc(n)%jules5x(t)%halo_j                 =  halo_j                 !  Size of halo in j direction
  jules5x_struc(n)%jules5x(t)%n_rows                 =  n_rows                 !  Number of rows in a v field
  jules5x_struc(n)%jules5x(t)%off_x                  =  off_x                  !  Size of small halo in i
  jules5x_struc(n)%jules5x(t)%off_y                  =  off_y                  !  Size of small halo in j
  jules5x_struc(n)%jules5x(t)%row_length             =  row_length             !  Number of points on a row
  jules5x_struc(n)%jules5x(t)%rows                   =  rows                   !  Number of rows in a theta field
  jules5x_struc(n)%jules5x(t)%co2_dim_len            =  co2_dim_len            !  Length of a CO2 field row
  jules5x_struc(n)%jules5x(t)%co2_dim_row            =  co2_dim_row            !  Number of CO2 field rows
  
  jules5x_struc(n)%jules5x(t)%land_pts               =  land_pts               !  No. of land points
  jules5x_struc(n)%jules5x(t)%land_pts_trif          =  land_pts_trif          !  For dimensioning land fields in TRIFFID
  jules5x_struc(n)%jules5x(t)%lice_pts               =  lice_pts               !  Number of land ice points
  jules5x_struc(n)%jules5x(t)%npft_trif              =  npft_trif              !  For dimensioning pft fields in TRIFFID =npft when TRIFFID on, otherwise =1
  jules5x_struc(n)%jules5x(t)%nsurft                 =  nsurft                 !  Number of surface tiles
  jules5x_struc(n)%jules5x(t)%soil_pts               =  soil_pts               !  Number of soil points
  jules5x_struc(n)%jules5x(t)%dim_cs1                =  dim_cs1                !  size of second dimension in soil carbon (cs) and related respiration variables
  jules5x_struc(n)%jules5x(t)%dim_cs2                =  dim_cs2                !  size used for some variables that are only used with TRIFFID. If not using TRIFFID these variables are set to be smaller to save some space
  
  jules5x_struc(n)%jules5x(t)%land_index             =  land_index(1)             !  index of land points
  jules5x_struc(n)%jules5x(t)%tile_index(pft)        =  surft_index(1, pft)          !  indices of land points which include the nth surface type
  jules5x_struc(n)%jules5x(t)%soil_index             =  soil_index(1)             !  index of soil points (i.e. land point number for each soil point)
  jules5x_struc(n)%jules5x(t)%lice_index             =  lice_index(1)          !  index of land ice points (i.e. land point number for each land ice point)
  jules5x_struc(n)%jules5x(t)%tile_pts(pft)          =  surft_pts(pft)            !  Number of land points which include the nth surface type
  jules5x_struc(n)%jules5x(t)%frac(pft)              =  frac_surft(1,pft)                !  fractional cover of each surface type
  
  jules5x_struc(n)%jules5x(t)%z1_tq                  =  z1_tq_ij(1,1)                  !  height of temperature data
  jules5x_struc(n)%jules5x(t)%z1_uv                  =  z1_uv_ij(1,1)                  !  height of wind data
  jules5x_struc(n)%jules5x(t)%ice_fract              =  ice_fract_ij(1,1)              !  fraction of gridbox covered by sea-ice  (decimal fraction)
  jules5x_struc(n)%jules5x(t)%ice_fract_ncat(:)      =  ice_fract_ncat_sicat(1,1,:)      !  fraction of gridbox covered by sea-ice on catagories
  jules5x_struc(n)%jules5x(t)%ti_cat(:)              =  ti_cat_sicat(1,1, :)              ! sea ice surface temperature on categories
  jules5x_struc(n)%jules5x(t)%pond_frac_cat(:)       =  pond_frac_cat_sicat(1,1,:)       ! Meltpond fraction on sea ice categories 
  jules5x_struc(n)%jules5x(t)%pond_depth_cat(:)      =  pond_depth_cat_sicat(1,1,:)      ! Meltpond depth on sea ice categories (m)  
  jules5x_struc(n)%jules5x(t)%sstfrz                 =  sstfrz_ij(1,1)                 ! Salinity-dependent sea surface freezing temperature (K)
  jules5x_struc(n)%jules5x(t)%land_mask              =  land_mask(1,1)              !     t if land, f elsewhere
end subroutine ancil_to_tile

