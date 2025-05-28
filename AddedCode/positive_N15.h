!-----------------------------------------------------------------------
      SUBROUTINE positive_N15 (ng,tile)
!-----------------------------------------------------------------------

      USE mod_param
      USE mod_forces
      USE mod_grid
      USE mod_ncparam
      USE mod_ocean
      USE mod_stepping
!
!  Imported variable declarations.
!
      integer, intent(in) :: ng, tile
!
!  Local variable declarations.
!
      character (len=*), parameter :: MyFile =                          &
     &  __FILE__

#include "tile.h"
!
!  Set header file name.
!
#ifdef DISTRIBUTE
      IF (Lbiofile(iNLM)) THEN
#else
      IF (Lbiofile(iNLM).and.(tile.eq.0)) THEN
#endif
        Lbiofile(iNLM)=.FALSE.
        BIONAME(iNLM)=__FILE__
      END IF
!
#ifdef PROFILE
      CALL wclock_on (ng, iNLM, 15, __LINE__, MyFile)
#endif
      CALL positive_N15_tile (ng, tile,                                     &
     &                   LBi, UBi, LBj, UBj, N(ng), NT(ng),             &
     &                   IminS, ImaxS, JminS, JmaxS,                    &
     &                   nstp(ng), nnew(ng),                            &
#ifdef MASKING
     &                   GRID(ng) % rmask,                              &
#endif

     &                   GRID(ng) % Hz,                                 &
     &                   OCEAN(ng) % t)
!
#ifdef PROFILE
      CALL wclock_off (ng, iNLM, 15, __LINE__, MyFile)
#endif
      RETURN
      END SUBROUTINE positive_N15

!
!-----------------------------------------------------------------------
      SUBROUTINE positive_N15_tile (ng,tile,                            &
     &                         LBi, UBi, LBj, UBj, UBk, UBt,            &
     &                         IminS, ImaxS, JminS, JmaxS,              &
     &                         nstp, nnew,                              &
#ifdef MASKING
     &                         rmask,                                   &
#endif
     &                         Hz, t)
!-----------------------------------------------------------------------
!
      USE mod_param
      USE mod_biology
      USE mod_ncparam
      USE mod_scalars
!
!  Imported variable declarations.
!
      integer, intent(in) :: ng, tile
      integer, intent(in) :: LBi, UBi, LBj, UBj, UBk, UBt
      integer, intent(in) :: IminS, ImaxS, JminS, JmaxS
      integer, intent(in) :: nstp, nnew
#ifdef ASSUMED_SHAPE
# ifdef MASKING
      real(r8), intent(in) :: rmask(LBi:,LBj:)
# endif
      real(r8), intent(in) :: Hz(LBi:,LBj:,:)
      real(r8), intent(inout) :: t(LBi:,LBj:,:,:,:)
#else
# ifdef MASKING
      real(r8), intent(in) :: rmask(LBi:UBi,LBj:UBj)
# endif
      real(r8), intent(in) :: Hz(LBi:UBi,LBj:UBj,UBk)
      real(r8), intent(inout) :: t(LBi:UBi,LBj:UBj,UBk,3,UBt)
#endif
!
!  Local variable declarations.
!
      integer :: i, ibio, itime, itrc, j, k
      real(r8), parameter :: Rstd = 1.0_r8
      real(r8), parameter :: t_d15N = 6.0_r8
      real(r8), parameter :: new_conc = 1.0e-6_r8
      real(r8) :: d15N

!#include "set_bounds.h"
      integer :: Istr,Iend,Jstr,Jend
      Istr   =BOUNDS(ng) % Istr   (tile)
      Iend   =BOUNDS(ng) % Iend   (tile)
      Jstr   =BOUNDS(ng) % Jstr   (tile)
      Jend   =BOUNDS(ng) % Jend   (tile)

