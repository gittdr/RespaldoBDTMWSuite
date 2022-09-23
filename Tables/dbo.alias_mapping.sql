CREATE TABLE [dbo].[alias_mapping]
(
[usr_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[usr_userid_alias] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[alias_mapping] ADD CONSTRAINT [alias_mapping_pk] PRIMARY KEY CLUSTERED ([usr_userid], [usr_userid_alias]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[alias_mapping] TO [public]
GO
GRANT INSERT ON  [dbo].[alias_mapping] TO [public]
GO
GRANT SELECT ON  [dbo].[alias_mapping] TO [public]
GO
GRANT UPDATE ON  [dbo].[alias_mapping] TO [public]
GO
