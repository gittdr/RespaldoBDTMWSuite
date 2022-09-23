SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_loadpermit_sp] @PM_Name varchar(50) , @number int AS 
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

	IF exists ( SELECT    PM_ID
	            FROM        Permit_Master
	            WHERE    (PM_Name LIKE @PM_Name + '%')) BEGIN
	            
		SELECT    PM_Name, PM_ID as Code
	    FROM        Permit_Master
	    WHERE    (PM_Name LIKE @PM_Name + '%') 
	    ORDER BY  PM_Name
	END
	ELSE BEGIN
		SELECT    PM_Name, PM_ID as Code
	    FROM        Permit_Master
	    WHERE    (PM_Name = 'UNKNOWN') 
	    ORDER BY  PM_Name
	END
	set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadpermit_sp] TO [public]
GO
