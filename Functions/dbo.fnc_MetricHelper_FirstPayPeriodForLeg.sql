SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_MetricHelper_FirstPayPeriodForLeg]
	(@lgh_number int)

RETURNS Datetime
AS
BEGIN


Declare @FirstPayPeriod Datetime
Set @FirstPayPeriod  =(Select Min(pyh_payperiod) from paydetail (NOLOCK) where lgh_number=@lgh_number)

Return @FirstPayPeriod
--select * from paydetail

END
GO
