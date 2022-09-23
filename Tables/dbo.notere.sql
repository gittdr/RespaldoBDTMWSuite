CREATE TABLE [dbo].[notere]
(
[not_number] [int] NOT NULL,
[ntb_table] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nre_tablekey] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_not_number] ON [dbo].[notere] ([not_number]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_ntb_table] ON [dbo].[notere] ([ntb_table], [nre_tablekey], [not_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[notere] TO [public]
GO
GRANT INSERT ON  [dbo].[notere] TO [public]
GO
GRANT REFERENCES ON  [dbo].[notere] TO [public]
GO
GRANT SELECT ON  [dbo].[notere] TO [public]
GO
GRANT UPDATE ON  [dbo].[notere] TO [public]
GO
