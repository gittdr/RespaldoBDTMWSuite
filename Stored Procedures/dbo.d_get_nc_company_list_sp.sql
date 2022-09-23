SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
CREATE PROCEDURE [dbo].[d_get_nc_company_list_sp] 
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Get name for all the nc companies 

exec d_get_nc_company_list_sp 

*/

BEGIN
    select ncec_cmp_child_id,  
           cmp_name
      from dbo.nce_company_info
           INNER JOIN dbo.company
           ON ncec_cmp_child_id = cmp_id
    
    union
    select 'UNKNOWN', 'UNKNOWN'
    
    return 0
END

GO
GRANT EXECUTE ON  [dbo].[d_get_nc_company_list_sp] TO [public]
GO
