SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_logins_not_in_group] @GroupName varchar(15)

AS

SET NOCOUNT ON

CREATE TABLE #T1 (LoginName varchar(15), SN int)


-- Get a list of all Logins
INSERT INTO #T1 (LoginName, SN) 
SELECT tblLogin.LoginName, tblLogin.SN
FROM tbllogin (NOLOCK)
WHERE LoginName <> 'Admin'

-- Delete any that are already a member of this group
DELETE FROM #T1
FROM tblFilters, tblFilterElement
WHERE #T1.LoginName = tblFilters.flt_LoginID
	AND tblFilters.flt_SN = tblFilterElement.flt_SN
	AND ISNULL(tblFilters.flt_Name,'') = ''	-- Make sure it's the admin filter
	AND tblFilterElement.fel_Type = 'TruckGroup'
	AND tblFilterElement.fel_Value = @GroupName
	AND (tblFilterElement.fel_NoView = 0
		OR tblFilterElement.fel_NoRead = 0
		OR tblFilterElement.fel_NoSend = 0
		OR tblFilterElement.fel_NoOwner = 0
		OR tblFilterElement.fel_NoContent = 0)

SELECT LoginName, SN
FROM #T1
GO
GRANT EXECUTE ON  [dbo].[tm_logins_not_in_group] TO [public]
GO
