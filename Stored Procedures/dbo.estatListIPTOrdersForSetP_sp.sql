SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatListIPTOrdersForSetP_sp]
-- 7/8/08: reworked to handle split trips (ie use lgh_outstatus ord_status) 
-- If @login, @usercompany and @group are all supplied, @login is used. 
-- If both @usercompany and @group are all supplied, @usercompany is used. 
-- If @login is supplied:
-- 	It returns: orders whose consignee is an @login profile company (if @direction = I) 
-- 	            orders whose shipper is an @login profile company (if @direction <> I) 
-- If @group is supplied:
-- 	It returns: orders whose consignee is in that group (if @direction = I) 
-- 	            orders whose shipper is in that group (if @direction <> I)    
@login Varchar(200), 
@UserCompanyID Varchar(200), 

@group varchar(6), 
----- @EarlyordSchedStartDt	datetime, @LateordSchedStartDt	datetime,	
@orderstatus	Varchar(6),   --  normally blank; use NC to prevent CMP orders from being returned.         
@direction         char(1)    --  I: (Inbound) O: (Outbound)	
AS
SET NOCOUNT ON

create table #temp2 (compid varchar(8) not null)  

-- Make list of user's estat profile companies 5/7/08
create table #temp3 (estatusercmpid varchar(8) not null) 
Insert into #temp3 select cmp_id from ESTATUSERCOMPANIES where login = @login 

Create table #order (
    Priority varchar(6),
	[Est Arrival] datetime,
	Trip# int,  
	IPT# varchar(30) NULL,  --IPT number (freight detail ref num)
	Trailer varchar(13) NULL,  -- 2/5/07
	[From] varchar(8) NULL,
        --ShipperName varchar(100),		
	--ShipperAddress varchar(100) NULL, ShipperZip varchar(10) NULL,
	--OriginCity varchar(18), ST char(6),		
	--StartDate datetime,
	[To] varchar(8) NULL,	
	--ConsigneeName varchar(100),		
	--ConsigneeAddress varchar(100) NULL, ConsigneeZip varchar(10) NULL,
	--DestinationCity varchar(18), DestST char(6),		
	comm varchar(8) NULL, -- commodity
	driver varchar(8) NULL, 
	status varchar(6) NULL
   	)

if  @login <> ''     --5/7/08
begin      
	insert into #order (trip#)  select 
	orderheader.ord_hdrnumber from orderheader, legheader  
	where 	      
	(
		(ord_consignee in (select estatusercmpid from #temp3)  and @direction = 'I')   or  
		(ord_shipper in (select estatusercmpid from #temp3)  and @direction <> 'I')		 	
	 )	
    	 and
	( lgh_outstatus  IN ('AVL', 'PLN', 'DSP') 		    
      and legheader.ord_hdrnumber = orderheader.ord_hdrnumber    
      and cmp_id_end = ord_consignee 
	)		 
end 
else
begin
	if  @UserCompanyID <> ''
	begin      
		insert into #order (trip#)  
		select 	orderheader.ord_hdrnumber from orderheader, legheader    
		where 	      
		(
			(ord_consignee = @UserCompanyID and @direction = 'I')   or
			(ord_shipper = @UserCompanyID and @direction <> 'I')			
		 )		
    		 and
		( lgh_outstatus  IN ('AVL', 'PLN', 'DSP') 		      
		and legheader.ord_hdrnumber = orderheader.ord_hdrnumber      
        and cmp_id_end = ord_consignee    
		)		
	end 
		else 
		if  @Group <> ''
		begin      
			Insert into #temp2 
			select cmp_id from company where cmp_othertype1 = @Group 
			insert into #order (trip#)  
			select 	orderheader.ord_hdrnumber  from orderheader, legheader   
			where 	      
			(
				(ord_consignee in (select compid from #temp2) and @direction = 'I') or
				(ord_shipper in (select compid from #temp2) and @direction <> 'I') 		
			 )
	   			 and
			(	
			lgh_outstatus  IN ('AVL', 'PLN', 'DSP') 		     
			and legheader.ord_hdrnumber = orderheader.ord_hdrnumber   
            and cmp_id_end = ord_consignee          
			)	 
		end 
end
update #order set 
	priority = ord_priority, 
	[Est Arrival] = ord_completiondate,
	ipt# = '',
	trailer = replace (ord_trailer,'UNKNOWN',''), 
	[from] = ord_shipper,                
	[to] = ord_consignee, 			
	comm = orderheader.cmd_code, 	--7/08/08
	driver = replace (ord_driver1,'UNKNOWN',''),
    status =  ord_status     	
    from orderheader where ord_hdrnumber = trip#

--- for each order in the temp table, get the IPT number 
update #order set ipt# =  ref_number 
	from referencenumber, freightdetail, stops 
	where ref_type = 'IPT'
	and ref_table = 'freightdetail'
	and freightdetail.fgt_number = referencenumber.ref_tablekey
	and freightdetail.stp_number = stops.stp_number
	and stops.ord_hdrnumber = trip#	
	and stops.stp_event = 'HPL'
	
If @direction = 'I' Select * from #order order by [to], [from], trip#
else Select * from #order order by [from], [to], trip# 
Drop Table #order
Drop Table #temp2
Drop Table #temp3
GO
GRANT EXECUTE ON  [dbo].[estatListIPTOrdersForSetP_sp] TO [public]
GO