!
!-----------------------------------------------------------------------
!  Restrict global tracer variables in nnew and nstp tracer arrays
!  so they are positive definite, to prevent isotope variable blowups
!-----------------------------------------------------------------------
!
 
      J_LOOP : DO j=Jstr,Jend
        DO k=1,N(ng)
          DO i=Istr,Iend
# ifdef MASKING
            IF (rmask(i,j).EQ.1) THEN
# endif
!NO3
              IF (t(i,j,k,nnew,iNO3_).LE.0.0_r8 .OR. t(i,j,k,nnew,iNO3_).NE.t(i,j,k,nnew,iNO3_)) THEN
                t(i,j,k,nnew,iNO3_)=new_conc
                t(i,j,k,nnew,iNO315_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iNO3_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iNO314_)=t(i,j,k,nnew,iNO3_)-          &
     &                                t(i,j,k,nnew,iNO315_)
                print *, "set pos nnew NO3 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iNO315_).LE.0.0_r8 .OR. t(i,j,k,nnew,iNO315_).NE.t(i,j,k,nnew,iNO315_)) THEN
                t(i,j,k,nnew,iNO3_)=new_conc
                t(i,j,k,nnew,iNO315_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iNO3_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iNO314_)=t(i,j,k,nnew,iNO3_)-          &
     &                                t(i,j,k,nnew,iNO315_)
                print *, "set pos nnew NO315 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iNO314_).LE.0.0_r8 .OR. t(i,j,k,nnew,iNO314_).NE.t(i,j,k,nnew,iNO314_)) THEN
                t(i,j,k,nnew,iNO3_)=new_conc
                t(i,j,k,nnew,iNO315_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iNO3_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iNO314_)=t(i,j,k,nnew,iNO3_)-          &
     &                                t(i,j,k,nnew,iNO315_)
                print *, "set pos nnew NO314 i,j,k=",i,j,k
              ENDIF
!NH4
              IF (t(i,j,k,nnew,iNH4_).LE.0.0_r8 .OR. t(i,j,k,nnew,iNH4_).NE.t(i,j,k,nnew,iNH4_)) THEN
                t(i,j,k,nnew,iNH4_)=new_conc
                t(i,j,k,nnew,iNH415_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iNH4_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iNH414_)=t(i,j,k,nnew,iNH4_)-          &
     &                                t(i,j,k,nnew,iNH415_)
                print *, "set pos nnew NH4 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iNH415_).LE.0.0_r8 .OR. t(i,j,k,nnew,iNH415_).NE.t(i,j,k,nnew,iNH415_)) THEN
                t(i,j,k,nnew,iNH4_)=new_conc
                t(i,j,k,nnew,iNH415_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iNH4_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iNH414_)=t(i,j,k,nnew,iNH4_)-          &
     &                                t(i,j,k,nnew,iNH415_)
                print *, "set pos nnew NH415 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iNH414_).LE.0.0_r8 .OR. t(i,j,k,nnew,iNH414_).NE.t(i,j,k,nnew,iNH414_)) THEN
                t(i,j,k,nnew,iNH4_)=new_conc
                t(i,j,k,nnew,iNH415_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iNH4_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iNH414_)=t(i,j,k,nnew,iNH4_)-          &
     &                                t(i,j,k,nnew,iNH415_)
                print *, "set pos nnew NH414 i,j,k=",i,j,k
              ENDIF
