SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE PROCEDURE [dbo].[tmail_Add_Accessorial3] @p_sOrdnumber varchar(12),		--1
						@p_sChargetype varchar(6),	--2
						@p_sQuantity varchar(12),	--3
						@p_sRate varchar(12),		--4
						@p_sCompany varchar(25),		--5 --PTS 61189 CMP_ID INCREASE LENGTH TO 25
						@p_sFlags varchar(12),		--6
						@p_trc_number varchar(8),	--7
						@p_driver1 varchar(8),		--8
						@p_driver2 varchar(8),		--9
						@p_trailer1 varchar(8),		--10
						@p_ivh_billto varchar(25),	--11 --PTS 61189 CMP_ID INCREASE LENGTH TO 25
						@p_date varchar(25),		--12
						@p_time varchar(25),		--13
						@p_sVolume varchar(12),		--14
						@p_sWeight varchar(12),		--15
						@p_sMiles varchar(12),		--16
						@p_sPieces varchar(12),		--17
						@p_ivh_revtype1 varchar(6),	--18
						@p_ivh_revtype2 varchar(6),	--19
						@p_ivh_revtype3 varchar(6),	--20
						@p_ivh_revtype4 varchar(6)	--21

AS	

/**
 * 
 * NAME:
 * dbo.tmail_Add_Accessorial3
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *  Inserts an accessorial charge in the invoicedetail table IF no invoice currently
 *  exists for the order number passed.  
 *
 * RETURNS:
 * 		1   	success
 *		-1	database error
 *		-2	invalid order number or order status (not AVL, PLN, DSP, STD or CMP) 
 *		-3	invalid charge type, or retired chargetype
 *		-4  	invoice exists, cannot add charge type
 *              -5	could not create invoiceheader number. Only fires if +1 flag is set.
 * 		-6	invalid input parameter
 *
 * RESULT SETS: 
 * none
 *
 * PARAMETERS:
 * 001 - @p_sOrdnumber      VARCHAR(12), input;
 *       TMWSuite order number the the accessorial is to be attached to. Required.
 * 002 - @p_sChargetype     VARCHAR(6), input;
 *       Charge type for accessorial. Required and must exist in TMWSuite.
 * 003 - @p_sQuantity  		VARCHAR(5), input;
 *       Quantity for accessorial
 * 004 - @p_sRate 			VARCHAR(5), input;
 *       Rate for accessorial (if not set, will use the rate for the selected ChargeType).
 * 005 - @p_sCompany      	VARCHAR(5), input;
 *       Company ID for accessorial
 * 006 - @p_sFlags		  	VARCHAR(5), input;
 *	 	+1 - Misc invoice (will create invoice header and attach the detail to it)
 * 007 - @p_trc_number	varchar(8), input
 * 008 - @p_driver1	varchar(8), input
 * 009 - @p_driver2	varchar(8), input
 * 010 - @p_trailer1	varchar(8), input
 * 011 - @p_ivh_billto	varchar(8), input
 *       The billto company id for this invoiceheader (only applies if +1 flag is set)
 * 012 - @p_date, varchar(25), input
 * 013 - @p_time, varchar(25), input
 * 014 - @p_sVolume	varchar(5), input
 * 015 - @p_sWeight	varchar(5), input
 * 016 - @p_sMiles	varchar(5), input
 * 017 - @p_sPieces	varchar(5), input
 * 018 - @p_ivh_revtyp1 varchar(6), input
 * 019 - @p_ivh_revtyp2 varchar(6), input
 * 020 - @p_ivh_revtyp3 varchar(6), input
 * 021 - @p_ivh_revtyp4 varchar(6), input
 *
 * REFERENCES:
 * dbo.tmail_CreateMiscInvoiceHeader2
 * dbo.getsystemnumber
 * dbo.tmw_log_error
 * 
 * REVISION HISTORY:
 * 03/24/2006.01 – PTS 31262 - David Gudat – initial version
 * 06/29/2006.01 - PTS       - MIZ - Created v2 to add the +1 flag as associated functionality.
 * 11/30/2006.01 - PTS 31449 - MIZ - Created v3 to add the inv_revtype parameters.
 *
 **/

SET NOCOUNT ON 

