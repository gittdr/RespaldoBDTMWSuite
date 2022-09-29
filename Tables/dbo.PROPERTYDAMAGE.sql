CREATE TABLE [dbo].[PROPERTYDAMAGE]
(
[prp_ID] [int] NOT NULL IDENTITY(1, 1),
[srp_ID] [int] NOT NULL,
[prp_Sequence] [tinyint] NOT NULL,
[prp_Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_Damage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_Value] [money] NULL,
[prp_Comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_ActionTaken] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_OwnerIs] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_OwnerCompanyID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_OwnerName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_OwnerAddress1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_OwnerAddress2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_OwnerCity] [int] NULL,
[prp_OwnerCtynmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_OwnerState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_OwnerZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_OwnerCountry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_OwnerPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_CKBox1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_CKBox2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_CKBox3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_CKBox4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_CKBox5] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_string1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_string2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_string3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_string4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_string5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_number1] [money] NULL,
[prp_number2] [money] NULL,
[prp_number3] [money] NULL,
[prp_number4] [money] NULL,
[prp_number5] [money] NULL,
[prp_date1] [datetime] NULL,
[prp_date2] [datetime] NULL,
[prp_date3] [datetime] NULL,
[prp_date4] [datetime] NULL,
[prp_date5] [datetime] NULL,
[prp_PropDamageType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_PropDamageType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_PropDamageType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prp_PropDamageType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__PROPERTYD__INS_T__6B64A34D] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_PROPERTYDAMAGE_timestamp] ON [dbo].[PROPERTYDAMAGE] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PROPERTYDAMAGE_INS_TIMESTAMP] ON [dbo].[PROPERTYDAMAGE] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_ovdID] ON [dbo].[PROPERTYDAMAGE] ([prp_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [INX_srpseq] ON [dbo].[PROPERTYDAMAGE] ([srp_ID], [prp_Sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PROPERTYDAMAGE] TO [public]
GO
GRANT INSERT ON  [dbo].[PROPERTYDAMAGE] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PROPERTYDAMAGE] TO [public]
GO
GRANT SELECT ON  [dbo].[PROPERTYDAMAGE] TO [public]
GO
GRANT UPDATE ON  [dbo].[PROPERTYDAMAGE] TO [public]
GO