!DON
              IF (t(i,j,k,nnew,iDON_).LE.0.0_r8 .OR. t(i,j,k,nnew,iDON_).NE.t(i,j,k,nnew,iDON_)) THEN
                t(i,j,k,nnew,iDON_)=new_conc
                t(i,j,k,nnew,iDON15_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iDON_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iDON14_)=t(i,j,k,nnew,iDON_)-          &
     &                                t(i,j,k,nnew,iDON15_)
                print *, "set pos nnew DON i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iDON15_).LE.0.0_r8 .OR. t(i,j,k,nnew,iDON15_).NE.t(i,j,k,nnew,iDON15_)) THEN
                t(i,j,k,nnew,iDON_)=new_conc
                t(i,j,k,nnew,iDON15_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iDON_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iDON14_)=t(i,j,k,nnew,iDON_)-          &
     &                                t(i,j,k,nnew,iDON15_)
                print *, "set pos nnew DON15 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iDON14_).LE.0.0_r8 .OR. t(i,j,k,nnew,iDON14_).NE.t(i,j,k,nnew,iDON14_)) THEN
                t(i,j,k,nnew,iDON_)=new_conc
                t(i,j,k,nnew,iDON15_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iDON_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iDON14_)=t(i,j,k,nnew,iDON_)-          &
     &                                t(i,j,k,nnew,iDON15_)
                print *, "set pos nnew DON14 i,j,k=",i,j,k
              ENDIF
!PON
              IF (t(i,j,k,nnew,iPON_).LE.0.0_r8 .OR. t(i,j,k,nnew,iPON_).NE.t(i,j,k,nnew,iPON_)) THEN
                t(i,j,k,nnew,iPON_)=new_conc
                t(i,j,k,nnew,iPON15_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iPON_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iPON14_)=t(i,j,k,nnew,iPON_)-          &
     &                                t(i,j,k,nnew,iPON15_)
                print *, "set pos nnew PON i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iPON15_).LE.0.0_r8 .OR. t(i,j,k,nnew,iPON15_).NE.t(i,j,k,nnew,iPON15_)) THEN
                t(i,j,k,nnew,iPON_)=new_conc
                t(i,j,k,nnew,iPON15_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iPON_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iPON14_)=t(i,j,k,nnew,iPON_)-          &
     &                                t(i,j,k,nnew,iPON15_)
                print *, "set pos nnew PON15 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iPON14_).LE.0.0_r8 .OR. t(i,j,k,nnew,iPON14_).NE.t(i,j,k,nnew,iPON14_)) THEN
                t(i,j,k,nnew,iPON_)=new_conc
                t(i,j,k,nnew,iPON15_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iPON_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iPON14_)=t(i,j,k,nnew,iPON_)-          &
     &                                t(i,j,k,nnew,iPON15_)
                print *, "set pos nnew PON14 i,j,k=",i,j,k
              ENDIF
!Sphy
              IF (t(i,j,k,nnew,iSphy).LE.0.0_r8 .OR. t(i,j,k,nnew,iSphy).NE.t(i,j,k,nnew,iSphy)) THEN
                t(i,j,k,nnew,iSphy)=new_conc
                t(i,j,k,nnew,iSphy15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iSphy)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iSphy14)=t(i,j,k,nnew,iSphy)-          &
     &                                t(i,j,k,nnew,iSphy15)
                print *, "set pos nnew Sphy i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iSphy15).LE.0.0_r8 .OR. t(i,j,k,nnew,iSphy15).NE.t(i,j,k,nnew,iSphy15)) THEN
                t(i,j,k,nnew,iSphy)=new_conc
                t(i,j,k,nnew,iSphy15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iSphy)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iSphy14)=t(i,j,k,nnew,iSphy)-          &
     &                                t(i,j,k,nnew,iSphy15)
                print *, "set pos nnew Sphy15 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iSphy14).LE.0.0_r8 .OR. t(i,j,k,nnew,iSphy14).NE.t(i,j,k,nnew,iSphy14)) THEN
                t(i,j,k,nnew,iSphy)=new_conc
                t(i,j,k,nnew,iSphy15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iSphy)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iSphy14)=t(i,j,k,nnew,iSphy)-          &
     &                                t(i,j,k,nnew,iSphy15)
                print *, "set pos nnew Sphy14 i,j,k=",i,j,k
              ENDIF
