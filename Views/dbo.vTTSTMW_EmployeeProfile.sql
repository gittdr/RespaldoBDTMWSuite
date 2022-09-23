SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE View [dbo].[vTTSTMW_EmployeeProfile]

As


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
	ee_terminationdt [Termination Date],
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

From    EmployeeProfile (NOLOCK)


GO
GRANT SELECT ON  [dbo].[vTTSTMW_EmployeeProfile] TO [public]
GO
