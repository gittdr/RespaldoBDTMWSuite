SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
                                      
CREATE PROC [dbo].[d_cmr_report_format01_sp] (@ord_hdrnumber int, @userid varchar (256)) 
AS
/**
 * 
 * REVISION HISTORY:
 * 10/24/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE
@stopcod	decimal (8,2),
@language       varchar (30),
@min 		int,
@text		varchar (256),
@ret		int,
@stop		int,
@freight	int,
@hazfreight    	int


SELECT 
freightdetail.fgt_number,
ISNULL (freightdetail.cmd_code,   'UNKNOWN') fgt_cmd_code,
ISNULL (freightdetail.fgt_weight,   0) fgt_weight,
ISNULL (freightdetail.fgt_weightunit, 'LBS'  ) fgt_weightunit,
ISNULL (freightdetail.fgt_count,   0) fgt_count,
ISNULL (freightdetail.fgt_countunit,   'PCS') fgt_countunit,
ISNULL (freightdetail.fgt_volume, 0) fgt_volume,  
ISNULL (freightdetail.fgt_volumeunit,   'CUB') fgt_volumeunit,
ISNULL (freightdetail.fgt_loadingmeters,   0) fgt_loadingmeters,
ISNULL (freightdetail.fgt_loadingmetersunit,   'LDM') fgt_loadingmetersunit,
ISNULL (freightdetail.fgt_description, '') fgt_description,
isnull (freightdetail.fgt_additionl_description, '') fgt_additionl_description,

ISNULL (commodity.cmd_code,   'UNKNOWN') cmd_code,
ISNULL (commodity.cmd_name,  'UNKNOWN') cmd_name,

isnull (commodity.cmd_hazardous, 0) cmd_hazardous,
commodity.cmd_imdg_class, 
commodity.cmd_imdg_subclass,
commodity.cmd_haz_num,
commodity.cmd_haz_class, 
commodity.cmd_haz_subclass,
commodity.cmd_adr_packaging_group,

ISNULL (commodity_language.language,	'') language,
ISNULL (commodity_language.description, '') description,

orderby.cmp_name orderbyname,   
orderby.cmp_address1 orderbyaddress1,   
orderby.cmp_address2 orderbyaddress2,
isnull (orderby.cmp_primaryphone, '')  orderby_primaryphone,   
isnull (orderby.cmp_faxphone, '')   orderby_faxphone,
orderby.cty_nmstct orderbycity,   
orderby.cmp_zip orderbyzip,  
orderby.cmp_country orderbycountry,  
ISNULL (shipper.cmp_taxid,   '') orderbytaxid,
ISNULL (shipper.doc_language ,    '')orderbylanguage, 		

shipper.cmp_name shippername,   
shipper.cmp_address1 shipperaddress1,   
shipper.cmp_address2 shipperaddress2, 
isnull (shipper.cmp_primaryphone, '')  shipper_primaryphone,   
isnull (shipper.cmp_faxphone, '')   shipper_faxphone,  
shipper.cty_nmstct shippercity,   
shipper.cmp_zip shipperzip,  
shipper.cmp_country shippercountry,  
ISNULL (shipper.cmp_taxid,   '') shippertaxid,
ISNULL (shipper.doc_language ,    '')shipperlanguage,  

consignee.cmp_name  consigneename,   
consignee.cmp_address1  consigneeaddress1,   
consignee.cmp_address2  consigneeaddress2,   
isnull (consignee.cmp_primaryphone, '')  consignee_primaryphone,   
isnull (consignee.cmp_faxphone, '')   consignee_faxphone,  
consignee.cty_nmstct  consigneecity,   
consignee.cmp_zip  consigneezip,   
consignee.cmp_country  consigneecountry, 
ISNULL (consignee.doc_language  ,   '') consingneedoclanguage,
ISNULL (consignee.cmp_taxid ,   '')consigneetaxid, 

billto.cmp_name billtoname,   
billto.cmp_address1 billtoaddress1,   
billto.cmp_address2 billtoaddress2,
isnull (billto.cmp_primaryphone, '')  billto_primaryphone,   
isnull (billto.cmp_faxphone, '')  billto_faxphone,     
billto.cty_nmstct billtocity,   
billto.cmp_zip billtozip,   
ISNULL (billto.cmp_taxid,  '')  billtotaxid,
ISNULL (billto.doc_language ,     '') billtodoclanguage,
ISNULL (billto.cmp_country ,  '') billtocountry,
ISNULL (language.doc_language ,  '') doc_language,
ISNULL (commodity_language.description , '') stoplanguage,
ISNULL ((SELECT DOC_LANGUAGE 
	   FROM COUNTRY 
          WHERE def_country = 1), 'English') DEFAULT_LANGUAGE,
ISNULL(( select description
           from commodity_language
          where freightdetail.cmd_code = commodity_language.cmd_code and
		commodity_language.language = ISNULL ((SELECT DOC_LANGUAGE 
		 					 FROM COUNTRY 
               						WHERE def_country = 1), 'English')), '') CountryLanguage,

isnull (branch.brn_niwoid, '') brn_niwodid,
isnull (branch.brn_name, '') brn_name,
isnull (branch.brn_add1, '') brn_add1,
isnull (branch.brn_add2, '') brn_add2,
isnull (branch.brn_city, '') brn_city,
isnull (branch.brn_state_c, '') brn_state,
isnull (branch.brn_zip, '') brn_zip,
isnull (branch.brn_country_c, '') brn_country,

ord_origin_earliestdate,
ord_origin_latestdate,
ord_dest_earliestdate,
ord_dest_latestdate,
ord_number,
orderheader.ord_hdrnumber, 
ord_bookedby,
usr_contact_number,
ord_remark,
ord_terms,

stp_comment,
stp_cod_amount,
convert (varchar (256), '') CODTEXT,  
stp_cod_currency,
stops.stp_number,

REFERENCENUMBER.ref_number,
stops.stp_refnum drop_reference,
isnull ((select stp_refnum 
	  from stops
	 where ord_hdrnumber = @ord_hdrnumber and
               stp_type = 'PUP' and
               mfh_number = (select min (mfh_number)
                                   from stops
	 		           where ord_hdrnumber = @ord_hdrnumber and
                                    stp_type = 'PUP')), '') pickup_reference,
convert (varchar (20), '') USERID

    INTO #cmr	 
FROM  freightdetail  LEFT OUTER JOIN  commodity_language  ON  FREIGHTDETAIL.CMD_CODE  = COMMODITY_LANGUAGE.CMD_CODE   
					RIGHT OUTER JOIN  company language  ON  LANGUAGE.DOC_LANGUAGE  = COMMODITY_LANGUAGE.LANGUAGE   
					LEFT OUTER JOIN  REFERENCENUMBER  ON  ( FREIGHTDETAIL.fgt_number  = REFERENCENUMBER.ref_tablekey AND REFERENCENUMBER.ref_type  = 'CMR'
															AND	REFERENCENUMBER.ref_table  = 'freightdetail'),
	 commodity,
	 orderheader,
	 stops,
	 company orderby,
	 company shipper,
	 company consignee,
	 company billto,
	 branch,
	 ttsusers 
WHERE	 (orderheader.ord_hdrnumber  = stops.ord_hdrnumber)
 AND	(stops.stp_number  = freightdetail.stp_number)
 AND	(freightdetail.cmd_code  = commodity.cmd_code)
 AND	(orderby.cmp_id  = orderheader.ord_company)
 AND	(shipper.cmp_id  = orderheader.ord_shipper)
 AND	(consignee.cmp_id  = orderheader.ord_consignee)
 AND	(orderheader.ord_billto  = billto.cmp_id)
 AND	(STOPS.CMP_ID  = LANGUAGE.CMP_ID)
 AND	(orderheader.ord_hdrnumber  = @ord_hdrnumber)
 AND	(orderheader.ord_booked_revtype1  = branch.brn_id)
 AND	(stops.stp_type  = 'DRP')
 AND	(ord_bookedby  = usr_userid)

select @min = min (fgt_number) 
	      from #cmr
	     where stp_cod_amount > 0
	      	
while @min > 0 
begin 	 

          SELECT  @stopcod = stp_cod_amount, @language = DEFAULT_LANGUAGE
                 FROM  #cmr
		where fgt_number = @min


          SET @TEXT  = ''
          exec @ret = translate_numbers_to_words_sp @stopcod , @language,  @text output
          SELECT @TEXT  = @TEXT + ' ' + convert(varchar(2), @ret) + '/100'

           update #cmr 
              set CODTEXT = @text 
            where fgt_number = @min

            select @min = min (fgt_number) 
	      from #cmr
             where fgt_number > @min and
                   stp_cod_amount > 0
	    
 	update #cmr 
	   set USERID = @userid       
end 

select @stop = min (stp_number)  
              from #cmr
	     where ord_hdrnumber = @ord_hdrnumber 
                   
while @stop > 0
begin
	select @freight = count (fgt_number)
	                 from #cmr
			where stp_number = @stop
	
	select @hazfreight = count (fgt_number)
			      from #cmr
			     where stp_number = @stop

	if ISNULL(@freight, 0) + ISNULL((@hazfreight * 3), 0) > 12
	begin 
	
		insert
		into  Packinglist
		select * from #cmr 
		where @stop = stp_number
		

		delete 
		from #cmr
		where @stop = stp_number
		
		insert 
		into #cmr
		select distinct
		1,
		'',
		sum (fgt_weight),
		fgt_weightunit,
		sum (fgt_count),
		fgt_countunit,
		sum (fgt_volume),  
		fgt_volumeunit,
		sum (fgt_loadingmeters),
		fgt_loadingmetersunit,
		'**   ZIE PAKLIJST   **',
		'' ,
		'',
		'**   ZIE PAKLIJST   **',
		'',
		'', 
		'',
		'',
		null, 
		'',
		null,
		'',
		'',
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
		'',
		DEFAULT_LANGUAGE,
		'',
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
		USERID
		
		
		from 
		packinglist
		where stp_number = @stop
		group by
		fgt_weightunit, fgt_countunit, fgt_volumeunit, fgt_loadingmetersunit, orderbyname, orderbyaddress1,   
		orderbyaddress2, orderby_primaryphone, orderby_faxphone, orderbycity, orderbyzip, orderbycountry, 
		orderbytaxid, orderbylanguage, shippername, shipperaddress1, shipperaddress2, shipper_primaryphone, 
		shipper_faxphone, shippercity, shipperzip, shippercountry, shippertaxid, shipperlanguage, 
		consigneename, consigneeaddress1, consigneeaddress2, consignee_primaryphone, consignee_faxphone,   
		consigneecity, consigneezip, consigneecountry, consingneedoclanguage, consigneetaxid, 
		billtoname, billtoaddress1, billtoaddress2, billto_primaryphone, billto_faxphone, billtocity, 
		billtozip, billtotaxid, billtodoclanguage, billtocountry, doc_language, DEFAULT_LANGUAGE, 
		brn_niwodid, brn_name, brn_add1, brn_add2, brn_city, brn_state, brn_zip, brn_country, 
		ord_origin_earliestdate, ord_origin_latestdate, ord_dest_earliestdate,
		ord_dest_latestdate, ord_number, ord_hdrnumber, ord_bookedby, usr_contact_number, ord_remark,
		ord_terms, stp_comment, stp_cod_amount, CODTEXT, stp_cod_currency, stp_number, ref_number,
		drop_reference, pickup_reference, USERID
	
	end

select @stop = min (stp_number)  
              from #cmr
	     where ord_hdrnumber = @ord_hdrnumber and
                   stp_number > @stop
end 

SELECT 

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

FROM #cmr

GO
GRANT EXECUTE ON  [dbo].[d_cmr_report_format01_sp] TO [public]
GO
