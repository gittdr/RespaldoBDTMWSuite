SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[WebProductsCarrierCheckCallMapDetailsView] as
SELECT chkcl.ckc_number 'checkcallnumber', chkcl.ckc_lghnumber 'legnumber', ccompany.cmp_name 'endcompany', scompany.cmp_name 'startcompany', scity.cty_name 'city', scity.cty_state 'state', ord.ord_hdrnumber 'ordernumber', dropeta.stp_number 'stopnumber', dropeta.ste_miles_out 'milesout', ord.ord_carrier 'carrier', chkcl.ckc_status 'status', ckc_latseconds 'latitude', ckc_longseconds 'longitude', chkcl.ckc_date 'date' 
FROM checkcall chkcl 
join legheader_active lgh on chkcl.ckc_lghnumber = lgh.lgh_number 
left outer join orderheader ord WITH (nolock) on ord.mov_number = lgh.mov_number 
left outer join city scity WITH (nolock)  on lgh.lgh_startcity = scity.cty_code  
left outer join  company  ccompany WITH (nolock) on lgh.cmp_id_end = ccompany.cmp_id   
left outer join  company  scompany WITH (nolock) on lgh.cmp_id_start = scompany.cmp_id  
left outer join Stops_eta dropeta with (nolock) on dropeta.stp_number = lgh.next_drp_stp_number, 
(SELECT ord.ord_hdrnumber 'ordernumber', MAX(chkcl.ckc_date) 'latest' FROM checkcall chkcl join legheader_active lgh on chkcl.ckc_lghnumber = lgh.lgh_number left outer join orderheader ord WITH (nolock) on ord.mov_number = lgh.mov_number GROUP BY ord.ord_hdrnumber ) maxdate 
WHERE ( maxdate.latest = chkcl.ckc_date AND maxdate.ordernumber = ord.ord_hdrnumber ) AND ((ckc_latseconds IS NOT NULL AND ckc_longseconds IS NOT NULL) OR ISNULL(scity.cty_name,'') !=''  )
GO
GRANT SELECT ON  [dbo].[WebProductsCarrierCheckCallMapDetailsView] TO [public]
GO
