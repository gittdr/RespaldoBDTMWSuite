SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_validation_section]
(
@type varchar(50)
)
AS

/* Change Control

TGRIFFIT 38797 11/23/2007 created this stored procedure. This will be the datasource for the d_validation_section_for_dddw dw (dddw in d_validation_group_info 'Failure' and d_validation_info 'Fetch'.

*/
    BEGIN
        SELECT vals_id,
            vals_type,
            vals_name,
            vals_create_user,
            vals_create_date,
            vals_update_user,
            vals_update_date
        FROM validation_section
        WHERE vals_type = @type
    END
GO
GRANT EXECUTE ON  [dbo].[d_validation_section] TO [public]
GO
