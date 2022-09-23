SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[WebProductsCarrierCheckCallMapDetailsView_WithIcon] as
SELECT chkcl.ckc_number 'checkcallnumber', chkcl.ckc_lghnumber 'legnumber', ccompany.cmp_name 'endcompany', scompany.cmp_name 'startcompany', scity.cty_name 'city', scity.cty_state 'state', ord.ord_hdrnumber 'ordernumber', dropeta.stp_number 'stopnumber', dropeta.ste_miles_out 'milesout', ord.ord_carrier 'carrier', chkcl.ckc_status 'status', ckc_latseconds 'latitude', ckc_longseconds 'longitude',  cccity.cty_latitude 'lat1', cccity.cty_longitude * -1 'long1', 
	chkcl.ckc_date 'date', dbo.TractorColorAndDirection(lgh.lgh_number,dropeta.stp_number,ord.ord_billto, NextDrop.stp_arrivaldate, NextDrop.stp_schdtearliest, NextDrop.stp_schdtlatest, DATEADD(ss, dropeta.ste_seconds_out,dropeta.ste_updated)) as 'Icon1'

FROM checkcall chkcl 
join legheader_active lgh on chkcl.ckc_lghnumber = lgh.lgh_number 
left outer join orderheader ord WITH (nolock) on ord.mov_number = lgh.mov_number 
left outer join city scity WITH (nolock)  on lgh.lgh_startcity = scity.cty_code  
left outer join city cccity WITH (nolock)  on chkcl.ckc_city = cccity.cty_code  
left outer join  company  ccompany WITH (nolock) on lgh.cmp_id_end = ccompany.cmp_id   
left outer join  company  scompany WITH (nolock) on lgh.cmp_id_start = scompany.cmp_id  
LEFT OUTER JOIN stops NextDrop WITH (NOLOCK) ON lgh.next_drp_stp_number = NextDrop.stp_number
left outer join Stops_eta dropeta with (nolock) on dropeta.stp_number = lgh.next_drp_stp_number, 
(SELECT ord.ord_hdrnumber 'ordernumber', MAX(chkcl.ckc_date) 'latest' FROM checkcall chkcl join legheader_active lgh on chkcl.ckc_lghnumber = lgh.lgh_number left outer join orderheader ord WITH (nolock) on ord.mov_number = lgh.mov_number GROUP BY ord.ord_hdrnumber ) maxdate 
WHERE ( maxdate.latest = chkcl.ckc_date AND maxdate.ordernumber = ord.ord_hdrnumber ) AND ((ckc_latseconds IS NOT NULL AND ckc_longseconds IS NOT NULL) OR ISNULL(scity.cty_name,'') !=''  )

GO
GRANT SELECT ON  [dbo].[WebProductsCarrierCheckCallMapDetailsView_WithIcon] TO [public]
GO
