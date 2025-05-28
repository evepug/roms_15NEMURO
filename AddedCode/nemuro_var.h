/*
** git $Id$
*************************************************** Hernan G. Arango ***
** Copyright (c) 2002-2025 The ROMS Group                             **
**   Licensed under a MIT/X style license                             **
**   See License_ROMS.md                                              **
************************************************************************
**                                                                    **
**  Assigns metadata indices to the Nemuro ecosystem model            **
**  variables that are used in input and output NetCDF files.         **
**  The metadata information is read from "varinfo.yaml".              **
**                                                                    **
**  This file is included in file "mod_ncparam.F", routine            **
**  "initialize_ncparm".                                              **
**                                                                    **
************************************************************************
*/

/*
**  Model state biological tracers.
*/

          CASE ('idTvar(iLphy)')
            idTvar(iLphy)=varid
          CASE ('idTvar(iSphy)')
            idTvar(iSphy)=varid
          CASE ('idTvar(iLzoo)')
            idTvar(iLzoo)=varid
          CASE ('idTvar(iSzoo)')
            idTvar(iSzoo)=varid
          CASE ('idTvar(iPzoo)')
            idTvar(iPzoo)=varid
          CASE ('idTvar(iNO3_)')
            idTvar(iNO3_)=varid
          CASE ('idTvar(iNH4_)')
            idTvar(iNH4_)=varid
          CASE ('idTvar(iPON_)')
            idTvar(iPON_)=varid
          CASE ('idTvar(iDON_)')
            idTvar(iDON_)=varid
          CASE ('idTvar(iSiOH)')
            idTvar(iSiOH)=varid
          CASE ('idTvar(iopal)')
            idTvar(iopal)=varid
#if defined N15
          CASE ('idTvar(iLphy15)')
	    idTvar(iLphy15)=varid
          CASE ('idTvar(iSphy15)')
	    idTvar(iSphy15)=varid
          CASE ('idTvar(iLzoo15)')
	    idTvar(iLzoo15)=varid
          CASE ('idTvar(iSzoo15)')
	    idTvar(iSzoo15)=varid
          CASE ('idTvar(iPzoo15)')
	    idTvar(iPzoo15)=varid
          CASE ('idTvar(iNO315_)')
	    idTvar(iNO315_)=varid
          CASE ('idTvar(iNH415_)')
	    idTvar(iNH415_)=varid
          CASE ('idTvar(iPON15_)')
	    idTvar(iPON15_)=varid
          CASE ('idTvar(iDON15_)')
	    idTvar(iDON15_)=varid
          CASE ('idTvar(iLphy14)')
	    idTvar(iLphy14)=varid
          CASE ('idTvar(iSphy14)')
	    idTvar(iSphy14)=varid
          CASE ('idTvar(iLzoo14)')
	    idTvar(iLzoo14)=varid
          CASE ('idTvar(iSzoo14)')
	    idTvar(iSzoo14)=varid
          CASE ('idTvar(iPzoo14)')
	    idTvar(iPzoo14)=varid
          CASE ('idTvar(iNO314_)')
	    idTvar(iNO314_)=varid
          CASE ('idTvar(iNH414_)')
	    idTvar(iNH414_)=varid
          CASE ('idTvar(iPON14_)')
	    idTvar(iPON14_)=varid
          CASE ('idTvar(iDON14_)')
	    idTvar(iDON14_)=varid
          CASE ('idTvar(iPONratio)')
	    idTvar(iPONratio)=varid
#endif
#ifdef OXY
          CASE ('idTvar(iOxyg)')
	    idTvar(iOxyg)=varid
#endif
#ifdef CARB
          CASE ('idTvar(iTIC_)')
	    idTvar(iTIC_)=varid
          CASE ('idTvar(iTAlk)')
	    idTvar(iTAlk)=varid
          CASE ('idTvar(iCalC)')
	    idTvar(iCalC)=varid
# if defined NEMURO_CARB_EXTRAOUT
          CASE ('idCflx')
	    idCflx=varid
          CASE ('idpCO2')
	    idpCO2=varid
          CASE ('idpH')
	    idpH=varid
# endif
#endif


