CREATE TABLE [dbo].[Costo_casetas_pilgrims]
(
[id_renglon] [int] NOT NULL IDENTITY(1, 1),
[comp_origen] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[comp_destino] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[no_ejes] [int] NOT NULL,
[monto_efectivo] [decimal] (8, 2) NULL,
[monto_iave] [decimal] (8, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Costo_casetas_pilgrims] ADD CONSTRAINT [PK__Costo_ca__B8322DB7569D87F5] PRIMARY KEY CLUSTERED ([comp_origen], [comp_destino], [no_ejes]) ON [PRIMARY]
GO
