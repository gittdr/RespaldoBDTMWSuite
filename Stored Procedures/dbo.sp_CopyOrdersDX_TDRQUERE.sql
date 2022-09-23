SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name> Linda
-- Create date: <Create Date,,> 13/04/20
-- Description:	<Description,,> Crea copia de órdenes CMP cargadas por DX con requisitos de Facturación Convoy360°.
								-- Sustituyendo:
								-- BillTo = TDRQUERE y División = CNV (Convoy360)
								-- Por
								-- BillTo = SAE y División = FRM (Freight Management)

-- Exec [dbo].[sp_CopyOrdersDX_TDRQUERE] 1
-- =============================================

CREATE PROCEDURE [dbo].[sp_CopyOrdersDX_TDRQUERE] (@accion int)
	-- Add the parameters for the stored procedure here
AS
BEGIN
	IF(@accion = 1)
	BEGIN

	DECLARE @ref VARCHAR(MAX);

	DECLARE @BillTo VARCHAR(MAX);
	DECLARE @OrderBy VARCHAR(MAX);
	DECLARE @Division VARCHAR(MAX);
	DECLARE @ProyOrden VARCHAR(MAX);
	DECLARE @InvoiceStatus VARCHAR(MAX);
	SET @BillTo = 'SAE';
	SET @OrderBy = 'SAE';
	SET @Division = 'CNV';
	SET @ProyOrden = 'SAEO';
	SET @InvoiceStatus = 'XIN'


		SELECT @ref = ord_refnum
		FROM orderheader
		WHERE ord_refnum = 'prueVER6-FactConvoy-1'
		PRINT @ref

		SELECT * 
		FROM orderheader
		WHERE ord_bookedby = 'DX'
		AND ord_billto = 'TDRQUERE'
		--AND ord_bookdate > '2020-03-29'
		AND ord_revtype4 IN ('CNV')
		AND ord_status = 'CMP'
		AND  ord_status <> 'CAN'
	
	END
END
GO