DECLARE 	@@vi_ivdnumber int, 
		@vi_ordhdrnumber int, 
		@vs_ordstatus varchar(6), 
		@vf_sum float, 
		@vs_CrLf varchar(2), 
		@vm_Rate money,
		@vi_flags int,
		@vi_ivh_hdrnumber int,
		@vs_ivh_hdrnumber varchar(15),
		@vf_totalweight float,
		@vf_totalpieces float,
		@vf_totalmiles float,
		@vf_totalvolume float,
		@vf_totalquantity float,
		@vm_totalcharge money,
		@vi_debug int

SET NOCOUNT ON

-- Initializations
SET @vi_ordhdrnumber = 0
SET @vs_ordstatus = ''
SET @vi_ivh_hdrnumber = 0
SET @vi_debug = 0	-- 0 = off, 1 = on
SELECT @vf_totalweight = 0, @vf_totalpieces = 0, @vf_totalmiles = 0, @vf_totalvolume = 0, @vf_totalquantity = 0

IF (@vi_debug > 0)
	SELECT 'INPUT PARMS' StepDesc, @p_sOrdnumber ord_number, @p_sChargetype chargetype, @p_sQuantity qty, @p_sRate rate, 
	@p_sCompany company, @p_sFlags flags, @p_trc_number trc_number, @p_driver1 driver1, 
	@p_driver2 driver2, @p_trailer1 trl1, @p_ivh_billto billto, @p_date Ddate, @p_time thyme, @p_sVolume vol, @p_sWeight wgt, @p_sMiles miles, @p_sPieces pcs

-- Validation
IF (ISNUMERIC(@p_sFlags) < 1)
	SET @vi_flags = 0
ELSE
	SET @vi_flags = CONVERT(int, @p_sFlags)

IF (ISNUMERIC(@p_sQuantity) > 0)
	SET @vf_totalquantity = CONVERT(float,@p_sQuantity)
ELSE
	SET @vf_totalquantity = 0

IF (ISNULL(@p_sVolume, '') <> '')
  BEGIN
	IF (ISNUMERIC(@p_sVolume) > 0)
		SET @vf_totalvolume = CONVERT(float, @p_sVolume)
	ELSE
	  BEGIN
		RAISERROR('Invalid Volume (%s).', 16, 1, @p_sVolume)
		RETURN -6
	  END
  END

IF (ISNULL(@p_sWeight,'') <> '')
  BEGIN
	IF (ISNUMERIC(@p_sWeight) > 0)
		SET @vf_totalweight = CONVERT(float, @p_sWeight)
	ELSE
	  BEGIN
		RAISERROR('Invalid Weight (%s).', 16, 1, @p_sWeight)
		RETURN -6
	  END
  END

IF (ISNULL(@p_sPieces,'') <> '')
  BEGIN
	IF (ISNUMERIC(@p_sPieces) > 0)
		SET @vf_totalpieces = CONVERT(float, @p_sPieces)
	ELSE
	  BEGIN
		RAISERROR('Invalid Pieces (%s).', 16, 1, @p_sPieces)
		RETURN -6
	  END
  END

IF (ISNULL(@p_sMiles,'') <> '') 
  BEGIN
	IF (ISNUMERIC(@p_sMiles) > 0)
		SET @vf_totalmiles = CONVERT(float, @p_sMiles)
	ELSE
	  BEGIN
		RAISERROR('Invalid Miles (%s).', 16, 1, @p_sMiles)
		RETURN -6
	  END
  END

IF (SELECT COUNT(*) 
	FROM chargetype (NOLOCK)
	where cht_itemcode = @p_sChargetype and ISNULL(cht_retired,'N') = 'N')  = 0
  BEGIN
	RAISERROR('Invalid ChargeType (%s).', 16, 1, @p_sChargeType)
	RETURN -3
  END

IF (ISNUMERIC(@p_sRate) > 0)
  BEGIN
	SET @vm_Rate = CONVERT(money, ISNULL(@p_sRate,0))	

	IF (@vm_Rate = 0)
		-- Rate was sent as zero, so pull it from the chargetype
		SELECT @vm_Rate = ISNULL(cht_rate,0)
		FROM chargetype (NOLOCK)
		WHERE cht_itemcode = @p_sChargeType
  END
