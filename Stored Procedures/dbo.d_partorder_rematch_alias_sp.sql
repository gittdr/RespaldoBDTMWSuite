SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[d_partorder_rematch_alias_sp] (@branch varchar(12), @alias varchar(20))
as

/**
 * 
 * NAME:
 * d_partorder_rematch_alias_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Finds all partorder for a given alias and resets the supplier to the appropriate TMWSuite Company ID.
 * In addition, the procedure calls the timeline matching routine for each partorder.
 *
 * RETURNS:
 * dw result set
 *
 * PARAMETERS:
 * 001 - @branch varchar(12) - branch id
 * 002 - @alias varchar(20) - 
 * 
 * REVISION HISTORY:
 * CGK	PTS# 31196	createsd
 *
 **/

create table #poh (
		poh_identity INT NULL
		)

declare @poh_identity as integer, @last_poh_identity as integer, @record_count as integer
declare @poh_supplier as varchar (8)

select @poh_identity = 0
select @record_count = 0

SELECT @poh_supplier = ca.ca_id
FROM company alias
INNER JOIN company_alternates ca ON alias.cmp_id = ca.ca_alt
INNER JOIN company verify ON ca.ca_id = verify.cmp_id
WHERE alias.cmp_revtype1 = @branch
AND alias.cmp_altid = @alias 

IF IsNull (@poh_supplier, '') = ''
	select -1 as return_code, Cast('Alias ' + @alias + ' is not associated with a TMW Suite Company.  Please Associate and try again.' as varchar (255)) as return_message
else
Begin
	INSERT INTO #poh (poh_identity)
	select poh_identity
	from partorder_header
	where poh_branch = @branch
	and poh_supplieralias = @alias
	and poh_supplier = 'UNKNOWN'

	select @poh_identity = 0
	select @last_poh_identity = 0
	
	WHILE 1=1
	Begin
		select @poh_identity = min (poh_identity)
		from #poh
		where poh_identity > @poh_identity

		IF IsNull (@poh_identity, 0) = 0 
			Break
		Else Begin
			select @record_count = @record_count + 1
			UPDATE partorder_header 
			SET poh_supplier = @poh_supplier
			WHERE poh_identity = @poh_identity
			
			exec timeline_match_sp @poh_identity
			
			select @last_poh_identity = @poh_identity
		End


	End
	select @record_count as return_code, Cast ('Complete with No Errors. ' + Cast (@record_count as varchar (20)) + ' record(s) updated.'  as varchar (255)) as return_message
End




GO
GRANT EXECUTE ON  [dbo].[d_partorder_rematch_alias_sp] TO [public]
GO
