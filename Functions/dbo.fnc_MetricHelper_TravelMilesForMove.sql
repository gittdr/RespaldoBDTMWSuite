SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_MetricHelper_TravelMilesForMove]
	(@Mov_number int)

RETURNS Float
AS
BEGIN

Declare @MoveMiles float

Set @MoveMiles=
	ISNULL(
		(Select Sum(stp_lgh_mileage)
		From Stops (NOLOCK)
		where 
			stops.Mov_number=@Mov_number
		)
	,0)

Return @MoveMiles


END
GO
