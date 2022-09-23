SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_company_group_items_dtl]
(
    @cg_id      int,
    @item       varchar(6),
    @type       varchar(6),
    @comp_id    varchar(8)
)
AS
    BEGIN

        SELECT  cg_id, 
                item, 
                lfb.name itemname, 
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
        AND item = @item
        AND type = @type
        AND comp_id = @comp_id
        AND GETDATE() >= effective_startdate
        AND GETDATE() <= effective_enddate
         
        UNION 
        
        SELECT  cg_id, 
                item, 
                lfb.name itemname, 
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
        AND item = @item
        AND type = @type
        AND comp_id = @comp_id
        AND (GETDATE() < effective_startdate
          OR GETDATE() > effective_enddate)
       
                    
    END
GO
GRANT EXECUTE ON  [dbo].[d_company_group_items_dtl] TO [public]
GO
