CREATE TABLE [dbo].[tmw2001_upgrade]
(
[mov_number] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [tmw2001_upgrade_mov] ON [dbo].[tmw2001_upgrade] ([mov_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tmw2001_upgrade] TO [public]
GO
GRANT INSERT ON  [dbo].[tmw2001_upgrade] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tmw2001_upgrade] TO [public]
GO
GRANT SELECT ON  [dbo].[tmw2001_upgrade] TO [public]
GO
GRANT UPDATE ON  [dbo].[tmw2001_upgrade] TO [public]
GO
