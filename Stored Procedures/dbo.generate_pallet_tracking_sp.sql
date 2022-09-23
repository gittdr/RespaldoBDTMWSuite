SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[generate_pallet_tracking_sp] (@p_mov_number int)
AS

declare @insert_records table (ins_ident int identity(1,1), fgt_number int)
declare @update_records table (upd_ident int identity(1,1), fgt_number int)
declare @counter int, @counter_stop int, @fgt_number int


--create the table var for records that need inserteed
insert into @insert_records (fgt_number)
select fgt_number
  from freightdetail
  join stops on stops.stp_number = freightdetail.stp_number and freightdetail.fgt_sequence = 1 and stops.stp_status = 'DNE'
  where stops.mov_number = @p_mov_number
  and freightdetail.fgt_number not in (select pt_fgt_number 
                                         from pallet_tracking)

--create the table var for records that need updated
insert into @update_records (fgt_number)
select fgt_number
  from freightdetail
  join stops on stops.stp_number = freightdetail.stp_number and freightdetail.fgt_sequence = 1 and stops.stp_status = 'DNE'
  where stops.mov_number = @p_mov_number
  and freightdetail.fgt_number in (select pt_fgt_number 
                                     from pallet_tracking)

--loop thru all the records that need inserted
select @counter = 1
select @counter_stop = count(*) from @insert_records
while @counter <= @counter_stop
begin
  select @fgt_number = fgt_number
    from @insert_records
   where ins_ident = @counter
    insert into pallet_tracking (pt_tractor_number,
                                 pt_trailer_number,
                                 pt_carrier_id,
                                 pt_company_id,
                                 pt_pallets_in,
                                 pt_pallets_out,
                                 pt_hand_count,
                                 pt_pallet_type,
                                 pt_activity_date,
                                 pt_fgt_number,
                                 pt_ord_number,
                                 pt_entry_type)
  select event.evt_tractor,
         event.evt_trailer1,
         event.evt_carrier,
         stops.cmp_id,
         ISNULL(freightdetail.fgt_pallets_in ,0), 
         ISNULL(freightdetail.fgt_pallets_out ,0), 
         0.00,
         ISNULL(freightdetail.fgt_pallet_type,'UNK'),
         stp_arrivaldate,
         @fgt_number,
         orderheader.ord_number,
         CASE RTRIM( LTRIM( legheader.lgh_updateapp ) ) WHEN 'Tmxactui' THEN 'U' ELSE 'O' END
    from freightdetail
    join stops on stops.stp_number = freightdetail.stp_number
    join event on stops.stp_number = event.stp_number and evt_sequence = 1
    join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
    join legheader on legheader.lgh_number = stops.lgh_number
   where freightdetail.fgt_number = @fgt_number
     and stops.ord_hdrnumber > 0
     and (freightdetail.fgt_pallets_in > 0 OR freightdetail.fgt_pallets_out > 0)
   select @counter = @counter + 1
end


--loop thru all the records that need updated
select @counter = 1
select @counter_stop = count(*) from @update_records
while @counter <= @counter_stop
begin
  select @fgt_number = fgt_number
    from @update_records
   where upd_ident = @counter
  /*update any that need updated*/
  update pallet_tracking
     set pt_tractor_number = event.evt_tractor,
         pt_trailer_number = event.evt_trailer1,
         pt_carrier_id = event.evt_carrier,
         pt_company_id = stops.cmp_id,
         pt_pallets_in = ISNULL(freightdetail.fgt_pallets_in ,0),
         pt_pallets_out = ISNULL(freightdetail.fgt_pallets_out ,0), 
         pt_hand_count = 0.00,
         pt_pallet_type = ISNULL(freightdetail.fgt_pallet_type,'UNK'),
         pt_activity_date = stp_arrivaldate,
         pt_fgt_number = @fgt_number,
         pt_ord_number = orderheader.ord_number,
         pt_entry_type = CASE RTRIM( LTRIM( legheader.lgh_updateapp ) ) WHEN 'Tmxactui' THEN 'U' ELSE 'O'END
    from pallet_tracking
    join freightdetail on freightdetail.fgt_number = pallet_tracking.pt_fgt_number
    join stops on stops.stp_number = freightdetail.stp_number
    join event on stops.stp_number = event.stp_number and evt_sequence = 1
    join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
    join legheader on legheader.lgh_number = stops.lgh_number
   where pallet_tracking.pt_fgt_number = @fgt_number
     and stops.ord_hdrnumber > 0
     and (pt_tractor_number <> event.evt_tractor OR 
          pt_tractor_number <> event.evt_tractor OR 
          pt_trailer_number <> event.evt_trailer1 OR 
          pt_carrier_id <> event.evt_carrier OR
          pt_company_id <> stops.cmp_id OR
          pt_pallets_in <> ISNULL(freightdetail.fgt_pallets_in ,0) OR
          pt_pallets_out <> ISNULL(freightdetail.fgt_pallets_out ,0) OR
          pt_pallet_type <> ISNULL(freightdetail.fgt_pallet_type,'UNK') OR
          pt_activity_date <> stp_arrivaldate)   
   /*remove any that were set to 0*/
   delete
     from pallet_tracking
    where pallet_tracking.pt_fgt_number = @fgt_number
      and pt_pallets_in = 0
      and pt_pallets_out = 0
   select @counter = @counter + 1
end


GO
GRANT EXECUTE ON  [dbo].[generate_pallet_tracking_sp] TO [public]
GO
