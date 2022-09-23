SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TariffInputTSGetFreightBreakList]
( @TariffInputTS_Id  INT
) RETURNS @List TABLE
         ( tar_tablebreak_code   VARCHAR(30)
         , weight                DECIMAL(19,6)
         , count                 DECIMAL(19,6)
         , volume                DECIMAL(19,6)
         , length                DECIMAL(19,6)
         , width                 DECIMAL(19,6)
         , height                DECIMAL(19,6)
         )
AS
/**
 *
 * NAME:
 * dbo.fnc_TariffInputTSGetFreightBreakList
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function Procedure returns List from TariffInputTSFreightBreakList
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @TariffInputTS_Id   INT
 *
 * REVISION HISTORY:
 * PTS 76379 SPN 04/10/2014 - Initial Version Created
 *
 **/

BEGIN

   INSERT INTO @List (tar_tablebreak_code, weight, count, volume, length, width, height)
   SELECT tar_tablebreak_code, weight, count, volume, length, width, height
     FROM TariffInputTSFreightBreakList
    WHERE TariffInputTS_Id = @TariffInputTS_Id

   RETURN

END
GO
GRANT REFERENCES ON  [dbo].[fnc_TariffInputTSGetFreightBreakList] TO [public]
GO
GRANT SELECT ON  [dbo].[fnc_TariffInputTSGetFreightBreakList] TO [public]
GO
