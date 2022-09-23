CREATE TABLE [dbo].[VISTA_Carta_Porte]
(
[Folio] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Serie] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UUID] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pdf_xml_descarga] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pdf_descargaFactura] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[xlm_descargaFactura] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  Trigger [dbo].[InsertaMsgCartaPorte]    Script Date: 12/28/2016 12:21:43 PM ******/



--  /*****************************************************/
--	Trigger que tiene como proposito insertar un mensaje para informarle al Operador de la generación de una carta porte
--  Ademas se anexa el link de la representación PDF de la misma

--DROP TRIGGER [InsertaMsgCartaPorte]

CREATE TRIGGER [dbo].[InsertaMsCartaporte] ON [TMWSuite].[dbo].[VISTA_Carta_Porte]
AFTER INSERT
AS

	DECLARE @ls_leg 	Integer,
		@l_operador		varchar(20),
		@l_unidad       varchar(20),
		@l_orden        varchar(20),
		@l_cliente      varchar(20),
		@l_ligapdf      varchar(max),
		@l_mensaje      varchar(max)
	



	/* Se hace el select para obtener los datos que se estan insertando */
	/* y enviar el mensaje a los operadores */

SELECT 	@ls_leg	    = b.LegNum,
	    @l_operador = a.lgh_driver1,
		@l_orden    = a.ord_hdrnumber,
		@l_unidad   = a.lgh_tractor,
		@l_cliente  = (select ord_billto from orderheader where orderheader.ord_hdrnumber = a.ord_hdrnumber),
		@l_ligapdf  = b.Pdf_descargaFactura
FROM  legheader a, INSERTED b
WHERE   a.lgh_number = b.LegNum 


/* Se arma el mensaje a enviar al operador*/
select @l_mensaje = 'Se ha generado la carta Porte para el cliente ' + @l_cliente + ' con el segmento ' + cast(@ls_leg as varchar(20)) 
                     + ' Puedes consultarla en la siguiente liga: ' + @l_ligapdf



/* se ejecuta el sp para enviar el mensaje*/

exec tm_insertamensaje @l_mensaje, @l_unidad


GO