!Lphy
              IF (t(i,j,k,nnew,iLphy).LE.0.0_r8 .OR. t(i,j,k,nnew,iLphy).NE.t(i,j,k,nnew,iLphy)) THEN
                t(i,j,k,nnew,iLphy)=new_conc
                t(i,j,k,nnew,iLphy15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iLphy)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iLphy14)=t(i,j,k,nnew,iLphy)-          &
     &                                t(i,j,k,nnew,iLphy15)
                print *, "set pos nnew Lphy i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iLphy15).LE.0.0_r8 .OR. t(i,j,k,nnew,iLphy15).NE.t(i,j,k,nnew,iLphy15)) THEN
                t(i,j,k,nnew,iLphy)=new_conc
                t(i,j,k,nnew,iLphy15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iLphy)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iLphy14)=t(i,j,k,nnew,iLphy)-          &
     &                                t(i,j,k,nnew,iLphy15)
                print *, "set pos nnew Lphy15 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iLphy14).LE.0.0_r8 .OR. t(i,j,k,nnew,iLphy14).NE.t(i,j,k,nnew,iLphy14)) THEN
                t(i,j,k,nnew,iLphy)=new_conc
                t(i,j,k,nnew,iLphy15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iLphy)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iLphy14)=t(i,j,k,nnew,iLphy)-          &
     &                                t(i,j,k,nnew,iLphy15)
                print *, "set pos nnew Lphy14 i,j,k=",i,j,k
              ENDIF
!Szoo
              IF (t(i,j,k,nnew,iSzoo).LE.0.0_r8 .OR. t(i,j,k,nnew,iSzoo).NE.t(i,j,k,nnew,iSzoo)) THEN
                t(i,j,k,nnew,iSzoo)=new_conc
                t(i,j,k,nnew,iSzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iSzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iSzoo14)=t(i,j,k,nnew,iSzoo)-          &
     &                                t(i,j,k,nnew,iSzoo15)
                print *, "set pos nnew Szoo i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iSzoo15).LE.0.0_r8 .OR. t(i,j,k,nnew,iSzoo15).NE.t(i,j,k,nnew,iSzoo15)) THEN
                t(i,j,k,nnew,iSzoo)=new_conc
                t(i,j,k,nnew,iSzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iSzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iSzoo14)=t(i,j,k,nnew,iSzoo)-          &
     &                                t(i,j,k,nnew,iSzoo15)
                print *, "set pos nnew Szoo15 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iSzoo14).LE.0.0_r8 .OR. t(i,j,k,nnew,iSzoo14).NE.t(i,j,k,nnew,iSzoo14)) THEN
                t(i,j,k,nnew,iSzoo)=new_conc
                t(i,j,k,nnew,iSzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iSzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iSzoo14)=t(i,j,k,nnew,iSzoo)-          &
     &                                t(i,j,k,nnew,iSzoo15)
                print *, "set pos nnew Szoo14 i,j,k=",i,j,k
              ENDIF
!Lzoo
              IF (t(i,j,k,nnew,iLzoo).LE.0.0_r8 .OR. t(i,j,k,nnew,iLzoo).NE.t(i,j,k,nnew,iLzoo)) THEN
                t(i,j,k,nnew,iLzoo)=new_conc
                t(i,j,k,nnew,iLzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iLzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iLzoo14)=t(i,j,k,nnew,iLzoo)-          &
     &                                t(i,j,k,nnew,iLzoo15)
                print *, "set pos nnew Lzoo i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iLzoo15).LE.0.0_r8 .OR. t(i,j,k,nnew,iLzoo15).NE.t(i,j,k,nnew,iLzoo15)) THEN
                t(i,j,k,nnew,iLzoo)=new_conc
                t(i,j,k,nnew,iLzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iLzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iLzoo14)=t(i,j,k,nnew,iLzoo)-          &
     &                                t(i,j,k,nnew,iLzoo15)
                print *, "set pos nnew Lzoo15 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iLzoo14).LE.0.0_r8 .OR. t(i,j,k,nnew,iLzoo14).NE.t(i,j,k,nnew,iLzoo14)) THEN
                t(i,j,k,nnew,iLzoo)=new_conc
                t(i,j,k,nnew,iLzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iLzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iLzoo14)=t(i,j,k,nnew,iLzoo)-          &
     &                                t(i,j,k,nnew,iLzoo15)
                print *, "set pos nnew Lzoo14 i,j,k=",i,j,k
              ENDIF
