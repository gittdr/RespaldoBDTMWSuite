SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_CreateMiscInvoiceHeader2] @p_trc_number varchar(8),	--1
						@p_driver1 varchar(8),		--2
						@p_driver2 varchar(8),		--3
						@p_trailer1 varchar(8),		--4
						@p_ivh_billto varchar(25),	--5 --PTS 61189 change cmp_id fields to 25 length
						@p_qty float,			--6
						@p_vol float,			--7
						@p_wgt float,			--8
						@p_mile float,			--9
						@p_pcs float,			--10
						@p_date varchar(25),		--11
						@p_time varchar(25),		--12
						@p_flags varchar(15),		--13
						@p_TotalCharge money,		--14
						@p_ivh_hdrnumber int OUT,	--15
						@p_ivh_revtype1 varchar(6),	--16
						@p_ivh_revtype2 varchar(6),	--17
						@p_ivh_revtype3 varchar(6),	--18
						@p_ivh_revtype4 varchar(6)	--19

AS

/**
 * 
 * NAME:
 * dbo.tmail_CreateMiscInvoiceHeader2
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *  Creates a miscellaneous invoice header (not attached to order).
 *
 * RETURNS:
 *  @p_ivh_hdrnumber
 *
 * RESULT SETS: 
 *  none
 *
 * PARAMETERS:
 * 001 - @p_trc_number  varchar(8), input, null;
 *        The tractor the invoice is for
 * 002 - @p_driver1 varchar(8), input
 *        The driver1 the invoice is for
 * 003 - @p_driver2 varchar(8), input
 *        The driver2 the invoice is for
 * 004 - @p_trailer1, varchar(8), input
 *        The trailer1 the invoice is for
 * 005 - @p_ivh_billto, varchar(8), input
 *        The billto for the invoice
 * 006 - @p_qty, float, input
 *        This is the qty
 * 007 - @p_vol, float, input
 *        This is the volume
 * 008 - @p_wgt, float, input
 *        This is the weight
 * 009 - @p_mile, float, input
 *        This is the mileage
 * 010 - @p_pcs, float, input
 *        This is the piece count
 * 011 - @p_date, varchar(25), input
 *        The date of the invoice (can hold just date or date/time)
 * 012 - @p_time, varchar(25), input
 *        The time of the invoice (can hold just time or date/time)
 * 013 - @p_flags, varchar(15), input
 *        Not used at this time
 * 014 - @p_TotalCharge, money, input
 *        The itemcode for the Charge Type of this invoice.
 * 015 - @p_ivh_hdrnumber, int, output
 *        The ivh_hdrnumber of the newly created invoiceheader.
 * 016 - @p_ivh_revtype1, varchar(6), input
 *	  If populated, will be used for the ivh_revtype1
 * 017 - @p_ivh_revtype2, varchar(6), input
 *	  If populated, will be used for the ivh_revtype2
 * 018 - @p_ivh_revtype3, varchar(6), input
 *	  If populated, will be used for the ivh_revtype3
 * 019 - @p_ivh_revtype4, varchar(6), input
 *	  If populated, will be used for the ivh_revtype4
 *
 * REFERENCES:
 * dbo.getsystemnumber
 * 
 * REVISION HISTORY:
 * 06/21/2006.01 – PTS33466 - MIZ – created
 * 11/30/2006.01 - PTS31449 - MIZ - Created v2 to add the ivh_revtype parameters.
 *
 **/

SET NOCOUNT ON

DECLARE @vs_ivh_invoicenumber varchar(12),
	@vs_ivh_terms varchar(3),
	@vm_rate money,
	@vdtm_date datetime

SET NOCOUNT ON 

-- Validation
IF (RTRIM(LTRIM(ISNULL(@p_trc_number,''))) <> '')
	IF NOT EXISTS (SELECT * 
					FROM tractorprofile (NOLOCK)
					WHERE trc_number = @p_trc_number)
	  BEGIN
		RAISERROR ('Invalid tractor (%s). Invoiceheader could not be created.', 16, 1, @p_trc_number)
		RETURN 1
	  END
ELSE
	SET @p_trc_number = 'UNKNOWN'

IF (LTRIM(RTRIM(ISNULL(@p_driver1,''))) <> '')
  BEGIN
	IF NOT EXISTS (SELECT * 
					FROM manpowerprofile (NOLOCK)
					WHERE mpp_id = @p_driver1)
	  BEGIN
		RAISERROR ('Invalid Driver1 (%s). Invoiceheader could not be created.', 16, 1, @p_driver1)
		RETURN 1
	  END
  END
