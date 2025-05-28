#include "cppdefs.h"
      MODULE mod_nemuro_sms
#if defined NEMURO_RESTRUCT     
      implicit none

      CONTAINS
!
!=======================================================================
!
!
      SUBROUTINE light_attenuation(tile, ng, j, IminS, ImaxS,           &
     &                             LBi, LBj,                            &
# if ! defined ASSUMED_SHAPE
     &                             UBi, UBj, UBk,                       &
# endif
# if defined NEMURO_CHL_GEIDER || defined NEMURO_CHL_NUDGECHL2N 
     &                             LightChl,                            &
# endif
     &                             LightS, LightL, PARsur, z_w, Bio     &
     &                             )
!
      USE mod_param
      USE mod_biology

!
!  Imported variable declarations.
!
      integer, intent(in) :: tile, ng, j, IminS, ImaxS
      integer, intent(in) :: LBi, LBj
# ifdef ASSUMED_SHAPE
      real(r8), intent(in) :: z_w(LBi:,LBj:,0:)
# else
      integer, intent(in) :: UBi, UBj, UBk
      real(r8), intent(in) :: z_w(LBi:UBi,LBj:UBj,0:UBk)
# endif
# if defined NEMURO_CHL_GEIDER || defined NEMURO_CHL_NUDGECHL2N 
      real(r8),intent(out),dimension(IminS:ImaxS,N(ng)) :: LightChl
# endif
      real(r8),intent(out),dimension(IminS:ImaxS,N(ng)) :: LightS,LightL
      real(r8),intent(in),dimension(IminS:ImaxS) :: PARsur
      real(r8),intent(in),dimension(IminS:ImaxS,N(ng),NT(ng)) :: Bio
!
!  Local variable declarations
!
      real(r8) :: cff1, cff2
#if defined NEMUCSC || defined NEMURO_CHL_GEIDER || defined NEMURO_CHL_NUDGECHL2N
      real(r8) :: Att, Irr, kappa
#else
      real(r8) :: AttL, AttS, IrrL, IrrS, kappaL, kappaS
#endif
      real(r8) :: dz

      integer :: i, k 
! instead of #include "set_bounds.h"
      integer :: Istr, Iend
      Istr   =BOUNDS(ng) % Istr   (tile)
      Iend   =BOUNDS(ng) % Iend   (tile)
!
!  Compute light attenuation as function of depth.
!
# if defined LIGHT_CFF
          cff1=1.0/0.5_r8
          cff2=1.0/1.0_r8
# else /* LIGHT_CFF */
          cff1=1.0/VmaxS(ng)
          cff2=1.0/VmaxL(ng)
# endif /* LIGHT_CFF */
          DO i=Istr,Iend
#if defined NEMUCSC || defined NEMURO_CHL_GEIDER || defined NEMURO_CHL_NUDGECHL2N
            Att=PARsur(i)
#else
            AttS=PARsur(i)
            AttL=PARsur(i)
#endif
            IF (PARsur(i).gt.0.0_r8) THEN              ! day time
              DO k=N(ng),1,-1
!
!  Attenuate the light to the center of the grid cell using the
!  Platt et al. (1980) photoinhibition formulation. Here, AttSW is
!  the light attenuation due to seawater and AttPS and AttPL is the
!  attenuation due to Small and Large Phytoplankton (self-shading
!  coefficient).
!
                dz=0.5_r8*(z_w(i,j,k)-z_w(i,j,k-1))
#if defined NEMURO_CHL_GEIDER || defined NEMURO_CHL_NUDGECHL2N
                kappa=AttSW(ng)+AttChl(ng)*                             &
     &            (Bio(i,k,iChlS)+Bio(i,k,iChlL))
                Irr=EXP(-kappa*dz)
                Att=Att*Irr
                LightChl(i,k)=Att
                LightS(i,k)=1.0_r8-EXP(-alphaPS(ng)*Att*cff1)
                LightL(i,k)=1.0_r8-EXP(-alphaPL(ng)*Att*cff2)
!
!  Attenuate the light to the bottom of the grid cell.
!
                Att=Att*Irr
#elif defined NEMUCSC
                kappa=AttSW(ng)+AttPS(ng)*Bio(i,k,iSphy)+               &
     &                          AttPL(ng)*Bio(i,k,iLphy)
                Irr=EXP(-kappa*dz)
                Att=Att*Irr
                LightS(i,k)=(1.0_r8-EXP(-alphaPS(ng)*Att*cff1))*        &
     &                      EXP(-betaPS(ng)*Att*cff1)
                LightL(i,k)=(1.0_r8-EXP(-alphaPL(ng)*Att*cff2))*        &
     &                      EXP(-betaPL(ng)*Att*cff2)
!
!  Attenuate the light to the bottom of the grid cell.
!
                Att=Att*Irr
#else
                kappaS=AttSW(ng)+                                       &
     &                 AttPS(ng)*(Bio(i,k,iSphy)+Bio(i,k,iLphy))
                kappaL=AttSW(ng)+                                       &
     &                 AttPL(ng)*(Bio(i,k,iSphy)+Bio(i,k,iLphy))
                IrrS=EXP(-kappaS*dz)
                IrrL=EXP(-kappaL*dz)
                AttS=AttS*IrrS
                AttL=AttL*IrrL
                LightS(i,k)=(1.0_r8-EXP(-alphaPS(ng)*AttS*cff1))*       &
     &                      EXP(-betaPS(ng)*AttS*cff1)
                LightL(i,k)=(1.0_r8-EXP(-alphaPL(ng)*AttL*cff2))*       &
     &                      EXP(-betaPL(ng)*AttL*cff2)
!
!  Attenuate the light to the bottom of the grid cell.
!
                AttS=AttS*IrrS
                AttL=AttL*IrrL
#endif
              END DO
            ELSE                                       ! night time
              DO k=1,N(ng)
#if defined NEMURO_CHL_GEIDER || defined NEMURO_CHL_NUDGECHL2N
                LightChl(i,k)=0.0_r8
#endif
                LightS(i,k)=0.0_r8
                LightL(i,k)=0.0_r8
              END DO
            END IF
          END DO
      RETURN
      END SUBROUTINE light_attenuation
!
!
!
      SUBROUTINE phytoplankton_pps(tile, ng, IminS, ImaxS, LightS, Bio  &
# if defined NEMURO_CHL_GEIDER 
     &                               ,Chl2NS, LightChl, BSS             &
# endif
#if defined NEM_IRON_LIMIT
     &                               , J                                &
# endif
# if defined TANGENT || defined ADJOINT
     &                               , BS                               &
# endif
#if defined DIAGNOSTICS_BIO
     &                               , DiaBio3dJ                        &
#endif
# if defined LOGDIAGNOSTICS_NEM_CHL || defined NEMURO_CHL_EXITONNEGATIVE
     &                               , j                                &
# endif
# if defined ISO || defined ISO_13C
     &                               , CO2star                          &
# endif
     &                               )
!
      USE mod_param
      USE mod_biology

!
!  Imported variable declarations.
!
      integer, intent(in) :: tile, ng, IminS, ImaxS
      real(r8),intent(inout),dimension(IminS:ImaxS,N(ng),NT(ng)) :: Bio
      real(r8),intent(in),dimension(IminS:ImaxS,N(ng)) :: LightS

# if defined NEMURO_CHL_GEIDER 
      real(r8),intent(in),dimension(IminS:ImaxS,N(ng)) :: LightChl
      real(r8),intent(out),dimension(IminS:ImaxS,N(ng)) :: Chl2NS
      real(r8),intent(out),dimension(IminS:ImaxS,N(ng)) :: BSS
# endif
# if defined TANGENT || defined ADJOINT
      real(r8),intent(inout),optional,                                  &
     &  dimension(IminS:ImaxS,N(ng),3:NT(ng),1:6) :: BS
# endif
#if defined NEM_IRON_LIMIT
      integer, intent(in) :: J
# endif
# ifdef DIAGNOSTICS_BIO
      real(r8), intent(inout) :: DiaBio3dJ(IminS:ImaxS,N(ng),NDbio3d)
# endif
# if defined ISO || defined ISO_13C
      real(r8), intent(in), dimension(IminS:ImaxS,N(ng)) :: CO2star
# endif 
# if defined LOGDIAGNOSTICS_NEM_CHL || defined NEMURO_CHL_EXITONNEGATIVE
      integer, intent(in) :: j
# endif

!
!  Local variable declarations
!
      real(r8) :: cff, cff1, cff2, cff3, cff4, cff5
      real(r8) :: GppNPS, GppAPS, GppPS
      real(r8) :: RnewS, ResPS, ExcPS
#ifdef N15
      real(r8) :: GppAPS15, GppNPS15, GppPS15
      real(r8) :: cff_iso1,cff_iso2,cff_iso3
      real(r8) :: epsilon_NH4,epsilon_NO3
      real(r8) :: gamma_NH4,gamma_NO3
      real(r8) :: NO3_old,NH4_old
      real(r8) :: ResPS15, ExcPS15
#endif
# if defined ISO && ! defined ISO_13C
      real(r8) :: &
        ticik,         &   ! TIC at current timestep
        di12c,         &   ! 12C in DIC
        di13c,         &   ! 13C in DIC
        di14c,         &   ! 14C in DIC
        R13C_DICik,    &   ! 13C/12C ratio at current timestep
        R14C_DICik,    &   ! 14C/12C ratio at current timestep
        alpha_cc = 0.998_r8, & ! equivlent to -2 per mil offset
        alpha_org = 0.978_r8,  & ! equivlent to -22 per mil offset
        alpha_aq_g, & ! equilibrium fractionation (CO2_gaseous <-> CO2_aq)
        alpha_dic_g,& ! equilibrium fractionation between total DIC and gaseous CO2
        alpha_aq_g_14c, & ! for 14C, with fractionation being twice as large for 14C than for 13C
        alpha_dic_g_14c,& ! for 14C, with fractionation being twice as large for 14C than for 13C
        alpha_poc_aq,  & ! equilibrium fractionation factor from aqueous CO2 to particulate organic carbon (POC)
        R13C_org,      &   ! ratio of 13C/12C in organic matter 
        R14C_org,      &      ! ratio of 14C/12C in organic matter
        R13C_cc,       &            ! ratio of 13C/12C in calcium carbonate     
        R14C_cc            ! ratio of 14C/12C in calcium carbonate  
# endif
# if defined ISO_13C
      real(r8) :: &
        ticik,         &   ! TIC at current timestep
        di12c,         &   ! 12C in DIC
        di13c,         &   ! 13C in DIC
        R13C_DICik,    &   ! 13C/12C ratio at current timestep
        alpha_cc = 0.998_r8, & ! equivlent to -2 per mil offset
        alpha_org = 0.978_r8,  & ! equivlent to -22 per mil offset
        alpha_aq_g, & ! equilibrium fractionation (CO2_gaseous <-> CO2_aq)
        alpha_dic_g,& ! equilibrium fractionation between total DIC and gaseous CO2
        alpha_poc_aq,  & ! equilibrium fractionation factor from aqueous CO2 to particulate organic carbon (POC)
        R13C_org,      &   ! ratio of 13C/12C in organic matter 
        R13C_cc                   ! ratio of 13C/12C in calcium carbonate     
# endif
# if defined NEMURO_CHL_GEIDER
      real(r8) :: rhoChl
#  if defined NEMURO_CHL_GEIDER_ACCLIM
      real(r8) :: acclim
#  endif
# endif
# if defined CARB 
      real(r8) :: cffC
      real(r8) :: NtoAlk = 1.0_r8 ! conversion N units to Alk units
      real(r8) :: CaCO3_frac = 0.07_r8 ! CaCO3 fraction of NPP
# endif
#ifdef NEM_IRON_LIMIT
      real(r8) :: FNratio, FCratio, FCratioE, cffFe, Flimit
      real(r8) :: cff6
      real(r8), parameter :: MinVal = 1.0e-6_r8
      logical :: debugging
      integer idebug,jdebug,kdebug
#endif
      integer :: i, k 
      integer, parameter :: itemp = 1 
! instead of #include "set_bounds.h"
      integer :: Istr, Iend
      Istr   =BOUNDS(ng) % Istr   (tile)
      Iend   =BOUNDS(ng) % Iend   (tile)

!-----------------------------------------------------------------------
!  Phytoplankton primary productivity.
!-----------------------------------------------------------------------
!
!  Gross primary production of Small Phytoplankton consisting of
!  nutrient uptake (NO3 and NH4) terms, temperature-dependend term,
!  and light limitation term. The Michaelis-Menten curve is used to
!  describe the change in uptake rate as a function of nutrient
!  concentration.
!
          cff=new_dtdays(ng)*VmaxS(ng)
          DO k=1,N(ng)
            DO i=Istr,Iend
#if defined TANGENT || defined ADJOINT
!
!  First save the initial Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iNO3_,1)=Bio(i,k,iNO3_)
                BS(i,k,iNH4_,1)=Bio(i,k,iNH4_)
                BS(i,k,iSphy,1)=Bio(i,k,iSphy)
# if defined NEMURO_CHL_GEIDER || defined NEMURO_CHL_NUDGECHL2N
                BS(i,k,iChlL,1)=Bio(i,k,iChlL)
                BS(i,k,iChlS,1)=Bio(i,k,iChlS)
# endif
              END IF
#endif
#ifdef NEM_IRON_LIMIT
!
!  Growth reduction factors due to iron limitation:
!
!    FNratio     current Fe:N ratio [umol-Fe/mmol-N]
!    FCratio     current Fe:C ratio [umol-Fe/mol-C]
!                  (umol-Fe/mmol-N)*(16 M-N/106 M-C)*(1E3 mmol-C/mol-C)
!    FCratioE    empirical  Fe:C ratio
!    Flimit      Phytoplankton growth reduction factor due to Fe
!                  limitation based on Fe:C ratio
!
! Small phytoplankton growth reduction factor due to iron limitation
!
              debugging=(1.eq.0)
              if (debugging) then
                idebug=160
                jdebug=760
                kdebug=40
                if ((i.eq.idebug) .and. (j.eq.jdebug) .and. (k.eq.kdebug)) then
                  write(6,*) '0) Bio(iFeD_,iFeSp)=',Bio(i,k,iFeD_),Bio(i,k,iFeSp)
                end if
              end if
              FNratio=Bio(i,k,iFeSp)/MAX(MinVal,Bio(i,k,iSphy))
              FCratio=FNratio*FeN2FeC
              FCratioE= B_Fe(ng)*Bio(i,k,iFeD_)**A_Fe(ng)
              Flimit = FCratio**2.0_r8/                                 &
     &                 (FCratio**2.0_r8+SK_FeC(ng)**2.0_r8)
!
!  Small Phytoplankton gross primary productivity, GppPS.
!
              cff1=cff*EXP(KGppS(ng)*Bio(i,k,itemp))*LightS(i,k)*       &
     &             Bio(i,k,iSphy)
              cff2=EXP(-PusaIS(ng)*Bio(i,k,iNH4_))/                     &
     &                   (KNO3S(ng)+Bio(i,k,iNO3_))
              cff3=1.0_r8/(KNH4S(ng)+Bio(i,k,iNH4_))
              cff4=cff2*Bio(i,k,iNO3_)
              cff5=cff3*Bio(i,k,iNH4_)
#  ifdef DIAGNOSTICS_NEM_LIM
              DiaBio3dJ(i,k,iNO3limSp)=DiaBio3dJ(i,k,iNO3limSp)+cff4
              DiaBio3dJ(i,k,iNH4limSp)=DiaBio3dJ(i,k,iNH4limSp)+cff5
              DiaBio3dJ(i,k,iFelimSp)=DiaBio3dJ(i,k,iFelimSp)+Flimit
#  endif
              cff6=Flimit/MAX(MinVal,cff4+cff5)
              cff4=cff1*cff2*MIN(1.0_r8,cff6)        ! Fe lim on N03
              cff5=cff1*cff3*MIN(1.0_r8,cff6)        ! Fe lim on NH4
#  if defined N15
              NO3_old=Bio(i,k,iNO3_)
              NH4_old=Bio(i,k,iNH4_)
#  endif
# if defined LOWER_LIM
              IF (Bio(i,k,iNO3_).LE.1.0e-3_r8) THEN
                cff4=0.0_r8
              ENDIF
              IF (Bio(i,k,iNH4_).LE.1.0e-3_r8) THEN
                cff5=0.0_r8
              ENDIF
# endif
              Bio(i,k,iNO3_)=Bio(i,k,iNO3_)/(1.0_r8+cff4)
              Bio(i,k,iNH4_)=Bio(i,k,iNH4_)/(1.0_r8+cff5)
              GppNPS=Bio(i,k,iNO3_)*cff4
              GppAPS=Bio(i,k,iNH4_)*cff5
              GppPS=GppNPS+GppAPS
              if (debugging) then
                if ((i.eq.idebug) .and. (j.eq.jdebug) .and. (k.eq.kdebug)) then
                  write(6,*) '1) Bio(iFeD_,iFeSp)=',Bio(i,k,iFeD_),Bio(i,k,iFeSp)
                  write(6,*) 'FNratio=',FNratio
                  write(6,*) 'FCratio,FCratioE=',FCratio, FCratioE
                  write(6,*) 'Flimit,GppPS=',Flimit,GppPS
                end if
              end if
#else
              cff1=cff*EXP(KGppS(ng)*Bio(i,k,itemp))*LightS(i,k)*       &
     &             Bio(i,k,iSphy)

              cff2=cff1*EXP(-PusaIS(ng)*Bio(i,k,iNH4_))/                &
     &             (KNO3S(ng)+Bio(i,k,iNO3_))
              cff3=cff1/(KNH4S(ng)+Bio(i,k,iNH4_))
#  if defined N15
              NO3_old=Bio(i,k,iNO3_)
              NH4_old=Bio(i,k,iNH4_)
#  endif
# if defined LOWER_LIM
              IF (Bio(i,k,iNO3_).LE.1.0e-3_r8) THEN
                cff2=0.0_r8
              ENDIF
              IF (Bio(i,k,iNH4_).LE.1.0e-3_r8) THEN
                cff3=0.0_r8
              ENDIF
# endif
              Bio(i,k,iNO3_)=Bio(i,k,iNO3_)/(1.0_r8+cff2)
              Bio(i,k,iNH4_)=Bio(i,k,iNH4_)/(1.0_r8+cff3)
              GppNPS=Bio(i,k,iNO3_)*cff2
              GppAPS=Bio(i,k,iNH4_)*cff3
              GppPS=GppNPS+GppAPS
#endif /* NEM_IRON_LIMIT */
#if defined NEMURO_CHL_GEIDER
!
!  Save small phytoplankton (post-growth).
!
              BSS(i,k)=Bio(i,k,iSphy)+GppPS
              
# if defined NEMURO_CHL_GEIDER_OLD
              Chl2NS(i,k)=Bio(i,k,iChlS)/MAX(BIOmin,Bio(i,k,iSphy))
# elif defined NEMURO_CHL_GEIDER_MINMAX
              Chl2NS(i,k)=MAX(Chl2NS_min,MIN(Chl2NS_max(ng),            &
     &          Bio(i,k,iChlS)/MAX(BIOmin,Bio(i,k,iSphy))))
# else
              Chl2NS(i,k)=MIN(Chl2NS_max(ng),                           &
     &          Bio(i,k,iChlS)/MAX(BIOmin,Bio(i,k,iSphy)))
# endif
# if defined NEMURO_CHL_GEIDER_ACCLIM
! the units here do not make sense (units of
! LightChl(i,k)*alphaPS(ng)/VmaxS(ng) cancel out)
!              acclim=MIN(Chl2NS_max(ng),Chl2NS_max(ng)/(                &
!     &          1.0_r8+(Chl2NS_max(ng)*LightChl(i,k)*alphaPS(ng)/       &
!     &          (2.0_r8*VmaxS(ng)))))
              acclim=MIN(Chl2NS_max(ng),Chl2NS_max(ng)/(                &
     &          1.0_r8+(LightChl(i,k)*alphaPS(ng)/(2.0_r8*VmaxS(ng)))))
              rhoChl=Chl2NS_max(ng)*GppPS/                              &
     &          MAX(BIOmin,new_dtdays(ng)*LightChl(i,k)*                &
     &          alphaPS(ng)*acclim)
              Bio(i,k,iChlS)=Bio(i,k,iChlS)+rhoChl*GppPS+               &
     &          new_dtdays(ng)*chltacclimS(ng)*                         &
     &          (acclim-Chl2NS(i,k))*Bio(i,k,iSphy)
# else
              ! based on (4) in Geider1997
              rhoChl=Chl2NS_max(ng)*GppPS/                              &
     &          MAX(BIOmin,Chl2NS(i,k)*new_dtdays(ng)*LightChl(i,k)*    &
     &          alphaPS(ng))
              Bio(i,k,iChlS)=Bio(i,k,iChlS)+rhoChl*GppPS
# endif
# if defined LOGDIAGNOSTICS_NEM_CHL
              if (k==LOGDIAGNOSTICS_NEM_CHL_K.and.i==LOGDIAGNOSTICS_NEM_CHL_I.and.j==LOGDIAGNOSTICS_NEM_CHL_J) then
                write(*,'(a30,f19.12)') 'ChlS = ',Bio(i,k,iChlS)
                write(*,'(a30,f19.12)') 'Sphy = ',Bio(i,k,iSphy)
                write(*,'(a30,f19.12)') 'Chl2NS = ',Chl2NS(i,k)
                write(*,'(a30,f19.12)') 'LightChl = ',LightChl(i,k)
                write(*,'(a30,f19.12)') 'alphaPS*LightChl/Sphy = ',     &
     &            alphaPS(ng)*LightChl(i,k)/Bio(i,k,iSphy)
                write(*,'(a30,f19.12)') 'alphaPS*LightChl*Chl2NS = ',   &
     &            alphaPS(ng)*LightChl(i,k)*Chl2NS(i,k)
                write(*,'(a30,f19.12,a,f19.12,a,f19.12)')               &
     &            'ChlS growth: ',rhoChl,'*',GppPS,'=',                 &
     &            rhoChl*GppPS
              end if
# endif
# ifdef DIAGNOSTICS_BIO
#  ifdef DIAGNOSTICS_NEM_CHL
              DiaBio3dJ(i,k,irhoChlS)=DiaBio3dJ(i,k,irhoChlS)+          &
     &          rhoChl*new_dtdays(ng)/Chl2NS(i,k)
#  endif
# endif
#endif
              Bio(i,k,iSphy)=Bio(i,k,iSphy)+GppPS
#if defined DIAGNOSTICS_BIO
# if defined DIAGNOSTICS_NEM_PHY || defined DIAGNOSTICS_NEM_NIT
              DiaBio3dJ(i,k,iGppNPS)=DiaBio3dJ(i,k,iGppNPS) + GppNPS
              DiaBio3dJ(i,k,iGppAPS)=DiaBio3dJ(i,k,iGppAPS) + GppAPS
# endif
#endif
#if defined N15
              IF (NO3_old.GT.0.0_r8) THEN
                epsilon_NO3=eps_GppNO3(ng)*                           &
     &                      (1.0_r8-(GppNPS/NO3_old))
              ELSE
                epsilon_NO3=0.0_r8
              ENDIF
              IF (NH4_old.GT.0.0_r8) THEN
                epsilon_NH4=eps_GppNH4(ng)*                           &
     &                        (1.0_r8-(GppAPS/NH4_old))
              ELSE
                epsilon_NH4=0.0_r8
              ENDIF
              gamma_NO3=1.0_r8-(epsilon_NO3/1000.0_r8)
              gamma_NH4=1.0_r8-(epsilon_NH4/1000.0_r8)
              IF ((Bio(i,k,iNO3_).GT.0.0_r8) .AND.                    &
     &            (Bio(i,k,iNO315_).GT.0.0_r8) .AND.                  &
     &            (Bio(i,k,iNO314_).GT.0.0_r8)) THEN
                GppNPS15=GppNPS*(gamma_NO3*(Bio(i,k,iNO315_)          &
     &                   /Bio(i,k,iNO314_)))/(1.0_r8+(gamma_NO3*      &
     &                   (Bio(i,k,iNO315_)/Bio(i,k,iNO314_))))
              ELSE
                GppNPS15=0.0_r8
              ENDIF
              IF ((Bio(i,k,iNH4_).GT.0.0_r8) .AND.                    &
     &            (Bio(i,k,iNH415_).GT.0.0_r8) .AND.                  &
     &            (Bio(i,k,iNH414_).GT.0.0_r8)) THEN
                GppAPS15=GppAPS*(gamma_NH4*(Bio(i,k,iNH415_)          &
     &                   /Bio(i,k,iNH414_)))/(1.0_r8+(gamma_NH4*      &
     &                   (Bio(i,k,iNH415_)/Bio(i,k,iNH414_))))
              ELSE
                GppAPS15=0.0_r8
              ENDIF
              GppPS15=GppNPS15+GppAPS15
              Bio(i,k,iNO315_)=Bio(i,k,iNO315_)-GppNPS15
              Bio(i,k,iNH415_)=Bio(i,k,iNH415_)-GppAPS15
              Bio(i,k,iSphy15)=Bio(i,k,iSphy15)+GppPS15
              Bio(i,k,iNO314_)=Bio(i,k,iNO3_)-Bio(i,k,iNO315_)
              Bio(i,k,iNH414_)=Bio(i,k,iNH4_)-Bio(i,k,iNH415_)
              Bio(i,k,iSphy14)=Bio(i,k,iSphy)-Bio(i,k,iSphy15)
#endif

#if defined OXY
!OX1.1.2
              Bio(i,k,iOxyg)=Bio(i,k,iOxyg)+GppNPS*rOxNO3+GppAPS*rOxNH4
#endif
#if defined CARB 
!C1.1.1
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iTIC_,1)=Bio(i,k,iTIC_)
                BS(i,k,iTAlk,1)=Bio(i,k,iTAlk)
              END IF
#  if defined ISO
              IF (PRESENT(BS)) THEN
                BS(i,k,iDI13C,1)=Bio(i,k,iDI13C)
                BS(i,k,iDI14C,1)=Bio(i,k,iDI14C)
              END IF
#  endif 
#  if defined ISO_13C
              IF (PRESENT(BS)) THEN
                BS(i,k,iDI13C,1)=Bio(i,k,iDI13C)
              END IF
#  endif 
# endif

! .07 CaCO3 fraction of net primary production
! RAG and CAE are choosing to use the explicit form of primary 
! production reducing TIC. We chose this because we couldn't obtain a
! semi implicit mass conserving equation. We think this is acceptable in
! the case of TIC because it should never get close to zero.
! old semi implicit code is commented below 
!               cffC=(1.0_r8+CaCO3_frac)*RedCN(ng)*GppPS/                 &
!      &                    MAX(BIOmin,Bio(i,k,iTIC_))
!               Bio(i,k,iTIC_)=Bio(i,k,iTIC_)/(1.0_r8+cffC)
                Bio(i,k,iTIC_)=Bio(i,k,iTIC_)-(1.0_r8+CaCO3_frac)*        &
       &        RedCN(ng)*GppPS
!
! Alkalinity changes due to new production-GppNPS (RG)
! Gain of ~1 Eq Alk per mole NO3- consumed during Gpp
! 106CO2 + 16NO3- + H2PO4- + 122H20 + 17H+ <-> Protoplasm + 138O2
! eqn 97 pp 205 from Morel and Herring 1993
! NtoAlk = 1:1 unit conversion from N (mmol m-3 N) to Alk (mEq m-3)
!             
              Bio(i,k,iTAlk)=Bio(i,k,iTAlk)+GppNPS*NtoAlk
!
! Alkalinity changes due to recycled production-GppAPS (RG)
! Loss of ~1 Eq Alk per mole NH4+ consumed during Gpp
! 106CO2 + 16NH4+ + H2PO4- + 106H20 <-> Protoplasm + 106O2 + 15H+
! eqn 98 pp 205 from Morel and Herring 1993
! NtoAlk = 1:1 unit conversion from N (mmol m-3 N) to Alk (mEq m-3)
!
              cffC=GppAPS*NtoAlk/MAX(BIOmin,Bio(i,k,iTAlk))
              Bio(i,k,iTAlk)=Bio(i,k,iTAlk)/(1.0_r8+cffC)
!
! .07 CaCO3 fraction of net primary production
! Addition (removal) of 1 mol CO3-- results in 2 mole change in alk 
! (Dickson, 1981)
!
              cffC=2.0_r8*CaCO3_frac*RedCN(ng)*GppPS/                   &
     &              MAX(BIOmin,Bio(i,k,iTAlk))
              Bio(i,k,iTAlk)=Bio(i,k,iTAlk)/(1.0_r8+cffC)
              Bio(i,k,iCalC)=Bio(i,k,iCalC)+CaCO3_frac*RedCN(ng)*GppPS
# if defined ISO

!-----------------------------------------------------------------------
! FOR CO2 DEPENDENT FRACTIONATION-NOT YET IMPLEMENTED
!     temperature dependent equilibrium fraction
!     alpha_aq_g_surf = equilibrium solubilitiy ratio of 13CO2 and 12CO2
!     at equilibrium, alpha_aq_g_surf = R13Caq/R13Cgaseous
!     alpha_dic_g_surf = equilibrium fractionation factor between DIC and 
!     gaseous CO2
!     at equilibrium, alpha_dic_g_surf = R13CDIC / R13Cgasous
!-----------------------------------------------------------------------                
!               alpha_aq_g  = 0.9986_r8 - 4.9e-6*Bio(i,k,itemp)
!               alpha_dic_g = 1.01051_r8 - 1.05e-4*Bio(i,k,itemp)
!
! ! Fractionation is twice as large for 14C than for 13C
!               alpha_aq_g_14c  = alpha_aq_g_surf*2.0_r8
!               alpha_dic_g_14c = alpha_dic_g_surf*2.0_r8
! !-----------------------------------------------------------------------
! !   Popp et al (1989)
! !-----------------------------------------------------------------------
!
!               alpha_poc_aq = -0.017_r8 * log10(CO2star(i,k) + 1.0034_r8
!
!               R13C_org = alpha_aq_g / alpha_dic_g * alpha_poc_aq * R13C_DICik
!-----------------------------------------------------------------------
!   Calculate DI13C and DI14C changes based on Gpp and CaCO3 production
!   photoC and CaCO3prod, respectively
!   First changes due to Gpp, then CaCO3 production
!   implicit algorithm is included in cffC
!-----------------------------------------------------------------------
              ticik=Bio(i,k,iTIC_)
              di13c = Bio(i,k,iDI13C)
              di14c = Bio(i,k,iDI14C)
! to prevent division by zero
              if (ticik > 0.0_r8) then
                  R13C_DICik = di13c / ticik
                  R14C_DICik = di14c / ticik
              else
                  R13C_DICik = 1.0_r8 ! since tracer is scaled, 1 means R13C_DICik = R13C_std
                  R14C_DICik = 1.0_r8 ! since tracer is scaled, 1 means R14C_DICik = R14C_std
              endif
              R13C_org = R13C_DICik * alpha_org
              R13C_cc = R13C_DICik * alpha_cc
              
  
! Gpp
! RAG and CAE are choosing to use the explicit form of primary 
! production reducing TIC (and DI13C/DI14C). We chose this because we couldn't obtain a
! semi implicit mass conserving equation. We think this is acceptable in
! the case of TIC because it should never get close to zero.
! semi implicit form is commented out below
!              cffC=(1.0_r8)*RedCN(ng)*GppPS*R13C_org/                    &
!              & MAX(BIOmin,Bio(i,k,iDI13C))
!              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)/(1.0_r8+cffC)
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)-RedCN(ng)*GppPS*R13C_org
  
