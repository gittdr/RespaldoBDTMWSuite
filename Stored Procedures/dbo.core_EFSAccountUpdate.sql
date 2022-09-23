SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_EFSAccountUpdate]
    	@efs_account_efs_account_number varchar (10), 
	@efs_account_efs_auto_update_trip_flag char (1),
	@efs_account_efs_auto_unassign_trip_flag char (1),
	@efs_account_efs_auto_update_tractor_flag char (1),
	@efs_account_efs_auto_unassign_tractor_flag char (1),
	@efs_account_efs_auto_update_trailer_flag char (1),
	@efs_account_efs_auto_unassign_trailer_flag char (1),
	@efs_account_efs_auto_update_driver_flag char (1),
	@efs_account_efs_auto_unassign_driver_flag char (1),
	@efs_account_efs_inactive_trip_card_status varchar (6),
	@efs_account_efs_default_assignment varchar (6)
AS
	UPDATE [efs_account]
	SET
	    efs_auto_update_trip_flag = @efs_account_efs_auto_update_trip_flag,
	    efs_auto_unassign_trip_flag = @efs_account_efs_auto_unassign_trip_flag,
	    efs_auto_update_tractor_flag = @efs_account_efs_auto_update_tractor_flag,
	    efs_auto_unassign_tractor_flag = @efs_account_efs_auto_unassign_tractor_flag,
	    efs_auto_update_trailer_flag = @efs_account_efs_auto_update_trailer_flag,
	    efs_auto_unassign_trailer_flag = @efs_account_efs_auto_unassign_trailer_flag,
	    efs_auto_update_driver_flag = @efs_account_efs_auto_update_driver_flag,
	    efs_auto_unassign_driver_flag = @efs_account_efs_auto_unassign_driver_flag,
	    efs_inactive_trip_card_status = @efs_account_efs_inactive_trip_card_status,
	    efs_default_assignment = @efs_account_efs_default_assignment,
	    efs_updated_on = GetDate (),
	    efs_updated_by = user,
	    efs_created_date = GetDate ()
	WHERE 	efs_account_number = @efs_account_efs_account_number

GO
GRANT EXECUTE ON  [dbo].[core_EFSAccountUpdate] TO [public]
GO
