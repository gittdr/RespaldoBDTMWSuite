SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create PROC [dbo].[d_refs_commaseplist_sp] (@p_table varchar(30),@p_tablekey int,@p_withtypesflag varchar(10))
AS  
/**
 * 
 * NAME:
 * dbo.d_refs_commasepline
 *
 * TYPE:
 * [StoredProcedure)
 *
 * DESCRIPTION:
 * This procedure returns a single row with a comma separated list of all reference numbers for the table and key passed 
 * if argument @p_withtypesflag = 'WITHTYPES' the ref_types are returned with the numbers
 *
 *  Example #1 exec d_refs_commaseplist_sp 'orderheader',33560,'WITHTYPES'
 *             Returns 'BL#: UI9087-00, PO: 6544321, POD: KL998
 *  Example #2 exec d_refs_commaseplist_sp 'orderheader',33560,''
 *             Returns 'UI9087-00, 6544321, KL998
 * 
 *
 * RETURNS:
 * None
 *
 * RESULT SETS: 
 * refnumbers varchar (500) a comma separated list of all ref numbers for the table and key values
 *
 * PARAMETERS:
 * 001 - @p_table varchar(30) 
 *       The table for which the ref numbers are to be returned
 * 002 - @p_tablekey int
 *       The key for the table for which ref numbers are to be returned 
 * 003 - @p_withtypesflag varchar(10)
 *       If 'WITHTYPES' the return set has the ref types followed by the ref numbers

 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 

 * 
 * REVISION HISTORY:
 * 03/13/2006.01 ? PTS32040 - Donna Petersen ? Created for C&K masterbill formats 71 & 72
 *
 **/


Create table #referencenumber (
ref_ident int identity
,ref_type varchar(6) null
, ref_number varchar(30) null
,ref_tablekey int
,ref_sequence int null)    

Declare @v_next int , @v_referencenumbers varchar(500) 

select @p_withtypesflag = upper(@p_withtypesflag),@v_referencenumbers = ''  
    
Insert Into #referencenumber     
Select Distinct ref_type, ref_number,ref_tablekey, ref_sequence From referencenumber    
Where ref_table = @p_table and     
ref_tablekey = @p_tablekey    
Order by ref_sequence,ref_number    
    
Select @v_next = Min(ref_ident) From #referencenumber     
Select @v_next = IsNull(@v_next,0)    
While @v_next > 0
 BEGIN     
   select @v_referencenumbers = @v_referencenumbers +
   (case @p_withtypesflag when 'WITHTYPES' Then  RTRIM(IsNull(ref_type,''))+ ': ' else '' end) 
   +IsNull( ref_number,'') +', '   
   from #referencenumber  where  ref_ident = @v_next

  select  @v_next = min(ref_ident) from #referencenumber where ref_ident > @v_next
  
 END    
If datalength(@v_referencenumbers)>3    
   Select refnumbers = substring(@v_referencenumbers,1,datalength(@v_referencenumbers) - 2)
Else
  Select refnumbers = @v_referencenumbers
GO
GRANT EXECUTE ON  [dbo].[d_refs_commaseplist_sp] TO [public]
GO
