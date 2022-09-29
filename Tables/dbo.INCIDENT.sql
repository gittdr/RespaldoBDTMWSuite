CREATE TABLE [dbo].[INCIDENT]
(
[inc_ID] [int] NOT NULL IDENTITY(1, 1),
[srp_ID] [int] NOT NULL,
[inc_Sequence] [tinyint] NOT NULL,
[inc_MppOrEeID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[inc_ReportedDate] [datetime] NULL,
[inc_ReceivedBy] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_HandledBy] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_TicketIssued] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_TrafficViolation] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_Points] [tinyint] NULL,
[inc_IncidentType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_IncidentType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_Description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_Comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_ComplaintantIs] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_EEComplaintant] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_ComplCmpID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_ComplName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_ComplAddress1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_ComplAddress2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_ComplCity] [int] NULL,
[inc_ComplCtynmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_ComplState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_ComplZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_ComplCountry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_ComplHomePhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_ComplWorkPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_FollowUpRequired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_FollowUpDesc] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_FollowUpCompleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_FollowUpCompletedDate] [datetime] NULL,
[inc_LawEnfDeptName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_LawEnfDeptAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_LawEnfDeptCity] [int] NULL,
[inc_LawEnfDeptCtynmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_LawEnfDeptState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_LawEnfDeptCountry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_LawEnfDeptZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_LawEnfDeptPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_LawEnfOfficer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_LawEnfOfficerBadge] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_PoliceReportNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_TicketIssuedTo] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_TicketDesc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_CKBox1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_CKBox2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_CKBox3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_CKBox4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_CKBox5] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_driver1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_trailer1] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_trailer2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_number] [int] NULL,
[mov_number] [int] NULL,
[inc_string1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_string2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_string3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_string4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_string5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_number1] [money] NULL,
[inc_number2] [money] NULL,
[inc_number3] [money] NULL,
[inc_number4] [money] NULL,
[inc_number5] [money] NULL,
[inc_IncidentType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_IncidentType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_IncidentType5] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_IncidentType6] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inc_date1] [datetime] NULL,
[inc_date2] [datetime] NULL,
[inc_date3] [datetime] NULL,
[inc_date4] [datetime] NULL,
[inc_date5] [datetime] NULL,
[inc_bigstring1] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__INCIDENT__INS_TI__54813DF5] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_INCIDENT_timestamp] ON [dbo].[INCIDENT] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_incID] ON [dbo].[INCIDENT] ([inc_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [INCIDENT_INS_TIMESTAMP] ON [dbo].[INCIDENT] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_srpEEDate] ON [dbo].[INCIDENT] ([srp_ID], [inc_Sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[INCIDENT] TO [public]
GO
GRANT INSERT ON  [dbo].[INCIDENT] TO [public]
GO
GRANT REFERENCES ON  [dbo].[INCIDENT] TO [public]
GO
GRANT SELECT ON  [dbo].[INCIDENT] TO [public]
GO
GRANT UPDATE ON  [dbo].[INCIDENT] TO [public]
GO
