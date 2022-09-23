SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_UpdTrc2] (@TruckID varchar(10), 
								   @Driver1 varchar(30), 
								   @Driver2 varchar(30) = NULL,
								   @TankFraction real,
								   @Gallons int)
AS 

SET NOCOUNT ON

EXEC dbo.tmail_UpdTrc3 @TruckID, @Driver1, @Driver2, @TankFraction, @Gallons, null
GO
GRANT EXECUTE ON  [dbo].[tmail_UpdTrc2] TO [public]
GO
