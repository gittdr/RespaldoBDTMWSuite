CREATE TABLE [dbo].[InsertCp]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[folio] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InsertCp] ADD CONSTRAINT [PK__InsertCp__6E4DA4BEDE6EC717] PRIMARY KEY CLUSTERED ([id_num]) ON [PRIMARY]
GO
