SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[process_driver_advance] (@mov_number integer, @debug integer = 0)
AS
SET NOCOUNT ON
DECLARE @drv_eligible CHAR (1), 
		@curr_lgh INTEGER,
		@min_lgh INTEGER,
		@drv_pct DECIMAL (5,2),
		@cmp_pct DECIMAL (5,2),
		@status CHAR (6),
		@ord INTEGER,
		@billto CHAR (8), @shipper CHAR (8),
		@payback MONEY, @max_payback MONEY, @pyt_item CHAR (6),
		@advance_amount MONEY, 
		@drv CHAR (8), @asgn_number INTEGER, 
		@extra_mpp_id INTEGER, @extra_cmp_id INTEGER, 
		@extra_mpp_tab INTEGER, @extra_cmp_tab INTEGER,
		@extra_mpp_elig INTEGER, 
		@extra_mpp_pct INTEGER, @extra_cmp_pct INTEGER ,
		/*@sdm_payback CHAR (6),*/ @payback_balance MONEY, @payback_end MONEY,
		@pa_id INTEGER, @total_pay MONEY, @pyt_fee1 MONEY, @trc char (13), 
		@crd_cardnumber varchar (20), @crd_accountid varchar (10), @crd_customerid varchar (10), 
		@message varchar (250), @status_code integer
SELECT @min_lgh = 0, @curr_lgh = 0
SELECT @extra_cmp_id = extra_id FROM EXTRA_INFO_HEADER WHERE TABLE_NAME = 'company'
SELECT @extra_mpp_id = extra_id FROM EXTRA_INFO_HEADER WHERE TABLE_NAME = 'driver'
SELECT top 1 @extra_cmp_pct = COL_ID, @extra_cmp_tab = TAB_ID FROM EXTRA_INFO_COLS WHERE EXTRA_ID = @extra_cmp_id AND LEFT (COL_NAME, 15) = 'Advance Percent'
---SELECT top 1 @extra_mpp_pct = COL_ID, @extra_mpp_tab = TAB_ID FROM EXTRA_INFO_COLS WHERE EXTRA_ID = @extra_mpp_id AND LEFT (COL_NAME, 15) = 'Advance Percent'
SELECT top 1 @extra_mpp_elig = COL_ID, @extra_mpp_tab = TAB_ID FROM EXTRA_INFO_COLS WHERE EXTRA_ID = @extra_mpp_id AND COL_NAME = 'NO Advance'
SELECT @pyt_item = LEFT(gi_string1,6), @max_payback = CAST (gi_string2 as money) FROM generalinfo WHERE gi_name = 'ProcessDriverAdvance' 
---select @extra_cmp_id ,@extra_cmp_pct ,@extra_mpp_id ,@extra_mpp_bond ,@extra_mpp_elig ,@extra_mpp_pct 

IF @extra_cmp_id IS NULL or @extra_mpp_id IS NULL or @extra_cmp_pct IS NULL or @extra_mpp_elig IS NULL /* or @extra_mpp_pct IS NULL */
BEGIN
	RAISERROR ('Missing extra info configuration for process_driver_advance.', 16, 41)
	RETURN
END
IF @pyt_item is null or @max_payback is null
BEGIN
	RAISERROR ('Missing GI configuration for process_driver_advance.', 16, 41)
	RETURN
END

SELECT @pyt_fee1 = pyt_fee1 FROM paytype where pyt_itemcode = @pyt_item

