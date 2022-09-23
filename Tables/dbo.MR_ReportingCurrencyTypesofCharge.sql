CREATE TABLE [dbo].[MR_ReportingCurrencyTypesofCharge]
(
[rtoc_fieldorreportname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rtoc_typeofcharge] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_ReportingCurrencyTypesofCharge] ADD CONSTRAINT [PK_MR_ReportingCurrencyFieldTypesofCharge] PRIMARY KEY CLUSTERED ([rtoc_fieldorreportname], [rtoc_typeofcharge]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_ReportingCurrencyTypesofCharge] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_ReportingCurrencyTypesofCharge] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_ReportingCurrencyTypesofCharge] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_ReportingCurrencyTypesofCharge] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_ReportingCurrencyTypesofCharge] TO [public]
GO
