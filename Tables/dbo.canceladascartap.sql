CREATE TABLE [dbo].[canceladascartap]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[Folio] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[motivo] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uuid] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[descripcion] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fecha] [datetime] NULL CONSTRAINT [DF__cancelada__fecha__086AF64F] DEFAULT (getdate())
) ON [PRIMARY]
GO
