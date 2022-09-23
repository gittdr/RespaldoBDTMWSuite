SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_get_nc_company_sp]
(
     @id varchar(8), 
     @id_type varchar(8)
)
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure.  Get company infor by a parent or child id from the ncec_company_info and company tables.

exec d_get_nc_company_sp 'UNKNOWN', 'Parent'
exec d_get_nc_company_sp 'ALLMID', 'CHILDCMP'
exec d_get_nc_company_sp 'S2YHOL', 'CNTCT'

*/

BEGIN
    select @id_type = upper(@id_type)
    
    if @id_type = 'PARENT'  -- by parent
    begin
        SELECT company.cmp_name,
             nce_company_info.ncec_cmp_child_id,
             nce_company_info.ncec_cmp_parent_id,
             nce_company_info.ncec_contact_type,
             nce_company_info.updated,
             nce_company_info.updated_by,
             nce_company_info.created_by,
             nce_company_info.created,
             ' '  cmp_address
        FROM nce_company_info
            LEFT OUTER JOIN company
            ON nce_company_info.ncec_cmp_child_id = company.cmp_id
        WHERE nce_company_info.ncec_cmp_parent_id = @id
    end
    else if @id_type = 'CNTCT'
    begin
            SELECT distinct company.cmp_name,
            ' ' , 
            @id ncec_cmp_parent_id,
             nce_company_info.ncec_contact_type,
             nce_company_info.updated,
             nce_company_info.updated_by,
             nce_company_info.created_by,
             nce_company_info.created,
             isnull(company.cmp_address1, ' ') + '  ' + Isnull(city.cty_name, ' ') + '  '
             + isnull(city.cty_state, ' ') cmp_address
        FROM dbo.nce_company_info
            INNER JOIN dbo.company
            ON nce_company_info.ncec_cmp_child_id = company.cmp_id
            LEFT OUTER JOIN dbo.city
            ON company.cmp_city = city.cty_code
        WHERE nce_company_info.ncec_cmp_child_id = @id
        
    end
    else if @id_type = 'CHILDCMP'  -- Child Companies
    begin
        SELECT company.cmp_name,
             nce_company_info.ncec_cmp_child_id,
             nce_company_info.ncec_cmp_parent_id,
             nce_company_info.ncec_contact_type,
             nce_company_info.updated,
             nce_company_info.updated_by,
             nce_company_info.created_by,
             nce_company_info.created,
             ' '  cmp_address
        FROM nce_company_info
            LEFT OUTER JOIN company
            ON nce_company_info.ncec_cmp_child_id = company.cmp_id
        WHERE nce_company_info.ncec_cmp_parent_id = @id
        AND ncec_contact_type = 'N'
        
    end
    else
    begin
      SELECT company.cmp_name,
             nce_company_info.ncec_cmp_child_id,
             nce_company_info.ncec_cmp_parent_id,
             nce_company_info.ncec_contact_type,
             nce_company_info.updated,
             nce_company_info.updated_by,
             nce_company_info.created_by,
             nce_company_info.created,
             isnull(company.cmp_address1, ' ') + '  ' + Isnull(city.cty_name, ' ') + '  '
             + isnull(city.cty_state, ' ') cmp_address
        FROM dbo.nce_company_info
            INNER JOIN dbo.company
            ON nce_company_info.ncec_cmp_child_id = company.cmp_id
            LEFT OUTER JOIN dbo.city
            ON company.cmp_city = city.cty_code
        WHERE nce_company_info.ncec_cmp_child_id = @id
        
    end
END
GO
GRANT EXECUTE ON  [dbo].[d_get_nc_company_sp] TO [public]
GO
