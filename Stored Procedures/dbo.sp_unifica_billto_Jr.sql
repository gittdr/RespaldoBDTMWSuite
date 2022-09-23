SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_unifica_billto_Jr] @BillTo varchar(20)
AS

BEGIN  --inicial principal
	declare @ls_tipofacturacion as varchar(5)
	SET NOCOUNT ON

		IF @BillTo = 'SAYER'
		Begin --sayer  2
			--obtiene el tipo de facturacion
			select @ls_tipofacturacion = cmp_invoicetype from company where cmp_id = 'SAYER'

			IF @ls_tipofacturacion = 'INV'
				begin --fac inv 3
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('SAYFUL','SAYTORT') and ivh_invoicestatus = 'RTP') > 0
						BEGIN --encuentra fac 4
							UPDATE invoiceheader set ivh_billto = 'SAYER' where ivh_billto in ('SAYFUL','SAYTORT') and ivh_invoicestatus = 'RTP'
							commit;
							select  'Invoices actualizadas con SAYER'
						END -- encuentra fac 4
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3
			
			IF @ls_tipofacturacion = 'MAS'
				begin --fac inv 3.1
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('SAYFUL','SAYTORT') and ivh_mbstatus = 'RTP') > 0
						BEGIN --encuentra fac 4.1
							UPDATE invoiceheader set ivh_billto = 'SAYER' where ivh_billto in ('SAYFUL','SAYTORT') and ivh_mbstatus = 'RTP'
							commit;
							select  'Invoices actualizadas con SAYER'
						END -- encuentra fac 4.1
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3.1
		end --sayer  2

		-- Cte Liverpool LIVERPOL, LIVFUSUR, LIVERDED  A   "LIVERPOL"
		
		IF @BillTo = 'LIVERPOL'
		Begin -- cte  2
			--obtiene el tipo de facturacion
			select @ls_tipofacturacion = cmp_invoicetype from company where cmp_id = 'LIVERPOL'

			IF @ls_tipofacturacion = 'INV'
				begin --fac inv 3
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('LIVFUSUR', 'LIVERDED') and ivh_invoicestatus = 'RTP') > 0
						BEGIN --encuentra fac 4
							UPDATE invoiceheader set ivh_billto = 'LIVERPOL' where ivh_billto in ('LIVFUSUR', 'LIVERDED') and ivh_invoicestatus = 'RTP'
							commit;
							select  'Invoices actualizadas con LIVERPOL'
						END -- encuentra fac 4
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3
			
			IF @ls_tipofacturacion = 'MAS'
				begin --fac inv 3.1
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('LIVFUSUR', 'LIVERDED') and ivh_mbstatus = 'RTP') > 0
						BEGIN --encuentra fac 4.1
							UPDATE invoiceheader set ivh_billto = 'LIVERPOL' where ivh_billto in ('LIVFUSUR', 'LIVERDED') and ivh_mbstatus = 'RTP'
							commit;
							select  'Invoices actualizadas con LIVERPOL'
						END -- encuentra fac 4.1
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3.1
		end --cte  2
		
		-- CTE PILTEPO, PILGRIMS  A   "PILGRIMS"
			IF @BillTo = 'PILGRIMS'
		Begin -- cte  2
			--obtiene el tipo de facturacion
			select @ls_tipofacturacion = cmp_invoicetype from company where cmp_id = 'PILGRIMS'

			IF @ls_tipofacturacion = 'INV'
				begin --fac inv 3
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('PILTEPO') and ivh_invoicestatus = 'RTP') > 0
						BEGIN --encuentra fac 4
							UPDATE invoiceheader set ivh_billto = 'PILGRIMS' where ivh_billto in ('PILTEPO') and ivh_invoicestatus = 'RTP'
							commit;
							select  'Invoices actualizadas con PILGRIMS'
						END -- encuentra fac 4
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3
			
			IF @ls_tipofacturacion = 'MAS'
				begin --fac inv 3.1
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('PILTEPO') and ivh_mbstatus = 'RTP') > 0
						BEGIN --encuentra fac 4.1
							UPDATE invoiceheader set ivh_billto = 'PILGRIMS' where ivh_billto in ('PILTEPO') and ivh_mbstatus = 'RTP'
							commit;
							select  'Invoices actualizadas con PILGRIMS'
						END -- encuentra fac 4.1
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3.1
		end --cte  2


		--CTE PEÑAFIEL, PEÑATECA,  PEÑASPOT    A   "PEÑAFIEL "
		
		IF @BillTo = 'PEÑAFIEL'
		Begin -- cte  2
			--obtiene el tipo de facturacion
			select @ls_tipofacturacion = cmp_invoicetype from company where cmp_id = 'PEÑAFIEL'

			IF @ls_tipofacturacion = 'INV'
				begin --fac inv 3
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('PEÑATECA', 'PEÑASPOT') and ivh_invoicestatus = 'RTP') > 0
						BEGIN --encuentra fac 4
							UPDATE invoiceheader set ivh_billto = 'PEÑAFIEL' where ivh_billto in ('PEÑATECA', 'PEÑASPOT') and ivh_invoicestatus = 'RTP'
							commit;
							select  'Invoices actualizadas con PEÑAFIEL'
						END -- encuentra fac 4
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3
			
			IF @ls_tipofacturacion = 'MAS'
				begin --fac inv 3.1
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('PEÑATECA', 'PEÑASPOT') and ivh_mbstatus = 'RTP') > 0
						BEGIN --encuentra fac 4.1
							UPDATE invoiceheader set ivh_billto = 'PEÑAFIEL' where ivh_billto in ('PEÑATECA', 'PEÑASPOT') and ivh_mbstatus = 'RTP'
							commit;
							select  'Invoices actualizadas con PEÑAFIEL'
						END -- encuentra fac 4.1
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3.1
		end --cte  2

		--- CTE ESTAFETA, ESTAFDED  A   ESTAFETA
		
		IF @BillTo = 'ESTAFETA'
		Begin -- cte  2
			--obtiene el tipo de facturacion
			select @ls_tipofacturacion = cmp_invoicetype from company where cmp_id = 'ESTAFETA'

			IF @ls_tipofacturacion = 'INV'
				begin --fac inv 3
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('ESTAFDED') and ivh_invoicestatus = 'RTP') > 0
						BEGIN --encuentra fac 4
							UPDATE invoiceheader set ivh_billto = 'ESTAFETA' where ivh_billto in ('ESTAFDED') and ivh_invoicestatus = 'RTP'
							commit;
							select  'Invoices actualizadas con ESTAFETA'
						END -- encuentra fac 4
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3
			
			IF @ls_tipofacturacion = 'MAS'
				begin --fac inv 3.1
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('ESTAFDED') and ivh_mbstatus = 'RTP') > 0
						BEGIN --encuentra fac 4.1
							UPDATE invoiceheader set ivh_billto = 'ESTAFETA' where ivh_billto in ('ESTAFDED') and ivh_mbstatus = 'RTP'
							commit;
							select  'Invoices actualizadas con ESTAFETA'
						END -- encuentra fac 4.1
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3.1
		end --cte  2

		--- CTE EUCOMEX, EUCTUL01  A   EUCOMEX
		
		IF @BillTo = 'EUCOMEX'
		Begin -- cte  2
			--obtiene el tipo de facturacion
			select @ls_tipofacturacion = cmp_invoicetype from company where cmp_id = 'EUCOMEX'

			IF @ls_tipofacturacion = 'INV'
				begin --fac inv 3
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('EUCTUL01') and ivh_invoicestatus = 'RTP') > 0
						BEGIN --encuentra fac 4
							UPDATE invoiceheader set ivh_billto = 'EUCOMEX' where ivh_billto in ('EUCTUL01') and ivh_invoicestatus = 'RTP'
							commit;
							select  'Invoices actualizadas con EUCOMEX'
						END -- encuentra fac 4
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3
			
			IF @ls_tipofacturacion = 'MAS'
				begin --fac inv 3.1
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('EUCTUL01') and ivh_mbstatus = 'RTP') > 0
						BEGIN --encuentra fac 4.1
							UPDATE invoiceheader set ivh_billto = 'EUCOMEX' where ivh_billto in ('EUCTUL01') and ivh_mbstatus = 'RTP'
							commit;
							select  'Invoices actualizadas con EUCOMEX'
						END -- encuentra fac 4.1
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3.1
		end --cte  2

		--- CTE PISA,  PISADED   A    PISA
		
		IF @BillTo = 'PISA'
		Begin -- cte  2
			--obtiene el tipo de facturacion
			select @ls_tipofacturacion = cmp_invoicetype from company where cmp_id = 'PISA'

			IF @ls_tipofacturacion = 'INV'
				begin --fac inv 3
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('PISADED') and ivh_invoicestatus = 'RTP') > 0
						BEGIN --encuentra fac 4
							UPDATE invoiceheader set ivh_billto = 'PISA' where ivh_billto in ('PISADED') and ivh_invoicestatus = 'RTP'
							commit;
							select  'Invoices actualizadas con PISA'
						END -- encuentra fac 4
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3
			
			IF @ls_tipofacturacion = 'MAS'
				begin --fac inv 3.1
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('PISADED') and ivh_mbstatus = 'RTP') > 0
						BEGIN --encuentra fac 4.1
							UPDATE invoiceheader set ivh_billto = 'PISA' where ivh_billto in ('PISADED') and ivh_mbstatus = 'RTP'
							commit;
							select  'Invoices actualizadas con PISA'
						END -- encuentra fac 4.1
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3.1
		end --cte  2


		--- CTE DHLDL03, DHLDEDMX, DHLMETRO  A   DHLMETRO
		
		IF @BillTo = 'DHLMETRO'
		Begin -- cte  2
			--obtiene el tipo de facturacion
			select @ls_tipofacturacion = cmp_invoicetype from company where cmp_id = 'DHLMETRO'

			IF @ls_tipofacturacion = 'INV'
				begin --fac inv 3
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('DHLDL03', 'DHLDEDMX') and ivh_invoicestatus = 'RTP') > 0
						BEGIN --encuentra fac 4
							UPDATE invoiceheader set ivh_billto = 'DHLMETRO' where ivh_billto in ('DHLDL03', 'DHLDEDMX') and ivh_invoicestatus = 'RTP'
							commit;
							select  'Invoices actualizadas con DHLMETRO'
						END -- encuentra fac 4
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3
			
			IF @ls_tipofacturacion = 'MAS'
				begin --fac inv 3.1
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('DHLDL03', 'DHLDEDMX') and ivh_mbstatus = 'RTP') > 0
						BEGIN --encuentra fac 4.1
							UPDATE invoiceheader set ivh_billto = 'DHLMETRO' where ivh_billto in ('DHLDL03', 'DHLDEDMX') and ivh_mbstatus = 'RTP'
							commit;
							select  'Invoices actualizadas con DHLMETRO'
						END -- encuentra fac 4.1
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3.1
		end --cte  2

		--- CTE PALACIO, PALHDEDI  A   PALACIO
		
		IF @BillTo = 'PALACIO'
		Begin -- cte  2
			--obtiene el tipo de facturacion
			select @ls_tipofacturacion = cmp_invoicetype from company where cmp_id = 'PALACIO'

			IF @ls_tipofacturacion = 'INV'
				begin --fac inv 3
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('PALHDEDI') and ivh_invoicestatus = 'RTP') > 0
						BEGIN --encuentra fac 4
							UPDATE invoiceheader set ivh_billto = 'PALACIO' where ivh_billto in ('PALHDEDI') and ivh_invoicestatus = 'RTP'
							commit;
							select  'Invoices actualizadas con PALACIO'
						END -- encuentra fac 4
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3
			
			IF @ls_tipofacturacion = 'MAS'
				begin --fac inv 3.1
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('PALHDEDI') and ivh_mbstatus = 'RTP') > 0
						BEGIN --encuentra fac 4.1
							UPDATE invoiceheader set ivh_billto = 'PALACIO' where ivh_billto in ('PALHDEDI') and ivh_mbstatus = 'RTP'
							commit;
							select  'Invoices actualizadas con PALACIO'
						END -- encuentra fac 4.1
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3.1
		end --cte  2

		--- CTE EFFEMDED , EFFEM  A  EFFEM

		IF @BillTo = 'EFFEM'
		Begin -- cte  2
			--obtiene el tipo de facturacion
			select @ls_tipofacturacion = cmp_invoicetype from company where cmp_id = 'EFFEM'

			IF @ls_tipofacturacion = 'INV'
				begin --fac inv 3
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('EFFEMDED') and ivh_invoicestatus = 'RTP') > 0
						BEGIN --encuentra fac 4
							UPDATE invoiceheader set ivh_billto = 'EFFEM' where ivh_billto in ('EFFEMDED') and ivh_invoicestatus = 'RTP'
							commit;
							select  'Invoices actualizadas con PALACIO'
						END -- encuentra fac 4
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3
			
			IF @ls_tipofacturacion = 'MAS'
				begin --fac inv 3.1
					IF (select COUNT(*) from invoiceheader where ivh_billto in ('EFFEMDED') and ivh_mbstatus = 'RTP') > 0
						BEGIN --encuentra fac 4.1
							UPDATE invoiceheader set ivh_billto = 'EFFEM' where ivh_billto in ('EFFEMDED') and ivh_mbstatus = 'RTP'
							commit;
							select  'Invoices actualizadas con EFFEM'
						END -- encuentra fac 4.1
					ELSE
							Select 'No hay facturas'
				End -- de cuando es facturacion ind 3.1
		end --cte  2

		SELECT 'Fin proceso'
END -- fin principal 1
GO
