SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE     Procedure [dbo].[DriverAwareSuite_UpdateDriverInformation] (@DriverID varchar(255),@Misc varchar(255),@ExtendedOpsNotes varchar(255))

As

Set NOCount On

if exists (select mpp_id from DriverAwareSuite_Information where mpp_id = @DriverID)

	Update DriverAwareSuite_Information
	Set    misc1 = @Misc,
	       extendedopsnotes = @ExtendedOpsNotes,
	       misc1date = Case When IsNull(misc1,'') <> ISNull(@Misc,'') Then getdate() else misc1date end,
	       extdopsnotesdate = Case When IsNull(extendedopsnotes,'') <> ISNull(@ExtendedOpsNotes,'') Then getdate() else extdopsnotesdate end 
	Where  mpp_id = @DriverID
else
	Insert into DriverAwareSuite_Information (mpp_id,misc1,extendedopsnotes,misc1date,extdopsnotesdate) Values (@DriverID,@Misc,@ExtendedOpsNotes,getdate(),getdate())
    




GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_UpdateDriverInformation] TO [public]
GO
