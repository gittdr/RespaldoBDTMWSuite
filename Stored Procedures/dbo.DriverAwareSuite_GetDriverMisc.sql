SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE    Procedure [dbo].[DriverAwareSuite_GetDriverMisc] (@DriverID varchar(255))

As

Set NOCount On

Select misc1
From   DriverAwareSuite_Information (NOLOCK)
Where  mpp_id = @DriverID
    
	














GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetDriverMisc] TO [public]
GO
