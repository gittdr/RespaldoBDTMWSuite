SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[fix_assignment] @mov int 
as
/**
 * 
 * NAME:
 * dbo.fix_assignment 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/

declare @test int, @field varchar(10), @alt varchar(10), @pyd_number int
select @field = 'ASGNUM', @alt = '', @pyd_number=0


/*this code only works for completed trips */
if (select count(*) from legheader
	where mov_number=@mov and lgh_outstatus<>'CMP') = 0
begin
	select 0 asgn_number, lgh_number, 'TRL' asgn_type, evt_trailer1 asgn_id, 'Y' asgn_controlling, 
		min(evt_startdate) asgn_date,  max(evt_enddate) asgn_enddate, min(stp_mfh_sequence) stp_mfh_sequence  
	into #a
	from event, stops
	where stops.stp_number = event.stp_number and mov_number = @mov and evt_trailer1 <> 'UNKNOWN'
		and (select count(*) from assetassignment
			where stops.lgh_number = assetassignment.lgh_number and
				event.evt_trailer1 = asgn_id and 
				asgn_type = 'TRL' ) = 0
	group by stops.lgh_number, evt_trailer1

/*mf 16830	while (select count(*) from #a
		where asgn_number=0) > 0 
	begin
		begin tran
		execute @test = getsystemnumber @field, @alt
		commit tran

		set rowcount 1 
		update #a
		set asgn_number = @test
		where asgn_number=0
		set rowcount 0
	end*/

	insert assetassignment (lgh_number,  asgn_type, asgn_id,       asgn_date,
				asgn_eventnumber, asgn_controlling, asgn_status, asgn_dispdate,
				asgn_enddate, asgn_dispmethod, mov_number, pyd_status, actg_type, evt_number)
	select lgh_number,  asgn_type, asgn_id,       asgn_date,
		null asgn_eventnumber, asgn_controlling, 'CMP' asgn_status, convert(datetime,null) asgn_dispdate,
		asgn_enddate, null asgn_dispmethod, @mov  mov_number,
		'NPD' pyd_status,  trl_actg_type actg_type, (select min(evt_number) 
								from stops,event
								where stops.mov_number= @mov and
									stops.stp_number = event.stp_number and
									stops.stp_mfh_sequence = #a.stp_mfh_sequence) evt_number
	from #a, trailerprofile
	where trailerprofile.trl_number = #a.asgn_id
	order by asgn_type, asgn_id, lgh_number

	drop table #a
end
GO
GRANT EXECUTE ON  [dbo].[fix_assignment] TO [public]
GO