/*
**  Biological tracers open boundary conditions.
*/

          CASE ('idTbry(iwest,iLphy)')
            idTbry(iwest,iLphy)=varid
          CASE ('idTbry(ieast,iLphy)')
            idTbry(ieast,iLphy)=varid
          CASE ('idTbry(isouth,iLphy)')
            idTbry(isouth,iLphy)=varid
          CASE ('idTbry(inorth,iLphy)')
            idTbry(inorth,iLphy)=varid

          CASE ('idTbry(iwest,iSphy)')
            idTbry(iwest,iSphy)=varid
          CASE ('idTbry(ieast,iSphy)')
            idTbry(ieast,iSphy)=varid
          CASE ('idTbry(isouth,iSphy)')
            idTbry(isouth,iSphy)=varid
          CASE ('idTbry(inorth,iSphy)')
            idTbry(inorth,iSphy)=varid

          CASE ('idTbry(iwest,iLzoo)')
            idTbry(iwest,iLzoo)=varid
          CASE ('idTbry(ieast,iLzoo)')
            idTbry(ieast,iLzoo)=varid
          CASE ('idTbry(isouth,iLzoo)')
            idTbry(isouth,iLzoo)=varid
          CASE ('idTbry(inorth,iLzoo)')
            idTbry(inorth,iLzoo)=varid

          CASE ('idTbry(iwest,iSzoo)')
            idTbry(iwest,iSzoo)=varid
          CASE ('idTbry(ieast,iSzoo)')
            idTbry(ieast,iSzoo)=varid
          CASE ('idTbry(isouth,iSzoo)')
            idTbry(isouth,iSzoo)=varid
          CASE ('idTbry(inorth,iSzoo)')
            idTbry(inorth,iSzoo)=varid

          CASE ('idTbry(iwest,iPzoo)')
            idTbry(iwest,iPzoo)=varid
          CASE ('idTbry(ieast,iPzoo)')
            idTbry(ieast,iPzoo)=varid
          CASE ('idTbry(isouth,iPzoo)')
            idTbry(isouth,iPzoo)=varid
          CASE ('idTbry(inorth,iPzoo)')
            idTbry(inorth,iPzoo)=varid

          CASE ('idTbry(iwest,iNO3_)')
            idTbry(iwest,iNO3_)=varid
          CASE ('idTbry(ieast,iNO3_)')
            idTbry(ieast,iNO3_)=varid
          CASE ('idTbry(isouth,iNO3_)')
            idTbry(isouth,iNO3_)=varid
          CASE ('idTbry(inorth,iNO3_)')
            idTbry(inorth,iNO3_)=varid

          CASE ('idTbry(iwest,iNH4_)')
            idTbry(iwest,iNH4_)=varid
          CASE ('idTbry(ieast,iNH4_)')
            idTbry(ieast,iNH4_)=varid
          CASE ('idTbry(isouth,iNH4_)')
            idTbry(isouth,iNH4_)=varid
          CASE ('idTbry(inorth,iNH4_)')
            idTbry(inorth,iNH4_)=varid

          CASE ('idTbry(iwest,iPON_)')
            idTbry(iwest,iPON_)=varid
          CASE ('idTbry(ieast,iPON_)')
            idTbry(ieast,iPON_)=varid
          CASE ('idTbry(isouth,iPON_)')
            idTbry(isouth,iPON_)=varid
          CASE ('idTbry(inorth,iPON_)')
            idTbry(inorth,iPON_)=varid

          CASE ('idTbry(iwest,iDON_)')
            idTbry(iwest,iDON_)=varid
          CASE ('idTbry(ieast,iDON_)')
            idTbry(ieast,iDON_)=varid
          CASE ('idTbry(isouth,iDON_)')
            idTbry(isouth,iDON_)=varid
          CASE ('idTbry(inorth,iDON_)')
            idTbry(inorth,iDON_)=varid

          CASE ('idTbry(iwest,iSiOH)')
            idTbry(iwest,iSiOH)=varid
          CASE ('idTbry(ieast,iSiOH)')
            idTbry(ieast,iSiOH)=varid
          CASE ('idTbry(isouth,iSiOH)')
            idTbry(isouth,iSiOH)=varid
          CASE ('idTbry(inorth,iSiOH)')
            idTbry(inorth,iSiOH)=varid

          CASE ('idTbry(iwest,iopal)')
            idTbry(iwest,iopal)=varid
          CASE ('idTbry(ieast,iopal)')
            idTbry(ieast,iopal)=varid
          CASE ('idTbry(isouth,iopal)')
            idTbry(isouth,iopal)=varid
          CASE ('idTbry(inorth,iopal)')
            idTbry(inorth,iopal)=varid
