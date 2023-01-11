CREATE TABLE [dbo].[NoInsertRegCp]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[uuid] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mensaje] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NoInsertRegCp] ADD CONSTRAINT [PK__NoInsert__6E4DA4BE7BAC00D6] PRIMARY KEY CLUSTERED ([id_num]) ON [PRIMARY]
GO
