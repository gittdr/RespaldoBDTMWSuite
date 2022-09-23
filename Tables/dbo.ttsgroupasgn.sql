CREATE TABLE [dbo].[ttsgroupasgn]
(
[grp_id] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[usr_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [k_grpiduserid] ON [dbo].[ttsgroupasgn] ([grp_id], [usr_userid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [k_userid] ON [dbo].[ttsgroupasgn] ([usr_userid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ttsgroupasgn] TO [public]
GO
GRANT INSERT ON  [dbo].[ttsgroupasgn] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ttsgroupasgn] TO [public]
GO
GRANT SELECT ON  [dbo].[ttsgroupasgn] TO [public]
GO
GRANT UPDATE ON  [dbo].[ttsgroupasgn] TO [public]
GO
