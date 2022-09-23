SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE    PROCEDURE [dbo].[actualiza_wfactura] (@invoice  varchar(12) ) AS

Declare   
@mbill int,
@status varchar(3),
@serie varchar(3),
@billto varchar(8),
@invoicenumber varchar(12)
/* Buscar en la vista*/

IF not exists (select  isnull(ivh_invoicenumber,'')
from  vTTSTMW_Header 
where ivh_invoicenumber = @invoice)
Begin
	-- Buscar en historico
	IF not exists (select  isnull(ivh_invoicenumber,'')
	from wfactura_hist  
	where ivh_invoicenumber = @invoice)
	begin 

	Select @mbill  = isnull(masterbill, 0), @billto = ivh_billto , @serie = serie
	from VISTA_TMW_Header where ivh_invoicenumber = @invoice 

	Select @status  = ivh_invoicestatus
	from invoiceheader 
	where ivh_invoicenumber = @invoice

	/*
	select  isnull(masterbill, 0)
	from VISTA_TMW_Header where ivh_invoicenumber = '361075'

	select   ivh_invoicestatus
	from invoiceheader 
	where ivh_invoicenumber ='361075'
	*/

	/* Impreso y no existe en la tabla de paso */
	If @status = 'PRN' 
	Begin
		If @mbill> 0 
		
	
		Begin    
		IF not exists (select  isnull(ivh_invoicenumber,'')
			from vTTSTMW_Header 
			where masterbill = @mbill)
			begin
		
				exec forma_cadena_mb  @mbill
		end
		end
		else
		Begin
		
			Insert into  vTTSTMW_Header
			select * from VISTA_TMW_header 
			where ivh_invoicenumber = @invoice and
			ivh_invoicenumber   not like 'T%'  
					
			Insert into  vTTSTMW_detail
			select * from VISTA_TMW_detail 
			where ivh_invoicenumber = @invoice and
			ivh_invoicenumber   not like 'T%'  

			IF not exists (select  isnull(invoice,'')
			from wf_archivos 
			where invoice = @invoice) and  @mbill = 0
			begin

				Insert into wf_archivos (serie, folio, fecha, invoice, master)
				values (@serie, 0, getdate(), @invoice ,  @mbill )
			end
	

			/*
				
			Insert into  dfe..comprobante
			select * from VISTA_dfe_header
			where invoice  = @invoice and
			invoice not like 'T%'  
					
			Insert into  dfe..concepto
			select ivh_invoicenumber, ivd_quantity, ivd_unit, descripcion, ivd_rate, ivd_charge,tasa_iva, tasa_ret, iva_monto, ret_monto
			from vista_tmw_detail
			where ivh_invoicenumber = @invoice and
			ivh_invoicenumber   not like 'T%' 

*/ 

			 
		
		end
	end
end
end
GO
