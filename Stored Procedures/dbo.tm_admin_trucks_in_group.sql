SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_admin_trucks_in_group] @LoginID varchar(15), @mcommgroup int


AS

CREATE TABLE #T1 (TruckName varchar(15), SN int, DefaultCabUnit int, NoContent int)

-- Get all tractors in this group
-- We default the NoContent = 1 (no ownership of this tractor)
INSERT INTO #T1 (SN, TruckName, DefaultCabUnit, NoContent)
SELECT tblTrucks.SN, tblTrucks.TruckName, ISNULL(tblTrucks.DefaultCabUnit,0), 1
FROM tblCabUnits (NOLOCK), tblCabUnitGroups(NOLOCK), tblTrucks (NOLOCK)
WHERE tblTrucks.DefaultCabUnit = tblCabUnits.SN
 AND tblCabUnitGroups.GroupCabSN = @mcommgroup
 AND tblCabUnitGroups.MemberCabSN = tblCabUnits.SN
 AND tblCabUnitGroups.Deleted = 0

-- Get the actual NoContent value from tblFilterElement
UPDATE #T1
SET #T1.NoContent = tblFilterElement.fel_NoContent
FROM tblFilters (NOLOCK), tblFilterElement (NOLOCK)
WHERE tblFilters.flt_LoginID = @LoginID
 AND ISNULL(tblFilters.flt_Name,'') = ''
 AND tblFilterElement.flt_SN = tblFilters.flt_SN
 AND #T1.TruckName = tblFilterElement.fel_Value 
 AND tblFilterElement.fel_Type = 'TruckID'

-- If user is Admin, then change NoOwner to 0
IF UPPER(@LoginID) = 'ADMIN'
	UPDATE #T1
	SET NoContent = 0

-- Return results
SELECT SN, TruckName, DefaultCabUnit, NoContent
FROM #T1
GO
GRANT EXECUTE ON  [dbo].[tm_admin_trucks_in_group] TO [public]
GO
