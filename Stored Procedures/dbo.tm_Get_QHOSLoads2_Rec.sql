SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Get_QHOSLoads2_Rec] 
							(
							 @LoadID   AS VARCHAR(80)
							 )

AS

DECLARE @UnloadTime AS DATETIME
DECLARE @LoadTime AS DATETIME
DECLARE @DriverID AS VARCHAR(8)
DECLARE @TractorID AS VARCHAR(8)
DECLARE @TrailerIDs AS VARCHAR(254)
DECLARE @LoadDescriptionType AS INT
DECLARE @LoadDescription AS VARCHAR(254)
DECLARE @UpdatedOn AS DATETIME

BEGIN
	----------------------------------------------------------------------------
	IF EXISTS(SELECT * 
				FROM dbo.tblQHOSLoads2 WITH (NOLOCK)
			   WHERE 
					 LoadID = @LoadID)
		------------------------------------------------------------------------
		-- Record found in tblQHOSLoads2
		SELECT 
				@LoadID = LoadID ,
				@DriverID = DriverID ,
				@LoadTime = LoadTime ,
				@UnloadTime = UnloadTime , 
				@TrailerIDs = TrailerIDs ,
				@TractorID = TractorID ,
				@LoadDescriptionType = LoadDescriptionType ,
				@LoadDescription = LoadDescription ,
				@UpdatedOn = UpdatedOn
		  FROM 
				dbo.tblQHOSLoads2  WITH (NOLOCK)
		 WHERE 
				LoadID = @LoadID
	ELSE
		------------------------------------------------------------------------
		-- Record NOT found in tblQHOSLoads2
		
		SELECT 
			@LoadID = 0 ,
			@DriverID = '' ,
			@LoadTime = 0 ,
			@UnloadTime = 0 , 
			@TrailerIDs = '' ,
			@TractorID = '' ,
			@LoadDescriptionType = 0 ,
			@LoadDescription = '' ,
			@UpdatedOn = 0
	 
	-------------------------------------------------------------------------------		
	SELECT 
		@LoadID AS 'LoadID' ,
		@DriverID AS 'DriverID' ,
		@LoadTime AS 'LoadTime' ,
		@UnloadTime AS 'UnloadTime' , 
		@TrailerIDs AS 'TrailerIDs' ,
		@TractorID AS 'TractorID' ,
		@LoadDescriptionType AS 'LoadDescriptionType' ,
		@LoadDescription AS 'LoadDescription' ,
		@UpdatedOn AS 'UpdatedOn'

	-------------------------------------------------------------------------------
END

GO
GRANT EXECUTE ON  [dbo].[tm_Get_QHOSLoads2_Rec] TO [public]
GO
