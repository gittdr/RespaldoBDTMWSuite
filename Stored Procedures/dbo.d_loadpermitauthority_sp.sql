SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_loadpermitauthority_sp] @PIA_Name varchar(50) , @number int AS 
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

	IF exists ( SELECT    PIA_ID
	            FROM        Permit_Issuing_Authority
	            WHERE    (PIA_Name LIKE @PIA_Name + '%')) BEGIN
	            
		SELECT    PIA_Name, PIA_ID as Code
	    FROM        Permit_Issuing_Authority
	    WHERE    (PIA_Name LIKE @PIA_Name + '%') 
	    ORDER BY  PIA_Name
	END
	ELSE BEGIN
		SELECT    PIA_Name, PIA_ID as Code
	    FROM        Permit_Issuing_Authority
	    WHERE    (PIA_Name = 'UNKNOWN') 
	    ORDER BY  PIA_Name
	END
	set rowcount 0 
GO
GRANT EXECUTE ON  [dbo].[d_loadpermitauthority_sp] TO [public]
GO
