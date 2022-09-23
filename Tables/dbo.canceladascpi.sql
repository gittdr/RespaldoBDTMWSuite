CREATE TABLE [dbo].[canceladascpi]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[motivo] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uuid] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[descripcion] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fecha] [datetime] NULL CONSTRAINT [DF__cancelada__fecha__058E89A4] DEFAULT (getdate())
) ON [PRIMARY]
GO
