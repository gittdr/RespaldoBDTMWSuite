SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_validation_event]
AS

/* Change Control

TGRIFFIT 38797 11/23/2007 created this stored procedure. This will be the datasource for the d_validation_event_for_dddw dw, which is used on the event column drop down in w_validation_mapping. 

*/
    BEGIN
        
        SELECT vale_id,
            vale_name,
            vale_pre_validation_rule,
            vale_active_flag,
            vale_create_user,
            vale_create_date,
            vale_update_user,
            vale_update_date
        FROM validation_event
        WHERE vale_active_flag = 'Y'
        
    END
GO
GRANT EXECUTE ON  [dbo].[d_validation_event] TO [public]
GO
