SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_MetricHelper_BillableMilesForLegheader]
	(@lgh_number int)

RETURNS Float
AS
BEGIN

Declare @LghMiles float

Set @LghMiles=
	ISNULL(
		(Select Sum(stp_ord_mileage)
		From Stops (NOLOCK)
		where 
			stops.lgh_number=@lgh_number
		)
	,0)

Return @LghMiles


END
GO
