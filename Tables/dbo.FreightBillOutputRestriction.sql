CREATE TABLE [dbo].[FreightBillOutputRestriction]
(
[FreightBillOutputRestrictionId] [int] NOT NULL IDENTITY(1, 1),
[CreatedBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__FreightBi__Creat__699732FD] DEFAULT (suser_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__FreightBi__Creat__6A8B5736] DEFAULT (getdate()),
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__FreightBi__LastU__6B7F7B6F] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__FreightBi__LastU__6C739FA8] DEFAULT (suser_name()),
[SystemReportId] [int] NOT NULL,
[ivs_number] [int] NOT NULL,
[BillDateTypeId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightBillOutputRestriction] ADD CONSTRAINT [PK_dbo.FreightBillOutputRestriction] PRIMARY KEY CLUSTERED ([FreightBillOutputRestrictionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ivs_number] ON [dbo].[FreightBillOutputRestriction] ([ivs_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SystemReportId] ON [dbo].[FreightBillOutputRestriction] ([SystemReportId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightBillOutputRestriction] ADD CONSTRAINT [FK_dbo.FreightBillOutputRestriction_dbo.DatePropertyType_BillDateType] FOREIGN KEY ([BillDateTypeId]) REFERENCES [dbo].[DatePropertyType] ([DatePropertyTypeId])
GO
ALTER TABLE [dbo].[FreightBillOutputRestriction] ADD CONSTRAINT [FK_dbo.FreightBillOutputRestriction_dbo.InvoiceSelection_ivs_number] FOREIGN KEY ([ivs_number]) REFERENCES [dbo].[invoiceselection] ([ivs_number])
GO
ALTER TABLE [dbo].[FreightBillOutputRestriction] ADD CONSTRAINT [FK_dbo.FreightBillOutputRestriction_dbo.SystemReport_SystemReportId] FOREIGN KEY ([SystemReportId]) REFERENCES [dbo].[SystemReport] ([SystemReportId])
GO
GRANT DELETE ON  [dbo].[FreightBillOutputRestriction] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightBillOutputRestriction] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightBillOutputRestriction] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightBillOutputRestriction] TO [public]
GO