!Pzoo
              IF (t(i,j,k,nnew,iPzoo).LE.0.0_r8 .OR. t(i,j,k,nnew,iPzoo).NE.t(i,j,k,nnew,iPzoo)) THEN
                t(i,j,k,nnew,iPzoo)=new_conc
                t(i,j,k,nnew,iPzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iPzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iPzoo14)=t(i,j,k,nnew,iPzoo)-          &
     &                                t(i,j,k,nnew,iPzoo15)
                print *, "set pos nnew Pzoo i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iPzoo15).LE.0.0_r8 .OR. t(i,j,k,nnew,iPzoo15).NE.t(i,j,k,nnew,iPzoo15)) THEN
                t(i,j,k,nnew,iPzoo)=new_conc
                t(i,j,k,nnew,iPzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iPzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iPzoo14)=t(i,j,k,nnew,iPzoo)-          &
     &                                t(i,j,k,nnew,iPzoo15)
                print *, "set pos nnew Pzoo15 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nnew,iPzoo14).LE.0.0_r8 .OR. t(i,j,k,nnew,iPzoo14).NE.t(i,j,k,nnew,iPzoo14)) THEN
                t(i,j,k,nnew,iPzoo)=new_conc
                t(i,j,k,nnew,iPzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nnew,iPzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nnew,iPzoo14)=t(i,j,k,nnew,iPzoo)-          &
     &                                t(i,j,k,nnew,iPzoo15)
                print *, "set pos nnew Pzoo14 i,j,k=",i,j,k
              ENDIF

!NO3
              IF (t(i,j,k,nstp,iNO3_).LE.0.0_r8 .OR. t(i,j,k,nstp,iNO3_).NE.t(i,j,k,nstp,iNO3_)) THEN
                t(i,j,k,nstp,iNO3_)=new_conc
                t(i,j,k,nstp,iNO315_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iNO3_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iNO314_)=t(i,j,k,nstp,iNO3_)-          &
     &                                t(i,j,k,nstp,iNO315_)
                print *, "set pos nstp NO3 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iNO315_).LE.0.0_r8 .OR. t(i,j,k,nstp,iNO315_).NE.t(i,j,k,nstp,iNO315_)) THEN
                t(i,j,k,nstp,iNO3_)=new_conc
                t(i,j,k,nstp,iNO315_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iNO3_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iNO314_)=t(i,j,k,nstp,iNO3_)-          &
     &                                t(i,j,k,nstp,iNO315_)
                print *, "set pos nstp NO315 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iNO314_).LE.0.0_r8 .OR. t(i,j,k,nstp,iNO314_).NE.t(i,j,k,nstp,iNO314_)) THEN
                t(i,j,k,nstp,iNO3_)=new_conc
                t(i,j,k,nstp,iNO315_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iNO3_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iNO314_)=t(i,j,k,nstp,iNO3_)-          &
     &                                t(i,j,k,nstp,iNO315_)
                print *, "set pos nstp NO314 i,j,k=",i,j,k
              ENDIF
