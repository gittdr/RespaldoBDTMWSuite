SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_214_record_id_2_10_sp] 
	@cmp_id varchar( 8 ),
	@n101code varchar(2),
	@trpid varchar(20)
as

-- put the data into a temp table so that it can be massaged
-- pts 11689 state field on database changed to char6, need to truncate for flat file
select
n101code=ISNULL(@n101code,'??'),
cmp_name = ISNULL(company.cmp_name,' '),
cmp_address1=substring(isnull(cmp_address1,''),1,30),
cty_state=SUBSTRING(ISNULL(city.cty_state,' '),1,2),
cty_name=ISNULL(city.cty_name,' '),
zip=isnull(company.cmp_zip,city.cty_zip)
into #214_temp_company
FROM company,city
WHERE company.cmp_id=@cmp_id and city.cty_code=company.cmp_city


-- return the row from the temp table
INSERT edi_214
SELECT 
data_col = '2' +			-- Record ID
'10' +					-- Record Version
n101code +				-- N101 code
	replicate(' ',2-datalength(n101code)) +
cmp_name +				-- name
	replicate(' ',30-datalength(cmp_name)) +
cmp_address1 +				-- address
	replicate(' ',30-datalength(cmp_address1)) +
cty_name +				-- city
	replicate(' ',18-datalength(cty_name)) +
cty_state +				-- state
	replicate(' ',2-datalength(cty_state)) +
zip +					-- zip
	replicate(' ',9-datalength(zip)) +
replicate(' ',10) +			-- Not used Location Code
replicate(' ',10) +			-- Not used Store Number
replicate(' ',2),			-- Not used store type
trp_id=@trpid

FROM #214_temp_company



GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_2_10_sp] TO [public]
GO
