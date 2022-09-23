SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_TCKAccountUpdate]
    	@tck_account_tck_account_number varchar (10), 
	@tck_account_tck_auto_update_trip_flag char (1),
	@tck_account_tck_auto_unassign_trip_flag char (1),
	@tck_account_tck_auto_update_tractor_flag char (1),
	@tck_account_tck_auto_unassign_tractor_flag char (1),
	@tck_account_tck_auto_update_trailer_flag char (1),
	@tck_account_tck_auto_unassign_trailer_flag char (1),
	@tck_account_tck_auto_update_driver_flag char (1),
	@tck_account_tck_auto_unassign_driver_flag char (1),
	@tck_account_tck_inactive_trip_card_status varchar (6),
	@tck_account_tck_force_cash_advance_flag char (1),
	@tck_account_tck_allow_off_network_flag char (1),
	@tck_account_tck_allow_volume_override char (1),
	@tck_account_tck_default_assignment char (1),
	@tck_account_tck_driver_required_flag char (1),
	@tck_account_tck_drivercdl_required_flag char (1),
	@tck_account_tck_tractor_required_flag char (1),
	@tck_account_tck_trailer_required_flag char (1),
	@tck_account_tck_advance_paytype varchar (6),
	@tck_account_tck_debitdollar_paytype varchar (6)

AS
	UPDATE [tck_account]
	SET
	    tck_auto_update_trip_flag = @tck_account_tck_auto_update_trip_flag,
	    tck_auto_unassign_trip_flag = @tck_account_tck_auto_unassign_trip_flag,
	    tck_auto_update_tractor_flag = @tck_account_tck_auto_update_tractor_flag,
	    tck_auto_unassign_tractor_flag = @tck_account_tck_auto_unassign_tractor_flag,
	    tck_auto_update_trailer_flag = @tck_account_tck_auto_update_trailer_flag,
	    tck_auto_unassign_trailer_flag = @tck_account_tck_auto_unassign_trailer_flag,
	    tck_auto_update_driver_flag = @tck_account_tck_auto_update_driver_flag,
	    tck_auto_unassign_driver_flag = @tck_account_tck_auto_unassign_driver_flag,
	    tck_inactive_trip_card_status = @tck_account_tck_inactive_trip_card_status,
	    tck_force_cash_advance_flag = @tck_account_tck_force_cash_advance_flag,
	    tck_allow_off_network_flag = @tck_account_tck_allow_off_network_flag,
	    tck_allow_volume_override = @tck_account_tck_allow_volume_override,
	    tck_default_assignment = @tck_account_tck_allow_volume_override,
	    tck_driver_required_flag = @tck_account_tck_driver_required_flag,
	    tck_drivercdl_required_flag = @tck_account_tck_drivercdl_required_flag,
	    tck_tractor_required_flag = @tck_account_tck_tractor_required_flag,
	    tck_trailer_required_flag = @tck_account_tck_trailer_required_flag,
	    tck_advance_paytype = @tck_account_tck_advance_paytype,
    	    tck_debitdollar_paytype = @tck_account_tck_debitdollar_paytype,
	    tck_updated_on = GetDate (),
	    tck_updated_by = user,
	    tck_created_date = GetDate ()
	WHERE 	tck_account_number = @tck_account_tck_account_number


GO
GRANT EXECUTE ON  [dbo].[core_TCKAccountUpdate] TO [public]
GO
