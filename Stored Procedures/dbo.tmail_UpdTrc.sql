SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_UpdTrc] @TruckID varchar(10), @Driver1 varchar(30), @Driver2 varchar(30) = NULL

AS 

EXEC dbo.tmail_UpdTrc2 @TruckID, @Driver1, @Driver2, 0, 0
GO
GRANT EXECUTE ON  [dbo].[tmail_UpdTrc] TO [public]
GO
