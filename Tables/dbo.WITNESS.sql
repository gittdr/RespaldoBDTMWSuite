CREATE TABLE [dbo].[WITNESS]
(
[wit_ID] [int] NOT NULL IDENTITY(1, 1),
[srp_ID] [int] NOT NULL,
[wit_Sequence] [tinyint] NOT NULL,
[wit_witnessIs] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_MppOrEeID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_Address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_Address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_city] [int] NULL,
[wit_Ctynmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_State] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_zip] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_Country] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_HomePhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_WorkPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_Comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_EmailAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_role] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_CKBox1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_CKBox2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_CKBox3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_CKBox4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_CKBox5] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_string1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_string2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_string3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_string4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_string5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_number1] [money] NULL,
[wit_number2] [money] NULL,
[wit_number3] [money] NULL,
[wit_number4] [money] NULL,
[wit_number5] [money] NULL,
[wit_WitnessType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_WitnessType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_WitnessType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_WitnessType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_WitnessType5] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_WitnessType6] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wit_date1] [datetime] NULL,
[wit_date2] [datetime] NULL,
[wit_date3] [datetime] NULL,
[wit_date4] [datetime] NULL,
[wit_date5] [datetime] NULL,
[dw_timestamp] [timestamp] NOT NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__WITNESS__INS_TIM__024808A5] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_WITNESS_timestamp] ON [dbo].[WITNESS] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [WITNESS_INS_TIMESTAMP] ON [dbo].[WITNESS] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_srpseq] ON [dbo].[WITNESS] ([srp_ID], [wit_Sequence]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_witID] ON [dbo].[WITNESS] ([wit_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WITNESS] TO [public]
GO
GRANT INSERT ON  [dbo].[WITNESS] TO [public]
GO
GRANT REFERENCES ON  [dbo].[WITNESS] TO [public]
GO
GRANT SELECT ON  [dbo].[WITNESS] TO [public]
GO
GRANT UPDATE ON  [dbo].[WITNESS] TO [public]
GO
