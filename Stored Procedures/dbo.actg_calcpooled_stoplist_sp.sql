SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[actg_calcpooled_stoplist_sp]
	@p_ord_hdrnumber as integer,
	@p_tkr_drop_stop as varchar (6),
	@p_tkr_pickup_stop as varchar (6),
	@p_tkr_eventcode as varchar (6),
	@p_tkr_event_loadstatus as varchar (6)
as
set nocount on 

--First Drop
If @p_tkr_drop_stop = 'FD' 
Begin
	Insert into actg_temp_tempstoplist (sp_id, ord_hdrnumber, stp_number, lgh_number, evt_sequence)
	select @@spid, ord_hdrnumber, stp_number, lgh_number, evt_sequence
	from actg_temp_orderstops
	where sp_id = @@spid 
	and stp_type = 'DRP'
	and evt_sequence = 1
	and ord_hdrnumber = @p_ord_hdrnumber
	and stp_sequence IN (select min (stp_sequence) from actg_temp_orderstops where sp_id = @@spid and stp_type = 'DRP' and evt_sequence = 1 and ord_hdrnumber = @p_ord_hdrnumber)
	
End

--Last Drop
If @p_tkr_drop_stop = 'LD' 
Begin
	Insert into actg_temp_tempstoplist (sp_id, ord_hdrnumber, stp_number, lgh_number, evt_sequence)
	select @@spid, ord_hdrnumber, stp_number, lgh_number, evt_sequence
	from actg_temp_orderstops
	where sp_id = @@spid
	and stp_type = 'DRP'
	and evt_sequence = 1
	and ord_hdrnumber = @p_ord_hdrnumber
	and stp_sequence IN (select max (stp_sequence) from actg_temp_orderstops WHERE sp_id = @@spid and stp_type = 'DRP' and evt_sequence = 1 and ord_hdrnumber = @p_ord_hdrnumber)
End

--Everthing But First Drop
If @p_tkr_drop_stop = 'EBFD' 
Begin
	Insert into actg_temp_tempstoplist (sp_id, ord_hdrnumber, stp_number, lgh_number, evt_sequence)
	select @@spid, ord_hdrnumber, stp_number, lgh_number, evt_sequence
	from actg_temp_orderstops
	where sp_id = @@spid 
	and stp_type = 'DRP'
	and evt_sequence = 1
	and ord_hdrnumber = @p_ord_hdrnumber
	and stp_sequence NOT IN (select min (stp_sequence) from actg_temp_orderstops WHERE sp_id = @@spid and stp_type = 'DRP' and evt_sequence = 1 and ord_hdrnumber = @p_ord_hdrnumber)
End

--Everthing But Last Drop
If @p_tkr_drop_stop = 'EBLD' 
Begin
	Insert into actg_temp_tempstoplist (sp_id, ord_hdrnumber, stp_number, lgh_number, evt_sequence)
	select @@spid, ord_hdrnumber, stp_number, lgh_number, evt_sequence
	from actg_temp_orderstops
	where sp_id = @@spid 
	and stp_type = 'DRP'
	and evt_sequence = 1
	and ord_hdrnumber = @p_ord_hdrnumber
	and stp_sequence NOT IN (select max (stp_sequence) from actg_temp_orderstops WHERE sp_id = @@spid and stp_type = 'DRP' and ord_hdrnumber = @p_ord_hdrnumber)

End

