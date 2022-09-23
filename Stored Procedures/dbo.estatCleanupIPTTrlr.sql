SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatCleanupIPTTrlr] 	@trl_number char(13),  @newordernumber int
-- sr 35292
-- example: estatCleanupIPTTrlr 'SHT10', 2011 

-- This proc is called when a trailer (@trl_number) has been assigned to a new shipment
-- (@newordernumber) whose first stop is @cmp_id (determined below from the order
-- number). The proc checks for all COMPLETED orders
-- with this trailer that have a DRL stop at @cmp_id, with a secondary event (PUL) that  
-- has not been actualized. It actualizes that event and gives it a date = 
-- the date of the first stop (@cmp_id) on @neworder minus 1 minute.  

-- Here is the typical case that this proc is suppose to address: 2 shipments:
-- Old shipment:        HPL  at company AA  DNE  Since these two primary events 
--                      DRL  at company BB  DNE  are DNE this order is complete.
-- 		        PUL  at company BB  OPN  
--
-- New shipment:        HPL  at company BB  OPN  BB = @cmp_id
-- = @newordernumber    DRL  at company CC  OPN
-- 		        PUL  at company CC  OPN	
-- The purpose of this proc is to make sure that the PUL event at company BB on  
-- the old shipment is DNE before the new shipment starts from that company.
-- Also the date on the old shipments PUL event is set to the date of the new 
-- shipment's HPL event minus one minute. 
as 
SET NOCOUNT ON

Begin
        declare @cmp_id as varchar(8) 
	-- get the id of the company at first stop on the new shipment
	select @cmp_id = (select cmp_id from stops 
		WHERE stops.ord_hdrnumber = @newordernumber
		and stp_mfh_sequence = 1)		

	declare @count as int	
	create table #result (mov_number int null, stp_number int null, evt_number int null )
	
	-- First find all completed orders with this trailer that have a DRL stop at this company 
        -- where the DRL stop has an OPN PUL secondary event.
	insert into #result (mov_number, stp_number, evt_number)
		select orderheader.mov_number, stops.stp_number, evt_number  from orderheader, stops, event     
		  where Replace (orderheader.ord_trailer,',', '') = Replace (@trl_number, ',', '') 
		  and orderheader.ord_status = 'CMP'	
		  and stops.ord_hdrnumber = orderheader.ord_hdrnumber	
                  and stp_event = 'DRL' 
                  and cmp_id = @cmp_id  
                  and event.stp_number = stops.stp_number
                  and evt_eventcode = 'PUL'
		  and evt_status = 'OPN'                   
	
	select @count = count (*) from #result
	IF @count > 0 
	Begin
               	--select * from #result

		declare @evt_number int
		declare @mov_number int
		declare @thedate datetime
		
		-- get the date to be used for the updated event from
                -- the first stop on the new shipment
		select @thedate = (select stp_arrivaldate from stops 
				WHERE stops.ord_hdrnumber = @newordernumber
				and stp_mfh_sequence = 1)
		select @thedate = dateadd(mi,-1,@thedate) 
		
		-- for each order: update the PUL event status
                -- and its date and exec update_move 
		select @evt_number = 0
		select @evt_number = min(evt_number) from #result
		while @evt_number is not NULL
		BEGIN		
			update event set evt_status = 'DNE' 
			where evt_number = @evt_number

                        update event set evt_startdate = @thedate,
			evt_enddate = @thedate, 
			evt_earlydate = @thedate, 
			evt_latedate = @thedate
			where evt_number = @evt_number

                        select @mov_number = mov_number from #result
				where evt_number = @evt_number		
			
			exec update_move @mov_number 
			
			select @evt_number = min(evt_number) from #result
				where evt_number > @evt_number  
		END 

	End
End
GO
GRANT EXECUTE ON  [dbo].[estatCleanupIPTTrlr] TO [public]
GO
