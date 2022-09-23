CREATE TABLE [dbo].[Vale_diesel_horas]
(
[no_vale] [int] NOT NULL,
[id_operador] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[no_orden] [int] NULL,
[no_movimiento] [int] NULL,
[id_unidad] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id_remolque] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[horas] [decimal] (5, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Vale_diesel_horas] ADD CONSTRAINT [PK__Vale_diesel_hora__56B242A4] PRIMARY KEY CLUSTERED ([no_vale]) ON [PRIMARY]
GO
