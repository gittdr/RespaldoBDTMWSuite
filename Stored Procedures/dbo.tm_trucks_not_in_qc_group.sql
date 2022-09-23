SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_trucks_not_in_qc_group]
	@mcommtype int,
	@mcommgroup int,
	@limit int		
AS

/**
 * 
 * NAME:
 * dbo.tm_trucks_not_in_qc_group
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 *	get trucks not in mcommgroup
 *
 * RETURNS:
 *  TruckName, SN, UnitID, Vendor, MobileCommType
 * 
 * PARAMETERS:
 *	@mcommtype int,
 *	@mcommgroup int,
 *	@limit int	
 * 
 * Change Log: 
 * 07/29/2013 - PTS64925 - APC - added comment section
 *
 **/
 
SET NOCOUNT ON

DECLARE @cmd nvarchar(1000) -- Holds the SQL statement
	/* For Testing
	DECLARE @limit int
	SET @limit = 1
	*/
--
-- 'DWG {35395}  Restricted so that retired trucks are not retrieved
--

CREATE TABLE #T1 (TruckName varchar(15), SN int, DefaultCabUnit int, UnitID varchar(50), Vendor Varchar(50), MobileCommType Varchar(50))

-- First pull all valid tractors for this group type
IF (@mcommtype = 1)  -- Qualcomm group
	-- Pull all tractors that aren't a group
	--  and that have a QualComm MCT
	SET @cmd = 'INSERT INTO #T1 (TruckName, SN, DefaultCabUnit, UnitID, Vendor, MobileCommType) 
				SELECT tblTrucks.TruckName, tblTrucks.SN, tblTrucks.DefaultCabUnit, UnitID, CASE ISNULL(DisplayName, '''') WHEN '''' THEN MobileCommType ELSE DisplayName END Vendor , MobileCommType
				FROM tbltrucks (NOLOCK), tblCabUnits (NOLOCK), tblMobileCommType (NOLOCK)
				WHERE tblTrucks.GroupFlag = 0
				  AND tblTrucks.DefaultCabUnit = tblCabUnits.SN
				  AND tblCabUnits.Type = tblMobileCommType.SN
				  AND tblMobileCommType.MobileCommType = ''QualComm''
				  AND tblTrucks.Retired = 0'

ELSE 
	-- Pull all tractors that aren't a group 
	--  and that have any kind of MCT in them
	SET @cmd = 'INSERT INTO #T1 (TruckName, SN, DefaultCabUnit, UnitID, Vendor, MobileCommType) 
				SELECT tblTrucks.TruckName, tblTrucks.SN, tblTrucks.DefaultCabUnit,UnitID, CASE ISNULL(DisplayName, '''') WHEN '''' THEN MobileCommType ELSE DisplayName END Vendor, MobileCommType
				FROM tblTrucks (NOLOCK), tblCabUnits (NOLOCK), tblMobileCommType (NOLOCK)
				WHERE tblTrucks.GroupFlag = 0 
				  AND ISNULL(tblTrucks.DefaultCabUnit,-1) <> -1
				  AND tblTrucks.DefaultCabUnit = tblCabUnits.SN
				  AND tblCabUnits.Type = tblMobileCommType.SN
				  AND tblTrucks.Retired = 0'

-- Execute the sql
EXEC sp_executesql @cmd

-- Delete any that are already a member of this group
--  and that aren't in the process of being removed
--  from this group.
DELETE FROM #T1
FROM tblcabunits, tblcabunitgroups
WHERE tblcabunitgroups.groupcabsn = @mcommgroup
  AND tblcabunitgroups.Membercabsn = tblcabunits.sn
  AND #T1.DefaultCabUnit = tblcabunits.SN
  AND tblCabUnitGroups.Deleted = 0

-- If limit = 1, then remove any tractors that are already
--  in 2 groups.
IF (@mcommtype = 1)
  BEGIN
	-- Count how many groups each MCT is in
	--  not counting groups it has been removed from
	--  and not counting non-mobile comm groups
	SELECT membercabSN, COUNT(membercabsn) kount
	INTO #temp
	FROM tblCabUnitGroups (NOLOCK), tblTrucks (NOLOCK)
	WHERE tblCabUnitGroups.Deleted <> 1
	  AND tblCabUnitGroups.GroupCabSN = tblTrucks.DefaultCabUnit
	  AND tblTrucks.GroupFlag = 1
	GROUP BY membercabsn

	-- Delete any that are in less than limit
	DELETE #temp
	WHERE kount < @limit

	-- Delete the appropriate truck for each MCT that
	--  is in at least the limit from #T1
	DELETE #T1 
	FROM #T1, #temp, tbltrucks
	WHERE #temp.membercabsn = tbltrucks.defaultcabunit
  	  AND tbltrucks.sn = #T1.SN
  END

SELECT TruckName, SN, UnitID, Vendor, MobileCommType
FROM #T1
ORDER BY TruckName

GO
GRANT EXECUTE ON  [dbo].[tm_trucks_not_in_qc_group] TO [public]
GO
