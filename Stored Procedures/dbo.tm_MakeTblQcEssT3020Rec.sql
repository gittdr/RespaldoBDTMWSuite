SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  StoredProcedure [dbo].[tm_MakeTblQcEssT3020Rec]    Script Date: 01/07/2013 09:06:01 ******/


CREATE PROCEDURE [dbo].[tm_MakeTblQcEssT3020Rec]

		@qcUserIDCompany				VARCHAR(20),	--
		@equipUnitAddr					VARCHAR(20),	--
		@equipID						VARCHAR(20),	--
		@eventKey						VARCHAR(20),	--
		@eventURL						VARCHAR(80),	--
		@eventTS_GMT					DATETIME,		--
		@sentTS_GMT						DATETIME,		--
		@equipSCAC						VARCHAR(10),	--
		@equipType						VARCHAR(20),	--
		@equipMobileType				VARCHAR(20),	--
		@equipAlias						VARCHAR(20),	--
		@equipDeviceID					VARCHAR(20),	--
		@equipDeviceFirmwareVers		VARCHAR(20),	--
		@equipVIN						VARCHAR(20),	--
		@equipDivision					VARCHAR(20),	--
		@driverID						VARCHAR(20),	--
		@eventTrigger					VARCHAR(30),	--
		@triggerData					VARCHAR(10),	--
		@eventType						VARCHAR(30),	--
		@speed							INT,			--
		@parkBrakeStatus				VARCHAR(20),	--
		@msgLocPosLat					FLOAT(8),		--
		@msgLocPosLon					FLOAT(8),		--
		@msgLocPosTS_GMT				DATETIME,		--
		@incdntLocPosLat				FLOAT(8),		--
		@incdntLocPosLon				FLOAT(8),		--
		@incdntLocPosTS_GMT				DATETIME,		--
		@evimsTripDataStartMonth		INT,			--
		@evimsTripDataStartDay			INT,			--
		@evimsTripDataStartYear			INT,			--
		@evimsTripDataStartHour			INT,			--
		@evimsTripDataStartMinute		INT,			--
		@evimsTripDataDistance			FLOAT(8),		--
		@evimsTripDataMaxSpeed			FLOAT(8),		--
		@evimsTripDataFollowPerc0_1		FLOAT(8),		--
		@evimsTripDataFollowPerc1_2		FLOAT(8),		--
		@evimsTripDataCoastingTime		FLOAT(8),		--
		@evimsTripDataHB				INT,			--
		@updater						VARCHAR(20),	--
		@rawXML							VARCHAR(MAX)	--

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
	
	INSERT INTO dbo.tblQcEssT3020 (
		qcUserIDCompany,
		equipUnitAddr,
		equipID,
		eventKey,
		eventURL,
		eventTS_GMT,
		sentTS_GMT,
		equipSCAC,
		equipType,
		equipMobileType,
		equipAlias,
		equipDeviceID,
		equipDeviceFirmwareVers,
		equipVIN,
		equipDivision,
		driverID,
		eventTrigger,
		triggerData,
		eventType,
		speed,
		parkBrakeStatus,
		msgLocPosLat,
		msgLocPosLon,
		msgLocPosTS_GMT,
		incdntLocPosLat,
		incdntLocPosLon,
		incdntLocPosTS_GMT,
		evimsTripDataStartMonth,
		evimsTripDataStartDay,
		evimsTripDataStartYear,
		evimsTripDataStartHour,
		evimsTripDataStartMinute,
		evimsTripDataDistance,
		evimsTripDataMaxSpeed,
		evimsTripDataFollowPerc0_1,
		evimsTripDataFollowPerc1_2,
		evimsTripDataCoastingTime,
		evimsTripDataHB,
		updatedby,
		updatedon,
		rawXML
		)
	VALUES (
		@qcUserIDCompany,
		@equipUnitAddr,
		@equipID,
		@eventKey,
		@eventURL,
		@eventTS_GMT,
		@sentTS_GMT,
		@equipSCAC,
		@equipType,
		@equipMobileType,
		@equipAlias,
		@equipDeviceID,
		@equipDeviceFirmwareVers,
		@equipVIN,
		@equipDivision,
		@driverID,
		@eventTrigger,
		@triggerData,
		@eventType,
		@speed,
		@parkBrakeStatus,
		@msgLocPosLat,
		@msgLocPosLon,
		@msgLocPosTS_GMT,
		@incdntLocPosLat,
		@incdntLocPosLon,
		@incdntLocPosTS_GMT,
		@evimsTripDataStartMonth,
		@evimsTripDataStartDay,
		@evimsTripDataStartYear,
		@evimsTripDataStartHour,
		@evimsTripDataStartMinute,
		@evimsTripDataDistance,
		@evimsTripDataMaxSpeed,
		@evimsTripDataFollowPerc0_1,
		@evimsTripDataFollowPerc1_2,
		@evimsTripDataCoastingTime,
		@evimsTripDataHB,
		@updatedby,
		@updatedon,
		@rawXML 
		)
END	

GO
GRANT EXECUTE ON  [dbo].[tm_MakeTblQcEssT3020Rec] TO [public]
GO
