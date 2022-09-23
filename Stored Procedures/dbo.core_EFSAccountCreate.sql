SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[core_EFSAccountCreate]
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
INSERT INTO [efs_account] (
    efs_account_number, 
    efs_auto_update_trip_flag,
    efs_auto_unassign_trip_flag,
    efs_auto_update_tractor_flag,
    efs_auto_unassign_tractor_flag,
    efs_auto_update_trailer_flag,
    efs_auto_unassign_trailer_flag,
    efs_auto_update_driver_flag,
    efs_auto_unassign_driver_flag,
    efs_inactive_trip_card_status,
    efs_default_assignment,
    efs_updated_on,
    efs_updated_by,
    efs_created_date)
VALUES (
    @efs_account_efs_account_number, 
    @efs_account_efs_auto_update_trip_flag,
    @efs_account_efs_auto_unassign_trip_flag,
    @efs_account_efs_auto_update_tractor_flag,
    @efs_account_efs_auto_unassign_tractor_flag,
    @efs_account_efs_auto_update_trailer_flag,
    @efs_account_efs_auto_unassign_trailer_flag,
    @efs_account_efs_auto_update_driver_flag,
    @efs_account_efs_auto_unassign_driver_flag,
    @efs_account_efs_inactive_trip_card_status,
    @efs_account_efs_default_assignment,
    GetDate(),
    user,
    GetDate()
)

IF NOT Exists (select cac_id from cdacctcode where cac_id = @efs_account_efs_account_number)
Begin
    insert into [cdacctcode] (cac_id, cac_description, cac_company, cfb_xfacetype)
    values (@efs_account_efs_account_number, 'EFS Account', 'UNK', 14)
End

-- IF NOT Exists (select ccc_id from cdcustcode where cac_id = @efs_account_efs_account_number and ccc_id = 'UNKNOWN')
-- Begin
--     insert into [cdcustcode] (cac_id, ccc_id, ccc_description, ccc_company)
--     values (@efs_account_efs_account_number, 'UNKNOWN', 'EFS Dummy Account', 'UNK')
-- End

SELECT efs_updated_on,
    efs_updated_by,
    efs_created_date
FROM [efs_account]
WHERE efs_account_number = @efs_account_efs_account_number
GO
GRANT EXECUTE ON  [dbo].[core_EFSAccountCreate] TO [public]
GO
