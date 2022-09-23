SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_MetricHelper_PayForLeg]
	(@lgh_number int)

RETURNS Money
AS
BEGIN


Declare @LegPay Money
Set @LegPay =(Select sum(pyd_amount) from paydetail (NOLOCK) where lgh_number=@lgh_number and pyd_pretax ='Y')

Return @LegPay


END
GO
