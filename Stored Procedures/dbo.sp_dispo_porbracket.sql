SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--DROP PROCEDURE sp_dispo_porbracket
--GO
-- Cuando la unidad no tiene tmc marca error.

/*
Create Table TTdispoNLT (
	bracket 			Int	NULL,
	Ordenes 			Int	NULL,
	unidades 			Int	NULL)

Create Table TTdispoMTY (
	bracket 			Int	NULL,
	Ordenes 			Int	NULL,
	unidades 			Int	NULL)

Create Table TTdispoGDL (
	bracket 			Int	NULL,
	Ordenes 			Int	NULL,
	unidades 			Int	NULL)

Create Table TTdispoQRO (
	bracket 			Int	NULL,
	Ordenes 			Int	NULL,
	unidades 			Int	NULL)

Create Table TTdispoMEX (
	bracket 			Int	NULL,
	Ordenes 			Int	NULL,
	unidades 			Int	NULL)
*/


CREATE   PROCEDURE [dbo].[sp_dispo_porbracket]
AS

DECLARE		
	@hoursbackdate			DATETIME,
	@hoursoutdate			DATETIME,
	@totalordenes12			INT, 
	@totalordenes24			INT, 
	@totalordenes36			INT, 
	@totalordenes48			INT,
	@totalunidades12		INT,
	@totalunidades24		INT,
	@totalunidades36		INT,
	@totalunidades48		INT


delete TTdispoNLT 
delete TTdispoMTY
delete TTdispoGDL
delete TTdispoQRO 
delete TTdispoMEX 

/* -- ORDENES -- */
-- Terminal NUEVO LAREDO, 
		select @totalordenes12 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('LAD') and lgh_startdate >= DATEADD(hour, -999, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  12, GETDATE())


		select @totalunidades12 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, 999, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  12, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'LAD'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 999, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  12, GETDATE()))


		
		INSERT INTO TTdispoNLT(bracket,Ordenes,unidades)
		Values(12,@totalordenes12 ,@totalunidades12)
		
		select @totalordenes24 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('LAD') and lgh_startdate >= DATEADD(hour, 12, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  24, GETDATE())

		select @totalunidades24 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, -12, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  24, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'LAD'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 12, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  24, GETDATE()))
		
		INSERT INTO TTdispoNLT(bracket,Ordenes,unidades)
		Values(24,@totalordenes24 ,@totalunidades24)
		
		select @totalordenes36 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('LAD') and lgh_startdate >= DATEADD(hour, 24, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  36, GETDATE())

		select @totalunidades36 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, -24, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  36, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'LAD'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 24, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  36, GETDATE()))
		
		
		INSERT INTO TTdispoNLT(bracket,Ordenes,unidades)
		Values(36,@totalordenes36 ,@totalunidades36)
		
		select @totalordenes48 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('LAD') and lgh_startdate >= DATEADD(hour, 0, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  999, GETDATE())

		select @totalunidades48 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, -0, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  999, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'LAD'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 0, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  999, GETDATE()))

		
		INSERT INTO TTdispoNLT(bracket,Ordenes,unidades)
		Values(48,@totalordenes48 ,@totalunidades48)


/* -- ORDENES -- */
-- Terminal MONTERREY, 
		select @totalordenes12 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('MTE') and lgh_startdate >= DATEADD(hour, 999, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  12, GETDATE())

		select @totalunidades12 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, -999, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  12, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'MTE'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 999, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  12, GETDATE()))



		
		INSERT INTO TTdispoMTY(bracket,Ordenes,unidades)
		Values(12,@totalordenes12 ,@totalunidades12)
		
		select @totalordenes24 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('MTE') and lgh_startdate >= DATEADD(hour, 12, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  24, GETDATE())

		select @totalunidades24 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, -12, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  24, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'MTE'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 12, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  24, GETDATE()))

		
		INSERT INTO TTdispoMTY(bracket,Ordenes,unidades)
		Values(24,@totalordenes24 ,@totalunidades24)
		
		select @totalordenes36 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('MTE') and lgh_startdate >= DATEADD(hour, 24, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  36, GETDATE())


		select @totalunidades36 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, 24, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  36, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'MTE'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 24, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  36, GETDATE()))

		
		INSERT INTO TTdispoMTY(bracket,Ordenes,unidades)
		Values(36,@totalordenes36 ,@totalunidades36)
		
		select @totalordenes48 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('MTE') and lgh_startdate >= DATEADD(hour, 0, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  999, GETDATE())

		select @totalunidades48 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, 0, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  999, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'MTE'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 0, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  999, GETDATE()))

		
		INSERT INTO TTdispoMTY(bracket,Ordenes,unidades)
		Values(48,@totalordenes48 ,@totalunidades48)

