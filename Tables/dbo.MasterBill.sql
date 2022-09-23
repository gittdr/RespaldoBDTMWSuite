CREATE TABLE [dbo].[MasterBill]
(
[MasterBillId] [int] NOT NULL IDENTITY(1, 1),
[Status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MasterBil__Creat__1E0AFB3C] DEFAULT (suser_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__MasterBil__Creat__1EFF1F75] DEFAULT (getdate()),
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__MasterBil__LastU__1FF343AE] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MasterBil__LastU__20E767E7] DEFAULT (suser_name()),
[MasterBillTypeId] [int] NOT NULL,
[MasterBillStyleId] [int] NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MasterBillSystemControlId] [int] NULL,
[MasterBillOutputRestrictionId] [int] NULL,
[BillDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterBill] ADD CONSTRAINT [PK_dbo.MasterBill] PRIMARY KEY CLUSTERED ([MasterBillId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NIX_MasterBill_MasterBillOutputRestrictionId] ON [dbo].[MasterBill] ([MasterBillOutputRestrictionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NIX_MasterBill_MasterBillSystemControlId] ON [dbo].[MasterBill] ([MasterBillSystemControlId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterBill] ADD CONSTRAINT [FK_dbo.MasterBill_dbo.MasterBillStyle_MasterBillStyle] FOREIGN KEY ([MasterBillStyleId]) REFERENCES [dbo].[MasterBillStyle] ([MasterBillStyleId])
GO
ALTER TABLE [dbo].[MasterBill] ADD CONSTRAINT [FK_dbo.MasterBill_dbo.MasterBillType_MasterBillType] FOREIGN KEY ([MasterBillTypeId]) REFERENCES [dbo].[MasterBillType] ([MasterBillTypeId])
GO
ALTER TABLE [dbo].[MasterBill] ADD CONSTRAINT [FK_MasterBill_MasterBillOutputRestriction] FOREIGN KEY ([MasterBillOutputRestrictionId]) REFERENCES [dbo].[MasterBillOutputRestriction] ([MasterBillOutputRestrictionId])
GO
GRANT DELETE ON  [dbo].[MasterBill] TO [public]
GO
GRANT INSERT ON  [dbo].[MasterBill] TO [public]
GO
GRANT SELECT ON  [dbo].[MasterBill] TO [public]
GO
GRANT UPDATE ON  [dbo].[MasterBill] TO [public]
GO
