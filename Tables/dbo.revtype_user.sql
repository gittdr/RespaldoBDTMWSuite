CREATE TABLE [dbo].[revtype_user]
(
[rev_labeldefinitions] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rev_abbr] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[usr_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_update] [datetime] NULL,
[last_updateby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_by] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[revtype_user] ADD CONSTRAINT [PK_revtype_user] PRIMARY KEY CLUSTERED ([rev_labeldefinitions], [rev_abbr], [usr_userid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[revtype_user] TO [public]
GO
GRANT INSERT ON  [dbo].[revtype_user] TO [public]
GO
GRANT REFERENCES ON  [dbo].[revtype_user] TO [public]
GO
GRANT SELECT ON  [dbo].[revtype_user] TO [public]
GO
GRANT UPDATE ON  [dbo].[revtype_user] TO [public]
GO
