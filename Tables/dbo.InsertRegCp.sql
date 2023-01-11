CREATE TABLE [dbo].[InsertRegCp]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[folio] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uuid] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[segmento] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serie] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rorder] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aplica] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billto] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[totalinvoice] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[totalvcartaporte] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[estatus] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InsertRegCp] ADD CONSTRAINT [PK__InsertRe__6E4DA4BEE73A34E3] PRIMARY KEY CLUSTERED ([id_num]) ON [PRIMARY]
GO
