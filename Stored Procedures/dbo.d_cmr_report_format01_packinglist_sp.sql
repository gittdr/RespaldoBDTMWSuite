SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
                                      
CREATE PROC [dbo].[d_cmr_report_format01_packinglist_sp] (@ord_hdrnumber int, @userid varchar (256)) 
AS

SELECT 
fgt_number, 
fgt_cmd_code,
fgt_weight,
fgt_weightunit,
fgt_count,
fgt_countunit,
fgt_volume,  
fgt_volumeunit,
fgt_loadingmeters,
fgt_loadingmetersunit,
fgt_description,
fgt_additionl_description,
cmd_code,
cmd_name,
cmd_hazardous,
cmd_imdg_class, 
cmd_imdg_subclass,
cmd_haz_num,
cmd_haz_class, 
cmd_haz_subclass,
cmd_adr_packaging_group,
language,
description,
orderbyname,   
orderbyaddress1,   
orderbyaddress2,
orderby_primaryphone,
orderby_faxphone,   
orderbycity,   
orderbyzip,  
orderbycountry,  
orderbytaxid,
orderbylanguage, 		
shippername,   
shipperaddress1,   
shipperaddress2, 
shipper_primaryphone,
shipper_faxphone,   
shippercity,   
shipperzip,  
shippercountry,  
shippertaxid,
shipperlanguage,  
consigneename,   
consigneeaddress1,   
consigneeaddress2,
consignee_primaryphone,
consignee_faxphone,      
consigneecity,   
consigneezip,   
consigneecountry, 
consingneedoclanguage,
consigneetaxid, 
billtoname,   
billtoaddress1,   
billtoaddress2,
billto_primaryphone,
billto_faxphone,   
billtocity,   
billtozip,   
billtotaxid,
billtodoclanguage,
billtocountry,
doc_language,
stoplanguage,
DEFAULT_LANGUAGE,
CountryLanguage,
brn_niwodid,
brn_name,
brn_add1,
brn_add2,
brn_city,
brn_state,
brn_zip,
brn_country,
ord_origin_earliestdate,
ord_origin_latestdate,
ord_dest_earliestdate,
ord_dest_latestdate,
ord_number,
ord_hdrnumber, 
ord_bookedby,
usr_contact_number,
ord_remark,
ord_terms,
stp_comment,
stp_cod_amount,
CODTEXT,  
stp_cod_currency,
stp_number,
ref_number,
drop_reference,
pickup_reference,
userid

FROM packinglist
where ord_hdrnumber = @ord_hdrnumber and 
      userid = @userid

delete 
FROM packinglist
where ord_hdrnumber = @ord_hdrnumber and 
      userid = @userid
 
GO
GRANT EXECUTE ON  [dbo].[d_cmr_report_format01_packinglist_sp] TO [public]
GO
