SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_210_record_id_3_39_sp] 
	@invoice_number varchar( 12 ),
	@trpid varchar(20),
	@docid varchar(30)
 as

/*
 * 
 * NAME:
 * dbo.edi_210_record_id_3_39_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure creates 210 3 records in the edi_210 table for all invoice details on the current order
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @invoice_number, varchar(12), input, null;
 *       This parameter indicates the number of the invoice 
 *       that the three records are being created for 
 * 002 - @trp_id, varchar(20), input, null;
 *       This parameter indicates the current trading partner 
 *       the invoice is being created for. 
 * 003 - @docid, varchar(30), input, null;
 *       This parameter indicates edi document id for the current batch/document 
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * CalledBy001 ? edi_210_all_39_sp 
 * CalledBy002 ? Name of Proc / Function That Calls Me 

 * 
 * REVISION HISTORY:
 * 03/1/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 *
 * Modified to trucate overlong column values 3/3/00
 * Modified 4/24/00 added deciman count, weight volume AND billing qty
 * Modified 5/6/00 expANDing added qualifier fields to 6 chars
 *   AND using actual PS qualifiers as defaults PTS 7964
 * Modified 5/25/00 to hokey up a total wgt,vol,count on rate by total charge line
 * Modified 6/22/00 pts 8301 to append copy of rate with 5 decimals at end of record
 * pts8407 7/7/00 sequence output of #3 to match what you see on a printed invoice
 * Modified 7/13/00 PTS8473 to check for NULL or empty string on ivd_description
 * Modified 9/25/00 pts8954 add parameter @docid and use that value in the edi_210 record
 * Modified 8/20/01 to fix error in presenting negative quantities (done under pts 11689 but not related)
 * Modified 12/27/02 to fix error usercommodity for linehaul not getting pulled
 * DMEEK 12/15/04 PTS 25868 - Output Splitbilling 'Audit Data' (cbadjustment, mincharge, oradjustment, fuelsurcharge, cwt, refnumber)
 * AROSS 04/01/05 Added defaults to weight,volume and count units where the value is NULL.  PTS 27552
 * 5/03/05.01 -A. Rossman - PTS 27969 -Added isnull wrapper to ivd_refnum and case statement to cwt on 
 *									insert to temp table to correct errors when re-running proc manually.
 * 6/14/05.02 -A.Rossman -  Added logic to get chargetype from ediaccessorial table when it is populated for the billto company.
 * 9/07/05.03 -A.Rossman - PTS 28502 - Do not use cht_description for delivery lines that have an ivd_description of UNKNOWN.
 * 12/16/05.04 - A.Rossman - PTS 31003 - Corrected conversion of vc_weight value to be an integer value.  Decimal values were causing errors.
 * 03/21/06.05 - A. Rossman - PTS 31685 - Get the values for the total weight,count and volume from the invoiceheader.
 * 04/16/07.06 - A.Rossman - PTS 31331 - Allow for negative quantities in the output for credit memo 210 messages.  Prior to this change only secondary charges with negative values
 *									were being included in the output.
 * 03/12/09.07 - A. Rossman - PTS 46481 - Update EDI commodity for Rateby Total on the Linehaul and Delivery Lines
 * 10/14/09.08 - D. Wilks - PTS 49432 - 46481 does not work for invoices created from orders with MT stops at the beginning
 * 12/14/09.09 - A. Rossman - PTS 50225 - corrected 5 decimal charge for negative amounts.
 * 07.02.10.10 - A. Rossman - PTS 53076 - Use ivd_description for GST and PST
 * 09.10.10.11 - A. Rossman - PTS 53933 - Extend reference field for 30 characters by adding additional field to output for extra 10 chars.
 * PCURR 03/13/12 PTS 62014 to fix issue with NULL value in edi_accessorial_code2.
 * 07.20.12.12 - C. Thomas  - PTS 58479 - Added functionality to roll Accessorial charges to LineHaul based on GI Setting
 * 07.22.13.13 - A. Rossman - PTS 68109 - corrected rounding issue with quantity.
 * 09.10.13.14 - A. ROssman - PTS 72054 - Use city and state from company on invoicedetail instead of stop.
 */

  DECLARE @ivh_hdrnumber integer
  DECLARE @emptystring varchar(30)
  DECLARE @varchar8 varchar(8)
  DECLARE @datacol varchar(255)
  DECLARE @E210NoZero3 varchar(1)
  DECLARE @totalwgt float(15),@totalcount float(15), @totalvolume float(15)
  DECLARE @wgtunit varchar(6),@volunit varchar(6),@countunit varchar(6)
  DECLARE @nextseq int, @rateby CHAR(1)
  Declare @data    varchar(200)
  DECLARE @SplitBillMilkRun char(1)
  DECLARE @addcitystate char(1),@city varchar(18), @state varchar(2),@reftype varchar(3)
   DECLARE @cmd_code varchar(8)	--PTS46481 AR
   DECLARE @v_secondAcc VARCHAR(6)	--52647
  DECLARE @UseRollIntoLH varchar(50) --58479 
  DECLARE @rollintolhamount money --58479 
  DECLARE @ratefactor float  --58479 
  DECLARE @unit varchar(6) --58479 
  DECLARE @rateunit varchar(6) --58479 


