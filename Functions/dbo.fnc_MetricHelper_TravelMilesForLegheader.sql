SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_MetricHelper_TravelMilesForLegheader]
	(@lgh_number int)

RETURNS Float
AS
BEGIN

Declare @LghMiles float

Set @LghMiles=
	ISNULL(
		(Select Sum(stp_lgh_mileage)
		From Stops (NOLOCK)
		where 
			stops.lgh_number=@lgh_number
		)
	,0)

Return @LghMiles


END
GO
