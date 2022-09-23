SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_210_record_id_5_sp] 
	@invoice_number varchar( 12 ),
	@trpid varchar(20),@related_recordID int
 as

declare @emptystring varchar(79),@systemowner varchar(40),@billdate datetime
declare @formattedbilldate varchar(8),@formattedtoday varchar(8),@alias varchar(3)
declare @status char, @billto varchar(8),@yyyy varchar(4),@mm varchar(3),@dd varchar(2)
declare @statustext varchar(4), @shipticket varchar(30), @ordhdrnumber int
declare @totalgallons varchar(9), @ediqualifier char(3)

select @emptystring=''

-- ID the system owner for any user specific requirements
Select @systemowner=upper(gi_string1)
From generalinfo
where gi_name = 'SystemOwner'


if @systemowner = 'FLORIDAROCK'
   BEGIN
   If @related_recordID = 1
     BEGIN
	SELECT @billdate = ivh_billdate,
		@billto  = ivh_billto,
	        @ordhdrnumber = ord_hdrnumber
	FROM    invoiceheader
	WHERE 	ivh_invoicenumber = @invoice_number

	SELECT	@alias = trp_alias,
		@status = trp_status
	FROM	edi_trading_partner
	WHERE	cmp_id = @billto

	SELECT @shipticket = ref_number
	FROM   referencenumber
        WHERE  ref_table = 'ORDERHEADER' 
          AND  ref_tablekey = @ordhdrnumber
	  AND  ref_type = 'SHIPTK'

	--**** this is an interim fix for FR going live soon may not work for
	--**** other FR businesses
	SELECT  @totalgallons = convert(varchar(9),SUM(ivd_quantity))
	FROM   invoicedetail 
	WHERE   ord_hdrnumber = @ordhdrnumber
	AND	 ivd_unit = 'GAL'

	SELECT @ediqualifier = convert(char(3),edicode)
	FROM   labelfile

	WHERE	 labeldefinition = 'VolumeUnits'
	AND	 abbr = 'GAL'

	-- condition the billdate
	
	select @yyyy=convert( varchar(4),datepart(yy,@billdate)),
		@mm=convert( varchar(2),datepart(mm,@billdate)),
		@dd=convert( varchar(2),datepart(dd,@billdate))

	SELECT  @formattedbilldate = replicate('0',4-datalength(@yyyy)) + @yyyy +
		replicate('0',2-datalength(@mm)) + @mm +
		replicate('0',2-datalength(@dd)) + @dd

	-- condition current date
	select @yyyy=convert( varchar(4),datepart(yy,getdate())),
		@mm=convert( varchar(2),datepart(mm,getdate())),
		@dd=convert( varchar(2),datepart(dd,getdate()))

	SELECT @formattedtoday = replicate('0',4-datalength(@yyyy)) + @yyyy +
		replicate('0',2-datalength(@mm)) + @mm +
		replicate('0',2-datalength(@dd)) + @dd

	-- convert the T/P status code to the text
	SELECT @statustext = 'TEST' where @status = 'T'
	SELECT @statustext = 'PROD' where @status = 'P'

	-- add a record for the as of bill date
	INSERT edi_210 (data_col, trp_id)
		SELECT 
		data_col = '5' +				-- Record ID
		'10' +						-- Record Version
		'BDT' +	-- misc data type
		@formattedbilldate +	replicate(' ',79-datalength(@formattedbilldate)),	-- misc data
		trp_id=@trpid
	-- add a record for today's date
	
	INSERT edi_210 (data_col, trp_id)
		SELECT 
		data_col = '5' +				-- Record ID

		'10' +						-- Record Version
		'CDT' +	-- misc data type
		@formattedtoday +	replicate(' ',79-datalength(@formattedtoday)),	-- misc data
		trp_id=@trpid
	
	-- add a record for the alias
	INSERT edi_210 (data_col, trp_id)
		SELECT 
		data_col = '5' +				-- Record ID
		'10' +						-- Record Version
		'ALS' +	-- misc data type
		@alias +	replicate(' ',79-datalength(@alias)),	-- misc data
		trp_id=@trpid
	
	-- add a record for the alias
	INSERT edi_210 (data_col, trp_id)
		SELECT 
		data_col = '5' +				-- Record ID
		'10' +						-- Record Version
		'SHP' +	-- misc data type
		@shipticket +	replicate(' ',79-datalength(@alias)),	-- misc data
		trp_id=@trpid
	-- add a record for the test/prod status
	INSERT edi_210 (data_col, trp_id)
		SELECT 
		data_col = '5' +				-- Record ID
		'10' +						-- Record Version
		'STS' +	-- misc data type
		@statustext +	replicate(' ',79-datalength(@statustext)),	-- misc data
		trp_id=@trpid
	
	-- add a record for the total volume
	INSERT edi_210 (data_col, trp_id)
		SELECT 
		data_col = '5' +				-- Record ID
		'10' +						-- Record Version
		'VOL' +	-- misc data type
		@ediqualifier    +     replicate(' ',3-datalength(@ediqualifier)) +
		@totalgallons +	replicate(' ',76-datalength(@statustext)),	-- misc data
		trp_id=@trpid


     END
 
   END
ELSE
	-- default return is nothing
     BEGIN



	-- return the row from the temp table

	INSERT edi_210 (data_col, trp_id)
	SELECT 
	data_col = '5' +				-- Record ID
	'10' +						-- Record Version
	@emptystring +	replicate(' ',3-datalength(@emptystring)) +	-- misc data type
	@emptystring +	replicate(' ',79-datalength(@emptystring)),	-- misc data
	trp_id=@trpid

	FROM invoiceheader
	WHERE 1=2

     END






GO
GRANT EXECUTE ON  [dbo].[edi_210_record_id_5_sp] TO [public]
GO
