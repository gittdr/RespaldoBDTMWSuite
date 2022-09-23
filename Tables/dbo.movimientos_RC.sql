CREATE TABLE [dbo].[movimientos_RC]
(
[idmov_rc] [int] NOT NULL IDENTITY(1, 1),
[apellido_paterno] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[apellido_materno] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nombre_operador] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RFC_operador] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tipo_mov] [char] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fecha_mov] [datetime] NULL,
[cliente_mov] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[movimientos_RC] ADD CONSTRAINT [PK__movimientos_RC__26860B06] PRIMARY KEY CLUSTERED ([idmov_rc]) ON [PRIMARY]
GO
