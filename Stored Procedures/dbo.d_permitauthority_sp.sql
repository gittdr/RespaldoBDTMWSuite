SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_permitauthority_sp] @PIA_Name varchar(50)
As

	SELECT    PIA_ID, PIA_Type, PIA_Name, st_abbr, cty_code, cty_nmstct, PIA_Contact, PIA_ContactPhone, PIA_ContactFax, 
		                     PIA_ContactEmail, PIA_Website, PIA_FTPAddress, PIA_FTPLogin, PIA_FTPPassword, PIA_Contact2, PIA_Contact2Phone, 
		                     PIA_Contact2Fax, PIA_Contact2Email, PIA_Mail_Address1, PIA_Mail_Address2, PIA_Mail_City, PIA_Mail_City_nmstct, PIA_Mail_Zip, PIA_Max_GVW
	FROM        Permit_Issuing_Authority PIA
  	WHERE	(PIA_Name = @PIA_Name)

GO
GRANT EXECUTE ON  [dbo].[d_permitauthority_sp] TO [public]
GO
