CREATE TABLE [dbo].[Calendario_DW]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Fecha] [date] NULL,
[dia] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mes] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[año] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[semana] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