! CaCO3 prod
!               cffC=CaCO3_frac*RedCN(ng)*GppPS*R13C_cc/                   &
!               & MAX(BIOmin,Bio(i,k,iDI13C))
!              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)/(1.0_r8+cffC)
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)-CaCO3_frac*RedCN(ng)*     &
              & GppPS*R13C_cc
  
              R14C_org = R14C_DICik * alpha_org * 2.0_r8
              R14C_cc = R14C_DICik * alpha_cc * 2.0_r8
  
! Gpp
!               cffC=(1.0_r8)*RedCN(ng)*GppPS*R14C_org/                    &
!               & MAX(BIOmin,Bio(i,k,iDI14C))
!               Bio(i,k,iDI14C)=Bio(i,k,iDI14C)/(1.0_r8+cffC)
              Bio(i,k,iDI14C)=Bio(i,k,iDI14C)-RedCN(ng)*GppPS*R14C_org
  
! CaCO3 prod
!               cffC=CaCO3_frac*RedCN(ng)*GppPS*R14C_cc/                   &
!               & MAX(BIOmin,Bio(i,k,iDI14C))
!               Bio(i,k,iDI14C)=Bio(i,k,iDI14C)/(1.0_r8+cffC)
              Bio(i,k,iDI14C)=Bio(i,k,iDI14C)-CaCO3_frac*RedCN(ng)*     &
              & GppPS*R14C_cc
  
# endif
# if defined ISO_13C

!-----------------------------------------------------------------------
! FOR CO2 DEPENDENT FRACTIONATION-NOT YET IMPLEMENTED
!     temperature dependent equilibrium fraction
!     alpha_aq_g_surf = equilibrium solubilitiy ratio of 13CO2 and 12CO2
!     at equilibrium, alpha_aq_g_surf = R13Caq/R13Cgaseous
!     alpha_dic_g_surf = equilibrium fractionation factor between DIC and 
!     gaseous CO2
!     at equilibrium, alpha_dic_g_surf = R13CDIC / R13Cgasous
!-----------------------------------------------------------------------                
!               alpha_aq_g  = 0.9986_r8 - 4.9e-6*Bio(i,k,itemp)
!               alpha_dic_g = 1.01051_r8 - 1.05e-4*Bio(i,k,itemp)
!
! ! Fractionation is twice as large for 14C than for 13C
!               alpha_aq_g_14c  = alpha_aq_g_surf*2.0_r8
!               alpha_dic_g_14c = alpha_dic_g_surf*2.0_r8
! !-----------------------------------------------------------------------
! !   Popp et al (1989)
! !-----------------------------------------------------------------------
!
!               alpha_poc_aq = -0.017_r8 * log10(CO2star(i,k) + 1.0034_r8
!
!               R13C_org = alpha_aq_g / alpha_dic_g * alpha_poc_aq * R13C_DICik
!-----------------------------------------------------------------------
!   Calculate DI13C and DI14C changes based on Gpp and CaCO3 production
!   photoC and CaCO3prod, respectively
!   First changes due to Gpp, then CaCO3 production
!   implicit algorithm is included in cffC
!-----------------------------------------------------------------------
              ticik=Bio(i,k,iTIC_)
              di13c = Bio(i,k,iDI13C)
! to prevent division by zero
              if (ticik > 0.0_r8) then
                  R13C_DICik= di13c / ticik
              else
                  R13C_DICik=0.0112372_r8 
              endif
              R13C_org = R13C_DICik * alpha_org
              R13C_cc = R13C_DICik * alpha_cc
              
  
! Gpp
! RAG and CAE are choosing to use the explicit form of primary 
! production reducing TIC (and DI13C/DI14C). We chose this because we couldn't obtain a
! semi implicit mass conserving equation. We think this is acceptable in
! the case of TIC because it should never get close to zero.
! semi implicit form is commented out below
!              cffC=(1.0_r8)*RedCN(ng)*GppPS*R13C_org/                    &
!              & MAX(BIOmin,Bio(i,k,iDI13C))
!              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)/(1.0_r8+cffC)
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)-RedCN(ng)*GppPS*R13C_org
  
! CaCO3 prod
!               cffC=CaCO3_frac*RedCN(ng)*GppPS*R13C_cc/                   &
!               & MAX(BIOmin,Bio(i,k,iDI13C))
!              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)/(1.0_r8+cffC)
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)-CaCO3_frac*RedCN(ng)*     &
              & GppPS*R13C_cc
  
# endif
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iTIC_,2)=Bio(i,k,iTIC_)
                BS(i,k,iTAlk,2)=Bio(i,k,iTAlk)
              END IF

#  if defined ISO
              IF (PRESENT(BS)) THEN
                BS(i,k,iDI13C,2)=Bio(i,k,iDI13C)
                BS(i,k,iDI14C,2)=Bio(i,k,iDI14C)
              END IF
#  endif 
#  if defined ISO_13C
              IF (PRESENT(BS)) THEN
                BS(i,k,iDI13C,2)=Bio(i,k,iDI13C)
              END IF
#  endif 
# endif

#endif
#ifdef NEM_IRON_LIMIT
! Iron uptake proportional to growth
              cffFe=GppPS*FNratio/MAX(MinVal,Bio(i,k,iFeD_))
              Bio(i,k,iFeD_)=Bio(i,k,iFeD_)/(1.0_r8+cffFe)
              Bio(i,k,iFeSp)=Bio(i,k,iFeSp)+                            &
     &                       Bio(i,k,iFeD_)*cffFe
              if (debugging) then
                if ((i.eq.idebug) .and. (j.eq.jdebug) .and. (k.eq.kdebug)) then
                  write(6,*) '2) Bio(iFeD_,iFeSp)=',Bio(i,k,iFeD_),Bio(i,k,iFeSp)
                end if
              end if
!
! Iron uptake to reach appropriate Fe:C ratio
              cffFe=new_dtdays(ng)*(FCratioE-FCratio)/T_fe(ng)
              cffFe=Bio(i,k,iSphy)*cffFe*FeC2FeN
              IF (cffFe.ge.0.0_r8) THEN
                cffFe=cffFe/MAX(MinVal,Bio(i,k,iFeD_))
                Bio(i,k,iFeD_)=Bio(i,k,iFeD_)/(1.0_r8+cffFe)
                Bio(i,k,iFeSp)=Bio(i,k,iFeSp)+                          &
     &                         Bio(i,k,iFeD_)*cffFe
              ELSE
                cffFe=-cffFe/MAX(MinVal,Bio(i,k,iFeSp))
                Bio(i,k,iFeSp)=Bio(i,k,iFeSp)/(1.0_r8+cffFe)
                Bio(i,k,iFeD_)=Bio(i,k,iFeD_)+                          &
     &                         Bio(i,k,iFeSp)*cffFe
              END IF
#endif
#if defined TANGENT || defined ADJOINT
# ifdef  NEM_IRON_LIMIT
         CAE error here.  TL & ADJ code not written for NEM_IRON_LIMIT
# endif
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iNO3_,2)=Bio(i,k,iNO3_)
                BS(i,k,iNH4_,2)=Bio(i,k,iNH4_)
                BS(i,k,iSphy,2)=Bio(i,k,iSphy)
              END IF
#endif
!
!  Small Phytoplankton respiration rate, ResPS, assumed to be
!  proportional to biomass. Use ratio of NO3 uptake to total update
!  (NO3 + NH4) to compute respiration contributions.
!
#if defined NEMURO_CODE_MOD5
              RnewS=(GppNPS+BIOmin)/(GppPS+BIOmin+BIOmin)
#else /* NEMURO_CODE_MOD5 */
              RnewS=GppNPS/MAX(BIOmin,GppPS)
#endif /* NEMURO_CODE_MOD5 */
              cff4=new_dtdays(ng)*ResPS0(ng)*EXP(KResPS(ng)*Bio(i,k,itemp))
#if defined LOWER_LIM
              IF (Bio(i,k,iSphy).LE.1.0e-6_r8) THEN
                cff4=0.0_r8
              ENDIF
#endif
              Bio(i,k,iSphy)=Bio(i,k,iSphy)/(1.0_r8+cff4)
              ResPS=Bio(i,k,iSphy)*cff4
              Bio(i,k,iNO3_)=Bio(i,k,iNO3_)+ResPS*RnewS
              Bio(i,k,iNH4_)=Bio(i,k,iNH4_)+ResPS*(1.0_r8-RnewS)
#if defined DIAGNOSTICS_BIO
# if defined DIAGNOSTICS_NEM_PHY || defined DIAGNOSTICS_NEM_NIT
              DiaBio3dJ(i,k,iResPS2NO3)=DiaBio3dJ(i,k,iResPS2NO3) +     &
     &                               ResPS*RnewS
              DiaBio3dJ(i,k,iResPS2NH4)=DiaBio3dJ(i,k,iResPS2NH4) +     &
     &                               ResPS*(1.0_r8-RnewS)
# endif
#endif
#if defined N15
              Bio(i,k,iSphy15)=Bio(i,k,iSphy15)/(1.0_r8+cff4)
              ResPS15=cff4*Bio(i,k,iSphy15)
              Bio(i,k,iNO315_)=Bio(i,k,iNO315_)+(ResPS15*RnewS)
              Bio(i,k,iNH415_)=Bio(i,k,iNH415_)+                        &
     &                         (ResPS15*(1.0_r8-RnewS))
              Bio(i,k,iSphy14)=Bio(i,k,iSphy)-Bio(i,k,iSphy15)
              Bio(i,k,iNO314_)=Bio(i,k,iNO3_)-Bio(i,k,iNO315_)
              Bio(i,k,iNH414_)=Bio(i,k,iNH4_)-Bio(i,k,iNH415_)
#endif
#if defined OXY
!OX1.1.3
              Bio(i,k,iOxyg)=Bio(i,k,iOxyg)-ResPS*(RnewS*rOxNO3+        &
     &                                    (1.0_r8-RnewS)*rOxNH4) 
#endif
#if defined CARB & ! defined KO02
!C1.1.2
              Bio(i,k,iTIC_)=Bio(i,k,iTIC_)+RedCN(ng)*ResPS
!
! Alkalinity changes due to respiration into NO3- (RG)
! Loss of ~1 Eq Alk per mole NO3- gained during respiration
! 106CO2 + 16NO3- + H2PO4- + 122H20 + 17H+ <-> Protoplasm + 138O2
! eqn 97 pp 205 from Morel and Herring 1993
! NtoAlk = 1:1 unit conversion from N (mmol m-3 N) to Alk (mEq m-3)
!          
! explicit -> Bio(i,k,iTAlk)=Bio(i,k,iTAlk)-ResPS*RnewS*NtoAlk
             
              
              cff4=ResPS*RnewS*NtoAlk/MAX(BIOmin,Bio(i,k,iTAlk))
              Bio(i,k,iTAlk)=Bio(i,k,iTAlk)/(1.0_r8+cff4)
!
! Alkalinity changes due to respiration into NH4+ (RG)
! Gain of ~1 Eq Alk per mole NH4+ gained during respiration
! 106CO2 + 16NH4+ + H2PO4- + 106H20 <-> Protoplasm + 106O2 + 15H+
! eqn 98 pp 205 from Morel and Herring 1993
! NtoAlk = 1:1 unit conversion from N (mmol m-3 N) to Alk (mEq m-3)
!
              Bio(i,k,iTAlk)=Bio(i,k,iTAlk)+ResPS*(1.0_r8-RnewS)*NtoAlk
#endif
#if defined ISO & ! defined KO02

! ResPS is the amount of Nitrogen respired from small phytoplankton
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)+RedCN(ng)*ResPS*R13C_org
              Bio(i,k,iDI14C)=Bio(i,k,iDI14C)+RedCN(ng)*ResPS*R14C_org
#endif
#if defined ISO_13C & ! defined KO02

! ResPS is the amount of Nitrogen respired from small phytoplankton
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)+RedCN(ng)*ResPS*R13C_org
#endif
#ifdef NEM_IRON_LIMIT
! Small phytoplankton respiration Fe terms
              Bio(i,k,iFeSp)=Bio(i,k,iFeSp)/(1.0_r8+cff4)
              Bio(i,k,iFeD_)=Bio(i,k,iFeD_)+                            &
     &                       Bio(i,k,iFeSp)*cff4*FeRR(ng)
              if (debugging) then
                if ((i.eq.idebug) .and. (j.eq.jdebug) .and. (k.eq.kdebug)) then
                  write(6,*) '3) cff4,FeRR=',cff4,FeRR(ng)
                  write(6,*) '3) Bio(iFeD_,iFeSp)=',Bio(i,k,iFeD_),Bio(i,k,iFeSp)
                end if
              end if
#endif
#if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iNO3_,3)=Bio(i,k,iNO3_)
                BS(i,k,iNH4_,3)=Bio(i,k,iNH4_)
                BS(i,k,iSphy,3)=Bio(i,k,iSphy)
                BS(i,k,iDON_,1)=Bio(i,k,iDON_)
              END IF
#endif
!
!  Small Phytoplankton extracellular excretion rate, ExcPS, assumed to
!  be proportional to production.
!
              ExcPS=GppPS*GammaS(ng)
#if defined LOWER_LIM
              IF (Bio(i,k,iSphy).LE.1.0e-6_r8) THEN
                ExcPS=0.0_r8
              ENDIF
#endif
#if defined N15
              IF (Bio(i,k,iSphy).GT.0.0_r8) THEN
                ExcPS15=ExcPS*(Bio(i,k,iSphy15)/Bio(i,k,iSphy))
              ELSE
                ExcPS15=0.0_r8
              ENDIF
#endif
              Bio(i,k,iSphy)=Bio(i,k,iSphy)-ExcPS
              Bio(i,k,iDON_)=Bio(i,k,iDON_)+ExcPS
#if defined N15
              Bio(i,k,iSphy15)=Bio(i,k,iSphy15)-ExcPS15
              Bio(i,k,iDON15_)=Bio(i,k,iDON15_)+ExcPS15
              Bio(i,k,iSphy14)=Bio(i,k,iSphy)-Bio(i,k,iSphy15)
              Bio(i,k,iDON14_)=Bio(i,k,iDON_)-Bio(i,k,iDON15_)
#endif
#ifdef NEM_IRON_LIMIT
! Small phytoplankton excretion Fe terms
              cffFe=ExcPS*Bio(i,k,iFeSp)/MAX(MinVal,Bio(i,k,iSphy))
              Bio(i,k,iFeSp)=Bio(i,k,iFeSp)-cffFe
              Bio(i,k,iFeD_)=Bio(i,k,iFeD_)+cffFe*FeRR(ng)
#endif
# if defined TANGENT || defined ADJOINT
# ifdef  NEM_IRON_LIMIT
         CAE error here.  TL & ADJ code not written for NEM_IRON_LIMIT
# endif
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iSphy,4)=Bio(i,k,iSphy)
                BS(i,k,iDON_,2)=Bio(i,k,iDON_)
              END IF
#endif
#if defined DIAGNOSTICS_BIO
# ifdef DIAGNOSTICS_NEM_PHY 
              DiaBio3dJ(i,k,iExcPS)=DiaBio3dJ(i,k,iExcPS) + ExcPS
# endif
#endif
            END DO
          END DO
      RETURN
      END SUBROUTINE phytoplankton_pps
!
!
!
      SUBROUTINE phytoplankton_ppl(tile, ng, IminS, ImaxS, LightL, Bio  &
#if defined NEM_IRON_LIMIT && defined NEM_IRON_RSIN
     &                               , LPSiN                            &
# endif
# if defined NEMURO_CHL_GEIDER 
     &                               , Chl2NL, LightChl, BSL            &
# endif
# if defined TANGENT || defined ADJOINT
     &                               , BS                               &
# endif
#if defined DIAGNOSTICS_BIO
     &                               , DiaBio3dJ                        &
#endif
# if defined LOGDIAGNOSTICS_NEM_CHL || defined NEMURO_CHL_EXITONNEGATIVE
     &                               , j                                &
# endif
# if defined ISO || defined ISO_13C
     &                               , CO2star                          &
# endif
     &                               )
!
      USE mod_param
      USE mod_biology

!
!  Imported variable declarations.
!
      integer, intent(in) :: tile, ng, IminS, ImaxS
      real(r8),intent(inout),dimension(IminS:ImaxS,N(ng),NT(ng)) :: Bio
      real(r8),intent(in),dimension(IminS:ImaxS,N(ng)) :: LightL
# if defined NEMURO_CHL_GEIDER 
      real(r8),intent(in),dimension(IminS:ImaxS,N(ng)) :: LightChl
      real(r8),intent(out),dimension(IminS:ImaxS,N(ng)) :: Chl2NL
      real(r8),intent(out),dimension(IminS:ImaxS,N(ng)) :: BSL
# endif
#if defined NEM_IRON_LIMIT && defined NEM_IRON_RSIN
      real(r8),intent(in),dimension(IminS:ImaxS,N(ng)) :: LPSiN
# endif
# if defined ISO || defined ISO_13C
      real(r8), intent(in), dimension(IminS:ImaxS,N(ng)) :: CO2star
# endif 
# if defined TANGENT || defined ADJOINT
      real(r8),intent(inout),optional,                                  &
     &  dimension(IminS:ImaxS,N(ng),3:NT(ng),1:6) :: BS
# endif
# ifdef DIAGNOSTICS_BIO
      real(r8), intent(inout) :: DiaBio3dJ(IminS:ImaxS,N(ng),NDbio3d)
# endif
# if defined LOGDIAGNOSTICS_NEM_CHL || defined NEMURO_CHL_EXITONNEGATIVE
      integer, intent(in) :: j
# endif
!
!  Local variable declarations
!
      real(r8) :: cff, cff1, cff2, cff3, cff4, cff5, cff6, cff7
      real(r8) :: fac1, fac2
      real(r8) :: GppNPL, GppAPL, GppPL
      real(r8) :: RnewL, ResPL, ExcPL
#ifdef N15
      real(r8) :: GppAPL15, GppNPL15, GppPL15
      real(r8) :: cff_iso1,cff_iso2,cff_iso3
      real(r8) :: epsilon_NH4,epsilon_NO3
      real(r8) :: gamma_NH4,gamma_NO3
      real(r8) :: NO3_old,NH4_old
      real(r8) :: ResPL15, ExcPL15
#endif
# if defined ISO
      real(r8) :: &
        ticik,         &   ! TIC at current timestep
        di12c,         &   ! 12C in DIC
        di13c,         &   ! 13C in DIC
        di14c,         &   ! 14C in DIC
        R13C_DICik,    &   ! 13C/12C ratio at current timestep
        R14C_DICik,    &   ! 14C/12C ratio at current timestep
        alpha_cc = 0.998_r8, & ! equivlent to -2 per mil offset
        alpha_org = 0.978_r8,  & ! equivlent to -22 per mil offset
        R13C_org,      &   ! ratio of 13C/12C in organic matter 
        R13C_cc,       &   ! ratio of 13C/12C in calcium carbonate  
        R14C_org,      &   ! ratio of 14C/12C in organic matter 
        R14C_cc            ! ratio of 14C/12C in calcium carbonate  
# endif
# if defined ISO_13C
      real(r8) :: &
        ticik,         &   ! TIC at current timestep
        di12c,         &   ! 12C in DIC
        di13c,         &   ! 13C in DIC
        R13C_DICik,    &   ! 13C/12C ratio at current timestep
        alpha_cc = 0.998_r8, & ! equivlent to -2 per mil offset
        alpha_org = 0.978_r8,  & ! equivlent to -22 per mil offset
        R13C_org,      &   ! ratio of 13C/12C in organic matter 
        R13C_cc          ! ratio of 13C/12C in calcium carbonate  
# endif
# if defined NEMURO_CHL_GEIDER
      real(r8) :: rhoChl
#  if defined NEMURO_CHL_GEIDER_ACCLIM
      real(r8) :: acclim
#  endif
# endif
#if defined CARB 
      real(r8) :: cffC
      real(r8) :: NtoAlk = 1.0_r8     ! conversion N units to Alk units
      real(r8) :: CaCO3_frac = 0.0_r8 ! Diatoms do not produce CaCO3 shells
#endif
#ifdef NEM_IRON_LIMIT
      real(r8) :: FNratio, FCratio, FCratioE, cffFe, Flimit, cff8
      real(r8), parameter :: MinVal = 1.0e-6_r8
#endif

      integer :: i, k 
      integer, parameter :: itemp = 1 
! instead of #include "set_bounds.h"
      integer :: Istr, Iend
      Istr   =BOUNDS(ng) % Istr   (tile)
      Iend   =BOUNDS(ng) % Iend   (tile)

!
!  Gross primary production of Large Phytoplankton consisting of
!  nutrient uptake (NO3, NH4, Silicate) terms, temperature-dependend
!  term, and light limitation term. Notice that there is a silicate
!  limiting term (which complicates the implicit algorithm). Again,
!  the Michaelis-Menten curve is used to describe the change in
!  uptake rate as a function of nutrient concentration.
!
          cff=new_dtdays(ng)*VmaxL(ng)
          fac1=1.0/RSiN(ng)
          fac2=new_dtdays(ng)*ResPL0(ng)
          DO k=1,N(ng)
            DO i=Istr,Iend     
#if defined TANGENT || defined ADJOINT
!
!  First save the initial Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iSiOH,1)=Bio(i,k,iSiOH)
                BS(i,k,iLphy,1)=Bio(i,k,iLphy)
# if defined NEMURO_CHL_GEIDER
                BS(i,k,iChlS,2)=Bio(i,k,iChlS)
                BS(i,k,iChlL,2)=Bio(i,k,iChlL)
# endif
              END IF
#endif
!
!  Large Phytoplankton gross primary productivity, GppPL. Notice that
!  the primary productivity is limited by previous time-step silicate
!  concentration.
!
#ifdef NEM_IRON_LIMIT
!
!  Growth reduction factors due to iron limitation:
!
!    FNratio     current Fe:N ratio [umol-Fe/mmol-N]
!    FCratio     current Fe:C ratio [umol-Fe/mol-C]
!                  (umol-Fe/mmol-N)*(16 M-N/106 M-C)*(1E3 mmol-C/mol-C)
!    FCratioE    empirical  Fe:C ratio
!    Flimit      Phytoplankton growth reduction factor due to Fe
!                  limitation based on Fe:C ratio
! Large phytoplankton growth reduction factor due to iron limitation
!
              FNratio=Bio(i,k,iFeLp)/MAX(MinVal,Bio(i,k,iLphy))
              FCratio=FNratio*FeN2FeC
              FCratioE= B_Fe(ng)*Bio(i,k,iFeD_)**A_Fe(ng)
              Flimit = FCratio**2.0_r8/                                 &
     &                 (FCratio**2.0_r8+LK_FeC(ng)**2.0_r8)

!
!  Large Phytoplankton gross primary productivity, GppPL.
!
              cff1=cff*EXP(KGppL(ng)*Bio(i,k,itemp))*LightL(i,k)*       &
     &             Bio(i,k,iLphy)
              cff2=EXP(-PusaIL(ng)*Bio(i,k,iNH4_))/                     &
     &             (KNO3L(ng)+Bio(i,k,iNO3_))
              cff3=1.0_r8/(KNH4L(ng)+Bio(i,k,iNH4_))
              cff4=cff2*Bio(i,k,iNO3_)
              cff5=cff3*Bio(i,k,iNH4_)
              cff6=Bio(i,k,iSiOH)/(KSiL(ng)+Bio(i,k,iSiOH))
#  ifdef DIAGNOSTICS_NEM_LIM
              DiaBio3dJ(i,k,iNO3limLp)=DiaBio3dJ(i,k,iNO3limLp)+cff4
              DiaBio3dJ(i,k,iNH4limLp)=DiaBio3dJ(i,k,iNH4limLp)+cff5
              DiaBio3dJ(i,k,iSilimLp)=DiaBio3dJ(i,k,iSilimLp)+cff6
              DiaBio3dJ(i,k,iFelimLp)=DiaBio3dJ(i,k,iFelimLp)+Flimit
#  endif
              cff7=cff6/MAX(MinVal,cff4+cff5)
              cff8=Flimit/MAX(MinVal,cff4+cff5)
              cff4=cff1*cff2*MIN(1.0_r8,MIN(cff7,cff8))   ! Si/Fe lim on N03
              cff5=cff1*cff3*MIN(1.0_r8,MIN(cff7,cff8))   ! Si/Fe lim on NH4
# if defined N15
              NO3_old=Bio(i,k,iNO3_)
              NH4_old=Bio(i,k,iNH4_)
# endif
# if defined LOWER_LIM
              IF (Bio(i,k,iNO3_).LE.1.0e-3_r8) THEN
                cff4=0.0_r8
              ENDIF
              IF (Bio(i,k,iNH4_).LE.1.0e-3_r8) THEN
                cff5=0.0_r8
              ENDIF
# endif
              Bio(i,k,iNO3_)=Bio(i,k,iNO3_)/(1.0_r8+cff4)
              Bio(i,k,iNH4_)=Bio(i,k,iNH4_)/(1.0_r8+cff5)
              GppNPL=Bio(i,k,iNO3_)*cff4
              GppAPL=Bio(i,k,iNH4_)*cff5
              GppPL=GppNPL+GppAPL
#else
              cff1=cff*EXP(KGppL(ng)*Bio(i,k,itemp))*LightL(i,k)*       &
     &             Bio(i,k,iLphy)
              cff2=EXP(-PusaIL(ng)*Bio(i,k,iNH4_))/                     &
     &             (KNO3L(ng)+Bio(i,k,iNO3_))
              cff3=1.0_r8/(KNH4L(ng)+Bio(i,k,iNH4_))
              cff4=cff2*Bio(i,k,iNO3_)
              cff5=cff3*Bio(i,k,iNH4_)
              cff6=Bio(i,k,iSiOH)/(KSiL(ng)+Bio(i,k,iSiOH))
#  ifdef DIAGNOSTICS_NEM_LIM
              DiaBio3dJ(i,k,iNO3limLp)=DiaBio3dJ(i,k,iNO3limLp)+cff4
              DiaBio3dJ(i,k,iNH4limLp)=DiaBio3dJ(i,k,iNH4limLp)+cff5
              DiaBio3dJ(i,k,iSilimLp)=DiaBio3dJ(i,k,iSilimLp)+cff6
#  endif
              cff7=cff6/MAX(BIOmin,cff4+cff5)
              cff4=cff1*cff2*MIN(1.0_r8,cff7) ! Si limitation on N03
              cff5=cff1*cff3*MIN(1.0_r8,cff7) ! Si limitation on NH4
# if defined N15
              NO3_old=Bio(i,k,iNO3_)
              NH4_old=Bio(i,k,iNH4_)
# endif
# if defined LOWER_LIM
              IF (Bio(i,k,iNO3_).LE.1.0e-3_r8) THEN
                cff4=0.0_r8
              ENDIF
              IF (Bio(i,k,iNH4_).LE.1.0e-3_r8) THEN
                cff5=0.0_r8
              ENDIF
# endif
              Bio(i,k,iNO3_)=Bio(i,k,iNO3_)/(1.0_r8+cff4)
              Bio(i,k,iNH4_)=Bio(i,k,iNH4_)/(1.0_r8+cff5)
              GppNPL=Bio(i,k,iNO3_)*cff4
              GppAPL=Bio(i,k,iNH4_)*cff5
              GppPL=GppNPL+GppAPL
#endif
#if defined NEMURO_CHL_GEIDER
!
!  Save large phytoplankton (post-growth).
!
              BSL(i,k)=Bio(i,k,iLphy)+GppPL

# if defined NEMURO_CHL_GEIDER_OLD
              Chl2NL(i,k)=Bio(i,k,iChlL)/MAX(BIOmin,Bio(i,k,iLphy))
# elif defined NEMURO_CHL_GEIDER_MINMAX
              Chl2NL(i,k)=MAX(Chl2NL_min,MIN(Chl2NL_max(ng),            &
     &          Bio(i,k,iChlL)/MAX(BIOmin,Bio(i,k,iLphy))))
# else
              Chl2NL(i,k)=MIN(Chl2NL_max(ng),                           &
     &          Bio(i,k,iChlL)/MAX(BIOmin,Bio(i,k,iLphy)))
# endif
# if defined NEMURO_CHL_GEIDER_ACCLIM
!              acclim=MIN(Chl2NL_max(ng),Chl2NL_max(ng)/(                &
!     &          1.0_r8+(Chl2NL_max(ng)*LightChl(i,k)*alphaPL(ng)/       &
!     &          (2.0_r8*VmaxL(ng)))))
              acclim=MIN(Chl2NL_max(ng),Chl2NL_max(ng)/(                &
     &          1.0_r8+(LightChl(i,k)*alphaPL(ng)/(2.0_r8*VmaxL(ng)))))
              rhoChl=Chl2NL_max(ng)*GppPL/                              &
     &          MAX(BIOmin,new_dtdays(ng)*LightChl(i,k)*                &
     &          alphaPL(ng)*acclim)
              Bio(i,k,iChlL)=Bio(i,k,iChlL)+rhoChl*GppPL+               &
     &          new_dtdays(ng)*chltacclimL(ng)*                         &
     &          (acclim-Chl2NL(i,k))*Bio(i,k,iLphy)
# else
              ! based on (4) in Geider1997
              rhoChl=Chl2NL_max(ng)*GppPL/                              &
     &          MAX(BIOmin,Chl2NL(i,k)*new_dtdays(ng)*LightChl(i,k)*    &
     &          alphaPL(ng))
              Bio(i,k,iChlL)=Bio(i,k,iChlL)+rhoChl*GppPL
# endif
# if defined LOGDIAGNOSTICS_NEM_CHL
              if (k==LOGDIAGNOSTICS_NEM_CHL_K.and.i==LOGDIAGNOSTICS_NEM_CHL_I.and.j==LOGDIAGNOSTICS_NEM_CHL_J) then
                write(*,'(a30,f19.12)') 'ChlL = ',Bio(i,k,iChlL)
                write(*,'(a30,f19.12)') 'Lphy = ',Bio(i,k,iLphy)
                write(*,'(a30,f19.12)') 'Chl2NL = ',Chl2NL(i,k)
                write(*,'(a30,f19.12)') 'LightChl = ',LightChl(i,k)
                write(*,'(a30,f19.12)') 'alphaPL*LightChl/Lphy = ',     &
     &            alphaPL(ng)*LightChl(i,k)/Bio(i,k,iLphy)
                write(*,'(a30,f19.12)') 'alphaPL*LightChl*Chl2NL = ',   &
     &            alphaPL(ng)*LightChl(i,k)*Chl2NL(i,k)
                write(*,'(a30,f19.12,a,f19.12,a,f19.12)')               &
     &            'ChlL growth: ',rhoChl,'*',GppPL,'=',                 &
     &            rhoChl*GppPL
              end if
# endif
# ifdef DIAGNOSTICS_BIO
#  ifdef DIAGNOSTICS_NEM_CHL
              DiaBio3dJ(i,k,irhoChlL)=DiaBio3dJ(i,k,irhoChlL)+          &
     &          rhoChl*new_dtdays(ng)/Chl2NL(i,k)
#  endif
# endif
#endif
              Bio(i,k,iLphy)=Bio(i,k,iLphy)+GppPL
#if defined NEM_IRON_LIMIT && defined NEM_IRON_RSIN
              Bio(i,k,iSiOH)=Bio(i,k,iSiOH)-GppPL*LPSiN(i,k)
