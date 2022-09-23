CREATE TABLE [dbo].[rnExternalDataSource]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[Available_YN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Caption] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaptionFull] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSourceType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServerName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConnectionStringOverride] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rnExternalDataSource] ADD CONSTRAINT [AutoPK_rnExternalDataSource_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rnExternalDataSource] TO [public]
GO
GRANT INSERT ON  [dbo].[rnExternalDataSource] TO [public]
GO
GRANT SELECT ON  [dbo].[rnExternalDataSource] TO [public]
GO
GRANT UPDATE ON  [dbo].[rnExternalDataSource] TO [public]
GO
