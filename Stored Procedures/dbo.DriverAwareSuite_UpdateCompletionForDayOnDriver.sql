SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE  Procedure [dbo].[DriverAwareSuite_UpdateCompletionForDayOnDriver] (@DriverID varchar(255),@CompletedForDay int =0)

As

if not exists (select mpp_id from DriverAwareSuite_Information where mpp_id = @DriverID)
Begin

      INSERT INTO DriverAwareSuite_Information (mpp_id,lastviolationdate) Values (@DriverID ,@CompletedForDay)
       
End
Else
Begin
      Update DriverAwareSuite_Information Set CompletedForDay = @CompletedForDay
      Where mpp_id = @DriverID
End




GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_UpdateCompletionForDayOnDriver] TO [public]
GO
