SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[refnumverticallist_sp] @p_maxrows int, @p_table1 varchar(50),@p_key1 int, @p_type1 varchar(6),
  @p_table2 varchar(50), @p_key2 int, @p_type2 varchar(6), @p_withtypes char(1)
as


/**
 * 
 * NAME:
 * dbo.refnumverticallist_sp
 *
 * TYPE:
 * [StoredProcedure]
 *
 * DESCRIPTION:
 * This procedure returns the specified number of reference numbers from up to two tables
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * referencenumberdisplay
 *
 * PARAMETERS:
 * 001 - @p_maxrows the maximum number of ref numbers to return
 * 002 - @p_table1 the first table to which the ref numbers are attached
 * 003- @p_key1 the tablekey value for the first table
 * 005 - @p_type1 the ref_type to search for (can use % wildcard)
 * 006 - @p_table2 the first table to which the ref numbers are attached
 * 007- @p_key2 the tablekey value for the first table
 * 008 - @p_type2 the ref_type to search for (can use % wildcard)
 * 009 - @p_withtypes 'Y' to return types with ref number
 * 
 *
 * REFERENCES: (NONE)

 * 
 * REVISION HISTORY:
 * 01/16/08 DPETE PTS 39496 add for invoice forma 130
 **/



declare @refs table ( refnum varchar(50))

set rowcount  @p_maxrows

insert into @refs
SELECT (case @p_withtypes when 'Y' then ref_type +': ' else '' end) +ref_number
from referencenumber
where ref_table = @p_table1
and ref_tablekey = @p_key1
and ref_type like @p_type1

insert into @refs
SELECT (case @p_withtypes when 'Y' then ref_type +': ' else '' end) +ref_number
from referencenumber
where ref_table = @p_table2
and ref_tablekey = @p_key2
and ref_type like @p_type2


set rowcount @p_maxrows

select refnum from @refs
GO
GRANT EXECUTE ON  [dbo].[refnumverticallist_sp] TO [public]
GO
