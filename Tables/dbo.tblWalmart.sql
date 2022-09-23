CREATE TABLE [dbo].[tblWalmart]
(
[contador] [int] NULL,
[Fecha] [datetime] NULL,
[referencia] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Factura] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orden] [int] NULL,
[SubTotal] [int] NULL,
[Total] [int] NULL
) ON [PRIMARY]
GO
