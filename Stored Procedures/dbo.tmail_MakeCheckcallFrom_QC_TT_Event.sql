SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_MakeCheckcallFrom_QC_TT_Event]	
		@ckc_status         CHAR(6),      -- 'HIST'
		@ckc_asgntype       CHAR(6),      -- 'TRL'
		@ckc_asgnid			VARCHAR(13),  -- Equipment ID ( Not the Unit Address)
		@ckc_date			DATETIME,	  -- Event timestamp from Qualcomm.
		@ckc_event          CHAR(6),      -- 'T1070'
		@ckc_comment		VARCHAR(254), -- 'Geofence Event Notification'
		@ckc_latseconds		INT,		  -- 
		@ckc_longseconds	INT,		  --
		@ckc_commentlarge   VARCHAR(254), -- Proximity info converted
		@ckc_ExtraData01	VARCHAR(255), -- Transaction ID
		@ckc_ExtraData02	VARCHAR(255), -- Unit Address
		@ckc_ExtraData03    VARCHAR(255), -- Postion Info (Raw)
		@ckc_ExtraData04    VARCHAR(255), -- Connection Status
		@ckc_ExtraData05    VARCHAR(255), -- Door Sensor State
		@ckc_ExtraData06    VARCHAR(255), -- Cargo Sensor State
		@ckc_ExtraData07    VARCHAR(255), -- T2 Battery Status
		@ckc_ExtraData08    VARCHAR(255), -- Power State
		@ckc_ExtraData09    VARCHAR(255), -- Aux Sensor State
		@ckc_ExtraData10    VARCHAR(255), -- Reefer Alarms
		@ckc_ExtraData11    VARCHAR(255), -- Reefer Status
		@ckc_ExtraData12    VARCHAR(255), -- Reefer Power
		@ckc_ExtraData13    VARCHAR(255), -- Mobile Health Status
		@ckc_ExtraData14    VARCHAR(255), -- Teth Reefer Attention
		@ckc_ExtraData15    VARCHAR(255), -- Teth Reefer Status
		@ckc_ExtraData16    VARCHAR(255), -- Teth Reefer Settings
		@ckc_ExtraData17	VARCHAR(255), -- Proximity Info (Raw)
		@ckc_ExtraData18    VARCHAR(255), -- Trip Info
		@ckc_ExtraData19    VARCHAR(255), -- Other Equip Info
		@ckc_ExtraData20    VARCHAR(255), -- Additional Info
		@ckc_Speed			INT,
		@ckc_heading 		FLOAT,
		@ckc_QCTTEvent		VARCHAR(08)	  -- ALERT or UPDATE indicator

AS

BEGIN

	DECLARE @ckc_number AS INT
	DECLARE	@ckc_updatedby AS CHAR(20)
	DECLARE @ckc_updatedon AS DATETIME

	--------------------------------------------------------------------------------
	-- Get the next available checkcall number
	EXECUTE @ckc_number = dbo.getsystemnumberblock 'CKCNUM','',1
	
	--------------------------------------------------------------------------------
	-- Populate the update fields
	
	-- Use the function call gettmwuser to get the user spid user for updatedby
	EXECUTE gettmwuser @ckc_updatedby
	
	SELECT @ckc_updatedby = ISNULL(@ckc_updatedby,'QCTrailerTracks')
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
		ckc_comment,
		ckc_updatedby,
		ckc_updatedon,
		ckc_latseconds,
		ckc_longseconds,
		ckc_commentlarge,
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
		ckc_Speed,
		ckc_Heading,
		ckc_QCTTEvent)
	VALUES (
		@ckc_number,
		@ckc_status,
		@ckc_asgntype,
		@ckc_asgnid,
		@ckc_date,
		@ckc_event,
		@ckc_comment,
		@ckc_updatedby,
		@ckc_updatedon,
		@ckc_latseconds,
		@ckc_longseconds,
		@ckc_commentlarge,
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
		@ckc_Speed,
		@ckc_Heading,
		@ckc_QCTTEvent)
END	

GO
GRANT EXECUTE ON  [dbo].[tmail_MakeCheckcallFrom_QC_TT_Event] TO [public]
GO
