CREATE TABLE [dbo].[conversation_manager]
(
[cm_id] [int] NOT NULL IDENTITY(1, 1),
[cm_table] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cm_tablekey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cm_withtable] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cm_withtablekey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cm_createdon] [datetime] NOT NULL,
[cm_createdby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cm_comment] [varchar] (7700) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[conversation_manager] ADD CONSTRAINT [PK_conversation_manager] PRIMARY KEY NONCLUSTERED ([cm_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[conversation_manager] TO [public]
GO
GRANT INSERT ON  [dbo].[conversation_manager] TO [public]
GO
GRANT REFERENCES ON  [dbo].[conversation_manager] TO [public]
GO
GRANT SELECT ON  [dbo].[conversation_manager] TO [public]
GO
GRANT UPDATE ON  [dbo].[conversation_manager] TO [public]
GO
