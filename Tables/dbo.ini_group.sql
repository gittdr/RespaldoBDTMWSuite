CREATE TABLE [dbo].[ini_group]
(
[group_id] [int] NOT NULL,
[group_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created] [datetime] NOT NULL,
[created_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[updated] [datetime] NOT NULL,
[updated_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ini_group] ADD CONSTRAINT [ini_group_pk] PRIMARY KEY CLUSTERED ([group_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ini_group] TO [public]
GO
GRANT INSERT ON  [dbo].[ini_group] TO [public]
GO
GRANT SELECT ON  [dbo].[ini_group] TO [public]
GO
GRANT UPDATE ON  [dbo].[ini_group] TO [public]
GO
