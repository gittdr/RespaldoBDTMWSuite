SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[CarrierHubHistoricalLoadsViewFuel]
as
select 'TMWWF_CarrierHub_HISTORICAL' AS 'TMWWF_CarrierHub_HISTORICAL',
	leg.lgh_number,  --This is required by the business objects.
	leg.ord_hdrnumber, --This is required by the business objects.
	(select abbr from labelfile where leg.lgh_204status = name and labeldefinition = 'Lgh204Status') as 'Edi204Status',
	convert(varchar, leg.lgh_204date, 110) + '/n' + convert(varchar, leg.lgh_204date, 108) 'Edi204Date', 
	rtrim((select ord_number from orderheader where ord_hdrnumber = leg.ord_hdrnumber))+ case when isnull(lgh_split_flag,'N') = 'N' then '' else '-' + lgh_split_flag end ord_number, 
	convert(varchar, lgh_startdate, 110) + '/n' + convert(varchar, lgh_startdate, 108) 'Start Date', 
	convert(varchar, lgh_enddate, 110) + '/n' + convert(varchar, lgh_enddate, 108) 'End Date', 
    leg.lgh_type1 'LghType1',
    leg.lgh_type2 'LghType2',
	leg.lgh_outstatus 'DispStatus', --This is required by the business objects.
	lgh_miles 'Mileage',
	startcompany.cmp_id 'PickupId',
	startcompany.cmp_name  'PickupName',
	startcity.cty_name 'PickupCity',
	lgh_startstate 'PickupState',
	convert(varchar, LegStartStop.stp_arrivaldate, 110) + '/n' + convert(varchar, LegStartStop.stp_arrivaldate, 108) 'PickupArrival',
	convert(varchar, LegStartStop.stp_departuredate, 110) + '/n' +  convert(varchar, LegStartStop.stp_departuredate, 108) 'PickupDeparture', 
	endcompany.cmp_id 'ConsigneeId',
	endcompany.cmp_name 'ConsigneeName',
	endcity.cty_name 'ConsigneeCity',
	endcompany.cmp_state 'ConsigneeState',
	LegFinalStop.stp_schdtearliest 'Retain',
	LegFinalStop.stp_schdtlatest 'Runout',
	LegFinalStop.stp_arrivaldate 'NextDropArrival',
	LegFinalStop.stp_departuredate 'NextDropDeparture',
	(select count(distinct ord_hdrnumber) from stops (nolock) where stops.lgh_number = leg.lgh_number and ord_hdrnumber <> 0 ) 'OrdCnt',
	(select count(*) from stops (nolock) where stops.lgh_number = leg.lgh_number and stp_type = 'PUP') 'PupCnt',
    (select count(*) from stops (nolock) where stops.lgh_number = leg.lgh_number and stp_type = 'DRP') 'DrpCnt',
	lgh_primary_trailer 'Trailer',
	leg.lgh_instatus 'InStatus', --This is required by the WS.
	lgh_carrier 'Carrier', --This is required by the business objects.
	lgh_startdate 'StartDate', 
	lgh_enddate 'EndDate',
	ord.ord_revtype1 'OrdRevType1',
	isnull(startcompany.cmp_latseconds/3600.0, startcity.cty_latitude) 'PickupLatitude',
	isnull(startcompany.cmp_longseconds/3600.0, startcity.cty_longitude) 'PickupLongitude',
	isnull(endcompany.cmp_latseconds/3600.0, endcity.cty_latitude) 'ConsigneeLatitude',
	isnull(endcompany.cmp_longseconds/3600.0, endcity.cty_longitude) 'ConsigneeLongitude',
	    det1.cmd_code 'Del Cmd1', det1.fgt_weight 'Del Wgt1', det1.fgt_count 'Del Cnt1', det1.fgt_volume 'Del Vol1',
	    det2.cmd_code 'Del Cmd2', det2.fgt_weight 'Del Wgt2', det1.fgt_count 'Del Cnt2', det2.fgt_volume 'Del Vol2',
    	det3.cmd_code 'Del Cmd3', det3.fgt_weight 'Del Wgt3', det1.fgt_count 'Del Cnt3', det3.fgt_volume 'Del Vol3',
    	det4.cmd_code 'Del Cmd4', det4.fgt_weight 'Del Wgt4', det1.fgt_count 'Del Cnt4', det4.fgt_volume 'Del Vol4'

	from legheader leg WITH(NOLOCK) join city as startcity on lgh_startcty_nmstct = startcity.cty_nmstct
                                join orderheader ord WITH(NOLOCK) on leg.ord_hdrnumber = ord.ord_hdrnumber
                                join company startcompany WITH(NOLOCK) on cmp_id_start = startcompany.cmp_id
                                join company endcompany WITH(NOLOCK) on endcompany.cmp_id  = leg.cmp_id_end
                                join city endcity WITH(NOLOCK) on endcity.cty_code = leg.lgh_endcity
                                join stops LegStartStop WITH(NOLOCK) on LegStartStop.stp_number = leg.stp_number_start
                                join stops LegFinalStop WITH(NOLOCK)on LegFinalStop.stp_number = leg.stp_number_end
                                join trailerprofile WITH(NOLOCK) on trailerprofile.trl_id = leg.lgh_primary_trailer
                                left outer join freightdetail as det1 on stp_number_end = det1.stp_number and det1.fgt_sequence = 1
                                left outer join freightdetail as det2 on stp_number_end = det2.stp_number and det2.fgt_sequence = 2
                                left outer join freightdetail as det3 on stp_number_end = det3.stp_number and det3.fgt_sequence = 3
                                left outer join freightdetail as det4 on stp_number_end = det4.stp_number and det4.fgt_sequence = 4

GO
GRANT DELETE ON  [dbo].[CarrierHubHistoricalLoadsViewFuel] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierHubHistoricalLoadsViewFuel] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierHubHistoricalLoadsViewFuel] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierHubHistoricalLoadsViewFuel] TO [public]
GO
