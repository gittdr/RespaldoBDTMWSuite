CREATE TABLE [dbo].[fuelticketelect]
(
[numtarjeta] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tractor] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Litros] [decimal] (6, 2) NULL,
[Costo] [decimal] (10, 4) NULL,
[Movimiento] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[numvale] [int] NULL,
[creadopor] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fechacreacion] [datetime] NULL,
[operador] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orden] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tipo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fechainsersion] [datetime] NULL,
[conciliado] [int] NULL,
[fuente] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