# else
              Bio(i,k,iSiOH)=Bio(i,k,iSiOH)-GppPL*RSiN(ng)
# endif
#if defined DIAGNOSTICS_BIO
# if defined DIAGNOSTICS_NEM_PHY || defined DIAGNOSTICS_NEM_NIT
              DiaBio3dJ(i,k,iGppNPL)=DiaBio3dJ(i,k,iGppNPL) + GppNPL
              DiaBio3dJ(i,k,iGppAPL)=DiaBio3dJ(i,k,iGppAPL) + GppAPL
# endif
#endif
#if defined N15
              IF (NO3_old.GT.0.0_r8) THEN
                epsilon_NO3=eps_GppNO3(ng)*                             &
     &                      (1.0_r8-(GppNPL/NO3_old))
              ELSE
                epsilon_NO3=0.0_r8
              ENDIF
              IF (NH4_old.GT.0.0_r8) THEN
                epsilon_NH4=eps_GppNH4(ng)*                             &
     &                        (1.0_r8-(GppAPL/NH4_old))
              ELSE
                epsilon_NH4=0.0_r8
              ENDIF
              gamma_NO3=1.0_r8-(epsilon_NO3/1000.0_r8)
              gamma_NH4=1.0_r8-(epsilon_NH4/1000.0_r8)
              IF ((Bio(i,k,iNO3_).GT.0.0_r8) .AND.                      &
     &            (Bio(i,k,iNO315_).GT.0.0_r8) .AND.                    &
     &            (Bio(i,k,iNO314_).GT.0.0_r8)) THEN
                GppNPL15=GppNPL*(gamma_NO3*(Bio(i,k,iNO315_)            &
     &                   /Bio(i,k,iNO314_)))/(1.0_r8+(gamma_NO3*        &
     &                   (Bio(i,k,iNO315_)/Bio(i,k,iNO314_))))
              ELSE
                GppNPL15=0.0_r8
              ENDIF
              IF ((Bio(i,k,iNH4_).GT.0.0_r8) .AND.                      &
     &            (Bio(i,k,iNH415_).GT.0.0_r8) .AND.                    &
     &            (Bio(i,k,iNH414_).GT.0.0_r8)) THEN
                GppAPL15=GppAPL*(gamma_NH4*(Bio(i,k,iNH415_)            &
     &                   /Bio(i,k,iNH414_)))/(1.0_r8+(gamma_NH4*        &
     &                   (Bio(i,k,iNH415_)/Bio(i,k,iNH414_))))
              ELSE
                GppAPL15=0.0_r8
              ENDIF
              GppPL15=GppNPL15+GppAPL15
              Bio(i,k,iNO315_)=Bio(i,k,iNO315_)-GppNPL15
              Bio(i,k,iNH415_)=Bio(i,k,iNH415_)-GppAPL15
              Bio(i,k,iLphy15)=Bio(i,k,iLphy15)+GppPL15
              Bio(i,k,iNO314_)=Bio(i,k,iNO3_)-Bio(i,k,iNO315_)
              Bio(i,k,iNH414_)=Bio(i,k,iNH4_)-Bio(i,k,iNH415_)
              Bio(i,k,iLphy14)=Bio(i,k,iLphy)-Bio(i,k,iLphy15)
#endif
#if defined OXY 
!OX1.1.4
              Bio(i,k,iOxyg)=Bio(i,k,iOxyg)+GppNPL*rOxNO3+GppAPL*rOxNH4
#endif 
#if defined CARB & ! defined KO03
!C1.1.3
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iTIC_,3)=Bio(i,k,iTIC_)
                BS(i,k,iTAlk,3)=Bio(i,k,iTAlk)
              END IF
#  if defined ISO
              IF (PRESENT(BS)) THEN
                BS(i,k,iDI13C,3)=Bio(i,k,iDI13C)
                BS(i,k,iDI14C,3)=Bio(i,k,iDI14C)
              END IF
#  endif
#  if defined ISO_13C
              IF (PRESENT(BS)) THEN
                BS(i,k,iDI13C,3)=Bio(i,k,iDI13C)
              END IF
#  endif 
# endif
! .07 CaCO3 fraction of net primary production
! RAG and CAE are choosing to use the explicit form of primary 
! production reducing TIC. We chose this because we couldn't obtain a
! semi implicit mass conserving equation. We think this is acceptable in
! the case of TIC because it should never get close to zero.
! old semi implicit code is commented below 
!               cffC=(1.0_r8+CaCO3_frac)*RedCN(ng)*GppPL/                 &
!      &                    MAX(BIOmin,Bio(i,k,iTIC_))
!               Bio(i,k,iTIC_)=Bio(i,k,iTIC_)/(1.0_r8+cffC)
                Bio(i,k,iTIC_)=Bio(i,k,iTIC_)-(1.0_r8+CaCO3_frac)*        &
       &        RedCN(ng)*GppPL
!
! Alkalinity changes due to new production-GppNPL (RG)
! Gain of ~1 Eq Alk per mole NO3- consumed during Gpp
! 106CO2 + 16NO3- + H2PO4- + 122H20 + 17H+ <-> Protoplasm + 138O2
! eqn 97 pp 205 from Morel and Herring 1993
! NtoAlk = 1:1 unit conversion from N (mmol m-3 N) to Alk (mEq m-3)
!        
              Bio(i,k,iTAlk)=Bio(i,k,iTAlk)+GppNPL*NtoAlk
!
! Alkalinity changes due to recycled production-GppAPL (RG)
! Loss of ~1 Eq Alk per mole NH4+ consumed during Gpp
! 106CO2 + 16NH4+ + H2PO4- + 106H20 <-> Protoplasm + 106O2 + 15H+
! eqn 98 pp 205 from Morel and Herring 1993
! NtoAlk = 1:1 unit conversion from N (mmol m-3 N) to Alk (mEq m-3)
!
              cffC=GppAPL*NtoAlk/MAX(BIOmin,Bio(i,k,iTAlk))
              Bio(i,k,iTAlk)=Bio(i,k,iTAlk)/(1.0_r8+cffC)

!
! No CaCO3 shells in diatoms (large phytoplankton). CaCO3_frac = 0
! Addition (removal) of 1 mol CO3-- results in 2 mole change in alk 
! (Dickson, 1981)
!
              cffC=2.0_r8*CaCO3_frac*RedCN(ng)*GppPL/                   &
     &                  MAX(BIOmin,Bio(i,k,iTAlk))
              Bio(i,k,iTAlk)=Bio(i,k,iTAlk)/(1.0_r8+cffC)
              Bio(i,k,iCalC)=Bio(i,k,iCalC)+CaCO3_frac*RedCN(ng)*GppPL
# if defined ISO

!-----------------------------------------------------------------------
!   Calculate DI13C and DI14C changes based on Gpp and CaCO3 production
!   photoC and CaCO3prod, respectively
!   First changes due to Gpp, then CaCO3 production
!   implicit algorithm is included in cffC
!-----------------------------------------------------------------------
              ticik=Bio(i,k,iTIC_)
              di13c = Bio(i,k,iDI13C)
              di14c = Bio(i,k,iDI14C)
! to prevent division by zero
              if (ticik > 0.0_r8) then
                  R13C_DICik= di13c / ticik
                  R14C_DICik= di14c / ticik
              else
                  R13C_DICik = 1.0_r8 ! since tracer is scaled, 1 means R13C_DICik = R13C_std
                  R14C_DICik = 1.0_r8 ! since tracer is scaled, 1 means R14C_DICik = R14C_std
              endif
              R13C_org = R13C_DICik * alpha_org
              R13C_cc = R13C_DICik * alpha_cc
  
! RAG and CAE are choosing to use the explicit form of primary 
! production reducing TIC (and DI13C/DI14C). We chose this because we couldn't obtain a
! semi implicit mass conserving equation. We think this is acceptable in
! the case of TIC because it should never get close to zero.
! semi implicit form is commented out below

! Gpp
!               cffC=(1.0_r8)*RedCN(ng)*GppPL*R13C_org/                    &
!               & MAX(BIOmin,Bio(i,k,iDI13C))
!               Bio(i,k,iDI13C)=Bio(i,k,iDI13C)/(1.0_r8+cffC)
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)-RedCN(ng)*GppPL*R13C_org
  
! CaCO3 prod
!               cffC=CaCO3_frac*RedCN(ng)*GppPL*R13C_cc/                   &
!               & MAX(BIOmin,Bio(i,k,iDI13C))
!               Bio(i,k,iDI13C)=Bio(i,k,iDI13C)/(1.0_r8+cffC)
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)-CaCO3_frac*RedCN(ng)*     &
              & GppPL*R13C_cc
  
              R14C_org = R14C_DICik * alpha_org * 2.0_r8
              R14C_cc = R14C_DICik * alpha_cc * 2.0_r8
  
! Gpp
!               cffC=(1.0_r8)*RedCN(ng)*GppPL*R14C_org/                    &
!               & MAX(BIOmin,Bio(i,k,iDI14C))
!               Bio(i,k,iDI14C)=Bio(i,k,iDI14C)/(1.0_r8+cffC)
              Bio(i,k,iDI14C)=Bio(i,k,iDI14C)-RedCN(ng)*GppPL*R14C_org
  
! CaCO3 prod
!               cffC=CaCO3_frac*RedCN(ng)*GppPL*R14C_cc/                   &
!               & MAX(BIOmin,Bio(i,k,iDI14C))
!               Bio(i,k,iDI14C)=Bio(i,k,iDI14C)/(1.0_r8+cffC)
              Bio(i,k,iDI14C)=Bio(i,k,iDI14C)-CaCO3_frac*RedCN(ng)*      &
              & GppPL*R14C_cc
  
# endif
# if defined ISO_13C

!-----------------------------------------------------------------------
!   Calculate DI13C and DI14C changes based on Gpp and CaCO3 production
!   photoC and CaCO3prod, respectively
!   First changes due to Gpp, then CaCO3 production
!   implicit algorithm is included in cffC
!-----------------------------------------------------------------------
              ticik=Bio(i,k,iTIC_)
              di13c = Bio(i,k,iDI13C)
! to prevent division by zero
              if (ticik > 0.0_r8) then
                  R13C_DICik= di13c / ticik
              else
                  R13C_DICik=0.0112372_r8
              endif
              R13C_org = R13C_DICik * alpha_org
              R13C_cc = R13C_DICik * alpha_cc
  
! RAG and CAE are choosing to use the explicit form of primary 
! production reducing TIC (and DI13C/DI14C). We chose this because we couldn't obtain a
! semi implicit mass conserving equation. We think this is acceptable in
! the case of TIC because it should never get close to zero.
! semi implicit form is commented out below

! Gpp
!               cffC=(1.0_r8)*RedCN(ng)*GppPL*R13C_org/                    &
!               & MAX(BIOmin,Bio(i,k,iDI13C))
!               Bio(i,k,iDI13C)=Bio(i,k,iDI13C)/(1.0_r8+cffC)
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)-RedCN(ng)*GppPL*R13C_org
  
! CaCO3 prod
!               cffC=CaCO3_frac*RedCN(ng)*GppPL*R13C_cc/                   &
!               & MAX(BIOmin,Bio(i,k,iDI13C))
!               Bio(i,k,iDI13C)=Bio(i,k,iDI13C)/(1.0_r8+cffC)
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)-CaCO3_frac*RedCN(ng)*     &
              & GppPL*R13C_cc
  
# endif
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iTIC_,4)=Bio(i,k,iTIC_)
                BS(i,k,iTAlk,4)=Bio(i,k,iTAlk)
              END IF
#  if defined ISO
              IF (PRESENT(BS)) THEN
                BS(i,k,iDI13C,4)=Bio(i,k,iDI13C)
                BS(i,k,iDI14C,4)=Bio(i,k,iDI14C)
              END IF
#  endif 
#  if defined ISO_13C
              IF (PRESENT(BS)) THEN
                BS(i,k,iDI13C,4)=Bio(i,k,iDI13C)
              END IF
#  endif 

# endif

#endif
#ifdef NEM_IRON_LIMIT
! Iron Uptake proportional to growth
              cffFe=GppPL*FNratio/MAX(MinVal,Bio(i,k,iFeD_))
              Bio(i,k,iFeD_)=Bio(i,k,iFeD_)/(1.0_r8+cffFe)
              Bio(i,k,iFeLp)=Bio(i,k,iFeLp)+                            &
     &                       Bio(i,k,iFeD_)*cffFe
!
! Iron uptake to reach appropriate Fe:C ratio
              cffFe=new_dtdays(ng)*(FCratioE-FCratio)/T_fe(ng)
              cffFe=Bio(i,k,iLphy)*cffFe*FeC2FeN
              IF (cffFe.ge.0.0_r8) THEN
                cffFe=cffFe/MAX(MinVal,Bio(i,k,iFeD_))
                Bio(i,k,iFeD_)=Bio(i,k,iFeD_)/(1.0_r8+cffFe)
                Bio(i,k,iFeLp)=Bio(i,k,iFeLp)+                          &
     &                         Bio(i,k,iFeD_)*cffFe
              ELSE
                cffFe=-cffFe/MAX(MinVal,Bio(i,k,iFeLp))
                Bio(i,k,iFeLp)=Bio(i,k,iFeLp)/(1.0_r8+cffFe)
                Bio(i,k,iFeD_)=Bio(i,k,iFeD_)+                          &
     &                         Bio(i,k,iFeLp)*cffFe
              END IF
#endif
# if defined TANGENT || defined ADJOINT
# ifdef  NEM_IRON_LIMIT
         CAE error here.  TL & ADJ code not written for NEM_IRON_LIMIT
# endif
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iNO3_,4)=Bio(i,k,iNO3_)
                BS(i,k,iNH4_,4)=Bio(i,k,iNH4_)
                BS(i,k,iLphy,2)=Bio(i,k,iLphy)
                BS(i,k,iSiOH,2)=Bio(i,k,iSiOH)
              END IF
#endif
!
!  Large Phytoplankton respiration rate, ResPL, assumed to be
!  proportional to biomass. Use ratio of NO3 uptake to total update
!  (NO3 + NH4) to compute respiration contributions. Use Si:N ratio to
!  compute SiOH4 contribution.
!
#if defined NEMURO_CODE_MOD5
              RnewL=(GppNPL+BIOmin)/(GppPL+BIOmin+BIOmin)
#else /* NEMURO_CODE_MOD5 */
              RnewL=GppNPL/MAX(BIOmin,GppPL)
#endif /* NEMURO_CODE_MOD5 */
              cff7=fac2*EXP(KResPL(ng)*Bio(i,k,itemp))
#if defined LOWER_LIM
              IF (Bio(i,k,iLphy).LE.1.0e-6_r8) THEN
                cff7=0.0_r8
              ENDIF
#endif
              Bio(i,k,iLphy)=Bio(i,k,iLphy)/(1.0_r8+cff7)
              ResPL=Bio(i,k,iLphy)*cff7
              Bio(i,k,iNO3_)=Bio(i,k,iNO3_)+ResPL*RnewL
              Bio(i,k,iNH4_)=Bio(i,k,iNH4_)+ResPL*(1.0_r8-RnewL)
#if defined NEM_IRON_LIMIT && defined NEM_IRON_RSIN
              Bio(i,k,iSiOH)=Bio(i,k,iSiOH)+ResPL*LPSiN(i,k)
#else
              Bio(i,k,iSiOH)=Bio(i,k,iSiOH)+ResPL*RSiN(ng)
#endif
#if defined DIAGNOSTICS_BIO
# if defined DIAGNOSTICS_NEM_PHY || defined DIAGNOSTICS_NEM_NIT
              DiaBio3dJ(i,k,iResPL2NO3)=DiaBio3dJ(i,k,iResPL2NO3) +     &
     &                               ResPL*RnewL
              DiaBio3dJ(i,k,iResPL2NH4)=DiaBio3dJ(i,k,iResPL2NH4) +     &
     &                               ResPL*(1.0_r8-RnewL)
# endif
#endif
#if defined N15
              Bio(i,k,iLphy15)=Bio(i,k,iLphy15)/(1.0_r8+cff7)
              ResPL15=cff7*Bio(i,k,iLphy15)
              Bio(i,k,iNO315_)=Bio(i,k,iNO315_)+(ResPL15*RnewL)
              Bio(i,k,iNH415_)=Bio(i,k,iNH415_)+                        &
     &                         (ResPL15*(1.0_r8-RnewL))
              Bio(i,k,iLphy14)=Bio(i,k,iLphy)-Bio(i,k,iLphy15)
              Bio(i,k,iNO314_)=Bio(i,k,iNO3_)-Bio(i,k,iNO315_)
              Bio(i,k,iNH414_)=Bio(i,k,iNH4_)-Bio(i,k,iNH415_)
#endif

#if defined OXY
!OX1.1.5
              Bio(i,k,iOxyg)=Bio(i,k,iOxyg)-ResPL*(RnewL*rOxNO3+        &
     &                                    (1.0_r8-RnewL)*rOxNH4) 
#endif
#if defined CARB & ! defined KO04
!C1.1.4
              Bio(i,k,iTIC_)=Bio(i,k,iTIC_)+RedCN(ng)*ResPL
              
!
! Alkalinity changes due to respiration into NO3- (RG)
! Loss of ~1 Eq Alk per mole NO3- gained during respiration
! 106CO2 + 16NO3- + H2PO4- + 122H20 + 17H+ <-> Protoplasm + 138O2
! eqn 97 pp 205 from Morel and Herring 1993
! NtoAlk = 1:1 unit conversion from N (mmol m-3 N) to Alk (mEq m-3)
!          
! explicit -> Bio(i,k,iTAlk)=Bio(i,k,iTAlk)-ResPL*RnewL*NtoAlk


              cff4=ResPL*RnewL*NtoAlk/MAX(BIOmin,Bio(i,k,iTAlk))
              Bio(i,k,iTAlk)=Bio(i,k,iTAlk)/(1.0_r8+cff4)
!
! Alkalinity changes due to respiration into NH4+ (RG)
! Gain of ~1 Eq Alk per mole NH4+ gained during respiration
! 106CO2 + 16NH4+ + H2PO4- + 106H20 <-> Protoplasm + 106O2 + 15H+
! eqn 98 pp 205 from Morel and Herring 1993
! NtoAlk = 1:1 unit conversion from N (mmol m-3 N) to Alk (mEq m-3)
!
              Bio(i,k,iTAlk)=Bio(i,k,iTAlk)+ResPL*(1.0_r8-RnewL)*NtoAlk
#endif
#if defined ISO & ! defined KO04
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)+RedCN(ng)*ResPL*R13C_org
              Bio(i,k,iDI14C)=Bio(i,k,iDI14C)+RedCN(ng)*ResPL*R14C_org
#endif
#if defined ISO_13C & ! defined KO04
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)+RedCN(ng)*ResPL*R13C_org
#endif
#ifdef NEM_IRON_LIMIT
! Large Phytoplankton respiration Fe terms
              Bio(i,k,iFeLp)=Bio(i,k,iFeLp)/(1.0_r8+cff7)
              Bio(i,k,iFeD_)=Bio(i,k,iFeD_)+                            &
     &                       Bio(i,k,iFeLp)*cff7*FeRR(ng)
#endif
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iNO3_,5)=Bio(i,k,iNO3_)
                BS(i,k,iNH4_,5)=Bio(i,k,iNH4_)
                BS(i,k,iLphy,3)=Bio(i,k,iLphy)
                BS(i,k,iSiOH,3)=Bio(i,k,iSiOH)
              END IF
#endif
!
!  Large Phytoplankton extracellular excretion rate, ExcPL, assumed to
!  be proportional to production.
!
              ExcPL=GppPL*GammaL(ng)
#if defined LOWER_LIM
              IF (Bio(i,k,iLphy).LE.1.0e-6_r8) THEN
                ExcPL=0.0_r8
              ENDIF
#endif
#if defined N15
              IF (Bio(i,k,iLphy).GT.0.0_r8) THEN
                ExcPL15=ExcPL*(Bio(i,k,iLphy15)/Bio(i,k,iLphy))
              ELSE
                ExcPL15=0.0_r8
              ENDIF
#endif
              Bio(i,k,iLphy)=Bio(i,k,iLphy)-ExcPL
              Bio(i,k,iDON_)=Bio(i,k,iDON_)+ExcPL
#if defined NEM_IRON_LIMIT && defined NEM_IRON_RSIN
              Bio(i,k,iSiOH)=Bio(i,k,iSiOH)+ExcPL*LPSiN(i,k)
#else
              Bio(i,k,iSiOH)=Bio(i,k,iSiOH)+ExcPL*RSiN(ng)
#endif
#if defined N15
              Bio(i,k,iLphy15)=Bio(i,k,iLphy15)-ExcPL15
              Bio(i,k,iDON15_)=Bio(i,k,iDON15_)+ExcPL15
              Bio(i,k,iLphy14)=Bio(i,k,iLphy)-Bio(i,k,iLphy15)
              Bio(i,k,iDON14_)=Bio(i,k,iDON_)-Bio(i,k,iDON15_)
#endif
#ifdef NEM_IRON_LIMIT
! Large Phytoplankton excretion Fe terms
              cffFe=ExcPL*Bio(i,k,iFeLp)/MAX(MinVal,Bio(i,k,iLphy))
              Bio(i,k,iFeLp)=Bio(i,k,iFeLp)-cffFe
              Bio(i,k,iFeD_)=Bio(i,k,iFeD_)+cffFe*FeRR(ng)
#endif
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iLphy,4)=Bio(i,k,iLphy)
                BS(i,k,iDON_,3)=Bio(i,k,iDON_)
                BS(i,k,iSiOH,4)=Bio(i,k,iSiOH)
                BS(i,k,iPON_,1)=Bio(i,k,iPON_)
                BS(i,k,iopal,1)=Bio(i,k,iopal)
              END IF
#endif
#if defined DIAGNOSTICS_BIO
# ifdef DIAGNOSTICS_NEM_PHY 
              DiaBio3dJ(i,k,iExcPL)=DiaBio3dJ(i,k,iExcPL) + ExcPL
# endif
#endif
            END DO
          END DO
      RETURN
      END SUBROUTINE phytoplankton_ppl
!
!
!
      SUBROUTINE phytoplankton_mortality(tile, ng, IminS, ImaxS, Bio    &
#if defined NEM_IRON_LIMIT && defined NEM_IRON_RSIN
     &                               , LPSiN                            &
#endif
# if defined TANGENT || defined ADJOINT
     &                               ,BS                                &
# endif
# if defined NEM_SPONGE
     &                               ,j                                 &
# endif
#if defined DIAGNOSTICS_BIO
     &                               , DiaBio3dJ                        &
#endif
     &                               )
!
      USE mod_param
      USE mod_biology

!
!  Imported variable declarations.
!
      integer, intent(in) :: tile, ng, IminS, ImaxS
      real(r8),intent(inout),dimension(IminS:ImaxS,N(ng),NT(ng)) :: Bio
#if defined NEM_IRON_LIMIT && defined NEM_IRON_RSIN
      real(r8),intent(in),dimension(IminS:ImaxS,N(ng)) :: LPSiN
#endif
# if defined TANGENT || defined ADJOINT
      real(r8),intent(inout),optional,                                  &
     &  dimension(IminS:ImaxS,N(ng),3:NT(ng),1:6) :: BS
# endif
# if defined NEM_SPONGE
      integer, intent(in) :: j
# endif
# ifdef DIAGNOSTICS_BIO
      real(r8), intent(inout) :: DiaBio3dJ(IminS:ImaxS,N(ng),NDbio3d)
# endif
!
!  Local variable declarations
!
      real(r8) :: fac1, fac2
      real(r8) :: cff1, cff2
      real(r8) :: MorPS, MorPL 
#ifdef N15
      real(r8) :: MorPL15, MorPS15
#endif
#ifdef NEM_SPONGE
      integer :: nbfr
      real(r8) :: nemfac
      real(r8), dimension(IminS:ImaxS) :: mortfac
#endif


      integer :: i, k 
      integer, parameter :: itemp = 1 
! instead of #include "set_bounds.h"
      integer :: Istr, Iend
      Istr   =BOUNDS(ng) % Istr   (tile)
      Iend   =BOUNDS(ng) % Iend   (tile)
!
!-----------------------------------------------------------------------
!  Phytoplankton mortality to particulate organic nitrogen.
!-----------------------------------------------------------------------
!

#ifdef NEM_SPONGE
!
!
      nbfr=NemSpongeN(ng)
      nemfac=NemSpongeF(ng)-1.0_r8    ! subtract 1 because we add it back later
      DO i=Istr,Iend
        mortfac(i)=1.0_r8
      END DO
      ! handle western boundary
      DO i=Istr,MIN(nbfr,Iend)
        cff1=1.0_r8+nemfac*REAL(nbfr-i,r8)/REAL(nbfr,r8)
        mortfac(i)=MAX(mortfac(i),cff1)
      END DO
      ! handle eastern boundary
      DO i=MAX(Istr,Lm(ng)+1-nbfr),Iend
        cff1=1.0_r8+nemfac*REAL(i-(Lm(ng)+1-nbfr),r8)/REAL(nbfr,r8)
        mortfac(i)=MAX(mortfac(i),cff1)
      END DO
      ! handle southern and northern boundaries
      DO i=Istr,Iend
        cff1=1.0_r8+nemfac*REAL(nbfr-j,r8)/REAL(nbfr,r8)
        mortfac(i)=MAX(mortfac(i),cff1)
        cff1=1.0_r8+nemfac*REAL(j-(Mm(ng)+1-nbfr),r8)/REAL(nbfr,r8)
        mortfac(i)=MAX(mortfac(i),cff1)
      END DO
#endif

      fac1=new_dtdays(ng)*MorPS0(ng)
      fac2=new_dtdays(ng)*MorPL0(ng)
      DO k=1,N(ng)
        DO i=Istr,Iend
          cff1=fac1*Bio(i,k,iSphy)*EXP(KMorPS(ng)*Bio(i,k,itemp))
          cff2=fac2*Bio(i,k,iLphy)*EXP(KMorPL(ng)*Bio(i,k,itemp))
#ifdef NEM_SPONGE
          cff1=cff1*mortfac(i)
          cff2=cff2*mortfac(i)
#endif
#if defined LOWER_LIM
          IF (Bio(i,k,iSphy).LE.1.0e-6_r8) THEN
            cff1=0.0_r8
          ENDIF
          IF (Bio(i,k,iLphy).LE.1.0e-6_r8) THEN
            cff2=0.0_r8
          ENDIF
#endif
          Bio(i,k,iSphy)=Bio(i,k,iSphy)/(1.0_r8+cff1)
          Bio(i,k,iLphy)=Bio(i,k,iLphy)/(1.0_r8+cff2)
          MorPS=Bio(i,k,iSphy)*cff1
          MorPL=Bio(i,k,iLphy)*cff2
          Bio(i,k,iPON_)=Bio(i,k,iPON_)+MorPS+MorPL
#if defined NEM_IRON_LIMIT && defined NEM_IRON_RSIN
          Bio(i,k,iopal)=Bio(i,k,iopal)+MorPL*LPSiN(i,k)
#else
          Bio(i,k,iopal)=Bio(i,k,iopal)+MorPL*RSiN(ng)
#endif
#if defined N15
          Bio(i,k,iSphy15)=Bio(i,k,iSphy15)/(1.0_r8+cff1)
          Bio(i,k,iLphy15)=Bio(i,k,iLphy15)/(1.0_r8+cff2)
          MorPS15=cff1*Bio(i,k,iSphy15)
          MorPL15=cff2*Bio(i,k,iLphy15)
          Bio(i,k,iPON15_)=Bio(i,k,iPON15_)+MorPS15+MorPL15
          Bio(i,k,iSphy14)=Bio(i,k,iSphy)-Bio(i,k,iSphy15)
          Bio(i,k,iLphy14)=Bio(i,k,iLphy)-Bio(i,k,iLphy15)
          Bio(i,k,iPON14_)=Bio(i,k,iPON_)-Bio(i,k,iPON15_)
#endif
#ifdef NEM_IRON_LIMIT
! Phytoplankton Mortality Fe terms
          Bio(i,k,iFeSp)=Bio(i,k,iFeSp)/(1.0_r8+cff1)
          Bio(i,k,iFeD_)=Bio(i,k,iFeD_)+                            &
     &                   Bio(i,k,iFeSp)*cff1*FeRR(ng)
          Bio(i,k,iFeLp)=Bio(i,k,iFeLp)/(1.0_r8+cff2)
          Bio(i,k,iFeD_)=Bio(i,k,iFeD_)+                            &
     &                   Bio(i,k,iFeLp)*cff2*FeRR(ng)
#endif
#if defined TANGENT || defined ADJOINT
# ifdef  NEM_IRON_LIMIT
         CAE error here.  TL & ADJ code not written for NEM_IRON_LIMIT
# endif
!
!  Save the intermediate Bio variables
!
          IF (PRESENT(BS)) THEN
            BS(i,k,iSphy,5)=Bio(i,k,iSphy)
            BS(i,k,iLphy,5)=Bio(i,k,iLphy)
            BS(i,k,iPON_,2)=Bio(i,k,iPON_)
            BS(i,k,iopal,2)=Bio(i,k,iopal)
          END IF
#endif
#if defined DIAGNOSTICS_BIO
# if defined DIAGNOSTICS_NEM_PHY 
          DiaBio3dJ(i,k,iMorPS)=DiaBio3dJ(i,k,iMorPS) + MorPS
          DiaBio3dJ(i,k,iMorPL)=DiaBio3dJ(i,k,iMorPL) + MorPL
# endif
#endif
        END DO
      END DO
      RETURN
      END SUBROUTINE phytoplankton_mortality
!
!
!
      SUBROUTINE zooplankton_grazing(tile, ng, IminS, ImaxS, Bio        &
#if defined NEM_IRON_LIMIT && defined NEM_IRON_RSIN
     &                               , LPSiN                            &
#endif
# if defined TANGENT || defined ADJOINT
     &                               , BS                               &
# endif
#if defined DIAGNOSTICS_BIO
     &                               , DiaBio3dJ                        &
#endif
     &                               )
!
      USE mod_param
      USE mod_biology

!
!  Imported variable declarations.
!
      integer, intent(in) :: tile, ng, IminS, ImaxS
      real(r8),intent(inout),dimension(IminS:ImaxS,N(ng),NT(ng)) :: Bio
#if defined NEM_IRON_LIMIT && defined NEM_IRON_RSIN
      real(r8),intent(in),dimension(IminS:ImaxS,N(ng)) :: LPSiN
#endif
# if defined TANGENT || defined ADJOINT
      real(r8),intent(inout),optional,                                  &
     &  dimension(IminS:ImaxS,N(ng),3:NT(ng),1:6) :: BS
# endif
# ifdef DIAGNOSTICS_BIO
      real(r8), intent(inout) :: DiaBio3dJ(IminS:ImaxS,N(ng),NDbio3d)
# endif
!
!  Local variable declarations
!
      real(r8) :: fac1, fac2, fac3, fac4, fac5, fac6, fac7 
# if defined ISO
      real(r8) :: &
        ticik,         &   ! TIC at current timestep
        di12c,         &   ! 12C in DIC
        di13c,         &   ! 13C in DIC
        di14c,         &   ! 14C in DIC
        R13C_DICik,    &   ! 13C/12C ratio at current timestep
        R14C_DICik,    &   ! 14C/12C ratio at current timestep
        alpha_cc = 0.998_r8, & ! equivlent to -2 per mil offset
        alpha_org = 0.978_r8,  & ! equivlent to -22 per mil offset
        R13C_org,      &   ! ratio of 13C/12C in organic matter 
        R13C_cc,       &   ! ratio of 13C/12C in calcium carbonate  
        R14C_org,      &   ! ratio of 14C/12C in organic matter 
        R14C_cc            ! ratio of 14C/12C in calcium carbonate  