ELSE
	-- We didn't send in a rate (or sent a non-numeric one), so get it from the ChargeType table.
	SELECT @vm_Rate = ISNULL(cht_rate,0)
	FROM chargetype (NOLOCK)
	WHERE cht_itemcode = @p_sChargeType

IF (@vi_debug > 0)
	SELECT 'Validating rate' StepDesc, @p_sRate RateParm, @p_sChargeType chargetype, @vm_Rate RateAfter

-- Calculate the total charge
SET @vm_totalcharge = (@vm_rate * @vf_totalquantity)

IF (@vi_debug > 0)
	SELECT 'Calc total charge' StepDesc, @vm_totalcharge TotalCharge

IF ISNULL(@p_sCompany, '') = ''
	SET @p_sCompany = 'UNKNOWN'

SET @p_ivh_billto = LTRIM(RTRIM(ISNULL(@p_ivh_billto,'')))
IF (@p_ivh_billto <> '')
  BEGIN
	IF NOT EXISTS (SELECT * 
					FROM company (NOLOCK)
					WHERE cmp_id = @p_ivh_billto)
	  BEGIN
		RAISERROR ('INVALID BILLTO (%s).', 16, 1, @p_ivh_billto)
		RETURN -6
	  END
  END

SET @p_ivh_revtype1 = UPPER(ISNULL(@p_ivh_revtype1,''))
SET @p_ivh_revtype2 = UPPER(ISNULL(@p_ivh_revtype2,''))
SET @p_ivh_revtype3 = UPPER(ISNULL(@p_ivh_revtype3,''))
SET @p_ivh_revtype4 = UPPER(ISNULL(@p_ivh_revtype4,''))

IF (@vi_flags & 1) = 1
  BEGIN  
	IF (@vi_debug > 0)
		SELECT 'In MiscInvoice' StepDesc

	-- Create the invoice header for the misc invoice
	EXEC dbo.tmail_CreateMiscInvoiceHeader2	@p_trc_number,
						@p_driver1,
						@p_driver2,
						@p_trailer1,
						@p_ivh_billto,
						@vf_totalquantity,
						@vf_totalvolume,
						@vf_totalweight,
						@vf_totalmiles,
						@vf_totalpieces,
						@p_date,
						@p_time,
						'',
						@vm_totalcharge,
						@vi_ivh_hdrnumber OUT,
						@p_ivh_revtype1,
						@p_ivh_revtype2,
						@p_ivh_revtype3,
						@p_ivh_revtype4

	IF (@vi_debug > 0)
		SELECT 'Just tried to create invoiceheader' StpeDesc, @vi_ivh_hdrnumber ivh_hdrnumber

	IF (@vi_ivh_hdrnumber < 1) 
	  BEGIN
		RAISERROR('Could not create invoiceheader.', 16, 1)
		RETURN -5
	  END
  END
ELSE
  BEGIN
	IF (@vi_debug > 0)
		SELECT 'In standard route (not misc invoice' StepDesc

	-- Not creating a misc invoice, so validate order number and status.
	SELECT  @vi_ordhdrnumber = ISNULL(ord_hdrnumber,0), 
		@vs_ordstatus = ISNULL(ord_status,'')
	FROM orderheader (NOLOCK) 
	WHERE ord_number = @p_sOrdnumber

	IF (@vi_debug > 0)
		SELECT 'Order info' StepDesc, @vi_ordhdrnumber ord_hdrnumber, @vs_ordstatus ord_status

	IF (@vi_ordhdrnumber IS NULL) 
	  BEGIN
		RAISERROR('Invalid order number (%s).', 16, 1, @p_sOrdnumber)
		RETURN -2
	  END

	IF (@vs_ordstatus NOT IN ('AVL','PLN','DSP','STD','CMP'))
	  BEGIN
		RAISERROR('Invalid order status (%s)', 16, 1, @vs_ordstatus)
		RETURN -2
	  END

	IF (SELECT COUNT(*)
		 FROM invoiceheader (NOLOCK)
		 WHERE ord_hdrnumber = @vi_ordhdrnumber) > 0 
	  BEGIN
		RAISERROR('Invoice exists for order %s', 16, 1, @p_sOrdnumber)
		RETURN -4
	  END

	IF (@p_ivh_billto = '')
		SET @p_ivh_billto = 'UNKNOWN'
  END

