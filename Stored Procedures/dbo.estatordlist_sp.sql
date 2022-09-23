SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- 9/21/07: 39533: FIX: Filtering by shipper not working - bug introduced by 37812 
-- 6/11/07: 37812: enable restrict by orderby
--3/23/05: sr 27193: template ids: 
--1/13/05: pts 26118: stopsalso function should support multiple companies 
--2/26/04: 21547: complete rewrite 
--2/14/04: sr21616: ability to use return ref numbers of a spcific type. 
--                   also return ord_hdrnumber
--4/21/03: SR 18065: shipment tracking: stops only - location drop-down
--Produces Summary List for estat Shipment Tracking module 
--This proc is essentially the same as estatordlist2_sp, except this proc: handles the case where
--user represents multiple companies (in his estat profile).
--If supplied with a reference number type and location (freightdetail etc.) it returns that 
--reference number for each order. If not supplied with reftype and location, returns the 
--ref number and type on the orderheader.      
Create procedure [dbo].[estatordlist_sp]
	@UserCompanyID Varchar(8), 
	@login varchar (132) ,   -- 40655
	@EarlyordSchedStartDt	datetime,
	@LateordSchedStartDt	datetime,	
	@orderstatus	Varchar(6), 
-- These company IDs represent the companies, if any, selected from the 
-- pwtr.asp dropdown lists, for filtering the orders.
-- Note that the sql logic involving these fields is easier to comprehend if you keep in  
-- mind that: due to logic in pwtr.asp: when @uo = 'A' then all 3 of the fields can come 
-- into play. But if @uo = e.g. 'S' (shipper) then only the consigneID and billtoID can 
-- come into play. (Because pwtr.asp does not display the Shipper dropdown list.)    
	@shipperID   	Varchar(8), 
	@consigneeID 	Varchar(8),
        @BillToID       Varchar(8),	
	@sortby         char(1),    -- O: ordernumber (dflt), R: refnumber, 
                                    -- S: startdate, F: finishdate	
--StopsAlso: means: after obtaining all orders that satisfy the regular parms criteria
--(shipper, status etc.) look for any additional orders on which @UserCompanyID 
-- or the user's additional companies occur as a stop even though they might not 
-- occur as a shipper, consignee, billto or orderby 
	@StopsAlso          char(1),    -- S: return orders on which company is merely 
                                        --a stop (even if not shipper etc.) 
--StopOnlyID: means return only orders that have this company as a stop, regarless of 
--whether the company occurs as shipper, billto, orderby or consignee. DO apply the 
--other parms criteria.   
 	@StopsOnlyID     Varchar(8),  -- sr 18065
--@uo:  = 'A' (AlL) means orders are not being limited to those on which the user's company 
--           is a billto, orderby or shipper.
--      = 'S' (Shipper), B (Billto) C (Consignee); example: if S then orders are restricted
--          to those on which the shipper is = one of the user's multiple companies      
        @uo              char(1),  --ktk 1/26/04    
        @refkind         varchar(16), -- 21616 2/13/04   stops, orderheader or freightdetail 
        @reftype         varchar(6),   --21616 2/13/04  
        @revtype3        varchar(6),  -- 22379 4/14/04
        @revtype4        varchar(6),  -- 22379 4/14/04
-- special ref type. if supplied it means user wants proc to also return a ref number of 
-- this type in addition to the primary order ref number. This ref num is generally not 
-- considered to be a ref num in the usual sense, but a ref num having special meaning for estat.  
-- (e.g. template id)
        @reftype2        varchar(6),   -- 27193
--@doconly: if supplied: indicates that only orders that have this type of document attached
--to them should be returned 
	@doconly        varchar(6) 	--30505
AS
SET NOCOUNT ON

Declare @edate	datetime,
	@ldate	datetime	
--set transaction isolation level read uncommitted  --pts 14619JD removed
if (@orderstatus='ALL' or @orderstatus='' or @orderstatus=NULL ) 
	begin
		Select @orderstatus = ''
	end

create table #temp2 (webusercmpid varchar(8) not null) --JD 
Insert into #temp2
select cmp_id from webusercompanies where login = @login --JD

Select @edate = @EarlyordSchedStartDt 
Select @ldate = @LateordSchedStartDt	

--Declare @inttemp int,             27193 never used
--	@neardate	datetime    27193 never used 