!NH4
              IF (t(i,j,k,nstp,iNH4_).LE.0.0_r8 .OR. t(i,j,k,nstp,iNH4_).NE.t(i,j,k,nstp,iNH4_)) THEN
                t(i,j,k,nstp,iNH4_)=new_conc
                t(i,j,k,nstp,iNH415_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iNH4_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iNH414_)=t(i,j,k,nstp,iNH4_)-          &
     &                                t(i,j,k,nstp,iNH415_)
                print *, "set pos nstp NH4 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iNH415_).LE.0.0_r8 .OR. t(i,j,k,nstp,iNH415_).NE.t(i,j,k,nstp,iNH415_)) THEN
                t(i,j,k,nstp,iNH4_)=new_conc
                t(i,j,k,nstp,iNH415_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iNH4_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iNH414_)=t(i,j,k,nstp,iNH4_)-          &
     &                                t(i,j,k,nstp,iNH415_)
                print *, "set pos nstp NH415 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iNH414_).LE.0.0_r8 .OR. t(i,j,k,nstp,iNH414_).NE.t(i,j,k,nstp,iNH414_)) THEN
                t(i,j,k,nstp,iNH4_)=new_conc
                t(i,j,k,nstp,iNH415_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iNH4_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iNH414_)=t(i,j,k,nstp,iNH4_)-          &
     &                                t(i,j,k,nstp,iNH415_)
                print *, "set pos nstp NH414 i,j,k=",i,j,k
              ENDIF
!DON
              IF (t(i,j,k,nstp,iDON_).LE.0.0_r8 .OR. t(i,j,k,nstp,iDON_).NE.t(i,j,k,nstp,iDON_)) THEN
                t(i,j,k,nstp,iDON_)=new_conc
                t(i,j,k,nstp,iDON15_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iDON_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iDON14_)=t(i,j,k,nstp,iDON_)-          &
     &                                t(i,j,k,nstp,iDON15_)
                print *, "set pos nstp DON i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iDON15_).LE.0.0_r8 .OR. t(i,j,k,nstp,iDON15_).NE.t(i,j,k,nstp,iDON15_)) THEN
                t(i,j,k,nstp,iDON_)=new_conc
                t(i,j,k,nstp,iDON15_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iDON_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iDON14_)=t(i,j,k,nstp,iDON_)-          &
     &                                t(i,j,k,nstp,iDON15_)
                print *, "set pos nstp DON15 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iDON14_).LE.0.0_r8 .OR. t(i,j,k,nstp,iDON14_).NE.t(i,j,k,nstp,iDON14_)) THEN
                t(i,j,k,nstp,iDON_)=new_conc
                t(i,j,k,nstp,iDON15_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iDON_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iDON14_)=t(i,j,k,nstp,iDON_)-          &
     &                                t(i,j,k,nstp,iDON15_)
                print *, "set pos nstp DON14 i,j,k=",i,j,k
              ENDIF
!PON
              IF (t(i,j,k,nstp,iPON_).LE.0.0_r8 .OR. t(i,j,k,nstp,iPON_).NE.t(i,j,k,nstp,iPON_)) THEN
                t(i,j,k,nstp,iPON_)=new_conc
                t(i,j,k,nstp,iPON15_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iPON_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iPON14_)=t(i,j,k,nstp,iPON_)-          &
     &                                t(i,j,k,nstp,iPON15_)
                print *, "set pos nstp PON i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iPON15_).LE.0.0_r8 .OR. t(i,j,k,nstp,iPON15_).NE.t(i,j,k,nstp,iPON15_)) THEN
                t(i,j,k,nstp,iPON_)=new_conc
                t(i,j,k,nstp,iPON15_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iPON_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iPON14_)=t(i,j,k,nstp,iPON_)-          &
     &                                t(i,j,k,nstp,iPON15_)
                print *, "set pos nstp PON15 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iPON14_).LE.0.0_r8 .OR. t(i,j,k,nstp,iPON14_).NE.t(i,j,k,nstp,iPON14_)) THEN
                t(i,j,k,nstp,iPON_)=new_conc
                t(i,j,k,nstp,iPON15_)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iPON_)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iPON14_)=t(i,j,k,nstp,iPON_)-          &
     &                                t(i,j,k,nstp,iPON15_)
                print *, "set pos nstp PON14 i,j,k=",i,j,k
              ENDIF
