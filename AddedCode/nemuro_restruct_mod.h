      MODULE mod_biology
!
!git $Id$
!================================================== Hernan G. Arango ===
!  Copyright (c) 2002-2025 The ROMS Group                              !
!    Licensed under a MIT/X style license                              !
!    See License_ROMS.md                                               !
!=======================================================================
!                                                                      !
!  Parameters for Nemuro ecosystem model:                              !
!                                                                      !
!  AlphaPS     Small Phytoplankton photochemical reaction coefficient: !
!                initial slope (low light) of the P-I curve,           !
!                [1/(W/m2) 1/day].                                     !
!  AlphaPL     Large Phytoplankton photochemical reaction coefficient: !
!                initial slope (low light) of the P-I curve,           !
!                [1/(W/m2) 1/day].                                     !
!  AlphaZL     Large Zooplankton assimilation efficiency,              !
!                [nondimemsional].                                     !
!  AlphaZP     Predator Zooplankton assimilation efficiency,           !
!                [nondimemsional].                                     !
!  AlphaZS     Small Zooplankton assimilation efficiency,              !
!                [nondimemsional].                                     !
#if defined NEMURO_CHL && ! defined NEMURO_CHL_STATICRATIO
!  AttChl      Light attenuation due to chlorophyll,                   !
!                [m2/millimole_N].                                     !
# if defined NEMURO_CHL_CHL2NMIN
!  Chl2NS_min  Min small phytoplankton Chl:N ratio, [g_chl/mol_N].     !
!  Chl2NL_min  Min large phytoplankton Chl:N ratio, [g_chl/mol_N].     !
# endif
!  Chl2NS_max  Max small phytoplankton Chl:N ratio, [g_chl/mol_N].     !
!  Chl2NL_max  Max large phytoplankton Chl:N ratio, [g_chl/mol_N].     !
# if defined NEMURO_CHL_GEIDER_ACCLIM || defined NEMURO_CHL_NUDGECHL2N
!  chltacclimS Time scale for Small Phytoplankton acclimatization.     !
!  chltacclimL Time scale for Large Phytoplankton acclimatization.     !
# endif
#else
!  AttPL       Light attenuation due to Large Phytoplankton, self-     !
!                shading coefficient, [m2/millimole_N].                !
!  AttPS       Light attenuation due to Small Phytoplankton, self-     !
!                shading coefficient, [m2/millimole_N].                !
#endif
!  AttSW       Light attenuation due to sea water, [1/m].              !
#if ! defined NEMURO_CHL_GEIDER && ! defined NEMURO_CHL_NUDGECHL2N
!  BetaPL      Large Phytoplankton photoinhibition coefficient,        !
!                [1/(W/m2) 1/day].                                     !
!  BetaPS      Small Phytoplankton photoinhibition coefficient,        !
!                [1/(W/m2) 1/day].                                     !
#endif
!  BetaZL      Large Zooplankton growth efficiency [nondimensional].   !
!  BetaZP      Predator Zooplankton growth efficiency [nondimensional].!
!  BetaZS      Small Zooplankton growth efficiency [nondimensional].   !
!  BioIter     Maximum number of iterations to achieve convergence of  !
!                the nonlinear solution.                               !
#if defined NEM_SPONGE
!  nemSpongeN  Number of points near the boundary over which to        !
!                enhance phytoplankton mortality.                      !
!  nemSpongeF  Maximum factor to enhance phytoplankton mortality       !
!                near boundary.                                        !
#endif
!  GammaL      Large Phytoplankton ratio of extracellular excretion to !
!                photosynthesis [nondimensional].                      !
!  GammaS      Small Phytoplankton ratio of extracellular excretion to !
!                photosynthesis [nondimensional].                      !
!  GRmaxLpl    Large Zooplankton maximum grazing rate on Large         !
!                Phytoplankton at 0 Celsius, [1/day].                  !
!  GRmaxLps    Large Zooplankton maximum grazing rate on Small         !
!                Phytoplankton at 0 Celsius, [1/day].                  !
!  GRmaxLzs    Small Zooplankton maximum grazing rate on Small         !
!                Zooplankton at 0 Celsius, [1/day].                    !
!  GRmaxPpl    Predator Zooplankton maximum grazing rate on Large      !
!                Phytoplankton at 0 Celsius, [1/day].                  !
!  GRmaxPzl    Predator Zooplankton maximum grazing rate on Large      !
!                Phytoplankton at 0 Celsius, [1/day].                  !
!  GRmaxPzs    Predator Zooplankton maximum grazing rate on Small      !
!                Zooplankton at 0 Celsius, [1/day].                    !
!  GRmaxSps    Small Zooplankton maximum grazing rate on Small         !
!                Phytoplankton at 0 Celsius, [1/day].                  !
#ifdef NEMUCSC
!  GRmaxSpl    Small Zooplankton maximum grazing rate on Large         !
!                Phytoplankton at 0 Celsius, [1/day].                  !
#endif
!  KD2N        Temperature coefficient for DON to NH4 decomposition,   !
!                [1/Celsius].                                          !
!  KGppL       Large Phytoplankton temperature coefficient for         !
!                photosynthetic rate, [1/Celsius].                     !
!  KGppS       Small Phytoplankton temperature coefficient for         !
!                photosynthetic rate, [1/Celsius].                     !
!  KGraL       Large Zooplankton temperature coefficient for grazing,  !
!                [1/Celsius].                                          !
!  KGraP       Predator Zooplankton temperature coefficient for        !
!                grazing,[1/Celsius].                                  !
!  KGraS       Small Zooplankton temperature coefficient for grazing,  !
!                [1/Celsius].                                          !
!  KMorPL      Large Phytoplankton temperature coefficient for         !
!                mortality, [1/Celsius].                               !
!  KMorPS      Small Phytoplankton temperature coefficient for         !
!                mortality, [1/Celsius].                               !
!  KMorZL      Large Zooplankton temperature coefficient for           !
!                mortality, [1/Celsius].                               !
!  KMorZP      Predator Zooplankton temperature coefficient for        !
!                mortality, [1/Celsius].                               !
!  KMorZS      Small Zooplankton temperature coefficient for           !
!                mortality, [1/Celsius].                               !
!  KNit        Temperature coefficient for nitrification (NH4 to NO3)  !
!                decomposition, [1/Celsius].                           !
!  KNH4L       Large Phytoplankton half satuation constant for NH4,    !
!                [millimole_N/m3].                                     !
!  KNH4S       Small Phytoplankton half satuation constant for NH4,    !
!                [millimole_N/m3].                                     !
!  KNO3L       Large Phytoplankton half satuation constant for NO3,    !
!                [millimole_N/m3].                                     !
!  KNO3S       Small Phytoplankton half satuation constant for NO3,    !
!                [millimole_N/m3].                                     !
!  KO2S        Temperature coefficient for Opal to SiOH4 decomposition,!
!                [1/Celsius].                                          !
!  KP2D        Temperature coefficient for PON to DON decomposition,   !
!                [1/Celsius].                                          !
!  KP2N        Temperature coefficient for PON to NH4 decomposition,   !
!                [1/Celsius].                                          !
!  KPL2ZL      Large Zooplankton half-saturation coefficient for       !
!                ingestion on Large Phytoplankton [millimole_N/m3]^2.  !
!  KPL2ZP      Predator Zooplankton half-saturation coefficient for    !
!                ingestion on Large Phytoplankton [millimole_N/m3]^2.  !
!  KPS2ZL      Larg Zooplankton half-saturation coefficient for        !
!                ingestion on Small Phytoplankton [millimole_N/m3]^2.  !
!  KPS2ZS      Small Zooplankton half-saturation coefficient for       !
!                ingestion on Small Phytoplankton [millimole_N/m3]^2.  !
#ifdef NEMUCSC
!  KPL2ZS      Small Zooplankton half-saturation coefficient for       !
!                ingestion on Large Phytoplankton [millimole_N/m3]^2.  !
#endif
!  KResPL      Large Phytoplankton temperature coefficient for         !
!                respiration, [1/Celsius].                             !
!  KResPS      Small Phytoplankton temperature coefficient for         !
!                respiration, [1/Celsius].                             !
!  KSiL        Large Phytoplankton half satuation constant for SiOH4,  !
!                [millimole_Si/m3].                                    !
!  KZL2ZP      Predator Zooplankton half-saturation coefficient for    !
!                ingestion on Large Zooplankton [millimole_N/m3]^2.    !
!  KZS2ZL      Large Zooplankton half-saturation coefficient for       !
!                ingestion on Small Phytoplankton [millimole_N/m3]^2.  !
!  KZS2ZP      Predator Zooplankton half-saturation coefficient for    !
!                ingestion on Small Zooplankton [millimole_N/m3]^2.    !
!  LamL        Large Zooplankton Ivlev constant, [m3/millimole_N].     !
!  LamP        Predator Zooplankton Ivlev constant, [m3/millimole_N].  !
!  LamS        Small Zooplankton Ivlev constant, [m3/millimole_N].     !
!  MorPL0      Large Phytoplankton mortality rate at 0 Celsius,        !
!                [m3/millimole_N 1/day].                               !
!  MorPS0      Small Phytoplankton mortality rate at 0 Celsius,        !
!                [m3/millimole_N 1/day].                               !
!  MorZL0      Large Zooplankton mortality rate at 0 Celsius,          !
!                [m3/millimole_N 1/day].                               !
!  MorZP0      Predator Zooplankton mortality rate at 0 Celsius,       !
!                [m3/millimole_N 1/day].                               !
!  MorZS0      Small Zooplankton mortality rate at 0 Celsius,          !
!                [m3/millimole_N 1/day].                               !
!  Nit0        Nitrification (NH4 to NO3) rate at 0 Celsius, [1/day].  !
!  PARfrac     Fraction of shortwave radiation that is available for   !
!                photosyntesis [nondimensional].                       !
!  PL2ZLstar   Large Zooplankton threshold value for grazing on        !
!                Large Phytoplankton, [millimole_N/m3].                !
!  PL2ZPstar   Predator Zooplankton threshold value for grazing on     !
!                Large Phytoplankton, [millimole_N/m3].                !
!  PS2ZLstar   Large Zooplankton threshold value for grazing on        !
!                Small Phytoplankton, [millimole_N/m3].                !
!  PS2ZSstar   Small Zooplankton threshold value for grazing on        !
!                Small Phytoplankton, [millimole_N/m3].                !
#ifdef NEMUCSC
!  PL2ZSstar   Small Zooplankton threshold value for grazing on        !
!                Large Phytoplankton, [millimole_N/m3].                !
#endif
!  PusaiL      Large Phytoplankton Ammonium inhibition coefficient,    !
!                [m3/millimole_N].                                     !
!  PusaiPL     Predator Zooplankton grazing on Large Phytoplankton     !
!                inhibition coefficient, [m3/millimole_N].             !
!  PusaiS      Small Phytoplankton Ammonium inhibition coefficient,    !
!                [m3/millimole_N].                                     !
!  PusaiZS     Predator Zooplankton grazing on Small Zooplankton       !
!                inhibition coefficient, [m3/millimole_N].             !
!  ResPL0      Large Phytoplankton respiration rate at 0 Celsius,      !
!                [1/day].                                              !
!  ResPS0      Small Phytoplankton respiration rate at 0 Celsius,      !
!                [1/day].                                              !
!  RSiN        Si:N ratio [millimole_Si/millimole_N].                  !
!  setVOpal    Opal Settling (sinking) velocity [m/day].               !
!  setVPON     PON Settling (sinking) velocity [m/day].                !
!  VD2N0       DON to NH4 decomposition rate at 0 Celsius, [1/day].    !
!  VmaxL       Maximum Large Phytoplankton photosynthetic rate [1/day] !
!                in the absence of photoinhibition under optimal light.!
!  VmaxS       Maximum Small Phytoplankton photosynthetic rate [1/day] !
!                in the absence of photoinhibition under optimal light.!
!  VO2S0       Opal to Silicate decomposition rate at 0 Celsius,       !
!                [1/day].                                              !
!  VP2D0       PON to DON decomposition rate at 0 Celsius, [1/day].    !
!  VP2N0       PON to NH4 decomposition rate at 0 Celsius, [1/day].    !
!  ZL2ZPstar   Small Zooplankton threshold value for grazing on        !
!                Small Phytoplankton, [millimole_N/m3].                !
!  ZS2ZLstar   Large Zooplankton threshold value for grazing on        !
!                Small Zooplankton, [millimole_N/m3].                  !
!  ZS2ZPstar   Predator Zooplankton threshold value for grazing on     !
!                Small Zooplankton, [millimole_N/m3].                  !
#if defined NEMURO_CHL && defined NEMURO_CHL_STATICRATIO
!  Chl2NS      Small phytoplankton Chl:N ratio, [g_chl/mol_N].         !
!  Chl2NL      Large phytoplankton Chl:N ratio, [g_chl/mol_N].         !
#endif
#ifdef NEM_IRON_LIMIT
! Parameters for iron limitation                                       !
!  T_Fe         [day]                                                  !
!  A_Fe         [nondimensional]                                       !
!  B_Fe         [1/M-C]                                                !
!  SK_FeC       [muM-Fe/M-C]                                           !
!  LK_FeC       [muM-Fe/M-C]                                           !
!  FeRR         [1/day]                                                !
# ifdef NEM_IRON_RELAX
!  FeHmin       [m]                                                    !
!  FeMax        [mmole/m3]                                             !
!  FeNudgTime   [day]                                                  !
!  FeN2FeC     FeN:C conversion ratio                                  !
!  FeC2FeN     FeC:N conversion ratio                                  !
# endif
#endif
#if defined CARB
! Parameters for carbon cycling                                        !
!  RedCN        Redfield carbon to nitrogen ratio.                     !
!  pCO2air      Atmospheric pCO2 (fixed).                              !
# if defined NEMURO_CO2_TREND
!  pCO2trend    Atmospheric pCO2 trend (fixed).                        !
# endif
# if defined DOR
!  DOR         DIC anomaly from direct ocean removal mmol C m-3        !
# endif   
# if defined OAE
!  OAE         TA anomaly from ocean alkalinity enahncement mmolEq m-3 !
# endif        
#endif
!                                                                      !
!=======================================================================
!
      USE mod_param
