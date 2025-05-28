#if defined CARB 
      real(r8), parameter :: Acoef = 2073.1_r8      ! Schmidt
      real(r8), parameter :: Bcoef = 125.62_r8      ! number
      real(r8), parameter :: Ccoef = 3.6276_r8      ! transfer
      real(r8), parameter :: Dcoef = 0.043219_r8    ! coefficients
      real(r8), parameter :: A1 = -60.2409_r8       ! surface
      real(r8), parameter :: A2 = 93.4517_r8        ! CO2
      real(r8), parameter :: A3 = 23.3585_r8        ! solubility
      real(r8), parameter :: B1 = 0.023517_r8       ! coefficients
      real(r8), parameter :: B2 = -0.023656_r8
      real(r8), parameter :: B3 = 0.0047036_r8
# if defined NEMURO_CO2_TREND
      real(r8), parameter, dimension(12) :: pCO2air_mo =                &
     &    (/ 0.05_r8, 0.67_r8, 1.45_r8, 2.59_r8, 3.03_r8, 2.32_r8,      &
     &       0.72_r8,-1.45_r8,-3.13_r8,-3.24_r8,-2.07_r8,-0.90_r8 /)
# endif
#endif
