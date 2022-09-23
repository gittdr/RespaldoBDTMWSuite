CREATE TABLE [dbo].[m2reqqueue]
(
[m2qid] [int] NOT NULL,
[m2qstat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_m2qid] ON [dbo].[m2reqqueue] ([m2qid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[m2reqqueue] TO [public]
GO
GRANT INSERT ON  [dbo].[m2reqqueue] TO [public]
GO
GRANT REFERENCES ON  [dbo].[m2reqqueue] TO [public]
GO
GRANT SELECT ON  [dbo].[m2reqqueue] TO [public]
GO
GRANT UPDATE ON  [dbo].[m2reqqueue] TO [public]
GO
