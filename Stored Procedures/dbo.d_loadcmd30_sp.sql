SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/****** Object:  Stored Procedure dbo.d_loadcmd30_sp    Script Date: 8/20/97 1:57:47 PM ******/
CREATE PROC [dbo].[d_loadcmd30_sp] @cmd varchar(60) , @number int AS

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

if exists ( SELECT cmd_name FROM commodity WHERE cmd_name LIKE @cmd + '%' and cmd_active = 'Y' ) 
	SELECT substring(cmd_name, 1, 30) cmd_name, cmd_code 
	FROM commodity 
	WHERE cmd_name LIKE @cmd + '%' and cmd_active = 'Y'
	ORDER BY cmd_name 
else 
	SELECT cmd_name , cmd_code 
		FROM commodity 
		WHERE cmd_name = 'UNKNOWN' 

       
set       
 rowcount 0


GO
GRANT EXECUTE ON  [dbo].[d_loadcmd30_sp] TO [public]
GO
