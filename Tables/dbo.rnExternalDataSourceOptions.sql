CREATE TABLE [dbo].[rnExternalDataSourceOptions]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[ExternalDataSourceSN] [int] NULL,
[OptionName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptionValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rnExternalDataSourceOptions] ADD CONSTRAINT [AutoPK_rnExternalDataSourceOptions_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rnExternalDataSourceOptions] TO [public]
GO
GRANT INSERT ON  [dbo].[rnExternalDataSourceOptions] TO [public]
GO
GRANT SELECT ON  [dbo].[rnExternalDataSourceOptions] TO [public]
GO
GRANT UPDATE ON  [dbo].[rnExternalDataSourceOptions] TO [public]
GO
