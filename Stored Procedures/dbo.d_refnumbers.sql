SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


Create procedure [dbo].[d_refnumbers]  @ord int  
As  
/*   
  MODIFCATION LOG   ** if colums are added, change also d_refnumbers_byorder and d_refnumbers_bymovorder 
11/21/02 created by LOR from d_refnumbers_byorder 
12/5/08 PTS43837  invoice by move add ord number for reference and add ref_table to where 
05/31/14 NQIAO PTS 76259 - modify the where condition to display reference number entered for credit memo/ rebill if any.
*/  
  
Declare @desc varchar (50), @int int  
Select @int = 0  
  
SELECT    
seq  = @int,     
referencenumber.ref_type ,           
referencenumber.ref_number ,             
referencenumber.ref_sequence ,             
referencenumber.ref_table ,             
referencenumber.ref_tablekey ,             
referencenumber.ord_hdrnumber ,
'' ord_number     
FROM referencenumber 
--Where referencenumber.ref_tablekey = @ord				// 76259
Where (referencenumber.ref_tablekey = @ord or
	   referencenumber.ref_tablekey in (select ivh_hdrnumber from invoiceheader where ivh_cmrbill_link = @ord))			--76259
and ref_table = 'invoiceheader'       
   
  
GO
GRANT EXECUTE ON  [dbo].[d_refnumbers] TO [public]
GO
