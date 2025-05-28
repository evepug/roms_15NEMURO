      SUBROUTINE read_BioPar (model, inp, out, Lwrite)
!
!git $Id$
!================================================== Hernan G. Arango ===
!  Copyright (c) 2002-2025 The ROMS Group                              !
!    Licensed under a MIT/X style license                              !
!    See License_ROMS.md                                               !
!=======================================================================
!                                                                      !
!  This routine reads in Nemuro ecosystem model input parameters.      !
!  They are specified in input script "nemuro.in".                     !
!                                                                      !
!=======================================================================
!
      USE mod_param
      USE mod_parallel
      USE mod_biology
      USE mod_ncparam
      USE mod_scalars
!
      USE inp_decode_mod
!
      implicit none
!
!  Imported variable declarations
!
      logical, intent(in) :: Lwrite
      integer, intent(in) :: model, inp, out
!
!  Local variable declarations.
!
!-- Hajoon
      integer :: ivar
!-- Hajoon
      integer :: Npts, Nval
      integer :: iTrcStr, iTrcEnd
      integer :: i, ifield, igrid, itracer, itrc, ng, nline, status

#if defined DIAGNOSTICS_BIO
      logical, dimension(Ngrids) :: Lbio
#endif

      logical, dimension(NBT,Ngrids) :: Ltrc

      real(r8), dimension(NBT,Ngrids) :: Rbio

      real(dp), dimension(nRval) :: Rval

      character (len=40 ) :: KeyWord
      character (len=256) :: line
      character (len=256), dimension(nCval) :: Cval
!
!-----------------------------------------------------------------------
!  Initialize.
!-----------------------------------------------------------------------
!
      igrid=1                            ! nested grid counter
      itracer=0                          ! LBC tracer counter
      iTrcStr=1                          ! first LBC tracer to process
      iTrcEnd=NBT                        ! last  LBC tracer to process
      nline=0                            ! LBC multi-line counter
!
!-----------------------------------------------------------------------
!  Read in Nemuro biological model parameters.
!-----------------------------------------------------------------------
!
      DO WHILE (.TRUE.)
        READ (inp,'(a)',ERR=10,END=20) line
        status=decode_line(line, KeyWord, Nval, Cval, Rval)
        IF (status.gt.0) THEN
          SELECT CASE (TRIM(KeyWord))
            CASE ('Lbiology')
              Npts=load_l(Nval, Cval, Ngrids, Lbiology)
            CASE ('BioIter')
              Npts=load_i(Nval, Rval, Ngrids, BioIter)
              DO ng=1,Ngrids
                new_dtdays=dt(ng)*sec2day/REAL(BioIter(ng),r8)
              END DO
            CASE ('AttSW')
              Npts=load_r(Nval, Rval, Ngrids, AttSW)
#if defined NEMURO_CHL && ! defined NEMURO_CHL_STATICRATIO
            CASE ('AttChl')
              Npts=load_r(Nval, Rval, Ngrids, AttChl)
            CASE ('Chl2NS_max')
              Npts=load_r(Nval, Rval, Ngrids, Chl2NS_max)
            CASE ('Chl2NL_max')
              Npts=load_r(Nval, Rval, Ngrids, Chl2NL_max)
# if defined NEMURO_CHL_CHL2NMIN
            CASE ('Chl2NS_min')
              Npts=load_r(Nval, Rval, Ngrids, Chl2NS_min)
            CASE ('Chl2NL_min')
              Npts=load_r(Nval, Rval, Ngrids, Chl2NL_min)
# endif
# if defined NEMURO_CHL_GEIDER_ACCLIM || defined NEMURO_CHL_NUDGECHL2N
            CASE ('chltacclimS')
              Npts=load_r(Nval, Rval, Ngrids, chltacclimS)
            CASE ('chltacclimL')
              Npts=load_r(Nval, Rval, Ngrids, chltacclimL)
# endif
#else
            CASE ('AttPS')
              Npts=load_r(Nval, Rval, Ngrids, AttPS)
            CASE ('AttPL')
              Npts=load_r(Nval, Rval, Ngrids, AttPL)
#endif
            CASE ('PARfrac')
              Npts=load_r(Nval, Rval, Ngrids, PARfrac)
            CASE ('AlphaPS')
              Npts=load_r(Nval, Rval, Ngrids, AlphaPS)
            CASE ('AlphaPL')
              Npts=load_r(Nval, Rval, Ngrids, AlphaPL)
#if ! defined NEMURO_CHL_GEIDER && ! defined NEMURO_CHL_NUDGECHL2N
            CASE ('BetaPS')
              Npts=load_r(Nval, Rval, Ngrids, BetaPS)
            CASE ('BetaPL')
              Npts=load_r(Nval, Rval, Ngrids, BetaPL)
#endif
#if defined BIOMIN_PARAMETER
            CASE ('BioMin')
              Npts=load_r(Nval, Rval, Ngrids, BioMin)
#endif
            CASE ('VmaxS')
              Npts=load_r(Nval, Rval, Ngrids, VmaxS)
            CASE ('VmaxL')
              Npts=load_r(Nval, Rval, Ngrids, VmaxL)
            CASE ('KNO3S')
              Npts=load_r(Nval, Rval, Ngrids, KNO3S)
            CASE ('KNO3L')
              Npts=load_r(Nval, Rval, Ngrids, KNO3L)
            CASE ('KNH4S')
              Npts=load_r(Nval, Rval, Ngrids, KNH4S)
            CASE ('KNH4L')
              Npts=load_r(Nval, Rval, Ngrids, KNH4L)
            CASE ('KSiL')
              Npts=load_r(Nval, Rval, Ngrids, KSiL)
            CASE ('PusaiS')
              Npts=load_r(Nval, Rval, Ngrids, PusaiS)
            CASE ('PusaiL')
              Npts=load_r(Nval, Rval, Ngrids, PusaiL)
            CASE ('KGppS')
              Npts=load_r(Nval, Rval, Ngrids, KGppS)
            CASE ('KGppL')
              Npts=load_r(Nval, Rval, Ngrids, KGppL)
            CASE ('ResPS0')
              Npts=load_r(Nval, Rval, Ngrids, ResPS0)
            CASE ('ResPL0')
              Npts=load_r(Nval, Rval, Ngrids, ResPL0)
            CASE ('KResPS')
              Npts=load_r(Nval, Rval, Ngrids, KResPS)
            CASE ('KResPL')
              Npts=load_r(Nval, Rval, Ngrids, KResPL)
            CASE ('GammaS')
              Npts=load_r(Nval, Rval, Ngrids, GammaS)
            CASE ('GammaL')
              Npts=load_r(Nval, Rval, Ngrids, GammaL)
            CASE ('MorPS0')
              Npts=load_r(Nval, Rval, Ngrids, MorPS0)
            CASE ('MorPL0')
              Npts=load_r(Nval, Rval, Ngrids, MorPL0)
            CASE ('KMorPS')
              Npts=load_r(Nval, Rval, Ngrids, KMorPS)
            CASE ('KMorPL')
              Npts=load_r(Nval, Rval, Ngrids, KMorPL)
            CASE ('GRmaxSps')
              Npts=load_r(Nval, Rval, Ngrids, GRmaxSps)
#if defined NEMUCSC
            CASE ('GRmaxSpl')
              Npts=load_r(Nval, Rval, Ngrids, GRmaxSpl)
#endif
            CASE ('GRmaxLps')
              Npts=load_r(Nval, Rval, Ngrids, GRmaxLps)
            CASE ('GRmaxLpl')
              Npts=load_r(Nval, Rval, Ngrids, GRmaxLpl)
            CASE ('GRmaxLzs')
              Npts=load_r(Nval, Rval, Ngrids, GRmaxLzs)
            CASE ('GRmaxPpl')
              Npts=load_r(Nval, Rval, Ngrids, GRmaxPpl)
            CASE ('GRmaxPzs')
              Npts=load_r(Nval, Rval, Ngrids, GRmaxPzs)
            CASE ('GRmaxPzl')
              Npts=load_r(Nval, Rval, Ngrids, GRmaxPzl)
            CASE ('KGraS')
              Npts=load_r(Nval, Rval, Ngrids, KGraS)
            CASE ('KGraL')
              Npts=load_r(Nval, Rval, Ngrids, KGraL)
            CASE ('KGraP')
              Npts=load_r(Nval, Rval, Ngrids, KGraP)
            CASE ('LamS')
              Npts=load_r(Nval, Rval, Ngrids, LamS)
            CASE ('LamL')
              Npts=load_r(Nval, Rval, Ngrids, LamL)
            CASE ('LamP')
              Npts=load_r(Nval, Rval, Ngrids, LamP)
            CASE ('KPS2ZS')
              Npts=load_r(Nval, Rval, Ngrids, KPS2ZS)
#if defined NEMUCSC
            CASE ('KPL2ZS')
              Npts=load_r(Nval, Rval, Ngrids, KPL2ZS)
#endif
            CASE ('KPS2ZL')
              Npts=load_r(Nval, Rval, Ngrids, KPS2ZL)
            CASE ('KPL2ZL')
              Npts=load_r(Nval, Rval, Ngrids, KPL2ZL)
            CASE ('KZS2ZL')
              Npts=load_r(Nval, Rval, Ngrids, KZS2ZL)
            CASE ('KPL2ZP')
              Npts=load_r(Nval, Rval, Ngrids, KPL2ZP)
            CASE ('KZS2ZP')
              Npts=load_r(Nval, Rval, Ngrids, KZS2ZP)
            CASE ('KZL2ZP')
              Npts=load_r(Nval, Rval, Ngrids, KZL2ZP)
            CASE ('PS2ZSstar')
              Npts=load_r(Nval, Rval, Ngrids, PS2ZSstar)
#if defined NEMUCSC
            CASE ('PL2ZSstar')
              Npts=load_r(Nval, Rval, Ngrids, PL2ZSstar)
