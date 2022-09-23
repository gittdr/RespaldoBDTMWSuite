SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[MasterBillParseForPrint_sp]
		@billto		VARCHAR(8)	-- 66113 
AS

/**
 * NAME:		dbo.MasterBillParseForPrint_sp
 * TYPE:		StoredProcedure
 * DESCRIPTION:	This storec procedure is created for PTS #55906 (KVS Transportation) to limit the number of freight bills to be grouped together
 *				under the same master bill.  This value is set for bill to company and stored in the company. field
 * RETURNS:		None
 * REVISION HISTORY:	BY			DATE			DESCRIPTION
 *						NQIAO		06/15/2011		Created for PTS #55906
 *
 * 02/08/2012	PTS60860 - Modified to support another 2 new break types (AMT, INV) for Service Pack
 * 02/20/2013	PTS66113 - modified to take input @billto and call masterbillparseforbillto_sp if @billto is not null or empty.
 **/
 
IF ISNULL(@billto, 'UNKNOWN') <> 'UNKNOWN' AND ltrim(rtrim(@billto)) > ''  	-- 66113 added this if..else condition
	EXEC MasterBillParseForBillto_sp @billto
ELSE
BEGIN
	DECLARE	@next_billto				varchar(8),	
			@next_customgroupby			varchar(60),
			@cmp_mb_breaktype			varchar(8),
			@CMP_mb_breakvalue			int,
			@ivh_hdrnumber				int,
			@ivh_mb_customgroupby		varchar(60),
			@detailcount				int,
			@breaknumber				int,
			@count						int,
			@totalamount				money,
			@totalinvoices				int,
			@ivh_totalcharge			money,
			@ivh_totalcharge_sum		money,
			@orig_sum					money,
			@invoicecount				int
		
	CREATE TABLE #BreakCompanies 	(
			cmp_id					varchar(8) not null,
			cmp_mb_breaktype		varchar(8),
			cmp_mb_breakvalue		int)

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
		
	/* get a list of the bill to companies and have cmp_mb_breaktype and cmp_mb_breakvalue defined */
	INSERT INTO #BreakCompanies
	SELECT	distinct child.cmp_id,
			cmp_mb_breaktype = 
				case ISNULL(parent.cmp_mb_breaktype, '')
					when '' then child.cmp_mb_breaktype
					when 'UNKNOWN' then child.cmp_mb_breaktype
					when 'UNK' then child.cmp_mb_breaktype
					else parent.cmp_mb_breaktype
				end,
			cmp_mb_breakvalue = 
				case ISNULL(parent.cmp_mb_breakvalue, 0)
					when 0 then child.cmp_mb_breakvalue
					else parent.cmp_mb_breakvalue
				end
	FROM	company parent, company child
	WHERE	parent.cmp_id = child.cmp_mastercompany
	AND		parent.cmp_active = 'Y'
	AND		child.cmp_active = 'Y'
	AND		child.cmp_billto = 'Y'
	AND		child.cmp_invoicetype = 'MAS'
	AND		((ISNULL(parent.cmp_mb_breaktype, '') <> '' AND left(parent.cmp_mb_breaktype, 3) <> 'UNK' AND parent.cmp_mb_breakvalue > 0) OR
		     (ISNULL(child.cmp_mb_breaktype, '') <> '' AND left(child.cmp_mb_breaktype, 3) <> 'UNK' AND child.cmp_mb_breakvalue > 0))

	IF @@rowcount = 0 -- no company to process
		Return;

	SELECT	@count = COUNT(1)
	FROM	#BreakCompanies
	WHERE	cmp_mb_breaktype = 'CHARGES'

	IF @count > 0		-- break down on total number of billable line charges
	BEGIN
		-- reset the break if already assigned
		UPDATE	invoiceheader
		SET		ivh_mb_customgroupby =	CASE CHARINDEX('`', ivh_mb_customgroupby)
										WHEN 0 THEN ivh_mb_customgroupby
										ELSE LEFT(ivh_mb_customgroupby, CHARINDEX('`', ivh_mb_customgroupby)-1)
										END
		FROM	#BreakCompanies
		JOIN	invoiceheader ivh ON cmp_id = ivh.ivh_billto AND ivh_mbstatus = 'RTP' AND ISNULL(ivh.ivh_mb_customgroupby, '') > ''
		JOIN	invoicedetail ivd ON ivh.ivh_hdrnumber = ivd.ivh_hdrnumber AND ivd.ivd_charge <> 0
		WHERE	cmp_mb_breaktype = 'CHARGES'

		-- get a list of bill to companies and associated billable detail line count
		INSERT INTO	@CmpInvDetailCnt
		SELECT	bkcmp.cmp_id,
				ivh.ivh_mb_customgroupby,
				'',
				0,
				COUNT(*)
		FROM	#BreakCompanies bkcmp
		JOIN	invoiceheader ivh ON bkcmp.cmp_id = ivh.ivh_billto AND ivh_mbstatus = 'RTP' AND ISNULL(ivh.ivh_mb_customgroupby, '') > ''
		JOIN	invoicedetail ivd ON ivh.ivh_hdrnumber = ivd.ivh_hdrnumber AND ivd.ivd_charge <> 0
		WHERE	cmp_mb_breaktype = 'CHARGES'
		GROUP BY bkcmp.cmp_id, ivh.ivh_mb_customgroupby

		UPDATE	@CmpInvDetailCnt
		SET		cmp_mb_breaktype = #BreakCompanies.cmp_mb_breaktype,
				cmp_mb_breakvalue = #BreakCompanies.cmp_mb_breakvalue
		FROM	#BreakCompanies
		WHERE	ivh_billto = cmp_id
	
		DELETE	FROM @CmpInvDetailCnt
		WHERE	cmp_mb_breakvalue >= detailcount

		SELECT	@count = COUNT(1)
		FROM	@CmpInvDetailCnt

		IF @count > 0
		BEGIN  
			/* loop thorugh all BILL TO companies that need to have master bill broken on count of billed line itmes */
			SELECT	@next_billto = MIN(ivh_billto)
			FROM	@CmpInvDetailCnt
	
			IF @next_billto IS NOT NULL
			BEGIN
				SELECT	@next_customgroupby = MIN(ivh_mb_customgroupby)
				FROM	@CmpInvDetailCnt
				WHERE	ivh_billto = @next_billto
			END
	
			WHILE	@next_customgroupby IS NOT NULL
			BEGIN
				SELECT	@cmp_mb_breaktype = cmp_mb_breaktype,
						@cmp_mb_breakvalue = cmp_mb_breakvalue
				FROM	@CmpInvDetailCnt
				WHERE	ivh_billto = @next_billto
				AND		ivh_mb_customgroupby = @next_customgroupby

				IF @cmp_mb_breaktype = 'CHARGES'  -- break on number of line item changes
				BEGIN
					DELETE FROM @BreakInvoices
			
					INSERT	INTO @BreakInvoices
					SELECT	ivh_hdrnumber,
							ivh_mb_customgroupby
					FROM	invoiceheader
					WHERE	ivh_billto = @next_billto
					AND		ivh_mbstatus = 'RTP'
					AND		ivh_mb_customgroupby = @next_customgroupby
						
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
		
				DELETE FROM @CmpInvDetailCnt
				WHERE	ivh_billto = @next_billto
				AND		ivh_mb_customgroupby = @next_customgroupby
		
				/* get next BILL TO company to process */
				SELECT	@next_billto = MIN(ivh_billto)
				FROM	@CmpInvDetailCnt
		
				SELECT	@next_customgroupby = MIN(ivh_mb_customgroupby)
				FROM	@CmpInvDetailCnt
				WHERE	ivh_billto = @next_billto
			END
		END
	END

	DELETE	FROM	#BreakCompanies
	WHERE	cmp_mb_breaktype = 'CHARGES'

	SELECT  @next_billto = MIN(cmp_id)
	FROM	#BreakCompanies

	IF @@rowcount = 0 Return;

	WHILE @next_billto IS NOT NULL		-- break down for other break type (e.g. AMT and INV)
	BEGIN
		-- initialize 
		DELETE FROM @SelectInvoices
		DELETE FROM @UpdateInvoices
		SELECT	@totalamount = 0,
				@totalinvoices = 0,
				@breaknumber = 1,
				@ivh_totalcharge_sum = 0,
				@invoicecount = 0
	
		SELECT  @cmp_mb_breaktype = cmp_mb_breaktype,
				@cmp_mb_breakvalue = cmp_mb_breakvalue
		FROM	#BreakCompanies
		WHERE	cmp_id = @next_billto
		
		IF @cmp_mb_breaktype = 'AMT'	-- break down on total amount
		BEGIN
			-- reset the break if already assigned
		
			UPDATE	invoiceheader
			SET		ivh_mb_customgroupby =''
			WHERE	ivh_billto = @next_billto
			AND		ivh_mbstatus = 'RTP' AND ISNULL(ivh_mb_customgroupby, '') > ''
		
			SELECT	@totalamount = SUM(ISNULL(ivh_totalcharge, 0))
			FROM	invoiceheader
			WHERE	ivh_billto = @next_billto
			AND		ivh_mbstatus = 'RTP'
		
			IF @totalamount > @cmp_mb_breakvalue	-- break down on the total amount
			BEGIN
				INSERT	INTO @SelectInvoices
				SELECT	ivh_hdrnumber,
						ivh_totalcharge
				FROM	invoiceheader
				WHERE	ivh_billto = @next_billto
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
				WHERE	ivh_billto = @next_billto
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
			WHERE	ivh_billto = @next_billto
			AND		ivh_mbstatus = 'RTP' AND ISNULL(ivh_mb_customgroupby, '') > ''

			SELECT	@totalinvoices = COUNT(ivh_hdrnumber)
			FROM	invoiceheader
			WHERE	ivh_billto = @next_billto
			AND		ivh_mbstatus = 'RTP'
			
			IF @totalinvoices >= @cmp_mb_breakvalue	-- break down on the total number of invoices
			BEGIN
				INSERT	INTO @SelectInvoices
				SELECT	ivh_hdrnumber,
						ivh_totalcharge
				FROM	invoiceheader
				WHERE	ivh_billto = @next_billto
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

		SELECT	@next_billto = MIN(cmp_id)
		FROM	#BreakCompanies
		WHERE	cmp_id > @next_billto
	END
END			-- 66113

GO
GRANT EXECUTE ON  [dbo].[MasterBillParseForPrint_sp] TO [public]
GO
