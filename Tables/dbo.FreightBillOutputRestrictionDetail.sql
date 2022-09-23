CREATE TABLE [dbo].[FreightBillOutputRestrictionDetail]
(
[FreightBillOutputRestrictionDetailId] [int] NOT NULL IDENTITY(1, 1),
[LabelDefinition] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__FreightBi__Creat__7508E5A9] DEFAULT (suser_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__FreightBi__Creat__75FD09E2] DEFAULT (getdate()),
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__FreightBi__LastU__76F12E1B] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__FreightBi__LastU__77E55254] DEFAULT (suser_name()),
[FreightBillOutputRestrictionId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightBillOutputRestrictionDetail] ADD CONSTRAINT [PK_dbo.FreightBillOutputRestrictionDetail] PRIMARY KEY CLUSTERED ([FreightBillOutputRestrictionDetailId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FreightBillOutputRestrictionId] ON [dbo].[FreightBillOutputRestrictionDetail] ([FreightBillOutputRestrictionId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightBillOutputRestrictionDetail] ADD CONSTRAINT [FK_dbo.FreightBillOutputRestrictionDetail_dbo.FreightBillOutputRestriction_FreightBillOutputRestrictionId] FOREIGN KEY ([FreightBillOutputRestrictionId]) REFERENCES [dbo].[FreightBillOutputRestriction] ([FreightBillOutputRestrictionId])
GO
GRANT DELETE ON  [dbo].[FreightBillOutputRestrictionDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightBillOutputRestrictionDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightBillOutputRestrictionDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightBillOutputRestrictionDetail] TO [public]
GO
