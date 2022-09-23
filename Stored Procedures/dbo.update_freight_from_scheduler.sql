SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[update_freight_from_scheduler] (@pi_new_mov int, @pi_sch_masterid int)
AS

/**
 * 
 * NAME:
 * dbo.update_freight_from_scheduler
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure will copy the commodity counts from the previous order based on a given schedule provided there is one.
 *
 *PARAMETERS:
 * 001 - @pi_new_mov, int
 *       This parameter indicates the mov_number to update
 * 002 - @pi_sch_masterid, int
 *       This parameter indicates the master schedule id to find the last order of
 *
 * REVISION HISTORY:
 * 04/10/2007.01 ? PTS35449 - Jason Bauwin ? Original
 *
 **/

declare @ll_last_mov_number int
declare @last_move Table( 
						  last_id		int identity(1,1),
						  stp_number	int,
                          cmp_id		varchar(8),
						  stp_city		int,
						  ord_hdrnumber int
						)
declare @new_move Table( 
						  new_id		int identity(1,1),
						  stp_number	int,
                          cmp_id		varchar(8),
						  stp_city		int,
						  ord_hdrnumber int
						)

select @ll_last_mov_number = mov_number
  from orderheader
 where ord_fromschedule = @pi_sch_masterid
   and ord_startdate = (select max(ord_startdate)
                          from orderheader
                         where ord_fromschedule = @pi_sch_masterid
                           and mov_number <> @pi_new_mov
						   and ord_completiondate <= (select min(ord_startdate)
                                                        from orderheader
                                                       where mov_number = @pi_new_mov))

if isnull(@ll_last_mov_number, -1) > 0
begin
	insert into @last_move(stp_number, cmp_id, stp_city, ord_hdrnumber)
    select stp_number, cmp_id, stp_city, ord_hdrnumber
      from stops
     where mov_number = @ll_last_mov_number
       and ord_hdrnumber > 0
       and stp_type in ('PUP', 'DRP')
     order by stp_mfh_sequence

	insert into @new_move(stp_number, cmp_id, stp_city, ord_hdrnumber)
	select stp_number, cmp_id, stp_city, ord_hdrnumber
	  from stops
	 where mov_number = @pi_new_mov
       and ord_hdrnumber > 0
	   and stp_type in ('PUP', 'DRP')
     order by stp_mfh_sequence

	if (select count(*) from @last_move) <> (select count(*) from @last_move)
    begin
		RETURN
	end

	update freightdetail
	   set freightdetail.fgt_count = fgt_old.fgt_count
--	select freightdetail.fgt_count, fgt_old.fgt_count
	  from freightdetail, freightdetail fgt_old, @new_move stops_new, @last_move stops_old, orderheader ord_new, orderheader ord_old
	 where freightdetail.fgt_sequence = fgt_old.fgt_sequence
	   and stops_new.new_id = stops_old.last_id
       and freightdetail.stp_number = stops_new.stp_number
       and fgt_old.stp_number = stops_old.stp_number
	   and stops_new.cmp_id = stops_old.cmp_id
	   and stops_new.stp_city = stops_old.stp_city
       and stops_new.ord_hdrnumber = ord_new.ord_hdrnumber
       and stops_old.ord_hdrnumber = ord_old.ord_hdrnumber
	   and ord_new.ord_fromorder = ord_old.ord_fromorder

end

GO
GRANT EXECUTE ON  [dbo].[update_freight_from_scheduler] TO [public]
GO
