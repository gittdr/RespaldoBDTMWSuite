SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_MetricHelper_PayForMove]
	(@mov_number int)

RETURNS Money
AS
BEGIN

Declare @MovePay Money

Set @MovePay=
	(Select sum(pyd_amount) 
	from paydetail p (NOLOCK), Legheader l (NOLOCK)
	where 	l.mov_number=@Mov_Number
		and
		p.lgh_number=l.lgh_number
		and
		p.pyd_pretax='Y'
	)

Return @MovePay


END
GO
