CREATE TABLE [dbo].[RtPenafiel]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[orden] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[segmento] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billto] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[estatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fechaTimbrado] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
