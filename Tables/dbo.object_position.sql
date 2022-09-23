CREATE TABLE [dbo].[object_position]
(
[obp_id] [int] NOT NULL IDENTITY(1, 1),
[obp_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[obp_parentname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[obp_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[obp_x] [int] NULL,
[obp_y] [int] NULL,
[obp_width] [int] NULL,
[obp_height] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[object_position] ADD CONSTRAINT [pk_object_position] PRIMARY KEY NONCLUSTERED ([obp_id]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [uk_object_position_name] ON [dbo].[object_position] ([obp_name], [obp_parentname], [obp_user]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[object_position] TO [public]
GO
GRANT INSERT ON  [dbo].[object_position] TO [public]
GO
GRANT REFERENCES ON  [dbo].[object_position] TO [public]
GO
GRANT SELECT ON  [dbo].[object_position] TO [public]
GO
GRANT UPDATE ON  [dbo].[object_position] TO [public]
GO
