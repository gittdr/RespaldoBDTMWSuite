SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[rptSummary_pay_rev] 
	(@MinDate datetime,
	 @Maxdate datetime) as

/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/26/2007.01 ? PTS40189 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

-- select * from legheader where 1=0

select 
	legheader.lgh_number lgh_number,
	min(legheader.mov_number) mov_number,
	min(legheader.lgh_Driver1) Drv1,
	min(legheader.lgh_tractor) Tractor,
	isNull(sum(pyd_amount),0) LegPayAmt
	
into #t
from 	legheader LEFT OUTER JOIN paydetail ON legheader.lgh_number = paydetail.lgh_number  --pts40189 outer join conversion
where
	legheader.lgh_startdate>=@MinDate
	and 
	legheader.lgh_startdate<=@MaxDate
group by legheader.lgh_number

--select * from #t

select 
	min(#t.lgh_number) lgh_number,
	min(#t.mov_number) mov_number,
	min(LegPayAmt) LegPayAmt,
	min(drv1) drv1,
	min(tractor) tractor,

	isNull(sum(stops.stp_lgh_mileage),0) LegMiles,

	--(isNull(min(LegPayAmt)/sum(stops.stp_lgh_mileage) ,0))
	--		PayPerMile


	(CASE IsNull(sum(stops.stp_lgh_mileage),0)
	WHEN 0 THEN 0
	ELSE (isNull(min(LegPayAmt)/ IsNull(sum(stops.stp_lgh_mileage),0) ,0))
	END) PayPerMile




	into #t1
	from #t, stops
	where #t.lgh_number=stops.lgh_number
	group by #t.lgh_number

--select * from #t1



select 
	Min(#t1.lgh_number) lgh_number,
	min(#t1.mov_number)mov_number ,
	min(drv1) drv1,
	min(tractor) tractor,

	min(LegPayAmt) LegPayAmt,
	min(LegMiles)LegMiles ,
	min(PayPerMile) PayPerMile,
	isNull(sum(ivh_totalcharge),0) TotalInvoiceRevenue 
into #t2
from #t1 LEFT OUTER JOIN invoiceheader ON #t1.mov_number = invoiceheader.mov_number  --pts 40189 outer join conversion
group by lgh_number

--select * from #t2

select 
	Min(#t2.lgh_number) LegNumber,
	min(#t2.mov_number) MoveNumber ,
	min(drv1) Driver1,
	min(tractor) Tractor,

	min(LegPayAmt) LegPayAmount,
	min(LegMiles) LegMiles ,
	min(PayPerMile) PayPerMile,
	min(TotalInvoiceRevenue)  TotalInvoiceRevenue,
	isNull(sum(stops.stp_lgh_mileage),0) TotalMilesForMoveNumber
	
	into #t3
	from 	#t2 LEFT OUTER JOIN stops ON #t2.mov_number = stops.mov_number  --pts40189 outer join conversion
	group by #t2.lgh_number



select *,  


	isNull(convert(float,LegMiles)/(CASE TotalMilesForMoveNumber
				WHEN 0 THEN 1
				ELSE TotalMilesForMoveNumber
				END),0)
		PercentLegMilesOfMoveMiles,


	
	--isNull(convert(float,LegMiles)/TotalMilesForMoveNumber,0)
	--	PercentDispMilesOfMove,

	isNull(TotalInvoiceRevenue	*(convert(float,LegMiles)
			/(CASE TotalMilesForMoveNumber
				WHEN 0 THEN 1
				ELSE TotalMilesForMoveNumber
				END) ),0 )
		ProRatedRevForLeg


	--isNull(TotalInvoiceRevenue	*(convert(float,LegMiles)/TotalMilesForMoveNumber),0 )
	--	ProRatedRev

	
	from #t3
drop table #t
drop table #t1
drop table #t2
drop table #t3
GO
GRANT EXECUTE ON  [dbo].[rptSummary_pay_rev] TO [public]
GO