# endif
# if defined ISO_13C
      real(r8) :: &
        ticik,         &   ! TIC at current timestep
        di12c,         &   ! 12C in DIC
        di13c,         &   ! 13C in DIC
        R13C_DICik,    &   ! 13C/12C ratio at current timestep
        alpha_cc = 0.998_r8, & ! equivlent to -2 per mil offset
        alpha_org = 0.978_r8,  & ! equivlent to -22 per mil offset
        R13C_org,      &   ! ratio of 13C/12C in organic matter 
        R13C_cc          ! ratio of 13C/12C in calcium carbonate  
# endif
# if defined NEMUCSC
      real(r8) :: fac8
#endif
      real(r8) :: cff, cff1, cff2, cff3, cff4, cff5, cff6
      real(r8) :: GraPL2ZL, GraPL2ZP, GraPS2ZL, GraPS2ZS
      real(r8) :: GraZL2ZP, GraZS2ZL, GraZS2ZP
#if defined NEMUCSC
      real(r8) :: GraPL2ZS
#endif
      real(r8) :: EgeZL, EgeZP, EgeZS
      real(r8) :: ExcZL, ExcZP, ExcZS
#ifdef N15
      real(r8) :: GraPL2ZL15, GraPL2ZP15, GraPS2ZL15, GraPS2ZS15
      real(r8) :: GraZL2ZP15, GraZS2ZL15, GraZS2ZP15
      real(r8) :: gamma_exc
# if defined NEMUCSC
      real(r8) :: GraPL2ZS15
# endif
      real(r8) :: EgeZL15, EgeZP15, EgeZS15
      real(r8) :: ExcZL15, ExcZP15, ExcZS15, ExcZ15
#endif
#ifdef NEM_IRON_LIMIT
      real(r8) :: cffFe
      real(r8), parameter :: MinVal = 1.0e-6_r8
#endif

      integer :: i, k 
      integer, parameter :: itemp = 1 
! instead of #include "set_bounds.h"
      integer :: Istr, Iend
      Istr   =BOUNDS(ng) % Istr   (tile)
      Iend   =BOUNDS(ng) % Iend   (tile)
!
!-----------------------------------------------------------------------
!  Zooplankton grazing, egestion and excretion.
!-----------------------------------------------------------------------

#if defined IVLEV_EXPLICIT
!
!  The rate of grazing by the zooplankton is modeled using an Ivlev
!  equation with a feeding threshold using an explicit (non-conserving)
!  algorithm to the original formulation. Notice that term is forced to
!  be positive using a MAX function.
!
#elif defined HOLLING_GRAZING
!
!  The rate of grazing by the zooplankton is modeled using a Holling-
!  type s-shaped curve. It is known to be numerically more stable and
!  allows an implicit discretization.
!
!    P(new) = P(old) - dt*mu*[P(old)/(Kp + P(old)^2)]*P(new)*Z(old)
!
!  The implicit grazing term is then:
!
!    P(new) = P(old) / (1 + G)
!
!  were the grazing rate, G, is:
!
!    G = dt * mu * [P(old)/(Kp + P(old)^2)] * Z(old)
!
#else
# define IVLEV_IMPLICIT
!
!  The rate of grazing by the zooplankton is modeled using an Ivlev
!  equation with a feeding threshold. An implicit algorithm is
!  achieved by multiplying grazing term by a unity factor, alpha:
!
!    alpha = 1 = P(new)/(P(old)+deltaP)
!
!  where
!
!    deltaP = P(new) - P(old) = - dt*mu*[1-EXP(lambda*P(old))]
!
!  The factor alpha can be approximated using Taylor series to:
!
!    alpha = [P(new) / P(old)] * [1 - deltaP/P(old)]
!
!  The discretized grazing term is then:
!
!    P(new) = P(old) - dt*mu*[1-EXP(lambda*P)] * alpha * Z(old)
!
!  Which can be approximated with an implicit algorithm to:
!
!    P(new) = P(old) / (1 + G)
!
!  were the grazing rate, G, is:
!
!    G = [1 + P(old)/(dt*mu*(1 - EXP(lambda*P(old))))] * Z(old)
!
#endif
          fac1=new_dtdays(ng)*GRmaxSps(ng)
          fac2=new_dtdays(ng)*GRmaxLps(ng)
          fac3=new_dtdays(ng)*GRmaxLpl(ng)
          fac4=new_dtdays(ng)*GRmaxLzs(ng)
          fac5=new_dtdays(ng)*GRmaxPpl(ng)
          fac6=new_dtdays(ng)*GRmaxPzs(ng)
          fac7=new_dtdays(ng)*GRmaxPzl(ng)
#if defined NEMUCSC
          fac8=new_dtdays(ng)*GRmaxSpl(ng)
#endif
          DO k=1,N(ng)
            DO i=Istr,Iend
!
!  Temperature-dependent term (Q10).
!
              cff1=EXP(KGraS(ng)*Bio(i,k,itemp))
              cff2=EXP(KGraL(ng)*Bio(i,k,itemp))
              cff3=EXP(KGraP(ng)*Bio(i,k,itemp))
# if defined TANGENT || defined ADJOINT
!
!  First save the initial Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iSphy,1)=Bio(i,k,iSphy)
                BS(i,k,iSzoo,1)=Bio(i,k,iSzoo)
              END IF
# endif
!
!  Small Zooplankton grazing on Small Phytoplankton, GraPS2ZS.
!
#if defined IVLEV_EXPLICIT
              cff4=1.0_r8-EXP(LamS(ng)*(PS2ZSstar(ng)-Bio(i,k,iSphy)))
              GraPS2ZS=fac1*cff1*MAX(0.0_r8,cff4)*Bio(i,k,iSzoo)
# if defined LOWER_LIM
              IF (Bio(i,k,iSphy).LE.1.0e-6_r8) THEN
                GraPS2ZS=0.0_r8
              ENDIF
# endif
# if defined N15
              IF (Bio(i,k,iSphy).GT.0.0_r8) THEN
                GraPS2ZS15=GraPS2ZS*(Bio(i,k,iSphy15)/Bio(i,k,iSphy))
              ELSE
                GraPS2ZS15=0.0_r8
              ENDIF
# endif
              Bio(i,k,iSphy)=Bio(i,k,iSphy)-GraPS2ZS
              Bio(i,k,iSzoo)=Bio(i,k,iSzoo)+GraPS2ZS
# if defined N15
              Bio(i,k,iSphy15)=Bio(i,k,iSphy15)-GraPS2ZS15
              Bio(i,k,iSzoo15)=Bio(i,k,iSzoo15)+GraPS2ZS15
              Bio(i,k,iSphy14)=Bio(i,k,iSphy)-Bio(i,k,iSphy15)
              Bio(i,k,iSzoo14)=Bio(i,k,iSzoo)-Bio(i,k,iSzoo15)
# endif
#else
# ifdef HOLLING_GRAZING
              cff4=1.0_r8/(KPS2ZS(ng)+Bio(i,k,iSphy)*Bio(i,k,iSphy))
              cff=fac1*cff1*cff4*Bio(i,k,iSzoo)*Bio(i,k,iSphy)
# elif defined IVLEV_IMPLICIT
              cff4=1.0_r8-EXP(LamS(ng)*(PS2ZSstar(ng)-Bio(i,k,iSphy)))
              cff5=1.0_r8/(fac1*cff4)
              cff=(1.0_r8+Bio(i,k,iSphy)*cff5)*cff1*Bio(i,k,iSzoo)
# endif
# if defined LOWER_LIM
              IF (Bio(i,k,iSphy).LE.1.0e-6_r8) THEN
                cff=0.0_r8
              ENDIF
# endif
              Bio(i,k,iSphy)=Bio(i,k,iSphy)/(1.0_r8+cff)
              GraPS2ZS=cff*Bio(i,k,iSphy)
              Bio(i,k,iSzoo)=Bio(i,k,iSzoo)+GraPS2ZS
# if defined N15
              Bio(i,k,iSphy15)=Bio(i,k,iSphy15)/(1.0_r8+cff)
              Bio(i,k,iSzoo15)=Bio(i,k,iSzoo15)+(cff*Bio(i,k,iSphy15))
              Bio(i,k,iSphy14)=Bio(i,k,iSphy)-Bio(i,k,iSphy15)
              Bio(i,k,iSzoo14)=Bio(i,k,iSzoo)-Bio(i,k,iSzoo15)
# endif
#endif
# ifdef NEM_IRON_LIMIT
!     Grazing Fe terms
              cffFe=GraPS2ZS*Bio(i,k,iFeSp)/MAX(MinVal,Bio(i,k,iSphy))
              Bio(i,k,iFeSp)=Bio(i,k,iFeSp)-cffFe
              Bio(i,k,iFeD_)=Bio(i,k,iFeD_)+cffFe*FeRR(ng)
# endif
#if defined DIAGNOSTICS_BIO
# if defined DIAGNOSTICS_NEM_PHY || defined DIAGNOSTICS_NEM_ZOO
              DiaBio3dJ(i,k,iGraPS2ZS)=DiaBio3dJ(i,k,iGraPS2ZS) +       &
     &                                  GraPS2ZS
# endif
#endif
#if defined NEMUCSC
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iLphy,6)=Bio(i,k,iLphy)
                BS(i,k,iSzoo,6)=Bio(i,k,iSzoo)
              END IF
# endif
!
!  Small Zooplankton grazing on Large Phytoplankton, GraPL2ZS.
!
# if defined IVLEV_EXPLICIT
              cff4=1.0_r8-EXP(LamL(ng)*(PL2ZSstar(ng)-Bio(i,k,iLphy)))
              GraPL2ZS=fac8*cff2*MAX(0.0_r8,cff4)*Bio(i,k,iSzoo)
# if defined LOWER_LIM
              IF (Bio(i,k,iLphy).LE.1.0e-6_r8) THEN
                GraPL2ZS=0.0_r8
              ENDIF
# endif
#  if defined N15
              IF (Bio(i,k,iLphy).GT.0.0_r8) THEN
                GraPL2ZS15=GraPL2ZS*(Bio(i,k,iLphy15)/Bio(i,k,iLphy))
              ELSE
                GraPL2ZS15=0.0_r8
              ENDIF
#  endif
              Bio(i,k,iLphy)=Bio(i,k,iLphy)-GraPL2ZS
              Bio(i,k,iSzoo)=Bio(i,k,iSzoo)+GraPL2ZS
#  if defined N15
              Bio(i,k,iLphy15)=Bio(i,k,iLphy15)-GraPL2ZS15
              Bio(i,k,iSzoo15)=Bio(i,k,iSzoo15)+GraPL2ZS15
              Bio(i,k,iLphy14)=Bio(i,k,iLphy)-Bio(i,k,iLphy15)
              Bio(i,k,iSzoo14)=Bio(i,k,iSzoo)-Bio(i,k,iSzoo15)
#  endif

# else
#  ifdef HOLLING_GRAZING
              cff4=1.0_r8/(KPL2ZS(ng)+Bio(i,k,iLphy)*Bio(i,k,iLphy))
              cff=fac8*cff2*cff4*Bio(i,k,iSzoo)*Bio(i,k,iLphy)
#  elif defined IVLEV_IMPLICIT
              cff4=1.0_r8-EXP(LamL(ng)*(PL2ZSstar(ng)-Bio(i,k,iLphy)))
              cff5=1.0_r8/(fac8*cff4)
              cff=(1.0_r8+Bio(i,k,iLphy)*cff5)*cff2*Bio(i,k,iSzoo)
#  endif
# if defined LOWER_LIM
              IF (Bio(i,k,iLphy).LE.1.0e-6_r8) THEN
                cff=0.0_r8
              ENDIF
# endif
              Bio(i,k,iLphy)=Bio(i,k,iLphy)/(1.0_r8+cff)
              GraPL2ZS=cff*Bio(i,k,iLphy)
              Bio(i,k,iSzoo)=Bio(i,k,iSzoo)+GraPL2ZS
#  if defined N15
              Bio(i,k,iLphy15)=Bio(i,k,iLphy15)/(1.0_r8+cff)
              Bio(i,k,iSzoo15)=Bio(i,k,iSzoo15)+(cff*Bio(i,k,iLphy15))
              Bio(i,k,iLphy14)=Bio(i,k,iLphy)-Bio(i,k,iLphy15)
              Bio(i,k,iSzoo14)=Bio(i,k,iSzoo)-Bio(i,k,iSzoo15)
#  endif
# endif
# ifdef NEM_IRON_LIMIT
!     Grazing Fe terms
              cffFe=GraPL2ZS*Bio(i,k,iFeLp)/MAX(MinVal,Bio(i,k,iLphy))
              Bio(i,k,iFeLp)=Bio(i,k,iFeLp)-cffFe
              Bio(i,k,iFeD_)=Bio(i,k,iFeD_)+cffFe*FeRR(ng)
# endif
# ifdef DIAGNOSTICS_BIO
#  if defined DIAGNOSTICS_NEM_PHY || defined DIAGNOSTICS_NEM_ZOO
              DiaBio3dJ(i,k,iGraPL2ZS)=DiaBio3dJ(i,k,iGraPL2ZS) +       &
     &                                  GraPL2ZS
#  endif
# endif
#endif
!
!  Large Zooplankton grazing on Small Phytoplankton, GraPS2ZL.
!
# if defined TANGENT || defined ADJOINT
!
!  First save the initial Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iSphy,2)=Bio(i,k,iSphy)
                BS(i,k,iSzoo,2)=Bio(i,k,iSzoo)
                BS(i,k,iLzoo,1)=Bio(i,k,iLzoo)
              END IF
#endif
#if defined IVLEV_EXPLICIT
              cff4=1.0_r8-EXP(LamL(ng)*(PS2ZLstar(ng)-Bio(i,k,iSphy)))
              GraPS2ZL=fac2*cff2*MAX(0.0_r8,cff4)*Bio(i,k,iLzoo)
# if defined LOWER_LIM
              IF (Bio(i,k,iSphy).LE.1.0e-6_r8) THEN
                GraPS2ZL=0.0_r8
              ENDIF
# endif
# if defined N15
              IF (Bio(i,k,iSphy).GT.0.0_r8) THEN
                GraPS2ZL15=GraPS2ZL*(Bio(i,k,iSphy15)/Bio(i,k,iSphy))
              ELSE
                GraPS2ZL15=0.0_r8
              ENDIF
# endif
              Bio(i,k,iSphy)=Bio(i,k,iSphy)-GraPS2ZL
              Bio(i,k,iLzoo)=Bio(i,k,iLzoo)+GraPS2ZL
# if defined N15
              Bio(i,k,iSphy15)=Bio(i,k,iSphy15)-GraPS2ZL15
              Bio(i,k,iLzoo15)=Bio(i,k,iLzoo15)+GraPS2ZL15
              Bio(i,k,iSphy14)=Bio(i,k,iSphy)-Bio(i,k,iSphy15)
              Bio(i,k,iLzoo14)=Bio(i,k,iLzoo)-Bio(i,k,iLzoo15)
# endif
#else
# ifdef HOLLING_GRAZING
              cff4=1.0_r8/(KPS2ZL(ng)+Bio(i,k,iSphy)*Bio(i,k,iSphy))
              cff=fac2*cff2*cff4*Bio(i,k,iLzoo)*Bio(i,k,iSphy)
# elif defined IVLEV_IMPLICIT
              cff4=1.0_r8-EXP(LamL(ng)*(PS2ZLstar(ng)-Bio(i,k,iSphy)))
              cff5=1.0_r8/(fac2*cff4)
              cff=(1.0_r8+Bio(i,k,iSphy)*cff5)*cff2*Bio(i,k,iLzoo)
# endif
# if defined LOWER_LIM
              IF (Bio(i,k,iSphy).LE.1.0e-6_r8) THEN
                cff=0.0_r8
              ENDIF
# endif
              Bio(i,k,iSphy)=Bio(i,k,iSphy)/(1.0_r8+cff)
              GraPS2ZL=cff*Bio(i,k,iSphy)
              Bio(i,k,iLzoo)=Bio(i,k,iLzoo)+GraPS2ZL
# if defined N15
              Bio(i,k,iSphy15)=Bio(i,k,iSphy15)/(1.0_r8+cff)
              Bio(i,k,iLzoo15)=Bio(i,k,iLzoo15)+(cff*Bio(i,k,iSphy15))
              Bio(i,k,iSphy14)=Bio(i,k,iSphy)-Bio(i,k,iSphy15)
              Bio(i,k,iLzoo14)=Bio(i,k,iLzoo)-Bio(i,k,iLzoo15)
# endif
#endif
# ifdef NEM_IRON_LIMIT
!     Grazing Fe terms
              cffFe=GraPS2ZL*Bio(i,k,iFeSp)/MAX(MinVal,Bio(i,k,iSphy))
              Bio(i,k,iFeSp)=Bio(i,k,iFeSp)-cffFe
              Bio(i,k,iFeD_)=Bio(i,k,iFeD_)+cffFe*FeRR(ng)
# endif
#if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iSphy,3)=Bio(i,k,iSphy)
                BS(i,k,iLzoo,2)=Bio(i,k,iLzoo)
              END IF
#endif
!
!  Large Zooplankton grazing on Large Phytoplankton, GraPL2ZL.
!
# if defined TANGENT || defined ADJOINT
!
!  First save the initial Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iLphy,1)=Bio(i,k,iLphy)
              END IF
#endif
#if defined IVLEV_EXPLICIT
              cff4=1.0_r8-EXP(LamL(ng)*(PL2ZLstar(ng)-Bio(i,k,iLphy)))
              GraPL2ZL=fac3*cff2*MAX(0.0_r8,cff4)*Bio(i,k,iLzoo)
# if defined LOWER_LIM
              IF (Bio(i,k,iLphy).LE.1.0e-6_r8) THEN
                GraPL2ZL=0.0_r8
              ENDIF
# endif
# if defined N15
              IF (Bio(i,k,iLphy).GT.0.0_r8) THEN
                GraPL2ZL15=GraPL2ZL*(Bio(i,k,iLphy15)/Bio(i,k,iLphy))
              ELSE
                GraPL2ZL15=0.0_r8
              ENDIF
# endif
              Bio(i,k,iLphy)=Bio(i,k,iLphy)-GraPL2ZL
              Bio(i,k,iLzoo)=Bio(i,k,iLzoo)+GraPL2ZL
# if defined N15
              Bio(i,k,iLphy15)=Bio(i,k,iLphy15)-GraPL2ZL15
              Bio(i,k,iLzoo15)=Bio(i,k,iLzoo15)+GraPL2ZL15
              Bio(i,k,iLphy14)=Bio(i,k,iLphy)-Bio(i,k,iLphy15)
              Bio(i,k,iLzoo14)=Bio(i,k,iLzoo)-Bio(i,k,iLzoo15)
# endif
#else
# ifdef HOLLING_GRAZING
              cff4=1.0_r8/(KPL2ZL(ng)+Bio(i,k,iLphy)*Bio(i,k,iLphy))
              cff=fac3*cff2*cff4*Bio(i,k,iLzoo)*Bio(i,k,iLphy)
# elif defined IVLEV_IMPLICIT
              cff4=1.0_r8-EXP(LamL(ng)*(PL2ZLstar(ng)-Bio(i,k,iLphy)))
              cff5=1.0_r8/(fac3*cff4)
              cff=(1.0_r8+Bio(i,k,iLphy)*cff5)*cff2*Bio(i,k,iLzoo)
# endif
# if defined LOWER_LIM
              IF (Bio(i,k,iLphy).LE.1.0e-6_r8) THEN
                cff=0.0_r8
              ENDIF
# endif
              Bio(i,k,iLphy)=Bio(i,k,iLphy)/(1.0_r8+cff)
              GraPL2ZL=cff*Bio(i,k,iLphy)
              Bio(i,k,iLzoo)=Bio(i,k,iLzoo)+GraPL2ZL
# if defined N15
              Bio(i,k,iLphy15)=Bio(i,k,iLphy15)/(1.0_r8+cff)
              Bio(i,k,iLzoo15)=Bio(i,k,iLzoo15)+(cff*Bio(i,k,iLphy15))
              Bio(i,k,iLphy14)=Bio(i,k,iLphy)-Bio(i,k,iLphy15)
              Bio(i,k,iLzoo14)=Bio(i,k,iLzoo)-Bio(i,k,iLzoo15)
# endif
#endif
# ifdef NEM_IRON_LIMIT
!     Grazing Fe terms
              cffFe=GraPL2ZL*Bio(i,k,iFeLp)/MAX(MinVal,Bio(i,k,iLphy))
              Bio(i,k,iFeLp)=Bio(i,k,iFeLp)-cffFe
              Bio(i,k,iFeD_)=Bio(i,k,iFeD_)+cffFe*FeRR(ng)
# endif
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iLphy,2)=Bio(i,k,iLphy)
                BS(i,k,iLzoo,3)=Bio(i,k,iLzoo)
              END IF
#endif
#if defined DIAGNOSTICS_BIO
# if defined DIAGNOSTICS_NEM_PHY || defined DIAGNOSTICS_NEM_ZOO
              DiaBio3dJ(i,k,iGraPL2ZL)=DiaBio3dJ(i,k,iGraPL2ZL) +       &
     &                                  GraPL2ZL
# endif
#endif
!
!  Large Zooplankton grazing on Small Zooplankton, GraZS2ZL.
!
#if defined IVLEV_EXPLICIT
              cff4=1.0_r8-EXP(LamL(ng)*(ZS2ZLstar(ng)-Bio(i,k,iSzoo)))
              GraZS2ZL=fac4*cff2*MAX(0.0_r8,cff4)*Bio(i,k,iLzoo)
# if defined LOWER_LIM
              IF (Bio(i,k,iSzoo).LE.1.0e-6_r8) THEN
                GraZS2ZL=0.0_r8
              ENDIF
# endif
# if defined N15
              IF (Bio(i,k,iSzoo).GT.0.0_r8) THEN
                GraZS2ZL15=GraZS2ZL*(Bio(i,k,iSzoo15)/Bio(i,k,iSzoo))
              ELSE
                GraZS2ZL15=0.0_r8
              ENDIF
# endif
              Bio(i,k,iSzoo)=Bio(i,k,iSzoo)-GraZS2ZL
              Bio(i,k,iLzoo)=Bio(i,k,iLzoo)+GraZS2ZL
# if defined N15
              Bio(i,k,iSzoo15)=Bio(i,k,iSzoo15)-GraZS2ZL15
              Bio(i,k,iLzoo15)=Bio(i,k,iLzoo15)+GraZS2ZL15
              Bio(i,k,iSzoo14)=Bio(i,k,iSzoo)-Bio(i,k,iSzoo15)
              Bio(i,k,iLzoo14)=Bio(i,k,iLzoo)-Bio(i,k,iLzoo15)
# endif
#else
# ifdef HOLLING_GRAZING
              cff4=1.0_r8/(KZS2ZL(ng)+Bio(i,k,iSzoo)*Bio(i,k,iSzoo))
              cff=fac4*cff2*cff4*Bio(i,k,iLzoo)*Bio(i,k,iSzoo)
# elif defined IVLEV_IMPLICIT
              cff4=1.0_r8-EXP(LamL(ng)*(ZS2ZLstar(ng)-Bio(i,k,iSzoo)))
              cff5=1.0_r8/(fac4*cff4)
              cff=(1.0_r8+Bio(i,k,iSphy)*cff5)*cff2*Bio(i,k,iLzoo)
# endif
# if defined LOWER_LIM
              IF (Bio(i,k,iSzoo).LE.1.0e-6_r8) THEN
                cff=0.0_r8
              ENDIF
# endif
              Bio(i,k,iSzoo)=Bio(i,k,iSzoo)/(1.0_r8+cff)
              GraZS2ZL=cff*Bio(i,k,iSzoo)
              Bio(i,k,iLzoo)=Bio(i,k,iLzoo)+GraZS2ZL
# if defined N15
              Bio(i,k,iSzoo15)=Bio(i,k,iSzoo15)/(1.0_r8+cff)
              Bio(i,k,iLzoo15)=Bio(i,k,iLzoo15)+(cff*Bio(i,k,iSzoo15))
              Bio(i,k,iSzoo14)=Bio(i,k,iSzoo)-Bio(i,k,iSzoo15)
              Bio(i,k,iLzoo14)=Bio(i,k,iLzoo)-Bio(i,k,iSzoo15)
# endif
#endif
#if defined TANGENT || defined ADJOINT
# ifdef  NEM_IRON_LIMIT
         CAE error here.  TL & ADJ code not written for NEM_IRON_LIMIT
# endif
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iSzoo,3)=Bio(i,k,iSzoo)
                BS(i,k,iLzoo,4)=Bio(i,k,iLzoo)
              END IF
#endif
#if defined DIAGNOSTICS_BIO
# if defined DIAGNOSTICS_NEM_ZOO
              DiaBio3dJ(i,k,iGraZS2ZL)=DiaBio3dJ(i,k,iGraZS2ZL) +       &
     &                                  GraZS2ZL
# endif
#endif
!
!  Predator Zooplankton grazing on Large Phytoplankton, GraPL2ZP.
!
# if defined TANGENT || defined ADJOINT
!
!  First save the initial Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iPzoo,1)=Bio(i,k,iPzoo)
              END IF
#endif
#if defined IVLEV_EXPLICIT
              cff4=1.0_r8-EXP(LamP(ng)*(PL2ZPstar(ng)-Bio(i,k,iLphy)))
              cff5=EXP(-PusaiPL(ng)*(Bio(i,k,iLzoo)+Bio(i,k,iSzoo)))
              GraPL2ZP=fac5*cff3*cff5*MAX(0.0_r8,cff4)*Bio(i,k,iPzoo)
# if defined LOWER_LIM
              IF (Bio(i,k,iLphy).LE.1.0e-6_r8) THEN
                GraPL2ZP=0.0_r8
              ENDIF
# endif
# if defined N15
              IF (Bio(i,k,iLphy).GT.0.0_r8) THEN
                GraPL2ZP15=GraPL2ZP*(Bio(i,k,iLphy15)/Bio(i,k,iLphy))
              ELSE
                GraPL2ZP15=0.0_r8
              ENDIF
# endif
              Bio(i,k,iLphy)=Bio(i,k,iLphy)-GraPL2ZP
              Bio(i,k,iPzoo)=Bio(i,k,iPzoo)+GraPL2ZP
# if defined N15
              Bio(i,k,iLphy15)=Bio(i,k,iLphy15)-GraPL2ZP15
              Bio(i,k,iPzoo15)=Bio(i,k,iPzoo15)+GraPL2ZP15
              Bio(i,k,iLphy14)=Bio(i,k,iLphy)-Bio(i,k,iLphy15)
              Bio(i,k,iPzoo14)=Bio(i,k,iPzoo)-Bio(i,k,iPzoo15)
# endif
#else
# ifdef HOLLING_GRAZING
              cff4=1.0_r8/(KPL2ZP(ng)+Bio(i,k,iLphy)*Bio(i,k,iLphy))
              cff5=EXP(-PusaiPL(ng)*(Bio(i,k,iLzoo)+Bio(i,k,iSzoo)))
              cff=fac5*cff3*cff4*cff5*Bio(i,k,iPzoo)*Bio(i,k,iLphy)
# elif defined IVLEV_IMPLICIT
              cff4=1.0_r8-EXP(LamP(ng)*(PL2ZPstar(ng)-Bio(i,k,iLphy)))
              cff5=EXP(-PusaiPL(ng)*(Bio(i,k,iLzoo)+Bio(i,k,iSzoo)))
              cff6=1.0_r8/(fac5*cff4)
              cff=(1.0_r8+Bio(i,k,iLphy)*cff6)*cff3*cff5*Bio(i,k,iPzoo)
# endif
# if defined LOWER_LIM
              IF (Bio(i,k,iLphy).LE.1.0e-6_r8) THEN
                cff=0.0_r8
              ENDIF
# endif
              Bio(i,k,iLphy)=Bio(i,k,iLphy)/(1.0_r8+cff)
              GraPL2ZP=cff*Bio(i,k,iLphy)
              Bio(i,k,iPzoo)=Bio(i,k,iPzoo)+GraPL2ZP
# if defined N15
              Bio(i,k,iLphy15)=Bio(i,k,iLphy15)/(1.0_r8+cff)
              Bio(i,k,iPzoo15)=Bio(i,k,iPzoo15)+(cff*Bio(i,k,iLphy15))
              Bio(i,k,iLphy14)=Bio(i,k,iLphy)-Bio(i,k,iLphy15)
              Bio(i,k,iPzoo14)=Bio(i,k,iPzoo)-Bio(i,k,iPzoo15)
# endif
#endif
# ifdef NEM_IRON_LIMIT
!     Grazing Fe terms
              cffFe=GraPL2ZP*Bio(i,k,iFeLp)/MAX(MinVal,Bio(i,k,iLphy))
              Bio(i,k,iFeLp)=Bio(i,k,iFeLp)-cffFe
              Bio(i,k,iFeD_)=Bio(i,k,iFeD_)+cffFe*FeRR(ng)
# endif
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iLphy,3)=Bio(i,k,iLphy)
                BS(i,k,iPzoo,2)=Bio(i,k,iPzoo)
              END IF
#endif
#if defined DIAGNOSTICS_BIO
# if defined DIAGNOSTICS_NEM_PHY || defined DIAGNOSTICS_NEM_ZOO
              DiaBio3dJ(i,k,iGraPL2ZP)=DiaBio3dJ(i,k,iGraPL2ZP) +       &
     &                                  GraPL2ZP
# endif
#endif
!
!  Predatory Zooplankton grazing on Small Zooplankton, GraZS2ZP.
!
#if defined IVLEV_EXPLICIT
              cff4=1.0_r8-EXP(LamP(ng)*(ZS2ZPstar(ng)-Bio(i,k,iSzoo)))
              cff5=EXP(-PusaiZS(ng)*Bio(i,k,iLzoo))
              GraZS2ZP=fac6*cff3*cff5*MAX(0.0_r8,cff4)*Bio(i,k,iPzoo)
# if defined LOWER_LIM
              IF (Bio(i,k,iSzoo).LE.1.0e-6_r8) THEN
                GraZS2ZP=0.0_r8
              ENDIF
# endif
# if defined N15
              IF (Bio(i,k,iSzoo).GT.0.0_r8) THEN
                GraZS2ZP15=GraZS2ZP*(Bio(i,k,iSzoo15)/Bio(i,k,iSzoo))
              ELSE
                GraZS2ZP15=0.0_r8
              ENDIF
# endif
              Bio(i,k,iSzoo)=Bio(i,k,iSzoo)-GraZS2ZP
              Bio(i,k,iPzoo)=Bio(i,k,iPzoo)+GraZS2ZP
# if defined N15
              Bio(i,k,iSzoo15)=Bio(i,k,iSzoo15)-GraZS2ZP15
              Bio(i,k,iPzoo15)=Bio(i,k,iPzoo15)+GraZS2ZP15
              Bio(i,k,iSzoo14)=Bio(i,k,iSzoo)-Bio(i,k,iSzoo15)
              Bio(i,k,iPzoo14)=Bio(i,k,iPzoo)-Bio(i,k,iPzoo15)
