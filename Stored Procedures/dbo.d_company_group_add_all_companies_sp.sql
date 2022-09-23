SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_company_group_add_all_companies_sp]
(
    @cg_id int
)
AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Company Groups integration piece.

*/

   BEGIN
   
        DECLARE @apocalypse datetime
        DECLARE @now    datetime
        
        SET @apocalypse = CONVERT(DATETIME,'20491231 23:59:59')
        SET @now = GETDATE() 

        CREATE TABLE #exisiting_grp
        (
            comp_id varchar(8)
        )
        
        INSERT INTO #exisiting_grp
        SELECT comp_id
        FROM company_group_detail
        WHERE cg_id = @cg_id
        
        INSERT INTO company_group_detail
        (cg_id, comp_id, effective_startdate, effective_enddate)
        SELECT @cg_id, cmp_id, @now, @apocalypse
        FROM company
            LEFT OUTER JOIN #exisiting_grp ON cmp_id = comp_id 
        WHERE comp_id IS NULL
        
        DROP TABLE #exisiting_grp
        
   
   END     

GO
GRANT EXECUTE ON  [dbo].[d_company_group_add_all_companies_sp] TO [public]
GO
