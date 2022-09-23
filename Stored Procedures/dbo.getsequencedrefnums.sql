SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  create procedure [dbo].[getsequencedrefnums](@ref_table varchar(50),@ref_tablekey int,
      @showtypes char(1),@sequencedreftypescsv varchar(100),@returnonlysequenced char(1),
      @excludereftypescsv varchar(100),@maxcount int)
as 
/* use this proc to get a return set of the ref numbers from any table and want some
   of the refs in a particular sequence on the return set and/or want some ref types
   excluded

arguments
   @ref_table 'orderheader' or 'invoiceheader' or 'stops' etc
   @ref_tablekey  key to table
   @showtypes  Y to include the ref type code as part of the return set
   @sequencedreftypescsv comma separated list of the ref types in the sequence they are to appear
           EG  'BOL,PO,REF'
   @returnonlysequenced 'Y' to return only the types in the list, N returns all others after
            the ones included in the @sequencedreftypescsv
   @excludereftypes is a comma sep list of any ref types to be excluded
   @maxcount set iimit of number of records to return, 0 means return all

Examples
   To rerun all order header refs
*/
declare @refs table (
    ref_number varchar(40) null,
    passedseq int null
)

declare @seqrefs table (ref_type varchar(6),seq int)
declare @omitrefs table (ref_type varchar(6))

If @maxcount = 0 select @maxcount = 999999

INSERT @omitrefs(ref_type )
SELECT * FROM CSVStringsToTable_fn(@excludereftypescsv) where value <> 'UNK'


INSERT @seqrefs(ref_type ,seq )
SELECT * FROM CSVStringsToTable_fn_seq(@sequencedreftypescsv) where value <> 'UNK'

If @returnonlysequenced = 'Y'
    insert into @refs
    select (case @showtypes
       when 'Y' then rt.ref_type + ' '
       else ''
    end) + rt.ref_number,
    srefs.seq
    from referencenumber rt
    join @seqrefs srefs on rt.ref_type = srefs.ref_type
    where rt.ref_table = @ref_table
    and rt.ref_tablekey = @ref_tablekey
    and not exists (select 1 from @omitrefs omit where omit.ref_type = rt.ref_type)
else

    insert into @refs
    select (case @showtypes
       when 'Y' then rt.ref_type + ' '
       else ''
    end) + rt.ref_number,
    case isnull(srefs.seq,0)
       when 0 then 1000 + ref_sequence
       else srefs.seq
       end
    from referencenumber rt
    left outer join  @seqrefs srefs on rt.ref_type = srefs.ref_type
    where rt.ref_table = @ref_table
    and rt.ref_tablekey = @ref_tablekey
    and not exists (select 1 from @omitrefs omit where omit.ref_type = rt.ref_type)
    order by (case isnull(srefs.seq,-99) when -99 then rt.ref_sequence else srefs.seq end)

set rowcount  @maxcount  -- limit rows returned

   select ref_number
   from @refs
   order by passedseq

GO
GRANT EXECUTE ON  [dbo].[getsequencedrefnums] TO [public]
GO