# endif
#else
# ifdef HOLLING_GRAZING
              cff4=1.0_r8/(KZS2ZP(ng)+Bio(i,k,iSzoo)*Bio(i,k,iSzoo))
              cff5=EXP(-PusaiZS(ng)*Bio(i,k,iLzoo))
              cff=fac6*cff3*cff4*cff5*Bio(i,k,iPzoo)*Bio(i,k,iSzoo)
# elif defined IVLEV_IMPLICIT
              cff4=1.0_r8-EXP(LamP(ng)*(ZS2ZPstar(ng)-Bio(i,k,iSzoo)))
              cff5=EXP(-PusaiZS(ng)*Bio(i,k,iLzoo))
              cff6=1.0_r8/(fac6*cff4)
              cff=(1.0_r8+Bio(i,k,iSzoo)*cff6)*cff3*cff5*Bio(i,k,iPzoo)
# endif
# if defined LOWER_LIM
              IF (Bio(i,k,iSzoo).LE.1.0e-6_r8) THEN
                cff=0.0_r8
              ENDIF
# endif
              Bio(i,k,iSzoo)=Bio(i,k,iSzoo)/(1.0_r8+cff)
              GraZS2ZP=cff*Bio(i,k,iSzoo)
              Bio(i,k,iPzoo)=Bio(i,k,iPzoo)+GraZS2ZP
# if defined N15
              Bio(i,k,iSzoo15)=Bio(i,k,iSzoo15)/(1.0_r8+cff)
              Bio(i,k,iPzoo15)=Bio(i,k,iPzoo15)+(cff*Bio(i,k,iSzoo15))
              Bio(i,k,iSzoo14)=Bio(i,k,iSzoo)-Bio(i,k,iSzoo15)
              Bio(i,k,iPzoo14)=Bio(i,k,iPzoo)-Bio(i,k,iPzoo15)
# endif
#endif
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iSzoo,4)=Bio(i,k,iSzoo)
                BS(i,k,iPzoo,3)=Bio(i,k,iPzoo)
              END IF
#endif
#if defined DIAGNOSTICS_BIO
# if defined DIAGNOSTICS_NEM_ZOO
              DiaBio3dJ(i,k,iGraZS2ZP)=DiaBio3dJ(i,k,iGraZS2ZP) +       &
     &                                  GraZS2ZP
# endif
#endif
!
!  Predatory Zooplankton grazing on Large Zooplankton, GraZL2ZP.
!
#if defined IVLEV_EXPLICIT
              cff4=1.0_r8-EXP(LamP(ng)*(ZL2ZPstar(ng)-Bio(i,k,iLzoo)))
              GraZL2ZP=fac7*cff3*MAX(0.0_r8,cff4)*Bio(i,k,iPzoo)
# if defined LOWER_LIM
              IF (Bio(i,k,iLzoo).LE.1.0e-6_r8) THEN
                GraZL2ZP=0.0_r8
              ENDIF
# endif
# if defined N15
              IF (Bio(i,k,iLzoo).GT.0.0_r8) THEN
                GraZL2ZP15=GraZL2ZP*(Bio(i,k,iLzoo15)/Bio(i,k,iLzoo))
              ELSE
                GraZL2ZP15=0.0_r8
              ENDIF
# endif
              Bio(i,k,iLzoo)=Bio(i,k,iLzoo)-GraZL2ZP
              Bio(i,k,iPzoo)=Bio(i,k,iPzoo)+GraZL2ZP
# if defined N15
              Bio(i,k,iLzoo15)=Bio(i,k,iLzoo15)-GraZL2ZP15
              Bio(i,k,iPzoo15)=Bio(i,k,iPzoo15)+GraZL2ZP15
              Bio(i,k,iLzoo14)=Bio(i,k,iLzoo)-Bio(i,k,iLzoo15)
              Bio(i,k,iPzoo14)=Bio(i,k,iPzoo)-Bio(i,k,iPzoo15)
# endif
#else
# ifdef HOLLING_GRAZING
              cff4=1.0_r8/(KZL2ZP(ng)+Bio(i,k,iLzoo)*Bio(i,k,iLzoo))
              cff=fac7*cff3*cff4*Bio(i,k,iPzoo)*Bio(i,k,iLzoo)
# elif defined IVLEV_IMPLICIT
              cff4=1.0_r8-EXP(LamP(ng)*(ZL2ZPstar(ng)-Bio(i,k,iLzoo)))
              cff5=1.0_r8/(fac7*cff4)
              cff=(1.0_r8+Bio(i,k,iLzoo)*cff5)*cff3*Bio(i,k,iPzoo)
# endif
# if defined LOWER_LIM
              IF (Bio(i,k,iLzoo).LE.1.0e-6_r8) THEN
                cff=0.0_r8
              ENDIF
# endif
              Bio(i,k,iLzoo)=Bio(i,k,iLzoo)/(1.0_r8+cff)
              GraZL2ZP=cff*Bio(i,k,iLzoo)
              Bio(i,k,iPzoo)=Bio(i,k,iPzoo)+GraZL2ZP
# if defined N15
              Bio(i,k,iLzoo15)=Bio(i,k,iLzoo15)/(1.0_r8+cff)
              Bio(i,k,iPzoo15)=Bio(i,k,iPzoo15)+(cff*Bio(i,k,iLzoo15))
              Bio(i,k,iLzoo14)=Bio(i,k,iLzoo)-Bio(i,k,iLzoo15)
              Bio(i,k,iPzoo14)=Bio(i,k,iPzoo)-Bio(i,k,iPzoo15)
# endif
#endif
#if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iLzoo,5)=Bio(i,k,iLzoo)
                BS(i,k,iPzoo,4)=Bio(i,k,iPzoo)
                BS(i,k,iPON_,1)=Bio(i,k,iPON_)
                BS(i,k,iopal,1)=Bio(i,k,iopal)
              END IF
#endif
#if defined DIAGNOSTICS_BIO
# if defined DIAGNOSTICS_NEM_ZOO
              DiaBio3dJ(i,k,iGraZL2ZP)=DiaBio3dJ(i,k,iGraZL2ZP) +       &
     &                                  GraZL2ZP
# endif
#endif
!
!  Zooplankton egestion to Particulate Organic Nitrogen (PON) and
!  Particulate Organic Silica (opal).
!
#if defined NEMUCSC
              EgeZS=(1.0_r8-AlphaZS(ng))*(GraPS2ZS+GraPL2ZS)
#else
              EgeZS=(1.0_r8-AlphaZS(ng))*GraPS2ZS
#endif
              EgeZL=(1.0_r8-AlphaZL(ng))*(GraPS2ZL+GraPL2ZL+GraZS2ZL)
              EgeZP=(1.0_r8-AlphaZP(ng))*(GraPL2ZP+GraZS2ZP+GraZL2ZP)
#if defined LOWER_LIM
              IF (Bio(i,k,iSzoo).LE.1.0e-6_r8) THEN
                EgeZS=0.0_r8
              ENDIF
              IF (Bio(i,k,iLzoo).LE.1.0e-6_r8) THEN
                EgeZL=0.0_r8
              ENDIF
              IF (Bio(i,k,iPzoo).LE.1.0e-6_r8) THEN
                EgeZP=0.0_r8
              ENDIF
#endif
#if defined N15
              IF (Bio(i,k,iSzoo).GT.0.0_r8) THEN
                EgeZS15=EgeZS*(Bio(i,k,iSzoo15)/Bio(i,k,iSzoo))
              ELSE
                EgeZS15=0.0_r8
              ENDIF
              IF (Bio(i,k,iLzoo).GT.0.0_r8) THEN
                EgeZL15=EgeZL*(Bio(i,k,iLzoo15)/Bio(i,k,iLzoo))
              ELSE
                EgeZL15=0.0_r8
              ENDIF
              IF (Bio(i,k,iPzoo).GT.0.0_r8) THEN
                EgeZP15=EgeZP*(Bio(i,k,iPzoo15)/Bio(i,k,iPzoo))
              ELSE
                EgeZP15=0.0_r8
              ENDIF
# endif
              Bio(i,k,iSzoo)=Bio(i,k,iSzoo)-EgeZS
              Bio(i,k,iLzoo)=Bio(i,k,iLzoo)-EgeZL
              Bio(i,k,iPzoo)=Bio(i,k,iPzoo)-EgeZP
              Bio(i,k,iPON_)=Bio(i,k,iPON_)+EgeZS+EgeZL+EgeZP
#if defined NEMUCSC
# if defined NEM_IRON_LIMIT && defined NEM_IRON_RSIN
              Bio(i,k,iopal)=Bio(i,k,iopal)+                            &
     &                       (GraPL2ZS+GraPL2ZL+GraPL2ZP)*LPSiN(i,k)
# else
              Bio(i,k,iopal)=Bio(i,k,iopal)+                            &
     &                       (GraPL2ZS+GraPL2ZL+GraPL2ZP)*RSiN(ng)
# endif
#else
# if defined NEM_IRON_LIMIT && defined NEM_IRON_RSIN
              Bio(i,k,iopal)=Bio(i,k,iopal)+(GraPL2ZL+GraPL2ZP)*LPSiN(i,k)
# else
              Bio(i,k,iopal)=Bio(i,k,iopal)+(GraPL2ZL+GraPL2ZP)*RSiN(ng)
# endif
#endif
#if defined N15
              Bio(i,k,iSzoo15)=Bio(i,k,iSzoo15)-EgeZS15
              Bio(i,k,iLzoo15)=Bio(i,k,iLzoo15)-EgeZL15
              Bio(i,k,iPzoo15)=Bio(i,k,iPzoo15)-EgeZP15
              Bio(i,k,iPON15_)=Bio(i,k,iPON15_)+EgeZS15+EgeZL15+EgeZP15

              Bio(i,k,iSzoo14)=Bio(i,k,iSzoo)-Bio(i,k,iSzoo15)
              Bio(i,k,iLzoo14)=Bio(i,k,iLzoo)-Bio(i,k,iLzoo15)
              Bio(i,k,iPzoo14)=Bio(i,k,iPzoo)-Bio(i,k,iPzoo15)
              Bio(i,k,iPON14_)=Bio(i,k,iPON_)-Bio(i,k,iPON15_)
#endif
#if defined DIAGNOSTICS_BIO
# if defined DIAGNOSTICS_NEM_ZOO || defined DIAGNOSTICS_NEM_NIT
              DiaBio3dJ(i,k,iEgeZS)=DiaBio3dJ(i,k,iEgeZS) + EgeZS
              DiaBio3dJ(i,k,iEgeZL)=DiaBio3dJ(i,k,iEgeZL) + EgeZL
              DiaBio3dJ(i,k,iEgeZP)=DiaBio3dJ(i,k,iEgeZP) + EgeZP
# endif
#endif
!
!  Zooplankton excretion to NH4.
!
#if defined NEMUCSC
              ExcZS=(AlphaZS(ng)-BetaZS(ng))*(GraPS2ZS+GraPL2ZS)
#else
              ExcZS=(AlphaZS(ng)-BetaZS(ng))*                           &
     &              GraPS2ZS
#endif
              ExcZL=(AlphaZL(ng)-BetaZL(ng))*                           &
     &              (GraPS2ZL+GraPL2ZL+GraZS2ZL)
              ExcZP=(AlphaZP(ng)-BetaZP(ng))*                           &
     &              (GraPL2ZP+GraZS2ZP+GraZL2ZP)
#if defined LOWER_LIM
              IF (Bio(i,k,iSzoo).LE.1.0e-6_r8) THEN
                ExcZS=0.0_r8
              ENDIF
              IF (Bio(i,k,iLzoo).LE.1.0e-6_r8) THEN
                ExcZL=0.0_r8
              ENDIF
              IF (Bio(i,k,iPzoo).LE.1.0e-6_r8) THEN
                ExcZP=0.0_r8
              ENDIF
#endif
              Bio(i,k,iSzoo)=Bio(i,k,iSzoo)-ExcZS
              Bio(i,k,iLzoo)=Bio(i,k,iLzoo)-ExcZL
              Bio(i,k,iPzoo)=Bio(i,k,iPzoo)-ExcZP
#if defined NEM_ZOOP_DON
! Change excretion from NH4 to DON, because excretion should go to DOC
              Bio(i,k,iDON_)=Bio(i,k,iDON_)+ExcZS+ExcZL+ExcZP
#else
              Bio(i,k,iNH4_)=Bio(i,k,iNH4_)+ExcZS+ExcZL+ExcZP
# if defined CARB
              ! RG added 
              Bio(i,k,iTAlk)=Bio(i,k,iTAlk)+ExcZS+ExcZL+ExcZP
# endif
#endif
#if defined N15
              gamma_exc=1.0_r8-(eps_exc(ng)/1000.0_r8)
              IF ((Bio(i,k,iSzoo).GT.0.0_r8) .AND.                    &
     &            (Bio(i,k,iSzoo15).GT.0.0_r8) .AND.                  &
     &            (Bio(i,k,iSzoo14).GT.0.0_r8)) THEN
                ExcZS15=ExcZS*(gamma_exc*(Bio(i,k,iSzoo15)            &
     &                  /Bio(i,k,iSzoo14)))/(1.0_r8+(gamma_exc*       &
                        (Bio(i,k,iSzoo15)/Bio(i,k,iSzoo14))))
              ELSE
                ExcZS15=0.0_r8
              ENDIF
              IF ((Bio(i,k,iLzoo).GT.0.0_r8) .AND.                    &
     &            (Bio(i,k,iLzoo15).GT.0.0_r8) .AND.                  &
     &            (Bio(i,k,iLzoo14).GT.0.0_r8)) THEN
                ExcZL15=ExcZL*(gamma_exc*(Bio(i,k,iLzoo15)            &
     &                  /Bio(i,k,iLzoo14)))/(1.0_r8+(gamma_exc*       &
     &                  (Bio(i,k,iLzoo15)/Bio(i,k,iLzoo14))))
              ELSE
                ExcZL15=0.0_r8
              ENDIF
              IF ((Bio(i,k,iPzoo).GT.0.0_r8) .AND.                    &
     &            (Bio(i,k,iPzoo15).GT.0.0_r8) .AND.                  &
     &            (Bio(i,k,iPzoo14).GT.0.0_r8)) THEN
                ExcZP15=ExcZP*(gamma_exc*(Bio(i,k,iPzoo15)            &
     &                  /Bio(i,k,iPzoo14)))/(1.0_r8+(gamma_exc*       &
     &                  (Bio(i,k,iPzoo15)/Bio(i,k,iPzoo14))))
              ELSE
                ExcZP15=0.0_r8
              ENDIF
              ExcZ15=ExcZS15+ExcZL15+ExcZP15
              Bio(i,k,iSzoo15)=Bio(i,k,iSzoo15)-ExcZS15
              Bio(i,k,iLzoo15)=Bio(i,k,iLzoo15)-ExcZL15
              Bio(i,k,iPzoo15)=Bio(i,k,iPzoo15)-ExcZP15
              Bio(i,k,iNH415_)=Bio(i,k,iNH415_)+ExcZ15
              Bio(i,k,iSzoo14)=Bio(i,k,iSzoo)-Bio(i,k,iSzoo15)
              Bio(i,k,iLzoo14)=Bio(i,k,iLzoo)-Bio(i,k,iLzoo15)
              Bio(i,k,iPzoo14)=Bio(i,k,iPzoo)-Bio(i,k,iPzoo15)
              Bio(i,k,iNH414_)=Bio(i,k,iNH4_)-Bio(i,k,iNH415_)
#endif

#if defined DIAGNOSTICS_BIO
# if defined DIAGNOSTICS_NEM_ZOO || defined DIAGNOSTICS_NEM_NIT
              DiaBio3dJ(i,k,iExcZS)=DiaBio3dJ(i,k,iExcZS) + ExcZS
              DiaBio3dJ(i,k,iExcZL)=DiaBio3dJ(i,k,iExcZL) + ExcZL
              DiaBio3dJ(i,k,iExcZP)=DiaBio3dJ(i,k,iExcZP) + ExcZP
# endif
#endif
#if defined OXY
!OX1.1.6
              Bio(i,k,iOxyg)=Bio(i,k,iOxyg)-rOxNH4*(ExcZS+ExcZL+ExcZP)
#endif
#if defined CARB & ! defined KO05
!C1.1.5
              Bio(i,k,iTIC_)=Bio(i,k,iTIC_)+RedCN(ng)*                  &
     &                                      (ExcZS+ExcZL+ExcZP)
#endif
#if defined ISO
              ticik=Bio(i,k,iTIC_)
              di13c = Bio(i,k,iDI13C)
              di14c = Bio(i,k,iDI14C)
              di12c = ticik - di13c - di14c
! to prevent division by zero
              if (ticik > 0.0_r8) then
                  R13C_DICik= di13c / ticik
                  R14C_DICik= di14c / ticik
              else
                  R13C_DICik = 1.0_r8 ! since tracer is scaled, 1 means R13C_DICik = R13C_std
                  R14C_DICik = 1.0_r8 ! since tracer is scaled, 1 means R14C_DICik = R14C_std
              endif
              R13C_org = R13C_DICik * alpha_org
              R14C_org = R14C_DICik * alpha_org 
#endif
#if defined ISO & ! defined KO05
!C1.1.5
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)+RedCN(ng)*               &
     &                        (ExcZS+ExcZL+ExcZP)*R13C_org
              Bio(i,k,iDI14C)=Bio(i,k,iDI14C)+RedCN(ng)*               &
     &                        (ExcZS+ExcZL+ExcZP)*R14C_org
#endif
#if defined ISO_13C
              ticik=Bio(i,k,iTIC_)
              di13c = Bio(i,k,iDI13C)
! to prevent division by zero
              if (ticik > 0.0_r8) then
                  R13C_DICik= di13c / ticik
              else
                  R13C_DICik=0.0112372_r8
              endif
              R13C_org = R13C_DICik * alpha_org
#endif
#if defined ISO_13C & ! defined KO05
!C1.1.5
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)+RedCN(ng)*               &
     &                        (ExcZS+ExcZL+ExcZP)*R13C_org
#endif
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iSzoo,5)=Bio(i,k,iSzoo)
                BS(i,k,iLzoo,6)=Bio(i,k,iLzoo)
                BS(i,k,iPzoo,5)=Bio(i,k,iPzoo)
                BS(i,k,iopal,2)=Bio(i,k,iopal)
              END IF
#endif
            END DO
          END DO
      RETURN
      END SUBROUTINE zooplankton_grazing
!
!
!
      SUBROUTINE zooplankton_mortality(tile, ng, IminS, ImaxS, Bio      &
# if defined TANGENT || defined ADJOINT
     &                                 , BS                             &
# endif
#if defined DIAGNOSTICS_BIO
     &                                 , DiaBio3dJ                      &
#endif
     &                                 )
!
      USE mod_param
      USE mod_biology

!
!  Imported variable declarations.
!
      integer, intent(in) :: tile, ng, IminS, ImaxS
      real(r8),intent(inout),dimension(IminS:ImaxS,N(ng),NT(ng)) :: Bio
# if defined TANGENT || defined ADJOINT
      real(r8),intent(inout),optional,                                  &
     &  dimension(IminS:ImaxS,N(ng),3:NT(ng),1:6) :: BS
# endif
# ifdef DIAGNOSTICS_BIO
      real(r8), intent(inout) :: DiaBio3dJ(IminS:ImaxS,N(ng),NDbio3d)
# endif
!
!  Local variable declarations
!
      real(r8) :: cff1, cff2, cff3
      real(r8) :: fac1, fac2, fac3

      integer :: i, k 
      integer, parameter :: itemp = 1 
! instead of #include "set_bounds.h"
      integer :: Istr, Iend
      Istr   =BOUNDS(ng) % Istr   (tile)
      Iend   =BOUNDS(ng) % Iend   (tile)
!
!-----------------------------------------------------------------------
!  Zooplankton mortality to particulate organic nitrogen.
!-----------------------------------------------------------------------
!
          fac1=new_dtdays(ng)*MorZS0(ng)
          fac2=new_dtdays(ng)*MorZL0(ng)
          fac3=new_dtdays(ng)*MorZP0(ng)
          DO k=1,N(ng)
            DO i=Istr,Iend
              cff1=fac1*Bio(i,k,iSzoo)*EXP(KMorZS(ng)*Bio(i,k,itemp))
              cff2=fac2*Bio(i,k,iLzoo)*EXP(KMorZL(ng)*Bio(i,k,itemp))
              cff3=fac3*Bio(i,k,iPzoo)*EXP(KMorZP(ng)*Bio(i,k,itemp))
#if defined LOWER_LIM
              IF (Bio(i,k,iSzoo).LE.1.0e-6_r8) THEN
                cff1=0.0_r8
              ENDIF
              IF (Bio(i,k,iLzoo).LE.1.0e-6_r8) THEN
                cff2=0.0_r8
              ENDIF
              IF (Bio(i,k,iPzoo).LE.1.0e-6_r8) THEN
                cff3=0.0_r8
              ENDIF
#endif
              Bio(i,k,iSzoo)=Bio(i,k,iSzoo)/(1.0_r8+cff1)
              Bio(i,k,iLzoo)=Bio(i,k,iLzoo)/(1.0_r8+cff2)
              Bio(i,k,iPzoo)=Bio(i,k,iPzoo)/(1.0_r8+cff3)
              Bio(i,k,iPON_)=Bio(i,k,iPON_)+                            &
     &                       Bio(i,k,iSzoo)*cff1+                       &
     &                       Bio(i,k,iLzoo)*cff2+                       &
     &                       Bio(i,k,iPzoo)*cff3
#if defined N15
              Bio(i,k,iSzoo15)=Bio(i,k,iSzoo15)/(1.0_r8+cff1)
              Bio(i,k,iLzoo15)=Bio(i,k,iLzoo15)/(1.0_r8+cff2)
              Bio(i,k,iPzoo15)=Bio(i,k,iPzoo15)/(1.0_r8+cff3)
              Bio(i,k,iPON15_)=Bio(i,k,iPON15_)+                        &
     &                         (cff1*Bio(i,k,iSzoo15))+             &
     &                         (cff2*Bio(i,k,iLzoo15))+             &
     &                         (cff3*Bio(i,k,iPzoo15))
              Bio(i,k,iSzoo14)=Bio(i,k,iSzoo)-Bio(i,k,iSzoo15)
              Bio(i,k,iLzoo14)=Bio(i,k,iLzoo)-Bio(i,k,iLzoo15)
              Bio(i,k,iPzoo14)=Bio(i,k,iPzoo)-Bio(i,k,iPzoo15)
              Bio(i,k,iPON14_)=Bio(i,k,iPON_)-Bio(i,k,iPON15_)
#endif

            END DO
          END DO
      RETURN
      END SUBROUTINE zooplankton_mortality
!
!
!
      SUBROUTINE nutrient_decomposition(tile, ng, IminS, ImaxS, Bio     &
# if defined TANGENT || defined ADJOINT
     &                                  , BS                            &
# endif
#if defined DIAGNOSTICS_BIO
     &                                  , DiaBio3dJ                     &
#endif
     &                                  )
!
      USE mod_param
      USE mod_biology

!
!  Imported variable declarations.
!
      integer, intent(in) :: tile, ng, IminS, ImaxS
      real(r8),intent(inout),dimension(IminS:ImaxS,N(ng),NT(ng)) :: Bio
# if defined TANGENT || defined ADJOINT
      real(r8),intent(inout),optional,                                  &
     &  dimension(IminS:ImaxS,N(ng),3:NT(ng),1:6) :: BS
# endif
# ifdef DIAGNOSTICS_BIO
      real(r8), intent(inout) :: DiaBio3dJ(IminS:ImaxS,N(ng),NDbio3d)
# endif
!
!  Local variable declarations
!
      real(r8) :: cff, cff1, cff2, cff3, cff4, cff5
      real(r8) :: fac1, fac2, fac3, fac4, fac5
# if defined OXY
#  if defined DENIT
      real(r8) :: DenitPON, DenitDON
#  endif
# endif
#if defined N15
# if defined OXY
#  if defined DENIT
      real(r8) :: gamma_denitPON, DenitPON15
      real(r8) :: gamma_denitDON, DenitDON15
#  endif
# endif
#endif
# if defined ISO
      real(r8) :: &
        ticik,         &   ! TIC at current timestep
        di12c,         &   ! 12C in DIC
        di13c,         &   ! 13C in DIC
        di14c,         &   ! 14C in DIC
        R13C_DICik,    &   ! 13C/12C ratio at current timestep
        R14C_DICik,    &   ! 14C/12C ratio at current timestep
        alpha_cc = 0.998_r8, & ! equivlent to -2 per mil offset
        alpha_org = 0.978_r8,  & ! equivlent to -22 per mil offset
        R13C_org,      &   ! ratio of 13C/12C in organic matter 
        R13C_cc,       &   ! ratio of 13C/12C in calcium carbonate  
        R14C_org,      &   ! ratio of 14C/12C in organic matter 
        R14C_cc            ! ratio of 14C/12C in calcium carbonate  
# endif
# if defined ISO_13C
      real(r8) :: &
        ticik,         &   ! TIC at current timestep
        di12c,         &   ! 12C in DIC
        di13c,         &   ! 13C in DIC
        R13C_DICik,    &   ! 13C/12C ratio at current timestep
        alpha_cc = 0.998_r8, & ! equivlent to -2 per mil offset
        alpha_org = 0.978_r8,  & ! equivlent to -22 per mil offset
        R13C_org,      &   ! ratio of 13C/12C in organic matter 
        R13C_cc          ! ratio of 13C/12C in calcium carbonate  
# endif
#if defined CARB 
      real(r8) :: cffC
      real(r8) :: NtoAlk = 1.0_r8 ! Unit conversion N to ALK
      real(r8) :: CaCO3_diss = 0.0057_r8 ! CaCO3 dissolution rate (per day)
#endif
# if defined DENIT
! where did this number come from?
! we want to know what the ratio of NO3 lost to
! NH4 created in denitrification is. To find it, we
! can take the ratio of C lost to NH4 created by remineralization
! (using redfield ratio C:N of 106/16=6.625), and divide it by the ratio
! of C lost to NO3 lost in denitrification (using value of 0.8 from
! PISCES model). 
!rNO3NH4=ratio of NO3 used to NH4 created in denitrification:
      real(r8), parameter :: rNO3NH4= 8.3_r8
# endif
      integer :: i, k 
      integer, parameter :: itemp = 1 
! instead of #include "set_bounds.h"
      integer :: Istr, Iend
      Istr   =BOUNDS(ng) % Istr   (tile)
      Iend   =BOUNDS(ng) % Iend   (tile)
!
!-----------------------------------------------------------------------
!  Nutrient decomposition.
!-----------------------------------------------------------------------
!
          fac1=new_dtdays(ng)*Nit0(ng)
          fac2=new_dtdays(ng)*VP2N0(ng)
          fac3=new_dtdays(ng)*VP2D0(ng)
          fac4=new_dtdays(ng)*VD2N0(ng)
          fac5=new_dtdays(ng)*VO2S0(ng)
          DO k=1,N(ng)
            DO i=Istr,Iend
# if defined TANGENT || defined ADJOINT
!
!  First save the initial Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iNH4_,1)=Bio(i,k,iNH4_)
                BS(i,k,iNO3_,1)=Bio(i,k,iNO3_)
                BS(i,k,iDON_,1)=Bio(i,k,iDON_)
                BS(i,k,iSiOH,1)=Bio(i,k,iSiOH)
#if defined OXY
                BS(i,k,iOxyg,1)=Bio(i,k,iOxyg)
#endif
              END IF
#endif
!
!  Nitrification: NH4 to NO3.
!
              cff1=fac1*EXP(KNit(ng)*Bio(i,k,itemp))
#if defined CARB & ! defined KO06
!C1.1.6a
              cffC=cff1
#endif
#if defined LOWER_LIM
              IF (Bio(i,k,iNH4_).LE.1.0e-3_r8) THEN
                cff1=0.0_r8
              ENDIF
#endif
              Bio(i,k,iNH4_)=Bio(i,k,iNH4_)/(1.0_r8+cff1)
              Bio(i,k,iNO3_)=Bio(i,k,iNO3_)+                            &
     &                       Bio(i,k,iNH4_)*cff1
#if defined N15
              Bio(i,k,iNH415_)=Bio(i,k,iNH415_)/(1.0_r8+cff1)
              Bio(i,k,iNO315_)=Bio(i,k,iNO315_)+                        &
     &                         (cff1*Bio(i,k,iNH415_))
              Bio(i,k,iNH414_)=Bio(i,k,iNH4_)-Bio(i,k,iNH415_)
              Bio(i,k,iNO314_)=Bio(i,k,iNO3_)-Bio(i,k,iNO315_)
#endif

#if defined OXY
!OX1.1.7b
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iNH4_,6)=Bio(i,k,iNH4_)
              END IF
#endif

              Bio(i,k,iOxyg)=Bio(i,k,iOxyg)-                            &
     &                       cff1*2.0_r8*Bio(i,k,iNH4_)
#endif
#if defined CARB & ! defined KO06
!C1.1.6b
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iTAlk,1)=Bio(i,k,iTAlk)
              END IF
#endif

!
! Nitrification (RG)            
! Alkalinity decreases by 2 Eq per mole of ammonium oxidized 
! NH4+ + 3/2O2 -> NO3- + 2H+ +H20
! eqn 3 pp 207 Morel and Hering 1993
! NtoAlk = 1:1 unit conversion from N (mmol m-3 N) to Alk (mEq m-3)
! old code = cff=cffC*Bio(i,k,iNH4_)/MAX(BIOmin,Bio(i,k,iTAlk))
! 
              cff=cffC*Bio(i,k,iNH4_)*NtoAlk*2.0_r8                    &
              & /MAX(BIOmin,Bio(i,k,iTAlk))
              Bio(i,k,iTAlk)=Bio(i,k,iTAlk)/(1.0_r8+cff)
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iTAlk,2)=Bio(i,k,iTAlk)
              END IF
#endif
#endif
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iNH4_,2)=Bio(i,k,iNH4_)
                BS(i,k,iNO3_,2)=Bio(i,k,iNO3_)
              END IF
#endif
!
!  Decomposition: PON to NH4.
!
              cff2=fac2*EXP(KP2N(ng)*Bio(i,k,itemp))
#if defined LOWER_LIM
              IF (Bio(i,k,iPON_).LE.1.0e-3_r8) THEN
                cff2=0.0_r8
              ENDIF
#endif
              Bio(i,k,iPON_)=Bio(i,k,iPON_)/(1.0_r8+cff2)
              Bio(i,k,iNH4_)=Bio(i,k,iNH4_)+                            &
     &                       Bio(i,k,iPON_)*cff2
#if defined N15
              Bio(i,k,iPON15_)=Bio(i,k,iPON15_)/(1.0_r8+cff2)
              Bio(i,k,iNH415_)=Bio(i,k,iNH415_)+                        &
     &                         (cff2*Bio(i,k,iPON15_))
              Bio(i,k,iNH414_)=Bio(i,k,iNH4_)-Bio(i,k,iNH415_)
              Bio(i,k,iPON14_)=Bio(i,k,iPON_)-Bio(i,k,iPON15_)
#endif

#if defined OXY || defined CARB
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iPON_,6)=Bio(i,k,iPON_)
              END IF
#endif

#endif
#if defined OXY
# if defined DENIT
              IF (Bio(i,k,iOxyg).LT.5.0_r8) THEN
                DenitPON=MIN(Bio(i,k,iPON_)*cff2*rNO3NH4,Bio(i,k,iNO3_))
