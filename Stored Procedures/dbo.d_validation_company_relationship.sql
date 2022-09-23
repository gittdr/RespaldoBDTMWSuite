SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_validation_company_relationship]
(
@co_grp_id int
)
AS

/* Change Control

TGRIFFIT 38797 11/23/2007 created this stored procedure. This will be the datasource for the d_validation_company_relationship dw, the main dw in w_validation_company_relationships.

*/
    BEGIN
        
        IF @co_grp_id > 0 
            SELECT valco_valcg_id,
                valco_cmp_id,
                valco_used_as,
                valco_create_user,
                valco_create_date,
                valco_update_user,
                valco_update_date,
                valcg_name
            FROM validation_company
                INNER JOIN validation_company_group
                ON valco_valcg_id = valcg_id
            WHERE valco_valcg_id = @co_grp_id
            
        ELSE
        
            SELECT valco_valcg_id,
                valco_cmp_id,
                valco_used_as,
                valco_create_user,
                valco_create_date,
                valco_update_user,
                valco_update_date,
                valcg_name
            FROM validation_company
                INNER JOIN validation_company_group
                ON valco_valcg_id = valcg_id
                
    END
GO
GRANT EXECUTE ON  [dbo].[d_validation_company_relationship] TO [public]
GO
