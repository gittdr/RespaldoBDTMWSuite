SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE view [dbo].[EstatActiveOrdersView_TDR_AVL]
as
select 
    'TMWWF_ESTAT_ACTIVE' as 'TMWWF_ESTAT_ACTIVE',  
	ord.ord_hdrnumber,
	ord.ord_number,
	leg.lgh_startdate 'StartDate', 
	leg.lgh_enddate 'EndDate', 
	leg.lgh_outstatus 'DispStatus',	
    	(select cmp_name from company where cmp_id = ord.ord_billto) 'BillTo',	
	ord.ord_billto 'BillToID',
    	(select cmp_name from company where cmp_id = ord.ord_company) 'OrderBy',
    	ord.ord_company 'OrderByID', 	
	scompany.cmp_id 'PickupID',
	scompany.cmp_name 'PickupName',
	scity.cty_name 'PickupCity',
	scity.cty_state 'PickupState',
	ccompany.cmp_id 'ConsigneeID',
	ccompany.cmp_name 'ConsigneeName',
	ccity.cty_name 'ConsigneeCity',
	ccity.cty_state 'ConsigneeState',	
	ord.ord_revtype1 'RevType1', ord.ord_revtype2 'RevType2', ord.ord_revtype3 'RevType3', ord.ord_revtype4 'RevType4',
	ord.ord_refnum as Referencia,
	cast(0.00 as float) as ETAdif,
	case when ord.ord_billto='pilgrims' then '<a href="https://69.20.92.116:8090/BitacoraPilgrims.aspx?lgh_header=' +cast (lgh_number as varchar(20))+'"  target="_blank">'+cast(lgh_number as varchar(20))+'   </a>'  else cast(lgh_number as varchar(20)) end as leg
	
from legheader as leg
        left join orderheader ord on ord.ord_hdrnumber = leg.ord_hdrnumber
		join city as scity on ord.ord_origincity = scity.cty_code
		join company as scompany on ord.ord_shipper = scompany.cmp_id
		join city as ccity on ord.ord_destcity = ccity.cty_code
		join company as ccompany on ord.ord_consignee= ccompany.cmp_id





GO
