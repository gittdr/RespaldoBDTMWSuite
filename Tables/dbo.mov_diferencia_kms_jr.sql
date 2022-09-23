CREATE TABLE [dbo].[mov_diferencia_kms_jr]
(
[billto] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[movimiento] [int] NOT NULL,
[kms_viaje] [int] NULL,
[kms_diesel] [int] NULL,
[diferencia_kms] [int] NULL
) ON [PRIMARY]
GO
