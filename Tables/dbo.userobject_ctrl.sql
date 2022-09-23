CREATE TABLE [dbo].[userobject_ctrl]
(
[id] [int] NOT NULL,
[control] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[x] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[y] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[width] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[height] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[visible] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[enable] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userobject_ctrl] ADD CONSTRAINT [pk_userobject_ctrl] PRIMARY KEY CLUSTERED ([id], [control]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userobject_ctrl] ADD CONSTRAINT [fk_userobject_ctrl] FOREIGN KEY ([id]) REFERENCES [dbo].[userobject] ([id])
GO
GRANT DELETE ON  [dbo].[userobject_ctrl] TO [public]
GO
GRANT INSERT ON  [dbo].[userobject_ctrl] TO [public]
GO
GRANT REFERENCES ON  [dbo].[userobject_ctrl] TO [public]
GO
GRANT SELECT ON  [dbo].[userobject_ctrl] TO [public]
GO
GRANT UPDATE ON  [dbo].[userobject_ctrl] TO [public]
GO
