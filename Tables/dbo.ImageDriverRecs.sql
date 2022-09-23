CREATE TABLE [dbo].[ImageDriverRecs]
(
[idr_ID] [int] NOT NULL IDENTITY(1, 1),
[image] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImageDriverRecs] ADD CONSTRAINT [PK__ImageDriverRecs__6F4C17CF] PRIMARY KEY CLUSTERED ([idr_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ImageDriverRecs] TO [public]
GO
GRANT INSERT ON  [dbo].[ImageDriverRecs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ImageDriverRecs] TO [public]
GO
GRANT SELECT ON  [dbo].[ImageDriverRecs] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImageDriverRecs] TO [public]
GO
