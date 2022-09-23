SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* This proc determines if the commodity code exists in the PowerSuite commodity table.
   If it does, the proc returns a -1.

   If it does not the proc adds the commodity and returns a 1. 

   Call might look like:
       exec @ret = dx_add_commodity
	'WIRE-06',
	'16g stainless',
	'N',
	''
   Note: if a frieght class is passed and cannot be found in the PowerSuite table 
   (commodityclass), it is assumed it is valid and it is added) 
*/  
CREATE PROCEDURE [dbo].[dx_add_commodity]
	@commodity_code varchar(8),
	@commodity_description varchar(60),
	@commodity_is_hazardous CHAR(1),
	@freight_class varchar(8)
	
 AS 
  
  DECLARE @hazmat_code int, @cmd_number int

   SELECT @commodity_code = UPPER(ISNULL(@commodity_code,'UNKNOWN'))
   SELECT @commodity_description = UPPER(ISNULL(@commodity_description,''))
   SELECT @hazmat_code = 
      CASE @commodity_is_hazardous
	WHEN 'Y' THEN 1
        ELSE 0
      END
  
  IF (SELECT COUNT(1)
      FROM commodity
      WHERE cmd_code = @commodity_code) > 0
         RETURN -1
  /* Generate new unique code number */
  execute @cmd_number = getsystemnumber 'CMDCODE', ''
  /* Make sure the freight class is valid in the commodityclass table, else add it */
  SELECT  @freight_class = UPPER(ISNULL(@freight_class ,'UNKNOWN'))
  If LEN(RTRIM(@freight_class)) = 0 SELECT @freight_class  = 'UNKNOWN'

  IF (SELECT COUNT(1) 
      FROM commodityclass
      WHERE ccl_code = @freight_class) = 0
   
        INSERT INTO commodityclass (ccl_code,ccl_description)
        VALUES (@freight_class,@freight_class)
 

  INSERT INTO commodity
              (cmd_code,cmd_name,cmd_class,cmd_hazardous,cmd_code_num,
               cmd_misc1,cmd_misc2,cmd_misc3,cmd_misc4,cmd_temperatureunit,
               cmd_taxtable1,cmd_taxtable2,cmd_taxtable3,cmd_taxtable4,cmd_updatedby, cmd_updateddate,
	       cmd_createdate,cmd_active)
  VALUES ( @commodity_code,@commodity_description,@freight_class,@hazmat_code,@cmd_number,
           NULL,NULL,NULL,NULL,'Frnhgt',
           'Y','Y','N','N','dx_add_commodity',getdate(),
           getdate(),'Y')

  RETURN 1

GO
GRANT EXECUTE ON  [dbo].[dx_add_commodity] TO [public]
GO
