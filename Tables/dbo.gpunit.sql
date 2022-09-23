CREATE TABLE [dbo].[gpunit]
(
[company] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[account] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usertype] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__gpunit__usertype__5EA3DC16] DEFAULT ('COMPANY'),
[uservalue] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__gpunit__uservalu__5F98004F] DEFAULT ('UNK')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[gpunit] ADD CONSTRAINT [ck_gptype] CHECK ((NOT [type]=NULL AND NOT [type]='' AND NOT [type]='UNK'))
GO
ALTER TABLE [dbo].[gpunit] ADD CONSTRAINT [pk_gpunit] PRIMARY KEY CLUSTERED ([company], [type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[gpunit] TO [public]
GO
GRANT INSERT ON  [dbo].[gpunit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[gpunit] TO [public]
GO
GRANT SELECT ON  [dbo].[gpunit] TO [public]
GO
GRANT UPDATE ON  [dbo].[gpunit] TO [public]
GO
