CREATE TABLE [dbo].[can_alliance]
(
[all_allianceid] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[all_alliancename] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[all_alliancecomments] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[can_alliance] ADD CONSTRAINT [pk_can_alliance] PRIMARY KEY NONCLUSTERED ([all_allianceid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[can_alliance] TO [public]
GO
GRANT INSERT ON  [dbo].[can_alliance] TO [public]
GO
GRANT REFERENCES ON  [dbo].[can_alliance] TO [public]
GO
GRANT SELECT ON  [dbo].[can_alliance] TO [public]
GO
GRANT UPDATE ON  [dbo].[can_alliance] TO [public]
GO