--Everthing But First and Last Drop
If @p_tkr_drop_stop = 'EBFLD' 
Begin
	Insert into actg_temp_tempstoplist (sp_id, ord_hdrnumber, stp_number, lgh_number, evt_sequence)
	select @@spid, a.ord_hdrnumber, a.stp_number, a.lgh_number, a.evt_sequence
	from 
		(select ord_hdrnumber, stp_number, lgh_number, evt_sequence
		from actg_temp_orderstops
		where sp_id = @@spid 
		and stp_type = 'DRP'
		and evt_sequence = 1
		and ord_hdrnumber = @p_ord_hdrnumber
		and stp_sequence NOT IN (select max (stp_sequence) from actg_temp_orderstops WHERE sp_id = @@spid and stp_type = 'DRP' and evt_sequence = 1 and ord_hdrnumber = @p_ord_hdrnumber)) a,
		(select ord_hdrnumber, stp_number, lgh_number, evt_sequence
		from actg_temp_orderstops
		where sp_id = @@spid 
		and stp_type = 'DRP'
		and evt_sequence = 1
		and ord_hdrnumber = @p_ord_hdrnumber
		and stp_sequence NOT IN (select min (stp_sequence) from actg_temp_orderstops WHERE sp_id = @@spid and stp_type = 'DRP' and evt_sequence = 1 and ord_hdrnumber = @p_ord_hdrnumber)) b
	where a.stp_number = b.stp_number
	
End



--First Pickup
If @p_tkr_pickup_stop = 'FP' 
Begin
	Insert into actg_temp_tempstoplist (sp_id, ord_hdrnumber, stp_number, lgh_number, evt_sequence)
	select @@spid, ord_hdrnumber, stp_number, lgh_number, evt_sequence
	from actg_temp_orderstops
	where sp_id = @@spid 
	and stp_type = 'PUP'
	and evt_sequence = 1
	and ord_hdrnumber = @p_ord_hdrnumber
	and stp_sequence IN (select min (stp_sequence) from actg_temp_orderstops where sp_id = @@spid and stp_type = 'PUP' and evt_sequence = 1 and ord_hdrnumber = @p_ord_hdrnumber)
End

--Last Pickup
If @p_tkr_pickup_stop = 'LP' 
Begin
	Insert into actg_temp_tempstoplist (sp_id, ord_hdrnumber, stp_number, lgh_number, evt_sequence)
	select @@spid, ord_hdrnumber, stp_number, lgh_number, evt_sequence
	from actg_temp_orderstops
	where sp_id = @@spid 
	and stp_type = 'PUP'
	and evt_sequence = 1
	and ord_hdrnumber = @p_ord_hdrnumber
	and stp_sequence IN (select max (stp_sequence) from actg_temp_orderstops WHERE sp_id = @@spid and stp_type = 'PUP' and evt_sequence = 1 and ord_hdrnumber = @p_ord_hdrnumber)
End

--Everthing But First Pickup
If @p_tkr_pickup_stop = 'EBFP' 
Begin
	Insert into actg_temp_tempstoplist (sp_id, ord_hdrnumber, stp_number, lgh_number, evt_sequence)
	select @@spid, ord_hdrnumber, stp_number, lgh_number, evt_sequence
	from actg_temp_orderstops
	where sp_id = @@spid
	and stp_type = 'PUP'
	and evt_sequence = 1
	and ord_hdrnumber = @p_ord_hdrnumber
	and stp_sequence NOT IN (select min (stp_sequence) from actg_temp_orderstops WHERE sp_id = @@spid and stp_type = 'PUP' and evt_sequence = 1 and ord_hdrnumber = @p_ord_hdrnumber)
End

--Everthing But Last Pickup
If @p_tkr_pickup_stop = 'EBLP' 
Begin
	Insert into actg_temp_tempstoplist (sp_id, ord_hdrnumber, stp_number, lgh_number, evt_sequence)
	select @@spid, ord_hdrnumber, stp_number, lgh_number, evt_sequence
	from actg_temp_orderstops
	where sp_id = @@spid 
	and stp_type = 'PUP'
	and evt_sequence = 1
	and ord_hdrnumber = @p_ord_hdrnumber
	and stp_sequence NOT IN (select max (stp_sequence) from actg_temp_orderstops WHERE sp_id = @@spid and stp_type = 'PUP' and evt_sequence = 1 and ord_hdrnumber = @p_ord_hdrnumber)
End

