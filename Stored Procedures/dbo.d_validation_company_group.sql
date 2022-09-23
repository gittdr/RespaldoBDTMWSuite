SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_validation_company_group]
(
    @id int = 0
)
AS

/* Change Control

TGRIFFIT 38797 11/23/2007 created this stored procedure. This will be the datasource for the d_validation_company_group dw (dw in w_validation_company_groups) and also d_validation_co_grp_for_dddw.

*/
    BEGIN
    
        IF @id = 0 
            SELECT valcg_id,
                valcg_name,
                valcg_create_user,
                valcg_create_date,
                valcg_update_user,
                valcg_update_date
           FROM validation_company_group
       ELSE
            SELECT valcg_id,
                valcg_name,
                valcg_create_user,
                valcg_create_date,
                valcg_update_user,
                valcg_update_date
           FROM validation_company_group
           WHERE valcg_id = @id
            
    END
GO
GRANT EXECUTE ON  [dbo].[d_validation_company_group] TO [public]
GO
