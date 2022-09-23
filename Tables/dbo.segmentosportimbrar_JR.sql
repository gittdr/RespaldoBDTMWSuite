CREATE TABLE [dbo].[segmentosportimbrar_JR]
(
[consecutivo] [int] NOT NULL IDENTITY(1, 1),
[billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[segmento] [int] NULL,
[estatus] [int] NULL,
[observaciones] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fecha] [datetime] NULL
) ON [PRIMARY]
GO
