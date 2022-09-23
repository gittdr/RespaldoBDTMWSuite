SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_company_group]
AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Company Groups integration piece.

*/

        
SELECT  cg_id, 
        name + ' (' + CAST(cg_id AS VARCHAR) + ')' name, 
        'Active' status, 
        effective_startdate, 
        effective_enddate,
        modified_by, 
        modified_date, 
        created_by, 
        created_date
FROM company_group
WHERE GETDATE() >= effective_startdate
  AND GETDATE() <= effective_enddate
  
UNION

SELECT  cg_id, 
        name + ' (' + CAST(cg_id AS VARCHAR) + ')' name, 
        'Inactive' status, 
        effective_startdate, 
        effective_enddate,
        modified_by, 
        modified_date, 
        created_by, 
        created_date
FROM company_group
WHERE (GETDATE() < effective_startdate
  OR GETDATE() > effective_enddate)

UNION
 
SELECT  -1, 
        '(ADD GROUP)' name, 
        'Active', 
        NULL, 
        NULL,
        NULL, 
        NULL, 
        NULL, 
        NULL
order by name

GO
GRANT EXECUTE ON  [dbo].[d_company_group] TO [public]
GO