!
      implicit none
!
!  Set biological tracer identification indices.
!
      integer, allocatable :: idbio(:)  ! Biological tracers
      integer :: iLphy                  ! Large Phytoplankton biomass
      integer :: iSphy                  ! Small Phytoplankton biomass
      integer :: iLzoo                  ! Large Zooplankton biomass
      integer :: iSzoo                  ! Small Zooplankton biomass
      integer :: iPzoo                  ! Predator Zooplankton biomass
      integer :: iNO3_                  ! Nitrate concentration
      integer :: iNH4_                  ! Ammonium concentration
      integer :: iPON_                  ! Particulate Organic Nitrogen
      integer :: iDON_                  ! Dissolved Organic Nitrogen
      integer :: iSiOH                  ! Silicate concentration
      integer :: iopal                  ! Particulate organic silica
#if defined NEMURO_CHL
      integer :: iChlo                  ! Chlorophyll
# if defined NEMURO_CHL_GEIDER || defined NEMURO_CHL_NUDGECHL2N
      integer :: iChlS                  ! Small Phytoplankton chlorophyll
      integer :: iChlL                  ! Large Phytoplankton chlorophyll
# endif
#endif
#if defined N15
      integer :: iLphy15                ! Large Phytoplankton 15N biomass
      integer :: iSphy15                ! Small Phytoplankton 15N biomass
      integer :: iLzoo15                ! Large Zooplankton 15N biomass
      integer :: iSzoo15                ! Small Zooplankton 15N biomass
      integer :: iPzoo15                ! Predator Zooplankton 15N biomass
      integer :: iNO315_                ! 15N Nitrate concentration
      integer :: iNH415_                ! 15N Ammonium concentration
      integer :: iPON15_                ! 15N Particulate Organic Nitrogen
      integer :: iDON15_                ! 15N Dissolved Organic Nitrogen
      integer :: iLphy14                ! Large Phytoplankton 14N biomass
      integer :: iSphy14                ! Small Phytoplankton 14N biomass
      integer :: iLzoo14                ! Large Zooplankton 14N biomass
      integer :: iSzoo14                ! Small Zooplankton 14N biomass
      integer :: iPzoo14                ! Predator Zooplankton 14N biomass
      integer :: iNO314_                ! 14N Nitrate concentration
      integer :: iNH414_                ! 14N Ammonium concentration
      integer :: iPON14_                ! 14N Particulate Organic Nitrogen
      integer :: iDON14_                ! 14N Dissolved Organic Nitrogen
      integer :: iPONratio              ! 15N PON/14N PON for sinking 
