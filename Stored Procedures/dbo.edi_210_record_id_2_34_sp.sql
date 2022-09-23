SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_210_record_id_2_34_sp] 
	@cmp_id varchar( 8 ),
	@n101code varchar(2),
	@trpid varchar(20),
	@docid varchar(30)
as
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
  dpete PTS 11689 8/20/01 state filed in database changed to 6 char, must truncate for EDI flat file
 * 11/12/2007.01 ? PTS40187 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @datacol varchar(250)

SELECT @trpid = LEFT(ISNULL(@trpid,'MISSING'),20)
SELECT @n101code = LEFT(ISNULL(@n101code,'XX'),2)

-- put the data into a temp table so that it can be massaged
select
SUBSTRING(ISNULL(company.cmp_name,'MISSING'),1,30) cmp_name,
SUBSTRING(ISNULL(company.cmp_address1,' '),1,30) cmp_address1,
SUBSTRING(ISNULL(city.cty_state,'  '),1,2) cty_state,
LEFT(ISNULL(city.cty_name,'  '),18) cty_name,
LEFT(REPLACE(ISNULL(isnull(company.cmp_zip,city.cty_zip),'  '),'-',''),9) zip,
LEFT(ISNULL(trp_storenumber,'  '),10) trp_storenumber,
LEFT(ISNULL(trp_storenumbertype,'  '),2) trp_storenumbertype
into #210_temp_company
FROM company LEFT OUTER JOIN edi_trading_partner ON company.cmp_id = edi_trading_partner.cmp_id,
	city  -- pts40187 outer join conversion
WHERE company.cmp_id=@cmp_id and city.cty_code=company.cmp_city  

SELECT @datacol = ISNULL( '2' +			
'34' +					
@n101code +				
	replicate(' ',2-datalength(@n101code)) +
cmp_name +				
	replicate(' ',30-datalength(cmp_name)) +
cmp_address1 +				
	replicate(' ',30-datalength(cmp_address1)) +
cty_state +				
	replicate(' ',2-datalength(cty_state)) +
cty_name +				
	replicate(' ',18-datalength(cty_name)) +
zip +					
	replicate(' ',9-datalength(zip)) +
'X                   ' +		
trp_storenumber +
	replicate(' ',10-datalength(trp_storenumber)) +
trp_storenumbertype +
	replicate(' ',2-datalength(trp_storenumbertype)),'NULL')
From #210_temp_company



-- return the row from the temp table
INSERT edi_210 (data_col, trp_id, doc_id)
Values(@datacol , @trpid, @docid)


GO
GRANT EXECUTE ON  [dbo].[edi_210_record_id_2_34_sp] TO [public]
GO
