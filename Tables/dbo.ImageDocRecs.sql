CREATE TABLE [dbo].[ImageDocRecs]
(
[idr_ID] [int] NOT NULL IDENTITY(1, 1),
[image] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImageDocRecs] ADD CONSTRAINT [PK__ImageDocRecs__6B7B86EB] PRIMARY KEY CLUSTERED ([idr_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ImageDocRecs] TO [public]
GO
GRANT INSERT ON  [dbo].[ImageDocRecs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ImageDocRecs] TO [public]
GO
GRANT SELECT ON  [dbo].[ImageDocRecs] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImageDocRecs] TO [public]
GO
