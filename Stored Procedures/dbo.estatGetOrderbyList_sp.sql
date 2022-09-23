SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatGetOrderbyList_sp]
    @weeks integer,  -- 2048
	@login varchar(132),   -- 40655
	@limitcust char(16),
    -- @format:  = ''  returns multi column data tha estat can then reformat per site customization option
    --           = 'rv' returns data in two columns for the report generator dropdowns 
	@format char(16) -- = 'rv' for Report Viewer format 2048 

AS

SET NOCOUNT ON

declare @onemonthback datetime
select @onemonthback = dateadd(ww,-@weeks,getdate()) --2048

create table #temp2 (webusercmpid varchar(8) not null) 
Insert into #temp2
select cmp_id from estatusercompanies where login = @login 

Create table #tt (custid	varchar(8) NULL)

if @limitcust = 'billto' --if customer must be a bill-to
begin
	insert into #tt
	select distinct ord_company as custid
		from orderheader with (index(sk_ord_bookdate))  -- 40530
		where ord_bookdate> @onemonthback and 
		ord_billto in (select webusercmpid from #temp2 )
end
else
begin
	if @limitcust = 'shipper' --if customer must be a shipper
	begin
		insert into #tt
		select distinct ord_company as custid
			from orderheader with (index(sk_ord_bookdate))  -- 40530
			where ord_bookdate> @onemonthback and 
			ord_shipper in (select webusercmpid from #temp2 )

	end
	else
	begin
		if @limitcust = 'consignee' --if customer must be a consignee
		begin
			insert into #tt
			select distinct ord_company as custid
				from orderheader with (index(sk_ord_bookdate))  -- 40530
				where ord_bookdate> @onemonthback and 
				ord_consignee in (select webusercmpid from #temp2 )
		end
		else
		begin
			if @limitcust = 'orderby' 
			begin
			insert into #tt
			select distinct ord_company as custid
				from orderheader with (index(sk_ord_bookdate))  -- 40530
				where ord_bookdate> @onemonthback and 
				ord_company in (select webusercmpid from #temp2 )
			end
			else
				
			begin
				if @limitcust = 'any'  -- If customer can be anybody
				begin
                 insert into #tt
					select distinct ord_company as custid
						from orderheader with (index(sk_ord_bookdate))  
							where ord_bookdate> @onemonthback
				end			
				else -- customer can be a billto, shipper, consignee or orderby
				begin

					Create table #ttx (custid	varchar(8) NULL)
					insert into #ttx
					select distinct ord_company as custid	
						from orderheader with (index(sk_ord_bookdate))  -- 40530
						where ord_bookdate> @onemonthback 
						and
						ord_shipper in (select webusercmpid from #temp2) 	--38875
					insert into #ttx
					select distinct ord_company as custid				--38875
						from orderheader with (index(sk_ord_bookdate))  -- 40530
						where ord_bookdate> @onemonthback 
						and
						 ord_company in (select webusercmpid from #temp2) 
					insert into #ttx
					select distinct ord_company as custid				--38875
						from orderheader with (index(sk_ord_bookdate))  -- 40530
						where ord_bookdate> @onemonthback 
						and
						 ord_consignee in (select webusercmpid from #temp2) 
					insert into #ttx
					select distinct ord_company as custid				--38875
						from orderheader with (index(sk_ord_bookdate))  -- 40530
						where ord_bookdate> @onemonthback 
						and
						 ord_billto in (select webusercmpid from #temp2) 
					
					insert into #tt select distinct custid from #ttx
                    drop table #ttx    						
				end
			end 
		end
	end
end	

if @format = 'rv' -- 2048
select 
distinct  
-- custid cmp_id, 2048
	cmp_name + ' - ' + cty_name + ',' + cty_state cmp_name,   -- 35978 2048
    custid cmp_id -- 2048
	from #tt, company, city   -- 35978
	where cmp_id = custid
	and cmp_city = cty_code   -- 35978
	order by cmp_name -- 5/9/06
else 
-- 1878:
select t.custid as cmp_id, cmp_name, cmp_address1, cty_name, cty_state   from #tt t 
				left join company c on t.custid = c.cmp_id
				left join city ct on c.cmp_city = ct.cty_code
order by cmp_name

drop table #temp2
drop table #tt
GO
GRANT EXECUTE ON  [dbo].[estatGetOrderbyList_sp] TO [public]
GO
