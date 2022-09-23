SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Adam Skinner
-- Create date: 2014-11-07
-- Description:	Get carrier lanes from origin to destination.
-- =============================================
CREATE PROCEDURE [dbo].[LaneRateMatrixOriginToDestinationCarrierLanes]	@originType varchar(50), 
																@originValue varchar(50), 
																@destinationType varchar(50), 
																@destinationValue varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	select distinct lrm.CarrierId, lrm.LaneId
	from dbo.core_LaneRateMatrix lrm
		inner join fn_LaneRateMatrixOriginToDestinationRateIds(@originType, @originValue, @destinationType, @destinationValue) t on t.Id = lrm.Id
		
END
GO
GRANT EXECUTE ON  [dbo].[LaneRateMatrixOriginToDestinationCarrierLanes] TO [public]
GO