Create table #order (
	OrderNumber char(12), 
        ordHdrNumber int,  --21616
	BookDt datetime,
	OrderStatus varchar(6),
	refnumber varchar(30) NULL,  -- 29308
	reftype varchar(6) NULL,
	MoveNumber int NULL,  -- 4 ??
	ShipperID varchar(8) NULL,
        ShipperName varchar(100),		-- 29298
	ShipperAddress varchar(100) NULL,  	-- 29298
	ShipperZip varchar(10) NULL,
	OriginCity varchar(24),			-- 39046
	ST char(6),		
	StartDate datetime,
	ConsigneeID varchar(8) NULL,	
	ConsigneeName varchar(100),		-- 29298
	ConsigneeAddress varchar(100) NULL,	-- 29298
	ConsigneeZip varchar(10) NULL,
	DestinationCity varchar(24),		-- 39046
	DestST char(6),		
        BillToID varchar(8) NULL,
        BillToName varchar(100),		-- 29298
	BillToAddress varchar(100) NULL,	-- 29298
	BillToZip varchar(10) NULL,
	BillToCity varchar(24),			-- 39046
	BillToST char(6),
	FinishDate datetime,
        charge money,
        revtype3 varchar(6),    -- 22379 
        revtype4 varchar(6),  -- 22379
        refnum2 varchar(30) null, --27193   -- 29308
 	trlnumber1 varchar(13)) -- 31222

