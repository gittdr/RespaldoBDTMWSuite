SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_210_record_id_2_sp] 
	@cmp_id varchar( 8 ),
	@n101code varchar(2),
	@trpid varchar(20)
as
/*
  MODIFICATION LOG
 put the data into a temp table so that it can be massaged
  pts 11689 state changed to char 6 on database, must truncate for flat file

*/
select
n101code=@n101code,
company.cmp_name,
ISNULL(company.cmp_address1,' ') cmp_address1,
SUBSTRING(city.cty_state,1,2) cty_state,
city.cty_name,
zip=isnull(company.cmp_zip,city.cty_zip)
into #210_temp_company
FROM company,city
WHERE company.cmp_id=@cmp_id and city.cty_code=company.cmp_city

update #210_temp_company set
cmp_address1=substring(isnull(cmp_address1,''),1,30),
zip=isnull(zip,''),
n101code=isnull(n101code,'')

-- return the row from the temp table
INSERT edi_210
SELECT 
data_col = '2' +			-- Record ID
'10' +					-- Record Version
n101code +				-- N101 code
	replicate(' ',2-datalength(n101code)) +
cmp_name +				-- name
	replicate(' ',30-datalength(cmp_name)) +
cmp_address1 +				-- address
	replicate(' ',30-datalength(cmp_address1)) +
cty_state +				-- state
	replicate(' ',2-datalength(cty_state)) +
cty_name +				-- city
	replicate(' ',18-datalength(cty_name)) +
zip +					-- zip
	replicate(' ',9-datalength(zip)) +
'X                   ',			-- locationcode
trp_id=@trpid

FROM #210_temp_company

GO
GRANT EXECUTE ON  [dbo].[edi_210_record_id_2_sp] TO [public]
GO
