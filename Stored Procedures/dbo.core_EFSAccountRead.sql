SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSAccountRead]
    @efs_account_efs_account_number varchar (10)
AS
	SELECT 
	efs_account_number as efs_account_efs_account_number, 
	efs_auto_update_trip_flag as efs_account_efs_auto_update_trip_flag, 
	efs_auto_unassign_trip_flag as efs_account_efs_auto_unassign_trip_flag,
	efs_auto_update_tractor_flag as efs_account_efs_auto_update_tractor_flag,
	efs_auto_unassign_tractor_flag  as efs_account_efs_auto_unassign_tractor_flag,
	efs_auto_update_trailer_flag  as efs_account_efs_auto_update_trailer_flag,
	efs_auto_unassign_trailer_flag  as efs_account_efs_auto_unassign_trailer_flag,
	efs_auto_update_driver_flag  as efs_account_efs_auto_update_driver_flag,
	efs_auto_unassign_driver_flag  as efs_account_efs_auto_unassign_driver_flag,
	efs_inactive_trip_card_status  as efs_account_efs_inactive_trip_card_status,
	efs_default_assignment  as efs_account_efs_default_assignment,
	efs_updated_on  as efs_account_efs_updated_on,
	efs_updated_by  as efs_account_efs_updated_by,
	efs_created_date  as efs_account_efs_created_date
	FROM [efs_account]
	WHERE 	efs_account_number = @efs_account_efs_account_number

	select 
	cac_id as cdcustcode_cac_id,
	ccc_id as cdcustcode_ccc_id,
	ccc_description as cdcustcode_ccc_description
	from cdcustcode
	where cac_id = @efs_account_efs_account_number

GO
GRANT EXECUTE ON  [dbo].[core_EFSAccountRead] TO [public]
GO
