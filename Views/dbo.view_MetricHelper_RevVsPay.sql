SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[view_MetricHelper_RevVsPay]

AS

Select 
	Lgh_number	LegNumber,
	l.mov_number 	MoveNumber,
	l.ord_hdrnumber OrderNumber,

	dbo.fnc_MetricHelper_allocatedTotOrdRevByMiles(lgh_number) AllocatedRevenueByMilePerc,
	dbo.fnc_MetricHelper_AllocateRevForLegByPayPerc(lgh_number) AllocatedTotRevenueByPayPerc,

	dbo.fnc_MetricHelper_LoadedMilesForLegheader(lgh_number) LoadedMilesSegment,
	dbo.fnc_MetricHelper_EmptyMilesForLegheader(lgh_number) EmptyMilesSegment,
	dbo.fnc_MetricHelper_TravelMilesForLegheader(lgh_number) TotalMilesSegment,
	dbo.fnc_MetricHelper_BillableMilesForLegheader(lgh_number) BillableMilesSegment,	
	dbo.fnc_MetricHelper_TravelMilesForMove(l.mov_number)	TravelMilesForMOVE,
	dbo.fnc_MetricHelper_PayForLeg(lgh_number) TotalCompensationForSegment,
	dbo.fnc_MetricHelper_PayForMove(l.mov_number) TotalCompensationForMove,	
	dbo.fnc_MetricHelper_UnallocatedTotOrdRevForLegheader(lgh_number) UnallocatedOrderTotRevenue,
	dbo.fnc_MetricHelper_UnallocatedTotInvRevForLegheader(lgh_number) UnallocatedInvTotRevenue,



	
	lgh_tractor	TractorID,
	lgh_driver1	Driver1ID,
	lgh_driver2	Driver2ID,
	lgh_carrier	CarrierID,
	lgh_startDate	SegmentStartDate,
	lgh_EndDate	SegmentEndDate,
	lgh_startcty_nmstct  SegmentStartCity,
	lgh_endcty_nmstct    SegmentEndCity,
	lgh_startstate 		SegmentStartState,
	lgh_endstate 		SegmentEndState,
	lgh_startregion1 	SegmentStartRegion1,
	lgh_endregion1 		SegmentEndRegion2,
	lgh_outstatus		SegmentStatus,

	lgh_class1	RevClass1,
	lgh_class2	RevClass2,
	lgh_class3	RevClass3,
	lgh_class4	RevClass4,
	lgh_startcity, 
	lgh_endcity, 
	mpp_teamleader, 
	mpp_fleet, 
	mpp_division, 
	mpp_domicile, 
	mpp_company, 
	mpp_terminal, 
	mpp_type1, 
	mpp_type2, 
	mpp_type3, 
	mpp_type4, 
	trc_company, 
	trc_division, 
	trc_fleet, 
	trc_terminal, 
	trc_type1, 
	trc_type2, 
	trc_type3, 
	trc_type4,
	trl_company, 
	trl_fleet, 
	trl_division, 
	trl_terminal, 
	l.trl_type1, 
	trl_type2, 
	trl_type3, 
	trl_type4, 
	l.cmd_code, 
	fgt_description,                
	cmp_id_start 	SegmentStartCmpID, 
	cmp_id_end 	SegmentEndCmpID	,  
	OrderStartDate	=
		ISNULL(
		(Select ord_startdate
		From 	orderheader o
		where 	o.ord_hdrnumber=l.ord_hdrnumber
			AND
			l.ord_hdrnumber>0
		)
		,lgh_StartDate)
	,
	OrderEndDate=
		ISNULL(
		(Select ord_CompletionDate
		From 	orderheader o
		where 	o.ord_hdrnumber=l.ord_hdrnumber
			AND
			l.ord_hdrnumber>0
		)
		,lgh_endDate),
	dbo.fnc_MetricHelper_FirstPayPeriodForLeg(lgh_number) FirstPayPeriodForLeg,
	dbo.fnc_MetricHelper_FirstInvoiceStatusOfOrder(Ord_hdrnumber) FirstInvoiceStatusForOrder

	,
	dbo.fnc_MetricHelper_FirstInvoiceXferDateOfOrder (Ord_hdrnumber) FirstInvoiceXferDateForOrder	
	

From 
	Legheader l (NOLOCK)
GO
