CREATE TABLE [dbo].[RESPALDO_Carta_Porte]
(
[Folio] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Serie] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UUID] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pdf_xml_descarga] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pdf_descargaFactura] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[xml_descargaFactura] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cancelFactura] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LegNum] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fecha] [datetime] NULL,
[Total] [money] NULL,
[Moneda] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RFC] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Origen] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Destino] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
