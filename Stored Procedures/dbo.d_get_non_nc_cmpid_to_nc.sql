SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROCEDURE [dbo].[d_get_non_nc_cmpid_to_nc] 
(
    @comp varchar(8) 
)    
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Get candiates for new nc company.

d_get_non_nc_cmpid_to_nc 'Y'
*/

BEGIN

    SELECT	cmp_name,
           cmp_id ,
           cmp_address1 ,
           cmp_address2 ,
           cty_nmstct,
           cmp_defaultbillto,
           cmp_defaultpriority,
           ISNULL (cmp_zip, '' ),
           cmp_subcompany,
           cmp_currency,
           cmp_mileagetable,
           cmp_shipper,
           cmp_consingee,
           cmp_billto,
           cmp_contact,
           SUBSTRING(cmp_misc1,1,30),
           cmp_othertype2
    FROM   company
    WHERE  cmp_id like @comp + '%'
      AND  NOT EXISTS (select 1 from nce_company_info where ncec_cmp_child_id = company.cmp_id)
    ORDER BY cmp_id

END

GO
GRANT EXECUTE ON  [dbo].[d_get_non_nc_cmpid_to_nc] TO [public]
GO
