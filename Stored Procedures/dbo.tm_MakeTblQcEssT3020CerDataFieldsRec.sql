SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tm_MakeTblQcEssT3020CerDataFieldsRec]
		@qcUserIDCompany				VARCHAR(20),	--
		@equipUnitAddr					VARCHAR(20),	--
		@equipID						VARCHAR(20),	--
		@eventKey						VARCHAR(20),	--
		@cerDataOffSetTime				INT,			--
		@cerDataSpeed					FLOAT(8),		--
		@cerDataEventType				VARCHAR(20),	--
		@cerDataFollowingTime			FLOAT(8),		--
		@updater						VARCHAR(20)		--

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
	
	INSERT INTO dbo.tblQcEssT3020CerDataFields (
		qcUserIDCompany,
		equipUnitAddr,
		equipID,
		eventKey,
		cerDataOffSetTime,
		cerDataSpeed,
		cerDataEventType,
		cerDataFollowingTime,
		updatedby,
		updatedon
		)
	VALUES (
		@qcUserIDCompany,
		@equipUnitAddr,
		@equipID,
		@eventKey,
		@cerDataOffSetTime,
		@cerDataSpeed,
		@cerDataEventType,
		@cerDataFollowingTime,
		@updatedby,
		@updatedon
		)
END	

GO
GRANT EXECUTE ON  [dbo].[tm_MakeTblQcEssT3020CerDataFieldsRec] TO [public]
GO