--Everthing But First and Last Pickup
If @p_tkr_pickup_stop = 'EBFLP' 
Begin
	Insert into actg_temp_tempstoplist (sp_id, ord_hdrnumber, stp_number, lgh_number, evt_sequence)
	select @@spid, a.ord_hdrnumber, a.stp_number, a.lgh_number, a.evt_sequence
	from 
		(select ord_hdrnumber, stp_number, lgh_number, evt_sequence
		from actg_temp_orderstops
		where sp_id = @@spid 
		and stp_type = 'PUP'
		and evt_sequence = 1
		and ord_hdrnumber = @p_ord_hdrnumber
		and stp_sequence NOT IN (select max (stp_sequence) from actg_temp_orderstops WHERE sp_id = @@spid and stp_type = 'PUP' and evt_sequence = 1 and ord_hdrnumber = @p_ord_hdrnumber)) a,
		(select ord_hdrnumber, stp_number, lgh_number, evt_sequence
		from actg_temp_orderstops
		where sp_id = @@spid 
		and stp_type = 'PUP'
		and evt_sequence = 1
		and ord_hdrnumber = @p_ord_hdrnumber
		and stp_sequence NOT IN (select min (stp_sequence) from actg_temp_orderstops WHERE sp_id = @@spid and stp_type = 'PUP' and evt_sequence = 1 and ord_hdrnumber = @p_ord_hdrnumber)) b
	where a.stp_number = b.stp_number
	
End

IF (IsNull (@p_tkr_drop_stop, 'UNK') = 'UNK' or @p_tkr_drop_stop = '') AND (IsNull (@p_tkr_pickup_stop, 'UNK') = 'UNK' or @p_tkr_pickup_stop = '') Begin
	Insert into actg_temp_tempstoplist (sp_id, ord_hdrnumber, stp_number, lgh_number, evt_sequence)
	select @@spid, ord_hdrnumber, stp_number, lgh_number, evt_sequence
	from actg_temp_orderstops
	where sp_id = @@spid
	and evt_sequence = 1
End


--Event Code Rule
IF IsNull (@p_tkr_eventcode, 'UNK') <> 'UNK' AND @p_tkr_eventcode <> '' Begin
	IF IsNull (@p_tkr_event_loadstatus, 'UNK') <> 'UNK' AND @p_tkr_event_loadstatus <> '' Begin
		IF @p_tkr_event_loadstatus = 'LD' Begin
			delete from actg_temp_tempstoplist
			where sp_id = @@spid
			and stp_number not in (select o.stp_number 
						 from actg_temp_orderstops o
						 where o.sp_id = @@spid
						 and o.evt_eventcode = @p_tkr_eventcode
						 and o.stp_loadstatus = 'LD'
						 and ord_hdrnumber = @p_ord_hdrnumber)
		End 
		Else Begin
			delete from actg_temp_tempstoplist
			where sp_id = @@spid 
			and stp_number not in (select o.stp_number 
						 from actg_temp_orderstops o
						 where o.sp_id = @@spid
						 and o.evt_eventcode = @p_tkr_eventcode
						 and o.stp_loadstatus <> 'LD'
					 	 and ord_hdrnumber = @p_ord_hdrnumber)			
		End				 
	End
	Else Begin
		delete from actg_temp_tempstoplist
		where sp_id = @@spid 
		and stp_number not in (select o.stp_number 
					 from actg_temp_orderstops o
					 where o.sp_id = @@spid
					 and o.evt_eventcode = @p_tkr_eventcode
					 and ord_hdrnumber = @p_ord_hdrnumber)
	End
End


Insert into actg_temp_stoplist (sp_id, ord_hdrnumber, stp_number, lgh_number, evt_sequence)
select distinct @@spid, ord_hdrnumber, stp_number, lgh_number, evt_sequence from actg_temp_tempstoplist 
where sp_id = @@spid and lgh_number NOT IN (select lgh_number from actg_temp_excludedlegs where sp_id = @@spid) /*PTS 32559 CGK 6/19/2006*/

GO
GRANT EXECUTE ON  [dbo].[actg_calcpooled_stoplist_sp] TO [public]
GO
