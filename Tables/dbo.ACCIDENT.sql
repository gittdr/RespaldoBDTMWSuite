CREATE TABLE [dbo].[ACCIDENT]
(
[acd_ID] [int] NOT NULL IDENTITY(1, 1),
[srp_ID] [int] NOT NULL,
[acd_AccidentType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_AccidentType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_VehicleRole] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_Description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_Comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_DOTRecordable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_RoadSituation] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_Illumination] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_WeatherType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_RoadSurface] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_NbrOfInjuries] [tinyint] NULL,
[acd_NbrOfFatalities] [tinyint] NULL,
[acd_AlcoholTestDone] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_HoursToAlcoholTest] [tinyint] NULL,
[acd_AlcoholTestDate] [datetime] NULL,
[acd_AlcoholTestResult] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_DrugTestDone] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_HoursToDrugTest] [tinyint] NULL,
[acd_DrugTestDate] [datetime] NULL,
[acd_DrugTestResult] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_CorrectiveActionReq] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_DriverAtWheel] [tinyint] NULL,
[acd_Driver1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_Driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_trailer1] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_trailer2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_Pictures] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_CVDamage] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_Trl1damage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_Trl2Damage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_TrcDamage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_VehicleTowed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_TowDestination] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_TowDestAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_TowDestCity] [int] NULL,
[acd_TowDestCtynmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_TowDestState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_TowDestZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_TowDestCountry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_TowDestPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_LawEnfDeptName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_LawEnfDeptAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_LawEnfDeptCity] [int] NULL,
[acd_LawEnfDeptCtynmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_LawEnfDeptState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_LawEnfDeptCountry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_LawEnfDeptZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_LawEnfDeptPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_LawEnfOfficer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_LawEnfOfficerBadge] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_PoliceReportNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_TicketIssued] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_TicketIssuedTo] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_TrafficViolation] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_TicketDesc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_Points] [tinyint] NULL,
[acd_AccdntPreventability] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_HazMat] [tinyint] NULL,
[acd_EstSpeed] [smallint] NULL,
[acd_RoadType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_ReportedToInsuranceCo] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_InsReportDate] [datetime] NULL,
[acd_OVDamaged] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_OPDamaged] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_cmpissuedpoints] [tinyint] NULL,
[acd_historicaldate] [datetime] NULL,
[acd_teamleader] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_logdrvhours] [float] NULL,
[acd_logodhours] [float] NULL,
[acd_bigstring1] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_CKBox1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_CKBox2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_CKBox3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_CKBox4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_CKBox5] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_string1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_string2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_string3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_string4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_string5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_number1] [money] NULL,
[acd_number2] [money] NULL,
[acd_number3] [money] NULL,
[acd_number4] [money] NULL,
[acd_number5] [money] NULL,
[acd_AccidentType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_AccidentType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_AccidentType5] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_AccidentType6] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_AccidentType7] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acd_date1] [datetime] NULL,
[acd_date2] [datetime] NULL,
[acd_date3] [datetime] NULL,
[acd_date4] [datetime] NULL,
[acd_date5] [datetime] NULL,
[dw_timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_accident] ON [dbo].[ACCIDENT] FOR DELETE
AS
SET NOCOUNT ON
DECLARE @srp_id					INT,
		@acd_driveratwheel		INT,
		@acd_driver1			VARCHAR(8),
		@acd_driver2			VARCHAR(8),
		@acd_accidenttype2		VARCHAR(6),
		@acd_cmpissuedpoints	TINYINT
	
IF (SELECT gi_string1
      FROM generalinfo
     WHERE gi_name = 'CompanyIssuedPoints') = 'Y'
BEGIN
   SELECT @srp_id = srp_id,
		  @acd_driveratwheel = acd_driveratwheel,
          @acd_driver1 = ISNULL(acd_driver1, 'UNKNOWN'),
          @acd_driver2 = ISNULL(acd_driver2, 'UNKNOWN'),
          @acd_accidenttype2 = ISNULL(acd_accidenttype2, 'UNK'),
          @acd_cmpissuedpoints = ISNULL(acd_cmpissuedpoints, 0)
     FROM deleted

   IF @srp_id = 0 AND @acd_driver1 <> 'UNKNOWN' AND @acd_accidenttype2 <> 'UNK' AND @acd_cmpissuedpoints > 0
      EXEC update_driver_cmpissuedpoints @acd_driver1
   IF @srp_id > 0 AND @acd_driveratwheel = 1 AND @acd_driver1 <> 'UNKNOWN' AND @acd_accidenttype2 <> 'UNK' AND 
      @acd_cmpissuedpoints > 0
      EXEC update_driver_cmpissuedpoints @acd_driver1
   IF @srp_id > 0 AND @acd_driveratwheel = 2 AND @acd_driver2 <> 'UNKNOWN' AND @acd_accidenttype2 <> 'UNK' AND 
      @acd_cmpissuedpoints > 0
      EXEC update_driver_cmpissuedpoints @acd_driver2
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_accident] ON [dbo].[ACCIDENT] FOR INSERT
AS
SET NOCOUNT ON
DECLARE @srp_id					INT,
		@acd_driveratwheel		INT,
		@acd_driver1			VARCHAR(8),
		@acd_driver2			VARCHAR(8),
		@acd_accidenttype2		VARCHAR(6),
		@acd_cmpissuedpoints	TINYINT
	
