CREATE TABLE [dbo].[convoy360_ViajesClienteAPI]
(
[ord_hdrnumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fechaCompletado] [datetime] NULL,
[completado] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evidencias] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wsRefnum] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_refnum] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
