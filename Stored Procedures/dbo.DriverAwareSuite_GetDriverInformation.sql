SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE     Procedure [dbo].[DriverAwareSuite_GetDriverInformation] (@DriverID varchar(255))

As

Set NOCount On

Select misc1,extendedopsnotes,misc1date,extdopsnotesdate
From   DriverAwareSuite_Information (NOLOCK)
Where  mpp_id = @DriverID
    
	














GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetDriverInformation] TO [public]
GO