#endif
#ifdef OXY
      integer :: iOxyg                  ! Oxygen
#endif
#ifdef CARB
      integer :: iTIC_                  ! Total inorganic carbon
      integer :: iTAlk                  ! Total alkalinity
      integer :: iCalC                  ! Calcium carbonate concentration
#endif
#ifdef ISO
      integer :: iDI13C                   ! Amount of 13C in DIC
      integer :: iDI14C                   ! Amount of 14C in DIC
#endif
#ifdef ISO_13C
      integer :: iDI13C                   ! Amount of 13C in DIC
#endif
#ifdef OAE
      integer :: iOAE_                   ! TA anomaly from OAE 
#endif
#ifdef DOR
      integer :: iDOR_                   ! DIC anomaly from DOR
#endif
#ifdef NEM_IRON_LIMIT
      integer :: iFeSp                  ! Small phytoplankton iron
      integer :: iFeLp                  ! Large phytoplankton iron
      integer :: iFeD_                  ! Available dissolved iron
#endif
#if defined DIAGNOSTICS && defined DIAGNOSTICS_BIO
!
!  Biological 2D diagnostic variable IDs.
!
      integer, allocatable :: iDbio2(:)       ! 2D biological terms

!
!  Biological 3D diagnostic variable IDs.
!
      integer, allocatable :: iDbio3(:)       ! 3D biological terms

      integer  :: idia                        ! a local index variable

# ifdef DIAGNOSTICS_NEM_LIM 
      integer  :: iNO3LimSp                   ! small P NO3 limitation
      integer  :: iNH4LimSp                   ! small P NH4 limitation
      integer  :: iNO3LimLp                   ! large P NO3 limitation
      integer  :: iNH4LimLp                   ! large P NH4 limitation
      integer  :: iSiLimLp                    ! large P SiOH limitation
#  ifdef NEM_IRON_LIMIT
      integer  :: iFeLimSp                    ! small P Fe limitation
      integer  :: iFeLimLp                    ! large P Fe limitation
#  endif
# endif
# if defined DIAGNOSTICS_NEM_PHY || defined DIAGNOSTICS_NEM_NIT
      integer  :: iGppNPS                     ! gross small P prim prod from NO3
      integer  :: iGppAPS                     ! gross small P prim prod from NH4
      integer  :: iGppNPL                     ! gross large P prim prod from NO3
      integer  :: iGppAPL                     ! gross large P prim prod from NH4
      integer  :: iResPS2NO3                  ! small P respiration to NO3
      integer  :: iResPL2NO3                  ! large P respiration to NO3
      integer  :: iResPS2NH4                  ! small P respiration to NH4
      integer  :: iResPL2NH4                  ! large P respiration to NH4
# endif
# ifdef DIAGNOSTICS_NEM_PHY 
      integer  :: iExcPS                      ! small P excretion
      integer  :: iExcPL                      ! large P excretion
      integer  :: iMorPS                      ! small P mortality
      integer  :: iMorPL                      ! large P mortality
      integer  :: iFudgePS              ! correction for neg vals in small phyt
      integer  :: iFudgePL              ! correction for neg vals in large phyt
# endif
# if defined DIAGNOSTICS_NEM_PHY || defined DIAGNOSTICS_NEM_ZOO
      integer  :: iGraPS2ZS                   ! Grazing of small P by small Z
      integer  :: iGraPS2ZL                   ! Grazing of small P by large Z
      integer  :: iGraPL2ZS                   ! Grazing of large P by small Z
      integer  :: iGraPL2ZL                   ! Grazing of large P by large Z
      integer  :: iGraPL2ZP                   ! Grazing of large P by pred Z
# endif
# ifdef DIAGNOSTICS_NEM_ZOO
      integer  :: iGraZS2ZL                   ! Grazing of small Z by large Z
      integer  :: iGraZS2ZP                   ! Grazing of small Z by pred Z
      integer  :: iGraZL2ZP                   ! Grazing of large Z by pred Z
      integer  :: iFudgeZS              ! correction for neg vals in small zoop
      integer  :: iFudgeZL              ! correction for neg vals in large zoop
      integer  :: iFudgeZP              ! correction for neg vals in pred zoop
# endif
# if defined DIAGNOSTICS_NEM_ZOO || defined DIAGNOSTICS_NEM_NIT
      integer  :: iEgeZS                      ! Egestion by small Z
      integer  :: iEgeZL                      ! Egestion by large Z
      integer  :: iEgeZP                      ! Egestion by pred Z
      integer  :: iExcZS                      ! Excretion by small Z
      integer  :: iExcZL                      ! Excretion by large Z
      integer  :: iExcZP                      ! Excretion by pred Z
      integer  :: iMorZS                      ! Mortality by small Z
      integer  :: iMorZL                      ! Mortality by large Z
      integer  :: iMorZP                      ! Mortality by pred Z