ELSE
	SET @p_driver1 = 'UNKNOWN'

IF (LTRIM(RTRIM(ISNULL(@p_driver2,''))) <> '')
  BEGIN
	IF NOT EXISTS (SELECT * 
					FROM manpowerprofile (NOLOCK)
					WHERE mpp_id = @p_driver2)
	  BEGIN
		RAISERROR ('Invalid Driver2 (%s). Invoiceheader could not be created.', 16, 1, @p_driver2)
		RETURN 1
	  END
  END
ELSE
	SET @p_driver2 = 'UNKNOWN'

IF (LTRIM(RTRIM(ISNULL(@p_trailer1,''))) <> '')
  BEGIN
	IF NOT EXISTS (SELECT * 
					FROM trailerprofile (NOLOCK)
					WHERE trl_number = @p_trailer1)
	  BEGIN
		RAISERROR ('INVALID TRAILER1 (%s). Invoiceheader could not be created.', 16, 1, @p_trailer1)
		RETURN 1
	  END
  END
ELSE
	SET @p_trailer1 = 'UNKNOWN'

IF (LTRIM(RTRIM(@p_ivh_billto)) = '')
  BEGIN
	RAISERROR ('No billto was provided. Invoiceheader could not be created.', 16, 1)
	RETURN 1
  END

-- Figure out the date/time
SET @p_date = RTRIM(LTRIM(ISNULL(@p_date,'')))
SET @p_time = RTRIM(LTRIM(ISNULL(@p_time,'')))

IF (@p_time + @p_date = '')
  BEGIN
	RAISERROR ('No date provided. Invoiceheader could not be created.', 16, 1)
	RETURN 1
  END
ELSE
  BEGIN
	IF (@p_date <> '' AND @p_time <> '')
	  BEGIN
		-- Both date and time fields are populated, so put together and test.
		IF (CHARINDEX(' ', @p_time) > 0)  -- Does the time field also contain the date?  If so, grab just the time.
			SET @p_time = LTRIM(SUBSTRING(@p_time, CHARINDEX(' ', @p_time), DATALENGTH(@p_time)))

		IF (CHARINDEX(' ', @p_date) > 0)  -- Does the date field also contain the time?  If so, grab just the date.
			SET @p_date = LTRIM(LEFT(@p_date, CHARINDEX(' ', @p_date)))

		SET @p_date = @p_date + ' ' + @p_time
		IF (ISDATE(@p_date) < 1)
		  BEGIN
			RAISERROR ('1) Invalid date/time (%s). Invoiceheader could not be created.', 16, 1, @p_date)
			RETURN 1
		  END
		ELSE
			SET @vdtm_date = CONVERT(datetime, @p_date)
	  END
	ELSE
	  BEGIN
		IF (@p_time = '') 
		  BEGIN
			-- @p_date must hold both date and time
			IF (ISDATE(@p_date) < 1)
			  BEGIN
				RAISERROR ('2) Invalid date/time (%s). Invoiceheader could not be created.', 16, 1, @p_date)
				RETURN 1
			  END
			ELSE
				SET @vdtm_date = CONVERT(datetime, @p_date)
		  END
		ELSE
			-- @p_time must hold both date and time
			IF (ISDATE(@p_time) < 1)
			  BEGIN
				RAISERROR ('3) Invalid date/time (%s). Invoiceheader could not be created.', 16, 1, @p_time)
				RETURN 1
			  END
			ELSE
				SET @vdtm_date = CONVERT(datetime, @p_time)	
	  END
  END

-- Validate the ivh_revtypes
IF (ISNULL(@p_ivh_revtype1,'') = '')
	SET @p_ivh_revtype1 = 'UNK'
ELSE
	IF NOT EXISTS (SELECT COUNT(*) 
					FROM labelfile (NOLOCK)
					WHERE labeldefinition = 'RevType1' AND abbr = @p_ivh_revtype1)
	  BEGIN
		RAISERROR ('Invalid ivh_revtype1 (%s). Invoiceheader could not be created.', 16, 1, @p_ivh_revtype1)
		RETURN 1
	  END

IF (ISNULL(@p_ivh_revtype2,'') = '')
	SET @p_ivh_revtype2 = 'UNK'
