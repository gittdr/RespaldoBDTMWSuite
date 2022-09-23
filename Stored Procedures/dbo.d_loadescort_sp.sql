SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_loadescort_sp] @PE_Name varchar(50) , @number int AS 
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

	IF exists ( SELECT    PE_ID
	            FROM        Permit_Escorts
	            WHERE    (PE_Name LIKE @PE_Name + '%')) BEGIN
	            
		SELECT    PE_Name, PE_ID as Code
	    FROM        Permit_Escorts
	    WHERE    (PE_Name LIKE @PE_Name + '%') 
	    ORDER BY  PE_Name
	END
	ELSE BEGIN
		SELECT    PE_Name, PE_ID as Code
	    FROM        Permit_Escorts
	    WHERE    (PE_Name = 'UNKNOWN') 
	    ORDER BY  PE_Name
	END
	set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadescort_sp] TO [public]
GO
