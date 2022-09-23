CREATE TABLE [dbo].[GroupLayoutPriority]
(
[groupid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[priority] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GroupLayoutPriority] ADD CONSTRAINT [PK_GroupLayoutPriorty] PRIMARY KEY CLUSTERED ([groupid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GroupLayoutPriority] TO [public]
GO
GRANT INSERT ON  [dbo].[GroupLayoutPriority] TO [public]
GO
GRANT REFERENCES ON  [dbo].[GroupLayoutPriority] TO [public]
GO
GRANT SELECT ON  [dbo].[GroupLayoutPriority] TO [public]
GO
GRANT UPDATE ON  [dbo].[GroupLayoutPriority] TO [public]
GO
