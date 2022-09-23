SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[d_dddw_companyaddress] ( @p_cmpid varchar(8))
AS
/**
 * 
 * NAME:
 * dbo.d_dddw_companyaddress
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns all alternative addresses for a company
 * Inserts a no altrnative address (car_key = 0) as an option
 *
 * RESULT SETS: 
 * car_key                 Identity column stored on orderheader or invoicehader
 * cmp_id			This is the company ID
 * car_addrname        		The name given to this address (it's ID)
 * car_name        		The company name for this address
 * car_address1        		The first line of address for this address
 * car_address2        		The second line of address for this address
 * car_address3        		The third line of address for this address
 * car_city int                 The city for this address
 * car_nmstct                   The nmstct for this address
 * car_zip                      The zip for this address
 * car_edi210                   The EDI 210 flag for this address
 *
 * PARAMETERS:
 * 001 - @p_cmpid, varchar(8)
 *       This parameter is the company ID 

 * REFERENCES: NONE

--PTS 30355 12/16/05 New
-- PTS40260 DPETE recode Pauls
 */


-- Following inserts a value for no alternative address
Select 
 car_key = 0
 ,cmp_id 
 ,'<NONE>'
 ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
From company Where cmp_id = @p_cmpid

-- Now add the real data
UNION
Select 
car_key
,companyaddress.cmp_id
,car_addrname 
,car_name
,car_address1
,car_address2
,car_address3 
,car_city
,car_nmstct
,car_zip
,car_edi210
from companyaddress
Where companyaddress.cmp_id = @p_cmpid
and IsNull(car_retired,'N') <> 'Y'


GO
GRANT EXECUTE ON  [dbo].[d_dddw_companyaddress] TO [public]
GO
