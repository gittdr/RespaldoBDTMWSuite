SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_ergon_billoflading](@ord_hdrnum int)
AS
/**
 * 
 * REVISION HISTORY:
 * 10/26/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

--Declare the variables needed for the accessorial cursor
declare @cht_itemcode char(6), 
        @cht_description varchar(30), 
        @rtn_value int,       
        @min_num int,
	@min_seq int,
  	@refnums_concat varchar(254),
	@refnums_remarks varchar(254),
	@ref_type varchar(6),
	@ref_number varchar(30),
	@ref_desc varchar(20)

--Create a temporary table for results of the temp table
CREATE TABLE #ergonbol (
term varchar(6) NULL,
date_loaded datetime NULL,
bill_of_lading_int int NULL,
billto_name varchar(100) NULL,
customer_no varchar(25) NULL,
from_shipper_name  varchar(100) NULL ,
at_shipper_cty_name varchar(18) NULL,
at_shipper_cty_state varchar(6) NULL,
to_consignee_name varchar(100) NULL,
at_consignee_cty_name varchar(18) NULL,
at_consignee_cty_state varchar(6) NULL,
br  money null,
trc varchar(8) null,
tri varchar(13) null,
rated_miles int null,
tank_cleaning varchar(14) null,
quantity_billed int null,
description_commodity_name varchar(60) null,
driver_id varchar(8) null,
driver_fname varchar(40) null,
driver_lname varchar(40) null,
cmd_misc1 varchar(254)null,
cmd_misc2 varchar(254)null,
cmd_misc3 varchar(254)null,
cmd_misc4 varchar(254)null,
loading_due_date varchar(50) null,
unloading_due_date varchar(50) null,
shipper_order_no varchar(30)null,
refnums_remarks varchar(254)null,
ord_remark varchar(254) null,
actual_quantity float null,
actual_units varchar(6) null,
driver_altid varchar(9) null)

--select the inital values for the BOL report
INSERT INTO  #ergonbol 
SELECT       
       --ORD.ORD_revtype1,
       Case ORD.ORD_revtype1 
            when 'UNK' THEN '' 
       	    else ORD.ORD_revtype1 
       	    end,      
       ORD.ORD_origin_earliestdate,       
       ORD.ORD_hdrnumber,
       --billto.cmp_name,
       Case billto.cmp_name 
            when 'UNKNOWN' THEN '' 
            else billto.cmp_name 
            end, 
       --billto.cmp_altid,
       Case billto.cmp_name 
            when 'UNKNOWN' THEN '' 
            else billto.cmp_altid 
            end, 
       --shipper.cmp_name shipper_name ,
       Case Shipper.cmp_name 
             when 'UNKNOWN' THEN '' 
             else shipper.cmp_name 
             end shipper_name,       
       --shipper_cty.cty_name shipper_cty_name,
       Case Shipper.cmp_name 
             when 'UNKNOWN' THEN '' 
	     else shipper_cty.cty_name
             end shipper_cty_name,
       --shipper_cty.cty_state shipper_cty_state,
       Case Shipper.cmp_name 
             when 'UNKNOWN' THEN ''
             else shipper_cty.cty_state
             end shipper_cty_state,
       --consignee.cmp_name consignee_name,
       Case consignee.cmp_name 
             when 'UNKNOWN' THEN '' 
             else consignee.cmp_name 
             end consignee_name,
       --consignee_cty.cty_name consignee_cty_name,
       Case consignee.cmp_name 
             when 'UNKNOWN' THEN '' 
	     else consignee_cty.cty_name
	     end consignee_cty_name,
       --consignee_cty.cty_state consignee_cty_state,
       Case consignee.cmp_name 
            when 'UNKNOWN' THEN '' 
       	    else consignee_cty.cty_state
            end consignee_cty_state,
       ord.ord_rate,             
       --lgh.lgh_tractor,
       Case
	     When lgh.lgh_tractor = 'UNKNOWN' Then ''	     
	     Else lgh.lgh_tractor
	     End ,
       --lgh.lgh_primary_trailer,
       Case
	     When lgh.lgh_primary_trailer = 'UNKNOWN' Then ''	     
	     Else lgh.lgh_primary_trailer
	     End ,
       --ord.ord_totalmiles,
       Case ord_totalmiles
             when -1 then 0
             else ord_totalmiles	
            end,
       '', --tank cleaning
       0 , --quantity billed if fuel surcharge invoicedetail exists
       cmd.cmd_dot_name,
       lgh.lgh_driver1,
       '', -- driver first name
       '', -- driver last name
       cmd.cmd_misc1,
       cmd.cmd_misc2,
       cmd.cmd_misc3,
       cmd.cmd_misc4,
       '',--earliest date from first pickup
       '',--earliest date from last drop
       '',--shipper order number
       '',--reference numbers to be displayed in the remarks
       isnull(ord.ord_remark,' '),
       CASE
		WHEN ord.ord_totalweight > 0 then ord.ord_totalweight
		WHEN ord.ord_totalvolume > 0 then ord.ord_totalvolume
		WHEN ord.ord_totalpieces > 0 then ord.ord_totalpieces
		ELSE 0
		END,
       CASE
		WHEN ord.ord_totalweight > 0 then ord.ord_totalweightunits
		WHEN ord.ord_totalvolume > 0 then ord.ord_totalvolumeunits
		WHEN ord.ord_totalpieces > 0 then ord.ord_totalcountunits
		ELSE ''
		END,
	''--driver alternate id
	
FROM  ORDERHEADER ORD  LEFT OUTER JOIN  company shipper  ON  ORD.ord_shipper  = shipper.cmp_id   
		LEFT OUTER JOIN  company consignee  ON  ORD.ord_consignee  = consignee.cmp_id   
		LEFT OUTER JOIN  company billto  ON  ord.ord_billto  = billto.cmp_id   
		LEFT OUTER JOIN  city consignee_cty  ON  ORD.ORD_destcity  = consignee_cty.cty_code   
		LEFT OUTER JOIN  city shipper_cty  ON  ORD.ORD_origincity  = shipper_cty.cty_code ,
	 STOPS STP,
	 commodity cmd,
	 LEGHEADER LGH 
WHERE	 ORD.ORD_HDRNUMBER  = @ord_hdrnum
 AND	STP.ORD_HDRNUMBER  = ORD.ORD_HDRNUMBER
 AND	STP.ORD_HDRNUMBER  = LGH.ORD_HDRNUMBER
 AND	STP.cmd_code  = cmd.cmd_code
 AND	STP.STP_EVENT  = 'LUL'


UPDATE #ergonbol
   SET driver_fname = mpp_firstname,
       driver_lname = mpp_lastname,
       driver_altid = mpp_otherid
  FROM manpowerprofile mpp, 
       #ergonbol bol
 WHERE bol.driver_id = mpp.mpp_id

UPDATE  #ergonbol
   SET  loading_due_date = convert(varchar(20), stp.stp_schdtearliest, 101) + ' ' + 
	Left(convert(varchar(20), stp.stp_schdtearliest, 108),5) + ' - ' +
	convert(varchar(20), stp.stp_schdtlatest, 101) + ' ' + 
	Left(convert(varchar(20), stp.stp_schdtlatest, 108),5)
  FROM  stops stp
 WHERE  stp.stp_mfh_sequence = (select min(stp_mfh_sequence)
                                  from stops
                                 where stp_type = 'PUP' and
                                      ord_hdrnumber = @ord_hdrnum) and
       stp.ord_hdrnumber = @ord_hdrnum

UPDATE #ergonbol
   SET  unloading_due_date = convert(varchar(20), stp.stp_schdtearliest, 101) + ' ' + 
	Left(convert(varchar(20), stp.stp_schdtearliest, 108),5) + ' - ' +
	convert(varchar(20), stp.stp_schdtlatest, 101) + ' ' + 
	Left(convert(varchar(20), stp.stp_schdtlatest, 108),5)
  FROM stops stp
 WHERE stp.stp_mfh_sequence = (select max(stp_mfh_sequence)
                                 from stops
                                where stp_type = 'DRP' and
                                      ord_hdrnumber = @ord_hdrnum)and
       stp.ord_hdrnumber = @ord_hdrnum


SET @min_num = 0

WHILE (SELECT COUNT(*) FROM invoicedetail WHERE ivd_number > @Min_num and ord_hdrnumber = @ord_hdrnum) > 0
	BEGIN
	  SELECT @Min_num = (SELECT MIN(ivd_number) 
                               FROM invoicedetail 
                              WHERE ivd_number > @min_num and 
                                    ord_hdrnumber = @ord_hdrnum)	 

	  SELECT @cht_itemcode = cht_itemcode
  	    from invoicedetail ivd
 	   where ivd.ivd_number = @Min_num

	  select @cht_description = cht_description
            from chargetype
           where cht_itemcode = @cht_itemcode

	  --Search the charge type description for the word FUEL
   	  select @rtn_value = charindex('FUEL',UPPER(@cht_description),1)
   
   	  --If the search has found the word FUEL and a previous search has not 
   	  --updated the table due to a successful search, then update the temp table
   	  If @rtn_value > 0 
      		Begin
       			Update #ergonbol
          		   set tank_cleaning = 'FUEL SURCHARGE',
              	               quantity_billed = 1
                        BREAK       			
      		End
	END
 
SET @min_seq = 0
SET @refnums_remarks = ''

WHILE (SELECT COUNT(*) FROM referencenumber WHERE ref_sequence > @min_seq and 
                                                  ref_tablekey = @ord_hdrnum and
                                                  ref_table = 'orderheader') > 0
	BEGIN
	  SELECT @min_seq = (SELECT MIN(ref_sequence) 
                               FROM referencenumber 
                              WHERE ref_sequence > @min_seq and 
                                    ref_tablekey = @ord_hdrnum and
                                    ref_table = 'orderheader') 

	  SELECT @ref_type   = ref_type,
          	 @ref_number = ref_number
  	    from referencenumber ref
 	   where ref.ref_sequence = @Min_seq and
		 ref.ref_tablekey = @ord_hdrnum and
                 ref.ref_table = 'orderheader'

	   SELECT @ref_desc = lab.name
	     FROM labelfile lab
            WHERE lab.abbr = @ref_type and
                  lab.labeldefinition = 'ReferenceNumbers'
   
   	   If @ref_type = 'SID' 
      		Begin
       			Update #ergonbol
          		   set shipper_order_no = @ref_number              	                      			
      		End
	   else
		Begin
			Select @refnums_concat = @ref_desc+'-'+@ref_number+' '	
			Select @refnums_remarks = @refnums_remarks + @refnums_concat			
		End
	END
	
	Update #ergonbol
	   set refnums_remarks = @refnums_remarks
 
--Select the final results
Select * from #ergonbol
GO
GRANT EXECUTE ON  [dbo].[d_ergon_billoflading] TO [public]
GO
