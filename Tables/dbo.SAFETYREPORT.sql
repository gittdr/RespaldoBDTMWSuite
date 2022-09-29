CREATE TABLE [dbo].[SAFETYREPORT]
(
[srp_ID] [int] NOT NULL,
[srp_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[srp_EventDate] [datetime] NULL,
[srp_EventLocIs] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_EventLocCmpID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_EventLoc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_EventAddress1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_EventAddress2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_EventCity] [int] NULL,
[srp_Eventctynmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_EventState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_EventZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_EventCountry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_OnPremises] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_Classification] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_SafetyType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_SafetyType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_SafetyType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_SafetyType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_SafetyStatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_ReportedBy] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_ReportedDate] [datetime] NULL,
[srp_Req1Complete] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_Req1DtDone] [datetime] NULL,
[srp_Req2Complete] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_Req2DtDone] [datetime] NULL,
[srp_Req3Complete] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_Req3DtDone] [datetime] NULL,
[srp_Req4Complete] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_Req4DtDone] [datetime] NULL,
[srp_Req5Complete] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_Req5DtDone] [datetime] NULL,
[srp_Req6Complete] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_Req6DtDone] [datetime] NULL,
[srp_ResponsibleParty] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_ResponsiblePartyDesc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_EstCost] [money] NULL,
[srp_TotalPaidByCmp] [money] NULL,
[srp_TotalPaidByIns] [money] NULL,
[srp_TotalReserves] [money] NULL,
[srp_TotalRecovered] [money] NULL,
[srp_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_trailer1] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_trailer2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_driver1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_mpporeeid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_Hazmat] [tinyint] NULL,
[srp_inscompany] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_inscoaddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_inscocity] [int] NULL,
[srp_inscoctynmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_inscostate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_inscozip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_inscocountry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_inscophone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_reportedtoinsurance] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_InsCoReportDate] [datetime] NULL,
[srp_claimnbr] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_inspolicynbr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[srp_cargodamagecost] [money] NULL,
[srp_propdamagecost] [money] NULL,
[srp_vdamagecost] [money] NULL,
[srp_mappedrevtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_number_driver1] [int] NULL,
[not_number_trip] [int] NULL,
[srp_reportedbyname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_insagent] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_CKBox1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_CKBox2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_CKBox3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_CKBox4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_CKBox5] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_string1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_string2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_string3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_string4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_string5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_number1] [money] NULL,
[srp_number2] [money] NULL,
[srp_number3] [money] NULL,
[srp_number4] [money] NULL,
[srp_number5] [money] NULL,
[srp_safetyType5] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_safetyType6] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_safetyType7] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_safetyType8] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[srp_date1] [datetime] NULL,
[srp_date2] [datetime] NULL,
[srp_date3] [datetime] NULL,
[srp_date4] [datetime] NULL,
[srp_date5] [datetime] NULL,
[ord_booked_revtype1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_booked_revtype1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__SAFETYREP__INS_T__7029586A] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[dt_safetyreport_SyncDriverAccident] ON [dbo].[SAFETYREPORT]
FOR DELETE
AS
	SET NOCOUNT ON 

	DECLARE @DoSync char(1)

	SELECT	@DoSync	= ISNULL(gi_string1, 'N')
	FROM generalinfo 
	WHERE gi_name = 'SafetyReportSyncDriverAccident'

	IF @DoSync = 'N' BEGIN
		RETURN
	END

	DELETE driveraccident 
	FROM driveraccident inner join deleted on (mpp_id = deleted.srp_driver1 and dra_accidentdate = deleted.srp_EventDate)


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[dt_safetyreport_SyncNotes] ON [dbo].[SAFETYREPORT]
FOR DELETE
AS
	SET NOCOUNT ON 

	DECLARE @DoSync char(1)

	SELECT	@DoSync	= ISNULL(gi_string1, 'N')
	FROM generalinfo 
	WHERE gi_name = 'SafetyReportSyncNotes'

	IF @DoSync = 'N' BEGIN
		RETURN
	END

	DELETE notes
	FROM notes inner join deleted on notes.not_number = deleted.not_number_driver1

	DELETE notes
	FROM notes inner join deleted on notes.not_number = deleted.not_number_trip
	


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_safetyreport_SyncDriverAccident] ON [dbo].[SAFETYREPORT]
FOR INSERT, UPDATE
AS
	SET NOCOUNT ON 

	DECLARE @DoSync char(1)

	SELECT	@DoSync	= ISNULL(gi_string1, 'N')
	FROM	generalinfo 
	WHERE	gi_name = 'SafetyReportSyncDriverAccident'

	IF @DoSync = 'N' BEGIN
		RETURN
	END

	INSERT INTO	driveraccident(
					mpp_id,
					dra_accidentdate
				) 
	SELECT DISTINCT	srp_driver1,
					srp_EventDate
	FROM			inserted
	WHERE isnull(srp_driver1, 'UNKNOWN') <> 'UNKNOWN'
			and srp_Classification = 'ACC'
			and not exists(SELECT * 
							FROM driveraccident drainner 
							WHERE drainner.mpp_id = inserted.srp_driver1
									and drainner.dra_accidentdate = inserted.srp_EventDate)

	UPDATE	driveraccident
	SET		dra_description = 'Safety Report: ' + convert(varchar(20), srp_number) + ' - ' + srp_description,
			dra_filenumber = left(srp_number, 12),
			--dra_code = null,
			trc_number = srp_tractor,
			trl_number = srp_trailer1,	  
			dra_location = left(srp_EventLoc, 30),
			dra_status =	CASE inserted.srp_safetystatus
								WHEN 'CLOSED' THEN 'CLD'
								WHEN 'UNK' THEN NULL
								ELSE 'OPN'
							END,
			cty_nmstct = srp_Eventctynmstct,
			dra_reserve = srp_TotalReserves,
			--dra_dispatcher = null,
			dra_cost = (srp_totalpaidbycmp + srp_TotalPaidByIns)
	FROM	driveraccident da inner join inserted on (da.mpp_id = inserted.srp_driver1 and da.dra_accidentdate = inserted.srp_EventDate)



GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[iut_safetyreport_SyncNotes] ON [dbo].[SAFETYREPORT]
FOR INSERT, UPDATE
AS
	SET NOCOUNT ON 

	DECLARE @DoSync char(1),
			@urgent char(1),
			@expires datetime,
			@expiredays int,
			@table varchar(18),
			@tablekey varchar(18),
			@NextNoteID int,
			@NextSequence int,
			@srp_id_last int

	SELECT	@DoSync	= ISNULL(gi_string1, 'N'),
			@urgent = ISNULL(gi_string2, 'N'),
			@expiredays = ISNULL(gi_integer1, 0)
	FROM	generalinfo 
	WHERE	gi_name = 'SafetyReportSyncNotes'

	IF @DoSync = 'N' BEGIN
		RETURN
	END


	SELECT @table = 'manpowerprofile'

	--Add note entry for driver1
	UPDATE	notes
	SET		not_text = LEFT('Safety Report: ' + convert(varchar(20), srp_number) + ' - ' + srp_description, 254),
			ntb_table = @table,
			nre_tablekey = srp_driver1,
			not_expires =	CASE @expiredays
								WHEN 0 then '20491231 23:59'
								ELSE dateadd(dd, @expiredays, CAST(CONVERT(VARCHAR(10), inserted.srp_EventDate, 102) + ' 23:59' as datetime))
							END
	FROM	notes inner join inserted on notes.not_number = inserted.not_number_driver1
	WHERE inserted.srp_driver1 <> 'UNKNOWN'
	
	--Remove any notes where Driver now UNKNOWN
	DELETE	notes
	FROM	notes inner join inserted on notes.not_number = inserted.not_number_driver1
	WHERE isnull(inserted.srp_driver1, 'UNKNOWN') = 'UNKNOWN'

	UPDATE	SAFETYREPORT
	SET		not_number_driver1 = NULL
	FROM	SAFETYREPORT inner join inserted on SAFETYREPORT.srp_id = inserted.srp_id
	WHERE	isnull(inserted.srp_driver1, 'UNKNOWN') = 'UNKNOWN'

	--Loop through to add remaining notes not updated
	--Add note entry for driver1
	SELECT	@srp_id_last = MIN(srp_id) 
	FROM	inserted
	WHERE	inserted.not_number_driver1 is null
			AND inserted.srp_driver1 <> 'UNKNOWN'
	

	WHILE @srp_id_last IS NOT NULL BEGIN
		SELECT	@tablekey = srp_driver1,
				@expires =	CASE @expiredays
								WHEN 0 then '20491231 23:59'
								ELSE dateadd(dd, @expiredays, CAST(CONVERT(VARCHAR(10), inserted.srp_EventDate, 102) + ' 23:59' as datetime))
							END

		FROM	inserted
		WHERE	inserted.srp_id =  @srp_id_last

		--Get the next sequence number
		SELECT	@NextSequence = ISNULL(MAX(not_sequence), 0) + 1
		FROM	notes
		WHERE	ntb_table = @Table 
				AND nre_tablekey = @TableKey

		exec @NextNoteID = getsystemnumber  'NOTES', NULL

		INSERT INTO	notes(
						not_number,
						not_text,
						not_type,
						not_urgent,
						not_expires,
						ntb_table,
						nre_tablekey,
						not_sequence
					)
		         
		SELECT 	@NextNoteID,
				'Safety Report: ' + convert(varchar(20), srp_number) + ' - ' + srp_description,
				'SFTRPT',
				@urgent,
				@expires,
				@table,
				@tablekey,
				@NextSequence
		FROM	inserted
		WHERE	inserted.srp_id = @srp_id_last
				
		UPDATE	safetyreport
		SET		not_number_driver1 = @NextNoteID
		FROM	inserted
		WHERE	safetyreport.srp_id = @srp_id_last

		SELECT	@srp_id_last = MIN(srp_id) 
		FROM	inserted
		WHERE	srp_id > @srp_id_last
				and inserted.not_number_driver1 is null
				AND inserted.srp_driver1 <> 'UNKNOWN'
		
	END


	--Remove any notes where order now not defined
	DELETE	notes
	FROM	notes inner join inserted on notes.not_number = inserted.not_number_trip
	WHERE isnull(inserted.ord_number, '') = '' AND isnull(inserted.mov_number, 0) = 0 AND isnull(lgh_number, 0) = 0

	UPDATE	SAFETYREPORT
	SET		not_number_trip = NULL
	FROM	SAFETYREPORT inner join inserted on SAFETYREPORT.srp_id = inserted.srp_id
	WHERE	isnull(inserted.ord_number, '') = '' AND isnull(inserted.mov_number, 0) = 0 AND isnull(inserted.lgh_number, 0) = 0


	--Add note entry for order
	UPDATE	notes
	SET		not_text = LEFT('Safety Report: ' + convert(varchar(20), i.srp_number) + ' - ' + i.srp_description, 254),
			ntb_table =		CASE WHEN i.ord_number > '' THEN 'orderheader' 
								WHEN i.mov_number > 0 THEN 'movement'
								WHEN i.lgh_number > 0 Then 'movement'
								ELSE  null
							END,
			nre_tablekey =	CASE WHEN i.ord_number > '' THEN (SELECT ohinner.ord_hdrnumber FROM orderheader ohinner WHERE ohinner.ord_number = i.ord_number)
								WHEN i.mov_number > 0 THEN convert(varchar(20), i.mov_number)
								WHEN i.lgh_number > 0 THEN (SELECT convert(varchar(20), mov_number) FROM legheader lghinner where lghinner.lgh_number = i.lgh_number)
								ELSE  null
							END,
			not_expires =	CASE @expiredays
								WHEN 0 then '20491231 23:59'
								ELSE dateadd(dd, @expiredays, CAST(CONVERT(VARCHAR(10), i.srp_EventDate, 102) + ' 23:59' as datetime))
							END
	FROM	notes inner join inserted i on notes.not_number = i.not_number_trip
	WHERE i.ord_number <> '' OR i.mov_number > 0 OR i.lgh_number > 0

	--Loop through to add remaining notes not updated
	--Add note entry for order
	SELECT	@srp_id_last = MIN(i.srp_id) 
	FROM	inserted i
	WHERE	i.not_number_trip is null
			and (i.ord_number <> '' OR i.mov_number > 0 OR i.lgh_number > 0)

	WHILE @srp_id_last IS NOT NULL BEGIN
		SELECT	@table	=	CASE WHEN i.ord_number > '' THEN 'orderheader' 
								WHEN i.mov_number > 0 THEN 'movement'
								WHEN i.lgh_number > 0 Then 'movement'
								ELSE  null
							END,
				@tablekey = CASE WHEN i.ord_number > '' THEN (SELECT ohinner.ord_hdrnumber FROM orderheader ohinner WHERE ohinner.ord_number = i.ord_number)
								WHEN i.mov_number > 0 THEN convert(varchar(20), i.mov_number)
								WHEN i.lgh_number > 0 Then (SELECT convert(varchar(20), mov_number) FROM legheader lghinner where lghinner.lgh_number = i.lgh_number)
								ELSE  null
							END,
				@expires =	CASE @expiredays
								WHEN 0 then '20491231 23:59'
								ELSE dateadd(dd, @expiredays, CAST(CONVERT(VARCHAR(10), i.srp_EventDate, 102) + ' 23:59' as datetime))
							END

		FROM	inserted i
		WHERE	i.srp_id =  @srp_id_last

		--Get the next sequence number
		SELECT	@NextSequence = ISNULL(MAX(not_sequence), 0) + 1
		FROM	notes
		WHERE	ntb_table = @Table 
				AND nre_tablekey = @TableKey

		exec @NextNoteID = getsystemnumber  'NOTES', NULL

		INSERT INTO	notes(
						not_number,
						not_text,
						not_type,
						not_urgent,
						not_expires,
						ntb_table,
						nre_tablekey,
						not_sequence
					)
		         
		SELECT 	@NextNoteID,
				'Safety Report: ' + convert(varchar(20), srp_number) + ' - ' + srp_description,
				'SFTRPT',
				@urgent,
				@expires,
				@table,
				@tablekey,
				@NextSequence
		FROM	inserted
		WHERE	inserted.srp_id = @srp_id_last
				
		UPDATE	safetyreport
		SET		not_number_trip = @NextNoteID
		FROM	inserted
		WHERE	safetyreport.srp_id = @srp_id_last

		SELECT	@srp_id_last = MIN(i.srp_id) 
		FROM	inserted i
		WHERE	i.srp_id > @srp_id_last
				and i.not_number_trip is null
				and (i.ord_number <> '' OR i.mov_number > 0 OR i.lgh_number > 0)
		
	END


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[ut_safetyreport] ON [dbo].[SAFETYREPORT]
FOR UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
  Begin
    declare @old_srpnumber varchar(20), @new_srpnumber varchar(20)
    if ((select count(*) from inserted) > 1) OR ((select count(*) from deleted) > 1)
      RETURN
    select @new_srpnumber = srp_number from inserted
    select @old_srpnumber= srp_number from deleted
	 if update(srp_number) and (@old_srpnumber <> @new_srpnumber)
      if (select count(blob_key) from ps_blob_data where blob_table = 'safetyreport' and blob_key = @old_srpnumber) > 0
        update ps_blob_data set blob_key = @new_srpnumber where blob_table = 'safetyreport' and blob_key = @old_srpnumber
  end
GO
CREATE NONCLUSTERED INDEX [idx_SAFETYREPORT_timestamp] ON [dbo].[SAFETYREPORT] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SAFETYREPORT_INS_TIMESTAMP] ON [dbo].[SAFETYREPORT] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_srpID] ON [dbo].[SAFETYREPORT] ([srp_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_srpnumber] ON [dbo].[SAFETYREPORT] ([srp_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SAFETYREPORT] TO [public]
GO
GRANT INSERT ON  [dbo].[SAFETYREPORT] TO [public]
GO
GRANT REFERENCES ON  [dbo].[SAFETYREPORT] TO [public]
GO
GRANT SELECT ON  [dbo].[SAFETYREPORT] TO [public]
GO
GRANT UPDATE ON  [dbo].[SAFETYREPORT] TO [public]
GO
