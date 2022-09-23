SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PWConsolidation_movement_ident_sp](	@movlist varchar(1000) , @leglist varchar(1000), @mastermov int OUT, @ps_returnmsg varchar(255) OUT)
	as
	/**
		PTS 78125 - DJM
			- determine the MOvement that should be the 'Master' in a list of Movements/Legs on a consolidation
			- Designed to be customized by the client. Should NOT apply itself to the database if it's already there.

	**/

	create table #moves (mov_number int, seq int)

	insert into #moves select * from CSVStringsToTable_fn_seq(@movlist)

	select  @mastermov = mov_number from #moves where seq = 1

	select @ps_returnmsg = '' 
GO
GRANT EXECUTE ON  [dbo].[PWConsolidation_movement_ident_sp] TO [public]
GO
