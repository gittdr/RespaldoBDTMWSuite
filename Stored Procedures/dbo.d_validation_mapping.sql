SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_validation_mapping]
(
@group_id int
)
AS

/* Change Control

TGRIFFIT 38797 11/23/2007 created this stored procedure. This will be the datasource for the d_validation_mapping dw (dw in w_validation_mapping).

*/
    BEGIN
    
        SELECT valm_valcg_id,
            valm_vale_id,
            valm_valg_id,
            valm_effective_from,
            valm_effective_to,
            valm_message_severity,
            valm_create_user,
            valm_create_date,
            valm_update_user,
            valm_update_date
        FROM validation_mapping
            INNER JOIN validation_event
            ON valm_vale_id = vale_id
            AND vale_active_flag = 'Y'
        WHERE valm_valcg_id = @group_id
        
    END
GO
GRANT EXECUTE ON  [dbo].[d_validation_mapping] TO [public]
GO
