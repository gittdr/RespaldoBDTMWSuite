CREATE TABLE [dbo].[ResNow_TripletsLastRefresh]
(
[DateLastRefresh] [datetime] NULL,
[ResNow_TripletsLastRefresh_ident] [int] NOT NULL IDENTITY(1, 1),
[rn_timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNow_TripletsLastRefresh] ADD CONSTRAINT [prkey_ResNow_TripletsLastRefresh] PRIMARY KEY CLUSTERED ([ResNow_TripletsLastRefresh_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNow_TripletsLastRefresh] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNow_TripletsLastRefresh] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNow_TripletsLastRefresh] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNow_TripletsLastRefresh] TO [public]
GO
