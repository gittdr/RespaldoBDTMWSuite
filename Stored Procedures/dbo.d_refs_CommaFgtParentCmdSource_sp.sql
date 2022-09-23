SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create PROC [dbo].[d_refs_CommaFgtParentCmdSource_sp] (@p_ordhdrnumber int,@p_fgtnumber int,@p_withtypesflag varchar(10)
, @p_includeexclude  char(1),@p_types varchar(80),@p_max int )
AS  
/**
 * 
 * NAME:
 * dbo.d_refs_CommaFgtParentCmdSource_sp
 *
 *    For printing ref numbers from the parent commodity of a delivered blend product
 *    Fuels DIspatch puts a fgt_parentcmd_fgt_number on the picked up commodity
 *    which point to one or more delevered products on the trip. Given the order and
 *    the delivered commodity fgt number, return ref numbers attached to the
 *    picked up commmodity or commodities that point to it
 *
 *    Return ref numberf for the commodity on the fgt_number passed plus any on the 
 *    pick up fgreight records which point to this one by the fgt_parencmd_fgt_nubmer
 *
 * TYPE:
 * [StoredProcedure)
 *
 * DESCRIPTION:
 *    For printing ref numbers form the parent commodity of a delivered product
 *    Fuels DIspatch puts a fgt_parentcmd_fgt_number on the picked up commodity
 *    which point to one or more delevered products on the trip. Given the order and
 *    the delivered commodity fgt number, return ref numbers attached to the
 *    picked up commmodity or commodities that point to it
 * This procedure returns a single row with a comma separated list of all reference numbers 
 *
 *  Example #1 exec d_refs_commaseplist_sp 64531,33560,'WITHTYPES'
 *             Returns 'BL#: UI9087-00, PO: 6544321, POD: KL998
 *  Example #2 exec d_refs_commaseplist_sp 64531,33560,''
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
 * 001 - @p_ordhdrnumber int 
 *       To use indexes on the stops table in trying to find the pickup commodities that point 
 *       to the fgt_number of the commodity on the invoice 
 * 002 - @p_fgtnumber int
 *       The fgt_number of the delivered commodity, look for htis value in the 
 *       fgt_parentcmd_fgt_number on the pickup commodity to return its ref numbers
 *       There may be mroe than one pickup commodity
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
 * 04/23/09.01 ? PTS45506 - Donna Petersen ? Created for Wynne format 164
 * 12/22/09 PTS 50215 customer wants distinct fgt ref numbers (by type and number)
 **/
declare @next int, @nxttype varchar(6), @nxtnumber varchar(30)
Declare  @v_referencenumbers varchar(500) 

declare @validfgtnumbers table (fgt_number int )

declare @types table (ref_type varchar(6))

declare @pupfgtnumber table (fgt_number int null)


declare  @referencenumber table(
ref_ident int identity
,ref_type varchar(6) null
, ref_number varchar(30) null
,ref_tablekey int null
,ref_sequence int null) 

-- note found ref numbers in referencenumber for order with invalid freight numbers
-- these were messing up the resultsInsert into @validfgtnumbers
insert into @validfgtnumbers
select fgt_number
from stops s join freightdetail f on s.stp_number = f.stp_number
where ord_hdrnumber = @p_ordhdrnumber

/* Pick up all refs for the order attached to (valid) freight for this order */
Insert into @referencenumber
select   ref_type,
ref_number,
ref_tablekey,
ref_sequence
from referencenumber 
join @validfgtnumbers vfgt on referencenumber.ref_tablekey = vfgt.fgt_number
where ref_table = 'freightdetail' 


/* eliminate duplicate ref numbers */
If @@rowcount > 1
  BEGIN
    Select @next = min(ref_ident) from @referencenumber
    While @next is not null
      BEGIN
        select @nxttype = ref_type, @nxtnumber = ref_number from @referencenumber where ref_ident = @next

       delete from @referencenumber 
        where ref_type = @nxttype
        and ref_number = @nxtnumber
        and ref_ident > @next

        select @next = min(ref_ident) from @referencenumber where ref_ident > @next
      END
     
  END

-- select '## refs after',* from  @referencenumber



INSERT @types(ref_type )
SELECT * FROM CSVStringsToTable_fn(@p_types) where value <> 'UNK'

select @p_withtypesflag = upper(@p_withtypesflag),@v_referencenumbers = ''  
If @p_includeexclude <> 'I' and @p_includeexclude <> 'E'  select @p_includeexclude = ''

if @p_ordhdrnumber > 0 and @p_fgtnumber > 0
  BEGIN

    insert into @pupfgtnumber
    select @p_fgtnumber


    insert into @pupfgtnumber
    select fgt_number 
    from stops
    join freightdetail on stops.stp_number = freightdetail.stp_number
    where stops.ord_hdrnumber = @p_ordhdrnumber
    and stp_type = 'PUP'
    and fgt_parentcmd_fgt_number = @p_fgtnumber

    set rowcount @p_max
    if (select count(*) from @pupfgtnumber) > 0
      BEGIN


        If @p_includeexclude = ''
          select --top (@p_max) can't do in older MSSQL
              @v_referencenumbers = @v_referencenumbers + 
              (case @p_withtypesflag when 'Y' then ref_type else '' end)
              +' '+ref_number+', '
          from @referencenumber referencenumber
          join @pupfgtnumber fgt on referencenumber.ref_tablekey = fgt.fgt_number
          --where ref_table = 'freightdetail'
          order by ref_sequence


        If @p_includeexclude = 'I'
          select --top (@p_max)  
              @v_referencenumbers = @v_referencenumbers + 
              (case @p_withtypesflag when 'Y' then referencenumber.ref_type else '' end)
              +' '+referencenumber.ref_number+', '
          from @referencenumber referencenumber
          join @pupfgtnumber fgt on referencenumber.ref_tablekey = fgt.fgt_number
          join @types tp on referencenumber.ref_type = tp.ref_type
          --where ref_table = 'freightdetail'
          order by ref_sequence


        If @p_includeexclude = 'E'
          select  --top (@p_max)  
              @v_referencenumbers = @v_referencenumbers + 
              (case @p_withtypesflag when 'Y' then ref_type else '' end)
              +' '+ref_number+', '
          from @referencenumber referencenumber
          join @pupfgtnumber fgt on referencenumber.ref_tablekey = fgt.fgt_number
          where --ref_table = 'freightdetail'
          not exists (select 1 from @types tp where tp.ref_type = referencenumber.ref_type)
          order by ref_sequence
       END
END

If datalength(@v_referencenumbers)>3    
   Select refnumbers = substring(@v_referencenumbers,1,datalength(@v_referencenumbers) - 2)
Else
  Select refnumbers = @v_referencenumbers
GO
GRANT EXECUTE ON  [dbo].[d_refs_CommaFgtParentCmdSource_sp] TO [public]
GO