SELECT @curr_lgh = lgh_number FROM legheader WHERE mov_number = @mov_number AND lgh_number > @min_lgh
WHILE @curr_lgh > 0 
BEGIN
	SELECT @payback_end = NULL, @payback_balance = NULL,
         @drv_eligible=NULL, @drv_pct=NULL, @asgn_number=NULL, @pa_id = NULL, 
         @total_pay = null,@crd_cardnumber=NULL, @crd_accountid=NULL, @crd_customerid=NULL,
         @payback=null, @message=NULL
	SELECT @drv = l.lgh_driver1, @ord = o.ord_hdrnumber, @status = l.lgh_outstatus, 
	       @billto = o.ord_billto, @shipper = o.ord_shipper, @trc = l.lgh_tractor
		FROM legheader l join orderheader o on l.ord_hdrnumber = o.ord_hdrnumber 
		WHERE l.lgh_number = @curr_lgh
	SELECT @status_code = code 
		FROM labelfile
		WHERE labeldefinition = 'DispStatus'
		  AND abbr = @status
	SELECT @asgn_number = asgn_number FROM assetassignment
		WHERE asgn_type = 'DRV' and asgn_id = @drv AND mov_number = @mov_number and lgh_number = @curr_lgh and asgn_controlling = 'Y'
	IF @debug > 0
		PRINT 'Processing Leg ' + CAST (@curr_lgh as varchar (10)) + ' Driver ' + @drv + ', Tractor ' + @trc + ', Bill To ' + @billto
	IF @drv = 'UNKNOWN' OR (@status_code <= 210 or @status_code >= 400)
	BEGIN
		SELECT @min_lgh = @curr_lgh, @curr_lgh = 0
		SELECT @curr_lgh = lgh_number FROM legheader WHERE mov_number = @mov_number AND lgh_number > @min_lgh
		CONTINUE
	END	
	SELECT TOP 1 @drv_eligible = LEFT (col_data, 1) FROM EXTRA_INFO_DATA
		WHERE EXTRA_ID = @extra_mpp_id AND TAB_ID = @extra_mpp_tab AND COL_ID = @extra_mpp_elig AND TABLE_KEY = @drv 
