SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- exec sp_obtiene_facturas_chrobins_oo

CREATE PROCEDURE [dbo].[sp_obtiene_facturas_chrobins_oo] 
AS

DECLARE	
	@V_registros	integer,
	@V_i			Integer,
	@V_consecutivo	Integer,	
	@V_Orden			Integer
		

DECLARE @TTOrddenesCHRobins TABLE(TT_NoOrden	Integer null)

Declare @TTResultado TABLE (cliente		integer,
							referencia	varchar(50),
							factura		varchar(50),
							monto		money,
							fuel		money,
							tralixpdf	varchar(250),
							imaging		varchar(250))
		
SET NOCOUNT ON

BEGIN --1 Principal

INSERT Into @TTOrddenesCHRobins 
	select ord_hdrnumber FROM   invoiceheader WHERE    (ivh_billto = 'CHROBINS') AND (ivh_creditmemo = 'N') and ivh_invoicestatus = 'XFR' and ivh_xferdate between dateadd(dd,-8,getdate()) and getdate()


-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @TTOrddenesCHRobins )
	BEGIN --3 Si hay movimientos de posiciones
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE ordenes_Cursor CURSOR FOR 
		SELECT TT_NoOrden
		FROM @TTOrddenesCHRobins
			
		OPEN ordenes_Cursor 
		FETCH NEXT FROM ordenes_Cursor INTO @V_orden

		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor abastecer_Cursor --3
		Insert into @TTResultado
		SELECT        ord_hdrnumber AS Cliente,
              (SELECT        REPLACE(ord_refnum, '#', '') AS Expr1  FROM            dbo.orderheader AS o WHERE        (ord_hdrnumber = i.ord_hdrnumber)) AS referencia, 
			  --REPLACE(REPLACE(REPLACE(ivh_invoicenumber, 'A', ''), 'B', ''), 'C', '') AS factura, 
			  ivh_hdrnumber,
			  ivh_totalcharge AS monto, 
			  ISNULL((SELECT        SUM(ivd_charge) AS Expr1 FROM            dbo.invoicedetail AS d WHERE        (cht_itemcode = 'ACXRUS') AND (ivh_hdrnumber = i.ivh_hdrnumber)), 0) AS fuel,

              (SELECT        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(rutapdf, 'folio=A', 'folio='), 'folio=B', 'folio='), 'folio=C', 'folio='), 'folio=D', 'folio='), 'folio=E', 'folio=') AS Expr1
                               FROM            dbo.VISTA_fe_generadas
                               WHERE        (invoice = i.ivh_invoicenumber)) AS tralixpdf,

              (SELECT        REPLACE(imaging, '172.16.136.34', '10.176.167.171') AS Expr1 
                               FROM            dbo.VISTA_fe_generadas
                               WHERE        (invoice = i.ivh_invoicenumber)) AS imaging
		FROM            dbo.invoiceheader AS i
		WHERE        (ivh_billto = 'CHROBINS') AND (ivh_creditmemo = 'N') AND ivh_hdrnumber =
		(select ivh_hdrnumber from invoiceheader where ivh_hdrnumber = (select max(ivh_hdrnumber) from invoiceheader where ord_hdrnumber = @V_orden))




		 


			FETCH NEXT FROM ordenes_Cursor INTO @V_orden
		END --3 cursor del stops_Cursor

	CLOSE ordenes_Cursor 
	DEALLOCATE ordenes_Cursor 
END -- 2 si hay movimientos del RC
select * from @TTResultado
END --1 Principal
GO
