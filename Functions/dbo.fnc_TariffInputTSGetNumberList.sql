SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TariffInputTSGetNumberList]
( @TariffInputTS_Id  INT
, @ListName          VARCHAR(50)
) RETURNS @List TABLE
         ( Value DECIMAL(19,6)
         )
AS
/**
 *
 * NAME:
 * dbo.fnc_TariffInputTSGetNumberList
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
   --Decimal
   Stop City List
   Delay Hours List
   Stop Count List
   Stop Event Count List
   Stop Type Order List
   Freight Length List
   Freight Width List
   Freight Height List
   Freight Count List
   Event Transfer Count List
   Stop Event OT1 to OT2 Count List
   Stop Event OT1 Count List
   Stop Event OT2 Count List
   Weight List
   Stop Number List
   */

   INSERT INTO @List (Value)
   SELECT DecimalValue
     FROM TariffInputTSLists
    WHERE TariffInputTS_Id = @TariffInputTS_Id
      AND ListName = @ListName

   RETURN

END
GO
GRANT REFERENCES ON  [dbo].[fnc_TariffInputTSGetNumberList] TO [public]
GO
GRANT SELECT ON  [dbo].[fnc_TariffInputTSGetNumberList] TO [public]
GO
