SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO








/*  Proceso para enviar las master a wf
     exec actualiza_wfactura_master
	EXEC envia_master_sp
  
*/
CREATE           PROCEDURE [dbo].[envia_master_sp] AS


Declare
@invoicenumber varchar(12)
 
/*  Crea Cursor*/
Declare Carga_cursor Cursor For
Select VISTA_TMW_header.ivh_invoicenumber
from VISTA_TMW_header ,invoiceheader
where masterbill   not in  (select masterbill  
from vttstmw_header ) and
VISTA_TMW_header.ivh_invoicenumber =  invoiceheader.ivh_invoicenumber and 
masterbill > 0 and
 ivh_lastprintdate >= dateadd(day, -2, getdate())and
 ivh_lastprintdate <= dateadd(minute, -15, getdate()) 

Open Carga_cursor
Fetch Next From Carga_cursor Into @invoicenumber 

While @@Fetch_Status = 0
Begin 
	Exec actualiza_wfactura @invoicenumber

	Fetch Next From Carga_cursor Into @invoicenumber 
end


CLOSE Carga_cursor
DEALLOCATE Carga_cursor











GO