ELSE
	IF NOT EXISTS (SELECT COUNT(*) 
					FROM labelfile (NOLOCK)
					WHERE labeldefinition = 'RevType2' AND abbr = @p_ivh_revtype2)
	  BEGIN
		RAISERROR ('Invalid ivh_revtype2 (%s). Invoiceheader could not be created.', 16, 1, @p_ivh_revtype2)
		RETURN 1
	  END

IF (ISNULL(@p_ivh_revtype3,'') = '')
	SET @p_ivh_revtype3 = 'UNK'
ELSE
	IF NOT EXISTS (SELECT COUNT(*) 
					FROM labelfile (NOLOCK)
					WHERE labeldefinition = 'RevType3' AND abbr = @p_ivh_revtype3)
	  BEGIN
		RAISERROR ('Invalid ivh_revtype3 (%s). Invoiceheader could not be created.', 16, 1, @p_ivh_revtype3)
		RETURN 1
	  END

IF (ISNULL(@p_ivh_revtype4,'') = '')
	SET @p_ivh_revtype4 = 'UNK'
ELSE
	IF NOT EXISTS (SELECT COUNT(*) 
					FROM labelfile (NOLOCK)
					WHERE labeldefinition = 'RevType4' AND abbr = @p_ivh_revtype4)
	  BEGIN
		RAISERROR ('Invalid ivh_revtype4 (%s). Invoiceheader could not be created.', 16, 1, @p_ivh_revtype4)
		RETURN 1
	  END

-- Get the ivh_terms from the cmp_terms field of the billto company
SET @p_ivh_billto = UPPER(@p_ivh_billto)
SET @vs_ivh_terms = ''
SELECT @vs_ivh_terms = ISNULL(cmp_terms,'') 
FROM company
WHERE cmp_id = @p_ivh_billto

IF (@vs_ivh_terms = '') 
	SET @vs_ivh_terms = 'UNK'

EXEC @p_ivh_hdrnumber = dbo.getsystemnumber 'INVHDR', NULL  
SET @vs_ivh_invoicenumber =  'S' + CONVERT(varchar(12), @p_ivh_hdrnumber) 

INSERT INTO invoiceheader (ivh_invoicenumber, 
				ivh_billto, 
				ivh_terms, 
				ivh_totalcharge, 
				ivh_shipper, 		-- 5
				ivh_consignee, 
				ivh_originpoint, 
				ivh_destpoint, 
				ivh_invoicestatus, 
				ivh_origincity, 	-- 10
				ivh_destcity, 
				ivh_originstate, 
				ivh_deststate, 
				ivh_originregion1,
				ivh_destregion1,	-- 15
				ivh_supplier, 
				ivh_shipdate, 		
				ivh_deliverydate, 
				ivh_revtype1, 
				ivh_revtype2, 		-- 20
				ivh_revtype3, 
				ivh_revtype4, 
				ivh_totalweight, 
				ivh_totalpieces, 
				ivh_totalmiles, 	-- 25
				ivh_currency, 
				ivh_currencydate, 	
				ivh_totalvolume, 
				ivh_taxamount1, 
				ivh_taxamount2, 	-- 30
				ivh_taxamount3, 
				ivh_taxamount4,
				ivh_transtype,
				ivh_creditmemo, 
				ivh_applyto, 		-- 35
				shp_hdrnumber,
				ivh_printdate,
				ivh_billdate, 
				ivh_lastprintdate,		
				ivh_hdrnumber, 		-- 40
				ord_hdrnumber, 	
				ivh_originregion2,
				ivh_originregion3,
				ivh_originregion4,
				ivh_destregion2,	-- 45
				ivh_destregion3,
				ivh_destregion4,
				mfh_hdrnumber,
				ivh_remark,
				ivh_driver,		-- 50
				ivh_tractor, 
				ivh_trailer, 
				ivh_user_id1,
				ivh_user_id2,
				ivh_ref_number,		-- 55
				ivh_driver2, 
				mov_number, 
				ivh_edi_flag,
				ivh_freight_miles, 
				ivh_priority, 		-- 60
				ivh_low_temp, 
				ivh_high_temp, 	
				ivh_xferdate,
				ivh_order_by, 
				tar_tarriffnumber, 	-- 65
				tar_number, 
				ivh_bookyear,
				ivh_bookmonth,
				tar_tariffitem, 
				ivh_maxlength,		-- 70
				ivh_maxwidth,
				ivh_maxheight,
				ivh_mbstatus,
				ivh_mbnumber, 
				ord_number, 		-- 75
				ivh_quantity, 
				ivh_rate, 
				ivh_charge, 
				cht_itemcode, 
				ivh_splitbill_flag, 	-- 80
				ivh_company, 
				ivh_carrier, 
				ivh_archarge, 
				ivh_arcurrency, 
				ivh_loadtime,		-- 85
				ivh_unloadtime,
				ivh_drivetime,	
				ivh_totaltime, 	
				ivh_rateby, 
				ivh_revenue_date,	-- 90
				ivh_batch_id,
				ivh_stopoffs, 
				ivh_quantity_type, 
				ivh_charge_type,
				ivh_originzipcode,	-- 95
				ivh_destzipcode,
				ivh_ratingquantity,
				ivh_ratingunit,
				ivh_unit,
				ivh_mileage_adjustment,	-- 100
				ivh_definition,
				ivh_hideshipperaddr,
				ivh_hideconsignaddr,
				ivh_paperworkstatus,
				ivh_showshipper,	-- 105
				ivh_showcons,
				ivh_allinclusivecharge,
				ivh_order_cmd_code,
				ivh_applyto_definition,
				ivh_reftype,		-- 110
				ivh_attention,
				ivh_rate_type,
				ivh_paperwork_override,
				ivh_cmrbill_link,
				ivh_mbperiod,		-- 115
				ivh_mbperiodstart,
				ivh_imagestatus,
				ivh_imagestatus_date,
				ivh_imagecount,
				ivh_mbimagestatus,	-- 120
				ivh_mbimagestatus_date,
				ivh_mbimagecount,
				last_updateby,
				last_updatedate,
				ivh_mileage_adj_pct,	-- 125
				ivh_custdoc,	
				ivh_entryport,
				ivh_exitport,
				ivh_paid_amount,
				ivh_pay_status,		-- 130
				ivh_dimfactor,	
				ivh_trlConfiguration,
				inv_revenue_pay_fix,
				inv_revenue_pay,
				ivh_billto_parent,	-- 135
				ivh_block_printing)
