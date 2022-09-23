SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_loadcmd_sp] @cmd varchar(60) , @number int AS

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

if exists ( SELECT cmd_name FROM commodity WHERE cmd_name LIKE @cmd +'%' and cmd_active = 'Y') 
	SELECT cmd_name , 
               cmd_code, 
	       cmd_non_spec, 
               cmd_flash_point,
               cmd_flash_unit,
               cmd_flash_point_max
		FROM commodity 
		WHERE cmd_name LIKE @cmd + '%' and cmd_active = 'Y'
		ORDER BY cmd_name 
else 
	SELECT cmd_name , 
               cmd_code , 
               cmd_non_spec, 
               cmd_flash_point, 
               cmd_flash_unit,
               cmd_flash_point_max
		FROM commodity 
		WHERE cmd_name = 'UNKNOWN' 

set rowcount 0 


GO
GRANT EXECUTE ON  [dbo].[d_loadcmd_sp] TO [public]
GO