#endif
            CASE ('PS2ZLstar')
              Npts=load_r(Nval, Rval, Ngrids, PS2ZLstar)
            CASE ('PL2ZLstar')
              Npts=load_r(Nval, Rval, Ngrids, PL2ZLstar)
            CASE ('ZS2ZLstar')
              Npts=load_r(Nval, Rval, Ngrids, ZS2ZLstar)
            CASE ('PL2ZPstar')
              Npts=load_r(Nval, Rval, Ngrids, PL2ZPstar)
            CASE ('ZS2ZPstar')
              Npts=load_r(Nval, Rval, Ngrids, ZS2ZPstar)
            CASE ('ZL2ZPstar')
              Npts=load_r(Nval, Rval, Ngrids, ZL2ZPstar)
            CASE ('PusaiPL')
              Npts=load_r(Nval, Rval, Ngrids, PusaiPL)
            CASE ('PusaiZS')
              Npts=load_r(Nval, Rval, Ngrids, PusaiZS)
            CASE ('MorZS0')
              Npts=load_r(Nval, Rval, Ngrids, MorZS0)
            CASE ('MorZL0')
              Npts=load_r(Nval, Rval, Ngrids, MorZL0)
            CASE ('MorZP0')
              Npts=load_r(Nval, Rval, Ngrids, MorZP0)
            CASE ('KMorZS')
              Npts=load_r(Nval, Rval, Ngrids, KMorZS)
            CASE ('KMorZL')
              Npts=load_r(Nval, Rval, Ngrids, KMorZL)
            CASE ('KMorZP')
              Npts=load_r(Nval, Rval, Ngrids, KMorZP)
            CASE ('AlphaZS')
              Npts=load_r(Nval, Rval, Ngrids, AlphaZS)
            CASE ('AlphaZL')
              Npts=load_r(Nval, Rval, Ngrids, AlphaZL)
            CASE ('AlphaZP')
              Npts=load_r(Nval, Rval, Ngrids, AlphaZP)
            CASE ('BetaZS')
              Npts=load_r(Nval, Rval, Ngrids, BetaZS)
            CASE ('BetaZL')
              Npts=load_r(Nval, Rval, Ngrids, BetaZL)
            CASE ('BetaZP')
              Npts=load_r(Nval, Rval, Ngrids, BetaZP)
            CASE ('Nit0')
              Npts=load_r(Nval, Rval, Ngrids, Nit0)
            CASE ('VP2N0')
              Npts=load_r(Nval, Rval, Ngrids, VP2N0)
            CASE ('VP2D0')
              Npts=load_r(Nval, Rval, Ngrids, VP2D0)
            CASE ('VD2N0')
              Npts=load_r(Nval, Rval, Ngrids, VD2N0)
            CASE ('VO2S0')
              Npts=load_r(Nval, Rval, Ngrids, VO2S0)
            CASE ('KNit')
              Npts=load_r(Nval, Rval, Ngrids, KNit)
            CASE ('KP2D')
              Npts=load_r(Nval, Rval, Ngrids, KP2D)
            CASE ('KP2N')
              Npts=load_r(Nval, Rval, Ngrids, KP2N)
            CASE ('KD2N')
              Npts=load_r(Nval, Rval, Ngrids, KD2N)
            CASE ('KO2S')
              Npts=load_r(Nval, Rval, Ngrids, KO2S)
            CASE ('RSiN')
              Npts=load_r(Nval, Rval, Ngrids, RSiN)
            CASE ('setVPON')
              Npts=load_r(Nval, Rval, Ngrids, setVPON)
              DO ng=1,Ngrids
                new_Wbio(1,ng)=setVPON(ng)
#if defined CARB & ! defined KO_CARB_SINK
                new_Wbio(3,ng)=setVPON(ng)
in conflict with N15 sinking code
to turn on CARB and N15, will need to resolve
#endif
              END DO
            CASE ('setVOpal')
              Npts=load_r(Nval, Rval, Ngrids, setVOpal)
              DO ng=1,Ngrids
                new_Wbio(2,ng)=setVOpal(ng)
              END DO
#if defined N15
# ifdef SINK_RATIO
            CASE ('setVPONratio')
              Npts=load_r(Nval, Rval, Ngrids, setVPONratio)
              DO ng=1,Ngrids
                new_Wbio(3,ng)=setVPONratio(ng)
              END DO
# else
            CASE ('setVPON14')
              Npts=load_r(Nval, Rval, Ngrids, setVPON14)
              DO ng=1,Ngrids
                new_Wbio(3,ng)=setVPON14(ng)
              END DO
            CASE ('setVPON15')
              Npts=load_r(Nval, Rval, Ngrids, setVPON15)
              DO ng=1,Ngrids
                new_Wbio(4,ng)=setVPON15(ng)
              END DO
# endif
#endif
#if defined NEMURO_CHL && defined NEMURO_CHL_STATICRATIO
            CASE ('Chl2NS')
              Npts=load_r(Nval, Rval, Ngrids, Chl2NS)
            CASE ('Chl2NL')
              Npts=load_r(Nval, Rval, Ngrids, Chl2NL)
#endif
#ifdef CARB
            CASE ('RedCN')
              Npts=load_r(Nval, Rval, Ngrids, RedCN)
            CASE ('pCO2air')
              Npts=load_r(Nval, Rval, Ngrids, pCO2air)
# if defined NEMURO_CO2_TREND
            CASE ('pCO2trend')
              Npts=load_r(Nval, Rval, Ngrids, pCO2trend)
# endif
#endif
#if defined N15
            CASE ('eps_GppNO3')
              Npts=load_r(Nval, Rval, Ngrids, eps_GppNO3)
            CASE ('eps_GppNH4')
              Npts=load_r(Nval, Rval, Ngrids, eps_GppNH4)
            CASE ('eps_exc')
              Npts=load_r(Nval, Rval, Ngrids, eps_exc)
            CASE ('eps_nitrif')
              Npts=load_r(Nval, Rval, Ngrids, eps_nitrif)
            CASE ('eps_remin')
              Npts=load_r(Nval, Rval, Ngrids, eps_remin)
            CASE ('eps_decomp')
              Npts=load_r(Nval, Rval, Ngrids, eps_decomp)
            CASE ('eps_reminDON')
              Npts=load_r(Nval, Rval, Ngrids, eps_reminDON)
# if defined DENIT
            CASE ('eps_denit')
              Npts=load_r(Nval, Rval, Ngrids, eps_denit)
# endif 
#endif
#ifdef NEM_IRON_LIMIT
            CASE ('T_Fe')
              Npts=load_r(Nval, Rval, Ngrids, T_Fe)
            CASE ('A_Fe')
              Npts=load_r(Nval, Rval, Ngrids, A_Fe)
            CASE ('B_Fe')
              Npts=load_r(Nval, Rval, Ngrids, B_Fe)
            CASE ('SK_FeC')
              Npts=load_r(Nval, Rval, Ngrids, SK_FeC)
            CASE ('LK_FeC')
              Npts=load_r(Nval, Rval, Ngrids, LK_FeC)
            CASE ('FeRR')
              Npts=load_r(Nval, Rval, Ngrids, FeRR)
# ifdef NEM_IRON_RELAX
            CASE ('FeHmin')
              Npts=load_r(Nval, Rval, Ngrids, FeHmin)
            CASE ('FeNudgTime')
              Npts=load_r(Nval, Rval, Ngrids, FeNudgTime)
            CASE ('FeMax')
              Npts=load_r(Nval, Rval, Ngrids, FeMax)
# endif
#endif
#ifdef NEM_SPONGE
            CASE ('nemSpongeN')
              Npts=load_i(Nval, Rval, Ngrids, nemSpongeN)
            CASE ('nemSpongeF')
              Npts=load_r(Nval, Rval, Ngrids, nemSpongeF)
#endif
            CASE ('TNU2')
              Npts=load_r(Nval, Rval, NBT, Ngrids, Rbio)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idbio(itrc)
                  nl_tnu2(i,ng)=Rbio(itrc,ng)
                END DO
              END DO
            CASE ('TNU4')
              Npts=load_r(Nval, Rval, NBT, Ngrids, Rbio)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idbio(itrc)
                  nl_tnu4(i,ng)=Rbio(itrc,ng)
                END DO
              END DO
            CASE ('ad_TNU2')
              Npts=load_r(Nval, Rval, NBT, Ngrids, Rbio)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idbio(itrc)
                  ad_tnu2(i,ng)=Rbio(itrc,ng)
                  tl_tnu2(i,ng)=Rbio(itrc,ng)
                END DO
              END DO
            CASE ('ad_TNU4')
              Npts=load_r(Nval, Rval, NBT, Ngrids, Rbio)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idbio(itrc)
                  ad_tnu4(i,ng)=Rbio(itrc,ng)
                  tl_tnu4(i,ng)=Rbio(itrc,ng)
                END DO
              END DO
            CASE ('LtracerSponge')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idbio(itrc)
                  LtracerSponge(i,ng)=Ltrc(itrc,ng)
                END DO
              END DO
            CASE ('AKT_BAK')
              Npts=load_r(Nval, Rval, NBT, Ngrids, Rbio)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idbio(itrc)
                  Akt_bak(i,ng)=Rbio(itrc,ng)
                END DO
              END DO
            CASE ('ad_AKT_fac')
              Npts=load_r(Nval, Rval, NBT, Ngrids, Rbio)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idbio(itrc)
                  ad_Akt_fac(i,ng)=Rbio(itrc,ng)
                  tl_Akt_fac(i,ng)=Rbio(itrc,ng)
                END DO
              END DO
            CASE ('TNUDG')
              Npts=load_r(Nval, Rval, NBT, Ngrids, Rbio)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idbio(itrc)
                  Tnudg(i,ng)=Rbio(itrc,ng)
                END DO
              END DO
            CASE ('Hadvection')
              IF (itracer.lt.NBT) THEN
                itracer=itracer+1
              ELSE
                itracer=1                      ! next nested grid
              END IF
              itrc=idbio(itracer)
              Npts=load_tadv(Nval, Cval, line, nline, itrc, igrid,      &
     &                       itracer, idbio(iTrcStr), idbio(iTrcEnd),   &
     &                       Vname(1,idTvar(itrc)),                     &
     &                       Hadvection)
            CASE ('Vadvection')
              IF (itracer.lt.NBT) THEN
                itracer=itracer+1
              ELSE
                itracer=1                      ! next nested grid
              END IF
              itrc=idbio(itracer)
              Npts=load_tadv(Nval, Cval, line, nline, itrc, igrid,      &
     &                       itracer, idbio(iTrcStr), idbio(iTrcEnd),   &
     &                       Vname(1,idTvar(itrc)),                     &
     &                       Vadvection)