/* -- ORDENES -- */
-- Terminal GUADALAJARA, 
		select @totalordenes12 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('GUD') and lgh_startdate >= DATEADD(hour, 999, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  12, GETDATE())

		select @totalunidades12 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, 999, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  12, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'GUD'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 999, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  12, GETDATE()))

		
		INSERT INTO TTdispoGDL(bracket,Ordenes,unidades)
		Values(12,@totalordenes12 ,@totalunidades12)
		
		select @totalordenes24 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('GUD') and lgh_startdate >= DATEADD(hour, 12, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  24, GETDATE())

		select @totalunidades24 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, 999, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  12, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'GUD'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 12, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  24, GETDATE()))

		
		INSERT INTO TTdispoGDL(bracket,Ordenes,unidades)
		Values(24,@totalordenes24 ,@totalunidades24)
		
		select @totalordenes36 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('GUD') and lgh_startdate >= DATEADD(hour, 24, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  36, GETDATE())

		select @totalunidades36 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, 24, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  36, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'GUD'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 24, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  36, GETDATE()))
		
		
		INSERT INTO TTdispoGDL(bracket,Ordenes,unidades)
		Values(36,@totalordenes36 ,@totalunidades36)
		
		select @totalordenes48 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('GUD') and lgh_startdate >= DATEADD(hour, 0, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  999, GETDATE())


		select @totalunidades48 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, 0, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  999, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'GUD'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 0, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  999, GETDATE()))
		
		INSERT INTO TTdispoGDL(bracket,Ordenes,unidades)
		Values(48,@totalordenes48 ,@totalunidades48)


/* -- ORDENES -- */
-- Terminal QUERETARO, 
		select @totalordenes12 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('QRO') and lgh_startdate >= DATEADD(hour, 999, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  12, GETDATE())

		select @totalunidades12 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, 999, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  12, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'QRO'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 999, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  12, GETDATE()))

		
		INSERT INTO TTdispoQRO(bracket,Ordenes,unidades)
		Values(12,@totalordenes12 ,@totalunidades12)
		
		select @totalordenes24 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('QRO') and lgh_startdate >= DATEADD(hour, 12, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  24, GETDATE())

		select @totalunidades24 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, 12, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  24, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'QRO'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 12, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  24, GETDATE()))



		
		INSERT INTO TTdispoQRO(bracket,Ordenes,unidades)
		Values(24,@totalordenes24 ,@totalunidades24)
		
		select @totalordenes36 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('QRO') and lgh_startdate >= DATEADD(hour, 24, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  36, GETDATE())


		select @totalunidades36 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, 24, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  36, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'QRO'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 24, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  36, GETDATE()))
		
		
		INSERT INTO TTdispoQRO(bracket,Ordenes,unidades)
		Values(36,@totalordenes36 ,@totalunidades36)
		
		select @totalordenes48 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('QRO') and lgh_startdate >= DATEADD(hour, 0, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  999, GETDATE())


		select @totalunidades48 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, 0, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  999, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'QRO'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 0, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  999, GETDATE()))

		
		INSERT INTO TTdispoQRO(bracket,Ordenes,unidades)
		Values(48,@totalordenes48 ,@totalunidades48)



/* -- ORDENES -- */
-- Terminal MEXICO, 
		select @totalordenes12 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('MEX') and lgh_startdate >= DATEADD(hour, 999, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  12, GETDATE())

		select @totalunidades12 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, 999, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  12, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'MEX'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 999, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  12, GETDATE()))
		
		INSERT INTO TTdispoMEX(bracket,Ordenes,unidades)
		Values(12,@totalordenes12 ,@totalunidades12)

		
		select @totalordenes24 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('MEX') and lgh_startdate >= DATEADD(hour, 12, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  24, GETDATE())


		select @totalunidades24 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, 12, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  24, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'MEX'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 12, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  24, GETDATE()))
		


		
		INSERT INTO TTdispoMEX(bracket,Ordenes,unidades)
		Values(24,@totalordenes24 ,@totalunidades24)
		
		select @totalordenes36 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('MEX') and lgh_startdate >= DATEADD(hour, 24, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  36, GETDATE())

		select @totalunidades36 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, 24, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  36, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'MEX'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 24, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  36, GETDATE()))



		
		
		INSERT INTO TTdispoMEX(bracket,Ordenes,unidades)
		Values(36,@totalordenes36 ,@totalunidades36)
		
		select @totalordenes48 = IsNull(count (ord_hdrnumber), 0) 
		from legheader 
		where lgh_outstatus = 'AVL' and lgh_class3 = 'BAJ' and 
		      lgh_class2 IN ('MEX') and lgh_startdate >= DATEADD(hour, 0, GETDATE()) AND  
		      lgh_startdate <= DATEADD(hour,  999, GETDATE())

		select @totalunidades48 = IsNull(count (ord_hdrnumber),0) 
		from legheader 
		where  	lgh_startdate >= DATEADD(hour, 0, GETDATE())
			AND lgh_startdate <= DATEADD(hour,  999, GETDATE()) 
			and trc_fleet in ('01','08','09') 
			and lgh_active = 'Y' 
			and lgh_class2 = 'MEX'
			and lgh_tractor in (
				select [tractor] from vTTSTMW_TractorProfile 
				where trcType3 = 'BAJ' and DRVType3 = 'BAJ' and
				[Available Date] >= DATEADD(hour, 0, GETDATE()) AND
				[Available Date] <= DATEADD(hour,  999, GETDATE()))

		
		INSERT INTO TTdispoMEX(bracket,Ordenes,unidades)
		Values(48,@totalordenes48 ,@totalunidades48)

GO