#if defined N15
          CASE ('idTbry(iwest,iLphy15)')
	    idTbry(iwest,iLphy15)=varid
          CASE ('idTbry(ieast,iLphy15)')
	    idTbry(ieast,iLphy15)=varid
          CASE ('idTbry(isouth,iLphy15)')
	    idTbry(isouth,iLphy15)=varid
          CASE ('idTbry(inorth,iLphy15)')
	    idTbry(inorth,iLphy15)=varid
    
          CASE ('idTbry(iwest,iSphy15)')
	    idTbry(iwest,iSphy15)=varid
          CASE ('idTbry(ieast,iSphy15)')
	    idTbry(ieast,iSphy15)=varid
          CASE ('idTbry(isouth,iSphy15)')
	    idTbry(isouth,iSphy15)=varid
          CASE ('idTbry(inorth,iSphy15)')
	    idTbry(inorth,iSphy15)=varid
    
          CASE ('idTbry(iwest,iLzoo15)')
	    idTbry(iwest,iLzoo15)=varid
          CASE ('idTbry(ieast,iLzoo15)')
	    idTbry(ieast,iLzoo15)=varid
          CASE ('idTbry(isouth,iLzoo15)')
	    idTbry(isouth,iLzoo15)=varid
          CASE ('idTbry(inorth,iLzoo15)')
	    idTbry(inorth,iLzoo15)=varid
    
          CASE ('idTbry(iwest,iSzoo15)')
	    idTbry(iwest,iSzoo15)=varid
          CASE ('idTbry(ieast,iSzoo15)')
	    idTbry(ieast,iSzoo15)=varid
          CASE ('idTbry(isouth,iSzoo15)')
	    idTbry(isouth,iSzoo15)=varid
          CASE ('idTbry(inorth,iSzoo15)')
	    idTbry(inorth,iSzoo15)=varid
    
          CASE ('idTbry(iwest,iPzoo15)')
	    idTbry(iwest,iPzoo15)=varid
          CASE ('idTbry(ieast,iPzoo15)')
	    idTbry(ieast,iPzoo15)=varid
          CASE ('idTbry(isouth,iPzoo15)')
	    idTbry(isouth,iPzoo15)=varid
          CASE ('idTbry(inorth,iPzoo15)')
	    idTbry(inorth,iPzoo15)=varid
    
          CASE ('idTbry(iwest,iNO315_)')
	    idTbry(iwest,iNO315_)=varid
          CASE ('idTbry(ieast,iNO315_)')
	    idTbry(ieast,iNO315_)=varid
          CASE ('idTbry(isouth,iNO315_)')
	    idTbry(isouth,iNO315_)=varid
          CASE ('idTbry(inorth,iNO315_)')
	    idTbry(inorth,iNO315_)=varid
    
          CASE ('idTbry(iwest,iNH415_)')
	    idTbry(iwest,iNH415_)=varid
          CASE ('idTbry(ieast,iNH415_)')
	    idTbry(ieast,iNH415_)=varid
          CASE ('idTbry(isouth,iNH415_)')
	    idTbry(isouth,iNH415_)=varid
          CASE ('idTbry(inorth,iNH415_)')
	    idTbry(inorth,iNH415_)=varid
    
          CASE ('idTbry(iwest,iPON15_)')
	    idTbry(iwest,iPON15_)=varid
          CASE ('idTbry(ieast,iPON15_)')
	    idTbry(ieast,iPON15_)=varid
          CASE ('idTbry(isouth,iPON15_)')
	    idTbry(isouth,iPON15_)=varid
          CASE ('idTbry(inorth,iPON15_)')
	    idTbry(inorth,iPON15_)=varid
    
          CASE ('idTbry(iwest,iDON15_)')
	    idTbry(iwest,iDON15_)=varid
          CASE ('idTbry(ieast,iDON15_)')
	    idTbry(ieast,iDON15_)=varid
          CASE ('idTbry(isouth,iDON15_)')
	    idTbry(isouth,iDON15_)=varid
          CASE ('idTbry(inorth,iDON15_)')
	    idTbry(inorth,iDON15_)=varid
          
          CASE ('idTbry(iwest,iLphy14)')
	    idTbry(iwest,iLphy14)=varid
          CASE ('idTbry(ieast,iLphy14)')
	    idTbry(ieast,iLphy14)=varid
          CASE ('idTbry(isouth,iLphy14)')
	    idTbry(isouth,iLphy14)=varid
          CASE ('idTbry(inorth,iLphy14)')
	    idTbry(inorth,iLphy14)=varid
    
          CASE ('idTbry(iwest,iSphy14)')
	    idTbry(iwest,iSphy14)=varid
          CASE ('idTbry(ieast,iSphy14)')
	    idTbry(ieast,iSphy14)=varid
          CASE ('idTbry(isouth,iSphy14)')
	    idTbry(isouth,iSphy14)=varid
          CASE ('idTbry(inorth,iSphy14)')
	    idTbry(inorth,iSphy14)=varid
    
          CASE ('idTbry(iwest,iLzoo14)')
	    idTbry(iwest,iLzoo14)=varid
          CASE ('idTbry(ieast,iLzoo14)')
	    idTbry(ieast,iLzoo14)=varid
          CASE ('idTbry(isouth,iLzoo14)')
	    idTbry(isouth,iLzoo14)=varid
          CASE ('idTbry(inorth,iLzoo14)')
	    idTbry(inorth,iLzoo14)=varid
    
          CASE ('idTbry(iwest,iSzoo14)')
	    idTbry(iwest,iSzoo14)=varid
          CASE ('idTbry(ieast,iSzoo14)')
	    idTbry(ieast,iSzoo14)=varid
          CASE ('idTbry(isouth,iSzoo14)')
	    idTbry(isouth,iSzoo14)=varid
          CASE ('idTbry(inorth,iSzoo14)')
	    idTbry(inorth,iSzoo14)=varid
    
          CASE ('idTbry(iwest,iPzoo14)')
	    idTbry(iwest,iPzoo14)=varid
          CASE ('idTbry(ieast,iPzoo14)')
	    idTbry(ieast,iPzoo14)=varid
          CASE ('idTbry(isouth,iPzoo14)')
	    idTbry(isouth,iPzoo14)=varid
          CASE ('idTbry(inorth,iPzoo14)')
	    idTbry(inorth,iPzoo14)=varid
    
          CASE ('idTbry(iwest,iNO314_)')
	    idTbry(iwest,iNO314_)=varid
          CASE ('idTbry(ieast,iNO314_)')
	    idTbry(ieast,iNO314_)=varid
          CASE ('idTbry(isouth,iNO314_)')
	    idTbry(isouth,iNO314_)=varid
          CASE ('idTbry(inorth,iNO314_)')
	    idTbry(inorth,iNO314_)=varid
    
          CASE ('idTbry(iwest,iNH414_)')
	    idTbry(iwest,iNH414_)=varid
          CASE ('idTbry(ieast,iNH414_)')
	    idTbry(ieast,iNH414_)=varid
          CASE ('idTbry(isouth,iNH414_)')
	    idTbry(isouth,iNH414_)=varid
          CASE ('idTbry(inorth,iNH414_)')
	    idTbry(inorth,iNH414_)=varid
    
          CASE ('idTbry(iwest,iPON14_)')
	    idTbry(iwest,iPON14_)=varid
          CASE ('idTbry(ieast,iPON14_)')
	    idTbry(ieast,iPON14_)=varid
          CASE ('idTbry(isouth,iPON14_)')
	    idTbry(isouth,iPON14_)=varid
          CASE ('idTbry(inorth,iPON14_)')
	    idTbry(inorth,iPON14_)=varid
    
          CASE ('idTbry(iwest,iDON14_)')
	    idTbry(iwest,iDON14_)=varid
          CASE ('idTbry(ieast,iDON14_)')
	    idTbry(ieast,iDON14_)=varid
          CASE ('idTbry(isouth,iDON14_)')
	    idTbry(isouth,iDON14_)=varid
          CASE ('idTbry(inorth,iDON14_)')
	    idTbry(inorth,iDON14_)=varid
    
          CASE ('idTbry(iwest,iPONratio)')
	    idTbry(iwest,iPONratio)=varid
          CASE ('idTbry(ieast,iPONratio)')
	    idTbry(ieast,iPONratio)=varid
          CASE ('idTbry(isouth,iPONratio)')
	    idTbry(isouth,iPONratio)=varid
          CASE ('idTbry(inorth,iPONratio)')
	    idTbry(inorth,iPONratio)=varid
