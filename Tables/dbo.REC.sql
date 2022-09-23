CREATE TABLE [dbo].[REC]
(
[Field] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[REC] TO [public]
GO
GRANT INSERT ON  [dbo].[REC] TO [public]
GO
GRANT REFERENCES ON  [dbo].[REC] TO [public]
GO
GRANT SELECT ON  [dbo].[REC] TO [public]
GO
GRANT UPDATE ON  [dbo].[REC] TO [public]
GO