--	SELECT TOP 1 @drv_pct = CAST (REPLACE(col_data, '%', '') as integer) FROM EXTRA_INFO_DATA
--		WHERE EXTRA_ID = @extra_mpp_id AND TAB_ID = @extra_mpp_tab AND COL_ID = @extra_mpp_pct AND TABLE_KEY = @drv 
SELECT TOP 1 @cmp_pct = CAST (REPLACE( CASE col_data WHEN '.' THEN NULL else col_data END, '%', '') as integer) FROM EXTRA_INFO_DATA
		WHERE EXTRA_ID = @extra_cmp_id AND TAB_ID = @extra_cmp_tab AND COL_ID = @extra_cmp_pct AND TABLE_KEY = @billto
	--- Set defaults
	IF @cmp_pct IS NULL 
		SELECT @cmp_pct = 45
	IF @drv_eligible IS NULL
		SELECT @drv_eligible = 'N'
	IF @cmp_pct > 100 
		SELECT @cmp_pct = 100
	IF @drv_pct > 100 
		SELECT @drv_pct = 100
	IF @drv_pct is null
		SELECT @drv_pct = @cmp_pct
		
	-- Remove old drivers pending advances
	IF @asgn_number IS NULL
		DELETE FROM pendingadvances 
			WHERE lgh_number = @curr_lgh AND pa_status = 'U'
	ELSE
		DELETE FROM pendingadvances 
			WHERE asgn_number <> @asgn_number AND pa_status = 'U' AND lgh_number = @curr_lgh
		
	SELECT @pa_id = pa_id
		FROM pendingadvances
		WHERE pa_status in ('U','X')
		AND lgh_number = @curr_lgh
		AND mov_number = @mov_number 

	--- Driver eligible?
	IF @drv_eligible = 'Y' OR @drv = 'UNKNOWN' OR @status NOT IN ('PLN','DSP','STD') or @asgn_number is null 
	BEGIN
		SELECT @message = 'Driver ' + @drv + ' is inelgible for advances. Order status: ' + @status + ' Eligible:' + ISNull (@drv_eligible, 'N')
		if @debug > 0 
			PRINT @message
			
		IF @pa_id IS NULL
			INSERT INTO pendingadvances (asgn_number, asgn_type, asgn_id, pyt_itemcode, pa_amount, pa_status, lgh_number,
			 mov_number, created_date, pa_pay, pa_payback, pa_processing_message)
			VALUES (@asgn_number, 'DRV', @drv, @pyt_item, @advance_amount, 'X', @curr_lgh, 
				@mov_number, CURRENT_TIMESTAMP, @total_pay, @payback, @message)
		ELSE
			UPDATE pendingadvances
				SET pa_amount = @advance_amount, pa_pay = @total_pay, pa_payback = @payback,
						pa_processing_message = @message, pa_status = 'X', update_date = CURRENT_TIMESTAMP, 
						asgn_number = @asgn_number, asgn_id = @drv, pa_fee = @pyt_fee1
				WHERE pa_id = @pa_id

		SELECT @min_lgh = @curr_lgh, @curr_lgh = 0
		SELECT @curr_lgh = lgh_number FROM legheader WHERE mov_number = @mov_number AND lgh_number > @min_lgh
		CONTINUE
	END
	
	--- Check to see if advance has already been paid
	IF EXISTS (SELECT pa_id FROM pendingadvances WHERE asgn_number = @asgn_number AND pa_status not in ('U','X'))
	BEGIN
		SELECT @message = 'Driver ' + @drv + ' has already been issued an advance.'
		if @debug > 0 
			PRINT @message
		SELECT @min_lgh = @curr_lgh, @curr_lgh = 0
		SELECT @curr_lgh = lgh_number FROM legheader WHERE mov_number = @mov_number AND lgh_number > @min_lgh
		CONTINUE
	END
	
	--- Check percent
	IF @drv_pct > @cmp_pct or @drv_pct = 0
		SELECT @drv_pct = @cmp_pct 
		
	--- Check for payback
	--SELECT top 1 @payback_balance = SUM(std_balance), @payback_end = SUM (std_endbalance)
	--	FROM standingdeduction 
	--	where sdm_itemcode = @sdm_payback AND asgn_type = 'DRV' and asgn_id = @drv AND std_status <> 'CLD'
	--IF @payback_balance IS NOT NULL and @payback_end IS NOT NULL
	select @payback_balance = sum (pyd_amount)
	from paydetail
		where asgn_type='DRV' and asgn_id=@drv 
		and pyt_itemcode = 'MN-'
		and pyh_number = 0
	IF @payback_balance IS NOT NULL and @payback_balance < 0
	BEGIN
		if @debug > 0 
			PRINT 'Payback Balance = ' +  CAST (@payback_balance AS varchar (15))
		IF @payback_balance <= -@max_payback 
		BEGIN
			SELECT @message = 'Driver ' + @drv + ' is inelgible for advances because of payback balance of ' + CAST (-@payback_balance as varchar (10))
			if @debug > 0 
				PRINT @message
			
			IF @pa_id IS NULL
				INSERT INTO pendingadvances (asgn_number, asgn_type, asgn_id, pyt_itemcode, pa_amount, pa_status, lgh_number,
				 mov_number, created_date, pa_pay, pa_payback, pa_processing_message)
				VALUES (@asgn_number, 'DRV', @drv, @pyt_item, @advance_amount, 'X', @curr_lgh, 
					@mov_number, CURRENT_TIMESTAMP, @total_pay, @payback_balance, @message)
		ELSE
			UPDATE pendingadvances
				SET pa_amount = @advance_amount, pa_pay = @total_pay, pa_payback = @payback_balance,
						pa_processing_message = @message, pa_status = 'X', update_date = CURRENT_TIMESTAMP, 
						asgn_number = @asgn_number, asgn_id = @drv, pa_fee = @pyt_fee1
				WHERE pa_id = @pa_id

			SELECT @min_lgh = @curr_lgh, @curr_lgh = 0
			SELECT @curr_lgh = lgh_number FROM legheader WHERE mov_number = @mov_number AND lgh_number > @min_lgh
			CONTINUE
		END
		SELECT @payback = @payback_balance
	END
	
	--- Calculate the amount of advance
	IF @debug > 0 
		PRINT 'Calculating advance'
	SELECT @total_pay = SUM(pyd_amount)
		FROM paydetail
		WHERE asgn_id = @drv and @asgn_number = asgn_number and asgn_type = 'DRV'
		  AND mov_number = @mov_number and lgh_number = @curr_lgh
	IF @total_pay IS NULL 
		SELECT @total_pay = 0
	IF @total_pay > 0 
	BEGIN
		SELECT @advance_amount = round (@total_pay * (CAST (@drv_pct AS Money) / 100.0), 2)
		IF @advance_amount <= 0 
			SELECT @advance_amount = NULL
		if @debug > 0 
			PRINT 'Advance amount calculated: ' + ISNULL (CAST (@advance_amount as varchar (15)), '<None>')
	END
	ELSE
	BEGIN
		SELECT @message = 'Driver ' + @drv + ' has no pay.'
		if @debug > 0 
			PRINT @message
	END
	
	--- Create/update advance
	SELECT TOP 1 @crd_cardnumber=crd_cardnumber, @crd_accountid=crd_accountid, @crd_customerid=crd_customerid
		FROM cashcard 
		  WHERE (crd_driver = @drv OR crd_unitnumber = @trc) 
		  AND crd_status = 'ACTIVE' AND crd_vendor = 'TCHI'
	IF @@ROWCOUNT = 0 AND @debug > 0
		PRINT 'WARNING! No cash card found for ' + @drv

	IF @pa_id IS NULL AND @advance_amount IS NOT NULL AND @advance_amount > 0 
	BEGIN
		INSERT INTO pendingadvances (asgn_number, asgn_type, asgn_id, pyt_itemcode, pa_amount, pa_status, lgh_number,
					 mov_number, created_date, crd_accountid, crd_customerid, crd_cardnumber, pa_fee, pa_pay, pa_payback, 
					 pa_processing_message, pa_advance_percent)
			VALUES (@asgn_number, 'DRV', @drv, @pyt_item, @advance_amount, 'U', @curr_lgh, 
				@mov_number, CURRENT_TIMESTAMP, @crd_accountid, @crd_customerid, @crd_cardnumber, @pyt_fee1, @total_pay, @payback, 
				@message, @drv_pct)
		if @debug > 0
			PRINT 'Advance inserted, id ' + cast (SCOPE_IDENTITY() AS varchar (10))
	END 
	ELSE IF @advance_amount IS NOT NULL AND @advance_amount > 0 
	BEGIN
		UPDATE pendingadvances
			SET pa_amount = @advance_amount, crd_cardnumber=@crd_cardnumber, crd_accountid=@crd_accountid, crd_customerid=@crd_customerid,
					pa_pay = @total_pay, pa_payback = @payback, pa_processing_message = @message, pa_status = 'U',
					update_date = CURRENT_TIMESTAMP, pa_advance_percent = @drv_pct, 
						asgn_number = @asgn_number, asgn_id = @drv, pa_fee = @pyt_fee1
			WHERE pa_id = @pa_id
		if @debug > 0
			PRINT 'Advance updated, id ' + cast (@pa_id AS varchar (10))
	END	
	ELSE
	BEGIN
		IF @pa_id IS NULL
			INSERT INTO pendingadvances (asgn_number, asgn_type, asgn_id, pyt_itemcode, pa_amount, pa_status, lgh_number,
			 mov_number, created_date, pa_pay, pa_payback, pa_processing_message, pa_advance_percent)
			VALUES (@asgn_number, 'DRV', @drv, @pyt_item, @advance_amount, 'X', @curr_lgh, 
				@mov_number, CURRENT_TIMESTAMP, @total_pay, @payback, @message, @drv_pct)
		ELSE
			UPDATE pendingadvances
				SET pa_amount = @advance_amount, pa_pay = @total_pay, pa_payback = @payback,
						pa_processing_message = @message, pa_status = 'X', update_date = CURRENT_TIMESTAMP, 
						pa_advance_percent = @drv_pct, 
						asgn_number = @asgn_number, asgn_id = @drv, pa_fee = @pyt_fee1
				WHERE pa_id = @pa_id
	END
	
	--- Loop foor splits
	SELECT @min_lgh = @curr_lgh, @curr_lgh = 0
	SELECT @curr_lgh = lgh_number FROM legheader WHERE mov_number = @mov_number AND lgh_number > @min_lgh
END

		
GO
GRANT EXECUTE ON  [dbo].[process_driver_advance] TO [public]
GO
