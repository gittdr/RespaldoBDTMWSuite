SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatGetIPLTOrdFromPlant_sp] 	@login  varchar(200)
-- Programming note: when testing uses status  = PLN istead of PND
-- Given a company id: return the ordernumbers of all orders  
-- to which that trailer is assigned, if the orders have status of PENDING. 
-- Return zero if no such order found.
-- estatGetIPLTOrdFromPlant_sp '01'
as 
SET NOCOUNT ON

Begin
	create table #temp3 (estatusercmpid varchar(8) not null) 
	Insert into #temp3 select cmp_id from ESTATUSERCOMPANIES where login = @login 


	declare @count as int	
	create table #result (ord_hdrnumber int null, ord_trailer varchar(13) null, 
        fromcompany varchar(100), tocompany varchar(100), [time] datetime, 
	iptnumber varchar(30), [description] varchar(60))
	
	insert into #result (ord_hdrnumber)
		select ord_hdrnumber
		  from orderheader
			where ord_shipper in (select estatusercmpid from #temp3) 
		  --where Replace (orderheader.ord_shipper,',', '') = Replace (@comp_id, ',', '') 
		  and orderheader.ord_status IN ('PND')	 --PND   
	
	select @count = count (*) from #result
	--IF @count <= 0 Begin
		--insert into #result (ord_hdrnumber) values (0)
	--End
	--else
if @count > 0
	begin
        	--update #result set ord_trailer = @trl_number
		update #result set ord_trailer = isnull(orderheader.ord_trailer,'') from orderheader 
                  	where orderheader.ord_hdrnumber = #result.ord_hdrnumber
	
		update #result set iptnumber = ref_number 
	        from referencenumber, freightdetail, stops 
		where ref_type = 'IPT' 	and ref_table = 'freightdetail'
		and referencenumber.ord_hdrnumber = #result.ord_hdrnumber
		and freightdetail.fgt_number = referencenumber.ref_tablekey
		and freightdetail.stp_number = stops.stp_number		
		and stops.stp_event = 'HPL'
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
	select ord_hdrnumber, ord_trailer, fromcompany, tocompany, [time], iptnumber, [description] from #result
End
drop table #temp3
GO
GRANT EXECUTE ON  [dbo].[estatGetIPLTOrdFromPlant_sp] TO [public]
GO
