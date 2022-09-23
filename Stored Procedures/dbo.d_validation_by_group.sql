SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_validation_by_group]
(
@group_id int
)
AS

/* Change Control

TGRIFFIT 38797 11/23/2007 created this stored procedure. This will be the datasource for the d_validation_info dw,
which is the 'detail' dw in w_validations. 

*/
    BEGIN
        SELECT val_id,
            val_valg_id,
            val_rule_number,
            val_type,
            val_position,
            val_length,
            val_value,
            val_fetch_section_id,
            val_create_user,
            val_create_date,
            val_update_user,
            val_update_date
       FROM validation
       WHERE val_valg_id = @group_id
    
    END
GO
GRANT EXECUTE ON  [dbo].[d_validation_by_group] TO [public]
GO
