CREATE TABLE [dbo].[persistente_VISTA_Fe_detail]
(
[folio] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cantidad] [float] NULL,
[unidadmedida] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[unidadmedida33] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[claveunidad] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[numidentificacion] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consecutivo] [int] NULL,
[idconcepto] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[descripcion] [varchar] (101) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[valorunitario] [money] NULL,
[Importe] [money] NULL,
[tasa_iva] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tipo_imp] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[impuestoiva] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tipofactoriva] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[iva_monto] [money] NULL,
[importe_iva_inc] [money] NULL,
[tasa_ret] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Retencion] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[impuestoret] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tipofactorret] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ret_monto] [money] NOT NULL,
[importe_ret_inc] [money] NOT NULL
) ON [PRIMARY]
GO