IF (SELECT gi_string1
      FROM generalinfo
     WHERE gi_name = 'CompanyIssuedPoints') = 'Y'
BEGIN
   SELECT @srp_id = srp_id,
		  @acd_driveratwheel = acd_driveratwheel,
          @acd_driver1 = ISNULL(acd_driver1, 'UNKNOWN'),
          @acd_driver2 = ISNULL(acd_driver2, 'UNKNOWN'),
          @acd_accidenttype2 = ISNULL(acd_accidenttype2, 'UNK'),
          @acd_cmpissuedpoints = ISNULL(acd_cmpissuedpoints, 0)
     FROM inserted
     
   IF @srp_id = 0 AND @acd_driver1 <> 'UNKNOWN' AND @acd_accidenttype2 <> 'UNK' AND @acd_cmpissuedpoints > 0
      EXEC update_driver_cmpissuedpoints @acd_driver1	
   IF @srp_id > 0 AND @acd_driveratwheel = 1 AND @acd_driver1 <> 'UNKNOWN' AND @acd_accidenttype2 <> 'UNK' AND 
      @acd_cmpissuedpoints > 0
      EXEC update_driver_cmpissuedpoints @acd_driver1
   IF @srp_id > 0 AND @acd_driveratwheel = 2 AND @acd_driver2 <> 'UNKNOWN' AND @acd_accidenttype2 <> 'UNK' AND 
      @acd_cmpissuedpoints > 0
      EXEC update_driver_cmpissuedpoints @acd_driver2
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_accident_SyncDriverAccident] ON [dbo].[ACCIDENT]
FOR INSERT, UPDATE
AS
	SET NOCOUNT ON 

	DECLARE @DoSync char(1)

	SELECT	@DoSync	= ISNULL(gi_string1, 'N')
	FROM generalinfo 
	WHERE gi_name = 'SafetyReportSyncDriverAccident'

	IF @DoSync = 'N' BEGIN
		RETURN
	END

	UPDATE driveraccident
	SET dra_points = ins.acd_points,
		dra_preventable = case ins.acd_AccdntPreventability
							when 'PREV' then 'Y'
							when 'UNAV' then 'N'
							else 'I'
						  end,
--		dra_dispatcher = (SELECT lbl.abbr FROM labelfile lbl WHERE lbl.name = ins.acd_teamleader)  --49304 pmill
		dra_dispatcher = (SELECT lbl.abbr FROM labelfile lbl WHERE lbl.labeldefinition = 'TeamLeader' and lbl.name = ins.acd_teamleader)
	FROM driveraccident da inner join safetyreport sr on (da.mpp_id = sr.srp_driver1 and da.dra_accidentdate = sr.srp_EventDate)
		inner join inserted ins on (ins.srp_id = sr.srp_id)




GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_accident] ON [dbo].[ACCIDENT] FOR UPDATE
AS
SET NOCOUNT ON
DECLARE @srp_id					INT,
		@acd_driveratwheel		INT,
		@acd_driver1			VARCHAR(8),
		@acd_driver2			VARCHAR(8),
		@acd_accidenttype2		VARCHAR(6),
		@acd_cmpissuedpoints	TINYINT
	
IF (SELECT gi_string1
      FROM generalinfo
     WHERE gi_name = 'CompanyIssuedPoints') = 'Y'
BEGIN
   SELECT @srp_id = srp_id,
		  @acd_driveratwheel = acd_driveratwheel,
          @acd_driver1 = ISNULL(acd_driver1, 'UNKNOWN'),
          @acd_driver2 = ISNULL(acd_driver2, 'UNKNOWN'),
          @acd_accidenttype2 = ISNULL(acd_accidenttype2, 'UNK'),
          @acd_cmpissuedpoints = ISNULL(acd_cmpissuedpoints, 0)
     FROM inserted
     
   IF @srp_id = 0 AND @acd_driver1 <> 'UNKNOWN' AND @acd_accidenttype2 <> 'UNK' AND @acd_cmpissuedpoints > 0
      EXEC update_driver_cmpissuedpoints @acd_driver1
   IF @srp_id > 0 AND @acd_driveratwheel = 1 AND @acd_driver1 <> 'UNKNOWN' AND @acd_accidenttype2 <> 'UNK'
      EXEC update_driver_cmpissuedpoints @acd_driver1
   IF @srp_id > 0 AND @acd_driveratwheel = 2 AND @acd_driver2 <> 'UNKNOWN' AND @acd_accidenttype2 <> 'UNK'
      EXEC update_driver_cmpissuedpoints @acd_driver2
END

GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_acdID] ON [dbo].[ACCIDENT] ([acd_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ACCIDENT_timestamp] ON [dbo].[ACCIDENT] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [INX_srp] ON [dbo].[ACCIDENT] ([srp_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ACCIDENT] TO [public]
GO
GRANT INSERT ON  [dbo].[ACCIDENT] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ACCIDENT] TO [public]
GO
GRANT SELECT ON  [dbo].[ACCIDENT] TO [public]
GO
GRANT UPDATE ON  [dbo].[ACCIDENT] TO [public]
GO
