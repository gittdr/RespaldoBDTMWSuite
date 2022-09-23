SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec tm_GetCabUnits 8, '112233 , !PEOPLENET' 
Create PROCEDURE [dbo].[tm_GetCabUnits]
	@CabType int,
  @CheckList VARCHAR(4000) = ''
/*******************************************************************************************************************  
  Object Description:
    Pulls a CabUnit value list base on a Type

  Revision History:
  Date         Name              Label/PTS    Description
  -----------  ---------------   ----------  ----------------------------------------
  2012/03/12   Jennifer White    PTS 62089    Created for Get CabUnit Value view 
  2014/09/17   Harry Abramowski  PTS 79508    order by added to make finding duplicate IDs possible in code
  2016/10/05   W. Riley Wolfe    PTS 105559   Get RouteSyncEnabled and AssetName. Used by tmailxfc
********************************************************************************************************************/
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

Declare @tmp AS TABLE(value VARCHAR(100));

INSERT INTO @tmp
SELECT value
FROM tm_CSVStringToVarcharTable(@CheckList)

IF COALESCE(@CheckList, '') = ''
	SELECT tblCabUnits.SN,
		UnitID,
		MCPassword,
		COALESCE(tblCabUnits.EnableZippedBlobs, 0) EnableZippedBlobs,
		COALESCE(tblTrucks.GroupFlag, 0) GroupFlag,
    COALESCE(tblCabUnits.RouteSyncEnabled, 0) RouteSyncEnabled,
		COALESCE(tblTrucks.TruckName, tbldrivers.NAME) AssetName
	FROM tblCabUnits
	LEFT JOIN tblTrucks ON (
			tblCabUnits.LinkedObjSN = tblTrucks.SN
			AND tblCabUnits.LinkedAddrType = 4
			)
	LEFT JOIN tblDrivers ON (
			tblCabUnits.LinkedObjSN = tblDrivers.SN
			AND tblCabUnits.LinkedAddrType = 5
			)
	WHERE [Type] = @CabType
	ORDER BY UnitID;
ELSE
	SELECT tblCabUnits.SN,
		UnitID,
		MCPassword,
		COALESCE(tblCabUnits.EnableZippedBlobs, 0) EnableZippedBlobs,
		COALESCE(tblTrucks.GroupFlag, 0) GroupFlag,
    COALESCE(tblCabUnits.RouteSyncEnabled, 0) RouteSyncEnabled,
		COALESCE(tblTrucks.TruckName, tbldrivers.NAME) AssetName
	FROM tblCabUnits
	LEFT JOIN tblTrucks ON (
			tblCabUnits.LinkedObjSN = tblTrucks.SN
			AND tblCabUnits.LinkedAddrType = 4
			)
	LEFT JOIN tblDrivers ON (
			tblCabUnits.LinkedObjSN = tblDrivers.SN
			AND tblCabUnits.LinkedAddrType = 5
			)
	WHERE [Type] = @CabType
		AND Exists(SELECT 1 FROM @tmp WHERE UnitID = value)
	ORDER BY UnitID;

GO
GRANT EXECUTE ON  [dbo].[tm_GetCabUnits] TO [public]
GO
