SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
Create procedure [dbo].[d_refnumbers_byorder]  @ord int
As
/* 

  MODIFCATION LOG  *** add columns??  change also d_refnumbers_bymovord and d_refnumbers

5/28/02 Created by DPETE
12/5/08 PTS 43837 add ord number as reference
08/06/12 PTS 64214 include where ref_table = 'orderheader' and ref_tablekey = ord_hdrnumber
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
ord_number   
        
FROM referencenumber 
left outer join orderheader on referencenumber.ord_hdrnumber = orderheader.ord_hdrnumber
Where referencenumber.ord_hdrnumber = @ord 
-- PTS 64214 SGB Added UNION and order by 
UNION 
SELECT  
seq  = @int,   
referencenumber.ref_type ,         
referencenumber.ref_number ,           
referencenumber.ref_sequence ,           
referencenumber.ref_table ,           
referencenumber.ref_tablekey ,           
referencenumber.ord_hdrnumber ,
ord_number   
FROM referencenumber 
left outer join orderheader on referencenumber.ord_hdrnumber = orderheader.ord_hdrnumber
where ref_table = 'orderheader' and ref_tablekey = @ord
order by ref_table, ref_tablekey,ref_sequence   
-- END PTS 64214 SGB Added UNION and order by 
 

GO
GRANT EXECUTE ON  [dbo].[d_refnumbers_byorder] TO [public]
GO
