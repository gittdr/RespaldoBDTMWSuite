SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [dbo].[d_loadsupplier_sp] (@revtype1 VARCHAR(6))
AS

			SELECT	Isnull(c1.cmp_name ,''),
				c1.cmp_id ,
				IsNull(c1.cmp_address1,'') ,
				c1.cmp_address2 , 
				c1.cty_nmstct,
				c1.cmp_defaultbillto,
				c1.cmp_defaultpriority,
				ISNULL (c1.cmp_zip, '' ),
				c1.cmp_subcompany,
				c1.cmp_currency,
				c1.cmp_mileagetable,
				c1.cmp_shipper,
				c1.cmp_consingee,
				c1.cmp_billto,
				cmp_contact = Isnull(c1.cmp_contact,''),
				SUBSTRING(c1.cmp_misc1,1,30),
				c1.cmp_primaryphone,
				cmp_geoloc = IsnUll(c1.cmp_geoloc,''),	
				c1.cmp_city ,			
				IsNull(c1.cmp_altid,'')
				FROM company c1
				JOIN company_alternates ca ON ca.ca_id = c1.cmp_id 
				JOIN company c2 ON ca.ca_alt = c2.cmp_id AND c2.cmp_revtype1 = @revtype1
				ORDER BY c1.cmp_id 


GO
GRANT EXECUTE ON  [dbo].[d_loadsupplier_sp] TO [public]
GO
