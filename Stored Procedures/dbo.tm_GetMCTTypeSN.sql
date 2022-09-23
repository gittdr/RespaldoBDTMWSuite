SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GetMCTTypeSN] @Tractor varchar(13)

AS

-- 06/31/03 MZ - Created 
-- 08/25/06 MZ - PTS34256 - Pull MCT Instance ID

SET NOCOUNT ON

IF NOT EXISTS (SELECT m.* FROM tblCabUnits m INNER JOIN tblTrucks t ON m.SN = t.DefaultCabUnit WHERE t.TruckName = @Tractor)
  BEGIN
	RAISERROR ('Not able to find MCT for tractor: %s',16,1, @Tractor)
	RETURN 1	
  END
ELSE
	SELECT  ISNULL(tblCabUnits.Type, 0) MCTType,
		ISNULL(tblCabUnits.InstanceId, 1) InstanceId
	FROM tblCabUnits (NOLOCK)
	INNER JOIN tblTrucks (NOLOCK) ON tblCabUnits.SN = tblTrucks.DefaultCabUnit 
	WHERE tblTrucks.TruckName = @Tractor
GO
GRANT EXECUTE ON  [dbo].[tm_GetMCTTypeSN] TO [public]
GO
