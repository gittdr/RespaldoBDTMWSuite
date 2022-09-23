SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE     Procedure [dbo].[DriverAwareSuite_UpdateDriverMisc] (@DriverID varchar(255),@Misc varchar(255))

As

Set NOCount On

if exists (select mpp_id from DriverAwareSuite_Information where mpp_id = @DriverID)

	Update DriverAwareSuite_Information
	Set    misc1 = @Misc
	Where  mpp_id = @DriverID
else
	Insert into DriverAwareSuite_Information (mpp_id,misc1) Values (@DriverID,@Misc)
    
	




GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_UpdateDriverMisc] TO [public]
GO
