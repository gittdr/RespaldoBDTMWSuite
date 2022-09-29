CREATE TABLE [dbo].[ttsusers]
(
[usr_fname] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_mname] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_lname] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[usr_password] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[usr_localini] [char] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_pwexp_dt] [datetime] NULL,
[usr_pwexp_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_pwexp_period] [int] NULL,
[timestamp] [timestamp] NULL,
[usr_sysadmin] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_mail_address] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_thirdparty] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_supervisor] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_lgh_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_candeletepay] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_booking_terminal] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_contact_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_dateformat] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_timeformat] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_printinvoices] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ttsusers__usr_pr__5D0FCE08] DEFAULT ('N'),
[usr_windows_userid] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[encrypt_password_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[encrypt_password_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_contact_fax] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_DSTApplies] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_GMTDelta] [smallint] NULL,
[usr_TZMins] [smallint] NULL,
[usr_maxlockcount] [int] NULL,
[usr_usedatecalendar] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_Imagepath] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_executing_terminal] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_pwdchange] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__ttsusers__usr_pw__6BBD784F] DEFAULT ('N'),
[settle_with_invoice] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__ttsusers__settle__0824ACD3] DEFAULT ('GI-DEFAULT'),
[settle_with_invoice_ivh_status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__ttsusers__settle__0918D10C] DEFAULT ('GI-DEFAULT'),
[usr_edi210print] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_DRFolder] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__ttsusers__INS_TI__005FC033] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[dt_ttsusers]
ON [dbo].[ttsusers]
FOR DELETE AS

DELETE usertypeassignment 
FROM deleted
WHERE usertypeassignment.usr_userid = deleted.usr_userid

DELETE branch_assignedtype
FROM deleted
WHERE bat_type ='USERS' and bat_value = deleted.usr_userid

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_ttsusers_rowsec] ON [dbo].[ttsusers]
FOR DELETE
AS
	--PTS 63035 JJF 20120517 - add itype
	DELETE	RowSecUserAssignments
	FROM	deleted d
	WHERE	RowSecUserAssignments.rsua_idtype = 'U'
			AND RowSecUserAssignments.usr_userid = d.usr_userid

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_ttsusers_rowsec] ON [dbo].[ttsusers]
FOR INSERT
AS
	--PTS 63035 JJF 20120517 - add idtype
	INSERT	RowSecUserAssignments (
				rsua_idtype,
				usr_userid,
				rscv_id
			)					
	SELECT	'U',
			tu.usr_userid, 
			rscv.rscv_id
	FROM	inserted tu
			CROSS JOIN RowSecColumns rsc
			INNER JOIN RowSecColumnValues rscv on rsc.rsc_id = rscv.rsc_id
	WHERE	rsc.rsc_sequence > 0
			AND rsc.rsc_unknown_value = rscv.rscv_value
			AND NOT EXISTS	(	SELECT	*
								FROM	RowSecUserAssignments rsua_inner
										INNER JOIN RowSecColumnValues rscv_inner on rscv_inner.rscv_id = rsua_inner.rscv_id
								WHERE	rsua_inner.rsua_idtype = 'U'
										AND rsua_inner.usr_userid = tu.usr_userid
										AND rscv_inner.rscv_value = rscv.rscv_value
										AND rscv_inner.rsc_id = rsc.rsc_id
							)	

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[itut_ttsusers]
ON [dbo].[ttsusers]
FOR INSERT, UPDATE AS

IF UPDATE (usr_type1)
BEGIN

	IF NOT EXISTS (SELECT * FROM usertypeassignment 
			JOIN inserted ON inserted.usr_userid = usertypeassignment.usr_userid AND inserted.usr_type1 = usertypeassignment.uta_type1 AND usertypeassignment.uta_default = '1')
	BEGIN

		DELETE usertypeassignment
		FROM deleted
		WHERE deleted.usr_userid = usertypeassignment.usr_userid AND deleted.usr_type1 = usertypeassignment.uta_type1
		
		IF NOT EXISTS (SELECT * FROM usertypeassignment 
				JOIN inserted ON inserted.usr_userid = usertypeassignment.usr_userid AND inserted.usr_type1 = usertypeassignment.uta_type1)
			INSERT INTO usertypeassignment
				(usr_userid,				
				 uta_type1,				
				 uta_default,			
				 uta_flag,				
				 uta_expupdate)
			SELECT usr_userid
				, usr_type1
				, '1'
				, '0'
				, '0'
			FROM inserted 
		ELSE
			UPDATE usertypeassignment
			SET uta_default = '1'
			FROM inserted
			WHERE inserted.usr_userid = usertypeassignment.usr_userid AND inserted.usr_type1 = usertypeassignment.uta_type1
	END			
END


GO
CREATE NONCLUSTERED INDEX [ttsusers_INS_TIMESTAMP] ON [dbo].[ttsusers] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ttsusers_timestamp] ON [dbo].[ttsusers] ([timestamp]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ttsusers] ADD CONSTRAINT [un_usr_userid] UNIQUE NONCLUSTERED ([usr_userid]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [id] ON [dbo].[ttsusers] ([usr_userid], [usr_password]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ttsusers_usr_windows_userid] ON [dbo].[ttsusers] ([usr_windows_userid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ttsusers] TO [public]
GO
GRANT INSERT ON  [dbo].[ttsusers] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ttsusers] TO [public]
GO
GRANT SELECT ON  [dbo].[ttsusers] TO [public]
GO
GRANT UPDATE ON  [dbo].[ttsusers] TO [public]
GO
