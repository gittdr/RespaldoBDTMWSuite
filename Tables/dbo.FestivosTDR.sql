CREATE TABLE [dbo].[FestivosTDR]
(
[IdFestivoTDR] [int] NOT NULL IDENTITY(1, 1),
[FechaFestivo] [date] NULL,
[Celebracion] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
