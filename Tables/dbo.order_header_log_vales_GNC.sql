CREATE TABLE [dbo].[order_header_log_vales_GNC]
(
[orden_log] [int] NOT NULL,
[movimiento_log] [int] NOT NULL,
[proyecto_log] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[peso_log] [int] NULL,
[kms_log] [int] NULL,
[litros_log] [int] NULL,
[operador_log] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unidad_log] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rendimiento_log] [float] NULL,
[ruta_log] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fecha_log] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[order_header_log_vales_GNC] ADD CONSTRAINT [PK__order_he__0A466D227D8C86D6] PRIMARY KEY CLUSTERED ([orden_log], [movimiento_log]) ON [PRIMARY]
GO
