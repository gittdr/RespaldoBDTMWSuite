SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO






















/*EXEC actualiza_wfactura_MASTER */ 


CREATE                          PROCEDURE [dbo].[actualiza_wfactura_MASTER]   AS

Declare   
@mbill int,
@billto varchar(8), 
@serie varchar(3), 
@invoice  varchar(12)
/* Buscar en la vista*/
/*
DECLARE  facturas  CURSOR FOR 
Select  masterbill, ivh_invoicenumber, ivh_billto 
from  VISTA_TMW_header
where masterbill not in
(select masterbill from vTTSTMW_Header ) and
masterbill > 0  
*/
DECLARE  facturas  CURSOR FOR 
Select  masterbill, VISTA_TMW_header.ivh_invoicenumber, VISTA_TMW_header.ivh_billto , VISTA_TMW_header.serie
from VISTA_TMW_header ,invoiceheader
where masterbill   not in  (select masterbill  
from vttstmw_header ) and
VISTA_TMW_header.ivh_invoicenumber =  invoiceheader.ivh_invoicenumber and 
masterbill > 0 and
 ivh_lastprintdate >= dateadd(day, -2, getdate())and
 ivh_lastprintdate <= dateadd(minute, -6, getdate()) 


OPEN facturas

FETCH NEXT FROM facturas
INTO @mbill, @invoice, @billto, @serie

WHILE @@FETCH_STATUS = 0
BEGIN


	If @billto <> 'TCHEDRAU'  AND @billto <> 'SAE' 
	begin
		--WAITFOR DELAY '00:00:01'
		Delete VTTSTMW_detail
		where ivh_invoicenumber = @invoice 
	
		Insert into  VTTSTMW_detail
		select * from VISTA_TMW_detail 
		where ivh_invoicenumber = @invoice 
	
		Insert into   VTTSTMW_Header 
		select * from VISTA_TMW_header
		where masterbill  = @mbill 
	
		IF not exists (select  isnull(invoice,'')
				from wf_archivos 
				where master = @mbill)
		begin

			Insert into wf_archivos (serie, folio, fecha, invoice, master)
			values (@serie, 0, getdate(), @invoice ,  @mbill )
		end 	 

		/*Formar la lista de facturas que ampara la  master bill */
		If @billto <> 'KRAFT' and  @billto  <> 'MATTEL' AND @billto <> 'NESTLE'  AND @billto <> 'LIVERPOL'  AND @billto <> 'ALMLIVER'   
		     exec forma_cadena_mb  @mbill
			
	end

		FETCH NEXT FROM facturas
		INTO @mbill, @invoice, @billto, @serie
		 
End
 


CLOSE facturas

DEALLOCATE facturas


GO
