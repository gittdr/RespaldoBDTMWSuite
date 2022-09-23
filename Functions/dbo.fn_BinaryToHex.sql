SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_BinaryToHex]
( @Input VARCHAR(100)
)
RETURNS VARCHAR(25)
AS
/**
*
* NAME:
* dbo.fn_BinaryToHex
*
* TYPE:
* Function
*
* DESCRIPTION:
* Function Procedure used for converting binary string to hex
*
* RETURNS:
*
* RESULT SETS:
*
* PARAMETERS:
* 001 @Input VARCHAR(100)
*
* REVISION HISTORY:
* PTS 99820 SPN 03/14/16 - Initial version
*
**/

BEGIN

   DECLARE @Output varchar(25) = ''

   IF LEN(@INPUT) % 4 <> 0 SET @INPUT = @Input + REPLICATE('0', 4- (LEN(@INPUT) % 4))

   WHILE LEN(@INPUT) > 0
   BEGIN
      SET @Output = CASE RIGHT(@Input, 4)
                       WHEN '0000' THEN '2'
                       WHEN '0001' THEN '3'
                       WHEN '0010' THEN '4'
                       WHEN '0011' THEN '5'
                       WHEN '0100' THEN '6'
                       WHEN '0101' THEN '7'
                       WHEN '0110' THEN '8'
                       WHEN '0111' THEN '9'
                       WHEN '1000' THEN 'A'
                       WHEN '1001' THEN 'B'
                       WHEN '1010' THEN 'C'
                       WHEN '1011' THEN 'D'
                       WHEN '1100' THEN 'E'
                       WHEN '1101' THEN 'F'
                       WHEN '1110' THEN 'G'
                       WHEN '1111' THEN 'H'
                    END + @Output
      SET @Input = LEFT(@Input, LEN(@Input) - 4)
   END

   RETURN @Output
END
GO
GRANT EXECUTE ON  [dbo].[fn_BinaryToHex] TO [public]
GO
GRANT REFERENCES ON  [dbo].[fn_BinaryToHex] TO [public]
GO
