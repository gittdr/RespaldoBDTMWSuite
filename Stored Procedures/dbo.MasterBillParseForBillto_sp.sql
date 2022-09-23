SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[MasterBillParseForBillto_sp]
	@billto		varchar(8)
AS

/**
 * NAME:		dbo.MasterBillParseForBillto_sp
 * TYPE:		StoredProcedure
 * DESCRIPTION:	This storec procedure is created for PTS #66113 to be called when creating a master bill for a specific bill to.
 *	
 * RETURNS:		None
 * REVISION HISTORY:	BY			DATE			DESCRIPTION
 *						NQIAO		02/20/2013		Created for PTS #66113
 *
 *
 *
 **/


DECLARE	@CmpInvDetailCnt TABLE	(
		ivh_billto				varchar(8),
		ivh_mb_customgroupby	varchar(60),
		cmp_mb_breaktype		varchar(8),
		cmp_mb_breakvalue		int,
		detailcount				int)

DECLARE @BreakInvoices TABLE	(
		ivh_hdrnumber			int,
		ivh_mb_customgroupby	varchar(60))
		
		
DECLARE @SelectInvoices TABLE	(
		ivh_hdrnumber			int,
		ivh_totalcharge			money)

DECLARE @UpdateInvoices table	(
		ivh_hdrnumber			int,
		ivh_mb_customgroupby	varchar(60))				

DECLARE	@customgroupby				varchar(60),
		@cmp_mastercompany			varchar(8),
		@cmp_mb_breaktype			varchar(8),
		@cmp_mb_breakvalue			int,
		@parent_mb_breaktype		varchar(8),
		@parent_mb_breakvalue		int,
		@count						int,
		@ivh_hdrnumber				int,
		@breaknumber				int,
		@detailcount				int,
		@totalamount				money,
		@totalinvoices				int,
		@orig_sum					money,
		@ivh_totalcharge			money,
		@ivh_totalcharge_sum		money,
		@invoicecount				int


SELECT	@cmp_mastercompany = ISNULL(cmp_mastercompany, ''),
		@cmp_mb_breaktype  = ISNULL(cmp_mb_breaktype, ''),
		@cmp_mb_breakvalue = ISNULL(cmp_mb_breakvalue, 0)
FROM	company
WHERE	cmp_id = @billto
AND		cmp_active = 'Y'
AND		cmp_billto = 'Y'
AND		cmp_invoicetype = 'MAS'


IF @@rowcount = 0 -- no company to process
	Return;

IF @cmp_mastercompany > '' AND LEFT(@cmp_mastercompany, 3) <> 'UNK'
	SELECT	@parent_mb_breaktype  = ISNULL(cmp_mb_breaktype, ''),
			@parent_mb_breakvalue = ISNULL(cmp_mb_breakvalue, 0)
	FROM	company
	WHERE	cmp_id = @cmp_mastercompany
	AND		cmp_active = 'Y'
	AND		cmp_billto = 'Y'
	AND		cmp_invoicetype = 'MAS'

IF @parent_mb_breaktype > '' AND LEFT(@parent_mb_breaktype, 3) <> 'UNK' AND @parent_mb_breakvalue > 0  -- override with parent company's setting
	SELECT	@cmp_mb_breaktype = @parent_mb_breaktype,
			@cmp_mb_breakvalue = @parent_mb_breakvalue

IF @cmp_mb_breaktype = '' OR LEFT(@cmp_mb_breaktype, 3) = 'UNK' OR @cmp_mb_breakvalue = 0
	Return;
	
