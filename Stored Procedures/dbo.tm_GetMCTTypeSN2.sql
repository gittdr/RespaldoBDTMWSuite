SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GetMCTTypeSN2] @Tractor varchar(13), @Driver varchar(50), @ToType varchar(10)

AS

-- 06/31/03 MZ - Created 
-- 08/25/06 MZ - PTS34256 - Pull MCT Instance ID

SET NOCOUNT ON

DECLARE @lToType int

IF ISNUMERIC(@ToType) <> 0 SELECT @lToType = CONVERT(int, @ToType)
ELSE SELECT @lToType = 4

IF @lToType <> 5 AND EXISTS (SELECT m.* 
								FROM tblCabUnits m (NOLOCK)
								INNER JOIN tblTrucks t (NOLOCK) ON m.SN = t.DefaultCabUnit 
								WHERE t.TruckName = @Tractor)
	SELECT  ISNULL(tblCabUnits.Type, 0) MCTType,
		ISNULL(tblCabUnits.InstanceId, 1) InstanceId,
		ISNULL(tblCabUnits.UnitID, '') UnitID
	FROM tblCabUnits (NOLOCK)
	INNER JOIN tblTrucks (NOLOCK) ON tblCabUnits.SN = tblTrucks.DefaultCabUnit 
	WHERE tblTrucks.TruckName = @Tractor
ELSE IF EXISTS (SELECT m.* 
				FROM tblCabUnits m (NOLOCK)
				INNER JOIN tblDrivers d (NOLOCK) ON m.SN = d.DefaultCabUnit 
				WHERE d.Name = @Driver)
	SELECT  ISNULL(tblCabUnits.Type, 0) MCTType,
		ISNULL(tblCabUnits.InstanceId, 1) InstanceId,
		ISNULL(tblCabUnits.UnitID, '') UnitID
	FROM tblCabUnits (NOLOCK)
	INNER JOIN tblDrivers d (NOLOCK) ON tblCabUnits.SN = d.DefaultCabUnit 
	WHERE d.Name = @Driver
ELSE IF @lToType = 5 AND EXISTS (SELECT m.* 
								FROM tblCabUnits m (NOLOCK) 
								INNER JOIN tblTrucks t (NOLOCK) ON m.SN = t.DefaultCabUnit 
								WHERE t.TruckName = @Tractor)
	SELECT  ISNULL(tblCabUnits.Type, 0) MCTType,
		ISNULL(tblCabUnits.InstanceId, 1) InstanceId,
		ISNULL(tblCabUnits.UnitID, '') UnitID
	FROM tblCabUnits (NOLOCK)
	INNER JOIN tblTrucks (NOLOCK) ON tblCabUnits.SN = tblTrucks.DefaultCabUnit 
	WHERE tblTrucks.TruckName = @Tractor
ELSE
  BEGIN
	RAISERROR ('Not able to find MCT for tractor: %s or Driver %s',16,1, @Tractor, @Driver)
	RETURN 1	
  END
GO
GRANT EXECUTE ON  [dbo].[tm_GetMCTTypeSN2] TO [public]
GO
