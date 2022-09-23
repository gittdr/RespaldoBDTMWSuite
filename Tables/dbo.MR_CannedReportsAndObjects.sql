CREATE TABLE [dbo].[MR_CannedReportsAndObjects]
(
[rao_reportname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rao_object] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rao_objectype] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rao_source] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_CannedReportsAndObjects] ADD CONSTRAINT [PK_MR_CannedReportsAndObjects] PRIMARY KEY CLUSTERED ([rao_reportname], [rao_object], [rao_objectype]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_CannedReportsAndObjects] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_CannedReportsAndObjects] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_CannedReportsAndObjects] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_CannedReportsAndObjects] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_CannedReportsAndObjects] TO [public]
GO
