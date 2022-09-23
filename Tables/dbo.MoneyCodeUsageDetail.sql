CREATE TABLE [dbo].[MoneyCodeUsageDetail]
(
[mcud_id] [int] NOT NULL IDENTITY(1, 1),
[mcu_id] [int] NOT NULL,
[mcud_Sequence] [int] NULL,
[mcud_CheckNumber] [int] NULL,
[mcud_ExpressCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcud_CreateDate] [datetime] NULL,
[mcud_Amount] [money] NULL,
[mcud_AuthorizationCode] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcud_PayeeName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcud_FirstInitial] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcud_LocationID] [int] NULL,
[mcud_VoidedDate] [datetime] NULL,
[mcud_CreditFlagVoided] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcud_LocationTypeCode] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcud_LocationName] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcud_LocationCity] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcud_LocationState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcud_LocationCountry] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcud_LocationOpisID] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedOn] [datetime] NOT NULL,
[LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedOn] [datetime] NOT NULL,
[ErrorMessage] [varchar] (4096) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_MoneyCodeUsageDetial_mcu_id] ON [dbo].[MoneyCodeUsageDetail] ([mcu_id]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [pk_MoneyCodeUsageDetail] ON [dbo].[MoneyCodeUsageDetail] ([mcud_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MoneyCodeUsageDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[MoneyCodeUsageDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[MoneyCodeUsageDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[MoneyCodeUsageDetail] TO [public]
GO
