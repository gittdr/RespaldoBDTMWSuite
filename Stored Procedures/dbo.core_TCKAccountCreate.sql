SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[core_TCKAccountCreate]
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
INSERT INTO [tck_account] (
    tck_account_number, 
    tck_auto_update_trip_flag,
    tck_auto_unassign_trip_flag,
    tck_auto_update_tractor_flag,
    tck_auto_unassign_tractor_flag,
    tck_auto_update_trailer_flag,
    tck_auto_unassign_trailer_flag,
    tck_auto_update_driver_flag,
    tck_auto_unassign_driver_flag,
    tck_inactive_trip_card_status,
    tck_force_cash_advance_flag,
    tck_allow_off_network_flag,
    tck_allow_volume_override,
    tck_default_assignment,
    tck_driver_required_flag,
    tck_drivercdl_required_flag,
    tck_tractor_required_flag,
    tck_trailer_required_flag,
    tck_advance_paytype,
    tck_debitdollar_paytype,
    tck_updated_on,
    tck_updated_by,
    tck_created_date)
VALUES (
    @tck_account_tck_account_number, 
    @tck_account_tck_auto_update_trip_flag,
    @tck_account_tck_auto_unassign_trip_flag,
    @tck_account_tck_auto_update_tractor_flag,
    @tck_account_tck_auto_unassign_tractor_flag,
    @tck_account_tck_auto_update_trailer_flag,
    @tck_account_tck_auto_unassign_trailer_flag,
    @tck_account_tck_auto_update_driver_flag,
    @tck_account_tck_auto_unassign_driver_flag,
    @tck_account_tck_inactive_trip_card_status,
    @tck_account_tck_force_cash_advance_flag,
    @tck_account_tck_allow_off_network_flag,
    @tck_account_tck_allow_volume_override,
    @tck_account_tck_default_assignment,
    @tck_account_tck_driver_required_flag,
    @tck_account_tck_drivercdl_required_flag,
    @tck_account_tck_tractor_required_flag,
    @tck_account_tck_trailer_required_flag,
    @tck_account_tck_advance_paytype,
    @tck_account_tck_debitdollar_paytype,
    GetDate(),
    user,
    GetDate()
)


IF NOT Exists (select cac_id from cdacctcode where cac_id = @tck_account_tck_account_number)
Begin
    insert into [cdacctcode] (cac_id, cac_description, cac_company, cfb_xfacetype)
    values (@tck_account_tck_account_number, 'T-Chek Account', 'UNK', 9)
End

IF NOT Exists (select ccc_id from cdcustcode where cac_id = @tck_account_tck_account_number and ccc_id = 'UNKNOWN')
Begin
    insert into [cdcustcode] (cac_id, ccc_id, ccc_description, ccc_company)
    values (@tck_account_tck_account_number, 'UNKNOWN', 'T-Chek Dummy Account', 'UNK')
End

SELECT tck_updated_on,
    tck_updated_by,
    tck_created_date
FROM [tck_account]
WHERE tck_account_number = @tck_account_tck_account_number

GO
GRANT EXECUTE ON  [dbo].[core_TCKAccountCreate] TO [public]
GO
