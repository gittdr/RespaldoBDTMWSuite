SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vSSRSRB_EmployeeProfile]
As

/*************************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_EmployeeProfile]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View based on the old vttstmw_EmployeeProfile
 *
**************************************************************************

Sample call

SELECT * FROM [vSSRSRB_EmployeeProfile]

**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Recordset (view)
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 DW created view
 ***********************************************************/

Select
	ee_ID [Employee ID],
	ee_firstname [First Name],
	ee_middleinit [Middle Initial],
	ee_lastname [Last Name],	
	ee_ssn [SSN],
	ee_address1 [Address1],
	ee_address2 [Address2],
	ee_city [City],
	ee_Ctynmstct [City State],
	ee_state [State],
	ee_zip [Zip Code],
	ee_Country [Country],
	ee_Terminal [Terminal],
	ee_supervisorID [Supervisor ID],
	ee_hiredate [Hire Date],
	(Cast(Floor(Cast(ee_hiredate as float))as smalldatetime)) AS [Hire Date Only],
	ee_terminationdt [Termination Date],
	(Cast(Floor(Cast(ee_terminationdt as float))as smalldatetime)) AS [Termination Date Only],
	ee_active [Active],
	ee_dateofbirth [DateOfBirth],
	ee_workphone [Work Phone],
	ee_homephone [Home Phone],
	ee_title [Title],
	ee_nbrdependents [Nbr Dependents],
	ee_worklocation [Work Location],
	ee_managementlevel [Management Level],
	ee_emername [Emergency Name],
	ee_emerphone [Emergency Phone],
	ee_licensenumber [License Number],
	ee_Licensestate [License State],
	ee_gender [Gender],
	ee_maritalstatus [Marital Status],
	ee_occupation [Occupation],
	ee_workstate [Work State]
FROM EmployeeProfile WITH (NOLOCK)

GO
GRANT SELECT ON  [dbo].[vSSRSRB_EmployeeProfile] TO [public]
GO
