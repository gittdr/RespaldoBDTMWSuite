SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_company_group_dtl]
(
    @cg_id int
)
AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Company Groups integration piece.

*/
    BEGIN
    
        SELECT  cg_id, 
                name, 
                effective_startdate, 
                effective_enddate,
                modified_by, 
                modified_date, 
                created_by, 
                created_date,
                'Active' status
        FROM company_group
        WHERE cg_id = @cg_id
        AND GETDATE() >= effective_startdate
        AND GETDATE() <= effective_enddate
        
        UNION
        
         SELECT cg_id, 
                name, 
                effective_startdate, 
                effective_enddate,
                modified_by, 
                modified_date, 
                created_by, 
                created_date,
                'Inactive' status
        FROM company_group
        WHERE cg_id = @cg_id
        AND (GETDATE() < effective_startdate
        OR GETDATE() > effective_enddate)
        
    END 

GO
GRANT EXECUTE ON  [dbo].[d_company_group_dtl] TO [public]
GO
