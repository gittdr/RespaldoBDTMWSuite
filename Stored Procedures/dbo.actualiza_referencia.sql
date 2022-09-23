SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO








/* 
SELECT *   FROM TMWSUITE.dbo.invoicedetail	 
where Ivh_hdrnumber in ( 13662)

select * from wfacturado    order  by folio invcnumber = '24185'
 SELECT * from TMWSUITE.dbo.vTTSTMW_Header  where ord_number = 10471 
 SELECT  * from TMWSUITE.dbo.vista_TMW_Header  where ivh_invoicenumber = 'TQR004302' 
ord_number = 10471 
 SELECT * from TMWSUITE.dbo.vista_TMW_detail  where ivh_invoicenumber = 'TQR004302'  ord_number = 10471 
 SELECT * from TMWSUITE.dbo.vTTSTMW_detail  where ivh_invoicenumber = 'TQR002773' 
 SELECT ivh_hdrnumber ,* from TMWSUITE.dbo.invoiceheader  where ivh_invoicenumber = 'TQR002773' 'TQR004302'
Exec actualiza_referencia  '30077', 'TDR153',  '2009-07-11 11:51:12' 
*/
CREATE         PROCEDURE  [dbo].[actualiza_referencia] (
 @invoice varchar(50), @llave varchar(50), @fecha datetime )AS

Declare 
@time timestamp,
@ord_number char(12),
@ref_number varchar(30) ,
@ref_type varchar(30) ,
@key  integer,
@masterbill  integer 
/*



select *  From TMWSUITE.dbo.vTTSTMW_Header  where ivh_creditmemo = 'Y'
Where ivh_invoicenumber = 'TQR004303'Y
*/
 IF  NOT EXISTs(Select   ord_number
From  vTTSTMW_Header 
Where ivh_invoicenumber = @invoice)
Begin
	Select @ord_number = ord_number
	From TMWSUITE.dbo.wfactura_hist  
	Where ivh_invoicenumber = @invoice
end
else
	Select @ord_number = ord_number,
	       @masterbill   = masterbill
	From  TMWSUITE.dbo.vTTSTMW_Header 
	Where ivh_invoicenumber = @invoice
 /*
	Select ord_number
	From TMWSUITE.dbo.vTTSTMW_Header 
	Where ivh_invoicenumber = 40620

*/



/*
Update  TMWSUITE.dbo.vTTSTMW_Header  
set    referencia_factura = 'TDR256', 
	fecha_wfactura = '2009/06/22 10:50' 
Where ivh_invoicenumber =  'TQR004305'*/

Select @ref_number =  ref_number ,
@ref_type  =  ref_type,
@time = timestamp
From TMWSUITE.dbo.referencenumber
Where ref_table = 'orderheader' and
ord_hdrnumber   = @ord_number

/*
select ref_number, timestamp ,*
From TMWSUITE.dbo.referencenumber
where  ref_table = 'orderheader' and
ref_tablekey   = 22932  


select ref_number, timestamp ,*
From TMWSUITE.dbo.referencenumber
where  ref_table = 'orderheader' and
ref_type = 'FTDR' AND
REF_NUMBER = '' AND
ref_tablekey   = 22932 


DELETE
TMWSUITE.dbo.referencenumber
where  ref_table = 'orderheader' and
ref_type = 'FTDR' AND
REF_NUMBER = '' AND
ref_tablekey   = 22932 
*/



DELETE
TMWSUITE.dbo.referencenumber
where  ref_table = 'orderheader' and
ref_type = 'FTDR' AND
REF_NUMBER = '' AND
ref_tablekey   =  @ord_number

Select  @key  = 1

If  len(@ref_number) > 1    /**si hay referencia */
 begin
		
	Select  @key = isnull(max(ref_sequence),0)
	from TMWSUITE.dbo.referencenumber
	where ref_table = 'orderheader' and
	ord_hdrnumber  = @ord_number		 

	Update TMWSUITE.dbo.referencenumber set ref_sequence  =  @key  +1 
	where ref_table = 'orderheader' and
	ord_hdrnumber  = @ord_number and ref_sequence =  1
	/*Update TMWSUITE.dbo.referencenumber set ref_sequence   = 2
	delete TMWSUITE.dbo.referencenumber where  
	ord_hdrnumber  = 10470 and ref_number = 'TQR002770' and ref_typedesc = ''*/
end 
	
/*si no existe  solo actualizar*/
/*If  @ref_type  = 'FTDR'  
	UPDATE TMWSUITE.dbo.referencenumber SET ref_number = @llave
	where  ord_hdrnumber  = @ord_number and ref_sequence =  1
ELSE	*/
	/*Insert into TMWSUITE.dbo.referencenumber
	(ref_tablekey, ref_type, ref_number, ref_typedesc,ref_sequence, ord_hdrnumber,
	  ref_table, ref_sid, ref_pickup, last_updateby, last_updatedate)
	Values (@ord_number, 'FTDR', @llave , '', 1,   @ord_number,              
	  'orderheader', '', '', 'WF', @fecha)*/

 
/*
Insert into TMWSUITE.dbo.referencenumber
(ref_tablekey, ref_type, ref_number, ref_typedesc,ref_sequence, ord_hdrnumber,
  ref_table, ref_sid, ref_pickup, last_updateby, last_updatedate)
Values (10470, 'REF','TDR256' , '', 1,   10470,              
  'orderheader', '', '', 'WF', getdate()) 

select * 
from TMWSUITE.dbo.referencenumber
	where 
	select * from TMWSUITE.dbo.invoiceheader
	where  ord_hdrnumber = 13330
*/

-- Actualizar todas las invoice de la master


Update TMWSUITE.dbo.invoiceheader
  Set  ivh_ref_number = @llave,
	ivh_reftype = 'FTDR'
Where    ivh_mbnumber  =  @masterbill   
and ivh_mbnumber  >0 


Update TMWSUITE.dbo.invoiceheader
  Set  ivh_ref_number = @llave,
	ivh_reftype = 'FTDR' 
where ivh_invoicenumber = @invoice

/*
Update  TMWSUITE.dbo.invoiceheader
set  ivh_ref_number = 'TDR254'
Where ord_number = 11899
*/


GO
