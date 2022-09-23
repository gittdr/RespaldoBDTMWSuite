SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE Procedure [dbo].[billing_validation_kvs_sp]
	@ivh_invoicenumber	varchar(12),
	@ErrorMessage varchar(255) OUTPUT
	
AS

DECLARE	@bill_to				varchar(8),
		@car_key				varchar(6),
		@ivh_currency			varchar(6),
		@cmp_mastercompany		varchar(8),
		@ord_hdrnumber			int,
		@ivh_order_by			varchar(8),
		@ivh_revtype2			varchar(6),
		@ivh_mbstatus			varchar(6),
		@ivh_mb_customgropuby	varchar(80),
		@groupby				varchar(12),
		@groupvalue				varchar(30),
		@stp_number_min			int,
		@fgt_number_min			int,
		@count					int,
		@sequence				int

SELECT	@ord_hdrnumber = ord_hdrnumber,
		@ivh_revtype2 = ivh_revtype2,
		@bill_to = ivh_billto,
		@ivh_order_by = ivh_order_by,
		@car_key = ltrim(rtrim(str(ISNULL(car_key, 0)))),
		@ivh_currency = ISNULL(ivh_currency, ''),
		@ivh_mbstatus = ivh_mbstatus
FROM	invoiceheader
WHERE	ivh_invoicenumber = @ivh_invoicenumber

SELECT	@cmp_mastercompany = cmp_mastercompany
FROM	company
WHERE	cmp_id = @bill_to

IF (@ivh_mbstatus = 'RTP')
BEGIN
	DECLARE	@groupbytbl table (
		bill_to		varchar(8) not null,
		groupby		varchar(12) not null,
		sequence	int not null)	
		
	SELECT	@count = 0,	
			@ivh_mb_customgropuby = @bill_to + '^' + @car_key + '^' + @ivh_currency
		
	INSERT INTO @groupbytbl VALUES('AERAENE', 'PONBR', 1)  
	INSERT INTO @groupbytbl VALUES('AERAENE', 'PMNBR', 2)
	
	INSERT INTO @groupbytbl VALUES('CHEVTEX', 'PONBR', 1)
	INSERT INTO @groupbytbl VALUES('CHEVTEX', 'ORDERBY', 2)
	INSERT INTO @groupbytbl VALUES('CHEVTEX', 'CHRGCD', 3)
	
	INSERT INTO @groupbytbl VALUES('OCCI000', 'PONBR', 1)
	INSERT INTO @groupbytbl VALUES('OCCI000', 'ORDERBY',2)
	INSERT INTO @groupbytbl VALUES('OCCI000', 'PROJCT',3)
	INSERT INTO @groupbytbl VALUES('OCCI000', 'WRKORD',4)

	SELECT	@sequence = MIN(sequence)
	FROM	@groupbytbl
	WHERE	bill_to = @cmp_mastercompany

	IF @@rowcount > 0
	BEGIN
		WHILE (@sequence IS NOT NULL)
		BEGIN
			SELECT @groupvalue = ''
		
			SELECT	@groupby = groupby
			FROM	@groupbytbl
			WHERE	bill_to = @cmp_mastercompany
			AND		sequence = @sequence
		
			IF @groupby = 'ORDERBY'
				BEGIN
					SELECT	@groupvalue = @ivh_order_by
				END
			ELSE
				BEGIN
					SELECT	@groupvalue = ISNULL(MIN(ref_number), '')
					FROM	referencenumber
					WHERE	ord_hdrnumber = @ord_hdrnumber
					AND		ref_table = 'orderheader'
					AND		ref_type = @groupby
				
					IF	@groupby = 'CHRGCD' AND @ivh_revtype2 <> 'DRLG'
						SELECT @groupvalue = ''
				END
			
			IF @groupvalue > ''
			SELECT	@ivh_mb_customgropuby = @ivh_mb_customgropuby + '^' + @groupvalue 

			SELECT	@sequence = MIN(sequence),
					@count = @count + 1
			FROM	@groupbytbl
			WHERE	bill_to = @cmp_mastercompany
			AND		sequence > @sequence
		END
		
		UPDATE	invoiceheader
		SET		ivh_mb_customgroupby = @ivh_mb_customgropuby
		WHERE	ivh_invoicenumber = @ivh_invoicenumber
	END
	
END

SELECT @ErrorMessage = ''

GO
GRANT EXECUTE ON  [dbo].[billing_validation_kvs_sp] TO [public]
GO
