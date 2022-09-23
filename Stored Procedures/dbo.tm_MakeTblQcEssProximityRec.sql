SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tm_MakeTblQcEssProximityRec]
		@qcUserIDCompany	VARCHAR(20),	--
		@equipUnitAddr		VARCHAR(20),	--
		@equipID			VARCHAR(20),	--
		@essEvent			VARCHAR(20),	--
		@eventKey			VARCHAR(20),	--
		@eventField			VARCHAR(20),	--
		@seq				INT,			--
		@distance			FLOAT(8),		--
		@direction			VARCHAR(3),		--
		@placeName			VARCHAR(50),	--
		@placeAlias			VARCHAR(50),	--
		@placeAlias2		VARCHAR(50),	--
		@placeAlias3		VARCHAR(50),	--
		@placeAlias4		VARCHAR(50),	--
		@placeAlias5		VARCHAR(50),	--
		@placeType			VARCHAR(20),	--
		@city				VARCHAR(50),	--
		@stateProv			VARCHAR(10),	--
		@postal				VARCHAR(20),	--
		@country			VARCHAR(20),	--
		@updater			VARCHAR(20)		--

AS

BEGIN

	DECLARE	@updatedby AS VARCHAR(20)
	DECLARE @updatedon AS DATETIME
	--------------------------------------------------------------------------------
	-- Populate the update fields
	
	-- Use the function call gettmwuser to get the user spid user for updatedby
	-- EXECUTE gettmwuser @updatedby
	
	SELECT @updatedby = ISNULL(@updater,'QCApplication')
	-- Use the system time for the updatedon
	SELECT @updatedon = GETDATE()

	--------------------------------------------------------------------------------
	
	INSERT INTO dbo.tblQcEssProximity (
		qcUserIDCompany,
		equipUnitAddr,
		equipID,
		essEvent,
		eventKey,
		eventField,
		seq,
		distance,
		direction,
		placeName,
		placeAlias,
		placeAlias2,
		placeAlias3,
		placeAlias4,
		placeAlias5,
		placeType,
		city,
		stateProv,
		postal,
		country,
		updatedby,
		updatedon
		)
	VALUES (
		@qcUserIDCompany,
		@equipUnitAddr,
		@equipID,
		@essEvent,
		@eventKey,
		@eventField,
		@seq,
		@distance,
		@direction,
		@placeName,
		@placeAlias,
		@placeAlias2,
		@placeAlias3,
		@placeAlias4,
		@placeAlias5,
		@placeType,
		@city,
		@stateProv,
		@postal,
		@country,
		@updatedby,
		@updatedon
		)
END	

GO
GRANT EXECUTE ON  [dbo].[tm_MakeTblQcEssProximityRec] TO [public]
GO