#  if defined LOWER_LIM
                IF (Bio(i,k,iNO3_).LE.1.0e-3_r8) THEN
                  DenitPON=0.0_r8
                ENDIF
#  endif
                Bio(i,k,iNO3_)=Bio(i,k,iNO3_)-DenitPON
#  if defined N15
                gamma_denitPON=1.0_r8-(eps_denit(ng)/1000.0_r8)
                IF ((Bio(i,k,iNO3_).GT.0.0_r8) .AND.                    &
     &              (Bio(i,k,iNO315_).GT.0.0_r8) .AND.                  &
     &              (Bio(i,k,iNO314_).GT.0.0_r8)) THEN
                  DenitPON15=DenitPON*(gamma_denitPON*(Bio(i,k,iNO315_) &
     &                  /Bio(i,k,iNO314_)))/(1.0_r8+(gamma_denitPON*    &
     &                  (Bio(i,k,iNO315_)/Bio(i,k,iNO314_))))
                ELSE
                  DenitPON15=0.0_r8
                ENDIF
                Bio(i,k,iNO315_)=Bio(i,k,iNO315_)-DenitPON15
                Bio(i,k,iNO314_)=Bio(i,k,iNO3_)-Bio(i,k,iNO315_)
#   endif
              ELSE
!OX1.1.8
                Bio(i,k,iOxyg)=Bio(i,k,iOxyg)-Bio(i,k,iPON_)*cff2*rOxNH4

              ENDIF
# else
              Bio(i,k,iOxyg)=Bio(i,k,iOxyg)-Bio(i,k,iPON_)*cff2*rOxNH4
# endif
#endif

#if defined CARB & ! defined KO07
!C1.1.7
              Bio(i,k,iTIC_)=Bio(i,k,iTIC_)+                            &
     &                       Bio(i,k,iPON_)*cff2*RedCN(ng)
     ! RG added 
              Bio(i,k,iTAlk)=Bio(i,k,iTAlk)+Bio(i,k,iPON_)*cff2
#endif
#if defined ISO
              ticik=Bio(i,k,iTIC_)
              di13c = Bio(i,k,iDI13C)
              di14c = Bio(i,k,iDI14C)
! to prevent divsison by zero
              if (ticik > 0.0_r8) then
                  R13C_DICik= di13c / ticik
                  R14C_DICik= di14c / ticik
              else
                  R13C_DICik = 1.0_r8 ! since tracer is scaled, 1 means R13C_DICik = R13C_std
                  R14C_DICik = 1.0_r8 ! since tracer is scaled, 1 means R14C_DICik = R14C_std
              endif
              R13C_org = R13C_DICik * alpha_org
              R14C_org = R14C_DICik * alpha_org 
#endif
#if defined ISO & ! defined KO07
!C1.1.7
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)+                         &
     &                       Bio(i,k,iPON_)*cff2*RedCN(ng)*R13C_org
              Bio(i,k,iDI14C)=Bio(i,k,iDI14C)+                         &
     &                       Bio(i,k,iPON_)*cff2*RedCN(ng)*R14C_org
#endif
#if defined ISO_13C
              ticik=Bio(i,k,iTIC_)
              di13c = Bio(i,k,iDI13C)
! to prevent divsison by zero
              if (ticik > 0.0_r8) then
                  R13C_DICik= di13c / ticik
              else
                  R13C_DICik=0.0112372_r8
              endif
              R13C_org = R13C_DICik * alpha_org
#endif
#if defined ISO_13C & ! defined KO07
!C1.1.7
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)+                         &
     &                       Bio(i,k,iPON_)*cff2*RedCN(ng)*R13C_org
#endif
#if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iNH4_,3)=Bio(i,k,iNH4_)
                BS(i,k,iPON_,3)=Bio(i,k,iPON_)
              END IF
#endif
!
!  Decomposition: PON to DON.
!
              cff3=fac3*EXP(KP2D(ng)*Bio(i,k,itemp))
#if defined LOWER_LIM
              IF (Bio(i,k,iPON_).LE.1.0e-3_r8) THEN
                cff3=0.0_r8
              ENDIF
#endif
              Bio(i,k,iPON_)=Bio(i,k,iPON_)/(1.0_r8+cff3)
              Bio(i,k,iDON_)=Bio(i,k,iDON_)+                            &
     &                       Bio(i,k,iPON_)*cff3
#if defined N15
              Bio(i,k,iPON15_)=Bio(i,k,iPON15_)/(1.0_r8+cff3)
              Bio(i,k,iDON15_)=Bio(i,k,iDON15_)+                        &
     &                         (cff3*Bio(i,k,iPON15_))
              Bio(i,k,iDON14_)=Bio(i,k,iDON_)-Bio(i,k,iDON15_)
              Bio(i,k,iPON14_)=Bio(i,k,iPON_)-Bio(i,k,iPON15_)
#endif
#if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iPON_,4)=Bio(i,k,iPON_)
                BS(i,k,iDON_,2)=Bio(i,k,iDON_)
              END IF
#endif
#if defined DIAGNOSTICS_BIO
# ifdef DIAGNOSTICS_NEM_NIT
              DiaBio3dJ(i,k,iPON2DON)=DiaBio3dJ(i,k,iPON2DON) +         &
     &                                 Bio(i,k,iPON_)*cff3
# endif
#endif
!
!  Decomposition: DON to NH4.
!
              cff4=fac4*EXP(KD2N(ng)*Bio(i,k,itemp))
#if defined LOWER_LIM
              IF (Bio(i,k,iDON_).LE.1.0e-3_r8) THEN
                cff4=0.0_r8
              ENDIF
#endif
              Bio(i,k,iDON_)=Bio(i,k,iDON_)/(1.0_r8+cff4)
              Bio(i,k,iNH4_)=Bio(i,k,iNH4_)+                            &
     &                       Bio(i,k,iDON_)*cff4
#if defined N15
              Bio(i,k,iDON15_)=Bio(i,k,iDON15_)/(1.0_r8+cff4)
              Bio(i,k,iNH415_)=Bio(i,k,iNH415_)+                        &
     &                         (cff4*Bio(i,k,iDON15_))
              Bio(i,k,iNH414_)=Bio(i,k,iNH4_)-Bio(i,k,iNH415_)
              Bio(i,k,iDON14_)=Bio(i,k,iDON_)-Bio(i,k,iDON15_)
#endif
#if defined OXY || defined CARB
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iDON_,6)=Bio(i,k,iDON_)
              END IF
# endif
#endif
#if defined DIAGNOSTICS_BIO
# ifdef DIAGNOSTICS_NEM_NIT
              DiaBio3dJ(i,k,iDON2NH4)=DiaBio3dJ(i,k,iDON2NH4) +         &
     &                                 Bio(i,k,iDON_)*cff4
# endif
#endif
#if defined OXY
# if defined DENIT
              IF (Bio(i,k,iOxyg).LT.5.0_r8 .AND.                        &
     &            Bio(i,k,iNO3_).GT.0.1_r8) THEN
                DenitDON=MIN(Bio(i,k,iDON_)*cff4*rNO3NH4,Bio(i,k,iNO3_))
#if defined LOWER_LIM
                IF (Bio(i,k,iNO3_).LE.1.0e-3_r8) THEN
                  DenitDON=0.0_r8
                ENDIF
#endif
                Bio(i,k,iNO3_)=Bio(i,k,iNO3_)-DenitDON
#  if defined N15
                gamma_denitDON=1.0_r8-(eps_denit(ng)/1000.0_r8)
                IF ((Bio(i,k,iNO3_).GT.0.0_r8) .AND.                    &
     &              (Bio(i,k,iNO315_).GT.0.0_r8) .AND.                  &
     &              (Bio(i,k,iNO314_).GT.0.0_r8)) THEN
                  DenitDON15=DenitDON*(gamma_denitDON*(Bio(i,k,iNO315_) &
     &                     /Bio(i,k,iNO314_)))/(1.0_r8+(gamma_denitDON* &
     &                     (Bio(i,k,iNO315_)/Bio(i,k,iNO314_))))

                ELSE
                  DenitDON15=0.0_r8
                ENDIF
                Bio(i,k,iNO315_)=Bio(i,k,iNO315_)-DenitDON15
                Bio(i,k,iNO314_)=Bio(i,k,iNO3_)-Bio(i,k,iNO315_)
#   endif
              ELSE
!OX1.1.9
                Bio(i,k,iOxyg)=Bio(i,k,iOxyg)-Bio(i,k,iDON_)*cff4*rOxNH4
              ENDIF
# else
!OX1.1.9
              Bio(i,k,iOxyg)=Bio(i,k,iOxyg)-Bio(i,k,iDON_)*cff4*rOxNH4
# endif
#endif
#if defined CARB & ! defined KO08
!C1.1.8
              Bio(i,k,iTIC_)=Bio(i,k,iTIC_)+                            &
     &                       Bio(i,k,iDON_)*cff4*RedCN(ng)
     ! RG added 
              Bio(i,k,iTAlk)=Bio(i,k,iTAlk)+Bio(i,k,iDON_)*cff4
#endif
#if defined ISO & ! defined KO08
!C1.1.8
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)+                        &
     &                       Bio(i,k,iDON_)*cff4*RedCN(ng)*R13C_org
              Bio(i,k,iDI14C)=Bio(i,k,iDI14C)+                        &
     &                       Bio(i,k,iDON_)*cff4*RedCN(ng)*R14C_org
#endif
#if defined ISO_13C & ! defined KO08
!C1.1.8
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)+                        &
     &                       Bio(i,k,iDON_)*cff4*RedCN(ng)*R13C_org
#endif
# if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iNH4_,4)=Bio(i,k,iNH4_)
                BS(i,k,iDON_,3)=Bio(i,k,iDON_)
#  if defined OXY
                BS(i,k,iOxyg,2)=Bio(i,k,iOxyg)
#  endif
              END IF
#endif
!
!  Decomposition: Opal to SiOH4.
!
              cff5=fac5*EXP(KO2S(ng)*Bio(i,k,itemp))
              Bio(i,k,iopal)=Bio(i,k,iopal)/(1.0_r8+cff5)
              Bio(i,k,iSiOH)=Bio(i,k,iSiOH)+                            &
     &                       Bio(i,k,iopal)*cff5
#if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iopal,3)=Bio(i,k,iopal)
                BS(i,k,iSiOH,2)=Bio(i,k,iSiOH)
              END IF
#endif
#if defined DIAGNOSTICS_BIO
# ifdef DIAGNOSTICS_NEM_SIL
              DiaBio3dJ(i,k,iOpal2SiOH)=DiaBio3dJ(i,k,iOpal2SiOH) +     &
     &                                   Bio(i,k,iopal)*cff5
# endif
#endif
#if defined CARB & ! defined KO09 & ! (defined ISO || defined ISO_13C)
!C1.1.9
!
!  Calcium carbonate dissolution
!
              cffC=new_dtdays(ng)*CaCO3_diss
              Bio(i,k,iCalC)=Bio(i,k,iCalC)/(1.0_r8+cffC)
              Bio(i,k,iTIC_)=Bio(i,k,iTIC_)+                            &
     &                       Bio(i,k,iCalC)*cffC
              Bio(i,k,iTAlk)=Bio(i,k,iTAlk)+                            &
     &                       2.0_r8*Bio(i,k,iCalC)*cffC
#endif
#if defined CARB & ! defined KO09 & defined ISO
!C1.1.9
!
!  Calcium carbonate dissolution
!
              cffC=new_dtdays(ng)*CaCO3_diss
              Bio(i,k,iCalC)=Bio(i,k,iCalC)/(1.0_r8+cffC)
              Bio(i,k,iTIC_)=Bio(i,k,iTIC_)+                            &
     &                       Bio(i,k,iCalC)*cffC
              Bio(i,k,iTAlk)=Bio(i,k,iTAlk)+                            &
     &                       2.0_r8*Bio(i,k,iCalC)*cffC
              R13C_cc = R13C_DICik * alpha_cc
              R14C_cc = R14C_DICik * alpha_cc 
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)+                          &
     &                       Bio(i,k,iCalC)*cffC*R13C_cc
              Bio(i,k,iDI14C)=Bio(i,k,iDI14C)+                          &
     &                       Bio(i,k,iCalC)*cffC*R14C_cc
#endif
#if defined CARB & ! defined KO09 & defined ISO_13C
!C1.1.9
!
!  Calcium carbonate dissolution
!
              cffC=new_dtdays(ng)*CaCO3_diss
              Bio(i,k,iCalC)=Bio(i,k,iCalC)/(1.0_r8+cffC)
              Bio(i,k,iTIC_)=Bio(i,k,iTIC_)+                            &
     &                       Bio(i,k,iCalC)*cffC
              Bio(i,k,iTAlk)=Bio(i,k,iTAlk)+                            &
     &                       2.0_r8*Bio(i,k,iCalC)*cffC
              R13C_cc = R13C_DICik * alpha_cc
              Bio(i,k,iDI13C)=Bio(i,k,iDI13C)+                          &
     &                       Bio(i,k,iCalC)*cffC*R13C_cc
#endif
            END DO
          END DO
      RETURN
      END SUBROUTINE nutrient_decomposition 
#if defined NEMURO_CHL_GEIDER
!
!
!
      SUBROUTINE chlorophyll_loss(tile, ng, IminS, ImaxS, Bio,          &
     &                            Chl2NS, Chl2NL, BSS, BSL              &
# if defined TANGENT || defined ADJOINT
     &                            , BS                                  &
# endif
# if defined DIAGNOSTICS_BIO
     &                            , DiaBio3dJ                           &
# endif
# if defined LOGDIAGNOSTICS_NEM_CHL || defined NEMURO_CHL_EXITONNEGATIVE
     &                            , j                                   &
# endif
     &                            )
!
      USE mod_param
      USE mod_biology

!
!  Imported variable declarations.
!
      integer, intent(in) :: tile, ng, IminS, ImaxS
      real(r8),intent(inout),dimension(IminS:ImaxS,N(ng),NT(ng)) :: Bio
      real(r8),intent(in),dimension(IminS:ImaxS,N(ng)) :: Chl2NS,Chl2NL
      real(r8),intent(in),dimension(IminS:ImaxS,N(ng)) :: BSS,BSL
# if defined TANGENT || defined ADJOINT
      real(r8),intent(inout),optional,                                  &
     &  dimension(IminS:ImaxS,N(ng),3:NT(ng),1:6) :: BS
# endif
# ifdef DIAGNOSTICS_BIO
      real(r8), intent(inout) :: DiaBio3dJ(IminS:ImaxS,N(ng),NDbio3d)
# endif
# if defined LOGDIAGNOSTICS_NEM_CHL || defined NEMURO_CHL_EXITONNEGATIVE 
      integer, intent(in) :: j
# endif
!
!  Local variable declarations
!
      integer :: i, k 
! instead of #include "set_bounds.h"
      integer :: Istr, Iend
      Istr   =BOUNDS(ng) % Istr   (tile)
      Iend   =BOUNDS(ng) % Iend   (tile)
!
!-----------------------------------------------------------------------
!  Chlorophyll: Account for phytoplankton loss terms.
!-----------------------------------------------------------------------
!
          DO k=1,N(ng)
            DO i=Istr,Iend
!
!  Small phytoplankton
!
              Bio(i,k,iChlS)=Bio(i,k,iChlS)+                            &
     &          (Bio(i,k,iSphy)-BSS(i,k))*                              &
# if defined NEMURO_CHL_OLD
     &          MIN(Chl2NS(i,k),Chl2NS_max(ng))
# elif defined NEMURO_CHL_GEIDER_LOSSV2
     &          (Bio(i,k,iChlS)/MAX(BIOmin,Bio(i,k,iSphy)))
# else
     &          Chl2NS(i,k)
# endif
#  if defined LOGDIAGNOSTICS_NEM_CHL
              if (k==LOGDIAGNOSTICS_NEM_CHL_K.and.i==LOGDIAGNOSTICS_NEM_CHL_I.and.j==LOGDIAGNOSTICS_NEM_CHL_J) then
                write(*,'(a30,f19.12,a,f19.12,a,f19.12)')               &
     &            'ChlS loss: ',(Bio(i,k,iSphy)-BSS(i,k)),'*',          &
     &            Chl2NS(i,k),'=',(Bio(i,k,iSphy)-BSS(i,k))*Chl2NS(i,k)
                write(*,'(a30,f19.12)') 'Sphy = ',Bio(i,k,iSphy)
              end if
#  endif
!
!  Large phytoplankton
!
              Bio(i,k,iChlL)=Bio(i,k,iChlL)+                            &
     &          (Bio(i,k,iLphy)-BSL(i,k))*                              &
# if defined NEMURO_CHL_OLD
     &          MIN(Chl2NL(i,k),Chl2NL_max(ng))
# elif defined NEMURO_CHL_GEIDER_LOSSV2
     &          (Bio(i,k,iChlL)/MAX(BIOmin,Bio(i,k,iLphy)))
# else
     &          Chl2NL(i,k)
# endif
#  if defined LOGDIAGNOSTICS_NEM_CHL
              if (k==LOGDIAGNOSTICS_NEM_CHL_K.and.i==LOGDIAGNOSTICS_NEM_CHL_I.and.j==LOGDIAGNOSTICS_NEM_CHL_J) then
                write(*,'(a30,f19.12,a,f19.12,a,f19.12)')               &
     &            'ChlL loss: ',(Bio(i,k,iLphy)-BSL(i,k)),'*',          &
     &            Chl2NL(i,k),'=',(Bio(i,k,iLphy)-BSL(i,k))*Chl2NL(i,k)
                write(*,'(a30,f19.12)') 'Lphy = ',Bio(i,k,iLphy)
              end if
#  endif
#  ifdef DIAGNOSTICS_BIO
#   ifdef DIAGNOSTICS_NEM_CHL
              DiaBio3dJ(i,k,iLossPS)=DiaBio3dJ(i,k,iLossPS)-            &
     &          Bio(i,k,iSphy)+BSS(i,k)
              DiaBio3dJ(i,k,iLossPL)=DiaBio3dJ(i,k,iLossPL)-            &
     &          Bio(i,k,iLphy)+BSL(i,k)
              DiaBio3dJ(i,k,iChl2NS)=DiaBio3dJ(i,k,iChl2NS)+            &
     &          Chl2NS(i,k)*dtdays
              DiaBio3dJ(i,k,iChl2NL)=DiaBio3dJ(i,k,iChl2NL)+            &
     &          Chl2NL(i,k)*dtdays
#   endif
#  endif
#  if defined NEMURO_CHL_MAXCORRECTION
              Bio(i,k,iChlS)=MIN(Bio(i,k,iChlS),                        &
     &          Bio(i,k,iSphy)*Chl2NS_max(ng))
              Bio(i,k,iChlL)=MIN(Bio(i,k,iChlL),                        &
     &          Bio(i,k,iLphy)*Chl2NL_max(ng))
#  endif
            END DO
          END DO
      END SUBROUTINE chlorophyll_loss
#endif
#if defined NEMURO_CHL_NUDGECHL2N
!
!
!
      SUBROUTINE chlorophyll_nudge(tile, ng, IminS, ImaxS, Bio,         &
     &  Chl2NS, Chl2NL, LightChl                                        &
# if defined LOGDIAGNOSTICS_NEM_CHL || defined NEMURO_CHL_NUDGECHL2N_EXTRAOUT
     &  , j                                                             &
# endif
     &  )
!
      USE mod_param
      USE mod_biology

!
!  Imported variable declarations.
!
      integer, intent(in) :: tile, ng, IminS, ImaxS
      real(r8),intent(inout),dimension(IminS:ImaxS,N(ng),NT(ng)) :: Bio
      real(r8),intent(in),dimension(IminS:ImaxS,N(ng)) :: Chl2NS, Chl2NL
      real(r8),intent(in),dimension(IminS:ImaxS,N(ng)) :: LightChl
# if defined LOGDIAGNOSTICS_NEM_CHL
      integer, intent(in) :: j
# endif
# if defined NEMURO_CHL_NUDGECHL2N_EXTRAOUT
      integer, intent(in), optional :: j
# endif
!
!  Local variable declarations
!
      integer :: i, k 
      real :: Chl2NS_aim, Chl2NL_aim
      real :: chlnudgecoeffS, chlnudgecoeffL 
# if ! defined NEMURO_CHL_NUDGECHL2N_GEIDER
      real :: I_star
# endif
! instead of #include "set_bounds.h"
      integer :: Istr, Iend
      Istr   =BOUNDS(ng) % Istr   (tile)
      Iend   =BOUNDS(ng) % Iend   (tile)
!
!-----------------------------------------------------------------------
!  Chlorophyll: Nudge towards light-dependent chlorophyll:N ratio.
!-----------------------------------------------------------------------
!
      chlnudgecoeffS=new_dtdays(ng)*chltacclimS(ng)
      chlnudgecoeffL=new_dtdays(ng)*chltacclimL(ng)
      DO k=1,N(ng)
        DO i=Istr,Iend
!
!  Small phytoplankton
!
# if defined NEMURO_CHL_NUDGECHL2N_GEIDER
          ! based on (5) in Geider1997
          Chl2NS_aim=MIN(Chl2NS_max(ng),Chl2NS_max(ng)/                 &
     &      (1.0_r8+(Chl2NS_max(ng)*LightChl(i,k)*alphaPS(ng)/          &
     &      (2.0_r8*VmaxS(ng)))))
# else
          ! based on (7) in Jackson2017
          ! I_star=LightChl(i,k)/I_k
          ! I_k=(VmaxS(ng)/Chl2NS(i,k))/alphaPS(ng)
          I_star=MAX(BIOmin,                                            &
     &      LightChl(i,k)*Chl2NS(i,k)*alphaPS(ng)/VmaxS(ng))
          Chl2NS_aim=MAX(Chl2NS_min(ng),                                &
     &      Chl2NS_max(ng)/I_star*(1.0_r8-EXP(-I_star)))
# endif
          Bio(i,k,iChlS)=Bio(i,k,iSphy)*(Chl2NS(i,k)+                   &
     &      chlnudgecoeffS*(Chl2NS_aim-Chl2NS(i,k)))
# if defined LOGDIAGNOSTICS_NEM_CHL
          if (k==LOGDIAGNOSTICS_NEM_CHL_K.and.i==LOGDIAGNOSTICS_NEM_CHL_I.and.j==LOGDIAGNOSTICS_NEM_CHL_J) then
            write(*,'(a)') 'chlorophyll nudging:' 
            write(*,'(a30,f19.12)') 'LightChl = ',LightChl(i,k)
            write(*,'(a30,f19.12)') 'Sphy = ',Bio(i,k,iSphy)
            write(*,'(a30,f19.12)') 'Chl2NS = ',Chl2NS(i,k)
            write(*,'(a30,f19.12)') 'Chl2NS_aim = ',Chl2NS_aim
            write(*,'(a30,f19.12)') 'effective Chl2NS = ',              &
     &        Chl2NS(i,k)+chlnudgecoeffS*(Chl2NS_aim-Chl2NS(i,k))
            write(*,'(a30,f19.12)') 'resulting ChlS = ',Bio(i,k,iChlS)
#  if ! defined NEMURO_CHL_NUDGECHL2N_GEIDER
            write(*,'(a30,f19.12)') 'I_star (S) = ',I_star
#  endif
          end if
# endif
!
!  Large phytoplankton
!
# if defined NEMURO_CHL_NUDGECHL2N_GEIDER
          ! based on (5) in Geider1997
          Chl2NL_aim=MIN(Chl2NL_max(ng),Chl2NL_max(ng)/                 &
     &      (1.0_r8+(Chl2NL_max(ng)*LightChl(i,k)*alphaPL(ng)/          &
     &      (2.0_r8*VmaxL(ng)))))
# else
          ! based on (7) in Jackson2017
          ! I_star=LightChl(i,k)/I_k
          ! I_k=(VmaxL(ng)/Chl2NL(i,k))/alphaPL(ng)
          I_star=MAX(BIOmin,                                            &
     &      LightChl(i,k)*Chl2NL(i,k)*alphaPL(ng)/VmaxL(ng))
          Chl2NL_aim=MAX(Chl2NL_min(ng),                                &
     &      Chl2NL_max(ng)/I_star*(1.0_r8-EXP(-I_star)))
# endif
          Bio(i,k,iChlL)=Bio(i,k,iLphy)*(Chl2NL(i,k)+                   &
     &      chlnudgecoeffL*(Chl2NL_aim-Chl2NL(i,k)))
# if defined LOGDIAGNOSTICS_NEM_CHL
          if (k==LOGDIAGNOSTICS_NEM_CHL_K.and.i==LOGDIAGNOSTICS_NEM_CHL_I.and.j==LOGDIAGNOSTICS_NEM_CHL_J) then
            write(*,'(a30,f19.12)') 'Lphy = ',Bio(i,k,iLphy)
            write(*,'(a30,f19.12)') 'Chl2NL = ',Chl2NL(i,k)
            write(*,'(a30,f19.12)') 'Chl2NL_aim = ',Chl2NL_aim
            write(*,'(a30,f19.12)') 'effective Chl2NL = ',              &
     &        Chl2NL(i,k)+chlnudgecoeffL*(Chl2NL_aim-Chl2NL(i,k))
            write(*,'(a30,f19.12)') 'resulting ChlL = ',Bio(i,k,iChlL)
#  if ! defined NEMURO_CHL_NUDGECHL2N_GEIDER
            write(*,'(a30,f19.12)') 'I_star (L) = ',I_star
#  endif
          end if
# endif
# if defined NEMURO_CHL_NUDGECHL2N_EXTRAOUT
          IF (PRESENT(j)) THEN
            if (k==NEMURO_CHL_NUDGECHL2N_EXTRAOUT_K.and.i==NEMURO_CHL_NUDGECHL2N_EXTRAOUT_I.and.j==NEMURO_CHL_NUDGECHL2N_EXTRAOUT_J) then
              write(*,'(a20,f19.12,a10,f19.12)') '::NL Sphy =',         &
     &          Bio(i,k,iSphy), ' Lphy =',Bio(i,k,iLphy)
            end if
          ENDIF 
# endif
        END DO
      END DO
      END SUBROUTINE chlorophyll_nudge
#endif
#if defined OXY
!
!
!
      SUBROUTINE o2_exchange(tile, ng, j, IminS, ImaxS,                 &
     &  LBi, LBj,                                                       &
# if ! defined ASSUMED_SHAPE
     &  UBi, UBj,                                                       &
# endif
# if defined BULK_FLUXES
     &  Uwind, Vwind,                                                   &
# else
     &  sustr, svstr,                                                   &
# endif
     &  Hz_inv, Bio)
!
      USE mod_param
      USE mod_biology
      USE mod_scalars, ONLY: rho0

!
!  Imported variable declarations.
!
      integer, intent(in) :: tile, ng, j, IminS, ImaxS
      integer, intent(in) :: LBi, LBj
#ifdef ASSUMED_SHAPE
# ifdef BULK_FLUXES
      real(r8), intent(in) :: Uwind(LBi:,LBj:)
      real(r8), intent(in) :: Vwind(LBi:,LBj:)
# else
      real(r8), intent(in) :: sustr(LBi:,LBj:)
      real(r8), intent(in) :: svstr(LBi:,LBj:)
# endif
#else
      integer, intent(in) :: UBi, UBj