IF @cmp_mb_breaktype = 'CHARGES'	AND @cmp_mb_breakvalue > 0	
BEGIN	-- break down on total number of billable line charges <begin>
	-- the invoiceheader.ivh_mb_customgroupby has been populated by customerized invoice validation stored procedure
	-- e.g. 'billing_validation_kvs_sp' fro KVS, this stored procedure is to break based on the value in cmp_mb_breakvalue
	-- reset the break if already assigned
	UPDATE	ivh
	SET		ivh_mb_customgroupby =	CASE CHARINDEX('`', ivh_mb_customgroupby)
										WHEN 0 THEN ivh_mb_customgroupby
										ELSE LEFT(ivh_mb_customgroupby, CHARINDEX('`', ivh_mb_customgroupby)-1)
									END
	FROM	invoiceheader ivh
			JOIN	
			invoicedetail ivd ON ivh.ivh_hdrnumber = ivd.ivh_hdrnumber AND ivd.ivd_charge <> 0
	WHERE	ivh.ivh_billto = @billto
	AND		ivh_mbstatus = 'RTP' 
	AND		ISNULL(ivh.ivh_mb_customgroupby, '') > ''

	-- get billable detail line count for the @billto
	SELECT	@count = COUNT(ivd_number)
	FROM	invoicedetail ivd
			JOIN
			invoiceheader ivh ON ivd.ivh_hdrnumber = ivh.ivh_hdrnumber
	WHERE	ivh.ivh_billto = @billto
	AND		ivh_mbstatus = 'RTP' 
	AND		ISNULL(ivh.ivh_mb_customgroupby, '') > ''
	AND		ivd.ivd_charge <> 0

	IF @count > @cmp_mb_breakvalue		-- need to break
	BEGIN  
		INSERT	INTO @BreakInvoices
		SELECT	ivh_hdrnumber,
				ivh_mb_customgroupby
		FROM	invoiceheader
		WHERE	ivh_billto = @billto
		AND		ivh_mbstatus = 'RTP'
						
		/* loop through all invoices of the BILL TO and break by cmp_mb_breaktype and cmp_mb_breakvalue */
		IF @@rowcount > 0
		BEGIN
			SELECT	@ivh_hdrnumber = MIN(ivh_hdrnumber),
					@breaknumber = 0,
					@detailcount = 0
			FROM	@BreakInvoices	
		
			WHILE @ivh_hdrnumber IS NOT NULL
			BEGIN
				-- count total detail lines	
				SELECT	@detailcount = @detailcount + ISNULL(COUNT(*), 0)
				FROM	invoicedetail 
				WHERE	ivh_hdrnumber = @ivh_hdrnumber
				AND		ivd_charge <> 0
					
				IF @detailcount <= @cmp_mb_breakvalue
				BEGIN
					UPDATE	invoiceheader
					SET		ivh_mb_customgroupby = ivh_mb_customgroupby + '`' + LTRIM(STR(@breaknumber))
					WHERE	ivh_hdrnumber = @ivh_hdrnumber
						
					DELETE FROM @BreakInvoices
					WHERE	ivh_hdrnumber = @ivh_hdrnumber
				END
				ELSE -- break
				BEGIN
					SELECT @breaknumber = @breaknumber + 1
					
					UPDATE	invoiceheader
					SET		ivh_mb_customgroupby = ivh_mb_customgroupby + '`' + LTRIM(STR(@breaknumber))
					WHERE	ivh_hdrnumber = @ivh_hdrnumber
						
					SELECT @detailcount = @detailcount - @cmp_mb_breakvalue  -- keep detail count of the broken invoice to add to the next loop
						
					DELETE FROM @BreakInvoices
					WHERE	ivh_hdrnumber = @ivh_hdrnumber 
				END
					
				SELECT	@ivh_hdrnumber = MIN(ivh_hdrnumber)
				FROM	@BreakInvoices
			END
		END
	END
END		-- break down on total number of billable line charges <end>

SELECT	@totalamount = 0,
		@totalinvoices = 0,
		@breaknumber = 1,
		@ivh_totalcharge_sum = 0,
		@invoicecount = 0

