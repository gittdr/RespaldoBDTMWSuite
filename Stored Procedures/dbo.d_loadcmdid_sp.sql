SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_loadcmdid_sp] @cmd varchar(8) , @number int AS 

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

if exists ( SELECT cmd_code FROM commodity WHERE cmd_code LIKE @cmd + '%' and cmd_active = 'Y') 
	SELECT cmd_name , 
	       cmd_code, 
               cmd_non_spec, 
               cmd_flash_point, 
               cmd_flash_unit,
               cmd_flash_point_max ,
               cmd_taxtable1,
               cmd_taxtable2,
               cmd_taxtable3,
               cmd_taxtable4

		FROM commodity 
		WHERE cmd_code LIKE @cmd + '%' AND cmd_active = 'Y'
	ORDER BY cmd_code 
else 
	SELECT cmd_name , 
               cmd_code, 
               cmd_non_spec, 
               cmd_flash_point, 
               cmd_flash_unit, 
               cmd_flash_point_max,
               cmd_taxtable1,
               cmd_taxtable2,
               cmd_taxtable3,
               cmd_taxtable4 
		FROM commodity 
		WHERE cmd_code = 'UNKNOWN' 

set rowcount 0 


GO
GRANT EXECUTE ON  [dbo].[d_loadcmdid_sp] TO [public]
GO
