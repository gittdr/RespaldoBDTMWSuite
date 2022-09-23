CREATE TABLE [dbo].[CARGODAMAGE]
(
[cdm_ID] [int] NOT NULL IDENTITY(1, 1),
[srp_ID] [int] NOT NULL,
[cdm_Sequence] [tinyint] NOT NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_Description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_Hazmat] [int] NULL,
[cdm_Damage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_quantity] [decimal] (9, 2) NULL,
[cdm_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_Value] [money] NULL,
[cdm_CargoDamageType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_CargoDamageType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_CargoDamageType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_CargoDamageType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_OwnerIs] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_OwnerCompanyID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_OwnerName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_OwnerAddress1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_OwnerAddress2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_OwnerCity] [int] NULL,
[cdm_OwnerCtynmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_OwnerState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_OwnerZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_OwnerCountry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_OwnerPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_CKBox1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_CKBox2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_CKBox3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_CKBox4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_CKBox5] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_string1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_string2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_string3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_string4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_string5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_number1] [money] NULL,
[cdm_number2] [money] NULL,
[cdm_number3] [money] NULL,
[cdm_number4] [money] NULL,
[cdm_number5] [money] NULL,
[cdm_date1] [datetime] NULL,
[cdm_date2] [datetime] NULL,
[cdm_date3] [datetime] NULL,
[cdm_date4] [datetime] NULL,
[cdm_date5] [datetime] NULL,
[cdm_CargoDamageType5] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdm_CargoDamageType6] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_cdmID] ON [dbo].[CARGODAMAGE] ([cdm_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_CARGODAMAGE_timestamp] ON [dbo].[CARGODAMAGE] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [INX_srpcmd] ON [dbo].[CARGODAMAGE] ([srp_ID], [cmd_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CARGODAMAGE] TO [public]
GO
GRANT INSERT ON  [dbo].[CARGODAMAGE] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CARGODAMAGE] TO [public]
GO
GRANT SELECT ON  [dbo].[CARGODAMAGE] TO [public]
GO
GRANT UPDATE ON  [dbo].[CARGODAMAGE] TO [public]
GO
