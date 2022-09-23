SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE       Function [dbo].[fnc_TMWRN_TotalDriverExpirationsForWeek] (@BeginDayOfWeek datetime,@EndDayOfWeek datetime,@DriverID varchar(150),@PriorityStatus varchar(150)= '9')
Returns int
As
Begin	

Declare @ExpirationCount int


SELECT @PriorityStatus = Case When Left(@PriorityStatus ,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@PriorityStatus , ''))) + ',' Else @PriorityStatus  End

Set @ExpirationCount = 0

While @BeginDayOfWeek <> (@EndDayofWeek+1)
Begin
	Set @ExpirationCount = @ExpirationCount + IsNull((Select Min(1) from Expiration (NOLOCK) Where (@PriorityStatus = ',,' OR CHARINDEX(',' + exp_priority + ',', @PriorityStatus) > 0) 
													and  
													exp_id = @DriverID and exp_idtype = 'DRV' 
													and 
													(  @BeginDayOfWeek between Cast(Floor(Cast(exp_expirationdate as float))as smalldatetime) and Cast(Floor(Cast(exp_compldate as float))as smalldatetime))),0)


	Set @BeginDayOfWeek = @BeginDayOfWeek + 1
End

Return @ExpirationCount
End






GO