#endif
#ifdef OXY
          CASE ('idTbry(iwest,iOxyg)')
	    idTbry(iwest,iOxyg)=varid
          CASE ('idTbry(ieast,iOxyg)')
	    idTbry(ieast,iOxyg)=varid
          CASE ('idTbry(isouth,iOxyg)')
	    idTbry(isouth,iOxyg)=varid
          CASE ('idTbry(inorth,iOxyg)')
	    idTbry(inorth,iOxyg)=varid
#endif
#ifdef CARB
          CASE ('idTbry(iwest,iTIC_)')
	    idTbry(iwest,iTIC_)=varid
          CASE ('idTbry(ieast,iTIC_)')
	    idTbry(ieast,iTIC_)=varid
          CASE ('idTbry(isouth,iTIC_)')
	    idTbry(isouth,iTIC_)=varid
          CASE ('idTbry(inorth,iTIC_)')
	    idTbry(inorth,iTIC_)=varid
    
          CASE ('idTbry(iwest,iTAlk)')
	    idTbry(iwest,iTAlk)=varid
          CASE ('idTbry(ieast,iTAlk)')
	    idTbry(ieast,iTAlk)=varid
          CASE ('idTbry(isouth,iTAlk)')
	    idTbry(isouth,iTAlk)=varid
          CASE ('idTbry(inorth,iTAlk)')
	    idTbry(inorth,iTAlk)=varid
    
          CASE ('idTbry(iwest,iCalC)')
	    idTbry(iwest,iCalC)=varid
          CASE ('idTbry(ieast,iCalC)')
	    idTbry(ieast,iCalC)=varid
          CASE ('idTbry(isouth,iCalC)')
	    idTbry(isouth,iCalC)=varid
          CASE ('idTbry(inorth,iCalC)')
	    idTbry(inorth,iCalC)=varid
