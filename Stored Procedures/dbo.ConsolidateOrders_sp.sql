SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ConsolidateOrders_sp] (
	@targetord		varchar(14),
	@orders			varchar(100)
	--@error			integer	OUTPUT,
	--@errmsg			varchar(1000) OUTPUT
)

as 

/*
*
*	PTS 43913 - DJM - Created to provide basic consolidation functionality.
*
*/

Declare	@targetmov	int,
	@sourceord		int,
	@sourcemov		int,
	@currord		varchar(15),
	@lastseq		int,
	@targetleg		int,
	@currhdr		int,
	@minseq			int,
	@error			integer	,
	@errmsg			varchar(1000),
	@sourceleg		int

-- Get the movement onto which to consolidate the other order(s)
select @targetmov = mov_number from orderheader where ord_number = @targetord
select @targetleg = min(lgh_number) from legheader where mov_number = @targetmov


-- Get the movement of the source order
select @sourcemov = mov_number from orderheader where ord_number = @currord

Create table #ordlist(
	ord_number	varchar(15),
	seq			int,
	ord_hdrnumber		int,
	lgh_number		int)

Create Table #stpseq(
	stp_number		int,
	ord_hdrnumber	int,
	stp_arrivaldate		datetime,
	stp_mfh_seq			int,
	seq				int identity)


--Populate the table using the function to parse a comma separated variable.
INSERT #ordlist(ord_number, seq) 
SELECT * FROM CSVStringsToTable_fn_seq(@orders) WHERE value NOT IN ('','%','%%')  
select @lastseq = 0

update #ordlist
set ord_hdrnumber = o.ord_hdrnumber
from orderheader o join #ordlist ol on o.ord_number = ol.ord_number

update #ordlist
set lgh_number = legheader.lgh_number
from legheader
where legheader.ord_hdrnumber = #ordlist.ord_hdrnumber

select @currord = ord_number,
	@currhdr = ord_hdrnumber,
    @sourceleg = lgh_number 
from #ordlist where seq = (select min(seq) from #ordlist where seq > @lastseq)

-- Begin a new transaction so we can roll back within the proc if necessary.
Begin tran c1;

	while @currhdr > 0
		begin
			
			update stops
			set lgh_number = @targetleg,
				mov_number = @targetmov
			where ord_hdrnumber = @currhdr
			
			if @@error <>  0 
				Goto rback;

			update orderheader
			set mov_number = @targetmov
			where ord_hdrnumber = @currhdr			
			if @@error <>  0 
				Goto rback;

			-- PTS 45011 - Remove the original Legheader records.
			delete from legheader
               where lgh_number = @sourceleg
            if @@error <> 0
                    Goto rback;
                       
			select @lastseq = seq from #ordlist where ord_number = @currord

			select @minseq = isNull(min(ol1.seq),0) from #ordlist ol1 where ol1.seq > @lastseq
			if @minseq = 0
				select @currhdr = 0
			else
				select @currord = isNull(ord_number,''),
					@currhdr = isNull(ord_hdrnumber,0),
                    @sourceleg = IsNull(lgh_number,0)
				from #ordlist where seq = (select isNull(min(ol1.seq),99999) from #ordlist ol1 where ol1.seq > @lastseq)

		end
	Goto weregood;

	rback:	
		Rollback tran c1;
		select @error = @@error
		Return
	
	weregood:
	/* Create the table			*/
	insert #stpseq (stp_number, ord_hdrnumber, stp_arrivaldate)
	select s.stp_number,
		s.ord_hdrnumber,
		s.stp_arrivaldate
	from stops s
	where s.mov_number = @targetmov
	order by s.stp_arrivaldate, s.ord_hdrnumber
	if @@error <> 0
		Begin
			rollback tran c1;
			select @error = @@error
			return
		end

	update stops
	set stops.stp_mfh_sequence = ss.seq
	from #stpseq ss inner join stops on stops.stp_number = ss.stp_number
	if @@error <> 0
		Begin
			rollback tran c1;
			select @error = @@error
			return
		end

	exec update_move @targetmov
	if @@error <> 0
		Begin
			rollback tran c1;
			select @error = @@error
			return
		end

commit tran c1;


GO
GRANT EXECUTE ON  [dbo].[ConsolidateOrders_sp] TO [public]
GO
