SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
pts10311 make v3.4 manual edi work in v 2001,2002
pts 11689 state field on database changed to 6 char, must trucate for flat file
*/

CREATE PROCEDURE [dbo].[edi_214_record_id_2_34_sp] 
	@cmp_id varchar( 8 ),
	@n101code varchar(2),
	@trpid varchar(20),
	@billto  varchar(8),
	@docid varchar(30)
as

-- put the data into a temp table so that it can be massaged
DECLARE @ediloccode varchar(10)
/* put the data into a temp table so that it can be massaged */
  SELECT    n101code=ISNULL(@n101code,'??'),
    cmp_name = SUBSTRING(ISNULL(company.cmp_name,' '),1,30),
    cmp_address1=substring(isnull(cmp_address1,' '),1,30),
    cty_state=SUBSTRING(ISNULL(city.cty_state,' '),1,2),
    cty_name=SUBSTRING(ISNULL(city.cty_name,' '),1,18),
    zip=SUBSTRING(ISNULL(city.cty_zip,' '),1,9)
  INTO #214_temp_company
  FROM company,city
  WHERE company.cmp_id=@cmp_id and city.cty_code=company.cmp_city 


  SELECT @ediloccode = SUBSTRING(cmpcmp.ediloc_code,1,10)
  FROM cmpcmp 
  Where cmpcmp.billto_cmp_id = @billto
  and   cmpcmp.cmp_id = @cmp_id

  SELECT @ediloccode = ISNULL(@ediloccode,'   ')


-- return the row from the temp table


INSERT edi_214 (data_col,trp_id,doc_id)
SELECT 
data_col = '2' +			-- Record ID
'34' +					-- Record Version
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
@cmp_id + replicate(' ',10-datalength(@cmp_id)) +			
@ediloccode +
	replicate(' ',10-datalength(@ediloccode)) +
'XX',
trp_id=@trpid, doc_id = @docid

FROM #214_temp_company


GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_2_34_sp] TO [public]
GO
