SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_loadpermitroute_sp] @PRT_Name varchar(50) , @number int AS 
	if @number = 1 
		set rowcount 1 
	else if @number <= 8 
		set rowcount 8
	else if @number <= 16
		set rowcount 16
	else if @number <= 24
		set rowcount 24
	else
		set rowcount 8

	IF exists ( SELECT    PRT_ID
	            FROM        Permit_Route
	            WHERE    (PRT_Name LIKE @PRT_Name + '%')) BEGIN

		SELECT	PRT.PRT_Name, PRT.PRT_ID AS Code, PIA.PIA_Type, PIA.PIA_Name, 
			lblPermitAuthorityType.name AS PermitAuthorityTypeName
		FROM	Permit_Route PRT INNER JOIN
			Permit_Issuing_Authority PIA ON PRT.PIA_ID = PIA.PIA_ID LEFT OUTER JOIN
			labelfile lblPermitAuthorityType ON PIA.PIA_Type = lblPermitAuthorityType.abbr AND 
			lblPermitAuthorityType.labeldefinition = 'PermitAuthorityType'
		WHERE	(PRT.PRT_Name LIKE @PRT_Name + '%')
		ORDER BY PRT.PRT_Name	            
	END
	ELSE BEGIN
		SELECT	PRT.PRT_Name, PRT.PRT_ID AS Code, PIA.PIA_Type, PIA.PIA_Name, 
			lblPermitAuthorityType.name AS PermitAuthorityTypeName
		FROM	Permit_Route PRT INNER JOIN
			Permit_Issuing_Authority PIA ON PRT.PIA_ID = PIA.PIA_ID LEFT OUTER JOIN
			labelfile lblPermitAuthorityType ON PIA.PIA_Type = lblPermitAuthorityType.abbr AND 
			lblPermitAuthorityType.labeldefinition = 'PermitAuthorityType'
		WHERE	(PRT_Name = 'UNKNOWN')
	END
	set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadpermitroute_sp] TO [public]
GO
