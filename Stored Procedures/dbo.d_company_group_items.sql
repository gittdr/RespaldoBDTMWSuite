SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_company_group_items]
(
    @cg_id      int,
    @comp_id    varchar(8)
)
AS
    BEGIN

        SELECT  cg_id, 
                item, 
                lfb.name + ' (' + item + ')' itemname, 
                type, 
                lfa.name typename, 
                'Active' status, 
                effective_startdate, 
                effective_enddate,
                modified_by, 
                modified_date, 
                created_by, 
                created_date, 
                comp_id  
        FROM company_item
            LEFT OUTER JOIN labelfile lfa ON type = lfa.abbr
                AND lfa.labeldefinition = 'ItemTp'
            LEFT OUTER JOIN labelfile lfb ON lfa.name = lfb.labeldefinition
                AND item = lfb.abbr
        WHERE cg_id = @cg_id
        AND GETDATE() >= effective_startdate
        AND GETDATE() <= effective_enddate
        AND (CASE WHEN @comp_id = '0' then '0' ELSE @comp_id END) = ISNULL(comp_id,'0')
  
        UNION 
        
        SELECT  cg_id, 
                item, 
                lfb.name + ' (' + item + ')' itemname, 
                type, 
                lfa.name typename, 
                'Inactive' status, 
                effective_startdate, 
                effective_enddate,
                modified_by, 
                modified_date, 
                created_by, 
                created_date, 
                comp_id  
        FROM company_item
            LEFT OUTER JOIN labelfile lfa ON type = lfa.abbr
                AND lfa.labeldefinition = 'ItemTp'
            LEFT OUTER JOIN labelfile lfb ON lfa.name = lfb.labeldefinition
                AND item = lfb.abbr
        WHERE cg_id = @cg_id
        AND (GETDATE() < effective_startdate
          OR GETDATE() > effective_enddate)
        AND (CASE WHEN @comp_id = '0' then '0' ELSE @comp_id END) = ISNULL(comp_id,'0')
        
        UNION
        
        SELECT  -1, 
                'AAA', 
                '(ADD TYPE)' item_name, 
                'AAA' type, 
                NULL, 
                'Active' status, 
                NULL, 
                NULL,
                NULL, 
                NULL, 
                NULL, 
                NULL, 
                '0'  
        
        ORDER BY type, item             
      
    END
GO
GRANT EXECUTE ON  [dbo].[d_company_group_items] TO [public]
GO
