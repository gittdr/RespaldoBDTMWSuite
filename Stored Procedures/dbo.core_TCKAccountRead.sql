SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_TCKAccountRead]
    @tck_account_tck_account_number varchar (10)
AS
	SELECT 
	tck_account_number as tck_account_tck_account_number, 
	tck_auto_update_trip_flag as tck_account_tck_auto_update_trip_flag, 
	tck_auto_unassign_trip_flag as tck_account_tck_auto_unassign_trip_flag,
	tck_auto_update_tractor_flag as tck_account_tck_auto_update_tractor_flag,
	tck_auto_unassign_tractor_flag  as tck_account_tck_auto_unassign_tractor_flag,
	tck_auto_update_trailer_flag  as tck_account_tck_auto_update_trailer_flag,
	tck_auto_unassign_trailer_flag  as tck_account_tck_auto_unassign_trailer_flag,
	tck_auto_update_driver_flag  as tck_account_tck_auto_update_driver_flag,
	tck_auto_unassign_driver_flag  as tck_account_tck_auto_unassign_driver_flag,
	tck_inactive_trip_card_status  as tck_account_tck_inactive_trip_card_status,
	tck_force_cash_advance_flag  as tck_account_tck_force_cash_advance_flag,
	tck_allow_off_network_flag  as tck_account_tck_allow_off_network_flag,
	tck_allow_volume_override  as tck_account_tck_allow_volume_override,
	tck_default_assignment  as tck_account_tck_default_assignment,
	tck_driver_required_flag as tck_account_tck_driver_required_flag,
	tck_drivercdl_required_flag as tck_account_tck_drivercdl_required_flag,
	tck_tractor_required_flag as tck_account_tck_tractor_required_flag,
	tck_trailer_required_flag as tck_account_tck_trailer_required_flag,
	tck_advance_paytype as tck_account_tck_advance_paytype,
    	tck_debitdollar_paytype as tck_account_tck_debitdollar_paytype,
	tck_updated_on  as tck_account_tck_updated_on,
	tck_updated_by  as tck_account_tck_updated_by,
	tck_created_date  as tck_account_tck_created_date
	FROM [tck_account]
	WHERE 	tck_account_number = @tck_account_tck_account_number

GO
GRANT EXECUTE ON  [dbo].[core_TCKAccountRead] TO [public]
GO
