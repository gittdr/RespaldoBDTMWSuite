SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_admin_trucks_not_in_group]   @LoginID varchar(15), @mcommgroup int

AS

DECLARE @cmd nvarchar(600) -- Holds the SQL statement

CREATE TABLE #T1 (TruckName varchar(15), SN int, DefaultCabUnit int)

IF (UPPER(@LoginID) = 'ADMIN')  -- Admin
	-- Pull all tractors that aren't a group
	--  and that have a default cab unit defined
	SET @cmd = 'INSERT INTO #T1 (TruckName, SN, DefaultCabUnit) 
				SELECT tblTrucks.TruckName, tblTrucks.SN, tblTrucks.DefaultCabUnit
				FROM tblTrucks (NOLOCK)
				WHERE tblTrucks.GroupFlag = 0
					AND ISNULL(tblTrucks.DefaultCabUnit,0) <> 0'
ELSE  -- Not admin
	-- Pull all tractors that this login has Content Admin rights to 
	--  that have a default cab unit defined.
	SET @cmd = 'INSERT INTO #T1 (TruckName, SN, DefaultCabUnit) 
			SELECT DISTINCT(tblFilterElement.fel_value), tblTrucks.SN, tblTrucks.DefaultCabUnit
			FROM tblFilters (NOLOCK), tblFilterElement (NOLOCK), tblTrucks (NOLOCK)
			WHERE tblFilters.flt_LoginID = ' + '''' + @LoginID + '''' + '
				AND ISNULL(tblFilters.flt_Name,' + ''''  + '''' + ') = ' + '''' + '''' + '
				AND tblFilters.flt_SN = tblFilterElement.flt_SN
				AND tblFilterElement.fel_Type = ''TruckId''
				AND tblFilterElement.fel_NoContent = 0	
				AND tblFilterElement.fel_Value = tblTrucks.TruckName
				AND ISNULL(tblTrucks.DefaultCabUnit,0) <> 0		
				AND tblTrucks.GroupFlag = 0'				

-- Execute the sql
EXEC sp_executesql @cmd

-- Delete any that are already a member of this group
--  and that aren't in the process of being removed
--  from this group.
DELETE FROM #T1
FROM tblcabunits (NOLOCK), tblcabunitgroups (NOLOCK)
WHERE tblcabunitgroups.groupcabsn = @mcommgroup
  AND tblcabunitgroups.Membercabsn = tblcabunits.sn
  AND #T1.DefaultCabUnit = tblcabunits.SN
  AND tblCabUnitGroups.Deleted = 0

SELECT TruckName, SN
FROM #T1
GO
GRANT EXECUTE ON  [dbo].[tm_admin_trucks_not_in_group] TO [public]
GO
