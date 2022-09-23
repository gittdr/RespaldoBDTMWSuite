SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create PROC [dbo].[d_refs_commaseplistfortypes_sp] (@p_table varchar(30),@p_tablekey int,@p_withtypesflag varchar(10)
, @p_includeexclude  char(1),@p_types varchar(80),@p_max int )
AS  
/**
 * 
 * NAME:
 * dbo.d_refs_commaseplistfortypes_sp
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
 * if type alues are passed, only refs of that type will be returned.
 *
 * PARAMETERS:
 * 001 - @p_table varchar(30) 
 *       The table for which the ref numbers are to be returned
 * 002 - @p_tablekey int
 *       The key for the table for which ref numbers are to be returned 
 * 003 - @p_withtypesflag varchar(10)
 *       If 'WITHTYPES' the return set has the ref types followed by the ref numbers
 * 004 - @includeexclude  flag that certain types will be excluded or included
 *        I to include only types specified, X to exclude types specified
 * 005 - @types comma sep list of ref types to exclude
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 

 * 
 * REVISION HISTORY:
 * 05/13/09.01 ? PTS46930 - Donna Petersen ? Created for Northwest Log format 165
 * 05/20/09                 select top (@p_max) does not work with SQL servers before 2005
 *  07/16/12 61804 DPETE eliminate duplicate ref numbers
 **/

declare @types table (ref_type varchar(6))


declare  @referencenumber table(
ref_type varchar(6) null
, ref_number varchar(30) null
)    

Declare @v_next int , @v_referencenumbers varchar(500) 

INSERT into @referencenumber
select  ref_type,ref_number
from referencenumber
where ref_table = @p_table
and ref_tablekey = @p_tablekey
order by ref_sequence


INSERT @types(ref_type )
SELECT * FROM CSVStringsToTable_fn(@p_types) where value <> 'UNK'

select @p_withtypesflag = upper(@p_withtypesflag),@v_referencenumbers = ''  
If @p_includeexclude <> 'I' and @p_includeexclude <> 'E'  select @p_includeexclude = ''

set rowcount @p_max
If @p_includeexclude = ''
  select  --top (@p_max) 
      @v_referencenumbers = @v_referencenumbers + 
      (case @p_withtypesflag when 'Y' then ref_type else '' end)
      +' '+ref_number+', '
  from (select distinct ref_type,ref_number from @referencenumber) refs
  


If @p_includeexclude = 'I'
  select --top (@p_max)  
      @v_referencenumbers = @v_referencenumbers + 
      (case @p_withtypesflag when 'Y' then referencenumber.ref_type else '' end)
      +' '+referencenumber.ref_number+', '
  from (select distinct ref_type,ref_number from @referencenumber) referencenumber
  join @types tp on referencenumber.ref_type = tp.ref_type
 -- where ref_table = @p_table
 -- and ref_tablekey = @p_tablekey
 -- order by ref_sequence


If @p_includeexclude = 'E'
  select  --top (@p_max) 
      @v_referencenumbers = @v_referencenumbers + 
      (case @p_withtypesflag when 'Y' then ref_type else '' end)
      +' '+ref_number+', '
  from (select distinct ref_type,ref_number from @referencenumber) referencenumber
  WHERE 
  not exists (select 1 from @types tp where tp.ref_type = referencenumber.ref_type)
  



If datalength(@v_referencenumbers)>3    
   Select refnumbers = substring(@v_referencenumbers,1,datalength(@v_referencenumbers) - 2)
Else
  Select refnumbers = @v_referencenumbers
GO
GRANT EXECUTE ON  [dbo].[d_refs_commaseplistfortypes_sp] TO [public]
GO