VALUES (@vs_ivh_invoicenumber,		-- ivh_invoicenumnber
	@p_ivh_billto,			-- ivh_billto
	@vs_ivh_terms,			-- ivh_terms
	@p_TotalCharge,			-- ivh_totalcharge
	'UNKNOWN',			-- ivh_shipper		-- 5
	'UNKNOWN',			-- ivh_consignee
	'UNKNOWN',			-- ivh_originpoint
	'UNKNOWN',			-- ivh_destpoint
	'HLD',				-- ivh_invoicestatus
	'0',				-- ivh_origincity	-- 10
	'0',				-- ivh_destcity
	null,				-- ivh_originstate
	null,				-- ivh_deststate
	null,				-- ivh_originregion1
	null,				-- ivh_destregion1	-- 15
	null,				-- ivh_supplier
	@vdtm_date,			-- ivh_shipdate
	@vdtm_date,			-- ivh_deliverydate
	@p_ivh_revtype1,		-- ivh_revtype1
	@p_ivh_revtype2,		-- ivh_revtype2		-- 20
	@p_ivh_revtype3,		-- ivh_revtype3
	@p_ivh_revtype4,		-- ivh_revtype4
	@p_wgt,				-- ivh_totalweight
	@p_pcs,				-- ivh_totalpieces
	@p_mile,			-- ivh_totalmiles	-- 25
	'US$',				-- ivh_currency
	null, 				-- ivh_currencydate
	@p_vol,				-- ivh_totalvolume
	null,				-- ivh_taxamount1
	null,				-- ivh_taxamount2	-- 30
	null,				-- ivh_taxamount3
	null,				-- ivh_taxamount4
	'CSH',				-- ivh_transtype
	null, 				-- ivh_creditmemo
	@vs_ivh_invoicenumber,		-- ivh_applyto		-- 35
	null,				-- shp_hdrnumber
	null,				-- ivh_printdate
	@vdtm_date,			-- ivh_billdate
	null,				-- ivh_lastprintdate
	@p_ivh_hdrnumber,		-- ivh_hdrnumber	-- 40
	0,				-- ord_hdrnumber
	null,				-- ivh_originregion2
	null,				-- ivh_originregion3
	null,				-- ivh_originregion4
	null,				-- ivh_destregion2	-- 45
	null,				-- ivh_destregion3		
	null,				-- ivh_destregion4
	null,				-- mfh_hdrnumber
	null,				-- ivh_remark
	@p_driver1,			-- ivh_driver		-- 50
	@p_trc_number,			-- ivh_tractor
	@p_trailer1,			-- ivh_trailer
	'TMAIL',			-- ivh_user_id1		-- TMWSuite uses suser_sname()
	'TMAIL',			-- ivh_user_id2
	null,				-- ivh_ref_number	-- 55
	@p_driver2,			-- ivh_driver2
	null,				-- mov_number
	'NONE',				-- ivh_edi_flag
	null,				-- ivh_freight_miles
	'?',				-- ivh_priority		-- 60
	0, 				-- ivh_low_temp
	0,				-- ivh_high_temp
	null,				-- ivh_xferdate
	'UNKNOWN',			-- ivh_order_by
	null,				-- tar_tarriffnumber	-- 65
	null,				-- tar_number
	null,				-- ivh_bookyear
	null, 				-- ivh_bookmonth
	null,				-- tar_tariffitem
	null,				-- ivh_maxlength	-- 70
	null, 				-- ivh_maxwidth
	null,				-- ivh_maxheight
	'HLD',   			-- ivh_mbstatus
	0,				-- ivh_mbnumber
	'0',				-- ord_number		-- 75
	@p_qty,				-- ivh_quantity
	null,				-- ivh_rate
	0,				-- ivh_charge
	null,				-- cht_itemcode
	'N',				-- ivh_splitbill_flag	-- 80
	'UNK',				-- ivh_company
	'UNKNOWN',			-- ivh_carrier
	@p_TotalCharge,			-- ivh_archarge
	'US$',  			-- ivh_arcurrency
	null,				-- ivh_loadtime		-- 85
	null, 				-- ivh_unloadtime
	null,				-- ivh_drivetime
	null,				-- ivh_totaltime
	null, 				-- ivh_rateby
	'19050101',			-- ivh_revenue_date	-- 90
	'UNKNOWN',			-- ivh_batch_id
	null,				-- ivh_stopoffs
	0,				-- ivh_quantity_type
	0, 				-- ivh_charge_type
	'',				-- ivh_originzipcode	-- 95
	'',				-- ivh_destzipcode
	null,				-- ivh_ratingquantity
	null,				-- ivh_ratingunit
	'FLT',   			-- ivh_unit
	0,				-- ivh_mileage_adjustment	-- 100
	'MISC',				-- ivh_definition
	null,				-- ivh_hideshipperaddr
	null,				-- ivh_hideconsignaddr
	'UNK',				-- ivh_paperworkstatus
	'UNKNOWN',			-- ivh_showshipper		-- 105
	'UNKNOWN',			-- ivh_showcons
	null,				-- ivh_allinclusivecharge
	null,				-- ivh_order_cmd_code	
	'MISC',				-- ivh_applyto_definition
	'REF',				-- ivh_reftype			-- 110
	null,				-- ivh_attention
	0,				-- ivh_rate_type
	'Y',				-- ivh_paperwork_override
	0,				-- ivh_cmrbill_link
	null,				-- ivh_mbperiod			-- 115
	null,				-- ivh_mtperiodstart
	null,				-- ivh_imagestatus
	null,				-- ivh_imagestatus_date
	null,				-- ivh_imagecount
	null,				-- ivh_mbimagestatus		-- 120
	null,				-- ivh_mbimagestatus_date
	null,				-- ivh_mbimagecount
	'TMAIL',			-- last_updateby
	GETDATE(),			-- last_updatedate
	0,				-- ivh_mileage_adj_pct		-- 125
	null,				-- ivh_custdoc
	'UNKNOWN',			-- ivh_entryport
	'UNKNOWN',			-- ivh_exitport
	null,				-- ivh_paid_amount
	null,				-- ivh_pay_status		-- 130
	0,				-- ivh_dimfactor
	'UNK',				-- ivh_trlConfiguration
	0,				-- inv_revenue_pay_fix
	@p_TotalCharge,			-- inv_revenue_pay			
	null, 				-- ivh_billto_parent		-- 135
	'N')				-- ivh_block_printing
GO
GRANT EXECUTE ON  [dbo].[tmail_CreateMiscInvoiceHeader2] TO [public]
GO
