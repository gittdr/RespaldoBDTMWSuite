SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE  View [dbo].[VTTSTMW_ServiceException]


as

Select 
	   [Consignee] = (select cmp_name from orderheader WITH (NOLOCK),company WITH (NOLOCK) where company.cmp_id = ord_consignee and serviceexception.sxn_ord_hdrnumber =  orderheader.ord_hdrnumber),
           [Shipper] = (select cmp_name from orderheader WITH (NOLOCK),company WITH (NOLOCK) where company.cmp_id = ord_shipper and serviceexception.sxn_ord_hdrnumber =  orderheader.ord_hdrnumber),
	   [Shipper ID] = (select ord_shipper from orderheader WITH (NOLOCK) where serviceexception.sxn_ord_hdrnumber =  orderheader.ord_hdrnumber),
           [Order Number] = (select ord_number from orderheader WITH (NOLOCK) where serviceexception.sxn_ord_hdrnumber =  orderheader.ord_hdrnumber),
 	   (select top 1 labelfile.name from labelfile WITH (NOLOCK) where labelfile.abbr =  sxn_expcode) as [Service Exception Code],
	   sxn_description as [Service Exception Description],
	   sxn_expdate  as [Service Exception Date],
	   [Origin Point] = (select ord_originpoint from orderheader WITH (NOLOCK) where serviceexception.sxn_ord_hdrnumber =  orderheader.ord_hdrnumber),
           [destination Point] = (select ord_destpoint from orderheader WITH (NOLOCK) where serviceexception.sxn_ord_hdrnumber =  orderheader.ord_hdrnumber),
	   [Origin region1] = (select ord_originregion1 from orderheader WITH (NOLOCK) where serviceexception.sxn_ord_hdrnumber =  orderheader.ord_hdrnumber),
           [Destination Region1] = (select ord_destregion1 from orderheader WITH (NOLOCK) where serviceexception.sxn_ord_hdrnumber =  orderheader.ord_hdrnumber),
	   [Resource ID] = sxn_asgn_id,
	   [Resource Type] = sxn_asgn_type

from serviceexception WITH (NOLOCK)






GO
GRANT SELECT ON  [dbo].[VTTSTMW_ServiceException] TO [public]
GO