!Sphy
              IF (t(i,j,k,nstp,iSphy).LE.0.0_r8 .OR. t(i,j,k,nstp,iSphy).NE.t(i,j,k,nstp,iSphy)) THEN
                t(i,j,k,nstp,iSphy)=new_conc
                t(i,j,k,nstp,iSphy15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iSphy)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iSphy14)=t(i,j,k,nstp,iSphy)-          &
     &                                t(i,j,k,nstp,iSphy15)
                print *, "set pos nstp Sphy i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iSphy15).LE.0.0_r8 .OR. t(i,j,k,nstp,iSphy15).NE.t(i,j,k,nstp,iSphy15)) THEN
                t(i,j,k,nstp,iSphy)=new_conc
                t(i,j,k,nstp,iSphy15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iSphy)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iSphy14)=t(i,j,k,nstp,iSphy)-          &
     &                                t(i,j,k,nstp,iSphy15)
                print *, "set pos nstp Sphy15 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iSphy14).LE.0.0_r8 .OR. t(i,j,k,nstp,iSphy14).NE.t(i,j,k,nstp,iSphy14)) THEN
                t(i,j,k,nstp,iSphy)=new_conc
                t(i,j,k,nstp,iSphy15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iSphy)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iSphy14)=t(i,j,k,nstp,iSphy)-          &
     &                                t(i,j,k,nstp,iSphy15)
                print *, "set pos nstp Sphy14 i,j,k=",i,j,k
              ENDIF
!Lphy
              IF (t(i,j,k,nstp,iLphy).LE.0.0_r8 .OR. t(i,j,k,nstp,iLphy).NE.t(i,j,k,nstp,iLphy)) THEN
                t(i,j,k,nstp,iLphy)=new_conc
                t(i,j,k,nstp,iLphy15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iLphy)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iLphy14)=t(i,j,k,nstp,iLphy)-          &
     &                                t(i,j,k,nstp,iLphy15)
                print *, "set pos nstp Lphy i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iLphy15).LE.0.0_r8 .OR. t(i,j,k,nstp,iLphy15).NE.t(i,j,k,nstp,iLphy15)) THEN
                t(i,j,k,nstp,iLphy)=new_conc
                t(i,j,k,nstp,iLphy15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iLphy)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iLphy14)=t(i,j,k,nstp,iLphy)-          &
     &                                t(i,j,k,nstp,iLphy15)
                print *, "set pos nstp Lphy15 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iLphy14).LE.0.0_r8 .OR. t(i,j,k,nstp,iLphy14).NE.t(i,j,k,nstp,iLphy14)) THEN
                t(i,j,k,nstp,iLphy)=new_conc
                t(i,j,k,nstp,iLphy15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iLphy)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iLphy14)=t(i,j,k,nstp,iLphy)-          &
     &                                t(i,j,k,nstp,iLphy15)
                print *, "set pos nstp Lphy14 i,j,k=",i,j,k
              ENDIF
!Szoo
              IF (t(i,j,k,nstp,iSzoo).LE.0.0_r8 .OR. t(i,j,k,nstp,iSzoo).NE.t(i,j,k,nstp,iSzoo)) THEN
                t(i,j,k,nstp,iSzoo)=new_conc
                t(i,j,k,nstp,iSzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iSzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iSzoo14)=t(i,j,k,nstp,iSzoo)-          &
     &                                t(i,j,k,nstp,iSzoo15)
                print *, "set pos nstp Szoo i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iSzoo15).LE.0.0_r8 .OR. t(i,j,k,nstp,iSzoo15).NE.t(i,j,k,nstp,iSzoo15)) THEN
                t(i,j,k,nstp,iSzoo)=new_conc
                t(i,j,k,nstp,iSzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iSzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iSzoo14)=t(i,j,k,nstp,iSzoo)-          &
     &                                t(i,j,k,nstp,iSzoo15)
                print *, "set pos nstp Szoo15 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iSzoo14).LE.0.0_r8 .OR. t(i,j,k,nstp,iSzoo14).NE.t(i,j,k,nstp,iSzoo14)) THEN
                t(i,j,k,nstp,iSzoo)=new_conc
                t(i,j,k,nstp,iSzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iSzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iSzoo14)=t(i,j,k,nstp,iSzoo)-          &
     &                                t(i,j,k,nstp,iSzoo15)
                print *, "set pos nstp Szoo14 i,j,k=",i,j,k
              ENDIF
