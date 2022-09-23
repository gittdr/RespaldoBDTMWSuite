CREATE TABLE [dbo].[movepassenger]
(
[psgr_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mov_number] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[movepassenger] ADD CONSTRAINT [pk_movepassenger] PRIMARY KEY CLUSTERED ([psgr_id], [mov_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[movepassenger] TO [public]
GO
GRANT INSERT ON  [dbo].[movepassenger] TO [public]
GO
GRANT REFERENCES ON  [dbo].[movepassenger] TO [public]
GO
GRANT SELECT ON  [dbo].[movepassenger] TO [public]
GO
GRANT UPDATE ON  [dbo].[movepassenger] TO [public]
GO
