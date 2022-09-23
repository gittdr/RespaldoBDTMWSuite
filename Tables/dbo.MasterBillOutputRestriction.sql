CREATE TABLE [dbo].[MasterBillOutputRestriction]
(
[MasterBillOutputRestrictionId] [int] NOT NULL IDENTITY(1, 1),
[CreatedBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MasterBil__Creat__63DE59A7] DEFAULT (suser_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__MasterBil__Creat__64D27DE0] DEFAULT (getdate()),
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__MasterBil__LastU__65C6A219] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MasterBil__LastU__66BAC652] DEFAULT (suser_name()),
[ScheduleId] [int] NOT NULL,
[SystemReportId] [int] NOT NULL,
[ivs_number] [int] NOT NULL,
[CutoffDateTypeId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterBillOutputRestriction] ADD CONSTRAINT [PK_dbo.MasterBillOutputRestriction] PRIMARY KEY CLUSTERED ([MasterBillOutputRestrictionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ivs_number] ON [dbo].[MasterBillOutputRestriction] ([ivs_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ScheduleId] ON [dbo].[MasterBillOutputRestriction] ([ScheduleId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SystemReportId] ON [dbo].[MasterBillOutputRestriction] ([SystemReportId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterBillOutputRestriction] ADD CONSTRAINT [FK_dbo.MasterBillOutputRestriction_dbo.DatePropertyType_CutoffDateType] FOREIGN KEY ([CutoffDateTypeId]) REFERENCES [dbo].[DatePropertyType] ([DatePropertyTypeId])
GO
ALTER TABLE [dbo].[MasterBillOutputRestriction] ADD CONSTRAINT [FK_dbo.MasterBillOutputRestriction_dbo.InvoiceSelection_ivs_number] FOREIGN KEY ([ivs_number]) REFERENCES [dbo].[invoiceselection] ([ivs_number])
GO
ALTER TABLE [dbo].[MasterBillOutputRestriction] ADD CONSTRAINT [FK_dbo.MasterBillOutputRestriction_dbo.Schedule_ScheduleId] FOREIGN KEY ([ScheduleId]) REFERENCES [dbo].[Schedules] ([ScheduleId])
GO
ALTER TABLE [dbo].[MasterBillOutputRestriction] ADD CONSTRAINT [FK_dbo.MasterBillOutputRestriction_dbo.SystemReport_SystemReportId] FOREIGN KEY ([SystemReportId]) REFERENCES [dbo].[SystemReport] ([SystemReportId])
GO
GRANT DELETE ON  [dbo].[MasterBillOutputRestriction] TO [public]
GO
GRANT INSERT ON  [dbo].[MasterBillOutputRestriction] TO [public]
GO
GRANT SELECT ON  [dbo].[MasterBillOutputRestriction] TO [public]
GO
GRANT UPDATE ON  [dbo].[MasterBillOutputRestriction] TO [public]
GO
