SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[serviceexceptionreport_sp](	@pl_from datetime,@pl_to datetime)
/*	@ps_asgn_type char(3),@ps_asgn_id varchar(13),
	@ps_shipperflag char(1),@ps_consignee_flag char(1),
	@ps_noaction_flag char(1),@ps_order_number varchar(12),
	@ps_teamleader varchar(6),@ps_region varchar(6))*/ 
AS
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/26/2007.01 ? PTS40189 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/
create table #temp (mov_number int not null,
					stp_number int not null,
					sxn_sequence_number int not null,					
					asgn_type  char(3) not null,
					asgn_id    varchar(13) not null,
					sxn_createdby varchar(20) not null,
					sxn_createddate datetime not null,
					sxn_expcode varchar(6) not null,
					sxn_expdate datetime not null,
					sxn_actioncode varchar(6) null,
					sxn_affectspay char(1) null,
					ord_number varchar(12) null,
					sxn_description varchar(255) null,
					sxn_action_description varchar(255) null,
					shipper_flag char(1) null,
					consignee_flag char(1) null,
					mpp_teamleader varchar(6) null,
					shipper_region1  varchar(6) null,
					shipper_region2  varchar(6) null,
					shipper_region3  varchar(6) null,
					shipper_region4  varchar(6) null,
					stp_event varchar(50) null,
					-- RE -5/13/03 - PTS #17410   
					sxn_delete_flag char(1) null,
					sxn_cmp_id varchar(8) null)

	create index dk_resource on #temp (asgn_type,asgn_id)
	create index dk_order on #temp (ord_number,stp_number)

		
  Insert into #temp(mov_number,
					stp_number,
					sxn_sequence_number,					
					asgn_type,
					asgn_id,
					sxn_createdby,
					sxn_createddate,
					sxn_expcode,
					sxn_expdate,
					sxn_actioncode,
					sxn_affectspay,	
					ord_number,
					sxn_description,
					sxn_action_description,
					-- RE -5/13/03 - PTS #17410   
					sxn_delete_flag,
					sxn_cmp_id)

(  SELECT 	 serviceexception.sxn_mov_number,
			 serviceexception.sxn_stp_number,
			 serviceexception.sxn_sequence_number,
			 serviceexception.sxn_asgn_type,   
	         serviceexception.sxn_asgn_id,   
			 serviceexception.sxn_createdby,
			 serviceexception.sxn_createddate,
	         serviceexception.sxn_expcode,   
	         serviceexception.sxn_expdate,   
			 serviceexception.sxn_actioncode,				
	         serviceexception.sxn_affectspay,   
			 orderheader.ord_number  ,
	         serviceexception.sxn_description,   
	         serviceexception.sxn_action_description,
			 -- RE -5/13/03 - PTS #17410   
			 ISNULL(serviceexception.sxn_delete_flag, 'N'),
			serviceexception.sxn_cmp_id
    FROM 	serviceexception LEFT OUTER JOIN orderheader ON serviceexception.sxn_ord_hdrnumber = orderheader.ord_hdrnumber
   WHERE 	serviceexception.sxn_expdate between @pl_from and @pl_to )  --pts40189 outer join conversion




	update #temp 
	set    #temp.mpp_teamleader = manpowerprofile.mpp_teamleader 
	from   manpowerprofile 
	where  asgn_type = 'DRV' and
		   asgn_id = mpp_id


	update  #temp
	set		shipper_flag = 'Y' 
	from 	orderheader a-- RE - 5/13/03 - PTS #17410, stops b
	where	#temp.ord_number = a.ord_number and
			-- RE - 5/13/03 - PTS #17410a.ord_hdrnumber  = b.ord_hdrnumber and
			-- RE - 5/13/03 - PTS #17410#temp.stp_number = b.stp_number and
			a.ord_shipper    = #temp.sxn_cmp_id -- RE - 5/13/03 - PTS #17410b.cmp_id	



	update  #temp
	set		consignee_flag = 'Y' 
	from 	orderheader a-- RE - 5/13/03 - PTS #17410, stops b
	where	#temp.ord_number = a.ord_number and
			-- RE - 5/13/03 - PTS #17410a.ord_hdrnumber  = b.ord_hdrnumber and
			-- RE - 5/13/03 - PTS #17410#temp.stp_number = b.stp_number and
			a.ord_consignee  = #temp.sxn_cmp_id


	update #temp
	 set 	shipper_region1 = cty_region1,
			shipper_region2 = cty_region2,					
			shipper_region3 = cty_region3,
			shipper_region4 = cty_region4
	from 	orderheader a, stops b,city c,company d
	where	#temp.ord_number = a.ord_number and
			-- RE - 5/13/03 - PTS #17410a.ord_hdrnumber  = b.ord_hdrnumber and
			-- RE - 5/13/03 - PTS #17410#temp.stp_number = b.stp_number and
			a.ord_shipper    = #temp.sxn_cmp_id	and
			a.ord_shipper	 = d.cmp_id and 
			d.cmp_city 		 = c.cty_code		



-- RE - 5/13/03 - PTS #17410	update #temp 
-- RE - 5/13/03 - PTS #17410	set    stp_event = eventcodetable.name
-- RE - 5/13/03 - PTS #17410	from   stops,eventcodetable
-- RE - 5/13/03 - PTS #17410	where  #temp.stp_number = stops.stp_number and
-- RE - 5/13/03 - PTS #17410			stops.stp_event = eventcodetable.abbr


/*
	update #temp 
	set    shipper_flag = 'Y' 
	from   orderheader
	where  #temp.ord_number = orderheader.ord_number and
			#temp.asgn_type = 'CMP' and
			#temp.asgn_id = ord_shipper

			
	update #temp 
	set    consignee_flag = 'Y' 
	from   orderheader
	where  #temp.ord_number = orderheader.ord_number and
			#temp.asgn_type = 'CMP' and
			#temp.asgn_id = ord_consignee




	update #temp set 	shipper_region1 = cty_region1,
						shipper_region2 = cty_region2,					
						shipper_region3 = cty_region3,
						shipper_region4 = cty_region4
			from 		company,city
			where 		asgn_type = 'CMP' and
						asgn_id = cmp_id  and
						cmp_city = cty_code and
						#temp.shipper_flag = 'Y'
							
*/			
select * from #temp

GO
GRANT EXECUTE ON  [dbo].[serviceexceptionreport_sp] TO [public]
GO
