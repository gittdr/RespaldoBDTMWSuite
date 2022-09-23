SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TariffInputTSGetStringList]
( @TariffInputTS_Id  INT
, @ListName          VARCHAR(50)
) RETURNS @List TABLE
         ( Value NVARCHAR(MAX)
         )
AS
/**
 *
 * NAME:
 * dbo.fnc_TariffInputTSGetStringList
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function Procedure returns List from TariffInputTS
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @TariffInputTS_Id   INT
 * 002 @ListName           VARCHAR(50)
 *
 * REVISION HISTORY:
 * PTS 76379 SPN 04/10/2014 - Initial Version Created
 *
 **/

BEGIN

   /*
   --String
   Stop Companies List
   Delay Type List
   Stop Type List
   Stop Event List
   Transfer Type List
   Stop Event Transfer Type List
   Commodities List
   Stop Event OT1 to OT2 Event List
   Stop Event OT1 to OT2 OT1 List
   Stop Event OT1 to OT2 OT2 List
   Stop Event OT1 Event List
   Stop Event OT1 OT1 List
   Stop Event OT2 Event List
   Stop Event OT2 OT2 List
   Stop Load Status List
   Weight Unit List
   LTL Commodities List
   */

   INSERT INTO @List (Value)
   SELECT StringValue
     FROM TariffInputTSLists
    WHERE TariffInputTS_Id = @TariffInputTS_Id
      AND ListName = @ListName

   RETURN

END
GO
GRANT REFERENCES ON  [dbo].[fnc_TariffInputTSGetStringList] TO [public]
GO
GRANT SELECT ON  [dbo].[fnc_TariffInputTSGetStringList] TO [public]
GO
