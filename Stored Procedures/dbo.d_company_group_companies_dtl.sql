SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_company_group_companies_dtl]
(
    @cg_id      int,
    @comp_id    varchar(8)
)
AS
  BEGIN
  
    SELECT  cg_id, 
            comp_id,
            cmp_name,
            effective_startdate,
            effective_enddate,
            modified_by,
            modified_date, 
            created_by, 
            created_date,
            'Active' status
    FROM company_group_detail
        INNER JOIN company ON cmp_id = comp_id
    WHERE cg_id = @cg_id
      AND comp_id = @comp_id
      AND GETDATE() >= effective_startdate
      AND GETDATE() <= effective_enddate
    UNION
    SELECT  cg_id, 
            comp_id,
            cmp_name,
            effective_startdate,
            effective_enddate,
            modified_by,
            modified_date, 
            created_by, 
            created_date,
            'Inactive' status
    FROM company_group_detail
        INNER JOIN company ON cmp_id = comp_id
    WHERE cg_id = @cg_id
      AND comp_id = @comp_id
      AND (GETDATE() < effective_startdate
      OR GETDATE() > effective_enddate)

    END
     
GO
GRANT EXECUTE ON  [dbo].[d_company_group_companies_dtl] TO [public]
GO