# endif
# if defined DIAGNOSTICS_NEM_NIT
      integer  :: iNH42NO3                    ! Nitrification (NH4 to NO3)
      integer  :: iPON2DON                    ! conversion of PON to DON
      integer  :: iPON2NH4                    ! remin of PON to NH4
      integer  :: iPON2NO3                    ! remin of PON to NO3
      integer  :: iDON2NH4                    ! remin of DON to NH4
      integer  :: iSinkPON                    ! sinking of PON
      integer  :: iFudgeNO3             ! correction for neg vals in nitrate
      integer  :: iFudgeNH4             ! correction for neg vals in ammonium
      integer  :: iFudgePON             ! correction for neg vals in PON
      integer  :: iFudgeDON             ! correction for neg vals in DON
# endif
# if defined DIAGNOSTICS_NEM_SIL
      integer  :: iOpal2SiOH                  ! remin of Opal to SiOH
      integer  :: iSinkOpal                   ! sinking of Opal
      integer  :: iFudgeSiOH            ! correction for neg vals in silicate
      integer  :: iFudgeOpal            ! correction for neg vals in opal
# endif
# if defined DIAGNOSTICS_NEM_CHL
      integer  :: iChl2NS
      integer  :: irhoChlS
      integer  :: iLossPS
      integer  :: iChl2NL
      integer  :: irhoChlL
      integer  :: iLossPL
# endif
# if defined DIAGNOSTICS_ISO
      integer  :: i13CO2as
      integer  :: i13CO2sa
# endif
#endif
!
!  Biological parameters.
!
      integer, allocatable :: BioIter(:)

      real(r8), allocatable :: AlphaPL(:)            ! 1/(W/m2) 1/day
      real(r8), allocatable :: AlphaPS(:)            ! 1/(W/m2) 1/day
      real(r8), allocatable :: AlphaZL(:)            ! nondimensional
      real(r8), allocatable :: AlphaZP(:)            ! nondimensional
      real(r8), allocatable :: AlphaZS(:)            ! nondimensional
#if defined NEMURO_CHL && ! defined NEMURO_CHL_STATICRATIO
      real(r8), allocatable :: AttChl(:)             ! m2/mg_chl
      real(r8), allocatable :: Chl2NS_max(:)         ! g_chl/mol_N
      real(r8), allocatable :: Chl2NL_max(:)         ! g_chl/mol_N
# if defined NEMURO_CHL_CHL2NMIN
      real(r8), allocatable :: Chl2NS_min(:)         ! g_chl/mol_N
      real(r8), allocatable :: Chl2NL_min(:)         ! g_chl/mol_N
# endif
# if defined NEMURO_CHL_GEIDER_ACCLIM || defined NEMURO_CHL_NUDGECHL2N
      real(r8), allocatable :: chltacclimS(:)
      real(r8), allocatable :: chltacclimL(:)
# endif
#else
      real(r8), allocatable :: AttPL(:)              ! m2/mmole_N
      real(r8), allocatable :: AttPS(:)              ! m2/mmole_N
#endif
      real(r8), allocatable :: AttSW(:)              ! 1/m
#if ! defined NEMURO_CHL_GEIDER && ! defined NEMURO_CHL_NUDGECHL2N
      real(r8), allocatable :: BetaPL(:)             ! 1/(W/m2) 1/day
      real(r8), allocatable :: BetaPS(:)             ! 1/(W/m2) 1/day
#endif
      real(r8), allocatable :: BetaZS(:)             ! nondimensional
      real(r8), allocatable :: BetaZL(:)             ! nondimensional
      real(r8), allocatable :: BetaZP(:)             ! nondimensional
#if defined BIOMIN_PARAMETER
      real(r8), allocatable :: BioMin(:)             ! nondimensional
#endif
      real(r8), allocatable :: GammaL(:)             ! nondimensional
      real(r8), allocatable :: GammaS(:)             ! nondimensional
      real(r8), allocatable :: GRmaxLpl(:)           ! 1/day
      real(r8), allocatable :: GRmaxLps(:)           ! 1/day
      real(r8), allocatable :: GRmaxLzs(:)           ! 1/day
      real(r8), allocatable :: GRmaxPpl(:)           ! 1/day
      real(r8), allocatable :: GRmaxPzl(:)           ! 1/day
      real(r8), allocatable :: GRmaxPzs(:)           ! 1/day
      real(r8), allocatable :: GRmaxSps(:)           ! 1/day
#if defined NEMUCSC
      real(r8), allocatable :: GRmaxSpl(:)           ! 1/day
#endif
      real(r8), allocatable :: KD2N(:)               ! 1/Celsius
      real(r8), allocatable :: KGppL(:)              ! 1/Celsius
      real(r8), allocatable :: KGppS(:)              ! 1/Celsius
      real(r8), allocatable :: KGraL(:)              ! 1/Celsius
      real(r8), allocatable :: KGraP(:)              ! 1/Celsius
      real(r8), allocatable :: KGraS(:)              ! 1/Celsius
      real(r8), allocatable :: KMorPL(:)             ! 1/Celsius
      real(r8), allocatable :: KMorPS(:)             ! 1/Celsius
      real(r8), allocatable :: KMorZL(:)             ! 1/Celsius
      real(r8), allocatable :: KMorZP(:)             ! 1/Celsius
      real(r8), allocatable :: KMorZS(:)             ! 1/Celsius
      real(r8), allocatable :: KNH4L(:)              ! mmole_N/m3
      real(r8), allocatable :: KNH4S(:)              ! mmole_N/m3
      real(r8), allocatable :: KNit(:)               ! 1/Celsius
      real(r8), allocatable :: KNO3L(:)              ! mmole_N/m3
      real(r8), allocatable :: KNO3S(:)              ! mmole_N/m3
      real(r8), allocatable :: KO2S(:)               ! 1/Celsius
      real(r8), allocatable :: KP2D(:)               ! 1/Celsius
      real(r8), allocatable :: KP2N(:)               ! 1/Celsius
      real(r8), allocatable :: KPL2ZL(:)             ! mmole_N/m3
      real(r8), allocatable :: KPS2ZL(:)             ! mmole_N/m3
      real(r8), allocatable :: KPS2ZS(:)             ! mmole_N/m3
#if defined NEMUCSC
      real(r8), allocatable :: KPL2ZS(:)             ! mmole_N/m3
#endif
      real(r8), allocatable :: KPL2ZP(:)             ! mmole_N/m3
      real(r8), allocatable :: KResPL(:)             ! 1/Celsius
      real(r8), allocatable :: KResPS(:)             ! 1/Celsius
      real(r8), allocatable :: KSiL(:)               ! mmole_Si/m3
      real(r8), allocatable :: KZL2ZP(:)             ! mmole_N/m3
      real(r8), allocatable :: KZS2ZL(:)             ! mmole_N/m3
      real(r8), allocatable :: KZS2ZP(:)             ! mmole_N/m3
      real(r8), allocatable :: LamL(:)               ! m3/mmole_N
      real(r8), allocatable :: LamP(:)               ! m3/mmole_N
      real(r8), allocatable :: LamS(:)               ! m3/mmole_N
      real(r8), allocatable :: MorPL0(:)             ! m3/mmole_N/day
      real(r8), allocatable :: MorPS0(:)             ! m3/mmole_N/day
      real(r8), allocatable :: MorZL0(:)             ! m3/mmole_N 1/day
      real(r8), allocatable :: MorZP0(:)             ! m3/mmole_N 1/day
      real(r8), allocatable :: MorZS0(:)             ! m3/mmole_N 1/day
      real(r8), allocatable :: Nit0(:)               ! 1/day
      real(r8), allocatable :: PARfrac(:)            ! nondimensional