EXEC @@vi_ivdnumber = dbo.getsystemnumber 'INVDET',NULL 
IF @@error <> 0 RETURN -1

IF (@vi_debug > 0)
	SELECT 'Got new ivd_number' StepDesc, @@vi_ivdnumber ivd_number

INSERT INTO invoicedetail (
		ivh_hdrnumber,				--1
		ivd_number,
		stp_number,
		ivd_description,
		cht_itemcode,				--5
		ivd_quantity,
		ivd_rate,
		ivd_charge,
		ivd_taxable1,
		ivd_taxable2,				--10
		ivd_taxable3,
		ivd_taxable4,
		ivd_unit,
		cur_code,
		ivd_currencydate,			--15
		ivd_glnum,
		ord_hdrnumber,
		ivd_type,
		ivd_rateunit,
		ivd_billto,				--20
		ivd_itemquantity,
		ivd_subtotalptr,
		ivd_allocatedrev,
		ivd_sequence,
		ivd_invoicestatus,			--25
		mfh_hdrnumber,
		ivd_refnum,
		cmd_code,
		cmp_id,
		ivd_distance,				--30
		ivd_distunit,
		ivd_wgt,
		ivd_wgtunit,
		ivd_count,
		ivd_countunit,				--35
		evt_number,
		ivd_reftype,
		ivd_volume,
		ivd_volunit,
		ivd_orig_cmpid,				--40
		ivd_payrevenue,
		ivd_sign,
		ivd_length,
		ivd_lengthunit,
		ivd_width,				--45
		ivd_widthunit,
		ivd_height,
		ivd_heightunit,
		ivd_exportstatus,
		cht_basisunit,				--50
		ivd_remark,
		tar_number,
		tar_tariffnumber,			
		tar_tariffitem,
		ivd_fromord,				--55
		ivd_zipcode,
		ivd_quantity_type,
		cht_class,
		ivd_mileagetable,
		ivd_charge_type,			--60
		ivd_trl_rent,
		ivd_trl_rent_start,
		ivd_trl_rent_end,
		ivd_rate_type,
		cht_lh_min,				--65
		cht_lh_rev,
		cht_lh_stl,
		cht_lh_rpt,
		cht_rollintolh,
		cht_lh_prn,				--70
		fgt_number,
		ivd_paylgh_number,
		ivd_tariff_type,
		ivd_taxid,
		ivd_ordered_volume,			--75
		ivd_ordered_loadingmeters,
		ivd_ordered_count,
		ivd_ordered_weight,
		ivd_loadingmeters,
		ivd_loadingmeters_unit,			--80
		last_updateby,
		last_updatedate,
		ivd_revtype1,
		ivd_hide)				--84