#endif



/*
**  Biological tracers point Source/Sinks (river runoff).
*/

          CASE ('idRtrc(iNO3_)')
            idRtrc(iNO3_)=varid
          CASE ('idRtrc(iNH4_)')
            idRtrc(iNH4_)=varid
          CASE ('idRtrc(iDON_)')
            idRtrc(iDON_)=varid
          CASE ('idRtrc(iPON_)')
            idRtrc(iPON_)=varid
          CASE ('idRtrc(iSiOH)')
            idRtrc(iSiOH)=varid

#if defined N15
          CASE ('idRtrc(iNO315_)')
	    idRtrc(iNO315_)=varid
          CASE ('idRtrc(iNH415_)')
	    idRtrc(iNH415_)=varid
          CASE ('idRtrc(iDON15_)')
	    idRtrc(iDON15_)=varid
          CASE ('idRtrc(iPON15_)')
	    idRtrc(iPON15_)=varid
          CASE ('idRtrc(iNO314_)')
	    idRtrc(iNO314_)=varid
          CASE ('idRtrc(iNH414_)')
	    idRtrc(iNH414_)=varid
          CASE ('idRtrc(iDON14_)')
	    idRtrc(iDON14_)=varid
          CASE ('idRtrc(iPON14_)')
	    idRtrc(iPON14_)=varid
#endif
#ifdef OXY
          CASE ('idRtrc(iOxyg)')
	    idRtrc(iOxyg)=varid
#endif
#ifdef CARB
          CASE ('idRtrc(iTIC_)')
	    idRtrc(iTIC_)=varid
          CASE ('idRtrc(iTAlk)')
	    idRtrc(iTAlk)=varid
          CASE ('idRtrc(iCalC)')
	    idRtrc(iCalC)=varid
# if defined NEMURO_CARB_EXTRAOUT
          CASE ('idCflx')
	    idCflx=varid
          CASE ('idpCO2')
	    idpCO2=varid
          CASE ('idpH')
	    idpH=varid
# endif
#endif
