SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[release_purchaseservice_sp] 
		@psd_number int , 
		@paydate datetime,
		@checkdate datetime,
		@payschedule_id int,
		@pyd_ref_invoice varchar(15),
		@pyd_ref_invoicedate datetime
AS
DECLARE @psh_vendor_id varchar(12),
        @pyd_number int,
        @stp_number int,
        @cmp_id varchar(8),
        @psd_type varchar(8),
        @pyt_itemcode varchar(6),
        @psd_rate money,
        @psd_qty float,
        @psh_number int,
        @pyt_minus char(1),
        @pyt_pretax char(1),
        @pyt_rateunit varchar(6),
        @pyt_unit varchar(6),
        @pyd_minus int,
        @pyt_description varchar(30),
		@ord_hdrnumber int,
		@lgh_number int

--PTS 55626 JJF 20110819 - move lower
--EXECUTE @pyd_number = getsystemnumber 'PYDNUM',''
--END PTS 55626 JJF 20110819 - move lower

SELECT @psh_number = psh_number,
                  @psd_type = psd_type,
                  @psd_rate = psd_rate,
                  @psd_qty = psd_qty
     FROM purchaseservicedetail
 WHERE psd_number = @psd_number

SELECT	@stp_number = stp_number,
		@psh_vendor_id = psh_vendor_id,
		@ord_hdrnumber = ord_hdrnumber
     FROM purchaseserviceheader
 WHERE psh_number = @psh_number

SELECT @cmp_id = cmp_id
     FROM stops
 WHERE stp_number = @stp_number

IF ISNULL(@stp_number, 0) <> 0
BEGIN
	SELECT	@lgh_number = lgh_number
	  FROM	stops
	 WHERE	stp_number = @stp_number
END
ELSE IF ISNULL(@ord_hdrnumber, 0) <> 0
BEGIN
	SELECT	@lgh_number = MIN(lgh_number)
	  FROM	stops 
	 WHERE	ord_hdrnumber = @ord_hdrnumber
END

IF @cmp_id IS NULL or @cmp_id = ' '
BEGIN
     SET @cmp_id = @psh_vendor_id
END

SELECT @pyt_itemcode = pyt_itemcode
     FROM labelfile
 WHERE labeldefinition = 'PurchaseService' AND
                   abbr = @psd_type
SELECT @pyt_minus = pyt_minus,
                  @pyt_pretax = pyt_pretax,
                  @pyt_rateunit = pyt_rateunit,
                  @pyt_unit = pyt_unit,
                  @pyt_description = pyt_description
     FROM paytype
 WHERE pyt_itemcode = @pyt_itemcode
IF @pyt_minus = 'N'
     SET @pyd_minus = 1
IF @pyt_minus = 'Y'
     SET @pyd_minus = 0

--PTS 55626 JJF 20110819 
IF EXISTS	(	SELECT	*
				FROM	paydetail
				WHERE	psd_number = @psd_number
			) BEGIN
			                                                  
	UPDATE	paydetail
	SET		asgn_id = @cmp_id,
			pyd_payto = @psh_vendor_id,
			pyt_itemcode = @pyt_itemcode,
			pyd_quantity = @psd_qty,
			pyd_rate = @psd_rate,
			pyd_amount = @psd_qty * @psd_rate,
			pyh_payperiod = @paydate,
			--pyd_status = 'PND',
			--pyh_number = 0,
			pyd_minus = @pyd_minus,
			pyd_pretax = @pyt_pretax,
			pyd_rateunit = @pyt_rateunit,
			pyd_unit = @pyt_unit,
			pyd_description = @pyt_description,
			pyd_ref_invoice = @pyd_ref_invoice,
			pyd_ref_invoicedate = @pyd_ref_invoicedate,
			ord_hdrnumber = @ord_hdrnumber,
			lgh_number = @lgh_number
	WHERE	psd_number = @psd_number
END
ELSE BEGIN

	EXECUTE @pyd_number = getsystemnumber 'PYDNUM',''
	INSERT INTO paydetail (pyd_number, asgn_type, asgn_id, pyd_payto, pyt_itemcode, pyd_quantity,
													  pyd_rate, pyd_amount, pyh_payperiod, psd_number, pyd_status, pyh_number,
													  pyd_minus, pyd_pretax, pyd_rateunit, pyd_unit, pyd_description, pyd_ref_invoice,
													  pyd_ref_invoicedate, ord_hdrnumber, lgh_number)
									  values (@pyd_number, 'TPR', @cmp_id, @psh_vendor_id, @pyt_itemcode, @psd_qty,
													  @psd_rate, @psd_qty * @psd_rate, @paydate, @psd_number,'PND', 0,
													  @pyd_minus, @pyt_pretax, @pyt_rateunit, @pyt_unit, @pyt_description, @pyd_ref_invoice,
													  @pyd_ref_invoicedate, @ord_hdrnumber, @lgh_number)
END
--INSERT INTO paydetail (pyd_number, asgn_type, asgn_id, pyd_payto, pyt_itemcode, pyd_quantity,
--                                                  pyd_rate, pyd_amount, pyh_payperiod, psd_number, pyd_status, pyh_number,
--                                                  pyd_minus, pyd_pretax, pyd_rateunit, pyd_unit, pyd_description, pyd_ref_invoice,
--                                                  pyd_ref_invoicedate, ord_hdrnumber, lgh_number)
--                                  values (@pyd_number, 'TPR', @cmp_id, @psh_vendor_id, @pyt_itemcode, @psd_qty,
--                                                  @psd_rate, @psd_qty * @psd_rate, @paydate, @psd_number,'PND', 0,
--                                                  @pyd_minus, @pyt_pretax, @pyt_rateunit, @pyt_unit, @pyt_description, @pyd_ref_invoice,
--                                                  @pyd_ref_invoicedate, @ord_hdrnumber, @lgh_number)

--END PTS 55626 JJF 20110819 - move lower


GO
GRANT EXECUTE ON  [dbo].[release_purchaseservice_sp] TO [public]
GO
