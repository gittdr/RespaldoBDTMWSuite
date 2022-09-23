SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create PROC [dbo].[d_refs_commaseplist_light_sp] (@p_table varchar(30),@p_tablekey int,@p_withtypesflag varchar(10))
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
 *  Example #1 exec d_refs_commaseplist_light_sp 'orderheader',33560,'WITHTYPES'
 *             Returns 'BL#: UI9087-00, PO: 6544321, POD: KL998
 *  Example #2 exec d_refs_commaseplist_light_sp 'orderheader',33560,''
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
 * 12/20/2007 BDH Created.  Used instead of d_refs_commaseplist_sp because this uses less overhead.
 **/

/*

select * from referencenumber where ord_hdrnumber = 4262

exec d_refs_commaseplist_light_sp 'orderheader', 1306, 'withtypes'


*/



declare @v_referencenumbers varchar (500)
set @v_referencenumbers = ''

select @v_referencenumbers = @v_referencenumbers  + (case @p_withtypesflag when 'WITHTYPES' Then  RTRIM(IsNull(ref_type,''))+ ': ' else '' end) 
   +IsNull( ref_number,'') +', '  
from referencenumber
where ref_tablekey = @p_tablekey and ref_table = @p_table
If len(@v_referencenumbers) > 0 Set @v_referencenumbers = substring(@v_referencenumbers,1,len(@v_referencenumbers) - 1)
 
Select refnumbers = @v_referencenumbers

GO
GRANT EXECUTE ON  [dbo].[d_refs_commaseplist_light_sp] TO [public]
GO
