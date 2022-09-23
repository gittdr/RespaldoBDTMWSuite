CREATE TABLE [dbo].[MoneyCodeUsage]
(
[mcu_id] [int] NOT NULL IDENTITY(1, 1),
[mcu_CodeId] [int] NULL,
[mcu_CreateDate] [datetime] NULL,
[mcu_ActivationDate] [datetime] NULL,
[mcu_CarrierId] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcu_ContractId] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcu_OriginalAmount] [money] NULL,
[mcu_AmountUsed] [money] NULL,
[mcu_PayeeName] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcu_FirstInitial] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcu_Coxref] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcu_IssuedTo] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcu_WhoOrIssuedBy] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcu_Notes] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcu_CodeStatus] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcu_VoidedDate] [datetime] NULL,
[mcu_FeeAmount] [money] NULL,
[mcu_EFSCheckFee] [money] NULL,
[mcu_ExpressCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcu_DeductFee] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcu_CreditFlagVoided] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcu_ConversionRate] [decimal] (11, 4) NULL,
[mcu_OneTimeUse] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mcu_ReportedCarrier] [datetime] NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedOn] [datetime] NOT NULL,
[LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedOn] [datetime] NOT NULL,
[PayDetailAction] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_number] [int] NULL,
[ErrorMessage] [varchar] (4096) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_MoneyCodeUsageCreatedOn] ON [dbo].[MoneyCodeUsage] ([CreatedOn]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_MoneyCodeUsageExpressCode] ON [dbo].[MoneyCodeUsage] ([mcu_ExpressCode]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [pk_MoneyCodeUsage] ON [dbo].[MoneyCodeUsage] ([mcu_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MoneyCodeUsage] TO [public]
GO
GRANT INSERT ON  [dbo].[MoneyCodeUsage] TO [public]
GO
GRANT SELECT ON  [dbo].[MoneyCodeUsage] TO [public]
GO
GRANT UPDATE ON  [dbo].[MoneyCodeUsage] TO [public]
GO
