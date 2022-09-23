CREATE TABLE [dbo].[vTTSTMW_Header]
(
[ivh_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ivh_shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ivh_consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[serie] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_user_id2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_invoicenumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ivh_billdate] [datetime] NOT NULL,
[ord_number] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mov_number] [int] NOT NULL,
[ivh_remark] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_ref_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_terms] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[firstname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[licensenumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tractor_licnum] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer_licnum] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[comprobante] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_descripcion] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_totalcharge] [decimal] (19, 4) NOT NULL,
[ivh_taxamount1] [decimal] (19, 4) NOT NULL,
[ivh_taxamount2] [decimal] (19, 4) NULL,
[ivh_creditmemo] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ciudad_origen] [varchar] (28) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ciudad_destino] [varchar] (28) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[moneda] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[masterbill] [int] NOT NULL,
[peso_estimado] [float] NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rfc] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[calle] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ext] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[interior] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[colonia] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[municipio] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ciudad] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[estado] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pais] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_address] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_phone1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rfc_origen] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[calle_origen] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ext_origen] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[interior_origen] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[colonia_origen] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[municipio_origen] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cd_origen] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edo_origen] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pais_origen] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip_origen] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[name_origen] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_address_origen] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_phone1_origen] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[revtype1_origen] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_name_origen] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rfc_destino] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[calle_destino] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ext_destino] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[interior_destino] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[colonia_destino] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[municipio_destino] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cd_destino] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edo_destino] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pais_destino] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip_destino] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[name_destino] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_address_destino] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_phone1_destino] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[revtype1_destino] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_name_destino] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[referencia_factura] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fecha_wfactura] [datetime] NULL,
[archivo_tif] [int] NULL,
[mast_inv] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER  [dbo].[tg_actualiza_referencia] 
ON  [dbo].[vTTSTMW_Header]
After update 
AS 

SET NOCOUNT ON  
declare	
 @fecha  datetime
 ,@invoice  varchar(50)
 ,@llave  varchar(50)
 
/*--------------------------------------------------------------*/
        SELECT @invoice = ivh_invoicenumber, 
		@llave  = referencia_factura ,
		@fecha =  fecha_wfactura 
              FROM inserted
	 
	Exec actualiza_referencia @invoice , @llave,  @fecha

/* generar archivo tif */
--EXEC sp_envia_archivo_tif  @llave
GO
ALTER TABLE [dbo].[vTTSTMW_Header] ADD CONSTRAINT [PK_vTTSTMW_Header] PRIMARY KEY CLUSTERED ([ivh_invoicenumber], [masterbill]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_vTTSTMW_Header] ON [dbo].[vTTSTMW_Header] ([ivh_billto]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_master_inv] ON [dbo].[vTTSTMW_Header] ([mast_inv]) ON [PRIMARY]
GO
