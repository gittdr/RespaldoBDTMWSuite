CREATE TABLE [dbo].[vTTSTMW_detail]
(
[ivh_invoicenumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ivd_quantity] [float] NOT NULL,
[ivd_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[descripcion] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ivd_rate] [decimal] (19, 4) NOT NULL,
[ivd_charge] [decimal] (19, 4) NOT NULL,
[tasa_iva] [decimal] (19, 4) NULL,
[tipo_imp] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iva_monto] [decimal] (19, 4) NULL,
[importe_iva_inc] [decimal] (19, 4) NULL,
[tasa_ret] [decimal] (19, 4) NULL,
[Retencion] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ret_monto] [decimal] (19, 4) NULL,
[importe_ret_inc] [decimal] (19, 4) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[vTTSTMW_detail] ADD CONSTRAINT [PK_vTTSTMW_detail] PRIMARY KEY CLUSTERED ([ivh_invoicenumber], [descripcion], [ivd_rate]) ON [PRIMARY]
GO
