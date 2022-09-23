SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_loadcmd_class2_sp] @cmd        VARCHAR(60), 
                                @number     INT,
                                @cmdclass2 VARCHAR(8)
AS

IF @number = 1 
   SET rowcount 1 
ELSE IF @number <= 8 
   SET rowcount 8
ELSE IF @number <= 16
   SET rowcount 16
ELSE IF @number <= 24
   SET rowcount 24
ELSE
   SET rowcount 8

IF EXISTS (SELECT cmd_name
             FROM commodity
            WHERE cmd_name LIKE @cmd +'%' AND
                  cmd_class2 = @cmdclass2 AND
                  cmd_active = 'Y') 
   SELECT cmd_name,
          cmd_code,
          cmd_non_spec,
          cmd_flash_point,
          cmd_flash_unit,
          cmd_flash_point_max
     FROM commodity
    WHERE cmd_name LIKE @cmd + '%' AND
          cmd_class2 = @cmdclass2 AND
          cmd_active = 'Y'
   ORDER BY cmd_name 
ELSE 
   SELECT cmd_name,
          cmd_code,
          cmd_non_spec,
          cmd_flash_point,
          cmd_flash_unit,
          cmd_flash_point_max
     FROM commodity
    WHERE cmd_name = 'UNKNOWN' 

SET rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadcmd_class2_sp] TO [public]
GO
