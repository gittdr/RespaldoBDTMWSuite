CREATE TABLE [dbo].[CompanyImagingHandling]
(
[CihId] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InvoiceType] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HandlingInstruction] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime2] (3) NULL,
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyImagingHandling] ADD CONSTRAINT [pk_CompanyImagingHandling_CihId] PRIMARY KEY CLUSTERED ([CihId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_CompanyImagingHandling_cmp_id] ON [dbo].[CompanyImagingHandling] ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CompanyImagingHandling] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyImagingHandling] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CompanyImagingHandling] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyImagingHandling] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyImagingHandling] TO [public]
GO
