SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tm_MakeTblCeDataRec]
		@tractorID		VARCHAR(20),	--
		@unitAddress	VARCHAR(20),	--
		@eventDateTime	DATETIME,		--
		@orderNbr		VARCHAR(20),	--
		@trailerID		VARCHAR(20),	--
		@driverID		VARCHAR(20),	--
		@eventLocation	VARCHAR(60),	--
		@criticalEvent	VARCHAR(30), 	--
		@updater		VARCHAR(20),	--
		@eventKey		VARCHAR(20)		--

AS

BEGIN

	DECLARE	@updatedBy AS VARCHAR(20)
	DECLARE @updatedOn AS DATETIME
	--------------------------------------------------------------------------------
	-- Populate the update fields
	
	-- Use the function call gettmwuser to get the user spid user for updatedby
	-- EXECUTE gettmwuser @updatedBy
	
	SELECT @updatedBy = ISNULL(@updater,'QCApplications')
	-- Use the system time for the updatedon
	SELECT @updatedOn = GETDATE()

	--------------------------------------------------------------------------------
	
	INSERT INTO dbo.tblCEData (
		tractorID,
		unitAddress,
		eventDateTime,
		orderNbr,
		trailerID,
		driverID,
		eventLocation,
		criticalEvent,
		updatedBy,
		updatedOn,
		eventKey
		)
	VALUES (
		@tractorID,
		@unitAddress,
		@eventDateTime,
		@orderNbr,
		@trailerID,
		@driverID,
		@eventLocation,
		@criticalEvent,
		@updatedBy,
		@updatedOn,
		@eventKey 
		)
END	

GO
GRANT EXECUTE ON  [dbo].[tm_MakeTblCeDataRec] TO [public]
GO
