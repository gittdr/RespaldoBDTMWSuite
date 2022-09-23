CREATE TABLE [dbo].[INJURY]
(
[inj_ID] [int] NOT NULL IDENTITY(1, 1),
[srp_ID] [int] NOT NULL,
[inj_sequence] [tinyint] NOT NULL,
[inj_ReportedDate] [datetime] NULL,
[inj_Description] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_Comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_HowOccurred] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_DateOfFullRelease] [datetime] NULL,
[inj_PersonIs] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_MppOrEeID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_Address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_Address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_City] [int] NULL,
[inj_Ctynmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_State] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_Country] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_HomePhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_WorkPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_LastDateWorked] [datetime] NULL,
[inj_ExpectedReturn] [datetime] NULL,
[inj_ClaimInDoubt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_InjuryType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_InjuryType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_IsFatal] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_TreatedAtScene] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_AtSceneCaregiver] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_TreatedAwayFromScene] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_ReportedToInsurance] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_InsCoReportDate] [datetime] NULL,
[inj_maritalstatus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_nbrdependents] [tinyint] NULL,
[inj_NextSchedAppt] [datetime] NULL,
[inj_DateofBirth] [datetime] NULL,
[inj_ssn] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_workstate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_occupation] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_medicalrestrictions] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_CKBox1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_CKBox2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_CKBox3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_CKBox4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_CKBox5] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_string1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_string2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_string3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_string4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_string5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_number1] [money] NULL,
[inj_number2] [money] NULL,
[inj_number3] [money] NULL,
[inj_number4] [money] NULL,
[inj_number5] [money] NULL,
[inj_date1] [datetime] NULL,
[inj_InjuryType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_InjuryType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_InjuryType5] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_InjuryType6] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inj_date2] [datetime] NULL,
[inj_date3] [datetime] NULL,
[inj_date4] [datetime] NULL,
[inj_date5] [datetime] NULL,
[dw_timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_INJURY_timestamp] ON [dbo].[INJURY] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_injID] ON [dbo].[INJURY] ([inj_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_srpseq] ON [dbo].[INJURY] ([srp_ID], [inj_sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[INJURY] TO [public]
GO
GRANT INSERT ON  [dbo].[INJURY] TO [public]
GO
GRANT REFERENCES ON  [dbo].[INJURY] TO [public]
GO
GRANT SELECT ON  [dbo].[INJURY] TO [public]
GO
GRANT UPDATE ON  [dbo].[INJURY] TO [public]
GO
