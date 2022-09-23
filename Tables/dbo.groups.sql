CREATE TABLE [dbo].[groups]
(
[grp_group] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[usr_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_grp_group] ON [dbo].[groups] ([grp_group], [usr_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_usr_id] ON [dbo].[groups] ([usr_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[groups] TO [public]
GO
GRANT INSERT ON  [dbo].[groups] TO [public]
GO
GRANT REFERENCES ON  [dbo].[groups] TO [public]
GO
GRANT SELECT ON  [dbo].[groups] TO [public]
GO
GRANT UPDATE ON  [dbo].[groups] TO [public]
GO
