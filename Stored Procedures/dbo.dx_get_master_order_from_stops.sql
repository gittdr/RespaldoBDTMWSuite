SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[dx_get_master_order_from_stops]
	@ord_company varchar(8),
	@ord_billto varchar(8),
	@ord_stopids varchar(100),
	@@ord_number varchar(12) OUTPUT

as

select @ord_company = case when rtrim(isnull(@ord_company,'')) in ('','UNKNOWN') then 'UNKNOWN' else rtrim(@ord_company) end
     , @ord_billto = rtrim(isnull(@ord_billto,''))

if @ord_company = 'UNKNOWN' or @ord_billto = 'UNKNOWN'  --wasn't matched
	return -1

declare @edi_stops table
	(ord int DEFAULT (1),
	 seq int IDENTITY,
	 cmp_id varchar(8),
	 PRIMARY KEY (seq, cmp_id))

declare @mst_stops table
	(ord int,
	 ident int IDENTITY,
	 cmp_id varchar(8))

declare @all_stops table
	(ord int,
	 seq int,
	 cmp_id varchar(8))

declare @count int, @index int, @ord_hdrnumber int, @stopids varchar(100), @minident int

select @index = 0, @stopids = rtrim(@ord_stopids), @@ord_number = ''

while 1=1
begin
	select @index = charindex(',', @stopids)
	if @index = 0
	begin
		insert @edi_stops (cmp_id)
			values (@stopids)
		break
	end
	else
	begin
		insert @edi_stops (cmp_id)
			select left(@stopids, @index - 1)
		select @stopids = right(@stopids, len(@stopids) - @index)
	end
end

select @count = count(1) from @edi_stops

select @ord_hdrnumber = 0

while 1=1
begin
	if @ord_billto = ''
		select @ord_hdrnumber = min(ord_hdrnumber)
		  from orderheader
		 where ord_hdrnumber > @ord_hdrnumber
		   and ord_company = @ord_company
		   and ord_status = 'MST'
	else
		select @ord_hdrnumber = min(ord_hdrnumber)
		  from orderheader
		 where ord_hdrnumber > @ord_hdrnumber
		   and ord_billto = @ord_billto
		   and ord_status = 'MST'

	if @ord_hdrnumber is null break

	delete from @mst_stops

	insert @mst_stops (ord, cmp_id)
	select ord_hdrnumber, cmp_id from stops
	 where ord_hdrnumber = @ord_hdrnumber
	   and (stp_type IN ('PUP','DRP') or stp_event IN ('BCST','NBCST','IBMT','IEMT'))
	 order by stp_mfh_sequence

	if @@rowcount > 0	  
	begin
		select @minident = min(ident) from @mst_stops
		insert @all_stops (ord, seq, cmp_id)
		select ord, ident - @minident + 1, cmp_id
		  from @mst_stops
		 order by ident
	end
end

select @ord_hdrnumber = 0

select @ord_hdrnumber = (select top 1 allstops.ord from @all_stops allstops
  left join @edi_stops edi
    on allstops.seq = edi.seq
   and allstops.cmp_id = edi.cmp_id
 group by allstops.ord
 having count(edi.ord) = @count
    and count(allstops.ord) = @count
 order by allstops.ord desc)

if isnull(@ord_hdrnumber, 0) > 0
	select @@ord_number = ord_number from orderheader where ord_hdrnumber = @ord_hdrnumber
else
	return -1

return 1


GO
GRANT EXECUTE ON  [dbo].[dx_get_master_order_from_stops] TO [public]
GO
