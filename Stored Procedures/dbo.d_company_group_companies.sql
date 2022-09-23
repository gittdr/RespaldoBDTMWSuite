SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_company_group_companies]
(
    @cg_id int
)
AS
    BEGIN

        SELECT  cg_id, 
                comp_id,
                cmp_name + ' (' + comp_id + ')' cmp_name,
                effective_startdate,
                effective_enddate,
                modified_by,
                modified_date, 
                created_by, 
                created_date,
                'Active' status,
                'Z' sortcol
        FROM company_group_detail
            INNER JOIN company ON cmp_id = comp_id
        WHERE cg_id = @cg_id
          AND GETDATE() >= effective_startdate
          AND GETDATE() <= effective_enddate
        UNION
        SELECT  cg_id, 
                comp_id,
                cmp_name + ' (' + comp_id + ')' cmp_name,
                effective_startdate,
                effective_enddate,
                modified_by,
                modified_date, 
                created_by, 
                created_date,
                'Inactive' status,
                'Z' sortcol
        FROM company_group_detail
            INNER JOIN company ON cmp_id = comp_id
        WHERE cg_id = @cg_id
          AND (GETDATE() < effective_startdate
          OR GETDATE() > effective_enddate)
          
        UNION
        
        SELECT  -1,
                '-1',
                '(ADD COMPANY)' cmp_name,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                'Active' status,
                'A' sortcol
         
        ORDER BY sortcol, cmp_name
     
    END
    
GO
GRANT EXECUTE ON  [dbo].[d_company_group_companies] TO [public]
GO
