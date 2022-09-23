SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
 CREATE PROC [dbo].[d_loadpayclass_sp] @paytype varchar(8) , @number int AS  
  
  
if @number = 1   
 set rowcount 1   
else if @number <= 8   
 set rowcount 8  
else if @number <= 16  
 set rowcount 16  
else if @number <= 24  
 set rowcount 24  
else  
 set rowcount 8  
  
if exists (SELECT paytype.pyt_number    
    FROM paytype    
   WHERE IsNull(paytype.pyt_retired,'N') <> 'Y' AND pyt_itemcode LIKE @paytype + '%' )  
  
SELECT paytype.pyt_number,     
         paytype.pyt_itemcode,     
         paytype.pyt_description,     
         paytype.pyt_basis,     
         paytype.pyt_basisunit,     
         paytype.pyt_quantity,     
         paytype.pyt_rateunit,     
         paytype.pyt_unit,     
         paytype.pyt_rate,     
         paytype.pyt_pretax,     
         paytype.pyt_minus,     
         paytype.pyt_editflag,     
         paytype.pyt_pr_glnum,     
         paytype.pyt_ap_glnum,     
         paytype.pyt_fee1,     
         paytype.pyt_fee2,     
         paytype.pyt_accept_negatives,     
         paytype.pyt_fservprocess,     
         paytype.pyt_editindispatch,   
         paytype.pyt_classflag     
    FROM paytype    
   WHERE IsNull(paytype.pyt_retired,'N') <> 'Y' AND pyt_itemcode LIKE @paytype + '%'  
   And paytype.pyt_classflag = 1
  
   ORDER by pyt_itemcode  
Else  
 SELECT paytype.pyt_number,     
         paytype.pyt_itemcode,     
         paytype.pyt_description,     
         paytype.pyt_basis,     
         paytype.pyt_basisunit,     
         paytype.pyt_quantity,     
         paytype.pyt_rateunit,     
         paytype.pyt_unit,     
         paytype.pyt_rate,     
         paytype.pyt_pretax,     
         paytype.pyt_minus,     
         paytype.pyt_editflag,     
         paytype.pyt_pr_glnum,     
         paytype.pyt_ap_glnum,     
         paytype.pyt_fee1,     
         paytype.pyt_fee2,     
         paytype.pyt_accept_negatives,     
         paytype.pyt_fservprocess,     
         paytype.pyt_editindispatch,   
         paytype.pyt_classflag     
    FROM paytype    
    WHERE pyt_itemcode = 'UNK'  
  
set rowcount 0   
GO
GRANT EXECUTE ON  [dbo].[d_loadpayclass_sp] TO [public]
GO
