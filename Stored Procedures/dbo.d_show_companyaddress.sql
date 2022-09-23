SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[d_show_companyaddress] ( @p_carkey int)
AS
/**
 * 
 * NAME:
 * dbo.d_show_companyaddress
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns the company address information for a specific address
 * Uses the identity column (car_key) to retrieve the address information
 * for a car_key attached to the order or invoice
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
 * 001 - @p_carkey int
 *       This parameter is the car_key value placed on the orderheader or
 *       invoiceheader as the car_key when an alternate billing addres is to be used

 * REFERENCES: NONE
--PTS 30355 12/16/05 New
--PTS40260 4/19/08 recode Pauls into main source
 */


If not exists (Select 1 from companyaddress where car_key = @p_carkey)
 Select 
 @p_carkey
 ,'UNKNOWN'
 ,'<NONE>'
 ,NULL,NULL,NULL,NULL,NULL,NULL,NUll

Else
 Select 
 car_key
 ,companyaddress.cmp_id
 ,car_addrname 
 ,car_address1
 ,car_address2
 ,car_address3 
 ,car_city
 ,car_nmstct
 ,car_zip
 ,car_edi210
 from companyaddress
 Where companyaddress.car_key = @p_carkey


GO
GRANT EXECUTE ON  [dbo].[d_show_companyaddress] TO [public]
GO
