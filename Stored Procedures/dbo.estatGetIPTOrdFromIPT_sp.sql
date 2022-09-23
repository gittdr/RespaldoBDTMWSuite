SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatGetIPTOrdFromIPT_sp] 	@IPT_number char(13)
-- Given an IPT number: return the ordernumbers of all orders that have 
-- that IPT number (i.e. freightdetail reference number, if the order 
-- has status of PENDING. Alos returns the trailer assigned to each order.
-- Returns order number = zero, and trailer  = '' if no such order found, 
-- if order has no trailer.
-- Example: exec estatGetIPTOrdFromIPT_sp 'ipt601'
as 
SET NOCOUNT ON

declare @count as int	
	create table #result (ord_hdrnumber int null, ord_trailer varchar(13) null, 
        fromcompany varchar(100), tocompany varchar(100), [time] datetime, 
	iptnumber varchar(30), [description] varchar(60))
	
        -- Return all orders that have the freightdetail ref number 
	insert into #result (ord_hdrnumber)	
        -- distinct here because a given order could have multiple identical 
	-- freightdetail ref num entries: 
	select distinct referencenumber.ord_hdrnumber  
		from referencenumber, orderheader -- 11/01/06 
 	where ref_number = @IPT_number  
	and ref_type = 'IPT' and ref_table = 'freightdetail'
 	and orderheader.ord_hdrnumber = referencenumber.ord_hdrnumber
        and orderheader.ord_status IN ('PND')	--PND

	select @count = count (*) from #result
	IF @count <= 0 
	Begin
		insert into #result (ord_hdrnumber, ord_trailer) values (0, '')
	End	
	else
	begin
		update #result set iptnumber = @IPT_number
		update #result set fromcompany = company.cmp_name from stops, company 
		where company.cmp_id = stops.cmp_id
                and  stops.ord_hdrnumber =  #result.ord_hdrnumber and stp_event = 'HPL'
		update #result set tocompany = company.cmp_name from stops, company 
		where company.cmp_id = stops.cmp_id
                and  stops.ord_hdrnumber =  #result.ord_hdrnumber and stp_event = 'DRL'	
		update #result set [time] = ord_bookdate from orderheader 
		where orderheader.ord_hdrnumber = #result.ord_hdrnumber
		update #result set description = fgt_description 		
	        from stops, freightdetail
		where stops.stp_number = freightdetail.stp_number
		and stops.ord_hdrnumber = #result.ord_hdrnumber
		and stops.stp_event = 'HPL'
	end
	--if order found but it does not have a trailer make trailer blank
        update #result set ord_trailer = isnull(orderheader.ord_trailer,'') from orderheader 
                  where orderheader.ord_hdrnumber = #result.ord_hdrnumber
	
	select ord_hdrnumber, ord_trailer, fromcompany, tocompany, [time], iptnumber, [description]  from #result

GO
GRANT EXECUTE ON  [dbo].[estatGetIPTOrdFromIPT_sp] TO [public]
GO
