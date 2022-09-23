SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[d_companyaddress] ( @p_cmpid varchar(8))
AS
/**
 * 
 * NAME:
 * dbo.d_companyaddress
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns all alternative addresses for a company
 *
 *
 * RESULT SETS:
 * car_key     Identity col for the table 
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
 * cmp_name                     Company tabke name associated with cmp_id
 * car_retired                  Addresses are retired, never deleted
 * car_contact    Free form text for contact info
 *
 * PARAMETERS:
 * 001 - @p_cmpid, varchar(8)
 *       This parameter is the company ID 

 * REFERENCES: NONE
 */

--PTS 30355 11/16/05 New
--PTS 40260 4/17/08 DPETE recode into main

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
,cmp_name
,car_retired = IsNull(car_retired,'N')
,car_contact
,car_email_address
from companyaddress
left outer join company on companyaddress.cmp_id = company.cmp_id
Where companyaddress.cmp_id = @p_cmpid


GO
GRANT EXECUTE ON  [dbo].[d_companyaddress] TO [public]
GO