#ifdef TANGENT
      real(r8), allocatable :: tl_PARfrac(:)         ! nondimensional
#endif
#ifdef ADJOINT
      real(r8), allocatable :: ad_PARfrac(:)         ! nondimensional
#endif
      real(r8), allocatable :: PusaiL(:)             ! m3/mmole_N
      real(r8), allocatable :: PusaiPL(:)            ! m3/mmole_N
      real(r8), allocatable :: PusaiS(:)             ! m3/mmole_N
      real(r8), allocatable :: PusaiZS(:)            ! m3/mmole_N
      real(r8), allocatable :: PL2ZLstar(:)          ! mmole_N/m3
      real(r8), allocatable :: PL2ZPstar(:)          ! mmole_N/m3
      real(r8), allocatable :: PS2ZLstar(:)          ! mmole_N/m3
      real(r8), allocatable :: PS2ZSstar(:)          ! mmole_N/m3
#if defined NEMUCSC
      real(r8), allocatable :: PL2ZSstar(:)          ! mmole_N/m3
#endif
      real(r8), allocatable :: ResPL0(:)             ! 1/day
      real(r8), allocatable :: ResPS0(:)             ! 1/day
      real(r8), allocatable :: RSiN(:)               ! mmole_Si/mmole_N
      real(r8), allocatable :: setVOpal(:)           ! m/day
#ifdef TANGENT
      real(r8), allocatable :: tl_setVOpal(:)        ! m/day
#endif
#ifdef ADJOINT
      real(r8), allocatable :: ad_setVOpal(:)        ! m/day
#endif
      real(r8), allocatable :: setVPON(:)            ! m/day
#if defined N15
# ifdef SINK_RATIO
      real(r8), allocatable :: setVPONratio(:)       ! m/day
# else
      real(r8), allocatable :: setVPON14(:)          ! m/day
      real(r8), allocatable :: setVPON15(:)          ! m/day
# endif
#endif
#ifdef TANGENT
      real(r8), allocatable :: tl_setVPON(:)         ! m/day
#endif
#ifdef ADJOINT
      real(r8), allocatable :: ad_setVPON(:)         ! m/day
#endif
      real(r8), allocatable :: VD2N0(:)              ! 1/day
      real(r8), allocatable :: VmaxL(:)              ! 1/day
      real(r8), allocatable :: VmaxS(:)              ! 1/day
      real(r8), allocatable :: VO2S0(:)              ! 1/day
      real(r8), allocatable :: VP2D0(:)              ! 1/day
      real(r8), allocatable :: VP2N0(:)              ! 1/day
      real(r8), allocatable :: ZL2ZPstar(:)          ! mmole_N/m3
      real(r8), allocatable :: ZS2ZLstar(:)          ! mmole_N/m3
      real(r8), allocatable :: ZS2ZPstar(:)          ! mmole_N/m3
#if defined NEMURO_CHL && defined NEMURO_CHL_STATICRATIO
      real(r8), allocatable :: Chl2NS(:)             ! g_chl/mol_N
      real(r8), allocatable :: Chl2NL(:)             ! g_chl/mol_N
#endif
#if defined N15
      real(r8), allocatable :: eps_GppNO3(:)         ! permil
      real(r8), allocatable :: eps_GppNH4(:)         ! permil
      real(r8), allocatable :: eps_exc(:)            ! permil
      real(r8), allocatable :: eps_nitrif(:)         ! permil
      real(r8), allocatable :: eps_remin(:)          ! permil
      real(r8), allocatable :: eps_decomp(:)         ! permil
      real(r8), allocatable :: eps_reminDON(:)       ! permil
# if defined DENIT
      real(r8), allocatable :: eps_denit(:)            ! permil
# endif
#endif
#ifdef CARB
      real(r8), allocatable :: RedCN(:)              ! mol_C/mol_N
      real(r8), allocatable :: pCO2air(:)            ! ppmv
# if defined NEMURO_CO2_TREND
      real(r8), allocatable :: pCO2trend(:)          ! ppmv per year
# endif
#endif

#ifdef NEM_IRON_LIMIT
      real(r8), allocatable :: T_Fe(:)               ! day
      real(r8), allocatable :: A_Fe(:)               ! nondimensional
      real(r8), allocatable :: B_Fe(:)               ! 1/M-C
      real(r8), allocatable :: SK_FeC(:)             ! muM-Fe/M-C
      real(r8), allocatable :: LK_FeC(:)             ! muM-Fe/M-C
      real(r8), allocatable :: FeRR(:)               ! 1/day
# ifdef NEM_IRON_RELAX
      real(r8), allocatable :: FeHmin(:)             ! m
      real(r8), allocatable :: FeMax(:)              ! mmole/m3
      real(r8), allocatable :: FeNudgTime(:)         ! day
# endif
#endif
#ifdef NEM_SPONGE
      integer, allocatable :: nemSpongeN(:)          ! number of points
      real(r8), allocatable :: nemSpongeF(:)         ! nondimensional
#endif

#if defined NEM_IRON_LIMIT
!
!  Set Fe:N and Fe:C conversion ratio and its inverse.
!
      real(r8), parameter :: FeN2FeC=(16.0_r8/106.0_r8)*1.0E3_r8
      real(r8), parameter :: FeC2FeN=(106.0_r8/16.0_r8)*1.0E-3_r8
#endif
#if defined CARB & ! defined KO_CARB_SINK
      integer, parameter :: Nsink = 3
#elif defined N15 & defined SINK_RATIO
      integer, parameter :: Nsink = 3
#elif defined N15 & ! defined SINK_RATIO
      integer, parameter :: Nsink = 4
#else
      integer, parameter :: Nsink = 2
#endif
#if defined MINVAL_NL
      real(r8), parameter :: BIOmin = MINVAL_NL
#else
      real(r8), parameter :: BIOmin = 1.0e-6_r8
#endif
! PM:
! BIOmin_lin is used in the tangent linear and adjoint code in place of
! BIOmin. Under certain conditions (low NO3 and NH4) the tangent linear and
! especially the adjoint code can develop linear instabilities that can lead
! to blowups (in the adjoint code ad_GppNPS is prone to grow very large).
! BIOmin_lin is larger than BIOmin to prevent these blowups. The effect
! of this change under normal conditions should be small.
!
#if defined MINVAL_LIN
      real(r8), parameter :: BIOmin_lin = MINVAL_LIN
#else
      real(r8), parameter :: BIOmin_lin = 1.0e-5_r8
#endif
#if defined OXY
      real(r8), parameter :: rOxNO3= 8.625_r8       ! 138/16
      real(r8), parameter :: rOxNH4= 6.625_r8       ! 106/16
      real(r8), parameter :: l2mol = 1000.0_r8/22.3916_r8      ! from ml/l to umol/l (=mmol/m3)