!Lzoo
              IF (t(i,j,k,nstp,iLzoo).LE.0.0_r8 .OR. t(i,j,k,nstp,iLzoo).NE.t(i,j,k,nstp,iLzoo)) THEN
                t(i,j,k,nstp,iLzoo)=new_conc
                t(i,j,k,nstp,iLzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iLzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iLzoo14)=t(i,j,k,nstp,iLzoo)-          &
     &                                t(i,j,k,nstp,iLzoo15)
                print *, "set pos nstp Lzoo i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iLzoo15).LE.0.0_r8 .OR. t(i,j,k,nstp,iLzoo15).NE.t(i,j,k,nstp,iLzoo15)) THEN
                t(i,j,k,nstp,iLzoo)=new_conc
                t(i,j,k,nstp,iLzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iLzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iLzoo14)=t(i,j,k,nstp,iLzoo)-          &
     &                                t(i,j,k,nstp,iLzoo15)
                print *, "set pos nstp Lzoo15 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iLzoo14).LE.0.0_r8 .OR. t(i,j,k,nstp,iLzoo14).NE.t(i,j,k,nstp,iLzoo14)) THEN
                t(i,j,k,nstp,iLzoo)=new_conc
                t(i,j,k,nstp,iLzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iLzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iLzoo14)=t(i,j,k,nstp,iLzoo)-          &
     &                                t(i,j,k,nstp,iLzoo15)
                print *, "set pos nstp Lzoo14 i,j,k=",i,j,k
              ENDIF
!Pzoo
              IF (t(i,j,k,nstp,iPzoo).LE.0.0_r8 .OR. t(i,j,k,nstp,iPzoo).NE.t(i,j,k,nstp,iPzoo)) THEN
                t(i,j,k,nstp,iPzoo)=new_conc
                t(i,j,k,nstp,iPzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iPzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iPzoo14)=t(i,j,k,nstp,iPzoo)-          &
     &                                t(i,j,k,nstp,iPzoo15)
                print *, "set pos nstp Pzoo i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iPzoo15).LE.0.0_r8 .OR. t(i,j,k,nstp,iPzoo15).NE.t(i,j,k,nstp,iPzoo15)) THEN
                t(i,j,k,nstp,iPzoo)=new_conc
                t(i,j,k,nstp,iPzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iPzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iPzoo14)=t(i,j,k,nstp,iPzoo)-          &
     &                                t(i,j,k,nstp,iPzoo15)
                print *, "set pos nstp Pzoo15 i,j,k=",i,j,k
              ENDIF
              IF (t(i,j,k,nstp,iPzoo14).LE.0.0_r8 .OR. t(i,j,k,nstp,iPzoo14).NE.t(i,j,k,nstp,iPzoo14)) THEN
                t(i,j,k,nstp,iPzoo)=new_conc
                t(i,j,k,nstp,iPzoo15)=((t_d15N+1000.0_r8)*          &
     &                                t(i,j,k,nstp,iPzoo)*Rstd)/    &
     &                                ((t_d15N+1000.0_r8)*Rstd+1000.0_r8)
                t(i,j,k,nstp,iPzoo14)=t(i,j,k,nstp,iPzoo)-          &
     &                                t(i,j,k,nstp,iPzoo15)
                print *, "set pos nstp Pzoo14 i,j,k=",i,j,k
              ENDIF
# ifdef MASKING
            ENDIF
# endif
          END DO
        END DO
      END DO J_LOOP

      RETURN
      END SUBROUTINE positive_N15_tile
