SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[rptSplitsHandW] 
	(@MinDate datetime,
	 @Maxdate datetime) as
/* ------------------------------------------------------------- */
	/* Round up moves to include */
/* ------------------------------------------------------------- */

Select 
	distinct mov_number 
Into 	
	#AllMoves
From 
	Legheader
where 
	legheader.lgh_startdate>=@MinDate
	and 
	legheader.lgh_startdate<=@MaxDate

/* ------------------------------------------------------------- */
		/* Round up total miles by Move # */
/* ------------------------------------------------------------- */
SELECT  
	Sum(	isNull(stops.stp_lgh_mileage,0) ) TotalMilesForMoveNumber,
	stops.mov_number
Into 
	#SumMilesForMove
From
	stops,
	#AllMoves
where
	#AllMoves.mov_number=stops.mov_number
group by 
	stops.mov_number

/* ------------------------------------------------------------- */
		/* Round up legheadermiles  -- Also get list of LGH*/
/* ------------------------------------------------------------- */
select 
	stops.lgh_number,
	sum( IsNull(stops.stp_lgh_mileage,0) ) LegMiles,
	sum( IsNull(stops.stp_ord_mileage,0) ) BilledMiles
into 
	#LegMiles
from 	
	#AllMoves, 
	stops
where 
	#AllMoves.Mov_number=stops.Mov_number
group by stops.lgh_number
/* ------------------------------------------------------------- */
		/* Round up MT legheadermiles  */
/* ------------------------------------------------------------- */

select 
	stops.lgh_number,
	sum( IsNull(stops.stp_lgh_mileage,0) ) MTMiles

into 
	#MTMiles
from 	
	#AllMoves, 
	stops
where 
	#AllMoves.Mov_number=stops.Mov_number
	and 
	stops.stp_loadstatus <> 'LD'
group by stops.lgh_number


/* ------------------------------------------------------------- */
		/* Round up Total Invoice amount for move*/
/* ------------------------------------------------------------- */
select 
	#AllMoves.mov_number,	
	sum(	isNull(ivh_totalcharge,0) ) GrossRevForMove
into 
	#GrossRevForMove
from 
	#AllMoves, 
	invoiceheader
where 
	#AllMoves.mov_number = invoiceheader.mov_number
group by #AllMoves.mov_number
--Select *  from #GrossRevForMove
/* ------------------------------------------------------------- */
	/* Round up Total LH amount H & W Style for move*/	
/* ------------------------------------------------------------- */
select 
	#AllMoves.mov_number,	
	sum(	isNull(ivd_charge,0)	) LHRevForMove
into #LHRevForMove
	from 
		#AllMoves, 
		invoiceheader,
		invoicedetail
	where 
		#AllMoves.mov_number = invoiceheader.mov_number
		and 
		invoiceheader.ivh_hdrnumber=invoicedetail.ivh_hdrnumber
		AND
		invoicedetail.cht_itemcode  in
			('LHD','LHW','LHC','LHV','LHF','LHT',	
			'100LTR','EXPAND','DEADHD','DETENT',
			'DOUBLE','HANDUN','HOLIDA','LAYOVR',
			'LOAD','MISC','MOVE','OVERSZ',
			'REDELV','RELOAD','RECSGN',
			'DEL','RETURN','REJECT',
			'SHUTTL','SPOTTL',
			'ID','TARP','TRKNOT',
			'WAIT','WKEND','A-FRME',
			'PLT','LHO','OOR',
			'STOPS','MIN',
			'STRGHT','FAC',
			'ORDFLT','REJMAT')

group by #AllMoves.mov_number

/* ------------------------------------------------------------- */

Select 
	legheader.lgh_number,
	legheader.mov_number,
	legheader.lgh_tractor,
	legheader.lgh_driver1,
	legheader.lgh_driver2,
	legheader.lgh_startdate,
	legheader.lgh_enddate,
	legheader.lgh_startcity,
	legheader.lgh_endcity,
	legheader.trl_type1,

	#SumMilesForMove.TotalMilesForMoveNumber,
	#LegMiles.LegMiles,
	IsNull(#MTMiles.MTMiles,0) MTMiles,
	isNull( (#LegMiles.LegMiles -#MTMiles.MTMiles),0) LoadedMiles,
	#LegMiles.BilledMiles,
	#GrossRevForMove.GrossRevForMove,
	#LHRevForMove.LHRevForMove,
	(#GrossRevForMove.GrossRevForMove-#LHRevForMove.LHRevForMove) AccRev 

From
	Legheader
		inner join #AllMoves on #AllMoves.mov_number=Legheader.mov_number	
		left outer join #SumMilesForMove on Legheader.mov_number = #SumMilesForMove.mov_number	
		left outer join #LegMiles on legheader.lgh_number = #LegMiles.lgh_number
		left outer join #MTMiles on legheader.lgh_number = #MTMiles.lgh_number
		left outer join #GrossRevForMove on Legheader.mov_number = #GrossRevForMove.mov_number
		left outer join #LHRevForMove on Legheader.mov_number = #LHRevForMove.mov_number
	
Drop table		#AllMoves
Drop table		#SumMilesForMove		
Drop table		#LegMiles
Drop table		#GrossRevForMove
Drop table		#LHRevForMove
	
GO
GRANT EXECUTE ON  [dbo].[rptSplitsHandW] TO [public]
GO