#endif

      real(r8), allocatable :: new_dtdays(:)   ! day
      integer, dimension(Nsink) :: idsink
      real(r8), allocatable :: new_Wbio(:,:)
!
      CONTAINS
!
      SUBROUTINE initialize_biology
!
!=======================================================================
!                                                                      !
!  This routine sets several variables needed by the biology model.    !
!  It allocates and assigns biological tracers indices.                !
!                                                                      !
!=======================================================================
!
!  Local variable declarations
!
      integer :: i, ic
#if defined CARB || \
    defined OXY ||  \
    defined N15 ||  \
    defined NEMURO_CHL || \
    defined NEM_IRON_LIMIT
      integer :: ic_offset
#endif
!
!-----------------------------------------------------------------------
!  Set number of biological tracers.
!-----------------------------------------------------------------------
!
#if defined N15
# if defined SINK_RATIO
      NBT=30
# else
      NBT=29
# endif
#else
      NBT=11
#endif
#if defined NEMURO_CHL
      NBT=NBT+1
# if defined NEMURO_CHL_GEIDER || defined NEMURO_CHL_NUDGECHL2N
      NBT=NBT+2
# endif
#endif
#ifdef OXY
      NBT=NBT+1
#endif
#ifdef CARB
      NBT=NBT+3
#endif
#ifdef ISO
      NBT=NBT+2
#endif
#ifdef ISO_13C
      NBT=NBT+1
#endif
#ifdef OAE
      NBT=NBT+1
#endif
#ifdef DOR
      NBT=NBT+1
#endif
#ifdef CONSERVATION
      NBT=NBT+3
#endif
#ifdef NEM_IRON_LIMIT
      NBT=NBT+3
#endif
#if defined DIAGNOSTICS && defined DIAGNOSTICS_BIO
!
!-----------------------------------------------------------------------
!  Set sources and sinks biology diagnostic parameters.
!-----------------------------------------------------------------------
!
!  Set number of diagnostics terms.
!
      NDbio3d=0
      NDbio2d=0
      idia=0
# ifdef DIAGNOSTICS_NEM_LIM 
      idia=idia+1
      iNO3LimSp   = idia
      idia=idia+1
      iNH4LimSp   = idia
      idia=idia+1
      iNO3LimLp   = idia
      idia=idia+1
      iNH4LimLp   = idia
      idia=idia+1
      iSiLimLp    = idia
#  ifdef NEM_IRON_LIMIT
      idia=idia+1
      iFeLimSp    = idia
      idia=idia+1
      iFeLimLp    = idia
#  endif
# endif
# if defined DIAGNOSTICS_NEM_PHY || defined DIAGNOSTICS_NEM_NIT
      idia=idia+1
      iGppNPS    = idia
      idia=idia+1
      iGppAPS    = idia
      idia=idia+1
      iGppNPL    = idia
      idia=idia+1
      iGppAPL    = idia
      idia=idia+1
      iResPS2NO3 = idia
      idia=idia+1
      iResPL2NO3 = idia
      idia=idia+1
      iResPS2NH4  = idia
      idia=idia+1
      iResPL2NH4  = idia
# endif
# ifdef DIAGNOSTICS_NEM_PHY 
      idia=idia+1
      iExcPS     = idia
      idia=idia+1
      iExcPL     = idia
      idia=idia+1
      iMorPS     = idia
      idia=idia+1
      iMorPL     = idia
      idia=idia+1
      iFudgePS   = idia
      idia=idia+1
      iFudgePL   = idia
# endif
# if defined DIAGNOSTICS_NEM_PHY || defined DIAGNOSTICS_NEM_ZOO
      idia=idia+1
      iGraPS2ZS  = idia
      idia=idia+1
      iGraPS2ZL  = idia
      idia=idia+1
      iGraPL2ZS  = idia
      idia=idia+1
      iGraPL2ZL  = idia
      idia=idia+1
      iGraPL2ZP  = idia
# endif
# ifdef DIAGNOSTICS_NEM_ZOO 
      idia=idia+1
      iGraZS2ZL  = idia
      idia=idia+1
      iGraZS2ZP  = idia
      idia=idia+1
      iGraZL2ZP  = idia
      idia=idia+1
      iFudgeZS   = idia
      idia=idia+1
      iFudgeZL   = idia
      idia=idia+1
      iFudgeZP   = idia
# endif
# if defined DIAGNOSTICS_NEM_ZOO || defined DIAGNOSTICS_NEM_NIT
      idia=idia+1
      iEgeZS     = idia
      idia=idia+1
      iEgeZL     = idia
      idia=idia+1
      iEgeZP     = idia
      idia=idia+1
      iExcZS     = idia
      idia=idia+1
      iExcZL     = idia
      idia=idia+1
      iExcZP     = idia
      idia=idia+1
      iMorZS     = idia
      idia=idia+1
      iMorZL     = idia
      idia=idia+1
      iMorZP     = idia
# endif
# if defined DIAGNOSTICS_NEM_NIT
      idia=idia+1
      iNH42NO3   = idia
      idia=idia+1
      iPON2DON   = idia
      idia=idia+1
      iPON2NH4   = idia
      idia=idia+1
      iPON2NO3   = idia
      idia=idia+1
      iDON2NH4   = idia
      idia=idia+1
      iSinkPON   = idia
      idia=idia+1
      iFudgeNO3  = idia
      idia=idia+1
      iFudgeNH4  = idia
      idia=idia+1
      iFudgePON  = idia
      idia=idia+1
      iFudgeDON  = idia
# endif
# if defined DIAGNOSTICS_NEM_SIL
      idia=idia+1
      iOpal2SiOH = idia
      idia=idia+1
      iSinkOpal  = idia
      idia=idia+1
      iFudgeSiOH = idia
      idia=idia+1
      iFudgeOpal = idia
# endif
# if defined DIAGNOSTICS_NEM_CHL
      idia=idia+1
      iChl2NS = idia
      idia=idia+1
      irhoChlS = idia
      idia=idia+1
      iLossPS = idia
      idia=idia+1
      iChl2NL = idia
      idia=idia+1
      irhoChlL = idia
      idia=idia+1
      iLossPL = idia
# endif
      NDbio3d=NDbio3d+idia
!
!  Allocate biological diagnostics vectors
!
      IF (.not.allocated(iDbio2)) THEN
        allocate ( iDbio2(NDbio2d) )
      END IF
      IF (.not.allocated(iDbio3)) THEN
        allocate ( iDbio3(NDbio3d) )
      END IF
