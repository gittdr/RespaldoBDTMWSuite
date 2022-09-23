CREATE TABLE [dbo].[ident_block]
(
[id] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create trigger [dbo].[uidt_ident_block] on [dbo].[ident_block] for insert,update,delete as
   RAISERROR ('This table must not be changed and is used for getsystemnumberblock.', 16, 1)
   ROLLBACK TRANSACTION
GO
ALTER TABLE [dbo].[ident_block] ADD CONSTRAINT [PK_ident_block_id] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ident_block] TO [public]
GO
GRANT INSERT ON  [dbo].[ident_block] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ident_block] TO [public]
GO
GRANT SELECT ON  [dbo].[ident_block] TO [public]
GO
GRANT UPDATE ON  [dbo].[ident_block] TO [public]
GO