#if defined ADJOINT || defined TANGENT || defined TL_IOMS
            CASE ('ad_Hadvection')
              IF (itracer.lt.NBT) THEN
                itracer=itracer+1
              ELSE
                itracer=1                      ! next nested grid
              END IF
              itrc=idbio(itracer)
              Npts=load_tadv(Nval, Cval, line, nline, itrc, igrid,      &
     &                       itracer, idbio(iTrcStr), idbio(iTrcEnd),   &
     &                       Vname(1,idTvar(itrc)),                     &
     &                       ad_Hadvection)
            CASE ('Vadvection')
              IF (itracer.lt.(NBT) THEN
                itracer=itracer+1
              ELSE
                itracer=1                      ! next nested grid
              END IF
              itrc=idbio(itracer)
              Npts=load_tadv(Nval, Cval, line, nline, itrc, igrid,      &
     &                       itracer, idbio(iTrcStr), idbio(iTrcEnd),   &
     &                       Vname(1,idTvar(itrc)),                     &
     &                       ad_Vadvection)
#endif
            CASE ('LBC(isTvar)')
              IF (itracer.lt.NBT) THEN
                itracer=itracer+1
              ELSE
                itracer=1                      ! next nested grid
              END IF
              ifield=isTvar(idbio(itracer))
              Npts=load_lbc(Nval, Cval, line, nline, ifield, igrid,     &
     &                      idbio(iTrcStr), idbio(iTrcEnd),             &
     &                      Vname(1,idTvar(idbio(itracer))), LBC)
#if defined ADJOINT || defined TANGENT || defined TL_IOMS
            CASE ('ad_LBC(isTvar)')
              IF (itracer.lt.NBT) THEN
                itracer=itracer+1
              ELSE
                itracer=1                      ! next nested grid
              END IF
              ifield=isTvar(idbio(itracer))
              Npts=load_lbc(Nval, Cval, line, nline, ifield, igrid,     &
     &                      idbio(iTrcStr), idbio(iTrcEnd),             &
     &                      Vname(1,idTvar(idbio(itracer))), ad_LBC)
#endif
            CASE ('LtracerSrc')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idbio(itrc)
                  LtracerSrc(i,ng)=Ltrc(itrc,ng)
                END DO
              END DO
            CASE ('LtracerCLM')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idbio(itrc)
                  LtracerCLM(i,ng)=Ltrc(itrc,ng)
                END DO
              END DO
            CASE ('LnudgeTCLM')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idbio(itrc)
                  LnudgeTCLM(i,ng)=Ltrc(itrc,ng)
                END DO
              END DO
            CASE ('Hout(idTvar)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idTvar(idbio(itrc))
                  IF (i.eq.0) THEN
                    IF (Master) WRITE (out,30)                          &
     &                                'idTvar(idbio(', itrc, '))'
                    exit_flag=5
                    RETURN
                  END IF
                  Hout(i,ng)=Ltrc(itrc,ng)
                END DO
              END DO
            CASE ('Hout(idTsur)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idTsur(idbio(itrc))
                  IF (i.eq.0) THEN
                    IF (Master) WRITE (out,30)                          &
     &                                'idTsur(idbio(', itrc, '))'
                    exit_flag=5
                    RETURN
                  END IF
                  Hout(i,ng)=Ltrc(itrc,ng)
                END DO
              END DO
! #ifdef CONSERVATION
!             CASE ('Hout(idCalA)')
!               Npts=load_l(Nval, Cval, 1, Ngrids, Ltrc)
!               DO ng=1,Ngrids
!                 Hout(idCalA,ng)=Ltrc(1,ng)
!               END DO
! #endif
#if (defined NEMURO || defined NEMURO_RESTRUCT) && defined NEMURO_CARB_EXTRAOUT
            CASE ('Hout(idCflx)')
              Npts=load_l(Nval, Cval, 1, Ngrids, Ltrc)
              DO ng=1,Ngrids
                Hout(idCflx,ng)=Ltrc(1,ng)
              END DO
# if defined ISO || defined ISO_13C
            CASE ('Hout(idF13Cas)')
              Npts=load_l(Nval, Cval, 1, Ngrids, Ltrc)
              DO ng=1,Ngrids
                Hout(idF13Cas,ng)=Ltrc(1,ng)
              END DO
            CASE ('Hout(idF13Csa)')
              Npts=load_l(Nval, Cval, 1, Ngrids, Ltrc)
              DO ng=1,Ngrids
                Hout(idF13Csa,ng)=Ltrc(1,ng)
              END DO
# endif
            CASE ('Hout(idpCO2)')
              Npts=load_l(Nval, Cval, 1, Ngrids, Ltrc)
              DO ng=1,Ngrids
                Hout(idpCO2,ng)=Ltrc(1,ng)
              END DO
            CASE ('Hout(idOmeg)')
              Npts=load_l(Nval, Cval, 1, Ngrids, Ltrc)
              DO ng=1,Ngrids
                Hout(idOmeg,ng)=Ltrc(1,ng)
              END DO
            CASE ('Hout(idpH)')
              Npts=load_l(Nval, Cval, 1, Ngrids, Ltrc)
              DO ng=1,Ngrids
                Hout(idpH,ng)=Ltrc(1,ng)
              END DO
#endif
            CASE ('Qout(idTvar)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idTvar(idbio(itrc))
                  Qout(i,ng)=Ltrc(itrc,ng)
                END DO
              END DO
            CASE ('Qout(idsurT)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idsurT(idbio(itrc))
                  IF (i.eq.0) THEN
                    IF (Master) WRITE (out,30)                          &
     &                                'idsurT(idbio(', itrc, '))'
                    exit_flag=5
                    RETURN
                  END IF
                  Qout(i,ng)=Ltrc(itrc,ng)
                END DO
              END DO
            CASE ('Qout(idTsur)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idTsur(idbio(itrc))
                  Qout(i,ng)=Ltrc(itrc,ng)
                END DO
              END DO
#if (defined NEMURO || defined NEMURO_RESTRUCT) && defined NEMURO_CARB_EXTRAOUT
            CASE ('Qout(idCflx)')
              Npts=load_l(Nval, Cval, 1, Ngrids, Ltrc)
              DO ng=1,Ngrids
                Qout(idCflx,ng)=Ltrc(1,ng)
              END DO
            CASE ('Qout(idpCO2)')
              Npts=load_l(Nval, Cval, 1, Ngrids, Ltrc)
              DO ng=1,Ngrids
                Qout(idpCO2,ng)=Ltrc(1,ng)
              END DO
            CASE ('Qout(idpH)')
              Npts=load_l(Nval, Cval, 1, Ngrids, Ltrc)
              DO ng=1,Ngrids
                Qout(idpH,ng)=Ltrc(1,ng)
              END DO
#endif
#if defined AVERAGES    || \
   (defined AD_AVERAGES && defined ADJOINT) || \
   (defined RP_AVERAGES && defined TL_IOMS) || \
   (defined TL_AVERAGES && defined TANGENT)
            CASE ('Aout(idTvar)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idTvar(idbio(itrc))
                  Aout(i,ng)=Ltrc(itrc,ng)
                END DO
              END DO
            CASE ('Aout(idTTav)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idTTav(idbio(itrc))
                  Aout(i,ng)=Ltrc(itrc,ng)
                END DO
              END DO
            CASE ('Aout(idUTav)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idUTav(idbio(itrc))
                  Aout(i,ng)=Ltrc(itrc,ng)
                END DO
              END DO
            CASE ('Aout(idVTav)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=idVTav(idbio(itrc))
                  Aout(i,ng)=Ltrc(itrc,ng)
                END DO
              END DO
            CASE ('Aout(iHUTav)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=iHUTav(idbio(itrc))
                  Aout(i,ng)=Ltrc(itrc,ng)
                END DO
              END DO
            CASE ('Aout(iHVTav)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO itrc=1,NBT
                  i=iHVTav(idbio(itrc))
                  Aout(i,ng)=Ltrc(itrc,ng)
                END DO
              END DO
#endif
#ifdef DIAGNOSTICS_TS
            CASE ('Dout(iTrate)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO i=1,NBT
                  itrc=idbio(i)
                  Dout(idDtrc(itrc,iTrate),ng)=Ltrc(i,ng)
                END DO
              END DO
            CASE ('Dout(iThadv)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO i=1,NBT
                  itrc=idbio(i)
                  Dout(idDtrc(itrc,iThadv),ng)=Ltrc(i,ng)
                END DO
              END DO
            CASE ('Dout(iTxadv)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO i=1,NBT
                  itrc=idbio(i)
                  Dout(idDtrc(itrc,iTxadv),ng)=Ltrc(i,ng)
                END DO
              END DO
            CASE ('Dout(iTyadv)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO i=1,NBT
                  itrc=idbio(i)
                  Dout(idDtrc(itrc,iTyadv),ng)=Ltrc(i,ng)
                END DO
              END DO
            CASE ('Dout(iTvadv)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO i=1,NBT
                  itrc=idbio(i)
                  Dout(idDtrc(itrc,iTvadv),ng)=Ltrc(i,ng)
                END DO
              END DO
# if defined TS_DIF2 || defined TS_DIF4
            CASE ('Dout(iThdif)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO i=1,NBT
                  itrc=idbio(i)
                  Dout(idDtrc(itrc,iThdif),ng)=Ltrc(i,ng)
                END DO
              END DO
            CASE ('Dout(iTxdif)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO i=1,NBT
                  itrc=idbio(i)
                  Dout(idDtrc(itrc,iTxdif),ng)=Ltrc(i,ng)
                END DO
              END DO
            CASE ('Dout(iTydif)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO i=1,NBT
                  itrc=idbio(i)
                  Dout(idDtrc(itrc,iTydif),ng)=Ltrc(i,ng)
                END DO
              END DO
#  if defined MIX_GEO_TS || defined MIX_ISO_TS
            CASE ('Dout(iTsdif)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO i=1,NBT
                  itrc=idbio(i)
                  Dout(idDtrc(itrc,iTsdif),ng)=Ltrc(i,ng)
                END DO
              END DO
#  endif
# endif
            CASE ('Dout(iTvdif)')
              Npts=load_l(Nval, Cval, NBT, Ngrids, Ltrc)
              DO ng=1,Ngrids
                DO i=1,NBT
                  itrc=idbio(i)
                  Dout(idDtrc(itrc,iTvdif),ng)=Ltrc(i,ng)
                END DO
              END DO
#endif
#ifdef DIAGNOSTICS_BIO
# if defined DIAGNOSTICS_NEM_LIM
          CASE ('Dout(iNO3LimSp)')
            IF (iDbio3(iNO3LimSp).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iNO3LimSp)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iNO3LimSp)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iNO3LimLp)')
            IF (iDbio3(iNO3LimLp).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iNO3LimLp)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iNO3LimLp)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iNH4LimSp)')
            IF (iDbio3(iNH4LimSp).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iNH4LimSp)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iNH4LimSp)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iNH4LimLp)')
            IF (iDbio3(iNH4LimLp).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iNH4LimLp)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iNH4LimLp)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iSiLimLp)')
            IF (iDbio3(iSiLimLp).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iSiLimLp)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iSiLimLp)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
#  if defined NEM_IRON_LIMIT
          CASE ('Dout(iFeLimSp)')
            IF (iDbio3(iFeLimSp).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iFeLimSp)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iFeLimSp)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iFeLimLp)')
            IF (iDbio3(iFeLimLp).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iFeLimLp)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iFeLimLp)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
#  endif
# endif
# if defined DIAGNOSTICS_NEM_PHY || defined DIAGNOSTICS_NEM_NIT
          CASE ('Dout(iGppNPS)')
            IF (iDbio3(iGppNPS).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iGppNPS)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iGppNPS)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iGppAPS)')
            IF (iDbio3(iGppAPS).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iGppAPS)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iGppAPS)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iGppNPL)')
            IF (iDbio3(iGppNPL).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iGppNPL)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iGppNPL)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iGppAPL)')
            IF (iDbio3(iGppAPL).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iGppAPL)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iGppAPL)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iResPS2NO3)')
            IF (iDbio3(iResPS2NO3).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iResPS2NO3)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iResPS2NO3)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iResPL2NO3)')
            IF (iDbio3(iResPL2NO3).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iResPL2NO3)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iResPL2NO3)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iResPS2NH4)')
            IF (iDbio3(iResPS2NH4).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iResPS2NH4)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iResPS2NH4)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iResPL2NH4)')
            IF (iDbio3(iResPL2NH4).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iResPL2NH4)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iResPL2NH4)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
