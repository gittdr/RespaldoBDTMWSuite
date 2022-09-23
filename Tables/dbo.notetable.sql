CREATE TABLE [dbo].[notetable]
(
[ntb_table] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ntb_englishname] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ntb_keyfields] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_ntb_table] ON [dbo].[notetable] ([ntb_table]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[notetable] TO [public]
GO
GRANT INSERT ON  [dbo].[notetable] TO [public]
GO
GRANT REFERENCES ON  [dbo].[notetable] TO [public]
GO
GRANT SELECT ON  [dbo].[notetable] TO [public]
GO
GRANT UPDATE ON  [dbo].[notetable] TO [public]
GO