#  ifdef BULK_FLUXES
      real(r8), intent(in) :: Uwind(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: Vwind(LBi:UBi,LBj:UBj)
#  else
      real(r8), intent(in) :: sustr(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: svstr(LBi:UBi,LBj:UBj)
#  endif
#endif
      real(r8), intent(in), dimension(IminS:ImaxS,N(ng)) :: Hz_inv
      real(r8),intent(inout),dimension(IminS:ImaxS,N(ng),NT(ng)) :: Bio
!
!  Local variable declarations
!
#include "nemuro_oxy_def.h"

      real(r8) :: cff1, cff2, cff3
      real(r8) :: u10squ, SchmidtN_Ox, O2satu, O2_Flux 
      real(r8) :: TS, AA 

      integer :: i, k 
      integer, parameter :: itemp = 1 
      integer, parameter :: isalt = 2 
! instead of #include "set_bounds.h"
      integer :: Istr, Iend
      Istr   =BOUNDS(ng) % Istr   (tile)
      Iend   =BOUNDS(ng) % Iend   (tile)
!OX1.1.10
!
!-----------------------------------------------------------------------
!  Surface O2 gas exchange.
!-----------------------------------------------------------------------
!
!  Compute surface O2 gas exchange.
!
          cff1=rho0*550.0_r8
          cff2=new_dtdays(ng)*0.31_r8*24.0_r8/100.0_r8
          k=N(ng)
          DO i=Istr,Iend
!
!  Compute O2 transfer velocity : u10squared (u10 in m/s)
!
# ifdef BULK_FLUXES
            u10squ=Uwind(i,j)*Uwind(i,j)+Vwind(i,j)*Vwind(i,j)
# else
            u10squ=cff1*SQRT((0.5_r8*(sustr(i,j)+sustr(i+1,j)))**2+     &
     &                       (0.5_r8*(svstr(i,j)+svstr(i,j+1)))**2)
# endif
# ifdef OCMIP_OXYGEN_SC
!
!  Alternative formulation for Schmidt number (Sc will be slightly
!  smaller up to about 35 C): Compute the Schmidt number of oxygen
!  in seawater using the formulation proposed by Keeling et al.
!  (1998, Global Biogeochem. Cycles, 12, 141-163).  Input temperature
!  in Celsius.
!
            SchmidtN_Ox=1638.0_r8-                                      &
     &                  Bio(i,k,itemp)*(81.83_r8-                       &
     &                                  Bio(i,k,itemp)*                 &
     &                                  (1.483_r8-                      &
     &                                   Bio(i,k,itemp)*0.008004_r8))
# else
!
!  Calculate the Schmidt number for O2 in sea water (Wanninkhof, 1992).
!
            SchmidtN_Ox=1953.4_r8-                                      &
     &                  Bio(i,k,itemp)*(128.0_r8-                       &
     &                                  Bio(i,k,itemp)*                 &
     &                                  (3.9918_r8-                     &
     &                                   Bio(i,k,itemp)*0.050091_r8))
# endif

            cff3=cff2*u10squ*SQRT(660.0_r8/SchmidtN_Ox)
!
!  Calculate O2 saturation concentration using Garcia and Gordon
!  L&O (1992) formula, (EXP(AA) is in ml/l).
!
            TS=LOG((298.15_r8-Bio(i,k,itemp))/                          &
     &             (273.15_r8+Bio(i,k,itemp)))
            AA=OA0+TS*(OA1+TS*(OA2+TS*(OA3+TS*(OA4+TS*OA5))))+          &
     &             Bio(i,k,isalt)*(OB0+TS*(OB1+TS*(OB2+TS*OB3)))+       &
     &             OC0*Bio(i,k,isalt)*Bio(i,k,isalt)
!
!  Convert from ml/l to mmol/m3.
!
            O2satu=l2mol*EXP(AA)
!
!  Add in O2 gas exchange.
!
            O2_Flux=cff3*(O2satu-Bio(i,k,iOxyg))
            Bio(i,k,iOxyg)=Bio(i,k,iOxyg)+                              &
     &                     O2_Flux*Hz_inv(i,k)
          END DO
        RETURN
      END SUBROUTINE o2_exchange
#endif
!

#if defined CARB & ! defined KO10 & ! defined ISO
!C1.1.10
!
!
!
      SUBROUTINE co2_exchange(tile, ng, j, IminS, ImaxS,                &
     &  LBi, LBj,                                                       &
# if ! defined ASSUMED_SHAPE
     &  UBi, UBj,                                                       &
# endif
#ifdef MASKING
     &  rmask,                                                          &
#endif
# if defined BULK_FLUXES
     &  Uwind, Vwind,                                                   &
# else
     &  sustr, svstr,                                                   &
# endif
     &  pH, CO2flx, omega_arag, CO2star, pCO2,          &
     &  Hz_inv,                                                         &
     &  Bio                                                             &
# if defined TANGENT || defined ADJOINT
     &  ,BS                                                             &
# endif
     &  )
!
      USE mod_param
      USE mod_biology
      USE mod_scalars, ONLY: rho0

!
!  Imported variable declarations.
!
      integer, intent(in) :: tile, ng, j, IminS, ImaxS
      integer, intent(in) :: LBi, LBj
#ifdef ASSUMED_SHAPE
# ifdef MASKING
      real(r8), intent(in) :: rmask(LBi:,LBj:)
# endif
# ifdef BULK_FLUXES
      real(r8), intent(in) :: Uwind(LBi:,LBj:)
      real(r8), intent(in) :: Vwind(LBi:,LBj:)
# else
      real(r8), intent(in) :: sustr(LBi:,LBj:)
      real(r8), intent(in) :: svstr(LBi:,LBj:)
# endif
      real(r8), intent(inout) :: pH(LBi:,LBj:,:)
      real(r8), intent(inout) :: CO2flx(LBi:,LBj:)
      real(r8), intent(inout) :: omega_arag(LBi:,LBj:,:)
      real(r8), intent(inout) :: CO2star(LBi:,LBj:,:)
      real(r8), intent(inout) :: pCO2(LBi:,LBj:,:)
#else
      integer, intent(in) :: UBi, UBj
# ifdef MASKING
      real(r8), intent(in) :: rmask(LBi:UBi,LBj:UBj)
# endif
# ifdef BULK_FLUXES
      real(r8), intent(in) :: Uwind(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: Vwind(LBi:UBi,LBj:UBj)
# else
      real(r8), intent(in) :: sustr(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: svstr(LBi:UBi,LBj:UBj)
# endif
      real(r8), intent(inout) :: pH(LBi:UBi,LBj:UBj,UBk)
      real(r8), intent(inout) :: CO2flx(LBi:UBi,LBj:UBj)
      real(r8), intent(inout) :: omega_arag(LBi:UBi,LBj:UBj,UBk)
      real(r8), intent(inout) :: CO2star(LBi:UBi,LBj:UBj,UBk)
      real(r8), intent(inout) :: pCO2(LBi:UBi,LBj:UBj,UBk)
#endif
      real(r8), intent(in), dimension(IminS:ImaxS,N(ng)) :: Hz_inv
      real(r8),intent(inout),dimension(IminS:ImaxS,N(ng),NT(ng)) :: Bio
# if defined TANGENT || defined ADJOINT
      real(r8),intent(inout),optional,                                  &
     &  dimension(IminS:ImaxS,N(ng),3:NT(ng),1:6) :: BS
# endif
!
!  Local variable declarations
!
#include "nemuro_carb_def.h"

# if defined NEMURO_CO2_SECULAR
      real(r8) :: pCO2air_secular
# endif
      
      real(r8) :: cff1, cff2, cff3
      real(r8) :: CO2_Flux, CO2_sol, SchmidtN, TempK
      real(r8) :: tempik, saltik, ticik, talkik, phik,co2starik, pco2ik
      real(r8) :: omega_aragik
# ifdef MASKING
      real(r8) :: maskik
# endif
      real(r8) :: cffC, u10squ

      integer :: i, k 
      integer, parameter :: itemp = 1 
      integer, parameter :: isalt = 2 
! instead of #include "set_bounds.h"
      integer :: Istr, Iend
      Istr   =BOUNDS(ng) % Istr   (tile)
      Iend   =BOUNDS(ng) % Iend   (tile)
!
!-----------------------------------------------------------------------
!  Surface CO2 gas exchange.
!-----------------------------------------------------------------------
!
!  Compute equilibrium partial pressure inorganic carbon (ppmv) at the
!  surface.
!
!
          cff1=rho0*550.0_r8
          cff2=new_dtdays(ng)*0.31_r8*24.0_r8/100.0_r8 
!
          DO k=1,N(ng)
            DO i=Istr,Iend
!
!  Compute pCO2 and pH.
!
              tempik=Bio(i,k,itemp)
              saltik=Bio(i,k,isalt)
              ticik=Bio(i,k,iTIC_)
              talkik=Bio(i,k,iTAlk)
#if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iTIC_,5)=Bio(i,k,iTIC_)
                BS(i,k,iTAlk,5)=Bio(i,k,iTAlk)
              END IF
#endif

#  ifdef MASKING
              maskik=rmask(i,j)
#  endif
              CALL pCO2_water (                                         &
#  ifdef MASKING
     &                         maskik,                                  &
#  endif
     &                         tempik, saltik, ticik, talkik,           &
     &                         0.0_r8, 0.0_r8, phik,omega_aragik,       &
     &                         co2starik,pco2ik)
              pCO2(i,j,k)=pco2ik
              CO2star(i,j,k)=co2starik 
              pH(i,j,k)=phik
              omega_arag(i,j,k) = omega_aragik


!
!  Compute surface CO2 gas exchange.
!
              IF (k.eq.N(ng)) THEN
!
!  Compute CO2 transfer velocity : u10squared (u10 in m/s)
!
# ifdef BULK_FLUXES
                u10squ=Uwind(i,j)**2+Vwind(i,j)**2
# else
                u10squ=cff1*SQRT((0.5_r8*(sustr(i,j)+sustr(i+1,j)))**2+ &
     &                           (0.5_r8*(svstr(i,j)+svstr(i,j+1)))**2)
# endif
                SchmidtN=Acoef-                                         &
     &                   Bio(i,k,itemp)*(Bcoef-                         &
     &                                   Bio(i,k,itemp)*(Ccoef-         &
     &                                   Bio(i,k,itemp)*Dcoef))
# if defined CONSERVATION
                ! closed system during budget calculations
                cff3=cff2*u10squ*SQRT(660.0_r8/SchmidtN)*0.0_r8 
# else                 
                cff3=cff2*u10squ*SQRT(660.0_r8/SchmidtN)
# endif
!
!  Calculate CO2 solubility [mol/(kg.atm)] using Weiss (1974) formula.
!
                TempK=0.01_r8*(Bio(i,k,itemp)+273.15_r8)
                CO2_sol=EXP(A1+                                         &
     &                      A2/TempK+                                   &
     &                      A3*LOG(TempK)+                              &
     &                      Bio(i,k,isalt)*(B1+TempK*(B2+B3*TempK))) 
!
!  Add in CO2 gas exchange.
!
# if defined NEMURO_CO2_SECULAR
                pCO2air_secular=pCO2air(ng)+                            &
     &                          1.5_r8*((tdays(ng)-dstart)/365.25_r8)
                CO2_Flux=cff3*CO2_sol*(pCO2air_secular-pco2ik)
# elif defined NEMURO_CO2_TREND
                pCO2air_secular=pCO2air(ng)+pCO2trend(ng)*              &
     &                          ((tdays(ng)-dstart)/365.25_r8)
                CO2_Flux=cff3*CO2_sol*(pCO2air_secular-pco2ik)
# elif defined NEMURO_CO2_RCP85
                pCO2air_mo=(/ 0.05_r8,0.67_r8,1.45_r8,2.59_r8,3.03_r8,  &
     &                        2.32_r8,0.72_r8,-1.45_r8,-3.13_r8,        &
     &                        -3.24_r8,-2.07_r8, -0.90_r8 /)
                tmod=MOD(tdays(ng)/(365.25_r8/12.0_r8),12.0_r8)+0.5_r8
                fac2=tmod-REAL(INT(tmod),r8)
                fac1=1.0_r8-fac2
                imo1=INT(tmod)
                IF (imo1.lt.1) imo1=12
                imo2=imo1+1
                IF (imo2.gt.12) imo2=1
                pCO2air_cyc=fac1*pCO2air_mo(imo1)+fac2*pCO2air_mo(imo2)
                pCO2air_trnd=1.8661_r8*((tdays(ng)-dstart)/             &
     &                                 365.25_r8)**1.220_r8
#  ifdef NEMURO_CO2_ENSEMBLE
                pCO2air_trnd=pCO2fac(ng)*pCO2air_trnd
#  endif
                pCO2air_tot = pCO2air(ng)+pCO2air_cyc+pCO2air_trnd
                CO2_Flux=cff3*CO2_sol*(pCO2air_tot-pCO2ik)
                if ((i.eq.10).and.(j.eq.10).and.                        &
     &              (tdays(ng).eq.REAL(INT(tdays(ng),r8))))             &
     &            print*,'CO2air',REAL(tdays(ng),r4),                   &
     &                   REAL(pCO2air_cyc,r4),REAL(pCO2air_trnd,r4)
# else
                CO2_Flux=cff3*CO2_sol*(pCO2air(ng)-pco2ik)* 86400 / 200 ! convert to per day from per timestep
# endif
                Bio(i,k,iTIC_)=Bio(i,k,iTIC_)+CO2_Flux*Hz_inv(i,k)
                CO2flx(i,j)=CO2_Flux
              END IF
!
            END DO ! i loop
          END DO ! k loop
          RETURN
      END SUBROUTINE co2_exchange
#endif

#if defined ISO && defined CARB &&! defined KO10
!C1.1.10
!
!
      SUBROUTINE co2_exchange_iso(tile, ng, j, IminS, ImaxS,                &
     &  LBi, LBj,                                                       &
# if ! defined ASSUMED_SHAPE
     &  UBi, UBj,                                                       &
# endif
#ifdef MASKING
     &  rmask,                                                          &
#endif
# if defined BULK_FLUXES
     &  Uwind, Vwind,                                                   &
# else
     &  sustr, svstr,                                                   &
# endif
#ifdef DIAGNOSTICS_ISO
     &  DiaBio2dJ,                                                      &
#endif
     &  pH, F13Cas, F13Csa, CO2flx, omega_arag, CO2star, pCO2,          &
     &  Hz_inv,                                                         &
     &  Bio                                                             &
# if defined TANGENT || defined ADJOINT
     &  ,BS                                                             &
# endif
     &  )

      USE mod_param
      USE mod_biology
      USE mod_scalars, ONLY: rho0

!
!  Imported variable declarations.
!
      integer, intent(in) :: tile, ng, j, IminS, ImaxS
      integer, intent(in) :: LBi, LBj
#ifdef ASSUMED_SHAPE
# ifdef MASKING
      real(r8), intent(in) :: rmask(LBi:,LBj:)
# endif
# ifdef DIAGNOSTICS_ISO
      real(r8), intent(inout) :: DiaBio2dJ(LBi:,:)
# endif
# ifdef BULK_FLUXES
      real(r8), intent(in) :: Uwind(LBi:,LBj:)
      real(r8), intent(in) :: Vwind(LBi:,LBj:)
# else
      real(r8), intent(in) :: sustr(LBi:,LBj:)
      real(r8), intent(in) :: svstr(LBi:,LBj:)
# endif
      real(r8), intent(inout) :: pH(LBi:,LBj:,:)
      real(r8), intent(inout) :: F13Cas(LBi:,LBj:)
      real(r8), intent(inout) :: F13Csa(LBi:,LBj:)
      real(r8), intent(inout) :: CO2flx(LBi:,LBj:)
      real(r8), intent(inout) :: omega_arag(LBi:,LBj:,:)
      real(r8), intent(inout) :: CO2star(LBi:,LBj:,:)
      real(r8), intent(inout) :: pCO2(LBi:,LBj:,:)
#else
      integer, intent(in) :: UBi, UBj
# ifdef MASKING
      real(r8), intent(in) :: rmask(LBi:UBi,LBj:UBj)
# endif
# ifdef BULK_FLUXES
      real(r8), intent(in) :: Uwind(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: Vwind(LBi:UBi,LBj:UBj)
# else
      real(r8), intent(in) :: sustr(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: svstr(LBi:UBi,LBj:UBj)
# endif
      real(r8), intent(inout) :: pH(LBi:UBi,LBj:UBj,UBk)
      real(r8), intent(inout) :: F13Cas(LBi:UBi,LBj:UBj)
      real(r8), intent(inout) :: F13Csa(LBi:UBi,LBj:UBj)
      real(r8), intent(inout) :: CO2flx(LBi:UBi,LBj:UBj)
      real(r8), intent(inout) :: omega_arag(LBi:UBi,LBj:UBj,UBk)
      real(r8), intent(inout) :: CO2star(LBi:UBi,LBj:UBj,UBk)
      real(r8), intent(inout) :: pCO2(LBi:UBi,LBj:UBj,UBk)
# ifdef DIAGNOSTICS_ISO
      real(r8), intent(inout) :: DiaBio2dJ(IminS:ImaxS,NDbio2d)
# endif
#endif
      real(r8), intent(in), dimension(IminS:ImaxS,N(ng)) :: Hz_inv
      real(r8),intent(inout),dimension(IminS:ImaxS,N(ng),NT(ng)) :: Bio
# if defined TANGENT || defined ADJOINT
      real(r8),intent(inout),optional,                                  &
     &  dimension(IminS:ImaxS,N(ng),3:NT(ng),1:6) :: BS
# endif
!
!  Local variable declarations
!
#include "nemuro_carb_def.h"

# if defined NEMURO_CO2_SECULAR
      real(r8) :: pCO2air_secular
# endif
      
      real(r8) :: cff1, cff2, cff3
      real(r8) :: CO2_Flux, CO2_sol, SchmidtN, TempK
      real(r8) :: tempik, saltik, ticik, talkik, phik,co2starik, pco2ik
      real(r8) :: omega_aragik
      real(r8) :: CO2_Flux_as, CO2_Flux_sa 
      real(r8) :: &
        d13C,          &   ! atm 13co2 value
        di12c,         &   ! 12C in DIC
        di13c,         &   ! 13C in DIC
        di14c,         &   ! 14C in DIC
        R13C_atm,      &   ! 13C/12C ratio in atmospheric CO2
        F13C_atm,      &   ! 13C/C fraction in atmospheric CO2
        FLUX13,        &   ! gas flux of 13CO2 (nmol/cm^2/s)
        FLUX13_as,     &
        FLUX13_sa,     &
        FLUX14_as,     &
        FLUX14_sa,     &
        D14C,          &   ! atm 14co2 value
        R14C_atm,      &   ! 14C/12C ratio in atmospheric CO2
        F14C_atm,      &   ! 14C/C fraction in atmospheric CO2
        FLUX14,        &   ! gas flux of 14CO2 (nmol/cm^2/s)
        eps_aq_g, &   ! eps equilibrium fractionation (CO2_gaseous <-> CO2_aq)
        alpha_aq_g, & ! equilibrium fractionation (CO2_gaseous <-> CO2_aq)
        eps_dic_g,  & ! equilibrium fractionation between total DIC and gaseous CO2
        alpha_dic_g,& ! equilibrium fractionation between total DIC and gaseous CO2
        alpha_aq_g_14c, & ! for 14C, with fractionation being twice as large for 14C than for 13C
        alpha_dic_g_14c,& ! for 14C, with fractionation being twice as large for 14C than for 13C
        eps_k,         &   ! eps = ( alpha -1 ) * 1000
        alpha_k,       &   ! kinetic fractionation during gas transfer
        alpha_k_14c,   &   ! twice as large for 14C
        R13C_std,      &   ! 13C/12C PDB standard ratio (Craig, 1957)
        R14C_std,      &   ! 14C/12C NOSAMS standard ratio
        R13C_DICik,    &   ! 13C/12C ratio at current timestep
        R14C_DICik         ! 14C/12C ratio at current timestep


# ifdef MASKING
      real(r8) :: maskik
# endif
      real(r8) :: cffC, u10squ

      integer :: i, k 
      integer, parameter :: itemp = 1 
      integer, parameter :: isalt = 2 
! instead of #include "set_bounds.h"
      integer :: Istr, Iend
      Istr   =BOUNDS(ng) % Istr   (tile)
      Iend   =BOUNDS(ng) % Iend   (tile)
!
!-----------------------------------------------------------------------
!  Surface CO2 gas exchange.
!-----------------------------------------------------------------------
!
!  Compute equilibrium partial pressure inorganic carbon (ppmv) at the
!  surface.
!
!
          cff1=rho0*550.0_r8 
          cff2=new_dtdays(ng)*0.31_r8*24.0_r8/100.0_r8
!
          DO k=1,N(ng)
            DO i=Istr,Iend
                
!
!  Compute pCO2 and pH.
!
              tempik=Bio(i,k,itemp)
              saltik=Bio(i,k,isalt)
              ticik=Bio(i,k,iTIC_)
              talkik=Bio(i,k,iTAlk)

#if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iTIC_,5)=Bio(i,k,iTIC_)
                BS(i,k,iTAlk,5)=Bio(i,k,iTAlk)
              END IF
#endif

#  ifdef MASKING
              maskik=rmask(i,j)
#  endif
              CALL pCO2_water (                                         &
#  ifdef MASKING
     &                         maskik,                                  &
#  endif
     &                         tempik, saltik, ticik, talkik,           &
     &                         0.0_r8, 0.0_r8, phik,omega_aragik,       &
     &                         co2starik,pco2ik)
              pCO2(i,j,k)=pco2ik
              CO2star(i,j,k)=co2starik 
              pH(i,j,k)=phik
              omega_arag(i,j,k) = omega_aragik

!
!  Compute surface CO2 gas exchange.
!
              IF (k.eq.N(ng)) THEN
!
!  Compute CO2 transfer velocity : u10squared (u10 in m/s)
!
# ifdef BULK_FLUXES
                u10squ=Uwind(i,j)**2+Vwind(i,j)**2
# else
                u10squ=cff1*SQRT((0.5_r8*(sustr(i,j)+sustr(i+1,j)))**2+ &
     &                           (0.5_r8*(svstr(i,j)+svstr(i,j+1)))**2)
# endif
                SchmidtN=Acoef-                                         &
     &                   Bio(i,k,itemp)*(Bcoef-                         &
     &                                   Bio(i,k,itemp)*(Ccoef-         &
     &                                   Bio(i,k,itemp)*Dcoef))

# if defined CONSERVATION
                ! closed system during budget calculations
                cff3=cff2*u10squ*SQRT(660.0_r8/SchmidtN)*0.0_r8 
# else                 
                cff3=cff2*u10squ*SQRT(660.0_r8/SchmidtN)
# endif
!
!  Calculate CO2 solubility [mol/(kg.atm)] using Weiss (1974) formula.
! equation 12 
                TempK=0.01_r8*(Bio(i,k,itemp)+273.15_r8)
                CO2_sol=EXP(A1+                                         &
     &                      A2/TempK+                                   &
     &                      A3*LOG(TempK)+                              &
     &                      Bio(i,k,isalt)*(B1+TempK*(B2+B3*TempK)))
!-----------------------------------------------------------------------
!    Setting Rstds. ! 14C/12C NOSAMS standard ratio 
!    13C/12C PDB standard ratio (Craig, 1957) 
!-----------------------------------------------------------------------
               R13C_std = 0.0112372_r8
               R14C_std = 1.176e-12
!-----------------------------------------------------------------------
!     individal discrimination factor of each species with respect to
!     gaseous CO2, temperature dependent, based on Zhang et al. 95      
!-----------------------------------------------------------------------
! However, following Schmittner et al. (2013), we neglect the effect 
! that the carbonate fraction (f CO3) has on αDIC←g because this is much
! smaller (0.05‰) than the temperature effect (3 ‰) -> Per Denith et 
! al., 2020

!-----------------------------------------------------------------------
!     kinetic fraction during gas transfer (per mil) (air-sea CO2
!     exchange) at 21C, Zhang et al 1995, eps_k = -0.95 at 5C
!     alpha_k = ratio of 13CO2 and CO2 gas transfer rates alphak = k13/k
!-----------------------------------------------------------------------
                eps_k = -0.81_r8  
!                 alpha_k = 0.99919_r8
                alpha_k = 1.0_r8 + eps_k / 1000_r8
                
! Fractionation is twice as large for 14C than for 13C
                alpha_k_14c = 1.0_r8 + eps_k* 2.0_r8 / 1000_r8
!                 alpha_k_14c = alpha_k * 2.0_r8
!-----------------------------------------------------------------------
!     temperature dependent equilibrium fraction
!     alpha_aq_g_surf = equilibrium solubilitiy ratio of 13CO2 and 12CO2
!     at equilibrium, alpha_aq_g_surf = R13Caq/R13Cgaseous
!     alpha_dic_g_surf = equilibrium fractionation factor between DIC and 
!     gaseous CO2
!     at equilibrium, alpha_dic_g_surf = R13CDIC / R13Cgasous
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!     individal discrimination factor of each species with respect to
!     gaseous CO2, temperature dependent, based on Zhang et al. 95      
!-----------------------------------------------------------------------
                eps_aq_g = 0.0049_r8 * Bio(i,k,itemp) - 1.31_r8
!  However, following Schmittner et al. (2013), we neglect the effect that the carbonate fraction (f CO3) has on αDIC←g because this is much smaller (0.05 ‰) than the temperature effect (3 ‰) ---> Per Denith et al., 2020
                eps_dic_g = -0.105_r8 * Bio(i,k,itemp) + 10.51_r8
                alpha_aq_g  = 1.0_r8 + eps_aq_g  / 1000_r8
                alpha_dic_g = 1.0_r8 + eps_dic_g / 1000_r8
!                 alpha_aq_g  = 0.9986_r8 - 4.9e-6*Bio(i,k,itemp)
!                 alpha_dic_g = 1.01051_r8 - 1.05e-4*Bio(i,k,itemp)

! Fractionation is twice as large for 14C than for 13C
!                 alpha_aq_g_14c  = alpha_aq_g*2.0_r8
!                 alpha_dic_g_14c = alpha_dic_g*2.0_r8
                alpha_aq_g_14c=1.0_r8+eps_aq_g*2.0_r8/1000_r8
                alpha_dic_g_14c=1.0_r8+eps_dic_g*2.0_r8/1000_r8

!-----------------------------------------------------------------------
!     initialize R13C_atm and R14C_atm
!-----------------------------------------------------------------------
! currently setting atmospheric values as constant
!                 d13C = -6.6_r8 ! per mil
                d13C = -8.4_r8 ! per mil, measured in 2015 from Graven et al., 2020
                D14C = 0.0_r8 ! per mil

                R13C_atm = R13C_std * ( 1_r8 + d13C / 1000_r8 )
                R14C_atm = R14C_std * ( 1_r8 + D14C / 1000_r8 )
                
! convert R to F -> 13F = 13R/(1 + 13R)
                F13C_atm = R13C_atm / (1+R13C_atm)
                F14C_atm = R14C_atm / (1+R14C_atm)
                
                
                di13c = Bio(i,k,iDI13C)
                di14c = Bio(i,k,iDI14C)
! to prevent division by zero
                if (ticik > 0.0_r8) then
                    R13C_DICik = di13c / ticik
                    R14C_DICik = di14c / ticik
                else
                    R13C_DICik = 1.0_r8 ! since tracer is scaled, 1 means R13C_DICik = R13C_std
                    R14C_DICik = 1.0_r8 ! since tracer is scaled, 1 means R14C_DICik = R14C_std
                endif

!
!  Add in CO2 gas exchange. And now isotopes!
!
# if defined NEMURO_CO2_SECULAR
                pCO2air_secular=pCO2air(ng)+                            &
     &                          1.5_r8*((tdays(ng)-dstart)/365.25_r8)
                CO2_Flux_as = cff3 * CO2_sol * pCO2air_secular
                CO2_Flux_sa = cff3 * CO2_sol * pco2ik
                
                FLUX13_as = alpha_k * alpha_aq_g * cff3 * CO2_sol  &
                & * pCO2air_secular * R13C_atm
                FLUX13_sa = alpha_k * alpha_aq_g * cff3 * CO2_sol  &
                & * pco2ik * R13C_DICik / alpha_dic_g
                
                FLUX14_as = cff3 * CO2_sol * alpha_k_14c *              &
     &          alpha_aq_g_14c * pCO2air_secular * R14C_atm
                FLUX14_sa = cff3 * CO2_sol * alpha_k_14c *              &
     &          alpha_aq_g_14c * pco2ik * R14C_DICik  / alpha_dic_g_14c
                
# elif defined NEMURO_CO2_TREND
                pCO2air_secular=pCO2air(ng)+pCO2trend(ng)*              &
     &                          ((tdays(ng)-dstart)/365.25_r8)
                CO2_Flux_as = cff3 * CO2_sol * pCO2air_secular
                CO2_Flux_sa = cff3 * CO2_sol * pco2ik

                FLUX13_as = alpha_k * alpha_aq_g * cff3 * CO2_sol  &
                & * pCO2air_secular * R13C_atm
                FLUX13_sa = alpha_k * alpha_aq_g * cff3 * CO2_sol  &
                & * pco2ik * R13C_DICik / alpha_dic_g
                
                FLUX14_as = cff3 * CO2_sol * alpha_k_14c *              &
     &          alpha_aq_g_14c * pCO2air_secular * R14C_atm
                FLUX14_sa = cff3 * CO2_sol * alpha_k_14c *              &
     &          alpha_aq_g_14c * pco2ik * R14C_DICik  / alpha_dic_g_14c
                
# elif defined NEMURO_CO2_RCP85
                pCO2air_mo=(/ 0.05_r8,0.67_r8,1.45_r8,2.59_r8,3.03_r8,  &
     &                        2.32_r8,0.72_r8,-1.45_r8,-3.13_r8,        &
     &                        -3.24_r8,-2.07_r8, -0.90_r8 /)
                tmod=MOD(tdays(ng)/(365.25_r8/12.0_r8),12.0_r8)+0.5_r8
                fac2=tmod-REAL(INT(tmod),r8)
                fac1=1.0_r8-fac2
                imo1=INT(tmod)
                IF (imo1.lt.1) imo1=12
                imo2=imo1+1
                IF (imo2.gt.12) imo2=1
                pCO2air_cyc=fac1*pCO2air_mo(imo1)+fac2*pCO2air_mo(imo2)
                pCO2air_trnd=1.8661_r8*((tdays(ng)-dstart)/             &
     &                                 365.25_r8)**1.220_r8
#  ifdef NEMURO_CO2_ENSEMBLE
                pCO2air_trnd=pCO2fac(ng)*pCO2air_trnd
#  endif
                pCO2air_tot = pCO2air(ng)+pCO2air_cyc+pCO2air_trnd
                CO2_Flux_as = cff3 * CO2_sol * pCO2air_tot
                CO2_Flux_sa = cff3 * CO2_sol * pco2ik
                
                FLUX13_as = alpha_k * alpha_aq_g * cff3 * CO2_sol  &
                & * pCO2air_tot * R13C_atm
                FLUX13_sa = alpha_k * alpha_aq_g * cff3 * CO2_sol  &
                & * pco2ik * R13C_DICik / alpha_dic_g

                FLUX14_as = cff3 * CO2_sol * alpha_k_14c *              &
     &          alpha_aq_g_14c * pCO2air_tot * R14C_atm
                FLUX14_sa = cff3 * CO2_sol * alpha_k_14c *              &
     &          alpha_aq_g_14c * pco2ik * R14C_DICik  / alpha_dic_g_14c
                
                if ((i.eq.10).and.(j.eq.10).and.                        &
     &              (tdays(ng).eq.REAL(INT(tdays(ng),r8))))             &
     &            print*,'CO2air',REAL(tdays(ng),r4),                   &
     &                   REAL(pCO2air_cyc,r4),REAL(pCO2air_trnd,r4)
# else
                CO2_Flux_as = cff3 * CO2_sol * pCO2air(ng)
                CO2_Flux_sa = cff3 * CO2_sol * pco2ik
                
                FLUX13_as = alpha_k * alpha_aq_g * cff3 * CO2_sol  &
                & * pCO2air(ng) * R13C_atm
                FLUX13_sa = alpha_k * alpha_aq_g * cff3 * CO2_sol  &
                & * pco2ik * R13C_DICik / alpha_dic_g

                FLUX14_as = cff3 * CO2_sol * alpha_k_14c *              &
     &          alpha_aq_g_14c * pCO2air(ng) * R14C_atm
                FLUX14_sa = cff3 * CO2_sol * alpha_k_14c *              &
     &          alpha_aq_g_14c * pco2ik * R14C_DICik  / alpha_dic_g_14c
# endif
                CO2_flux = CO2_Flux_as - CO2_Flux_sa
! need to scale the air to sea flux into model units             
                FLUX13 = (FLUX13_as / R13C_std) - FLUX13_sa
                FLUX14 = (FLUX14_as / R14C_std) - FLUX14_sa
                
                Bio(i,k,iTIC_)=Bio(i,k,iTIC_)+CO2_Flux*Hz_inv(i,k)
                Bio(i,k,iDI13C)= Bio(i,k,iDI13C)+FLUX13*Hz_inv(i,k)
                Bio(i,k,iDI14C)= Bio(i,k,iDI14C)+FLUX14*Hz_inv(i,k)
!                 CO2flx(i,j) = CO2_Flux
                CO2flx(i,j) = CO2_Flux * 86400 / 200 ! convert to per day from per timestep
                F13Cas(i,j) = alpha_k * alpha_aq_g * R13C_atm
                F13Csa(i,j) = alpha_k * alpha_aq_g * R13C_DICik          &
    &           * R13C_std / alpha_dic_g
                
# if defined DIAGNOSTICS_ISO
                 DiaBio2dJ(i,R13C_as) = DiaBio2dJ(i,i13CO2as) +        &
                 & FLUX13_as * Hz_inv(i,k)
                 DiaBio2dJ(i,R13C_sa) = FLUX13_sa * Hz_inv(i,k)
# endif
              END IF
!
            END DO ! i loop
          END DO ! k loop
          RETURN
      END SUBROUTINE co2_exchange_iso
#endif

#if defined ISO_13C && defined CARB &&! defined KO10
!C1.1.10
!
!
      SUBROUTINE co2_exchange_iso_13C(tile, ng, j, IminS, ImaxS,                &
     &  LBi, LBj,                                                       &
# if ! defined ASSUMED_SHAPE
     &  UBi, UBj,                                                       &
# endif
#ifdef MASKING
     &  rmask,                                                          &
#endif
# if defined BULK_FLUXES
     &  Uwind, Vwind,                                                   &
# else
     &  sustr, svstr,                                                   &
# endif
#ifdef DIAGNOSTICS_ISO
     &  DiaBio2dJ,                                                      &
#endif
     &  pH, F13Cas, F13Csa, CO2flx, omega_arag, CO2star, pCO2,          &
     &  Hz_inv,                                                         &
     &  Bio                                                             &
# if defined TANGENT || defined ADJOINT
     &  ,BS                                                             &
# endif
     &  )

      USE mod_param
      USE mod_biology
      USE mod_scalars, ONLY: rho0

!
!  Imported variable declarations.
!
      integer, intent(in) :: tile, ng, j, IminS, ImaxS
      integer, intent(in) :: LBi, LBj
#ifdef ASSUMED_SHAPE
# ifdef MASKING
      real(r8), intent(in) :: rmask(LBi:,LBj:)
# endif
# ifdef DIAGNOSTICS_ISO
      real(r8), intent(inout) :: DiaBio2dJ(LBi:,:)
# endif
# ifdef BULK_FLUXES
      real(r8), intent(in) :: Uwind(LBi:,LBj:)
      real(r8), intent(in) :: Vwind(LBi:,LBj:)
# else
      real(r8), intent(in) :: sustr(LBi:,LBj:)
      real(r8), intent(in) :: svstr(LBi:,LBj:)
# endif
      real(r8), intent(inout) :: pH(LBi:,LBj:,:)
      real(r8), intent(inout) :: F13Cas(LBi:,LBj:)
      real(r8), intent(inout) :: F13Csa(LBi:,LBj:)
      real(r8), intent(inout) :: CO2flx(LBi:,LBj:)
      real(r8), intent(inout) :: omega_arag(LBi:,LBj:,:)
      real(r8), intent(inout) :: CO2star(LBi:,LBj:,:)
      real(r8), intent(inout) :: pCO2(LBi:,LBj:,:)
#else
      integer, intent(in) :: UBi, UBj
# ifdef MASKING
      real(r8), intent(in) :: rmask(LBi:UBi,LBj:UBj)
# endif
# ifdef BULK_FLUXES
      real(r8), intent(in) :: Uwind(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: Vwind(LBi:UBi,LBj:UBj)
# else
      real(r8), intent(in) :: sustr(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: svstr(LBi:UBi,LBj:UBj)
# endif
      real(r8), intent(inout) :: pH(LBi:UBi,LBj:UBj,UBk)
      real(r8), intent(inout) :: F13Cas(LBi:UBi,LBj:UBj)
      real(r8), intent(inout) :: F13Csa(LBi:UBi,LBj:UBj)
      real(r8), intent(inout) :: CO2flx(LBi:UBi,LBj:UBj)
      real(r8), intent(inout) :: omega_arag(LBi:UBi,LBj:UBj,UBk)
      real(r8), intent(inout) :: CO2star(LBi:UBi,LBj:UBj,UBk)
      real(r8), intent(inout) :: pCO2(LBi:UBi,LBj:UBj,UBk)
# ifdef DIAGNOSTICS_ISO
      real(r8), intent(inout) :: DiaBio2dJ(IminS:ImaxS,NDbio2d)
# endif
#endif
      real(r8), intent(in), dimension(IminS:ImaxS,N(ng)) :: Hz_inv
      real(r8),intent(inout),dimension(IminS:ImaxS,N(ng),NT(ng)) :: Bio
# if defined TANGENT || defined ADJOINT
      real(r8),intent(inout),optional,                                  &
     &  dimension(IminS:ImaxS,N(ng),3:NT(ng),1:6) :: BS
# endif
!
!  Local variable declarations
!
#include "nemuro_carb_def.h"

# if defined NEMURO_CO2_SECULAR
      real(r8) :: pCO2air_secular
# endif
      
      real(r8) :: cff1, cff2, cff3
      real(r8) :: CO2_Flux, CO2_sol, SchmidtN, TempK
      real(r8) :: tempik, saltik, ticik, talkik, phik,co2starik, pco2ik
      real(r8) :: omega_aragik
      real(r8) :: CO2_Flux_as, CO2_Flux_sa 
      real(r8) :: &
        d13C,          &   ! atm 13co2 value
        di12c,         &   ! 12C in DIC
        di13c,         &   ! 13C in DIC
        R13C_atm,      &   ! 13C/12C ratio in atmospheric CO2
        F13C_atm,      &   ! 13C/C fraction in atmospheric CO2
        FLUX13,        &   ! gas flux of 13CO2 (nmol/cm^2/s)
        FLUX13_as,     &
        FLUX13_sa,     &
        eps_aq_g, &   ! eps equilibrium fractionation (CO2_gaseous <-> CO2_aq)
        alpha_aq_g, & ! equilibrium fractionation (CO2_gaseous <-> CO2_aq)
        eps_dic_g,  & ! equilibrium fractionation between total DIC and gaseous CO2
        alpha_dic_g,& ! equilibrium fractionation between total DIC and gaseous CO2
        eps_k,         &   ! eps = ( alpha -1 ) * 1000
        alpha_k,       &   ! kinetic fractionation during gas transfer
        R13C_std,      &   ! 13C/12C PDB standard ratio (Craig, 1957)
        R13C_DICik       ! 13C/12C ratio at current timestep


# ifdef MASKING
      real(r8) :: maskik
# endif
      real(r8) :: cffC, u10squ

      integer :: i, k 
      integer, parameter :: itemp = 1 
      integer, parameter :: isalt = 2 
! instead of #include "set_bounds.h"
      integer :: Istr, Iend
      Istr   =BOUNDS(ng) % Istr   (tile)
      Iend   =BOUNDS(ng) % Iend   (tile)
!
!-----------------------------------------------------------------------
!  Surface CO2 gas exchange.
!-----------------------------------------------------------------------
!
!  Compute equilibrium partial pressure inorganic carbon (ppmv) at the
!  surface.
!
!
          cff1=rho0*550.0_r8 
          cff2=new_dtdays(ng)*0.31_r8*24.0_r8/100.0_r8
!
          DO k=1,N(ng)
            DO i=Istr,Iend
!
!  Compute pCO2 and pH.
!
              tempik=Bio(i,k,itemp)
              saltik=Bio(i,k,isalt)
              ticik=Bio(i,k,iTIC_)
              talkik=Bio(i,k,iTAlk)

#if defined TANGENT || defined ADJOINT
!
!  Save the intermediate Bio variables
!
              IF (PRESENT(BS)) THEN
                BS(i,k,iTIC_,5)=Bio(i,k,iTIC_)
                BS(i,k,iTAlk,5)=Bio(i,k,iTAlk)
              END IF
#endif

#  ifdef MASKING
              maskik=rmask(i,j)
#  endif
              CALL pCO2_water (                                         &
#  ifdef MASKING
     &                         maskik,                                  &
#  endif
     &                         tempik, saltik, ticik, talkik,           &
     &                         0.0_r8, 0.0_r8, phik,omega_aragik,       &
     &                         co2starik,pco2ik)
              pCO2(i,j,k)=pco2ik
              CO2star(i,j,k)=co2starik 
              pH(i,j,k)=phik
              omega_arag(i,j,k) = omega_aragik

!
!  Compute surface CO2 gas exchange.
!
              IF (k.eq.N(ng)) THEN
!
!  Compute CO2 transfer velocity : u10squared (u10 in m/s)
!
# ifdef BULK_FLUXES
                u10squ=Uwind(i,j)**2+Vwind(i,j)**2
# else
                u10squ=cff1*SQRT((0.5_r8*(sustr(i,j)+sustr(i+1,j)))**2+ &
     &                           (0.5_r8*(svstr(i,j)+svstr(i,j+1)))**2)
# endif
                SchmidtN=Acoef-                                         &
     &                   Bio(i,k,itemp)*(Bcoef-                         &
     &                                   Bio(i,k,itemp)*(Ccoef-         &
     &                                   Bio(i,k,itemp)*Dcoef))

# if defined CONSERVATION
                ! closed system during budget calculations
                cff3=cff2*u10squ*SQRT(660.0_r8/SchmidtN)*0.0_r8 
# else                 
                cff3=cff2*u10squ*SQRT(660.0_r8/SchmidtN)
# endif
!
!  Calculate CO2 solubility [mol/(kg.atm)] using Weiss (1974) formula.
! equation 12 
                TempK=0.01_r8*(Bio(i,k,itemp)+273.15_r8)
                CO2_sol=EXP(A1+                                         &
     &                      A2/TempK+                                   &
     &                      A3*LOG(TempK)+                              &
     &                      Bio(i,k,isalt)*(B1+TempK*(B2+B3*TempK)))
!-----------------------------------------------------------------------
!    Setting Rstds. ! 14C/12C NOSAMS standard ratio 
!    13C/12C PDB standard ratio (Craig, 1957) 
!-----------------------------------------------------------------------
               R13C_std = 0.0112372_r8
!-----------------------------------------------------------------------
!     individal discrimination factor of each species with respect to
!     gaseous CO2, temperature dependent, based on Zhang et al. 95      
!-----------------------------------------------------------------------
! However, following Schmittner et al. (2013), we neglect the effect 
! that the carbonate fraction (f CO3) has on αDIC←g because this is much
! smaller (0.05‰) than the temperature effect (3 ‰) -> Per Denith et 
! al., 2020

!-----------------------------------------------------------------------
!     kinetic fraction during gas transfer (per mil) (air-sea CO2
!     exchange) at 21C, Zhang et al 1995, eps_k = -0.95 at 5C
!     alpha_k = ratio of 13CO2 and CO2 gas transfer rates alphak = k13/k
!-----------------------------------------------------------------------
                eps_k = -0.81_r8  
!                 alpha_k = 0.99919_r8
                alpha_k = 1.0_r8 + eps_k / 1000_r8
                
!-----------------------------------------------------------------------
!     temperature dependent equilibrium fraction
!     alpha_aq_g_surf = equilibrium solubilitiy ratio of 13CO2 and 12CO2
!     at equilibrium, alpha_aq_g_surf = R13Caq/R13Cgaseous
!     alpha_dic_g_surf = equilibrium fractionation factor between DIC and 
!     gaseous CO2
!     at equilibrium, alpha_dic_g_surf = R13CDIC / R13Cgasous
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!     individal discrimination factor of each species with respect to
!     gaseous CO2, temperature dependent, based on Zhang et al. 95      
!-----------------------------------------------------------------------
                eps_aq_g = 0.0049_r8 * Bio(i,k,itemp) - 1.31_r8
!  However, following Schmittner et al. (2013), we neglect the effect that the carbonate fraction (f CO3) has on αDIC←g because this is much smaller (0.05 ‰) than the temperature effect (3 ‰) ---> Per Denith et al., 2020
                eps_dic_g = -0.105_r8 * Bio(i,k,itemp) + 10.51_r8
                alpha_aq_g  = 1.0_r8 + eps_aq_g  / 1000_r8
                alpha_dic_g = 1.0_r8 + eps_dic_g / 1000_r8
!                 alpha_aq_g  = 0.9986_r8 - 4.9e-6*Bio(i,k,itemp)
!                 alpha_dic_g = 1.01051_r8 - 1.05e-4*Bio(i,k,itemp)


!-----------------------------------------------------------------------
!     initialize R13C_atm and R14C_atm
!-----------------------------------------------------------------------
! currently setting atmospheric values as constant
!                 d13C = -6.6_r8 ! per mil
                d13C = -8.0_r8 ! per mil

                R13C_atm = R13C_std * ( 1_r8 + d13C / 1000_r8 )
                
! convert R to F -> 13F = 13R/(1 + 13R)
                F13C_atm = R13C_atm / (1+R13C_atm)
                
                di13c = Bio(i,k,iDI13C)
! to prevent division by zero
                if (ticik > 0.0_r8) then
                    R13C_DICik= di13c / ticik
                else
                    R13C_DICik=R13C_std
                endif

!
!  Add in CO2 gas exchange. And now isotopes!
!
# if defined NEMURO_CO2_SECULAR
                pCO2air_secular=pCO2air(ng)+                            &
     &                          1.5_r8*((tdays(ng)-dstart)/365.25_r8)
                CO2_Flux_as = cff3 * CO2_sol * pCO2air_secular
                CO2_Flux_sa = cff3 * CO2_sol * pco2ik
                CO2_Flux=CO2_Flux_as-CO2_Flux_sa
                
                FLUX13_as = alpha_k * alpha_aq_g * cff3 * CO2_sol  &
                & * pCO2air_secular * F13C_atm
                FLUX13_sa = alpha_k * alpha_aq_g * cff3 * CO2_sol  &
                & * pco2ik * R13C_DICik / alpha_dic_g
                
                
# elif defined NEMURO_CO2_TREND
                pCO2air_secular=pCO2air(ng)+pCO2trend(ng)*              &
     &                          ((tdays(ng)-dstart)/365.25_r8)
                CO2_Flux_as = cff3 * CO2_sol * pCO2air_secular
                CO2_Flux_sa = cff3 * CO2_sol * pco2ik
                CO2_Flux=CO2_Flux_as-CO2_Flux_sa

                FLUX13_as = alpha_k * alpha_aq_g * cff3 * CO2_sol  &
                & * pCO2air_secular * F13C_atm
                FLUX13_sa = alpha_k * alpha_aq_g * cff3 * CO2_sol  &
                & * pco2ik * R13C_DICik / alpha_dic_g

                
# elif defined NEMURO_CO2_RCP85
                pCO2air_mo=(/ 0.05_r8,0.67_r8,1.45_r8,2.59_r8,3.03_r8,  &
     &                        2.32_r8,0.72_r8,-1.45_r8,-3.13_r8,        &
     &                        -3.24_r8,-2.07_r8, -0.90_r8 /)
                tmod=MOD(tdays(ng)/(365.25_r8/12.0_r8),12.0_r8)+0.5_r8
                fac2=tmod-REAL(INT(tmod),r8)
                fac1=1.0_r8-fac2
                imo1=INT(tmod)
                IF (imo1.lt.1) imo1=12
                imo2=imo1+1
                IF (imo2.gt.12) imo2=1
                pCO2air_cyc=fac1*pCO2air_mo(imo1)+fac2*pCO2air_mo(imo2)
                pCO2air_trnd=1.8661_r8*((tdays(ng)-dstart)/             &
     &                                 365.25_r8)**1.220_r8
#  ifdef NEMURO_CO2_ENSEMBLE
                pCO2air_trnd=pCO2fac(ng)*pCO2air_trnd
#  endif
                pCO2air_tot = pCO2air(ng)+pCO2air_cyc+pCO2air_trnd
                CO2_Flux=cff3*CO2_sol*(pCO2air_tot-pCO2ik)
                CO2_Flux_as = cff3 * CO2_sol * pCO2air_tot
                CO2_Flux_sa = cff3 * CO2_sol * pco2ik
                
                FLUX13_as = alpha_k * alpha_aq_g * cff3 * CO2_sol  &
                & * pCO2air_tot * F13C_atm
                FLUX13_sa = alpha_k * alpha_aq_g * cff3 * CO2_sol  &
                & * pco2ik * R13C_DICik / alpha_dic_g
                
                if ((i.eq.10).and.(j.eq.10).and.                        &
     &              (tdays(ng).eq.REAL(INT(tdays(ng),r8))))             &
     &            print*,'CO2air',REAL(tdays(ng),r4),                   &
     &                   REAL(pCO2air_cyc,r4),REAL(pCO2air_trnd,r4)
# else
                CO2_Flux=cff3*CO2_sol*(pCO2air(ng)-pco2ik)
                CO2_Flux_as = cff3 * CO2_sol * pCO2air(ng)
                CO2_Flux_sa = cff3 * CO2_sol * pco2ik
                
                FLUX13_as = alpha_k * alpha_aq_g * cff3 * CO2_sol  &
                & * pCO2air(ng) * F13C_atm
                FLUX13_sa = alpha_k * alpha_aq_g * cff3 * CO2_sol  &
                & * pco2ik * R13C_DICik / alpha_dic_g
# endif
! need to scale the air to sea flux into model units 
                FLUX13 = FLUX13_as - FLUX13_sa
                
                Bio(i,k,iTIC_)=Bio(i,k,iTIC_)+CO2_Flux*Hz_inv(i,k)
                Bio(i,k,iDI13C)= Bio(i,k,iDI13C)+FLUX13*Hz_inv(i,k)
                CO2flx(i,j)=CO2_Flux
                F13Cas(i,j) = alpha_k * alpha_aq_g * F13C_atm
                F13Csa(i,j)= alpha_k * alpha_aq_g * R13C_DICik          &

    &           * R13C_std / alpha_dic_g
                
# if defined DIAGNOSTICS_ISO
                 DiaBio2dJ(i,R13C_as) = DiaBio2dJ(i,i13CO2as) +        &
                 & FLUX13_as * Hz_inv(i,k)
                 DiaBio2dJ(i,R13C_sa) = FLUX13_sa * Hz_inv(i,k)
# endif
              END IF
!
            END DO ! i loop
          END DO ! k loop
          RETURN
      END SUBROUTINE co2_exchange_iso_13C
#endif

!
!
!
      SUBROUTINE sinking(tile, ng, j, IminS, ImaxS, LBi, LBj,           &
#if ! defined ASSUMED_SHAPE
     &                   UBi, UBj, UBk,                                 &
#endif
     &                   Hz, Hz_inv, Hz_inv2, Hz_inv3, z_w,             &
     &                   Bio                                            &
#if defined DIAGNOSTICS_BIO
     &                   , DiaBio3d                                     &
#endif
     &                   )
!
      USE mod_param
      USE mod_biology

!
!  Imported variable declarations.
!
      integer, intent(in) :: j, tile, ng, IminS, ImaxS
      integer, intent(in) :: LBi, LBj
      real(r8),intent(inout),dimension(IminS:ImaxS,N(ng),NT(ng)) :: Bio
# ifdef ASSUMED_SHAPE
      real(r8), intent(in) :: Hz(LBi:,LBj:,:)
      real(r8), intent(in) :: z_w(LBi:,LBj:,0:)
#  ifdef DIAGNOSTICS_BIO
      real(r8), intent(inout) :: DiaBio3d(LBi:,LBj:,:,:)
#  endif
# else
      integer, intent(in) :: UBi,UBj, UBk
      real(r8), intent(in) :: Hz(LBi:UBi,LBj:UBj,UBk)
      real(r8), intent(in) :: z_w(LBi:UBi,LBj:UBj,0:UBk)
#  ifdef DIAGNOSTICS_BIO
      real(r8), intent(inout) :: DiaBio3d(LBi:UBi,LBj:UBj,UBk,NDbio3d)
#  endif
# endif
      real(r8), intent(in), dimension(IminS:ImaxS,N(ng)) :: Hz_inv
      real(r8), intent(in), dimension(IminS:ImaxS,N(ng)) :: Hz_inv2
      real(r8), intent(in), dimension(IminS:ImaxS,N(ng)) :: Hz_inv3
!
!  Local variable declarations
!
# if defined BIO_SEDIMENT
      real(r8) :: cff1
# endif
      real(r8) :: cff

      integer :: i, k, isink, ibio, ks 
      integer, dimension(IminS:ImaxS,N(ng)) :: ksource
      
      real(r8) :: cffL, cffR, cu, dltL, dltR
      real(r8), dimension(IminS:ImaxS,0:N(ng)) :: FC
      real(r8), dimension(IminS:ImaxS,N(ng)) :: WL
      real(r8), dimension(IminS:ImaxS,N(ng)) :: WR
      real(r8), dimension(IminS:ImaxS,N(ng)) :: bL
      real(r8), dimension(IminS:ImaxS,N(ng)) :: bR
      real(r8), dimension(IminS:ImaxS,N(ng)) :: qc
      
! instead of #include "set_bounds.h"
      integer :: Istr, Iend
      Istr   =BOUNDS(ng) % Istr   (tile)
      Iend   =BOUNDS(ng) % Iend   (tile)

!Set PONratio variable value before sinking
#if defined N15
# if defined SINK_RATIO
          DO k=1,N(ng)
            DO i=Istr,Iend
              IF ((Bio(i,k,iPON14_).GT.0.0_r8) .AND.                    &
     &           (Bio(i,k,iPON15_).GT.0.0_r8)) THEN
                Bio(i,k,iPONratio)=(Bio(i,k,iPON15_)/Bio(i,k,iPON14_))
              ELSE
                Bio(i,k,iPONratio)=1.006_r8
              ENDIF
            END DO
          END DO
# endif
#endif


!
!-----------------------------------------------------------------------
!  Vertical sinking terms.
!-----------------------------------------------------------------------
!
!  Reconstruct vertical profile of selected biological constituents
!  "Bio(:,:,isink)" in terms of a set of parabolic segments within each
!  grid box. Then, compute semi-Lagrangian flux due to sinking.
!
          SINK_LOOP: DO isink=1,Nsink
            ibio=idsink(isink)
!
!  Copy concentration of biological particulates into scratch array
!  "qc" (q-central, restrict it to be positive) which is hereafter
!  interpreted as a set of grid-box averaged values for biogeochemical
!  constituent concentration.
!
            DO k=1,N(ng)
              DO i=Istr,Iend
                qc(i,k)=Bio(i,k,ibio)
              END DO
            END DO
!
            DO k=N(ng)-1,1,-1
              DO i=Istr,Iend
                FC(i,k)=(qc(i,k+1)-qc(i,k))*Hz_inv2(i,k)
              END DO
            END DO
            DO k=2,N(ng)-1
              DO i=Istr,Iend
                dltR=Hz(i,j,k)*FC(i,k)
                dltL=Hz(i,j,k)*FC(i,k-1)
                cff=Hz(i,j,k-1)+2.0_r8*Hz(i,j,k)+Hz(i,j,k+1)
                cffR=cff*FC(i,k)
                cffL=cff*FC(i,k-1)
!
!  Apply PPM monotonicity constraint to prevent oscillations within the
!  grid box.
!
                IF ((dltR*dltL).le.0.0_r8) THEN
                  dltR=0.0_r8
                  dltL=0.0_r8
                ELSE IF (ABS(dltR).gt.ABS(cffL)) THEN
                  dltR=cffL
                ELSE IF (ABS(dltL).gt.ABS(cffR)) THEN
                  dltL=cffR
                END IF
!
!  Compute right and left side values (bR,bL) of parabolic segments
!  within grid box Hz(k); (WR,WL) are measures of quadratic variations.
!
!  NOTE: Although each parabolic segment is monotonic within its grid
!        box, monotonicity of the whole profile is not guaranteed,
!        because bL(k+1)-bR(k) may still have different sign than
!        qc(i,k+1)-qc(i,k).  This possibility is excluded,
!        after bL and bR are reconciled using WENO procedure.
!
                cff=(dltR-dltL)*Hz_inv3(i,k)
                dltR=dltR-cff*Hz(i,j,k+1)
                dltL=dltL+cff*Hz(i,j,k-1)
                bR(i,k)=qc(i,k)+dltR
                bL(i,k)=qc(i,k)-dltL
                WR(i,k)=(2.0_r8*dltR-dltL)**2
                WL(i,k)=(dltR-2.0_r8*dltL)**2
              END DO
            END DO
            cff=1.0E-14_r8
            DO k=2,N(ng)-2
              DO i=Istr,Iend
                dltL=MAX(cff,WL(i,k  ))
                dltR=MAX(cff,WR(i,k+1))
                bR(i,k)=(dltR*bR(i,k)+dltL*bL(i,k+1))/(dltR+dltL)
                bL(i,k+1)=bR(i,k)
              END DO
            END DO
            DO i=Istr,Iend
              FC(i,N(ng))=0.0_r8            ! NO-flux boundary condition
#if defined LINEAR_CONTINUATION
              bL(i,N(ng))=bR(i,N(ng)-1)
              bR(i,N(ng))=2.0_r8*qc(i,N(ng))-bL(i,N(ng))
#elif defined NEUMANN
              bL(i,N(ng))=bR(i,N(ng)-1)
              bR(i,N(ng))=1.5_r8*qc(i,N(ng))-0.5_r8*bL(i,N(ng))
#else
              bR(i,N(ng))=qc(i,N(ng))       ! default strictly monotonic
              bL(i,N(ng))=qc(i,N(ng))       ! conditions
              bR(i,N(ng)-1)=qc(i,N(ng))
#endif
#if defined LINEAR_CONTINUATION
              bR(i,1)=bL(i,2)
              bL(i,1)=2.0_r8*qc(i,1)-bR(i,1)
#elif defined NEUMANN
              bR(i,1)=bL(i,2)
              bL(i,1)=1.5_r8*qc(i,1)-0.5_r8*bR(i,1)
#else
              bL(i,2)=qc(i,1)               ! bottom grid boxes are
              bR(i,1)=qc(i,1)               ! re-assumed to be
              bL(i,1)=qc(i,1)               ! piecewise constant.
#endif
            END DO
!
!  Apply monotonicity constraint again, since the reconciled interfacial
!  values may cause a non-monotonic behavior of the parabolic segments
!  inside the grid box.
!
            DO k=1,N(ng)
              DO i=Istr,Iend
                dltR=bR(i,k)-qc(i,k)
                dltL=qc(i,k)-bL(i,k)
                cffR=2.0_r8*dltR
                cffL=2.0_r8*dltL
                IF ((dltR*dltL).lt.0.0_r8) THEN
                  dltR=0.0_r8
                  dltL=0.0_r8
                ELSE IF (ABS(dltR).gt.ABS(cffL)) THEN
                  dltR=cffL
                ELSE IF (ABS(dltL).gt.ABS(cffR)) THEN
                  dltL=cffR
                END IF
                bR(i,k)=qc(i,k)+dltR
                bL(i,k)=qc(i,k)-dltL
              END DO
            END DO
!
!  After this moment reconstruction is considered complete. The next
!  stage is to compute vertical advective fluxes, FC. It is expected
!  that sinking may occurs relatively fast, the algorithm is designed
!  to be free of CFL criterion, which is achieved by allowing
!  integration bounds for semi-Lagrangian advective flux to use as
!  many grid boxes in upstream direction as necessary.
!
!  In the two code segments below, WL is the z-coordinate of the
!  departure point for grid box interface z_w with the same indices;
!  FC is the finite volume flux; ksource(:,k) is index of vertical
!  grid box which contains the departure point (restricted by N(ng)).
!  During the search: also add in content of whole grid boxes
!  participating in FC.
!
            cff=new_dtdays(ng)*ABS(new_Wbio(isink,ng))
            DO k=1,N(ng)
              DO i=Istr,Iend
                FC(i,k-1)=0.0_r8
                WL(i,k)=z_w(i,j,k-1)+cff
                WR(i,k)=Hz(i,j,k)*qc(i,k)
                ksource(i,k)=k
              END DO
            END DO
            DO k=1,N(ng)
              DO ks=k,N(ng)-1
                DO i=Istr,Iend
                  IF (WL(i,k).gt.z_w(i,j,ks)) THEN
                    ksource(i,k)=ks+1
                    FC(i,k-1)=FC(i,k-1)+WR(i,ks)
                  END IF
                END DO
              END DO
            END DO
!
!  Finalize computation of flux: add fractional part.
!
            DO k=1,N(ng)
              DO i=Istr,Iend
                ks=ksource(i,k)
                cu=MIN(1.0_r8,(WL(i,k)-z_w(i,j,ks-1))*Hz_inv(i,ks))
                FC(i,k-1)=FC(i,k-1)+                                    &
     &                    Hz(i,j,ks)*cu*                                &
     &                    (bL(i,ks)+                                    &
     &                     cu*(0.5_r8*(bR(i,ks)-bL(i,ks))-              &
     &                         (1.5_r8-cu)*                             &
     &                         (bR(i,ks)+bL(i,ks)-                      &
     &                          2.0_r8*qc(i,ks))))
              END DO
            END DO
#if defined N15
# if defined SINK_RATIO
            IF (ibio.EQ.iPONratio) THEN
              DO i=Istr,Iend
                FC(i,N(ng))=FC(i,N(ng)-1)
              END DO
            ENDIF
# endif
#endif
            DO k=1,N(ng)
              DO i=Istr,Iend
                Bio(i,k,ibio)=qc(i,k)+(FC(i,k)-FC(i,k-1))*Hz_inv(i,k)
#if defined DIAGNOSTICS_BIO
# ifdef DIAGNOSTICS_NEM_NIT
                IF (ibio.eq.iPON_)                                      &
     &            DiaBio3d(i,j,k,iSinkPON)=DiaBio3d(i,j,k,iSinkPON) +   &
     &                         (FC(i,k)-FC(i,k-1))*Hz_inv(i,k)
# endif
# ifdef DIAGNOSTICS_NEM_SIL
                IF (ibio.eq.iOpal)                                      &
     &            DiaBio3d(i,j,k,iSinkOpal)=DiaBio3d(i,j,k,iSinkOpal) + &
     &                         (FC(i,k)-FC(i,k-1))*Hz_inv(i,k)
# endif
#endif
              END DO
            END DO
#ifdef BIO_SEDIMENT
!
!  Particulate fluxes reaching the seafloor are remineralized and returned
!  to the dissolved nutrient pool. Without this conversion, particulate
!  material falls out of the system. This is a temporary fix to restore
!  total nutrient conservation. This may require a time delay
!  remineralization in the future.
!
!  HGA: The original Nemuro model has a restoring upwelling rate (UPW).
!       The code below is an interpretation in terms of the semi-
!       Lagrangian algorithm. What is the correct nutrient path from
!       the benthos to the water column?  NH4 to NO3?
!
            IF (ibio.eq.iPON_) THEN
              DO i=Istr,Iend
                cff1=FC(i,0)*Hz_inv(i,1)
#if defined NEMUCSC
                Bio(i,1,iNH4_)=Bio(i,1,iNH4_)+cff1
#if defined DIAGNOSTICS_BIO
# ifdef DIAGNOSTICS_NEM_NIT
                DiaBio3d(i,j,1,iPON2NH4)=DiaBio3d(i,j,1,iPON2NH4)+cff1
# endif
#endif
#else
                Bio(i,1,iNO3_)=Bio(i,1,iNO3_)+cff1
#if defined DIAGNOSTICS_BIO
# ifdef DIAGNOSTICS_NEM_NIT
                DiaBio3d(i,j,1,iPON2NO3)=DiaBio3d(i,j,1,iPON2NO3)+cff1
# endif
#endif
#endif
              END DO
            ELSE IF (ibio.eq.iopal) THEN
              DO i=Istr,Iend
                cff1=FC(i,0)*Hz_inv(i,1)
                Bio(i,1,iSiOH)=Bio(i,1,iSiOH)+cff1
#if defined DIAGNOSTICS_BIO
# ifdef DIAGNOSTICS_NEM_SIL
                DiaBio3d(i,j,1,iOpal2SiOH)=DiaBio3d(i,j,1,iOpal2SiOH)+cff1
# endif
#endif
              END DO
# ifdef CARB & ! (defined ISO || ISO_13C)
            ELSE IF (ibio.eq.iCalC) THEN
              DO i=Istr,Iend
                cff1=FC(i,0)*Hz_inv(i,1)
                Bio(i,1,iTIC_)=Bio(i,1,iTIC_)+cff1
                Bio(i,1,iTAlk)=Bio(i,1,iTAlk)+2.0_r8*cff1
              END DO
# endif
# ifdef CARB & defined ISO
            ELSE IF (ibio.eq.iCalC) THEN
              DO i=Istr,Iend
                cff1=FC(i,0)*Hz_inv(i,1)
                Bio(i,1,iTIC_)=Bio(i,1,iTIC_)+cff1
                Bio(i,1,iTAlk)=Bio(i,1,iTAlk)+2.0_r8*cff1   
                ! equivlent to 0 per mil and -100
                Bio(i,1,iDI13C)=Bio(i,1,iDI13C)+cff1*0.0112372_r8
                Bio(i,1,iDI14C)=Bio(i,1,iDI14C)+cff1*1.053e-12
              END DO
# endif
            END IF
            
#endif
          END DO SINK_LOOP
#ifdef N15
# ifdef SINK_RATIO
          DO k=1,N(ng)
            DO i=Istr,Iend
              Bio(i,k,iPON14_)=Bio(i,k,iPON_)/(1.0_r8+Bio(i,k,iPONratio))
              Bio(i,k,iPON15_)=Bio(i,k,iPON_)-Bio(i,k,iPON14_)
            END DO
          END DO
# endif
#endif
      RETURN
      END SUBROUTINE sinking
#endif 
      END MODULE mod_nemuro_sms
