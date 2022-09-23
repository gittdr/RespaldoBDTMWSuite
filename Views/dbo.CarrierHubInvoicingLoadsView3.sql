SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[CarrierHubInvoicingLoadsView3]
as
	select 'TMWWF_CarrierHub_INVOICING' AS 'TMWWF_CarrierHub_INVOICING',
		leg.lgh_number,  
		leg.ord_hdrnumber,
		(select abbr from labelfile where leg.lgh_204status = name and labeldefinition = 'Lgh204Status') as 'Edi204Status',
		leg.lgh_204date 'Edi204Date', 
		rtrim((select ord_number from orderheader where ord_hdrnumber = leg.ord_hdrnumber))+ case when isnull(lgh_split_flag,'N') = 'N' then '' else '-' + lgh_split_flag end ord_number, 
		(select ord_priority from orderheader where ord_hdrnumber = leg.ord_hdrnumber) as OrderPriority,
		(select ord_job_remaining from orderheader where ord_hdrnumber= leg.ord_hdrnumber) as 'Multi-Job Remaining',
		(select ord_job_ordered from orderheader where ord_hdrnumber = leg.ord_hdrnumber) as 'Multi-Job Ordered',
		(select ord_fromOrder from orderheader where ord_hdrnumber = leg.ord_hdrnumber) as 'From Order',
		lgh_startdate 'Start Date', 
		lgh_enddate 'End Date', 
		leg.lgh_outstatus 'DispStatus',
		leg.lgh_instatus 'InStatus',
	    (select 'XIN') as InvoiceStatus,
		ordhead.ord_status 'OrderStatus',
		lgh_booked_revtype1 'BookedBy',
		lgh_tm_status 'TotalMailStatus',
		leg.ord_billto 'BillTo',
		lgh_order_source 'OrderBy',
		lgh_miles 'Mileage',
		cmp_id_start 'ConsigneeId',
		ccompany.cmp_name  'ConsigneeName',
		lgh_startcity 'ConsigneeCity',
		lgh_startstate 'ConsigneeState',
		ccity.cty_region1 'ConsigneeRegion1',
		ccity.cty_region2 'ConsigneeRegion2',
		ccity.cty_region3 'ConsigneeRegion3',
		ccity.cty_region4 'ConsigneeRegion4',
		endcompany.cmp_id 'FinalId',
		endcompany.cmp_name 'FinalName',
		endcompany.cty_nmstct 'FinalCity',
		endcompany.cmp_state 'FinalState',
		endcity.cty_region1 'FinalRegion1',
		endcity.cty_region2 'FinalRegion2',
		endcity.cty_region3 'FinalRegion3',
		endcity.cty_region4 'FinalRegion4',
		stops.stp_schdtearliest 'FinalEarliest', 
		stops.stp_schdtlatest 'FinalLatest', 
		stops.stp_arrivaldate 'FinalArrival', 
		stops.stp_departuredate 'FinalDeparture', 
		(select count(distinct ord_hdrnumber) from stops where stops.lgh_number = leg.lgh_number and ord_hdrnumber <> 0 ) 'OrdCnt',
		(select count(*) from stops where stops.lgh_number = leg.lgh_number and stp_type = 'PUP')   'PupCnt',
		(select count(*) from stops where stops.lgh_number = leg.lgh_number and stp_type = 'DRP')  'DrpCnt',
		'' 'TotalVol',
		lgh_tractor 'Tractor', lgh_driver1 'Driver1',lgh_driver2 'Driver2', lgh_primary_trailer 'Trailer', lgh_primary_pup 'Trailer2',
		lgh_carrier 'Carrier',
		lgh_class1 'RevType1', lgh_class2 'RevType2', lgh_class3 'RevType3', lgh_class4 'RevType4',
		lgh_type1 'LghType1',
		replace(lgh_type2,'UNK','') 'LghType2',
		lgh_updatedon 'LastUpdate', 
		lgh_updatedby 'LastUpdateBy',
		isnull(ccompany.cmp_latseconds/3600.0, ccity.cty_latitude) 'ConsigneeLatitude',
		isnull(ccompany.cmp_longseconds/3600.0, ccity.cty_longitude) 'ConsigneeLongitude',
		isnull(endcompany.cmp_latseconds/3600.0, endcity.cty_latitude) 'FinalLatitude',
		isnull(endcompany.cmp_longseconds/3600.0, endcity.cty_longitude) 'FinalLongitude',
		tractorprofile.trc_company 'Company',
		tractorprofile.trc_terminal 'Terminal',
		tractorprofile.trc_division 'Division',
		tractorprofile.trc_fleet 'Fleet',	
		manpowerprofile.mpp_TeamLeader 'TeamLeader', 
		manpowerprofile.mpp_domicile 'Domicile', 
		manpowerprofile.mpp_type1 'DrvType1',
		manpowerprofile.mpp_type2 'DrvType2',
		manpowerprofile.mpp_type3 'DrvType3',
		manpowerprofile.mpp_type4 'DrvType4',
		manpowerprofile.mpp_qualificationlist,
		tractorprofile.trc_type1 'TrcType1',
		tractorprofile.trc_type2 'TrcType2',
		tractorprofile.trc_type3 'TrcType3',
		tractorprofile.trc_type4 'TrcType4',
		tractorprofile.trc_accessorylist,
		trailerprofile.trl_status 'TrlStatus',
		trailerprofile.trl_type1 'TrlType1',
		trailerprofile.trl_type2 'TrlType2',
		trailerprofile.trl_type3 'TrlType3',
		trailerprofile.trl_type4 'TrlType4',
		trailerprofile.trl_accessorylist,
		lgh_startdate 'StartDate', 
		lgh_enddate 'EndDate',
        lgh_startcty_nmstct 'Origin', 
	    lgh_endcty_nmstct 'Destination', 
        (select dbo.fnc_TMWRN_FormatNumbers(SUM(p.pyd_amount),2) from paydetail p
         WHERE p.lgh_number = leg.lgh_number) as Pago,
         (select max(pyd_currency)  from paydetail p
         WHERE p.lgh_number = leg.lgh_number) as Moneda,
        (select case when max(pyd_status) = 'REL' then 'LIBERADO' when  max(pyd_status) = 'PND' then 'PENDIENTE' end  from paydetail p
         WHERE p.lgh_number = leg.lgh_number) as EstadoPago



	from legheader as leg  join city as ccity on lgh_startcty_nmstct = ccity.cty_nmstct
						  join company as ccompany on cmp_id_start = ccompany.cmp_id
						  join company as endcompany on endcompany.cmp_id  = cmp_id_end
						  join city as endcity on endcity.cty_code = lgh_endcity
						  join stops on stp_number = stp_number_end
						  join manpowerprofile on mpp_id = lgh_driver1
						  join tractorprofile on trc_number = lgh_tractor
						  join trailerprofile on trailerprofile.trl_id = lgh_primary_trailer
						  left outer join stops as dstop on stp_number_rstart = dstop.stp_number
						  left outer join company as dcompany on dstop.cmp_id = dcompany.cmp_id
						  join orderheader ordhead on leg.ord_hdrnumber = ordhead.ord_hdrnumber
      where year(lgh_startdate) > 2011
GO
GRANT DELETE ON  [dbo].[CarrierHubInvoicingLoadsView3] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierHubInvoicingLoadsView3] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierHubInvoicingLoadsView3] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierHubInvoicingLoadsView3] TO [public]
GO
