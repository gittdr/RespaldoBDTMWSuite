SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[dx_add_basic_orderheader]  @mov_number int, @ord_hdrnumber int, 
	@ord_company varchar(8), @ord_number char(12),  		
	@ord_bookedby char(20), @ord_billto varchar(8),
	@ord_revtype1 varchar(6), @ord_revtype2 varchar(6), 	
	@ord_revtype3 varchar(6), @ord_revtype4 varchar(6),
	@ord_totalmiles int,@ord_reftype varchar(6), @ord_refnum varchar(30), 
	@ord_remark varchar(254), 
	@ord_quantity float, @ord_unit varchar(6), @ord_rate money, @ord_charge money, @ord_status varchar(6) = 'AVL',
	@invoice_status varchar(6) = 'PND'
as	

DECLARE @ord_originpoint varchar(8), @ord_destpoint varchar(8), 
	@ord_origincity int, @ord_destcity int, @ord_originstate char(2),
	@ord_deststate  char(2), @ord_originregion1 varchar(6), 
	@ord_destregion1  varchar(6),
	@ord_startdate datetime, @ord_completiondate datetime,
	@ord_originregion2 varchar(6), @ord_originregion3 varchar(6), 	
	@ord_originregion4 varchar(6), @ord_destregion2 varchar(6), 
	@ord_destregion3 varchar(6), @ord_destregion4 varchar(6),
	@Pup_stp int, @drp_stp int,  @cmd_name varchar(60),
	@cmd_code varchar(8), @ord_origin_earliestdate datetime,
	@ord_origin_latestdate datetime, @ord_stopcount int,
	@ord_dest_earliestdate datetime, @ord_dest_latestdate datetime,
	@ord_totalweight int,@ord_weightunit varchar(6),
	@ord_totalvolume int,@ord_volumeunit varchar(6),
	@ord_totalcount int,@ord_countunit varchar(6),@retcode int

  /* get total from summing drop stops */

  SELECT @ord_totalweight = SUM(ISNULL(stp_weight,0)),
         @ord_totalvolume = SUM(ISNULL(stp_volume,0)),
	@ord_totalcount = SUM(ISNULL(stp_count,0))
  FROM stops
  WHERE ord_hdrnumber = @ord_hdrnumber
  AND  stp_type = 'DRP'

  /* get units from first drop */
  SELECT @drp_stp=min(stp_sequence) 
  FROM stops
  WHERE ord_hdrnumber = @ord_hdrnumber and
	stp_type='DRP'

  SELECT @ord_weightunit = stp_weightunit,
	@ord_volumeunit = stp_volumeunit,
	@ord_countunit = stp_countunit
  FROM stops
  WHERE ord_hdrnumber = @ord_hdrnumber
  AND stp_sequence = @drp_stp

 /* get the stp_number for the first PUP and last DRP */
 SELECT @pup_stp = MIN(stp_number)
 FROM stops 
 WHERE ord_hdrnumber = @ord_hdrnumber
 AND stp_sequence = (SELECT MIN(s2.stp_sequence) 
			FROM stops s2
			WHERE s2.ord_hdrnumber= @ord_hdrnumber 
			and stp_type='PUP')


 SELECT @drp_stp = MAX(stp_number)
 FROM stops 
 WHERE ord_hdrnumber = @ord_hdrnumber
 AND stp_sequence = (SELECT MAX(s2.stp_sequence) 
			FROM stops s2
			WHERE s2.ord_hdrnumber= @ord_hdrnumber 
			and stp_type='DRP')

SELECT @ord_originpoint=origin.cmp_id, @ord_destpoint = dest.cmp_id, 
	@ord_origincity = origin.stp_city, @ord_destcity = dest.stp_city, 
	@ord_originstate = oc.cty_state, @ord_deststate = dc.cty_state, 
	@ord_originregion1 = oc.cty_region1, @ord_destregion1 = dc.cty_region1,
	@ord_startdate = origin.stp_arrivaldate, @ord_completiondate = dest.stp_departuredate,
	@ord_originregion2 = oc.cty_region2, @ord_originregion3 = oc.cty_region3, 	
	@ord_originregion4 = oc.cty_region4, @ord_destregion2  = dc.cty_region2, 
	@ord_destregion3 = dc.cty_region3, @ord_destregion4 = dc.cty_region4,
	@cmd_code = origin.cmd_code, @cmd_name=origin.stp_description,
	@ord_origin_earliestdate = origin.stp_schdtearliest,
	@ord_origin_latestdate = origin.stp_schdtlatest, 
	@ord_dest_earliestdate = dest.stp_schdtearliest,
	@ord_dest_latestdate = dest.stp_schdtlatest
from stops origin, stops dest, city oc, city dc
where origin.stp_number=@pup_stp and
	dest.stp_number=@drp_stp and
	origin.stp_city = oc.cty_code and
	dest.stp_city = dc.cty_code


SELECT @ord_stopcount =count(*) from stops
WHERE ord_hdrnumber = @ord_hdrnumber