SELECT 		@vi_ivh_hdrnumber,			--1 ivh_hdrnumber
		@@vi_ivdnumber,				-- ivd_number
		null,					-- stp_number
		cht_description,			-- ivd_description
		cht_itemcode,				--5 cht_itemcode
		@vf_totalquantity,			-- ivd_quantity
		@vm_Rate,				-- ivd_rate
		@vm_totalcharge,			-- ivd_charge
		cht_taxtable1,				-- ivd_taxable1
		cht_taxtable2,				--10 ivd_taxable2
		cht_taxtable3,				-- ivd_taxable3
		cht_taxtable4, 				-- ivd_taxable4
		cht_unit,				-- ivd_unit
		cht_currunit,				-- cur_code
		GETDATE(),				--15 ivd_currencydate
		cht_glnum,				-- ivd_glnum
		@vi_ordhdrnumber,			-- ord_hdrnumber
		'LI',					-- ivd_type
		cht_rateunit,				-- ivd_rateunit
		@p_ivh_billto,				--20 ivd_billto 
		0,					-- ivd_itemquantity
		0,					-- ivd_subtotalptr
		null,					-- ivd_allocatedrev
		999,					-- ivd_sequence
		'HLD',					--25 ivd_invoicestatus   Always create new invoicedetails with a HOLD status.
		null,					-- mfh_hdrnumber
		null,					-- ivd_refnum
		'UNKNOWN',				-- cmd_code
		@p_sCompany,				-- cmp_id
		@vf_totalmiles,				--30 ivd_distance
		'MIL',					-- ivd_distunit
		@vf_totalweight,			-- ivd_wgt
		'LBS',					-- ivd_wgtunit
		@vf_totalpieces,			-- ivd_count
		'PCS',					--35 ivd_countunit
		null,					-- evt_number
		'REF',					-- ivd_reftype
		@vf_totalvolume,			-- ivd_volume
		'CUB',					-- ivd_volunit
		null,					--40 ivd_orig_cmpid
		null,					-- ivd_payrevenue
		cht_sign,				-- ivd_sign
		null,					-- ivd_length
		null,					-- ivd_lengthunit
		null,					--45 ivd_width
		null,					-- ivd_widthunit
		null,					-- ivd_height
		null,					-- ivd_heightunit
		null,					-- ivd_exportstatus
		cht_basisunit,				--50 cht_basisunit
		null,					-- ivd_remark
		null,					-- tar_number
		null,					-- tar_tariffnumber
		null,					-- tar_tariffitem
		'Y',					--55 ivd_fromord ???
		null,					-- ivd_zipcode
		0,					-- ivd_quantity_type
		cht_class,				-- cht_class
		null,					-- ivd_mileagetable
		0,					--60 ivd_charge_type
		null,					-- ivd_trl_rent
		null,					-- ivd_trl_rent_start
		null,					-- ivd_trl_rent_end
		0,					-- ivd_rate_type
		'N',					--65 cht_lh_min
		'N',					-- cht_lh_rev
		'N',					-- cht_lh_stl
		'N',					-- cht_lh_rpt
		0, 					-- cht_rollintolh
		null,					--70 cht_lh_prn
		null,					-- fgt_number
		null,					-- ivd_paylgh_number
		null,					-- ivd_tariff_type
		null,					-- ivd_taxid
		0,					--75 ivd_ordered_volume
		0, 					-- ivd_ordered_loadingmeters
		0,					-- ivd_ordered_count
		0,					-- ivd_ordered_weight
		0,					-- ivd_loadingmeters
		null,					--80 ivd_loadingmeters_unit
		'TMAIL',				-- last_updateby
		GETDATE(),				-- last_updatedate
		'UNK',					-- ivd_revtype1
		null					--84 ivd_hide
	FROM chargetype (NOLOCK) 
	WHERE cht_itemcode = @p_sChargetype

IF @@error<>0
  BEGIN
	SET @vs_ivh_hdrnumber = CONVERT(varchar(25), @vi_ivh_hdrnumber)

	IF (@vi_debug > 0)
		SELECT 'Invoicedetail creation failed' StepDesc, @vi_ivh_hdrnumber ivh_hdrnumber

	IF (@vi_flags & 1) = 1
	  BEGIN
		IF (@vi_debug > 0)
			SELECT 'Invoicedetail creation failed. Delete invoiceheader ' + @vs_ivh_hdrnumber

		-- Didn't create the invoicedetail, so roll back the invoiceheader creation
		DELETE invoiceheader
		WHERE ivh_hdrnumber = @vi_ivh_hdrnumber
	  END

	EXEC dbo.tmw_log_error 0, 'tmail_Add_Accessorial Failed', @@error, ''
	SET @vs_CrLf = CHAR(13) + CHAR(10)
	SET @vs_ivh_hdrnumber = CONVERT(varchar(25), @vi_ivh_hdrnumber)
	RAISERROR('Error adding accessorial for order (%s), invoiceheader (%s)%s%s', 16, 1, @p_sOrdnumber, @vs_ivh_hdrnumber, @vs_CrLf, @@Error)
    RETURN -1
  END

IF (@vi_debug > 0)
	SELECT 'Invoicedetail creation succeeded' StepDesc, @vi_ivh_hdrnumber ivh_hdrnumber

IF (@vi_flags & 1) = 0
  BEGIN
	/* Reset order totals */
	SELECT @vf_sum = SUM(ivd_charge)
	FROM invoicedetail (NOLOCK)
	WHERE ord_hdrnumber = @vi_ordhdrnumber
	
	UPDATE orderheader 
	SET ord_accessorial_chrg = @vf_sum,ord_totalcharge = (ord_charge + @vf_sum)
	WHERE ord_hdrnumber = @vi_ordhdrnumber 
  END

RETURN 1
GO
GRANT EXECUTE ON  [dbo].[tmail_Add_Accessorial3] TO [public]
GO
