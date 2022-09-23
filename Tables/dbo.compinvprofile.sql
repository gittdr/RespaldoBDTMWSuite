CREATE TABLE [dbo].[compinvprofile]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_lastsiteplandate] [datetime] NULL,
[cmp_recommordersize] [int] NULL,
[cmp_group_nbr] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[compinvprofile] ADD CONSTRAINT [pk_compinvprofile] PRIMARY KEY CLUSTERED ([cmp_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[compinvprofile] ADD CONSTRAINT [fk_compinvprofile] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[company] ([cmp_id])
GO
GRANT DELETE ON  [dbo].[compinvprofile] TO [public]
GO
GRANT INSERT ON  [dbo].[compinvprofile] TO [public]
GO
GRANT REFERENCES ON  [dbo].[compinvprofile] TO [public]
GO
GRANT SELECT ON  [dbo].[compinvprofile] TO [public]
GO
GRANT UPDATE ON  [dbo].[compinvprofile] TO [public]
GO