INSERT INTO orderheader 
	( ord_company, ord_number, ord_customer, 		--1
	ord_bookdate, ord_bookedby, ord_status, 		--2
	ord_originpoint, ord_destpoint, ord_invoicestatus, 	--3	
	ord_origincity, ord_destcity, ord_originstate, 		--4
	ord_deststate, ord_originregion1, ord_destregion1, 	--5
	ord_supplier, ord_billto, ord_startdate, 		--6
	ord_completiondate, ord_revtype1, ord_revtype2, 	--7
	ord_revtype3, ord_revtype4, ord_totalweight, ord_totalvolume,	--8
	ord_totalpieces, ord_totalmiles, ord_odmetermiles,ord_totalcharge, --9
	ord_currency, ord_currencydate,  	--10
	ord_hdrnumber, ord_remark, ord_shipper, 		--11
	ord_consignee, ord_originregion2, ord_originregion3, 	--12
	ord_originregion4, ord_destregion2, ord_destregion3,	--13 
	ord_destregion4, ord_priority, mov_number, 		--14
	ord_showshipper, ord_showcons, ord_subcompany, 		--15
	ord_lowtemp, ord_hitemp, ord_quantity,	                --16
	ord_rate, ord_charge, ord_rateunit, 			--17
	ord_unit, trl_type1, ord_driver1, 			--18
	ord_driver2, ord_tractor, ord_trailer, 			--19
	ord_length, ord_width, ord_height, 			--20	
	ord_reftype, ord_refnum, cmd_code, ord_description, 		--21
	ord_terms, cht_itemcode, ord_origin_earliestdate, 	--22
	ord_origin_latestdate, ord_stopcount, --23
	ord_dest_earliestdate, ord_dest_latestdate, ord_cmdvalue, --24
	ord_accessorial_chrg, ord_availabledate, ord_miscqty, 	--25
	ord_datetaken, ord_totalweightunits, ord_totalvolumeunits,--26 
	ord_totalcountunits, ord_loadtime, ord_unloadtime, 	--27
	ord_drivetime, ord_rateby, ord_thirdpartytype1, 	--28
	ord_thirdpartytype2, ord_quantity_type, ord_charge_type, ord_cod_amount )--29 
VALUES ( @ord_company, @ord_number, 'UNKNOWN', 	        	--1
	GETDATE(), @ord_bookedby, @ord_status, 		        --2
	@ord_originpoint, @ord_destpoint, @invoice_status,		--3
	@ord_origincity, @ord_destcity, @ord_originstate, 	--4
	@ord_deststate, @ord_originregion1, @ord_destregion1, 	--5
	'UNKNOWN', @ord_billto, @ord_startdate, 		--6
	@ord_completiondate, @ord_revtype1, @ord_revtype2, 	--7
	@ord_revtype3, @ord_revtype4, @ord_totalweight,@ord_totalvolume, --8
	@ord_totalcount, @ord_totalmiles,  @ord_totalmiles,@ord_charge,	--9
	'US$', getdate(), 					--10 
	@ord_hdrnumber, @ord_remark,@ord_originpoint,			--11	
	@ord_destpoint, @ord_originregion2, @ord_originregion3, 	--12
	@ord_originregion4, @ord_destregion2, @ord_destregion3,	--13 
	@ord_destregion4, 'UNK', @mov_number, 		        --14
	'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 			--15
	0, 0, @ord_quantity,     				--16
	@ord_rate, @ord_charge, 'FLT', 				--17
	@ord_unit, 'UNK', 'UNKNOWN', 				--18
	'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 			--19
	0.0000, 0.0000, 0.0000, 				--20
	@ord_reftype, @ord_refnum, @cmd_code, @cmd_name, 				--21
	'UNK', 'LHF', @ord_origin_earliestdate, 		--22
	@ord_origin_latestdate, @ord_stopcount, 		--23
	@ord_dest_earliestdate, @ord_dest_latestdate, 0.0,      --24	
	0.0000, getdate(), 0.0000, 				--25
	getdate(), @ord_weightunit, @ord_volumeunit, 				--26
	@ord_countunit, 0, 0, 						--27
	0, 'T', 'UNKNOWN', 			        	--28
	NULL, 0, 0, 0 )			--29

SELECT @retcode = @@error
  IF @retcode<>0
     BEGIN
	EXEC dx_log_error 888, 'INSERT INTO Orderheader Failed', @retcode, @ord_number
	return -1
     END


--insert tar refnumber
INSERT INTO referencenumber
      ( ref_tablekey,
	ref_type,
	ref_number,
	ref_sequence,
	ref_table,
	ref_sid,
	ref_pickup)
Values  (@ord_hdrnumber,
	@ord_reftype,
	@ord_refnum,
	1,
	'orderheader',
	'Y',
	Null)

GO
GRANT EXECUTE ON  [dbo].[dx_add_basic_orderheader] TO [public]
GO
