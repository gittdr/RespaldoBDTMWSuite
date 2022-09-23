SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_MakeCheckcallFromQcEssEvent]	
		@ckc_status       		CHAR(6),		-- 
		@ckc_asgntype     		CHAR(6),		-- 
		@ckc_asgnid				VARCHAR(13),	--
		@ckc_date				DATETIME,		--
		@ckc_event        		CHAR(6),		-- 
		@ckc_city				INT,			--
		@ckc_comment			VARCHAR(254),	-- 
		@ckc_latseconds			INT,			-- 
		@ckc_longseconds		INT,			--
		@ckc_lghnumber			INT,			--
		@ckc_tractor			VARCHAR(8),		--
		@ckc_extsensoralarm		CHAR(1),		--
		@ckc_vehicleignition	CHAR(1),		--
		@ckc_milesfrom			FLOAT,			--
		@ckc_directionfrom		CHAR(3),		--
		@ckc_validity			CHAR(6),		--
		@ckc_mtavailable		CHAR(1),		--
		@ckc_minutes			INT,			--
		@ckc_mileage			INT,			--
		@ckc_home				CHAR(1),		--
		@ckc_cityname			VARCHAR(16),	--
		@ckc_state				VARCHAR(6),		--
		@ckc_zip				VARCHAR(10),	--
		@ckc_commentlarge		VARCHAR(254),	--
		@ckc_minutes_to_final	INT,			--
		@ckc_miles_to_final		INT,			--
		@ckc_odometer			INT,			--
		@ckc_ExtraData01		VARCHAR(255),	-- 
		@ckc_ExtraData02		VARCHAR(255),	-- 
		@ckc_ExtraData03		VARCHAR(255),	-- 
		@ckc_ExtraData04		VARCHAR(255),	-- 
		@ckc_ExtraData05		VARCHAR(255),	-- 
		@ckc_ExtraData06		VARCHAR(255),	-- 
		@ckc_ExtraData07		VARCHAR(255),	-- 
		@ckc_ExtraData08		VARCHAR(255),	-- 
		@ckc_ExtraData09		VARCHAR(255),	-- 
		@ckc_ExtraData10		VARCHAR(255),	-- 
		@ckc_ExtraData11		VARCHAR(255),	-- 
		@ckc_ExtraData12		VARCHAR(255),	-- 
		@ckc_ExtraData13		VARCHAR(255),	-- 
		@ckc_ExtraData14		VARCHAR(255),	-- 
		@ckc_ExtraData15		VARCHAR(255),	-- 
		@ckc_ExtraData16		VARCHAR(255),	-- 
		@ckc_ExtraData17		VARCHAR(255),	-- 
		@ckc_ExtraData18		VARCHAR(255),	-- 
		@ckc_ExtraData19		VARCHAR(255),	-- 
		@ckc_ExtraData20		VARCHAR(255),	-- 
		@tripstatus				INT,			--
		@ckc_odometer2			INT,			--
		@ckc_Speed				INT,			--
		@ckc_Speed2				INT,			--
		@ckc_heading			FLOAT,			--
		@ckc_gps_type			INT,			--
		@ckc_gps_miles			FLOAT,			--
		@ckc_fuel_meter			FLOAT,			--
		@ckc_idle_meter			INT,			--
		@ckc_associatedmsgsn	INT,			--
		@ckc_timezone			VARCHAR(10),	--
		@ckc_QCTTEvent			VARCHAR(08),	--
		@updater				VARCHAR(20)		--

AS