#endif
!
!-----------------------------------------------------------------------
!  Allocate various module variables.
!-----------------------------------------------------------------------
!
      IF (.not.allocated(BioIter)) THEN
        allocate ( BioIter(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(AlphaPL)) THEN
        allocate ( AlphaPL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(AlphaPS)) THEN
        allocate ( AlphaPS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(AlphaZL)) THEN
        allocate ( AlphaZL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(AlphaZP)) THEN
        allocate ( AlphaZP(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(AlphaZS)) THEN
        allocate ( AlphaZS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF
#if defined NEMURO_CHL && ! defined NEMURO_CHL_STATICRATIO
      IF (.not.allocated(AttChl)) THEN
        allocate ( AttChl(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(Chl2NS_max)) THEN
        allocate ( Chl2NS_max(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(Chl2NL_max)) THEN
        allocate ( Chl2NL_max(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF
# if defined NEMURO_CHL_CHL2NMIN
      IF (.not.allocated(Chl2NS_min)) THEN
        allocate ( Chl2NS_min(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF
      IF (.not.allocated(Chl2NL_min)) THEN
        allocate ( Chl2NL_min(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF
# endif
# if defined NEMURO_CHL_GEIDER_ACCLIM || defined NEMURO_CHL_NUDGECHL2N
      IF (.not.allocated(chltacclimS)) THEN
        allocate ( chltacclimS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(chltacclimL)) THEN
        allocate ( chltacclimL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

# endif
#else
      IF (.not.allocated(AttPL)) THEN
        allocate ( AttPL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(AttPS)) THEN
        allocate ( AttPS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

#endif
      IF (.not.allocated(AttSW)) THEN
        allocate ( AttSW(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF
#if ! defined NEMURO_CHL_GEIDER && ! defined NEMURO_CHL_NUDGECHL2N
      IF (.not.allocated(BetaPL)) THEN
        allocate ( BetaPL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(BetaPS)) THEN
        allocate ( BetaPS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

#endif
      IF (.not.allocated(BetaZS)) THEN
        allocate ( BetaZS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(BetaZL)) THEN
        allocate ( BetaZL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(BetaZP)) THEN
        allocate ( BetaZP(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(GammaL)) THEN
        allocate ( GammaL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(GammaS)) THEN
        allocate ( GammaS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(GRmaxLpl)) THEN
        allocate ( GRmaxLpl(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(GRmaxLps)) THEN
        allocate ( GRmaxLps(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(GRmaxLzs)) THEN
        allocate ( GRmaxLzs(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(GRmaxPpl)) THEN
        allocate ( GRmaxPpl(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(GRmaxPzl)) THEN
        allocate ( GRmaxPzl(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(GRmaxPzs)) THEN
        allocate ( GRmaxPzs(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(GRmaxSps)) THEN
        allocate ( GRmaxSps(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

#if defined NEMUCSC
      IF (.not.allocated(GRmaxSpl)) THEN
        allocate ( GRmaxSpl(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

#endif
      IF (.not.allocated(KD2N)) THEN
        allocate ( KD2N(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KGppL)) THEN
        allocate ( KGppL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KGppS)) THEN
        allocate ( KGppS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KGraL)) THEN
        allocate ( KGraL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KGraP)) THEN
        allocate ( KGraP(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KGraS)) THEN
        allocate ( KGraS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KMorPL)) THEN
        allocate ( KMorPL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KMorPS)) THEN
        allocate ( KMorPS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KMorZL)) THEN
        allocate ( KMorZL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KMorZP)) THEN
        allocate ( KMorZP(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KMorZS)) THEN
        allocate ( KMorZS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KNH4L)) THEN
        allocate ( KNH4L(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KNH4S)) THEN
        allocate ( KNH4S(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KNit)) THEN
        allocate ( KNit(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KNO3L)) THEN
        allocate ( KNO3L(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KNO3S)) THEN
        allocate ( KNO3S(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KO2S)) THEN
        allocate ( KO2S(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KP2D)) THEN
        allocate ( KP2D(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KP2N)) THEN
        allocate ( KP2N(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KPL2ZL)) THEN
        allocate ( KPL2ZL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KPS2ZL)) THEN
        allocate ( KPS2ZL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KPS2ZS)) THEN
        allocate ( KPS2ZS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

#if defined NEMUCSC
      IF (.not.allocated(KPL2ZS)) THEN
        allocate ( KPL2ZS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

#endif
      IF (.not.allocated(KPL2ZP)) THEN
        allocate ( KPL2ZP(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KResPL)) THEN
        allocate ( KResPL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KResPS)) THEN
        allocate ( KResPS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KSiL)) THEN
        allocate ( KSiL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KZL2ZP)) THEN
        allocate ( KZL2ZP(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KZS2ZL)) THEN
        allocate ( KZS2ZL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(KZS2ZP)) THEN
        allocate ( KZS2ZP(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(LamL)) THEN
        allocate ( LamL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(LamP)) THEN
        allocate ( LamP(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(LamS)) THEN
        allocate ( LamS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(MorPL0)) THEN
        allocate ( MorPL0(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(MorPS0)) THEN
        allocate ( MorPS0(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(MorZL0)) THEN
        allocate ( MorZL0(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(MorZP0)) THEN
        allocate ( MorZP0(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(MorZS0)) THEN
        allocate ( MorZS0(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(Nit0)) THEN
        allocate ( Nit0(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(PARfrac)) THEN
        allocate ( PARfrac(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

#ifdef TANGENT
      IF (.not.allocated(tl_PARfrac)) THEN
        allocate ( tl_PARfrac(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

#endif
#ifdef ADJOINT
      IF (.not.allocated(ad_PARfrac)) THEN
        allocate ( ad_PARfrac(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

#endif
      IF (.not.allocated(PusaiL)) THEN
        allocate ( PusaiL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(PusaiPL)) THEN
        allocate ( PusaiPL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(PusaiS)) THEN
        allocate ( PusaiS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(PusaiZS)) THEN
        allocate ( PusaiZS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(PL2ZLstar)) THEN
        allocate ( PL2ZLstar(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(PL2ZPstar)) THEN
        allocate ( PL2ZPstar(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(PS2ZLstar)) THEN
        allocate ( PS2ZLstar(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(PS2ZSstar)) THEN
        allocate ( PS2ZSstar(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

#if defined NEMUCSC
      IF (.not.allocated(PL2ZSstar)) THEN
        allocate ( PL2ZSstar(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

#endif
      IF (.not.allocated(ResPL0)) THEN
        allocate ( ResPL0(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(ResPS0)) THEN
        allocate ( ResPS0(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(RSiN)) THEN
        allocate ( RSiN(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(setVOpal)) THEN
        allocate ( setVOpal(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

#ifdef TANGENT
      IF (.not.allocated(tl_setVOpal)) THEN
        allocate ( tl_setVOpal(Ngrids) )
        tl_setVOpal=0.0_r8
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

#endif
#ifdef ADJOINT
      IF (.not.allocated(ad_setVOpal)) THEN
        allocate ( ad_setVOpal(Ngrids) )
        ad_setVOpal=0.0_r8
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

#endif
      IF (.not.allocated(setVPON)) THEN
        allocate ( setVPON(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

#ifdef TANGENT
      IF (.not.allocated(tl_setVPON)) THEN
        allocate ( tl_setVPON(Ngrids) )
        tl_setVPON=0.0_r8
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF
#endif
#ifdef ADJOINT
      IF (.not.allocated(ad_setVPON)) THEN
        allocate ( ad_setVPON(Ngrids) )
        ad_setVPON=0.0_r8
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF
#endif

#if defined N15
# ifdef SINK_RATIO
      IF (.not.allocated(setVPONratio)) THEN
        allocate ( setVPONratio(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF
# else
      IF (.not.allocated(setVPON14)) THEN
        allocate ( setVPON14(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(setVPON15)) THEN
        allocate ( setVPON15(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF
# endif
#endif
      IF (.not.allocated(VD2N0)) THEN
        allocate ( VD2N0(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(VmaxL)) THEN
        allocate ( VmaxL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(VmaxS)) THEN
        allocate ( VmaxS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(VO2S0)) THEN
        allocate ( VO2S0(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(VP2D0)) THEN
        allocate ( VP2D0(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(VP2N0)) THEN
        allocate ( VP2N0(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(ZL2ZPstar)) THEN
        allocate ( ZL2ZPstar(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(ZS2ZLstar)) THEN
        allocate ( ZS2ZLstar(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(ZS2ZPstar)) THEN
        allocate ( ZS2ZPstar(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

#if defined NEMURO_CHL && defined NEMURO_CHL_STATICRATIO
      IF (.not.allocated(Chl2NS)) THEN
        allocate ( Chl2NS(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(Chl2NL)) THEN
        allocate ( Chl2NL(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

#endif
#ifdef NEM_IRON_LIMIT
      IF (.not.allocated(T_Fe)) THEN
        allocate ( T_Fe(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(A_Fe)) THEN
        allocate ( A_Fe(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(B_Fe)) THEN
        allocate ( B_Fe(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(SK_FeC)) THEN
        allocate ( SK_FeC(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(LK_FeC)) THEN
        allocate ( LK_FeC(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(FeRR)) THEN
        allocate ( FeRR(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

# ifdef NEM_IRON_RELAX
      IF (.not.allocated(FeHmin)) THEN
        allocate ( FeHmin(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(FeMax)) THEN
        allocate ( FeMax(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(FeNudgTime)) THEN
        allocate ( FeNudgTime(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

# endif
#endif
#ifdef CARB
      IF (.not.allocated(RedCN)) THEN
        allocate ( RedCN(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(pCO2air)) THEN
        allocate ( pCO2air(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

# if defined NEMURO_CO2_TREND
      IF (.not.allocated(pCO2trend)) THEN
        allocate ( pCO2trend(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

# endif
#endif
#ifdef NEM_SPONGE
      IF (.not.allocated(nemSpongeN)) THEN
        allocate ( nemSpongeN(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(nemSpongeF)) THEN
        allocate ( nemSpongeF(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF
#endif

#if defined N15
      IF (.not.allocated(eps_GppNO3)) THEN
        allocate ( eps_GppNO3(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF


      IF (.not.allocated(eps_GppNH4)) THEN
        allocate ( eps_GppNH4(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(eps_exc)) THEN
        allocate ( eps_exc(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

# if defined DENIT
      IF (.not.allocated(eps_denit)) THEN
        allocate ( eps_denit(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF
# endif

      IF (.not.allocated(eps_nitrif)) THEN
        allocate ( eps_nitrif(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(eps_remin)) THEN
        allocate ( eps_remin(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF
      
      IF (.not.allocated(eps_decomp)) THEN
        allocate ( eps_decomp(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

      IF (.not.allocated(eps_reminDON)) THEN
        allocate ( eps_reminDON(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF
#endif
!
!  New variables
!
      IF (.not.allocated(new_dtdays)) THEN
        allocate ( new_dtdays(Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF
      IF (.not.allocated(new_Wbio)) THEN
        allocate ( new_Wbio(Nsink,Ngrids) )
        Dmem(1)=Dmem(1)+REAL(Ngrids,r8)
      END IF

!
!  Allocate biological tracer vector.
!
      IF (.not.allocated(idbio)) THEN
        allocate ( idbio(NBT) )
        Dmem(1)=Dmem(1)+REAL(NBT,r8)
      END IF
!
!-----------------------------------------------------------------------
!  Initialize tracer identification indices.
!-----------------------------------------------------------------------
!
      ic=NAT+NPT+NCS+NNS
      DO i=1,NBT
        idbio(i)=ic+i
      END DO
      iSphy=ic+1
      iLphy=ic+2
      iSzoo=ic+3
      iLzoo=ic+4
      iPzoo=ic+5
      iNO3_=ic+6
      iNH4_=ic+7
      iPON_=ic+8
      iDON_=ic+9
      iSiOH=ic+10
      iopal=ic+11
#if defined N15
      iSphy15=ic+12
      iLphy15=ic+13
      iSzoo15=ic+14
      iLzoo15=ic+15
      iPzoo15=ic+16
      iNO315_=ic+17
      iNH415_=ic+18
      iPON15_=ic+19
      iDON15_=ic+20
      iSphy14=ic+21
      iLphy14=ic+22
      iSzoo14=ic+23
      iLzoo14=ic+24
      iPzoo14=ic+25
      iNO314_=ic+26
      iNH414_=ic+27
      iPON14_=ic+28
      iDON14_=ic+29
      iPONratio=ic+30
#endif
#if defined CARB || \
    defined OXY || \
    defined NEMURO_CHL || \
    defined NEM_IRON_LIMIT
      ic_offset=12
#endif
#if defined N15
      ic_offset=31
#endif
#if defined NEMURO_CHL
      iChlo=ic+ic_offset
      ic_offset=ic_offset+1
#endif
#ifdef OXY
      iOxyg=ic+ic_offset
      ic_offset=ic_offset+1
#endif
#ifdef NEM_IRON_LIMIT
      iFeSp=ic+ic_offset
      iFeLp=ic+ic_offset+1
      iFeD_=ic+ic_offset+2
      ic_offset=ic_offset+3
#endif
#ifdef CARB
      iTIC_=ic+ic_offset
      iTAlk=ic+ic_offset+1
      iCalC=ic+ic_offset+2
      ic_offset=ic_offset+3
#endif
#ifdef ISO
      iDI13C=ic+ic_offset
      iDI14C=ic+ic_offset+1
      ic_offset=ic_offset+2
#endif
#ifdef ISO_13C
      iDI13C=ic+ic_offset
      ic_offset=ic_offset+1
#endif
#ifdef DOR
      iDOR_=ic+ic_offset
      ic_offset=ic_offset+1
#endif
#ifdef OAE
      iOAE_=ic+ic_offset
      ic_offset=ic_offset+1
#endif
#if defined NEMURO_CHL_GEIDER || defined NEMURO_CHL_NUDGECHL2N
      ! let helper variables have last index
      iChlS=ic+ic_offset
      iChlL=ic+ic_offset+1
      ic_offset=ic_offset+2
#endif
!
!  Initialize sinking indices
!
      idsink(1)=iPON_                 ! particulate organic nitrogen
      idsink(2)=iopal                 ! particulate organic silica
#if defined N15
# if defined SINK_RATIO
      idsink(3)=iPONratio             ! 15PON/14PON
#  if defined CARB & ! defined KO_CARB_SINK
      idsink(4)=iCalC                 ! carbon detritus
#  endif
# else
      idsink(3)=iPON15_               ! particulate organic 15 nitrogen
      idsink(4)=iPON14_               ! particulate organic 14 nitrogen
#  if defined CARB & ! defined KO_CARB_SINK
      idsink(5)=iCalC                 ! carbon detritus
#  endif
# endif
#else
# if defined CARB & ! defined KO_CARB_SINK 
      idsink(3)=iCalC                 ! carbon detritus
# endif
#endif
!
      RETURN
      END SUBROUTINE initialize_biology

#  if defined CARB
#   include <nemuro_mod_pco2water.h>
#  endif

      END MODULE mod_biology