IF @cmp_mb_breaktype = 'AMT'	-- break down on total amount
BEGIN
	-- reset the break if already assigned
	UPDATE	invoiceheader
	SET		ivh_mb_customgroupby =''
	WHERE	ivh_billto = @billto
	AND		ivh_mbstatus = 'RTP' AND ISNULL(ivh_mb_customgroupby, '') > ''

	SELECT	@totalamount = SUM(ISNULL(ivh_totalcharge, 0))
	FROM	invoiceheader
	WHERE	ivh_billto = @billto
	AND		ivh_mbstatus = 'RTP'
		
	IF @totalamount > @cmp_mb_breakvalue	-- break down on the total amount
	BEGIN
		INSERT	INTO @SelectInvoices
		SELECT	ivh_hdrnumber,
				ivh_totalcharge
		FROM	invoiceheader
		WHERE	ivh_billto = @billto
		AND		ivh_mbstatus = 'RTP'
		AND		ivh_totalcharge >= @cmp_mb_breakvalue
			
		IF @@rowcount > 0		-- break those invoices having ivh_totalcharge >= break value
		BEGIN
			SELECT	@ivh_hdrnumber = MIN(ivh_hdrnumber)
			FROM	@SelectInvoices
	
			WHILE @ivh_hdrnumber IS NOT NULL
			BEGIN
				INSERT	INTO @UpdateInvoices
				VALUES	(@ivh_hdrnumber, @breaknumber)
					
				DELETE	FROM @SelectInvoices
				WHERE	ivh_hdrnumber = @ivh_hdrnumber
					
				SELECT	@ivh_hdrnumber = MIN(ivh_hdrnumber),
						@breaknumber = @breaknumber + 1	
				FROM	@SelectInvoices		
			END
		END
		
		INSERT	INTO @SelectInvoices
		SELECT	ivh_hdrnumber,
				ivh_totalcharge
		FROM	invoiceheader
		WHERE	ivh_billto = @billto
		AND		ivh_mbstatus = 'RTP'
		AND		ivh_totalcharge < @cmp_mb_breakvalue
			
		IF @@rowcount > 0		-- break those invoices having ivh_totalcharge < break value
		BEGIN
			SELECT	@ivh_hdrnumber = MIN(ivh_hdrnumber)
			FROM	@SelectInvoices
			WHERE	ivh_totalcharge <= @cmp_mb_breakvalue - ISNULL(@orig_sum, 0)
			
			WHILE @ivh_hdrnumber IS NOT NULL
			BEGIN
				SELECT	@ivh_totalcharge = ivh_totalcharge,
						@orig_sum = @ivh_totalcharge_sum,
						@ivh_totalcharge_sum = @ivh_totalcharge_sum + ivh_totalcharge
				FROM	@SelectInvoices
				WHERE	ivh_hdrnumber = @ivh_hdrnumber
				
				IF @ivh_totalcharge_sum <= @cmp_mb_breakvalue
				BEGIN
					SELECT	@orig_sum = @ivh_totalcharge_sum
					INSERT	INTO @UpdateInvoices
					VALUES	(@ivh_hdrnumber, @breaknumber)
			
					DELETE	FROM @SelectInvoices
					WHERE	ivh_hdrnumber = @ivh_hdrnumber
				END
					
				SELECT	@ivh_hdrnumber = MIN(ivh_hdrnumber)
				FROM	@SelectInvoices
				WHERE	ivh_totalcharge <= @cmp_mb_breakvalue - @orig_sum
			
				IF @ivh_hdrnumber IS NULL
				BEGIN
					SELECT	@orig_sum = 0,
							@ivh_totalcharge_sum = 0,
							@breaknumber = @breaknumber + 1
						
					SELECT	@ivh_hdrnumber = MIN(ivh_hdrnumber)
					FROM	@SelectInvoices
					WHERE	ivh_totalcharge <= @cmp_mb_breakvalue - @orig_sum		
				END		
			END
		END
	END						
		UPDATE	invoiceheader
		SET		ivh_mb_customgroupby = updt.ivh_mb_customgroupby
		FROM	@UpdateInvoices updt
		WHERE	invoiceheader.ivh_hdrnumber = updt.ivh_hdrnumber
END

		
IF @cmp_mb_breaktype = 'INV'	-- break down on total number of invoices
BEGIN
	-- reset the break if already assigned
	UPDATE	invoiceheader
	SET		ivh_mb_customgroupby =''
	WHERE	ivh_billto = @billto
	AND		ivh_mbstatus = 'RTP' AND ISNULL(ivh_mb_customgroupby, '') > ''

	SELECT	@totalinvoices = COUNT(ivh_hdrnumber)
	FROM	invoiceheader
	WHERE	ivh_billto = @billto
	AND		ivh_mbstatus = 'RTP'
			
	IF @totalinvoices >= @cmp_mb_breakvalue	-- break down on the total number of invoices
	BEGIN
		INSERT	INTO @SelectInvoices
		SELECT	ivh_hdrnumber,
				ivh_totalcharge
		FROM	invoiceheader
		WHERE	ivh_billto = @billto
		AND		ivh_mbstatus = 'RTP'
			
		SELECT	@ivh_hdrnumber = MIN(ivh_hdrnumber)
		FROM	@SelectInvoices
			
		WHILE @ivh_hdrnumber IS NOT NULL
		BEGIN
			SELECT @invoicecount = @invoicecount + 1
			IF @invoicecount <= @cmp_mb_breakvalue
			BEGIN
				INSERT	INTO @UpdateInvoices
				VALUES	(@ivh_hdrnumber, @breaknumber)
					
				DELETE	FROM @SelectInvoices
				WHERE	ivh_hdrnumber = @ivh_hdrnumber
			END
			ELSE
			BEGIN
				SELECT	@breaknumber = @breaknumber + 1,
						@invoicecount = 0
			END
										
			SELECT	@ivh_hdrnumber = MIN(ivh_hdrnumber)
			FROM	@SelectInvoices
		END
	END
		
	UPDATE	invoiceheader
	SET		ivh_mb_customgroupby = updt.ivh_mb_customgroupby
	FROM	@UpdateInvoices updt
	WHERE	invoiceheader.ivh_hdrnumber = updt.ivh_hdrnumber
END

GO
GRANT EXECUTE ON  [dbo].[MasterBillParseForBillto_sp] TO [public]
GO