-- =============================================================================
-- Stored Proc: tmail_MakeCheckcallFromQcEssEvent
-- Author     :	Sensabaugh, Virgil
-- Create date: 2013.01.28
-- Description:
--      This procedure will take the given data from QC ESS Events and 
--      insert that date into the checkcall table.
--		NOTE:  The mapping of data to the various checkcall table fields will be 
--		determined by the application function/method that calls this stored
--		proc.
--      
--      Outputs:
--      ------------------------------------------------------------------------
--      None
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		001 - @ckc_status       	CHAR(6),		-- 
--		002 - @ckc_asgntype     	CHAR(6),		-- 
--		003 - @ckc_asgnid			VARCHAR(13),	--
--		004 - @ckc_date				DATETIME,		--
--		005 - @ckc_event        	CHAR(6),		-- 
--		006 - @ckc_city				INT,			--
--		007 - @ckc_comment			VARCHAR(254),	-- 
--		008 - @ckc_latseconds		INT,			-- 
--		009 - @ckc_longseconds		INT,			--
--		010 - @ckc_lghnumber		INT,			--
--		011 - @ckc_tractor			VARCHAR(8),		--
--		012 - @ckc_extsensoralarm	CHAR(1),		--
--		013 - @ckc_vehicleignition	CHAR(1),		--
--		014 - @ckc_milesfrom		FLOAT,			--
--		015 - @ckc_directionfrom	CHAR(3),		--
--		016 - @ckc_validity			CHAR(6),		--
--		017 - @ckc_mtavailable		CHAR(1),		--
--		018 - @ckc_minutes			INT,			--
--		019 - @ckc_mileage			INT,			--
--		020 - @ckc_home				CHAR(1),		--
--		021 - @ckc_cityname			VARCHAR(16),	--
--		022 - @ckc_state			VARCHAR(6),		--
--		023 - @ckc_zip				VARCHAR(10),	--
--		024 - @ckc_commentlarge		VARCHAR(254),	--
--      025 - @ckc_minutes_to_final	INT,			--
--		026 - @ckc_miles_to_final	INT,			--
--		027 - @ckc_odometer			INT,			--
--		028 - @ckc_ExtraData01		VARCHAR(255),	-- 
--		029 - @ckc_ExtraData02		VARCHAR(255),	-- 
--		030 - @ckc_ExtraData03		VARCHAR(255),	-- 
--		031 - @ckc_ExtraData04		VARCHAR(255),	-- 
--		032 - @ckc_ExtraData05		VARCHAR(255),	-- 
--		033 - @ckc_ExtraData06		VARCHAR(255),	-- 
--		034 - @ckc_ExtraData07		VARCHAR(255),	-- 
--		035 - @ckc_ExtraData08		VARCHAR(255),	-- 
--		036 - @ckc_ExtraData09		VARCHAR(255),	-- 
--		037 - @ckc_ExtraData10		VARCHAR(255),	-- 
--		038 - @ckc_ExtraData11		VARCHAR(255),	-- 
--		039 - @ckc_ExtraData12		VARCHAR(255),	-- 
--		040 - @ckc_ExtraData13		VARCHAR(255),	-- 
--		041 - @ckc_ExtraData14		VARCHAR(255),	-- 
--		042 - @ckc_ExtraData15		VARCHAR(255),	-- 
--		043 - @ckc_ExtraData16		VARCHAR(255),	-- 
--		044 - @ckc_ExtraData17		VARCHAR(255),	-- 
--		045 - @ckc_ExtraData18		VARCHAR(255),	-- 
--		046 - @ckc_ExtraData19		VARCHAR(255),	-- 
--		047 - @ckc_ExtraData20		VARCHAR(255),	-- 
--		048 - @tripstatus			INT,			--
--		049 - @ckc_odometer2		INT,			--
--		050 - @ckc_Speed			INT,			--
--		051 - @ckc_Speed2			INT,			--
--		052 - @ckc_heading			FLOAT,			--
--		053 - @ckc_gps_type			INT,			--
--		054 - @ckc_gps_miles		FLOAT,			--
--		055 - @ckc_fuel_meter		FLOAT,			--
--		056 - @ckc_idle_meter		INT,			--
--		057 - @ckc_associatedmsgsn	INT,			--
--		058 - @ckc_timezone			VARCHAR(10),	--
--      059 - @ckc_QCTTEvent		VARCHAR(08),	--
--		060 - @updater				VARCHAR(20)		--
--
-- =============================================================================

