CREATE TABLE [dbo].[DedicatedBillOutputRestriction]
(
[DedicatedBillOutputRestrictionId] [int] NOT NULL IDENTITY(1, 1),
[SystemReportId] [int] NOT NULL,
[InvoiceSelectionId] [int] NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_DedicatedBillOutputRestriction_CreatedDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DedicatedBillOutputRestriction_CreatedBy] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NOT NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedBillOutputRestriction] ADD CONSTRAINT [PK_DedicatedBillOutputRestriction] PRIMARY KEY CLUSTERED ([DedicatedBillOutputRestrictionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DedicatedBillOutputRestriction_InvoiceSelectionId] ON [dbo].[DedicatedBillOutputRestriction] ([InvoiceSelectionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DedicatedBillOutputRestriction_SystemReportId] ON [dbo].[DedicatedBillOutputRestriction] ([SystemReportId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedBillOutputRestriction] ADD CONSTRAINT [FK_DedicatedBillOutputRestriction_InvoiceSelection_ivs_number] FOREIGN KEY ([InvoiceSelectionId]) REFERENCES [dbo].[invoiceselection] ([ivs_number])
GO
ALTER TABLE [dbo].[DedicatedBillOutputRestriction] ADD CONSTRAINT [FK_DedicatedBillOutputRestriction_SystemReport_SystemReportId] FOREIGN KEY ([SystemReportId]) REFERENCES [dbo].[SystemReport] ([SystemReportId])
GO
GRANT DELETE ON  [dbo].[DedicatedBillOutputRestriction] TO [public]
GO
GRANT INSERT ON  [dbo].[DedicatedBillOutputRestriction] TO [public]
GO
GRANT SELECT ON  [dbo].[DedicatedBillOutputRestriction] TO [public]
GO
GRANT UPDATE ON  [dbo].[DedicatedBillOutputRestriction] TO [public]
GO
