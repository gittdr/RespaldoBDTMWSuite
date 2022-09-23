CREATE TABLE [dbo].[SPILL]
(
[spl_ID] [int] NOT NULL IDENTITY(1, 1),
[srp_ID] [int] NOT NULL,
[spl_SpillType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_SpillType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_Description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_Comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_ActionTaken] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_Damage] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_Driver1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_Driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_trailer1] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_trailer2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_Pictures] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_LawEnfDeptName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_LawEnfDeptAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_LawEnfDeptctynmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_LawEnfDeptCity] [int] NULL,
[spl_LawEnfDeptState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_LawEnfDeptZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_LawEnfDeptCountry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_LawEnfDeptPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_LawEnfOfficer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_LawEnfOfficerBadge] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_PoliceReportNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_TicketIssued] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_TrafficViolation] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_AccdntPreventability] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_HazMat] [tinyint] NULL,
[spl_OwnerIs] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_OwnerCmpID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_OwnerName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_OwnerAddress1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_OwnerAddress2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_OwnerCity] [int] NULL,
[spl_OwnerCtynmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_OwnerState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_OwnerZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_OwnerCountry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_OwnerPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_TicketIssuedTo] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_TicketDesc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_Points] [tinyint] NULL,
[spl_CKBox1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_CKBox2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_CKBox3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_CKBox4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_CKBox5] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_string1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_string2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_string3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_string4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_string5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_number1] [money] NULL,
[spl_number2] [money] NULL,
[spl_number3] [money] NULL,
[spl_number4] [money] NULL,
[spl_number5] [money] NULL,
[spl_SpillType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_SpillType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_SpillType5] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_SpillType6] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_SpillType7] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_date1] [datetime] NULL,
[spl_date2] [datetime] NULL,
[spl_date3] [datetime] NULL,
[spl_date4] [datetime] NULL,
[spl_date5] [datetime] NULL,
[dw_timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SPILL_timestamp] ON [dbo].[SPILL] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_splID] ON [dbo].[SPILL] ([spl_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [INX_srp] ON [dbo].[SPILL] ([srp_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SPILL] TO [public]
GO
GRANT INSERT ON  [dbo].[SPILL] TO [public]
GO
GRANT REFERENCES ON  [dbo].[SPILL] TO [public]
GO
GRANT SELECT ON  [dbo].[SPILL] TO [public]
GO
GRANT UPDATE ON  [dbo].[SPILL] TO [public]
GO
