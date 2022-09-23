SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Add_QHOSLoads2_Rec]	
		@LoadID					AS VARCHAR(8),
		@DriverID				AS VARCHAR(8),
		@LoadTime				AS DATETIME,
		@UnloadTime				AS DATETIME,
		@TrailerIDs				AS VARCHAR(254),
		@TractorID				AS VARCHAR(8),
		@LoadDescriptionType	AS INT,
		@LoadDescription		AS VARCHAR(254)
AS

BEGIN

	DECLARE @UpdatedOn AS DATETIME
	----------------------------------------------------------------------------
	-- Use the system time for the updatedon
	SELECT @UpdatedOn = GETDATE()
	----------------------------------------------------------------------------
	INSERT INTO [dbo].[tblQHOSLoads2] (
		LoadID,
		DriverID,
		LoadTime,
		UnloadTime,
		TrailerIDs,
		TractorID,
		LoadDescriptionType,
		LoadDescription,
		UpdatedOn
		)
	VALUES (
		@LoadID,
		@DriverID,
		CONVERT(DATETIME, @LoadTime),
		CONVERT(DATETIME, @UnloadTime),
		@TrailerIDs,
		@TractorID,
		@LoadDescriptionType,
		@LoadDescription,
		@UpdatedOn 
		)
END	

GO
GRANT EXECUTE ON  [dbo].[tm_Add_QHOSLoads2_Rec] TO [public]
GO