CREATE TABLE #210_inv_temp (
	vc_weight		VARCHAR(12) NULL,	
	ivd_wgtunit		VARCHAR(6) NULL,					
	ivd_description	VARCHAR(30) NULL,
	vc_quantity		VARCHAR(12) NULL,	
	ivd_quantity	FLOAT NULL,                       
	ivd_unit		VARCHAR(6) NULL,
	vc_charge		VARCHAR(12) NULL,
	ivd_charge		MONEY NULL,
    ivd_rate		MONEY NULL,
	vc_rate			VARCHAR(12) NULL,
	vc_rate_to5dec	VARCHAR(25) NULL,
	ivd_rateunit 	VARCHAR(6) NULL,
	cur_code 		CHAR(1) NULL,
	cht_itemcode	VARCHAR(6) NULL,
	cmd_code		VARCHAR(8) NULL,					
	cht_basisunit	VARCHAR(6) NULL,
	ivh_billto		VARCHAR(8) NULL,
	ivd_type		VARCHAR(6) NULL,
	weight_qualifier	VARCHAR(30) NULL,
	quantity_qualifier	VARCHAR(30) NULL,
	charges_qualifier	VARCHAR(30) NULL,
	rate_qualifier	VARCHAR(30) NULL,
	freight_class 	VARCHAR(3) NULL,
	billedas_quantity	VARCHAR(30) NULL,
	billedas_qualifier	VARCHAR(30) NULL,
	NMFC	VARCHAR(30) NULL,
	usercommodity	VARCHAR(8) NULL,
	primarycharge	VARCHAR(30) NULL,
	vc_dec_volume 	VARCHAR(12) NULL,	
	ivd_volunit	VARCHAR(6) NULL,
	vc_dec_count	VARCHAR(12) NULL,	
	ivd_countunit	VARCHAR(6) NULL,
	vc_dec_weight 	VARCHAR(12) NULL,
	count_qualifier  	VARCHAR(6) NULL,
	volume_qualifier  	VARCHAR(6) NULL,
	second_weight_qualifier  	VARCHAR(6) NULL,
	second_quantity_qualifier  	VARCHAR(6) NULL,
	wgtvolcountmil INTEGER NULL,
	ivd_sequence	INTEGER NULL,
	ivh_rateby	CHAR(1) NULL,
	ivd_wgt INTEGER NULL,
	ivd_volume INTEGER NULL,
	ivd_count INTEGER NULL,
	cht_primary	CHAR(1) NULL,
	cbadjustment VARCHAR(9) NULL,
	mincharge VARCHAR(9) NULL,
	oradjustment VARCHAR(9) NULL,
	fuelsurcharge VARCHAR (9) NULL,
	cwt VARCHAR (9) NULL,
	refnumber VARCHAR (30) NULL,
	ivd_reftype varchar(6) NULL,
	stp_number	int NULL,
	cty_name	varchar(18) NULL,
	state		varchar(2) NULL,
	secondary_edi_acc varchar(6) NULL,	--52647 
	cht_rollintolh int null,		    --58479
	cmp_id VARCHAR(8) null)				--72054

  SELECT @emptystring='',@varchar8 = ''

-- PTS 7759 check setting which omits zero charge records
 SELECT @E210NoZero3 = upper(ISNULL(gi_string1,'N')) 
 FROM generalinfo 
 WHERE gi_name = 'E210NoZero3'
 
 --PTS 36652
 SELECT @SplitbillMilkrun =UPPER(LEFT(ISNULL( gi_string1,'N'),1))  FROM generalinfo WHERE gi_name = 'SplitbillMilkrun'
SELECT  @addcitystate =  UPPER(ISNULL(trp_210_cityst,'N')) FROM edi_trading_partner WHERE trp_210id = @trpid

  SELECT  @E210NoZero3 = ISNULL( @E210NoZero3,'N')

  SELECT @ivh_hdrnumber=ivh_hdrnumber 
  FROM invoiceheader 
  WHERE ivh_invoicenumber=@invoice_number