# endif
# ifdef DIAGNOSTICS_NEM_PHY
          CASE ('Dout(iExcPS)')
            IF (iDbio3(iExcPS).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iExcPS)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iExcPS)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iExcPL)')
            IF (iDbio3(iExcPL).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iExcPL)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iExcPL)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iMorPS)')
            IF (iDbio3(iMorPS).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iMorPS)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iMorPS)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iMorPL)')
            IF (iDbio3(iMorPL).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iMorPL)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iMorPL)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
# endif
# if defined DIAGNOSTICS_NEM_PHY || defined DIAGNOSTICS_NEM_ZOO
          CASE ('Dout(iGraPS2ZS)')
            IF (iDbio3(iGraPS2ZS).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iGraPS2ZS)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iGraPS2ZS)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iGraPS2ZL)')
            IF (iDbio3(iGraPS2ZL).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iGraPS2ZL)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iGraPS2ZL)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
#  if defined NEMUCSC
          CASE ('Dout(iGraPL2ZS)')
            IF (iDbio3(iGraPL2ZS).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iGraPL2ZS)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iGraPL2ZS)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
#  endif
          CASE ('Dout(iGraPL2ZL)')
            IF (iDbio3(iGraPL2ZL).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iGraPL2ZL)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iGraPL2ZL)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iGraPL2ZP)')
            IF (iDbio3(iGraPL2ZP).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iGraPL2ZP)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iGraPL2ZP)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
# endif
# ifdef DIAGNOSTICS_NEM_ZOO
          CASE ('Dout(iGraZS2ZL)')
            IF (iDbio3(iGraZS2ZL).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iGraZS2ZL)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iGraZS2ZL)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iGraZS2ZP)')
            IF (iDbio3(iGraZS2ZP).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iGraZS2ZP)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iGraZS2ZP)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iGraZL2ZP)')
            IF (iDbio3(iGraZL2ZP).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iGraZL2ZP)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iGraZL2ZP)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
# endif
# if defined DIAGNOSTICS_NEM_ZOO || defined DIAGNOSTICS_NEM_NIT
          CASE ('Dout(iEgeZS)')
            IF (iDbio3(iEgeZS).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iEgeZS)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iEgeZS)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iEgeZL)')
            IF (iDbio3(iEgeZL).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iEgeZL)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iEgeZL)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iEgeZP)')
            IF (iDbio3(iEgeZP).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iEgeZP)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iEgeZP)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iExcZS)')
            IF (iDbio3(iExcZS).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iExcZS)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iExcZS)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iExcZL)')
            IF (iDbio3(iExcZL).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iExcZL)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iExcZL)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iExcZP)')
            IF (iDbio3(iExcZP).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iExcZP)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iExcZP)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iMorZS)')
            IF (iDbio3(iMorZS).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iMorZS)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iMorZS)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iMorZL)')
            IF (iDbio3(iMorZL).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iMorZL)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iMorZL)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iMorZP)')
            IF (iDbio3(iMorZP).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iMorZP)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iMorZP)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
# endif
# ifdef DIAGNOSTICS_NEM_NIT
          CASE ('Dout(iNH42NO3)')
            IF (iDbio3(iNH42NO3).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iNH42NO3)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iNH42NO3)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iPON2DON)')
            IF (iDbio3(iPON2DON).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iPON2DON)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iPON2DON)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iPON2NH4)')
            IF (iDbio3(iPON2NH4).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iPON2NH4)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iPON2NH4)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iPON2NO3)')
            IF (iDbio3(iPON2NO3).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iPON2NO3)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iPON2NO3)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iDON2NH4)')
            IF (iDbio3(iDON2NH4).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iDON2NH4)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iDON2NH4)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iSinkPON)')
            IF (iDbio3(iSinkPON).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iSinkPON)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iSinkPON)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
# endif
# ifdef DIAGNOSTICS_NEM_SIL
          CASE ('Dout(iOpal2SiOH)')
            IF (iDbio3(iOpal2SiOH).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iOpal2SiOH)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iOpal2SiOH)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iSinkOpal)')
            IF (iDbio3(iSinkOpal).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iSinkOpal)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iSinkOpal)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
# endif
# if defined DIAGNOSTICS_NEM_PHY
          CASE ('Dout(iFudgePS)')
            IF (iDbio3(iFudgePS).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iFudgePS)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iFudgePS)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iFudgePL)')
            IF (iDbio3(iFudgePL).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iFudgePL)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iFudgePL)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
# endif
# if defined DIAGNOSTICS_NEM_ZOO
          CASE ('Dout(iFudgeZS)')
            IF (iDbio3(iFudgeZS).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iFudgeZS)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iFudgeZS)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iFudgeZL)')
            IF (iDbio3(iFudgeZL).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iFudgeZL)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iFudgeZL)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iFudgeZP)')
            IF (iDbio3(iFudgeZP).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iFudgeZP)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iFudgeZP)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
# endif
# if defined DIAGNOSTICS_NEM_NIT
          CASE ('Dout(iFudgeNO3)')
            IF (iDbio3(iFudgeNO3).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iFudgeNO3)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iFudgeNO3)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iFudgeNH4)')
            IF (iDbio3(iFudgeNH4).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iFudgeNH4)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iFudgeNH4)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iFudgePON)')
            IF (iDbio3(iFudgePON).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iFudgePON)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iFudgePON)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iFudgeDON)')
            IF (iDbio3(iFudgeDON).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iFudgeDON)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iFudgeDON)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
# endif
# if defined DIAGNOSTICS_NEM_SIL
          CASE ('Dout(iFudgeSiOH)')
            IF (iDbio3(iFudgeSiOH).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iFudgeSiOH)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iFudgeSiOH)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iFudgeOpal)')
            IF (iDbio3(iFudgeOpal).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iFudgeOpal)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iFudgeOpal)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
