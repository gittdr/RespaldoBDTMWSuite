CREATE TABLE [dbo].[IndicadoresTDR_DW]
(
[Id_IndicadorTDR] [int] NOT NULL IDENTITY(1, 1),
[Indicador] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fecha] [date] NULL,
[Proyecto] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Valor] [decimal] (20, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IndicadoresTDR_DW] ADD CONSTRAINT [PK_IndicadoresTDR_DW] PRIMARY KEY CLUSTERED ([Id_IndicadorTDR]) ON [PRIMARY]
GO
