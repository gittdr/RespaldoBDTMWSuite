CREATE TABLE [dbo].[gmap_rutainstruccion]
(
[idrutapaso] [int] NOT NULL IDENTITY(1, 1),
[cmporigen] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmpdestino] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ciudadnmsctorigen] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ciudadnmsctdestino] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tipo] [nchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[link_img] [nchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[texto] [nchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[distancia] [float] NULL,
[tiempo] [decimal] (6, 2) NULL,
[tiempoparado] [decimal] (6, 2) NULL,
[costo] [money] NULL,
[longitud] [float] NULL,
[latitud] [float] NULL
) ON [PRIMARY]
GO
