CREATE TABLE [dbo].[Tabla_paso_cargadiesel_jr]
(
[id_consecutivo] [int] NOT NULL IDENTITY(1, 1),
[id_unidad] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fecha] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tipo_mov] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[importe] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Tabla_paso_cargadiesel_jr] ADD CONSTRAINT [PK__Tabla_paso_carga__2D624D65] PRIMARY KEY CLUSTERED ([id_consecutivo]) ON [PRIMARY]
GO
