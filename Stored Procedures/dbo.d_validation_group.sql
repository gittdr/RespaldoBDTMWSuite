SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_validation_group]
(
@id int,
@eff_from datetime,
@eff_to datetime
)

AS

/* Change Control

TGRIFFIT 38797 11/23/2007 created this stored procedure. This will be the datasource for the d_validation_group_info dw (dw in w_validation_company_groups) and also d_validation_grp_for_dddw.

*/
    BEGIN
        IF @id = 0
            SELECT valg_id,
                valg_name,
                valg_effective_from,
                valg_effective_to,
                valg_failure_section_id,
                valg_description,
                valg_create_user,
                valg_create_date,
                valg_update_user,
                valg_update_date
            FROM validation_group
            WHERE valg_effective_from >= @eff_from
            AND valg_effective_to <= @eff_to
        ELSE
            SELECT valg_id,
                valg_name,
                valg_effective_from,
                valg_effective_to,
                valg_failure_section_id,
                valg_description,
                valg_create_user,
                valg_create_date,
                valg_update_user,
                valg_update_date
            FROM validation_group
            WHERE valg_id = @id
         
    END
GO
GRANT EXECUTE ON  [dbo].[d_validation_group] TO [public]
GO
