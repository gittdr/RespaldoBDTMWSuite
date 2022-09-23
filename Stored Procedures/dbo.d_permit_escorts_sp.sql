SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_permit_escorts_sp] @PE_Name varchar(50)
As

SELECT	PE_ID, PE_Name, PE_Type, PE_Escort_Cost, PE_Contact, PE_Contact_Phone, PE_Contact_Fax, PE_Contact_Email, 
	PE_Contact2, PE_Contact2_Phone, PE_Contact2_Fax, PE_Contact2_Email, PE_Website, PE_Address1, PE_Address2, 
	PE_City, PE_City_nmstct, PE_Zip
	FROM        Permit_Escorts
	WHERE    (PE_Name = @PE_Name)

GO
GRANT EXECUTE ON  [dbo].[d_permit_escorts_sp] TO [public]
GO