-- retrieve most of the data into a temp table
INSERT INTO #210_inv_temp
	SELECT
		vc_weight=RIGHT(convert( varchar( 12 ),CONVERT(int, ISNULL(ivd_wgt,0))),7), 
		--vc_weight=RIGHT(convert( varchar( 12 ), ISNULL(ivd_wgt,0)),7),    --AJR PTS 31003	
		ivd_wgtunit= ISNULL(ivd_wgtunit,'LB '),		--PTS 27552			
		ivd_description=SUBSTRING(ISNULL(ivd_description,' '),1,30),				
		vc_quantity=case when upper(d.cht_basisunit) = 'REV' and (upper(d.cht_itemcode) =
					 'GST' or upper(d.cht_itemcode) = 'PST' ) then
					 case when ISNULL(ivd_rate,0.00) = 0 then
					      RIGHT(convert( varchar(12),0),9)
					 else 
					      RIGHT(convert( varchar(12),convert(decimal,(ISNULL(ivd_charge,0.00)*100/ivd_rate)*100)),9)
					 end	   
				  else
					RIGHT(convert( varchar(12),convert(decimal,ISNULL(ivd_quantity,0.00)*100)),9)
				  end,	
		ivd_quantity = ISNULL(ivd_quantity,0.00),                       
		ivd_unit = ISNULL(ivd_Unit,' '),
		vc_charge=RIGHT(convert( varchar( 12 ), convert(int,ISNULL(ivd_charge,0.00)*100)),9),
		ivd_charge = ISNULL(ivd_charge,0.00),
	        ivd_rate,
		vc_rate=RIGHT(convert( varchar( 12 ),convert(int, ISNULL(ivd_rate,0.00)*100)),9),  
	        vc_rate_to5dec=case when upper(d.cht_basisunit) = 'REV' and (upper(d.cht_itemcode) =
					 'GST' ) then
					RIGHT(CONVERT(varchar( 25 ),ISNULL(ivd_rate,0.00)*1000),17)
				else
					RIGHT(CONVERT(varchar( 25 ),ISNULL(ivd_rate,0.00)*100000),17)
				end,
		ivd_rateunit = ISNULL(ivd_rateunit,' '),
		cur_code = SUBSTRING(ISNULL(cur_code,'US'),1,1),
		cht_itemcode = ISNULL(d.cht_itemcode,' '),
		cmd_code = ISNULL(cmd_code,' '),					
		cht_basisunit = ISNULL(d.cht_basisunit,' '),
		ivh_billto = ISNULL(ivh_billto,' '),
		ivd_type = ISNULL(ivd_type,' '),              -- bill to company
		weight_qualifier=@emptystring,
		quantity_qualifier=@emptystring,
		charges_qualifier=@emptystring,
		rate_qualifier=@emptystring,
		freight_class= 
	     	CASE d.cht_itemcode
	       		WHEN 'QST' Then 'QST'
	       		WHEN 'GST' Then 'GST'
	       		WHEN 'SO'  Then 'SOC'
	       		WHEN 'TAX3'Then 'QST'
	       		ELSE '?'
	     	END,
		billedas_quantity=@emptystring,
		billedas_qualifier=@emptystring,
		NMFC=@emptystring,
		usercommodity= ISNULL(cmd_code,' '),
		primarycharge=@emptystring,
		vc_dec_volume =RIGHT(convert( varchar(12),convert(int,ISNULL(ivd_volume,0.00)*100)),9),	
		ivd_volunit = ISNULL(ivd_volunit,'CUB'),	--PTS 27552
		vc_dec_count = RIGHT(convert( varchar(12),convert(int,ISNULL(ivd_count,0.00)*100)),9),	
		ivd_countunit = ISNULL(ivd_countunit,'PCS'),	--PTS 27552
		vc_dec_weight = RIGHT(convert( varchar(12),convert(int,ISNULL(ivd_wgt,0.00)*100)),9),
		count_qualifier = ISNULL(ivd_countunit,''),
		volume_qualifier = ISNULL(ivd_volunit,''),
		second_weight_qualifier = ISNULL(ivd_wgtunit,'LB '), --PTS 27552
		second_quantity_qualifier = ISNULL(ivd_unit,''),
		wgtvolcountmil = (ISNULL(ivd_wgt,0) + ISNULL(ivd_distance,0) + isnull(ivd_volume,0) + ISNULL(ivd_count,0)),
		ivd_sequence,
		ISNULL(ivh_rateby,''),
		ivd_wgt,
		ivd_volume,
		ivd_count,
		cht_primary,
		cbadjustment = RIGHT(convert( varchar(9),convert(int,ISNULL(ivd_cbadjustment,0.00)*100)),9),
		mincharge = RIGHT(convert( varchar(9),convert(int,ISNULL(ivd_charge - ivd_rawcharge,0.00)*100)),9),
		oradjustment = RIGHT(convert( varchar(9),convert(int,ISNULL(ivd_oradjustment,0.00)*100)),9), 
		fuelsurcharge = RIGHT(convert( varchar(9),convert(int,ISNULL(ivd_fsc,0.00)*100)),9),
		cwt =  CASE ivd_wgt			   --PTS 27969    AROSS
					WHEN 0 then '0'
					WHEN null then '0'
					ELSE RIGHT(convert( varchar(9),convert(int,ISNULL(ivd_charge/(ivd_wgt/100),0.00)*100)),9)
			   END,
		refnumber = isnull(ivd_refnum,' '),-- ISNULL(LEFT(ivd_refnum,20),''),	
		ivd_reftype = ISNULL(ivd_reftype,'UNK'),		--36652
		stp_number =ISNULL(stp_number,0)	,			--36652
		cty_name = '',
		state = '',
		secondary_edi_acc = '',
		d.cht_rollintolh,	--58479
		isnull(d.cmp_id,'UNKNOWN')	--72054
	FROM invoicedetail d, invoiceheader h,chargetype c
	WHERE h.ivh_hdrnumber=@ivh_hdrnumber
	AND d.Ivh_hdrnumber = h.ivh_hdrnumber
	AND c.cht_itemcode = d.cht_itemcode
    ORDER  BY ivd_sequence

    --PTS58479 - CThom - Add to LHF charges from details when cht_rollintolh is set to true
select @rollintolhamount = sum(tbl.ivd_charge)
from #210_inv_temp tbl
	join chargetype c on c.cht_itemcode = tbl.cht_itemcode
where tbl.cht_rollintolh = 1
	and tbl.ivd_type = 'LI'
	and c.cht_basis = 'ACC'
		
select @rollintolhamount = isnull(@rollintolhamount,0)
Select @UseRollIntoLH =  IsNull(UPPER(LEFT(gi_string1,8)),'N') FROM generalinfo WHERE gi_name = 'EDI210UseRollIntoLH' --PTS 58479
	-- roll up only if rating by total for an order
