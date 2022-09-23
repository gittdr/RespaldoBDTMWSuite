SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_preadvice_rpt] (@begin datetime, @end datetime, @branch varchar(12), @agent varchar(8))
AS
	/*
	branch (based on agent)
	      address information from branch file
	agent from tractor or carrier
	      address from the third party profile
	truck number from legheader
	carrier id from legheader
	end date from the legheader
	order number (list of orders from legheader)
	revenue type 1
	order by
	      address from company related to order by
	shipper
	      address from company related to the shipper
	bill to
	      address from company related to the bill to
	consignee
	      address from company related to the consignee
	unload date
	freight detail first reference number
	delivery instructions
	freight weight
	loading meters
	count
	number freight details
	first stop reference number
	order header terms
	order header remarks
	COD amount
	*/
	
--	DECLARE @begin datetime, 
--	        @end datetime
--	SET @begin = '1/1/2003'
--	SET @end = '12/31/2003'

IF @branch IS NULL OR LEN(RTRIM(@branch)) = ''
   SET @branch = 'UNK'

IF @agent IS NULL OR LEN(RTRIM(@agent)) = ''
   SET @agent = 'UNKNOWN'
	
	CREATE TABLE #tmp1
	  (lgh_number int NOT NULL, 
	--   asset_type char(3) NOT NULL, 
	--   asset_id varchar(8) NOT NULL, 
	   branch varchar(12) NULL, 
	   agent varchar(8) NULL)
	
	INSERT INTO #tmp1 (lgh_number, 
	--asset_type, asset_id, 
	                   agent, branch)
	SELECT DISTINCT lgh_number, 
	--'CAR', lgh_carrier, 
	        tpr_id, tpr_branch 
	  FROM legheader, carrier, thirdpartyprofile 
	 WHERE lgh_enddate BETWEEN @begin AND @end AND 
	       lgh_carrier <> 'UNKNOWN' AND
	       lgh_carrier = car_id AND
	       (car_agent = @agent OR @agent = 'UNKNOWN') AND 
	       car_agent = tpr_id AND 
               (tpr_branch = @branch OR @branch = 'UNK')
	UNION
	SELECT lgh_number, 
	--'TRC', lgh_tractor, 
	       tpr_id, tpr_branch 
	  FROM legheader, tractorprofile, thirdpartyprofile 
	 WHERE lgh_enddate BETWEEN @begin AND @end AND 
	       lgh_tractor <> 'UNKNOWN' AND 
	       lgh_tractor = trc_number AND 
	       (trc_thirdparty = @agent OR @agent = 'UNKNOWN') AND 
	       trc_thirdparty = tpr_id AND 
               (tpr_branch = @branch OR @branch = 'UNK')
	
	SELECT freightdetail.fgt_number,
	       ISNULL(freightdetail.cmd_code, 'UNKNOWN') fgt_cmd_code, 
	       ISNULL(freightdetail.fgt_weight, 0) fgt_weight, 
	       ISNULL(freightdetail.fgt_weightunit, 'LBS') fgt_weightunit, 
	       ISNULL(freightdetail.fgt_count, 0) fgt_count, 
	       ISNULL(freightdetail.fgt_countunit, 'PCS') fgt_countunit, 
	       ISNULL(freightdetail.fgt_volume, 0) fgt_volume, 
	       ISNULL(freightdetail.fgt_volumeunit, 'CUB') fgt_volumeunit, 
	       ISNULL(freightdetail.fgt_loadingmeters,   0) fgt_loadingmeters,
	       ISNULL(freightdetail.fgt_loadingmetersunit,   'LDM') fgt_loadingmetersunit,
	       ISNULL(freightdetail.fgt_description, '') fgt_description,
	       ISNULL(freightdetail.fgt_additionl_description, '') fgt_additionl_description,
	       CASE WHEN orderby.cmp_name = 'UNKNOWN' THEN '' ELSE orderby.cmp_name END orderbyname, 
	       orderby.cmp_address1 orderbyaddress1, 
	       orderby.cmp_address2 orderbyaddress2, 
	       orderby.cty_nmstct orderbycity, 
	       orderby.cmp_zip orderbyzip, 
               (SELECT ISNULL(name, '') 
                  FROM country 
                 WHERE code = orderby.cmp_country) orderbycountry, 
	       CASE WHEN shipper.cmp_name = 'UNKNOWN' THEN '' ELSE shipper.cmp_name END shippername, 
	       shipper.cmp_address1 shipperaddress1, 
	       shipper.cmp_address2 shipperaddress2, 
	       shipper.cty_nmstct shippercity, 
	       shipper.cmp_zip shipperzip, 
               (SELECT ISNULL(name, '') 
                  FROM country 
                 WHERE code = shipper.cmp_country) shippercountry, 
	       CASE WHEN consignee.cmp_name = 'UNKNOWN' THEN '' ELSE consignee.cmp_name END consigneename, 
	       consignee.cmp_address1 consigneeaddress1, 
	       consignee.cmp_address2 consigneeaddress2, 
	       consignee.cty_nmstct consigneecity, 
	       consignee.cmp_zip consigneezip, 
               (SELECT ISNULL(name, '') 
                  FROM country 
                 WHERE code = consignee.cmp_country) consigneecountry, 
	       CASE WHEN billto.cmp_name = 'UNKNOWN' THEN '' ELSE billto.cmp_name END billtoname, 
	       billto.cmp_address1 billtoaddress1, 
	       billto.cmp_address2 billtoaddress2, 
	       billto.cty_nmstct billtocity, 
	       billto.cmp_zip billtozip, 
               (SELECT ISNULL(name, '') 
                  FROM country 
                 WHERE code = billto.cmp_country) billtocountry, 
               ord_booked_revtype1, 
	       ord_number,
	       ord_remark, 
	       (SELECT CASE WHEN name = 'UNKNOWN' THEN '' ELSE name END 
                  FROM labelfile 
                 WHERE labeldefinition = 'CreditTerms' AND abbr = ord_terms) ord_terms, 
	       stp_comment, 
	       stp_cod_amount, 
	       (SELECT CASE WHEN name = 'UNKNOWN' THEN '' ELSE name END 
                  FROM labelfile 
                 WHERE labeldefinition = 'Currencies' AND abbr = stp_cod_currency) stp_cod_currency, 
	       stops.stp_number, 
               stops.stp_mfh_sequence, 
               stops.stp_arrivaldate, 
	       referencenumber.ref_number, 
	       stops.stp_refnum drop_reference, 
	       ISNULL((SELECT stp_refnum 
	                 FROM stops 
	                WHERE ord_hdrnumber = orderheader.ord_hdrnumber AND 
	                      stp_type = 'PUP' AND 
	                      mfh_number = (SELECT MIN(mfh_number) 
	                                      FROM stops 
	                                     WHERE ord_hdrnumber = orderheader.ord_hdrnumber AND 
	                                           stp_type = 'PUP')), '') pickup_reference, 
	       #tmp1.agent, 
	       CASE WHEN thirdpartyprofile.tpr_name = 'UNKNOWN' THEN '' ELSE thirdpartyprofile.tpr_name END agentname, 
	       thirdpartyprofile.tpr_address1 agentaddress1, 
	       thirdpartyprofile.tpr_address2 agentaddress2, 
	       thirdpartyprofile.tpr_cty_nmstct agentcity, 
	       thirdpartyprofile.tpr_zip agentzip, 
               (SELECT ISNULL(name, '') 
                  FROM country 
                 WHERE code = thirdpartyprofile.tpr_country) agentcountry, 
	       #tmp1.branch, 
	       CASE WHEN branch.brn_name = 'UNKNOWN' THEN '' ELSE branch.brn_name END branchname, 
	       branch.brn_add1 branchaddress1, 
	       branch.brn_add2 branchaddress2, 
	       branch.brn_city branchcity, 
	       branch.brn_zip branchzip, 
               (SELECT ISNULL(name, '') 
                  FROM country 
                 WHERE code = branch.brn_country_c) branchcountry, 
	       evt_tractor tractor, 
	       evt_carrier carrier 
	  INTO #report 
	  FROM #tmp1, 
	       freightdetail,   
	       orderheader,   
	       stops,
	       company orderby,
	       company shipper,   
	       company consignee,   
	       company billto,
	       referencenumber, 
	       branch, 
	       thirdpartyprofile, 
	       event 
	 WHERE #tmp1.lgh_number = stops.lgh_number AND 
	       orderheader.ord_hdrnumber = stops.ord_hdrnumber AND 
	       stops.stp_number = freightdetail.stp_number AND 
	       stops.stp_number = event.stp_number AND 
	       event.evt_sequence = 1 AND 
	       orderby.cmp_id = orderheader.ord_company AND 
	       shipper.cmp_id = orderheader.ord_shipper AND 
	       consignee.cmp_id = orderheader.ord_consignee AND 
	       orderheader.ord_billto = billto.cmp_id AND 
	       (stops.stp_type = 'DRP' Or stops.stp_type = 'PUP') AND 
	       freightdetail.fgt_number *= referencenumber.ref_tablekey AND 
	       referencenumber.ref_type = 'CMR' AND 
	       referencenumber.ref_table = 'freightdetail' AND 
	       #tmp1.agent = thirdpartyprofile.tpr_id AND 
	       #tmp1.branch = branch.brn_id 
	
	select * from #report

	drop table #tmp1
	
	drop table #report
GO
GRANT EXECUTE ON  [dbo].[d_preadvice_rpt] TO [public]
GO
