SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tm_GetUAFromTRCBusRule]
		@TRC				AS VARCHAR(50)

AS

BEGIN

	DECLARE @McuID AS VARCHAR(50)
	
	SELECT @McuID = c.unitid
	FROM tblTrucks AS t, tblCabUnits AS c
	WHERE t.SN = c.Truck
	  AND t.TruckName = @TRC 		

 	SELECT @McuID as 'MCUID'

END

GO
GRANT EXECUTE ON  [dbo].[tm_GetUAFromTRCBusRule] TO [public]
GO
