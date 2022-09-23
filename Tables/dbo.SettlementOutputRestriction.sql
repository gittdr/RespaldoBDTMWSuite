CREATE TABLE [dbo].[SettlementOutputRestriction]
(
[SettlementOutputRestrictionId] [int] NOT NULL IDENTITY(1, 1),
[CreatedBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Settlemen__Creat__7CED2BEF] DEFAULT (suser_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__Settlemen__Creat__7DE15028] DEFAULT (getdate()),
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__Settlemen__LastU__7ED57461] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Settlemen__LastU__7FC9989A] DEFAULT (suser_name()),
[SystemReportId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SettlementOutputRestriction] ADD CONSTRAINT [PK_dbo.SettlementOutputRestriction] PRIMARY KEY CLUSTERED ([SettlementOutputRestrictionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SystemReportId] ON [dbo].[SettlementOutputRestriction] ([SystemReportId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SettlementOutputRestriction] ADD CONSTRAINT [FK_dbo.SettlementOutputRestriction_dbo.SystemReport_SystemReportId] FOREIGN KEY ([SystemReportId]) REFERENCES [dbo].[SystemReport] ([SystemReportId])
GO
GRANT DELETE ON  [dbo].[SettlementOutputRestriction] TO [public]
GO
GRANT INSERT ON  [dbo].[SettlementOutputRestriction] TO [public]
GO
GRANT SELECT ON  [dbo].[SettlementOutputRestriction] TO [public]
GO
GRANT UPDATE ON  [dbo].[SettlementOutputRestriction] TO [public]
GO
