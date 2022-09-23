SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TariffInputTSGetDateList]
( @TariffInputTS_Id  INT
, @ListName          VARCHAR(50)
) RETURNS @List TABLE
         ( Value DATETIME
         )
AS
/**
 *
 * NAME:
 * dbo.fnc_TariffInputTSGetDateList
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
   --Date
   Stop Arrival Date List
   */

   INSERT INTO @List (Value)
   SELECT DateValue
     FROM TariffInputTSLists
    WHERE TariffInputTS_Id = @TariffInputTS_Id
      AND ListName = @ListName

   RETURN

END
GO
GRANT REFERENCES ON  [dbo].[fnc_TariffInputTSGetDateList] TO [public]
GO
GRANT SELECT ON  [dbo].[fnc_TariffInputTSGetDateList] TO [public]
GO
