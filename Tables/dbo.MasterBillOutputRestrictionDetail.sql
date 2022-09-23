CREATE TABLE [dbo].[MasterBillOutputRestrictionDetail]
(
[MasterBillOutputRestrictionDetailId] [int] NOT NULL IDENTITY(1, 1),
[LabelDefinition] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MasterBil__Creat__007A9855] DEFAULT (suser_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__MasterBil__Creat__016EBC8E] DEFAULT (getdate()),
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__MasterBil__LastU__0262E0C7] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MasterBil__LastU__03570500] DEFAULT (suser_name()),
[MasterBillOutputRestrictionId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterBillOutputRestrictionDetail] ADD CONSTRAINT [PK_dbo.MasterBillOutputRestrictionDetail] PRIMARY KEY CLUSTERED ([MasterBillOutputRestrictionDetailId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MasterBillOutputRestrictionId] ON [dbo].[MasterBillOutputRestrictionDetail] ([MasterBillOutputRestrictionId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterBillOutputRestrictionDetail] ADD CONSTRAINT [FK_dbo.MasterBillOutputRestrictionDetail_dbo.MasterBillOutputRestriction_MasterBillOutputRestrictionId] FOREIGN KEY ([MasterBillOutputRestrictionId]) REFERENCES [dbo].[MasterBillOutputRestriction] ([MasterBillOutputRestrictionId])
GO
GRANT DELETE ON  [dbo].[MasterBillOutputRestrictionDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[MasterBillOutputRestrictionDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[MasterBillOutputRestrictionDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[MasterBillOutputRestrictionDetail] TO [public]
GO