IF @UseRollIntoLH = 'Y' and @rollintolhamount <> 0 and exists (select 1 from invoiceheader where ivh_hdrnumber = @ivh_hdrnumber
			and ivh_rateby in ('T','D') and ord_hdrnumber > 0)
	BEGIN  -- if min charge or quantity applied modify it
		If exists (select 1 from #210_inv_temp where cht_itemcode = 'MIN')
			BEGIN
				select @unit = ivd_unit,
				@rateunit = ivd_rateunit
				from #210_inv_temp tbl
				where cht_itemcode = 'MIN'
 
				select @ratefactor = unc_factor
				from unitconversion
				where unc_from = @unit
					and unc_to = @rateunit
					and unc_convflag = 'R'

				select @ratefactor = isnull(@ratefactor,1)
				update #210_inv_temp
				set ivd_charge = ivd_charge + @rollintolhamount,
					vc_charge=RIGHT(convert( varchar( 12 ), convert(int,ISNULL(ivd_charge+ @rollintolhamount,0.00)*100)),9),
					mincharge= right(convert( varchar( 12 ),  mincharge  + (@rollintolhamount*100)),9),
					vc_rate=convert( varchar( 12 ),convert(float, case ivd_quantity	
				when 0 then convert(int, ((ivd_charge + @rollintolhamount)*100))
					else  round((ivd_charge + @rollintolhamount)*100 / (ivd_quantity * @ratefactor),4)
					end)) -- rate
				
				where cht_itemcode = 'MIN'
				
				update #210_inv_temp
				set vc_rate_to5dec = case when upper(cht_basisunit) = 'REV' and upper(cht_itemcode) =
					 'GST'  then
					RIGHT(CONVERT(varchar( 25 ),ISNULL(ivd_rate + @rollintolhamount,0.00)*1000),17)
				else
					RIGHT(CONVERT(varchar( 25 ),ISNULL(ivd_rate + @rollintolhamount,0.00)*100000),17)
				end	 
				where cht_itemcode = 'MIN'
			
			END
		ELSE
			BEGIN
				
				select @unit = ivd_unit,
				@rateunit = ivd_rateunit
				from #210_inv_temp tbl
				where ivd_type = 'SUB'
 			        select @ratefactor = unc_factor
				from unitconversion
				where unc_from = @unit
				and unc_to = @rateunit
				and unc_convflag = 'R'

				select @ratefactor = isnull(@ratefactor,1)

				update #210_inv_temp
				set ivd_charge = ivd_charge + @rollintolhamount,
				vc_charge=RIGHT(convert( varchar( 12 ), convert(int,ISNULL(ivd_charge+ @rollintolhamount,0.00)*100)),9),
				mincharge= right(convert( varchar( 12 ),  mincharge  + (@rollintolhamount*100)),9),
				vc_rate=convert( varchar( 12 ),convert(float, case ivd_quantity 
				when 0 then convert(int, ((ivd_charge + @rollintolhamount)*100))
					else  round((ivd_charge + @rollintolhamount)*100 / (ivd_quantity * @ratefactor),4)
					end))  -- rate	
				where ivd_type = 'SUB'
				
				update #210_inv_temp
				set vc_rate_to5dec = case when upper(cht_basisunit) = 'REV' and upper(cht_itemcode) =
					 'GST'  then
					RIGHT(CONVERT(varchar( 25 ),ISNULL(ivd_rate + @rollintolhamount,0.00)*1000),17)
				else
					RIGHT(CONVERT(varchar( 25 ),ISNULL(ivd_rate + @rollintolhamount,0.00)*100000),17)
				end	
				where ivd_type = 'SUB'
				 
			END
			
			
		delete from #210_inv_temp 
		where cht_rollintolh = 1
	END

-- PTS 16681 update row for linehaul usercommodity: set it to first DEL row's commodity
UPDATE #210_inv_temp
SET cmd_code = (SELECT TOP 1 cmd_code from #210_inv_temp where cht_itemcode = 'DEL' and cmd_code <> 'UNKNOWN' order by ivd_sequence),--49432	
usercommodity = (SELECT TOP 1 cmd_code from #210_inv_temp where cht_itemcode = 'DEL' and cmd_code <> 'UNKNOWN' order by ivd_sequence)	--46481 --49432
WHERE ivd_type = 'SUB'

--PTS 46481
IF (SELECT ISNULL(cmd_code,'UNKNOWN') FROM #210_inv_temp WHERE ivd_type = 'SUB') = 'UNKNOWN'
	UPDATE #210_inv_temp
		SET cmd_code = (SELECT TOP 1 cmd_code FROM #210_inv_temp WHERE cht_itemcode = 'UNK' and cmd_code <> 'UNKNOWN' order by ivd_sequence),  --49432
		     usercommodity = (SELECT TOP 1 cmd_code FROM #210_inv_temp WHERE cht_itemcode = 'UNK' and cmd_code <> 'UNKNOWN' order by ivd_sequence)  --49432
	WHERE ivd_type = 'SUB'
--PTS 46481	
	
-- PTS 7924 this is shakey, but Rich insists

  SELECT --@totalwgt = SUM(ivd_wgt),		--get the totals from the invoiceheader instead.
      	 --@totalvolume = SUM(ivd_volume),
      	 --@totalcount = SUM(ivd_count),
       @wgtunit = MIN(ivd_wgtunit),
       @volunit = MIN(ivd_volunit),
       @countunit = MIN(ivd_countunit)
  FROM #210_inv_temp
  WHERE cht_itemcode = 'DEL'
  
  /* AROSS - PTS 31685 --get the total weight,volume and count from the invoiceheader. 
  	The SUM of invoicedetails is not reliable in some cases.			*/
    
    SELECT	@totalwgt = ivh_totalweight,
  		@totalvolume = ivh_totalvolume,
  		@totalcount = ivh_totalpieces
    FROM	invoiceheader WITH(NOLOCK)
    WHERE	ivh_invoicenumber = @invoice_number	
  
  --36652
  -- UPDATE #210_inv_temp
  -- SET	      cty_name  =  c.cty_name,
  			-- state = UPPER(LEFT(s.stp_state,2))
-- FROM	stops s 			
  	-- INNER JOIN city c
  		-- ON  c.cty_code = s.stp_city
-- WHERE  #210_inv_temp.stp_number = s.stp_number

--72054
UPDATE #210_inv_temp
SET		cty_name = ci.cty_name,
		state = UPPER(LEFT(ci.cty_state,2))
FROM	city ci WITH(NOLOCK)
	INNER JOIN company co WITH(NOLOCK) ON ci.cty_code = co.cmp_city
WHERE #210_inv_temp.cmp_id = co.cmp_id	
--END 72054  		
  

  --PTS 8367 6/30/00
  SELECT @totalwgt = ISNULL(@totalwgt,0)
  SELECT @totalvolume = ISNULL(@totalvolume,0)
  SELECT @totalcount = ISNULL(@totalcount,0)
  SELECT @wgtunit = ISNULL(@wgtunit,' ')
  SELECT @volunit = ISNULL(@volunit,' ')
  SELECT @countunit = ISNULL(@countunit,' ')

  UPDATE #210_inv_temp
  SET vc_weight = RIGHT(convert( varchar( 12 ), ISNULL(@totalwgt,0)),7),	
      vc_dec_weight = RIGHT(convert( varchar(12),convert(int,ISNULL(@totalwgt,0.00)*100)),9),
      vc_dec_volume = RIGHT(convert( varchar(12),convert(int,ISNULL(@totalvolume,0.00)*100)),9),
      vc_dec_count = RIGHT(convert( varchar(12),convert(int,ISNULL(@totalcount,0.00)*100)),9),
      ivd_wgtunit = @wgtunit,
      ivd_volunit = @volunit,
      ivd_countunit = @countunit,
      volume_qualifier = @volunit,
      count_qualifier = @countunit,
      weight_qualifier = @wgtunit
  WHERE ivh_rateby  =  'T'
  AND cht_primary = 'Y'
  AND ivd_charge > 0
  AND ivd_wgt = 0
  AND ivd_volume = 0
  AND ivd_count = 0

/*PTS 46481*/
SELECT @cmd_code = cmd_code FROM #210_inv_temp WHERE cht_primary = 'Y' and cht_itemcode = 'DEL'
IF ISNULL(@cmd_code,'UNKNOWN') <> 'UNKNOWN'
	UPDATE #210_inv_temp SET cmd_code = @cmd_code WHERE cht_primary = 'Y' AND cmd_code = 'UNKNOWN' AND ivh_rateby = 'T'
/*PTS 46481 end*/

-- PTS 7759
  IF substring(@E210NoZero3,1,1) = 'Y'
  	DELETE FROM #210_inv_temp WHERE ivd_charge = 0

-- Set the primary charge flag 
  UPDATE #210_inv_temp 
  SET primarycharge = c.cht_primary,
	cht_basisunit = c.cht_basisunit,
	Freight_class = 
      	  CASE c.cht_primary + freight_class
         	WHEN 'Y?' Then '002'
         	WHEN 'N?' Then '003'
         	Else freight_class
          END,
    	ivd_description = 
      	  CASE 
         	WHEN c.cht_primary = 'N'  AND c.cht_basis <> 'TAX'		--53076 Do not use cht_description for TAX items
				Then SUBSTRING(UPPER(ISNULL(c.cht_description,'? ')),1,30)
         	WHEN #210_inv_temp.ivd_description = 'UNKNOWN' AND #210_inv_temp.ivd_type <>'DRP'  
				Then SUBSTRING(UPPER(ISNULL(c.cht_description,'? ')),1,30)
			WHEN #210_inv_temp.ivd_description IS NULL AND #210_inv_temp.ivd_type <>'DRP'
	 			Then SUBSTRING(UPPER(ISNULL(c.cht_description,'? ')),1,30)
			WHEN RTRIM(#210_inv_temp.ivd_description) = '' AND #210_inv_temp.ivd_type <>'DRP'
				Then SUBSTRING(UPPER(ISNULL(c.cht_description,'? ')),1,30)
			WHEN RTRIM(#210_inv_temp.ivd_description) = '' AND #210_inv_temp.ivd_type = 'DRP'	--AROSS PTS28502 Corrected description for delivery line
				Then 'UNKNOWN'
         	Else ISNULL(RTRIM(#210_inv_temp.ivd_description),'UNKNOWN')
      	  END,
    	charges_qualifier = 
      	  CASE RTRIM(ISNULL(c.cht_edicode,''))
        	WHEN NULL then substring(c.cht_itemcode,1,3)  -- for sql 6.5 
     		WHEN '' then substring(c.cht_itemcode,1,3)
     		ELSE UPPER(substring(c.cht_edicode,1,3))
      	  END            -- added 3/22/00
  FROM chargetype c 
  WHERE #210_inv_temp.cht_itemcode = c.cht_itemcode

-- Get edi code for quantity qualifier through generalinfo AND labelfile
--if edicode is nul or empty string use the abbr 
  UPDATE #210_inv_temp 
  SET quantity_qualifier= case when edicode is null or edicode = ''  then
		                 convert(char(2),UPPER(SUBSTRING(ISNULL(abbr,' '),1,2)))
			       else
				 convert(char(2),UPPER(SUBSTRING(edicode,1,2)))
			       end 	
  FROM labelfile ,generalinfo  
  WHERE labeldefinition=gi_string1 AND abbr=ivd_unit AND gi_name='UnitBasis'+#210_inv_temp.cht_basisunit

-- Get edi code for second quantity qualifier through generalinfo AND labelfile
  UPDATE #210_inv_temp 
  SET second_quantity_qualifier= UPPER(edicode)
  FROM labelfile ,generalinfo 
  WHERE labeldefinition=gi_string1 AND abbr=ivd_unit 
  AND gi_name='UnitBasis'+#210_inv_temp.cht_basisunit
  AND edicode IS NOT NULL AND edicode > ''

-- Get edi code for rate qualifier through labelfile
  UPDATE #210_inv_temp 
  SET rate_qualifier= case when edicode is null or edicode = ''  then
		           	convert(char(2),UPPER(SUBSTRING(ISNULL(ivd_rateunit,' '),1,2)))
		           else
				 convert(char(2),UPPER(SUBSTRING(edicode,1,2)))
			   end,
      ivd_rateunit = 
          Case 
            WHEN edicode > ' ' THEN UPPER(edicode)
            ELSE ivd_rateunit
          End
  FROM #210_inv_temp,labelfile
  WHERE labeldefinition='RateBy' AND abbr=ivd_rateunit

-- Get edi code for weight qualifier through labelfile
  UPDATE #210_inv_temp 
  SET weight_qualifier= UPPER(convert(char(2),UPPER(SUBSTRING(ISNULL(edicode,' '),1,2))))
  FROM #210_inv_temp,labelfile
  WHERE labeldefinition='WeightUnits' AND abbr=ivd_wgtunit

-- Get edi code for second weight qualifier through labelfile
  UPDATE #210_inv_temp 
  SET second_weight_qualifier= UPPER(edicode)
  FROM #210_inv_temp,labelfile
  WHERE labeldefinition='WeightUnits' AND abbr=ivd_wgtunit
  AND edicode IS NOT NULL AND edicode > ''


-- Get edi code for volume qualifier through labelfile
  UPDATE #210_inv_temp 
  SET volume_qualifier= UPPER(edicode)
  FROM #210_inv_temp,labelfile
  WHERE labeldefinition='VolumeUnits' AND abbr=ivd_volunit
  AND edicode IS NOT NULL AND edicode > ''


-- Get edi code for count qualifier through labelfile
  UPDATE #210_inv_temp 
  SET count_qualifier= UPPER(edicode)
  FROM #210_inv_temp,labelfile
  WHERE labeldefinition='CountUnits' AND abbr=ivd_countunit
  AND edicode IS NOT NULL AND edicode > ''

-- Get the EDI equivalent for the commodity AND place in the temp
  UPDATE #210_inv_temp set 
	usercommodity = SUBSTRING(ISNULL(e.edi_cmd_code,''),1,8)
  FROM edicommodity e
  WHERE #210_inv_temp.ivh_billto = e.cmp_id
  AND   #210_inv_temp.cmd_code   = e.cmd_code 
  AND edi_cmd_code IS NOT NULL
  AND edi_cmd_code > ''

-- AROSS PTS 28408 Update the charges qualifier based on the ediaccessorial setup for the billto company.
If exists(SELECT 1 FROM ediaccessorial e, #210_inv_temp WHERE #210_inv_temp.ivh_billto = e.cmp_id AND #210_inv_temp.cht_itemcode = e.cht_itemcode	)
	UPDATE #210_inv_temp SET charges_qualifier = LEFT(edi_accessorial_code,3) 
		FROM	ediaccessorial e, #210_inv_temp
		WHERE   #210_inv_temp.ivh_billto = e.cmp_id
				AND #210_inv_temp.cht_itemcode   = e.cht_itemcode
--PTS 52647 Secondary equivalent value
if exists(SELECT 1 FROM ediaccessorial e, #210_inv_temp WHERE #210_inv_temp.ivh_billto = e.cmp_id AND #210_inv_temp.cht_itemcode = e.cht_itemcode)
	update #210_inv_temp set secondary_edi_acc =  isnull(edi_accessorial_code2,'') --PCURR PTS 62014
	FROM	ediaccessorial e, #210_inv_temp
		WHERE   #210_inv_temp.ivh_billto = e.cmp_id
				AND #210_inv_temp.cht_itemcode   = e.cht_itemcode
				
				
-- Get the EDI equivalent for the accessorial cht_itemcode AND place in the temp
/*UPDATE #210_inv_temp set 
	charges_qualifier =
          CASE #210_inv_temp.cht_itemcode
             WHEN 'ORDFLT' Then 'FLT'
             WHEN 'MIN' Then 'MIN'
	     --Else SUBSTRING(ISNULL(e.edi_accessorial_code,' '),1,8)
          END		  
FROM ediaccessorial e
WHERE   #210_inv_temp.ivh_billto = e.cmp_id
AND   #210_inv_temp.cht_itemcode   = e.cht_itemcode	  */

--End 28408

-- for Minimum charges AND quantities set the description to MINIMUM
-- (PTS 6013 7/12/99) AND the usercommodity code to MIN
UPDATE #210_inv_temp
set ivd_description = 'MINIMUM',
    usercommodity = 'MIN'
WHERE  cht_itemcode = 'MIN'

-- Pad to the right size AND hANDle negative numbers
UPDATE #210_inv_temp set
vc_weight=
   CASE SUBSTRING(vc_weight,1,1)
     WHEN '-' Then '-' + REPLICATE('0',7 - datalength(vc_weight)) + SUBSTRING(vc_weight,2,datalength(vc_weight) - 1) --REPLACE(vc_weight,'-','')
     Else REPLICATE('0',7 - datalength(vc_weight)) + vc_weight
   END,
vc_quantity = 
   CASE SUBSTRING(vc_quantity,1,1)
     WHEN '-' Then '-' + REPLICATE('0',9 - datalength(vc_quantity)) + SUBSTRING(vc_quantity,2,datalength(vc_quantity) - 1) --REPLACE(vc_quantity,'-','')
     Else REPLICATE('0',9 - datalength(vc_quantity)) + vc_quantity
   END, 
vc_charge = 
   CASE SUBSTRING(vc_charge,1,1)
     WHEN '-' Then '-' + REPLICATE('0',9 - datalength(vc_charge)) + SUBSTRING(vc_charge,2,datalength(vc_charge) - 1) --REPLACE(vc_charge,'-','')
     Else REPLICATE('0',9 - datalength(vc_charge)) + vc_charge
   END, 
vc_dec_weight=
   CASE SUBSTRING(vc_dec_weight,1,1)
     WHEN '-' Then '-' + REPLICATE('0',9 - datalength(vc_dec_weight)) + SUBSTRING(vc_dec_weight,2,datalength(vc_dec_weight) - 1) --REPLACE(vc_weight,'-','')
     Else REPLICATE('0',9 - datalength(vc_dec_weight)) + vc_dec_weight
   END,
vc_dec_count=
   CASE SUBSTRING(vc_dec_count,1,1)
     WHEN '-' Then '-' + REPLICATE('0',9 - datalength(vc_dec_count)) + SUBSTRING(vc_dec_count,2,datalength(vc_dec_count) - 1) --REPLACE(vc_weight,'-','')
     Else REPLICATE('0',9 - datalength(vc_dec_count)) + vc_dec_count
   END,
vc_dec_volume=
   CASE SUBSTRING(vc_dec_volume,1,1)
     WHEN '-' Then '-' + REPLICATE('0',9 - datalength(vc_dec_volume)) + SUBSTRING(vc_dec_volume,2,datalength(vc_dec_volume) - 1) --REPLACE(vc_weight,'-','')
     Else REPLICATE('0',9 - datalength(vc_dec_volume)) + vc_dec_volume
   END,
billedas_qualifier=ISNULL(billedas_qualifier,''),
ivd_unit=isnull(ivd_unit,''),
vc_rate = 
   CASE SUBSTRING(vc_rate,1,1)
     WHEN '-' Then '-' + REPLICATE('0',9 - datalength(vc_rate)) + SUBSTRING(vc_rate,2,datalength(vc_rate) - 1) --REPLACE(vc_rate,'-','')
     Else REPLICATE('0',9 - datalength(vc_rate)) + vc_rate
   END, 
rate_qualifier=ISNULL(rate_qualifier,''),
NMFC=ISNULL(NMFC,''),
Freight_class=ISNULL(freight_class,''),
Usercommodity=ISNULL(usercommodity,''),
ivd_rateunit=isnull(ivd_rateunit,''),
cur_code=isnull(substring(cur_code,1,1),''),
vc_rate_to5dec =
	CASE SUBSTRING(vc_rate_to5dec,1,1)
	WHEN '-' Then '-' + Replicate('0',14 - (LEN(vc_rate_to5dec)-3)) + SUBSTRING(vc_rate_to5dec,2,LEN(vc_rate_to5dec) - 4)	--PTS 50225
	Else SUBSTRING(vc_rate_to5dec,1,LEN(vc_rate_to5dec) - 3)  -- pull off .00
	END
/* An unrated invoice with flag to not write zero charge lines leaves no result set and an error */
	IF (SELECT COUNT(*) FROM  #210_inv_temp) > 0 AND
	   (SELECT COUNT(*) FROM  #210_inv_temp WHERE wgtvolcountmil > 0 or ivd_quantity > 0 or primarycharge = 'N') > 0  AND (@SplitBillMilkRun = 'Y')
	BEGIN
		-- then create the records
		insert into edi_210(data_col,doc_id,trp_id)
		select  '3' +			
		'39'  +
		vc_weight +		-- weight 
		weight_qualifier +	-- weight qualifier
		replicate(' ',2-datalength(weight_qualifier)) +
		ivd_description +			-- commodity desc
		replicate(' ',30-datalength(ivd_description))+
		vc_quantity +		-- Quantity (incl 2 decimals)
		quantity_qualifier +	-- Quantity qualifier
		replicate(' ',3-datalength(quantity_qualifier))  +
		vc_charge +		-- charges
		charges_qualifier +	-- charges qualifier
		replicate(' ',3-datalength(charges_qualifier)) +
		SUBSTRING(vc_quantity,1,7)+	-- billed as quantity (2 decimals truncated)
		quantity_qualifier +	-- billed as quantity qualifier
		replicate(' ',2-datalength(quantity_qualifier))  +
		vc_rate +		-- rate
		rate_qualifier +	-- rate qualifier
		replicate(' ',2-datalength(rate_qualifier)) +
		NMFC +			-- NMFC
		replicate(' ',7-datalength(NMFC)) +
		freight_class +		-- freight class
		replicate(' ',7-datalength(freight_class)) +
		usercommodity +		-- user commodity
		replicate(' ',8-datalength(usercommodity)) +
		cur_code +		-- currency
		replicate(' ',1-datalength(cur_code)) +
		vc_dec_count +
		count_qualifier + replicate(' ',6-datalength(count_qualifier)) +
		vc_dec_weight + 
		second_weight_qualifier + replicate(' ',6-datalength(second_weight_qualifier)) +
		vc_dec_volume + 
		volume_qualifier + replicate(' ',6-datalength(volume_qualifier)) +
		vc_quantity +		
		second_quantity_qualifier +	-- Quantity qualifier
		replicate(' ',6-datalength(second_quantity_qualifier))  +
		replicate('0',14 - datalength(vc_rate_to5dec)) + vc_rate_to5dec +
		ivd_rateunit + REPLICATE(' ',6 - datalength(ivd_rateunit))+		--Split bill from here on
		replicate(' ',9-datalength(cbadjustment)) + cbadjustment + 
		replicate(' ',9-datalength(mincharge)) + mincharge + 
		replicate(' ',9-datalength(oradjustment)) + oradjustment + 
		replicate('0',9-datalength(fuelsurcharge)) + fuelsurcharge +
		replicate(' ',9-datalength(cwt)) + cwt +
		replicate(' ',20-datalength(substring(refnumber,1,20))) + refnumber,
		@docid,
		@trpid
		FROM #210_inv_temp
		WHERE wgtvolcountmil <> 0 or ivd_quantity <> 0 or primarycharge = 'N'
	--PTS 31331 - Allow for negative(non-zero) quantities in output.	
	--Warning do not change the above WHERE without checking on affect on Florida 
	--Rock.  They need to map line items with billing quantities AND zero charge

	--INSERT into EDI_210(data_col,doc_id,trp_id)
	--values(@data,@docid,@trpid)
	--doc_id = @docid,
	--trp_id = @trpid

	END

	/*Added for PTS 36652 to separate split bill stuff */
	IF (SELECT COUNT(*) FROM  #210_inv_temp) > 0 AND
	   (SELECT COUNT(*) FROM  #210_inv_temp WHERE wgtvolcountmil > 0 or ivd_quantity > 0 or primarycharge = 'N') > 0 AND (@SplitBillMilkRun <> 'Y')
	   BEGIN

			insert into edi_210(data_col,doc_id,trp_id)
			select  '3' +			
			'39'  +
			vc_weight +		-- weight 
			weight_qualifier +	-- weight qualifier
			replicate(' ',2-datalength(weight_qualifier)) +
			ivd_description +			-- commodity desc
			replicate(' ',30-datalength(ivd_description))+
			vc_quantity +		-- Quantity (incl 2 decimals)
			quantity_qualifier +	-- Quantity qualifier
			replicate(' ',3-datalength(quantity_qualifier))  +
			vc_charge +		-- charges
			charges_qualifier +	-- charges qualifier
			replicate(' ',3-datalength(charges_qualifier)) +
			SUBSTRING(vc_quantity,1,7)+	-- billed as quantity (2 decimals truncated)
			quantity_qualifier +	-- billed as quantity qualifier
			replicate(' ',2-datalength(quantity_qualifier))  +
			vc_rate +		-- rate
			rate_qualifier +	-- rate qualifier
			replicate(' ',2-datalength(rate_qualifier)) +
			NMFC +			-- NMFC
			replicate(' ',7-datalength(NMFC)) +
			freight_class +		-- freight class
			replicate(' ',7-datalength(freight_class)) +
			usercommodity +		-- user commodity
			replicate(' ',8-datalength(usercommodity)) +
			cur_code +		-- currency
			replicate(' ',1-datalength(cur_code)) +
			vc_dec_count +
			count_qualifier + replicate(' ',6-datalength(count_qualifier)) +
			vc_dec_weight + 
			second_weight_qualifier + replicate(' ',6-datalength(second_weight_qualifier)) +
			vc_dec_volume + 
			volume_qualifier + replicate(' ',6-datalength(volume_qualifier)) +
			vc_quantity +		
			second_quantity_qualifier +	-- Quantity qualifier
			replicate(' ',6-datalength(second_quantity_qualifier))  +
			replicate('0',14 - datalength(vc_rate_to5dec)) + vc_rate_to5dec +
			ivd_rateunit + REPLICATE(' ',6 - datalength(ivd_rateunit))+
			CASE @addcitystate
				WHEN 'Y' 	THEN  ISNULL(cty_name,CHAR(32)) + REPLICATE(' ',18 - datalength(ISNULL(cty_name,CHAR(32)))) 
							+ ISNULL(state,CHAR(32)) + REPLICATE(' ',2 - DATALENGTH(ISNULL(state,CHAR(32))))
							+ ISNULL(LEFT(ivd_reftype,3),CHAR(32)) + REPLICATE(' ',3 - DATALENGTH(ISNULL(LEFT(ivd_reftype,3),CHAR(32)))) 
							 + ISNULL(substring(refnumber,1,20),' ') + REPLICATE(' ',20 - DATALENGTH(ISNULL(substring(refnumber,1,20),' ')))
				WHEN 'N' THEN REPLICATE(CHAR(32),43)
				ELSE REPLICATE(CHAR(32),43)
			END +
			secondary_edi_acc + REPLICATE(CHAR(32),6-DATALENGTH(isnull(secondary_edi_acc,'')))+
			CASE @addcitystate
				WHEN 'Y'	THEN	SUBSTRING(refnumber,21,10) + REPLICATE(char(32),10 - Datalength(SUBSTRING(refnumber,21,10)))
				WHEN 'N' THEN REPLICATE(CHAR(32),10)
				ELSE  REPLICATE(CHAR(32),10)
			END,		
			@docid,
			@trpid
		FROM #210_inv_temp
		WHERE wgtvolcountmil <> 0 or ivd_quantity <> 0 or primarycharge = 'N'
	  END	
		

GO
GRANT EXECUTE ON  [dbo].[edi_210_record_id_3_39_sp] TO [public]
GO