BEGIN

	DECLARE @ckc_number AS INT
	DECLARE	@ckc_updatedby AS CHAR(20)
	DECLARE @ckc_updatedon AS DATETIME

	--------------------------------------------------------------------------------
	-- Get the next available checkcall number
	EXECUTE @ckc_number = dbo.getsystemnumberblock 'CKCNUM','',1
	
	--------------------------------------------------------------------------------
	-- Populate the update fields
	
	SELECT @ckc_updatedby = ISNULL(@updater,'QCApplication')
	-- Use the system time for the updatedon
	SELECT @ckc_updatedon = GETDATE()

	--------------------------------------------------------------------------------
	INSERT INTO dbo.checkcall (
		ckc_number,
		ckc_status,
		ckc_asgntype,
		ckc_asgnid,
		ckc_date,
		ckc_event,
		ckc_city,
		ckc_comment,
		ckc_updatedby,
		ckc_updatedon,
		ckc_latseconds,
		ckc_longseconds,
		ckc_lghnumber,
		ckc_tractor,
		ckc_extsensoralarm,
		ckc_vehicleignition,
		ckc_milesfrom,
		ckc_directionfrom,
		ckc_validity,
		ckc_mtavailable,
		ckc_minutes,
		ckc_mileage,
		ckc_home,
		ckc_cityname,
		ckc_state,
		ckc_zip,
		ckc_commentlarge,
		ckc_minutes_to_final,
		ckc_miles_to_final,
		ckc_odometer,
		ckc_ExtraData01,
		ckc_ExtraData02,
		ckc_ExtraData03,
		ckc_ExtraData04,
		ckc_ExtraData05,
		ckc_ExtraData06,
		ckc_ExtraData07,
		ckc_ExtraData08,
		ckc_ExtraData09,
		ckc_ExtraData10,
		ckc_ExtraData11,
		ckc_ExtraData12,
		ckc_ExtraData13,
		ckc_ExtraData14,
		ckc_ExtraData15,
		ckc_ExtraData16,
		ckc_ExtraData17,
		ckc_ExtraData18,
		ckc_ExtraData19,
		ckc_ExtraData20,
		tripstatus,
		ckc_odometer2,
		ckc_Speed,
		ckc_speed2,
		ckc_Heading,
		ckc_gps_type,
		ckc_gps_miles,
		ckc_fuel_meter,
		ckc_idle_meter,
		ckc_associatedmsgsn,
		ckc_timezone,
		ckc_QCTTEvent)
	VALUES (
		@ckc_number,
		@ckc_status,
		@ckc_asgntype,
		@ckc_asgnid,
		@ckc_date,
		@ckc_event,
		@ckc_city,
		@ckc_comment,
		@ckc_updatedby,
		@ckc_updatedon,
		@ckc_latseconds,
		@ckc_longseconds,
		@ckc_lghnumber,
		@ckc_tractor,
		@ckc_extsensoralarm,
		@ckc_vehicleignition,
		@ckc_milesfrom,
		@ckc_directionfrom,
		@ckc_validity,
		@ckc_mtavailable,
		@ckc_minutes,
		@ckc_mileage,
		@ckc_home,
		@ckc_cityname,
		@ckc_state,
		@ckc_zip,
		@ckc_commentlarge,
		@ckc_minutes_to_final,
		@ckc_miles_to_final,
		@ckc_odometer,
		@ckc_ExtraData01,
		@ckc_ExtraData02,
		@ckc_ExtraData03, 
		@ckc_ExtraData04,
		@ckc_ExtraData05,
		@ckc_ExtraData06,
		@ckc_ExtraData07,
		@ckc_ExtraData08,
		@ckc_ExtraData09,
		@ckc_ExtraData10,
		@ckc_ExtraData11,
		@ckc_ExtraData12,
		@ckc_ExtraData13,
		@ckc_ExtraData14,
		@ckc_ExtraData15,
		@ckc_ExtraData16,
		@ckc_ExtraData17,
		@ckc_ExtraData18,
		@ckc_ExtraData19,
		@ckc_ExtraData20,
		@tripstatus,
		@ckc_odometer2,
		@ckc_Speed,
		@ckc_Speed2,
		@ckc_heading,
		@ckc_gps_type,
		@ckc_gps_miles,
		@ckc_fuel_meter,
		@ckc_idle_meter,
		@ckc_associatedmsgsn,
		@ckc_timezone,
		@ckc_QCTTEvent)
END	

GO
GRANT EXECUTE ON  [dbo].[tmail_MakeCheckcallFromQcEssEvent] TO [public]
GO
