CREATE TABLE [dbo].[ImageOrderRecs]
(
[ior_ID] [int] NOT NULL IDENTITY(1, 1),
[image] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImageOrderRecs] ADD CONSTRAINT [PK__ImageOrderRecs__66049EF9] PRIMARY KEY CLUSTERED ([ior_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ImageOrderRecs] TO [public]
GO
GRANT INSERT ON  [dbo].[ImageOrderRecs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ImageOrderRecs] TO [public]
GO
GRANT SELECT ON  [dbo].[ImageOrderRecs] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImageOrderRecs] TO [public]
GO