# endif
# if defined DIAGNOSTICS_NEM_CHL
          CASE ('Dout(iChl2NS)')
            IF (iDbio3(iChl2NS).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iChl2NS)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iChl2NS)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(irhoChlS)')
            IF (iDbio3(irhoChlS).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(irhoChlS)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(irhoChlS)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iLossPS)')
            IF (iDbio3(iLossPS).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iLossPS)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iLossPS)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iChl2NL)')
            IF (iDbio3(iChl2NL).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iChl2NL)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iChl2NL)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(irhoChlL)')
            IF (iDbio3(irhoChlL).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(irhoChlL)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(irhoChlL)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(iLossPL)')
            IF (iDbio3(iLossPL).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio3(iLossPL)'
              exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio3(iLossPL)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
# endif
# if defined DIAGNOSTICS_ISO
          CASE ('Dout(i13CO2as)')
            IF (iDbio2(i13CO2as).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio2(i13CO2as)'
                exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio2(i13CO2as)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
          CASE ('Dout(i13CO2sa)')
            IF (iDbio2(i13CO2sa).eq.0) THEN
              IF (Master) WRITE (out,40) 'iDbio2(i13CO2sa)'
                exit_flag=5
              RETURN
            END IF
            Npts=load_l(Nval, Cval, Ngrids, Lbio)
            i=iDbio2(i13CO2sa)
            DO ng=1,Ngrids
              Dout(i,ng)=Lbio(ng)
            END DO
# endif 
#endif
          END SELECT
        END IF
      END DO
  10  IF (Master) WRITE (out,40) line
      exit_flag=4
      RETURN
  20  CONTINUE
!-- Hajoon
#if defined TANGENT || defined TL_IOMS
      DO ng=1,Ngrids
        DO ivar=1,nLBCvar
          DO i=1,4
            tl_LBC(i,ivar,ng)%acquire  =ad_LBC(i,ivar,ng)%acquire
            tl_LBC(i,ivar,ng)%Chapman_explicit=                         &
     &              ad_LBC(i,ivar,ng)%Chapman_explicit
            tl_LBC(i,ivar,ng)%Chapman_implicit=                         &
     &              ad_LBC(i,ivar,ng)%Chapman_implicit
            tl_LBC(i,ivar,ng)%clamped  =ad_LBC(i,ivar,ng)%clamped
            tl_LBC(i,ivar,ng)%closed   =ad_LBC(i,ivar,ng)%closed
            tl_LBC(i,ivar,ng)%Flather  =ad_LBC(i,ivar,ng)%Flather
            tl_LBC(i,ivar,ng)%gradient =ad_LBC(i,ivar,ng)%gradient
            tl_LBC(i,ivar,ng)%nested   =ad_LBC(i,ivar,ng)%nested
            tl_LBC(i,ivar,ng)%nudging  =ad_LBC(i,ivar,ng)%nudging
            tl_LBC(i,ivar,ng)%periodic =ad_LBC(i,ivar,ng)%periodic
            tl_LBC(i,ivar,ng)%radiation=ad_LBC(i,ivar,ng)%radiation
            tl_LBC(i,ivar,ng)%reduced  =ad_LBC(i,ivar,ng)%reduced
          END DO
        END DO
      END DO
#endif
!-- Hajoon
!
!-----------------------------------------------------------------------
!  Report input parameters.
!-----------------------------------------------------------------------
!
      IF (Master.and.Lwrite) THEN  !different from Ryan's inp file
        DO ng=1,Ngrids
          IF (Lbiology(ng)) THEN
!
!  Report variables
!
            WRITE (out,'(/1x,a,i0,a)')                                  &
     &        'NEMURO variable information (Grid ',ng,'):'
            WRITE (out,'(1x,a)')                                        &
     &        '====================================='
            WRITE (out,'(2x,a,i0)') 'Number of biological tracers: ',NBT
            DO itrc=1,NBT
              i=idbio(itrc)
              WRITE(out,'(4x,a,i3,"/",i0,": ",a)')                      &
     &        'biological tracer',itrc,NBT,trim(Vname(1,idTvar(i)))
            END DO
!
!  Report input parameters.
!
            WRITE (out,50) ng
            WRITE (out,60) BioIter(ng), 'BioIter',                      &
     &            'Number of iterations for nonlinear convergence.'
#if defined BIOMIN_PARAMETER
            WRITE (out,80) BioMin(ng), 'BioMin',                        &
     &            'MinVal used in the biological code',                 &
     &            '(nondimensional).'
#endif
            WRITE (out,70) AttSW(ng), 'AttSW',                          &
     &            'Light attenuation due to seawater (m-1)'
#if defined NEMURO_CHL && ! defined NEMURO_CHL_STATICRATIO
            WRITE (out,70) AttChl(ng), 'AttChl',                        &
     &            'Light attenuation due to chlorophyll (m2/mg_chl).'
# if defined NEMURO_CHL_CHL2NMIN
            WRITE (out,70) Chl2NS_min(ng), 'Chl2NS_min',                &
     &            'Min small phytoplankton Chl:N ratio (g_chl/mol_N).'
            WRITE (out,70) Chl2NL_min(ng), 'Chl2NL_min',                &
     &            'Min large phytoplankton Chl:N ratio (g_chl/mol_N).'
# endif
            WRITE (out,70) Chl2NS_max(ng), 'Chl2NS_max',                &
     &            'Max small phytoplankton Chl:N ratio (g_chl/mol_N).'
            WRITE (out,70) Chl2NL_max(ng), 'Chl2NL_max',                &
     &            'Max large phytoplankton Chl:N ratio (g_chl/mol_N).'
# if defined NEMURO_CHL_GEIDER_ACCLIM || defined NEMURO_CHL_NUDGECHL2N
            WRITE (out,80) chltacclimS(ng), 'chltacclimS',              &
     &            'Small phytoplankton chlorophyll acclim timescale',   &
     &            '(1/day).'
            WRITE (out,80) chltacclimL(ng), 'chltacclimL',              &
     &            'Large phytoplankton chlorophyll acclim timescale',   &
     &            '(1/day).'
# endif
#else
            WRITE (out,80) AttPS(ng), 'AttPS',                          &
     &            'Light attenuation due to small phytoplankton',       &
     &            '(m2/mmole_N).'
            WRITE (out,80) AttPL(ng), 'AttPL',                          &
     &            'Light attenuation due to large phytoplankton',       &
     &            '(m2/mmole_N).'
#endif
            WRITE (out,80) PARfrac(ng), 'PARfrac',                      &
     &            'Fraction of shortwave radiation that is',            &
     &            'photosynthetically active (nondimensional).'
            WRITE (out,80) AlphaPS(ng), 'AlphaPS',                      &
     &            'Small phytoplankton initial slope of the P-I curve', &
     &            '(1/(W/m2) 1/day).'
            WRITE (out,80) AlphaPL(ng), 'AlphaPL',                      &
     &            'Small phytoplankton initial slope of the P-I curve', &
     &            '(1/(W/m2) 1/day).'
#if ! defined NEMURO_CHL_GEIDER && ! defined NEMURO_CHL_NUDGECHL2N
            WRITE (out,80) BetaPS(ng), 'BetaPS',                        &
     &            'Small phytoplankton photoinhibition coefficient',    &
     &            '(1/(W/m2) 1/day).'
            WRITE (out,80) BetaPL(ng), 'BetaPL',                        &
     &            'Large phytoplankton photoinhibition coefficient',    &
     &            '(1/(W/m2) 1/day).'
#endif
            WRITE (out,80) VmaxS(ng), 'VmaxS',                          &
     &            'Small phytoplankton maximum photosynthetic rate',    &
     &            '(1/day).'
            WRITE (out,80) VmaxL(ng), 'VmaxL',                          &
     &            'Large phytoplankton maximum photosynthetic rate',    &
     &            '(1/day).'
            WRITE (out,80) KNO3S(ng), 'KNO3S',                          &
     &            'Small phytoplankton NO3 half saturation constant',   &
     &            '(mmole_N/m3).'
            WRITE (out,80) KNO3L(ng), 'KNO3L',                          &
     &            'Large phytoplankton NO3 half saturation constant',   &
     &            '(mmole_N/m3).'
            WRITE (out,80) KNH4S(ng), 'KNH4S',                          &
     &            'Small phytoplankton NH4 half saturation constant',   &
     &            '(mmole_N/m3).'
            WRITE (out,80) KNH4L(ng), 'KNH4L',                          &
     &            'Large phytoplankton NH4 half saturation constant',   &
     &            '(mmole_N/m3).'
            WRITE (out,80) KSiL(ng), 'KSiL',                            &
     &            'Small phytoplankton SiOH4 half saturation constant', &
     &            '(mmole_Si/m3).'
            WRITE (out,80) PusaiS(ng), 'PusaiS',                        &
     &            'Small phytoplankton NH4 inhibition coefficient',     &
     &            '(m3/mmole_N).'
            WRITE (out,80) PusaiL(ng), 'PusaiL',                        &
     &            'Large phytoplankton NH4 inhibition coefficient',     &
     &            '(m3/mmole_N).'
            WRITE (out,80) KGppS(ng), 'KGppS',                          &
     &            'Small phytoplankton temperature coefficient for',    &
     &            'photosynthetic rate (1/Celsius).'
            WRITE (out,80) KGppL(ng), 'KGppL',                          &
     &            'Large phytoplankton temperature coefficient for',    &
     &            'photosynthetic rate (1/Celsius).'
            WRITE (out,70) ResPS0(ng), 'ResPS0',                        &
     &            'Small phytoplankton respiration rate (1/day).'
            WRITE (out,70) ResPL0(ng), 'ResPL0',                        &
     &            'Large phytoplankton respiration rate (1/day).'
            WRITE (out,80) KResPS(ng), 'KResPS',                        &
     &            'Small phytoplankton temperature coefficient for',    &
     &            'respiration (1/Celsius).'
            WRITE (out,80) KResPL(ng), 'KResPL',                        &
     &            'Large phytoplankton temperature coefficient for',    &
     &            'respiration (1/Celsius).'
            WRITE (out,80) GammaS(ng), 'GammaS',                        &
     &            'Small phytoplankton ratio of extracellular',         &
     &            'excretion to photosynthesis (nondimensional).'
            WRITE (out,80) GammaL(ng), 'GammaL',                        &
     &            'Large phytoplankton ratio of extracellular',         &
     &            'excretion to photosynthesis (nondimensional).'
            WRITE (out,80) MorPS0(ng), 'MorPS0',                        &
     &            'Small phytoplankton mortality rate',                 &
     &            '(m3/mmole_N/day).'
            WRITE (out,80) MorPL0(ng), 'MorPL0',                        &
     &            'Large phytoplankton mortality rate',                 &
     &            '(m3/mmole_N/day).'
            WRITE (out,80) KMorPS(ng), 'KMorPS',                        &
     &            'Small phytoplankton temperature coefficient for',    &
     &            'mortality (1/Celsius).'
            WRITE (out,80) KMorPL(ng), 'KMorPL',                        &
     &            'Large phytoplankton temperature coefficient for',    &
     &            'mortality (1/Celsius).'
            WRITE (out,80) GRmaxSps(ng), 'GRmaxSps',                    &
     &            'Small zooplankton grazing rate on small',            &
     &            'phytoplankton (1/day).'
#if defined NEMUCSC
            WRITE (out,80) GRmaxSpl(ng), 'GRmaxSpl',                    &
     &            'Small zooplankton grazing rate on large',            &
     &            'phytoplankton (1/day).'
#endif
            WRITE (out,80) GRmaxLps(ng), 'GRmaxLps',                    &
     &            'Large zooplankton grazing rate on small',            &
     &            'phytoplankton (1/day).'
            WRITE (out,80) GRmaxLpl(ng), 'GRmaxLpl',                    &
     &            'Large zooplankton grazing rate on large',            &
     &            'phytoplankton (1/day).'
            WRITE (out,80) GRmaxLzs(ng), 'GRmaxLzs',                    &
     &            'Large zooplankton grazing rate on small',            &
     &            'zooplankton (1/day).'
            WRITE (out,80) GRmaxPpl(ng), 'GRmaxPpl',                    &
     &            'Predator zooplankton grazing rate on large',         &
     &            'phytoplankton (1/day).'
            WRITE (out,80) GRmaxPzs(ng), 'GRmaxPzs',                    &
     &            'Predator zooplankton grazing rate on small',         &
     &            'zooplankton (1/day).'
            WRITE (out,80) GRmaxPzl(ng), 'GRmaxPzl',                    &
     &            'Predator zooplankton grazing rate on large',         &
     &            'zooplankton (1/day).'
            WRITE (out,80) KGraS(ng), 'KGraS',                          &
     &            'Small zooplankton temperature coefficient for',      &
     &            'grazing (1/Celsius).'
            WRITE (out,80) KGraL(ng), 'KGraL',                          &
     &            'Large zooplankton temperature coefficient for',      &
     &            'grazing (1/Celsius).'
            WRITE (out,80) KGraP(ng), 'KGraP',                          &
     &            'Predator zooplankton temperature coefficient for',   &
     &            'grazing (1/Celsius).'
            WRITE (out,80) LamS(ng), 'LamS',                            &
     &            'Small zooplankton grazing Ivlev constant',           &
     &            '(m3/mmole_N).'
            WRITE (out,80) LamL(ng), 'LamL',                            &
     &            'Large zooplankton grazing Ivlev constant',           &
     &            '(m3/mmole_N).'
            WRITE (out,80) LamP(ng), 'LamP',                            &
     &            'Preditor zooplankton grazing Ivlev constant',        &
     &            '(m3/mmole_N).'
#ifdef HOLLING_GRAZING
            WRITE (out,80) KPS2ZS(ng), 'KPS2ZS',                        &
     &            'Half-saturation constant for small zooplankton',     &
     &            'grazing on small phytoplankton (mmole_N/m3)^2.'
# if defined NEMUCSC
            WRITE (out,80) KPL2ZS(ng), 'KPL2ZS',                        &
     &            'Half-saturation constant for small zooplankton',     &
     &            'grazing on large phytoplankton (mmole_N/m3)^2.'
# endif
            WRITE (out,80) KPS2ZL(ng), 'KPS2ZL',                        &
     &            'Half-saturation constant for large zooplankton',     &
     &            'grazing on small phytoplankton (mmole_N/m3)^2.'
            WRITE (out,80) KPL2ZL(ng), 'KPL2ZL',                        &
     &            'Half-saturation constant for large zooplankton',     &
     &            'grazing on large phytoplankton (mmole_N/m3)^2.'
            WRITE (out,80) KPL2ZP(ng), 'KPL2ZP',                        &
     &            'Half-saturation constant for predator zooplankton',  &
     &            'grazing on large phytoplankton (mmole_N/m3)^2.'
            WRITE (out,80) KZS2ZP(ng), 'KZS2ZP',                        &
     &            'Half-saturation constant for predator zooplankton',  &
     &            'grazing on small zooplankton (mmole_N/m3)^2.'
            WRITE (out,80) KZL2ZP(ng), 'KZL2ZP',                        &
     &            'Half-saturation constant for predator zooplankton',  &
     &            'grazing on large zooplankton (mmole_N/m3)^2.'
#else
            WRITE (out,80) PS2ZSstar(ng), 'PS2ZSstar',                  &
     &            'Small zooplankton threshold for grazing on small',   &
     &            'phytoplankton (mmole_N/m3).'
# if defined NEMUCSC
            WRITE (out,80) PL2ZSstar(ng), 'PL2ZSstar',                  &
     &            'Small zooplankton threshold for grazing on large',   &
     &            'phytoplankton (mmole_N/m3).'
# endif 
           WRITE (out,80) PS2ZLstar(ng), 'PS2ZLstar',                  &
     &            'Large zooplankton threshold for grazing on small',   &
     &            'phytoplankton (mmole_N/m3).'
            WRITE (out,80) PL2ZLstar(ng), 'PL2ZLstar',                  &
     &            'Large zooplankton threshold for grazing on large',   &
     &            'phytoplankton (mmole_N/m3).'
            WRITE (out,80) PL2ZLstar(ng), 'PL2ZLstar',                  &
     &            'Large zooplankton threshold for grazing on small',   &
     &            'zooplankton (mmole_N/m3).'
            WRITE (out,80) PL2ZPstar(ng), 'PL2ZPstar',                  &
     &            'Predator zooplankton threshold for grazing on large',&
     &            'phytoplankton (mmole_N/m3).'
            WRITE (out,80) ZS2ZPstar(ng), 'ZS2ZPstar',                  &
     &            'Predator zooplankton threshold for grazing on small',&
     &            'zooplankton (mmole_N/m3).'
            WRITE (out,80) ZL2ZPstar(ng), 'ZL2ZPstar',                  &
     &            'Predator zooplankton threshold for grazing on large',&
     &            'zooplankton (mmole_N/m3).'
#endif
            WRITE (out,80) PusaiPL(ng), 'PusauPL',                      &
     &            'Predator zooplankton grazing inhibition on large',   &
     &            'phytoplankton (mmole_N/m3).'
            WRITE (out,80) PusaiZS(ng), 'PusauZS',                      &
     &            'Predator zooplankton grazing inhibition on small',   &
     &            'zootoplankton (mmole_N/m3).'
            WRITE (out,80) MorZS0(ng), 'MorZS0',                        &
     &            'Small zooplankton mortality rate at 0 Celsius',      &
     &            '(m3/mmole_N/day).'
            WRITE (out,80) MorZL0(ng), 'MorZL0',                        &
     &            'Large zooplankton mortality rate at 0 Celsius',      &
     &            '(m3/mmole_N/day).'
            WRITE (out,80) MorZP0(ng), 'MorZP0',                        &
     &            'Predator zooplankton mortality rate at 0 Celsius',   &
     &            '(m3/mmole_N/day).'
            WRITE (out,80) KMorZS(ng), 'KMorZS',                        &
     &            'Small zooplankton temperature coefficient for',      &
     &            'mortality (1/Celsius).'
            WRITE (out,80) KMorZL(ng), 'KMorZL',                        &
     &            'Large zooplankton temperature coefficient for',      &
     &            'mortality (1/Celsius).'
            WRITE (out,80) KMorZP(ng), 'KMorZP',                        &
     &            'Predator zooplankton temperature coefficient for',   &
     &            'mortality (1/Celsius).'
            WRITE (out,80) AlphaZS(ng), 'AlphaZS',                      &
     &            'Small zooplankton assimilation efficiency',          &
     &            '(nondimensional).'
            WRITE (out,80) AlphaZL(ng), 'AlphaZL',                      &
     &            'Large zooplankton assimilation efficiency',          &
     &            '(nondimensional).'
            WRITE (out,80) AlphaZP(ng), 'AlphaZP',                      &
     &            'Predator zooplankton assimilation efficiency',       &
     &            '(nondimensional).'
            WRITE (out,80) BetaZS(ng), 'BetaZS',                        &
     &            'Small zooplankton growth efficiency',                &
     &            '(nondimensional).'
            WRITE (out,80) BetaZL(ng), 'BetaZL',                        &
     &            'Large zooplankton growth efficiency',                &
     &            '(nondimensional).'
            WRITE (out,80) BetaZP(ng), 'BetaZP',                        &
     &            'Predator zooplankton growth efficiency',             &
     &            '(nondimensional).'
            WRITE (out,70) Nit0(ng), 'Nit0',                            &
     &            'NH4 to NO3 decomposition rate (1/day).'
            WRITE (out,70) VP2N0(ng), 'VP2N0',                          &
     &            'PON to NH4 decomposition rate (1/day).'
            WRITE (out,70) VP2D0(ng), 'VP2D0',                          &
     &            'PON to DON decomposition rate (1/day).'
            WRITE (out,70) VD2N0(ng), 'VD2N0',                          &
     &            'DON to NH4 decomposition rate (1/day).'
            WRITE (out,70) VO2S0(ng), 'VO2S0',                          &
     &            'Opal to SiOH4 decomposition rate (1/day).'
            WRITE (out,80) KNit(ng), 'KNit',                            &
     &            'Temperature coefficient for NH4 to NO3',             &
     &            'decomposition (1/Celsius).'
            WRITE (out,80) KP2D(ng), 'KP2D',                            &
     &            'Temperature coefficient for PON to DON',             &
     &            'decomposition (1/Celsius).'
            WRITE (out,80) KP2N(ng), 'KP2N',                            &
     &            'Temperature coefficient for PON to NH4',             &
     &            'decomposition (1/Celsius).'
            WRITE (out,80) KD2N(ng), 'KD2N',                            &
     &            'Temperature coefficient for DON to NH4',             &
     &            'decomposition (1/Celsius).'
            WRITE (out,80) KO2S(ng), 'KO2S',                            &
     &            'Temperature coefficient for Opal to SiOH4',          &
     &            'decomposition (1/Celsius).'
            WRITE (out,70) RSiN(ng), 'RSiN',                            &
     &            'Si:N ratio (mmole_Si/mmole_N)'
            WRITE (out,70) setVPON(ng), 'setVPON',                      &
     &            'PON sinking velocity (m/day).'
            WRITE (out,70) setVOpal(ng), 'setVOpal',                    &
     &            'Opal sinking velocity (m/day).'
#ifdef N15
            WRITE (out,80) eps_GppNO3(ng), 'eps_GppNO3',                &
     &            'epsilon for N isotope frac during NO3 uptake',       &
     &            '(permil).'
            WRITE (out,80) eps_GppNH4(ng), 'eps_GppNH4',                &
     &            'epsilon for N isotope frac during NH4 uptake',       &
     &            '(permil).'
            WRITE (out,80) eps_exc(ng), 'eps_exc',                      &
     &            'epsilon for N isotope frac during zooplankton',      &
     &            'NH4 excretion (permil).' 
# ifdef DENIT
            WRITE (out,80) eps_denit(ng), 'eps_denit',                  &
     &            'epsilon for N isotope frac during water',            &
     &            'column denitrification (permil).'
# endif
            WRITE (out,80) eps_nitrif(ng), 'eps_nitrif',                &
     &            'epsilon for N isotope frac during nitrification',    &
     &            '(permil).'
            WRITE (out,80) eps_remin(ng), 'eps_remin',                  &
     &            'epsilon for N isotope frac during PON to NH4',       &
     &            'remineralization (permil).'
            WRITE (out,80) eps_decomp(ng), 'eps_decomp',                &
     &            'epsilon for N isotope frac during PON to DON',       &
     &            'decomposition (permil).'
            WRITE (out,80) eps_reminDON(ng), 'eps_reminDON',            &
     &            'epsilon for N isotope frac during DON to NH4',       &
     &            'remineralization (permil).'
# ifdef SINK_RATIO
            WRITE (out,70) setVPONratio(ng), 'setVPONratio',            &
     &            'PONratio sinking velocity (m/day).'
# else
            WRITE (out,70) setVPON14(ng), 'setVPON14',                  &
     &            '14PON sinking velocity (m/day).'
            WRITE (out,70) setVPON15(ng), 'setVPON15',                  &
     &            '15PON sinking velocity (m/day).'
# endif
#endif
#if defined NEMURO_CHL && defined NEMURO_CHL_STATICRATIO
            WRITE (out,70) Chl2NS(ng), 'Chl2NS',                        &
     &            'Small phytoplankton Chl:N ratio (g_chl/mol_N).'
            WRITE (out,70) Chl2NL(ng), 'Chl2NL',                        &
     &            'Large phytoplankton Chl:N ratio (g_chl/mol_N).'
#endif
#ifdef CARB
            WRITE (out,80) RedCN(ng), 'RedCN',                          &
     &            'Redfield Carbon:Nitrogen ratio (mol_C/mol_N).'
            WRITE (out,80) pCO2air(ng), 'pCO2air',                      &
     &            'partial pressure of CO2 in the air (ppm vol).'
# if defined NEMURO_CO2_TREND
            WRITE (out,80) pCO2trend(ng), 'pCO2trend',                  &
     &            'atmospheric pCO2 trend (ppm vol per year).'
# endif
#endif
#ifdef NEM_IRON_LIMIT
            WRITE (out,70) T_Fe(ng), 'T_Fe',                            &
     &            'Iron uptake time scale (day-1).'
            WRITE (out,70) A_Fe(ng), 'A_Fe',                            &
     &            'Empirical Fe:C power (-).'
            WRITE (out,70) B_Fe(ng), 'B_Fe',                            &
     &            'Empirical Fe:C coefficient (1/M-C).'
            WRITE (out,70) SK_FeC(ng), 'SK_FeC',                        &
     &            'Small P Fe:C at F=0.5 (muM-Fe/M-C).'
            WRITE (out,70) LK_FeC(ng), 'LK_FeC',                        &
     &            'Large P Fe:C at F=0.5 (muM-Fe/M-C).'
            WRITE (out,70) FeRR(ng), 'FeRR',                            &
     &            'Fe remineralization rate (day-1).'
# ifdef NEM_IRON_RELAX
            WRITE (out,70) FeHmin(ng), 'FeHmin',                        &
     &            'Minimum coastal bathymetry (m) for Fe nudging.'
            WRITE (out,70) FeNudgTime(ng), 'FeNudgTime',                &
     &            'Fe nudging time scale (days) at h <= FeHmin.'
            WRITE (out,70) FeMax(ng), 'FeMax',                          &
     &            'Fe value (mmoles/m3) used in coastal nudging.'
# endif
#endif
#ifdef NEM_SPONGE
            WRITE (out,60) nemSpongeN(ng), 'nemSpongeN',                &
     &            'Npts near bry with increased phyto mortality.'
            WRITE (out,80) nemSpongeF(ng), 'nemSpongeF',                &
     &            'Maximum phyto mortality factor increase',            &
     &            '(nondimensional).'
#endif
#ifdef TS_DIF2
            DO itrc=1,NBT
              i=idbio(itrc)
              WRITE (out,90) nl_tnu2(i,ng), 'nl_tnu2', i,               &
     &              'NLM Horizontal, harmonic mixing coefficient',      &
     &              '(m2/s) for tracer ', i, TRIM(Vname(1,idTvar(i)))
# ifdef ADJOINT
              WRITE (out,90) ad_tnu2(i,ng), 'ad_tnu2', i,               &
     &              'ADM Horizontal, harmonic mixing coefficient',      &
     &              '(m2/s) for tracer ', i, TRIM(Vname(1,idTvar(i)))
# endif
# if defined TANGENT || defined TL_IOMS
              WRITE (out,90) tl_tnu2(i,ng), 'tl_tnu2', i,               &
     &              'TLM Horizontal, harmonic mixing coefficient',      &
     &              '(m2/s) for tracer ', i, TRIM(Vname(1,idTvar(i)))
# endif
            END DO
#endif
#ifdef TS_DIF4
            DO itrc=1,NBT
              i=idbio(itrc)
              WRITE (out,90) nl_tnu4(i,ng), 'nl_tnu4', i,               &
     &              'NLM Horizontal, biharmonic mixing coefficient',    &
     &              '(m4/s) for tracer ', i, TRIM(Vname(1,idTvar(i)))
# ifdef ADJOINT
              WRITE (out,90) ad_tnu4(i,ng), 'ad_tnu4', i,               &
     &              'ADM Horizontal, biharmonic mixing coefficient',    &
     &              '(m4/s) for tracer ', i, TRIM(Vname(1,idTvar(i)))
# endif
# if defined TANGENT || defined TL_IOMS
              WRITE (out,90) tl_tnu4(i,ng), 'tl_tnu4', i,               &
     &              'TLM Horizontal, biharmonic mixing coefficient',    &
     &              '(m4/s) for tracer ', i, TRIM(Vname(1,idTvar(i)))
# endif
            END DO
#endif
            DO itrc=1,NBT
              i=idbio(itrc)
              IF (LtracerSponge(i,ng)) THEN
                WRITE (out,100) LtracerSponge(i,ng), 'LtracerSponge',   &
     &              i, 'Turning ON  sponge on tracer ', i,              &
     &              TRIM(Vname(1,idTvar(i)))
              ELSE
                WRITE (out,100) LtracerSponge(i,ng), 'LtracerSponge',   &
     &              i, 'Turning OFF sponge on tracer ', i,              &
     &              TRIM(Vname(1,idTvar(i)))
              END IF
            END DO
            DO itrc=1,NBT
              i=idbio(itrc)
              WRITE(out,90) Akt_bak(i,ng), 'Akt_bak', i,                &
     &             'Background vertical mixing coefficient (m2/s)',     &
     &             'for tracer ', i, TRIM(Vname(1,idTvar(i)))
            END DO
#ifdef FORWARD_MIXING
            DO itrc=1,NBT
              i=idbio(itrc)
# ifdef ADJOINT
              WRITE (out,90) ad_Akt_fac(i,ng), 'ad_Akt_fac', i,         &
     &              'ADM basic state vertical mixing scale factor',     &
     &              'for tracer ', i, TRIM(Vname(1,idTvar(i)))
# endif
# if defined TANGENT || defined TL_IOMS
              WRITE (out,90) tl_Akt_fac(i,ng), 'tl_Akt_fac', i,         &
     &              'TLM basic state vertical mixing scale factor',     &
     &              'for tracer ', i, TRIM(Vname(1,idTvar(i)))
# endif
            END DO
#endif
            DO itrc=1,NBT
              i=idbio(itrc)
              WRITE (out,90) Tnudg(i,ng), 'Tnudg', i,                   &
     &              'Nudging/relaxation time scale (days)',             &
     &              'for tracer ', i, TRIM(Vname(1,idTvar(i)))
            END DO
            DO itrc=1,NBT
              i=idbio(itrc)
              IF (LtracerSrc(i,ng)) THEN
                WRITE (out,100) LtracerSrc(i,ng), 'LtracerSrc',         &
     &              i, 'Turning ON  point sources/Sink on tracer ', i,  &
     &              TRIM(Vname(1,idTvar(i)))
              ELSE
                WRITE (out,100) LtracerSrc(i,ng), 'LtracerSrc',         &
     &              i, 'Turning OFF point sources/Sink on tracer ', i,  &
     &              TRIM(Vname(1,idTvar(i)))
              END IF
            END DO
            DO itrc=1,NBT
              i=idbio(itrc)
              IF (LtracerCLM(i,ng)) THEN
                WRITE (out,100) LtracerCLM(i,ng), 'LtracerCLM', i,      &
     &              'Turning ON  processing of climatology tracer ', i, &
     &              TRIM(Vname(1,idTvar(i)))
              ELSE
                WRITE (out,100) LtracerCLM(i,ng), 'LtracerCLM', i,      &
     &              'Turning OFF processing of climatology tracer ', i, &
     &              TRIM(Vname(1,idTvar(i)))
              END IF
            END DO
            DO itrc=1,NBT
              i=idbio(itrc)
              IF (LnudgeTCLM(i,ng)) THEN
                WRITE (out,100) LnudgeTCLM(i,ng), 'LnudgeTCLM', i,      &
     &              'Turning ON  nudging of climatology tracer ', i,    &
     &              TRIM(Vname(1,idTvar(i)))
              ELSE
                WRITE (out,100) LnudgeTCLM(i,ng), 'LnudgeTCLM', i,      &
     &              'Turning OFF nudging of climatology tracer ', i,    &
     &              TRIM(Vname(1,idTvar(i)))
              END IF
            END DO
            IF ((nHIS(ng).gt.0).and.ANY(Hout(:,ng))) THEN
              WRITE (out,'(1x)')
              DO itrc=1,NBT
                i=idbio(itrc)
                IF (Hout(idTvar(i),ng)) WRITE (out,110)                 &
     &              Hout(idTvar(i),ng), 'Hout(idTvar)',                 &
     &              'Write out tracer ', i, TRIM(Vname(1,idTvar(i)))
              END DO
              DO itrc=1,NBT
                i=idbio(itrc)
                IF (Hout(idTsur(i),ng)) WRITE (out,110)                 &
     &              Hout(idTsur(i),ng), 'Hout(idTsur)',                 &
     &              'Write out tracer flux ', i,                        &
     &              TRIM(Vname(1,idTvar(i)))
              END DO
            END IF
            IF ((nQCK(ng).gt.0).and.ANY(Qout(:,ng))) THEN
              WRITE (out,'(1x)')
              DO itrc=1,NBT
                i=idbio(itrc)
                IF (Qout(idTvar(i),ng)) WRITE (out,110)                 &
     &              Qout(idTvar(i),ng), 'Qout(idTvar)',                 &
     &              'Write out tracer ', i, TRIM(Vname(1,idTvar(i)))
              END DO
              DO itrc=1,NBT
                i=idbio(itrc)
                IF (Qout(idsurT(i),ng)) WRITE (out,110)                 &
     &              Qout(idsurT(i),ng), 'Qout(idsurT)',                 &
     &              'Write out surface tracer ', i,                     &
     &              TRIM(Vname(1,idTvar(i)))
              END DO
              DO itrc=1,NBT
                i=idbio(itrc)
                IF (Qout(idTsur(i),ng)) WRITE (out,110)                 &
     &              Qout(idTsur(i),ng), 'Qout(idTsur)',                 &
     &              'Write out tracer flux ', i,                        &
     &              TRIM(Vname(1,idTvar(i)))
              END DO
            END IF
#if defined AVERAGES    || \
   (defined AD_AVERAGES && defined ADJOINT) || \
   (defined RP_AVERAGES && defined TL_IOMS) || \
   (defined TL_AVERAGES && defined TANGENT)
            IF ((nAVG(ng).gt.0).and.ANY(Aout(:,ng))) THEN
              WRITE (out,'(1x)')
              DO itrc=1,NBT
                i=idbio(itrc)
                IF (Aout(idTvar(i),ng)) WRITE (out,110)                 &
     &              Aout(idTvar(i),ng), 'Aout(idTvar)',                 &
     &              'Write out averaged tracer ', i,                    &
     &              TRIM(Vname(1,idTvar(i)))
              END DO
              DO itrc=1,NBT
                i=idbio(itrc)
                IF (Aout(idTTav(i),ng)) WRITE (out,110)                 &
     &              Aout(idTTav(i),ng), 'Aout(idTTav)',                 &
     &              'Write out averaged <t*t> for tracer ', i,          &
     &              TRIM(Vname(1,idTvar(i)))
              END DO
              DO itrc=1,NBT
                i=idbio(itrc)
                IF (Aout(idUTav(i),ng)) WRITE (out,110)                 &
     &              Aout(idUTav(i),ng), 'Aout(idUTav)',                 &
     &              'Write out averaged <u*t> for tracer ', i,          &
     &              TRIM(Vname(1,idTvar(i)))
              END DO
              DO itrc=1,NBT
                i=idbio(itrc)
                IF (Aout(idVTav(i),ng)) WRITE (out,110)                 &
     &              Aout(idVTav(i),ng), 'Aout(idVTav)',                 &
     &              'Write out averaged <v*t> for tracer ', i,          &
     &              TRIM(Vname(1,idTvar(i)))
              END DO
              DO itrc=1,NBT
                i=idbio(itrc)
                IF (Aout(iHUTav(i),ng)) WRITE (out,110)                 &
     &              Aout(iHUTav(i),ng), 'Aout(iHUTav)',                 &
     &              'Write out averaged <Huon*t> for tracer ', i,       &
     &              TRIM(Vname(1,idTvar(i)))
              END DO
              DO itrc=1,NBT
                i=idbio(itrc)
                IF (Aout(iHVTav(i),ng)) WRITE (out,110)                 &
     &              Aout(iHVTav(i),ng), 'Aout(iHVTav)',                 &
     &              'Write out averaged <Hvom*t> for tracer ', i,       &
     &              TRIM(Vname(1,idTvar(i)))
              END DO
            END IF
#endif
#ifdef DIAGNOSTICS_TS
            IF ((nDIA(ng).gt.0).and.ANY(Dout(:,ng))) THEN
              WRITE (out,'(1x)')
              DO i=1,NBT
                itrc=idbio(i)
                IF (Dout(idDtrc(itrc,iTrate),ng))                       &
     &            WRITE (out,110) .TRUE., 'Dout(iTrate)',               &
     &              'Write out rate of change of tracer ', itrc,        &
     &              TRIM(Vname(1,idTvar(itrc)))
              END DO
              DO i=1,NBT
                itrc=idbio(i)
                IF (Dout(idDtrc(itrc,iThadv),ng))                       &
     &            WRITE (out,110) .TRUE., 'Dout(iThadv)',               &
     &              'Write out horizontal advection, tracer ', itrc,    &
     &              TRIM(Vname(1,idTvar(itrc)))
              END DO
              DO i=1,NBT
                itrc=idbio(i)
                IF (Dout(idDtrc(itrc,iTxadv),ng))                       &
     &            WRITE (out,110) .TRUE., 'Dout(iTxadv)',               &
     &              'Write out horizontal X-advection, tracer ', itrc,  &
     &              TRIM(Vname(1,idTvar(itrc)))
              END DO
              DO i=1,NBT
                itrc=idbio(i)
                IF (Dout(idDtrc(itrc,iTyadv),ng))                       &
     &            WRITE (out,110) .TRUE., 'Dout(iTyadv)',               &
     &              'Write out horizontal Y-advection, tracer ', itrc,  &
     &              TRIM(Vname(1,idTvar(itrc)))
              END DO
              DO i=1,NBT
                itrc=idbio(i)
                IF (Dout(idDtrc(itrc,iTvadv),ng))                       &
     &            WRITE (out,110) .TRUE., 'Dout(iTvadv)',               &
     &              'Write out vertical advection, tracer ', itrc,      &
     &              TRIM(Vname(1,idTvar(itrc)))
              END DO
# if defined TS_DIF2 || defined TS_DIF4
              DO i=1,NBT
                itrc=idbio(i)
                IF (Dout(idDtrc(itrc,iThdif),ng))                       &
     &            WRITE (out,110) .TRUE., 'Dout(iThdif)',               &
     &              'Write out horizontal diffusion, tracer ', itrc,    &
     &              TRIM(Vname(1,idTvar(itrc)))
              END DO
              DO i=1,NBT
                itrc=idbio(i)
                IF (Dout(idDtrc(i,iTxdif),ng))                          &
     &            WRITE (out,110) .TRUE., 'Dout(iTxdif)',               &
     &              'Write out horizontal X-diffusion, tracer ', itrc,  &
     &              TRIM(Vname(1,idTvar(itrc)))
              END DO
              DO i=1,NBT
                itrc=idbio(i)
                IF (Dout(idDtrc(itrc,iTydif),ng))                       &
     &            WRITE (out,110) .TRUE., 'Dout(iTydif)',               &
     &              'Write out horizontal Y-diffusion, tracer ', itrc,  &
     &              TRIM(Vname(1,idTvar(itrc)))
              END DO
#  if defined MIX_GEO_TS || defined MIX_ISO_TS
              DO i=1,NBT
                itrc=idbio(i)
                IF (Dout(idDtrc(itrc,iTsdif),ng))                       &
     &            WRITE (out,110) .TRUE., 'Dout(iTsdif)',               &
     &              'Write out horizontal S-diffusion, tracer ', itrc,  &
     &              TRIM(Vname(1,idTvar(itrc)))
              END DO
#  endif
# endif
              DO i=1,NBT
                itrc=idbio(i)
                IF (Dout(idDtrc(itrc,iTvdif),ng))                       &
     &            WRITE (out,110) .TRUE., 'Dout(iTvdif)',               &
     &              'Write out vertical diffusion, tracer ', itrc,      &
     &              TRIM(Vname(1,idTvar(itrc)))
              END DO
            END IF
#endif
          END IF
        END DO
      END IF
!
!-----------------------------------------------------------------------
!  Rescale biological tracer parameters.
!-----------------------------------------------------------------------
!
!  Take the square root of the biharmonic coefficients so it can
!  be applied to each harmonic operator.
!
      DO ng=1,Ngrids
        DO itrc=1,NBT
          i=idbio(itrc)
          nl_tnu4(i,ng)=SQRT(ABS(nl_tnu4(i,ng)))
#ifdef ADJOINT
          ad_tnu4(i,ng)=SQRT(ABS(ad_tnu4(i,ng)))
#endif
#if defined TANGENT || defined TL_IOMS
          tl_tnu4(i,ng)=SQRT(ABS(tl_tnu4(i,ng)))
#endif
!
!  Compute inverse nudging coefficients (1/s) used in various tasks.
!
          IF (Tnudg(i,ng).gt.0.0_r8) THEN
            Tnudg(i,ng)=1.0_r8/(Tnudg(i,ng)*86400.0_r8)
          ELSE
            Tnudg(i,ng)=0.0_r8
          END IF
        END DO
      END DO

  30  FORMAT (/,' read_BioPar - variable info not yet loaded, ',        &
     &        a,i2.2,a)
  40  FORMAT (/,' read_BioPar - Error while processing line: ',/,a)
  50  FORMAT (/,/,' Nemuro Model Parameters, Grid: ',i2.2,              &
     &        /,  ' =================================',/)
  60  FORMAT (1x,i10,2x,a,t32,a)
  70  FORMAT (1p,e11.4,2x,a,t32,a)
  80  FORMAT (1p,e11.4,2x,a,t32,a,/,t34,a)
  90  FORMAT (1p,e11.4,2x,a,'(',i2.2,')',t32,a,/,t34,a,i2.2,':',1x,a)
 100  FORMAT (10x,l1,2x,a,'(',i2.2,')',t32,a,i2.2,':',1x,a)
 110  FORMAT (10x,l1,2x,a,t32,a,i2.2,':',1x,a)

      RETURN
      END SUBROUTINE read_BioPar