-- if stopsalso not active then (this is the typical case)
If @stopsalso <> 'S'
begin
	insert into #order
	Select 	ord_number, 	
	ord_hdrnumber, 	-- 21616
	ord_bookdate, 		
	ord_status,       	
	'', --ord_refnum,  21616
	'', --ord_reftype,  21616
	orderheader.mov_number,  
	ord_shipper, 		
        company_a.cmp_name, 	
	company_a.cmp_address1,	
	company_a.cmp_zip,	
	city_a.cty_name,		
	city_a.cty_state, 	
	ord_startdate,           
	ord_consignee, 		
	company_b.cmp_name, 	
	company_b.cmp_address1, 	
	company_b.cmp_zip,	
	city_b.cty_name,		
	city_b.cty_state, 	
        ord_billto,            
        company_c.cmp_name,      
	company_c.cmp_address1,  
	company_c.cmp_zip,	
	city_c.cty_name,		
	city_c.cty_state, 	
	ord_completiondate,
        isnull(ord_charge,0),
        ord_revtype3,	-- 22379
        ord_revtype4,    -- 22379
        '',               -- refnum2 27193
        ''                -- trlnumber1 31222 
  	from 
		orderheader, 
		Company company_a, Company company_b, Company company_c, 
		city city_a, city city_b, city city_c
	where 
	      
	(-- the user must be somewhere on the order	
		ord_shipper in (select webusercmpid from #temp2) or
		ord_company in (select webusercmpid from #temp2) or
		ord_consignee in (select webusercmpid from #temp2) or
		ord_billto in (select webusercmpid from #temp2)
		-- bookedby looks like 'estat-xxxxx' where xxxxx is user's company 27195
                 or 
        	substring(ord_bookedby,7,8) in (select webusercmpid from #temp2)   --27195
	 )
	 and
	(
		ord_startdate >=@edate  and  ord_startdate <=@ldate 	
		and
		city_a.cty_code =ord_origincity and city_b.cty_code =ord_destcity 
		and city_c.cty_code =company_c.cmp_city 
		and
		company_a.cmp_id =ord_shipper and company_B.cmp_id =ord_Consignee 
		and company_c.cmp_id =ord_billto    
         )
    	 and
	(
		 ord_status  <> 'CAN' and ord_status <> 'ICO' -- 30098	
                 and -- order can have any status but cmp and it does   
                 (@orderstatus = 'NC' and ord_status  <> 'CMP') 
		 or -- either the order does not have to have a specific status or it has that specific status 
                 (@orderstatus = '' or ord_status  = @orderstatus) 				
	 )	
	 and    -- restrictions based on pwtr's drop-down lists and the 'user must a bill-to, etc.
                -- type profile options:
         (	-- Either there are no restrictions:
        	(@uo = '' and @shipperID = '' and @consigneeID = '' and @billtoID = '')
		or -- or the order satisfies the restrictions:   
         	(	

			( -- 39533
				      (@uo = 'O' and ord_company in  (select webusercmpid from #temp2)) -- 37812
                                                and (ord_shipper = @shipperID  or @shipperID='') 		-- 39533
				and (ord_consignee = @ConsigneeID or @ConsigneeID='')  	 -- 39533
				and (ord_billto = @billtoID or @billtoID='' )			-- 39533
                                     ) -- 39533
			


                                    or         -- 37812   
 			@uo <> 'O' and  -- 39533
                                    (	-- 39533
			(	-- 37812  	
 			((ord_shipper = @shipperID and @uo <> 'S') -- the shipper drop-down list
				-- user must be a Shipper option 
				or (@uo = 'S' and ord_shipper in (select webusercmpid from #temp2))  
				or @shipperID='')	
			and
			((ord_consignee = @ConsigneeID and @uo <> 'C' ) -- the consignee drop-down list
			-- user must be a Shipper option 
				or (@uo = 'C' and ord_consignee in (select webusercmpid from #temp2))  
				or @ConsigneeID='')
			and
     			((ord_billto = @billtoID and @uo <> 'B' ) 
				or (@uo = 'B' and ord_billto in (select webusercmpid from #temp2))  
				or @billtoID='')
			) -- 37812             
                                    )   -- 39533                      
 	    )
        )
	and 
        (@revtype3 = '' or ord_revtype3 = @revtype3)  --22379
	and
	(@revtype4 = '' or ord_revtype4 = @revtype4)  --22379 

end  
else --@stopsalso = 'S' 
-- Return order if the user is merely a stop (even if user is not a bill-to, shipper etc.)
-- (the only restrictions that apply are status and specific shipper etc.)  
-- Note: due to logic in estat's user profile function: if stopsalso is active 
-- (i.e. @stopsalso = 'S' 
-- then the functions that limit the orders to those on which the user's company is a 
-- billto, etc (see @uo above) CANNOT BE active.  
begin
	insert into #order 
	select distinct a.ord_number, 
	a.ord_hdrnumber, 	--21616
	ord_bookdate, 		
	ord_status,       	
	'', --ord_refnum,  21616
	'', --ord_reftype, 21616
	a.mov_number,  
	ord_shipper, 		
	company_a.cmp_name, 	
	company_a.cmp_address1,	
	company_a.cmp_zip,	
	city_a.cty_name,		
	city_a.cty_state, 	
	ord_startdate,           
	ord_consignee, 		
	company_b.cmp_name, 	
	company_b.cmp_address1, 	
	company_b.cmp_zip,	
	city_b.cty_name,		
	city_b.cty_state, 	
	a.ord_billto,  -- 22890             
	company_c.cmp_name,      
	company_c.cmp_address1,  
	company_c.cmp_zip,	
	city_c.cty_name,		
	city_c.cty_state, 	
	ord_completiondate,
        isnull(ord_charge,0),
        ord_revtype3,	-- 22379
        ord_revtype4,    -- 22379
        '',               -- refnum2 27193 
	''                -- trlnumber1 31222 
	from orderheader a , stops b, legheader, 
	Company company_a, Company company_b, Company company_c, 
	city city_a, city city_b, city city_c
	where a.ord_hdrnumber = b.ord_hdrnumber -- and b.cmp_id = @UserCompanyID 26118
          	-- and (the stop company is one of the user's companies 
                -- or the orderby or billto is one of the user's companies)
                and  
		( (b.cmp_id in (select webusercmpid from #temp2)) -- 26118 
                   or -- 26118
                   -- check for this explicitly because billto or orderby may not be a stop on the order
                   (a.ord_company in (select webusercmpid from #temp2)) --26118
                   or (a.ord_billto in (select webusercmpid from #temp2)) --29474
                ) 
		and not exists (select * from #order c where a.ord_hdrnumber = c.ordernumber)
		and
		a.Mov_Number =legheader.mov_number
		and
		legheader.lgh_startdate>=@edate  and legheader.lgh_startdate<=@ldate 
		and
		city_a.cty_code =ord_origincity and city_b.cty_code =ord_destcity 
		and city_c.cty_code =company_c.cmp_city
		and
		company_a.cmp_id =ord_shipper and company_B.cmp_id =ord_Consignee 
		and company_c.cmp_id = a.ord_billto --22890 ktk
              	and
		(
		 ord_status  <> 'CAN' and ord_status <> 'ICO' -- 30098 	
                 and -- order can have any status but cmp and it does   
                 (@orderstatus = 'NC' and ord_status  <> 'CMP') 
		 or -- either the order does not have to have a specific status or it has that specific status 
                 (@orderstatus = '' or ord_status  = @orderstatus) 				
		 )
		and -- either the order does not have to have a specific shipper or it has that specific shipper  
		(@shipperID='' or ord_shipper = @shipperID   ) 
		and
		(@ConsigneeID='' or ord_consignee = @ConsigneeID  ) 
		and
        	(@BillToID='' or a.ord_billto = @BillToID  ) --22890 ktk
		and 
                (@revtype3 = '' or ord_revtype3 = @revtype3)  --22379
		and
		(@revtype4 = '' or ord_revtype4 = @revtype4)  --22379 

end		
-- If user selected a company from the location dropdown list then apply that restriction:
if @stopsonlyid <> '' 
-- remove any order in which that company does NOT occur on any stop
begin
	Delete from #order
	where ordhdrnumber not in
	(select distinct ordhdrnumber  
	from #order, stops b				
	where ordhdrnumber = b.ord_hdrnumber and b.cmp_id = @stopsonlyid 
	)
end
--30505:
if @doconly <> ''
begin
	Delete from #order
	where ordhdrnumber not in
	(select distinct ord_hdrnumber from web_order_docs			
	where document = @doconly	)
end  
--end 30505
--Pickup reference number
--If a ref num of a specific type is requested
if @reftype <> '' and @refkind <> ''
begin
	update #order set reftype = @reftype  
	if @refkind = 'freightdetail'
	begin
		update #order set refnumber = ref_number
		--from referencenumber, freightdetail, stops, orderheader, #order 4/30/07   38875
		from referencenumber, freightdetail, stops,  #order                   -- 4/30/07 38875
		where ref_type = @reftype and ref_table = @refkind 
		and ref_tablekey = fgt_number
		and freightdetail.stp_number = stops.stp_number
                and stops.ord_hdrnumber = #order.ordhdrnumber 
                and stops.ord_hdrnumber > 0 --5/9/07  38875 
 	end
	else
	begin
		if @refkind = 'stops'
		begin
			update #order set refnumber = ref_number
			--from referencenumber, stops, orderheader, #order  4/30/07   38875 
			from referencenumber, stops,  #order                    -- 4/30/07   38875 
			where ref_type = @reftype and ref_table = @refkind 
			and ref_tablekey = stp_number
	                and stops.ord_hdrnumber = #order.ordhdrnumber 
		and stops.ord_hdrnumber > 0 --5/9/07   38875 
	 	end
		else
		begin
			if @refkind = 'orderheader'
			begin
				update #order set refnumber = ref_number
				--from referencenumber, orderheader, #order 4/30/07   38875 
				from referencenumber,  #order   --  38875
				where ref_type = @reftype and ref_table = @refkind 
				and referencenumber.ord_hdrnumber = #order.ordhdrnumber 
		 	end	
		end
	end
end
-- since no specific reftype requested, return refnum and type from the orderheader 
-- pickup the first ref num (min seq) that is not the special estat ref number:
else
begin
	update #order 
-- 27193        set refnumber = ord_refnum, reftype = ord_reftype     -- 27193
--		from orderheader, #order				-- 27193
--		where ord_hdrnumber = #order.ordhdrnumber		-- 27193 replace with:
	SET	refnumber = ref_number, reftype = ref_type 
		from referencenumber
		where referencenumber.ord_hdrnumber = #order.ordhdrnumber 
		and ref_table = 'orderheader' 
		and ref_sequence = (select min(ref_sequence) from referencenumber 
		where referencenumber.ord_hdrnumber = #order.ordhdrnumber and ref_table = 'orderheader'
                and ref_type <> @reftype2) 
-- end27193 

end

--if caller wants an additional ref number of a specific type
if @reftype2<> ''      
begin
	update #order set	refnum2 = ref_number
	from referencenumber
	where referencenumber.ord_hdrnumber = ordhdrnumber and ref_table = 'orderheader' and ref_type = @reftype2
end
-- 31222
update #order set trlnumber1 = lgh_primary_trailer
 from legheader, stops, #order
 where legheader.lgh_number = stops.lgh_number
 and stops.ord_hdrnumber = #order.ordhdrnumber 
 and stops.ord_hdrnumber > 0  -- 38875 
-- end 31222
If @sortby = 'R' Select * from #order order by refnumber
else if @sortby = 'S'  Select * from #order order by startdate
else if @sortby = 'F'  Select * from #order order by finishdate
else Select * from #order order by ordernumber 
Drop Table #order
Drop Table #temp2
GO
GRANT EXECUTE ON  [dbo].[estatordlist_sp] TO [public]
GO
