CREATE TABLE [dbo].[SAFETYCOST]
(
[sc_ID] [int] NOT NULL IDENTITY(1, 1),
[srp_ID] [int] NOT NULL,
[sc_Sequence] [tinyint] NOT NULL,
[sc_DateEntered] [datetime] NOT NULL,
[sc_DateOfService] [datetime] NULL,
[sc_DescOfService] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sc_PaidByCmp] [money] NULL,
[sc_PaidByIns] [money] NULL,
[sc_RecoveredCost] [money] NULL,
[sc_CostType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sc_CostType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sc_CKBox1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sc_CKBox2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sc_CKBox3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sc_CKBox4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sc_CKBox5] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sc_string1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sc_string2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sc_string3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sc_string4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sc_string5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sc_number1] [money] NULL,
[sc_number2] [money] NULL,
[sc_number3] [money] NULL,
[sc_number4] [money] NULL,
[sc_number5] [money] NULL,
[sc_date1] [datetime] NULL,
[sc_date2] [datetime] NULL,
[sc_date3] [datetime] NULL,
[sc_date4] [datetime] NULL,
[sc_date5] [datetime] NULL,
[sc_CostType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sc_CostType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sc_CostType5] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sc_CostType6] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__SAFETYCOS__INS_T__6F353431] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SAFETYCOST_timestamp] ON [dbo].[SAFETYCOST] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SAFETYCOST_INS_TIMESTAMP] ON [dbo].[SAFETYCOST] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_scID] ON [dbo].[SAFETYCOST] ([sc_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SAFETYCOST] TO [public]
GO
GRANT INSERT ON  [dbo].[SAFETYCOST] TO [public]
GO
GRANT REFERENCES ON  [dbo].[SAFETYCOST] TO [public]
GO
GRANT SELECT ON  [dbo].[SAFETYCOST] TO [public]
GO
GRANT UPDATE ON  [dbo].[SAFETYCOST] TO [public]
GO
