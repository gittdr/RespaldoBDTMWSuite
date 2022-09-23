SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_dispatch_dashboard    Script Date: 6/1/99 11:54:45 AM ******/
create procedure [dbo].[d_dispatch_dashboard] (@inboundview_id 		varchar(6),
													@outboundview_id 		varchar(6),
													@user_id					varchar(20),
													@expiration_tolerence int)
												

as
declare 	@inbound_trips 			int,
			@outbound_trips			int,
			@days_out					int,
			@pri1_drv_expirations 	int,
			@key_expirations 	int,
			@prihigh_messages			int,			
			@prilow_messages			int,
			@eta_late30					int,
			@eta_late90					int,
			@eta_reallate				int,
			@today						datetime
			
select @today = getdate()

                        
SELECT DISTINCT
	legheader.lgh_number, 
	legheader.mov_number, 
	legheader.lgh_primary_trailer, 
	legheader.lgh_etaalert1,
	legheader.lgh_etamins1,
	legheader.lgh_outstatus,
	legheader.lgh_instatus,
	event.evt_driver1, 
	event.evt_driver2, 
	event.evt_tractor, 
	event.evt_carrier, 
	dispatchview.dv_id,
	"OB" view_type
into #mighty_table
FROM city city_a, 
	company company_a, 
	event, 
	legheader, 
	orderheader, 
	manpowerprofile, 
	tractorprofile, 
	trailerprofile, 
	city city_b, 
	company company_b, 
	stops,
	dispatchview 
WHERE ( legheader.cmp_id_start = company_a.cmp_id ) and
 		( legheader.cmp_id_end = company_b.cmp_id ) and 
		( legheader.lgh_startcity = city_a.cty_code ) and 
		( legheader.lgh_endcity = city_b.cty_code ) and 
		( stops.stp_number = event.stp_number ) and
 		( stops.lgh_number = legheader.lgh_number ) and 
		( manpowerprofile.mpp_id = event.evt_driver1 ) and
 		( tractorprofile.trc_number = event.evt_tractor ) and
 		( trailerprofile.trl_id = legheader.lgh_primary_trailer ) and 
		( orderheader.ord_hdrnumber = legheader.ord_hdrnumber ) and 
		( legheader.lgh_outstatus in ('STD','AVL','PND','DIS','PLN')) AND 
		( dv_id = @outboundview_id) AND
 		( dv_lgh_type1 like '%'+orderheader.ord_revtype1+'%' OR dv_lgh_type1 = '') AND
 		( dv_lgh_type2 like '%'+orderheader.ord_revtype2+'%' OR dv_lgh_type2 = '') AND
 		( dv_lgh_type3 like '%'+orderheader.ord_revtype3+'%' OR dv_lgh_type3 = '') AND
 		( dv_lgh_type4 like '%'+orderheader.ord_revtype4+'%' OR dv_lgh_type4 = '') AND
 		( dv_mpp_type1 like '%'+manpowerprofile.mpp_type1+'%' OR dv_mpp_type1 = '') AND
 		( dv_mpp_type2 like '%'+manpowerprofile.mpp_type2+'%' OR dv_mpp_type2 = '') AND
 		( dv_mpp_type3 like '%'+manpowerprofile.mpp_type3+'%' OR dv_mpp_type3 = '') AND
 		( dv_mpp_type4 like '%'+manpowerprofile.mpp_type4+'%' OR dv_mpp_type4 = '') AND 
		( dv_teamleader like '%'+manpowerprofile.mpp_teamleader+'%' OR dv_teamleader = '') AND
 		( dv_domicile like '%'+manpowerprofile.mpp_domicile+'%' OR dv_domicile = '') AND 
		( dv_trc_type1 like '%'+tractorprofile.trc_type1+'%' OR dv_trc_type1 = '') AND
 		( dv_trc_type2 like '%'+tractorprofile.trc_type2+'%' OR dv_trc_type2 = '') AND
 		( dv_trc_type3 like '%'+tractorprofile.trc_type3+'%' OR dv_trc_type3 = '') AND
 		( dv_trc_type4 like '%'+tractorprofile.trc_type4+'%' OR dv_trc_type4 = '') AND 
		( dv_fleet like '%'+tractorprofile.trc_fleet+'%' OR dv_fleet = '') AND 
		( dv_division like '%'+tractorprofile.trc_division+'%' OR dv_division = '') AND
 		( dv_company like '%'+tractorprofile.trc_company+'%' OR dv_company = '') AND
 		( dv_terminal like '%'+tractorprofile.trc_terminal+'%' OR dv_terminal = '') AND 
		( dv_states like '%'+city_a.cty_state+'%' OR dv_states = '') AND
 		( dv_cmp_id like '%'+cmp_id_start+'%' OR dv_cmp_id = '') AND
 		( dv_region1 = city_a.cty_region1 OR dv_region1 = 'UNK' ) AND
 		( dv_region2 = city_a.cty_region2 OR dv_region2 = 'UNK' ) AND 
		( dv_region3  = city_a.cty_region3 OR dv_region3 = 'UNK' ) AND 
		( dv_region4 = city_a.cty_region4 OR  dv_region4 = 'UNK' ) AND 
		( dv_city = city_a.cty_code OR dv_city = 0 ) AND 
		( dv_driver = event.evt_driver1 OR dv_driver = 'UNKNOWN' ) AND
 		( dv_tractor = event.evt_tractor OR dv_tractor = 'UNKNOWN' ) AND
 		( legheader.lgh_startdate >= dateadd ( hour, -dv_hours_back, getdate() ) AND 
		legheader.lgh_startdate <= dateadd ( hour, dv_hours_out, getdate() ) )
                 
UNION SELECT DISTINCT
	legheader.lgh_number, 
	legheader.mov_number, 
	legheader.lgh_primary_trailer, 
	legheader.lgh_etaalert1,
	legheader.lgh_etamins1,
	legheader.lgh_outstatus,
	legheader.lgh_instatus,
	event.evt_driver1, 
	event.evt_driver2, 
	event.evt_tractor, 
	event.evt_carrier, 
	inbnd.dv_id,
	"IB" view_type
FROM city city_a, 
	company company_a, 
	event, 
	legheader, 
	orderheader, 
	manpowerprofile, 
	tractorprofile, 
	trailerprofile, 
	city city_b, 
	company company_b, 
	stops,
	dispatchview inbnd
WHERE ( legheader.cmp_id_start = company_a.cmp_id ) and
 		( legheader.cmp_id_end = company_b.cmp_id ) and 
		( legheader.lgh_startcity = city_a.cty_code ) and 
		( legheader.lgh_endcity = city_b.cty_code ) and 
		( stops.stp_number = event.stp_number ) and
 		( stops.lgh_number = legheader.lgh_number ) and 
		( manpowerprofile.mpp_id = event.evt_driver1 ) and
 		( tractorprofile.trc_number = event.evt_tractor ) and
 		( trailerprofile.trl_id = legheader.lgh_primary_trailer ) and 
		( orderheader.ord_hdrnumber = legheader.ord_hdrnumber ) and 
		(legheader.lgh_instatus <> "HST") AND ( inbnd.dv_id = @inboundview_id) AND
 		( inbnd.dv_lgh_type1 like '%'+orderheader.ord_revtype1+'%' OR inbnd.dv_lgh_type1 = '') AND
 		( inbnd.dv_lgh_type2 like '%'+orderheader.ord_revtype2+'%' OR inbnd.dv_lgh_type2 = '') AND
 		( inbnd.dv_lgh_type3 like '%'+orderheader.ord_revtype3+'%' OR inbnd.dv_lgh_type3 = '') AND
 		( inbnd.dv_lgh_type4 like '%'+orderheader.ord_revtype4+'%' OR inbnd.dv_lgh_type4 = '') AND
 		( inbnd.dv_mpp_type1 like '%'+manpowerprofile.mpp_type1+'%' OR inbnd.dv_mpp_type1 = '') AND
 		( inbnd.dv_mpp_type2 like '%'+manpowerprofile.mpp_type2+'%' OR inbnd.dv_mpp_type2 = '') AND
 		( inbnd.dv_mpp_type3 like '%'+manpowerprofile.mpp_type3+'%' OR inbnd.dv_mpp_type3 = '') AND
 		( inbnd.dv_mpp_type4 like '%'+manpowerprofile.mpp_type4+'%' OR inbnd.dv_mpp_type4 = '') AND 
		( inbnd.dv_teamleader like '%'+manpowerprofile.mpp_teamleader+'%' OR inbnd.dv_teamleader = '') AND
 		( inbnd.dv_domicile like '%'+manpowerprofile.mpp_domicile+'%' OR inbnd.dv_domicile = '') AND 
		( inbnd.dv_trc_type1 like '%'+tractorprofile.trc_type1+'%' OR inbnd.dv_trc_type1 = '') AND
 		( inbnd.dv_trc_type2 like '%'+tractorprofile.trc_type2+'%' OR inbnd.dv_trc_type2 = '') AND
 		( inbnd.dv_trc_type3 like '%'+tractorprofile.trc_type3+'%' OR inbnd.dv_trc_type3 = '') AND
 		( inbnd.dv_trc_type4 like '%'+tractorprofile.trc_type4+'%' OR inbnd.dv_trc_type4 = '') AND 
		( inbnd.dv_fleet like '%'+tractorprofile.trc_fleet+'%' OR inbnd.dv_fleet = '') AND 
		( inbnd.dv_division like '%'+tractorprofile.trc_division+'%' OR inbnd.dv_division = '') AND
 		( inbnd.dv_company like '%'+tractorprofile.trc_company+'%' OR inbnd.dv_company = '') AND
 		( inbnd.dv_terminal like '%'+tractorprofile.trc_terminal+'%' OR inbnd.dv_terminal = '') AND 
		( inbnd.dv_states like '%'+city_a.cty_state+'%' OR inbnd.dv_states = '') AND
 		( inbnd.dv_cmp_id like '%'+cmp_id_start+'%' OR inbnd.dv_cmp_id = '') AND
 		( inbnd.dv_region1 = city_a.cty_region1 OR inbnd.dv_region1 = 'UNK' ) AND
 		( inbnd.dv_region2 = city_a.cty_region2 OR inbnd.dv_region2 = 'UNK' ) AND 
		( inbnd.dv_region3  = city_a.cty_region3 OR inbnd.dv_region3 = 'UNK' ) AND 
		( inbnd.dv_region4 = city_a.cty_region4 OR  inbnd.dv_region4 = 'UNK' ) AND 
		( inbnd.dv_city = city_a.cty_code OR inbnd.dv_city = 0 ) AND 
		( inbnd.dv_driver = event.evt_driver1 OR inbnd.dv_driver = 'UNKNOWN' ) AND
 		( inbnd.dv_tractor = event.evt_tractor OR inbnd.dv_tractor = 'UNKNOWN' ) AND
 		( legheader.lgh_startdate >= dateadd ( hour, -inbnd.dv_hours_back, getdate() ) AND 
		legheader.lgh_startdate <= dateadd ( hour, inbnd.dv_hours_out, getdate() ) )




                         
select 
	@inbound_trips = count(*)
from #mighty_table
where dv_id = @inboundview_id 

                        
select 
	@outbound_trips = count(*)
from #mighty_table
where dv_id = @outboundview_id AND
		lgh_outstatus <>'STD'

                                                      
select 
	@pri1_drv_expirations = count(*) 
from #mighty_table, expiration
where (expiration.exp_idtype = "DRV") and
		(expiration.exp_id in (#mighty_table.evt_driver1, #mighty_table.evt_driver2)) and
		(expiration.exp_completed = "N") and
		(expiration.exp_expirationdate <= @today) and
		(expiration.exp_code not in ("HOME", "KEY"))


if (@pri1_drv_expirations = 0)
	begin
		select 
			@pri1_drv_expirations = count(*) 
		from #mighty_table, expiration
		where (expiration.exp_idtype = "DRV") and
				(expiration.exp_id in (#mighty_table.evt_driver1, #mighty_table.evt_driver2)) and
				(expiration.exp_completed = "N") and
				(datediff(day, @today, expiration.exp_expirationdate) <= @expiration_tolerence) and
				(expiration.exp_code not in ("HOME", "KEY"))

	
	   if (@pri1_drv_expirations > 0) 
			select @pri1_drv_expirations = 2
		else
			select @pri1_drv_expirations = 0
	end 
else
	select @pri1_drv_expirations  = 1


                                
select 
	@key_expirations = count(*) 
from #mighty_table, expiration
where (expiration.exp_idtype = "DRV") and
		(expiration.exp_id in (#mighty_table.evt_driver1, #mighty_table.evt_driver2)) and
		(expiration.exp_completed = "N") and
		(expiration.exp_expirationdate <= @today) and
		(expiration.exp_priority  = "9")

if (@key_expirations = 0)
	begin
		select 
			@key_expirations = count(*) 
		from #mighty_table, expiration
		where (expiration.exp_idtype = "DRV") and
				(expiration.exp_id in (#mighty_table.evt_driver1, #mighty_table.evt_driver2)) and
				(expiration.exp_completed = "N") and
				(datediff(day, @today,expiration.exp_expirationdate) <= @expiration_tolerence)and
				(expiration.exp_priority  = "9")

	
	   if (@key_expirations > 0) 
			select @key_expirations = 2
		else
			select @key_expirations = 0

	end 
else
	select @key_expirations = 1

                   
select 
	@days_out = count(*) 
from #mighty_table, expiration
where (expiration.exp_idtype = "DRV") and
		(expiration.exp_id in (#mighty_table.evt_driver1, #mighty_table.evt_driver2)) and
		(expiration.exp_completed = "N") and
		(expiration.exp_code = "HOME") and
		(expiration.exp_expirationdate <= @today)

if (@days_out = 0)
	begin
		select 
			@days_out = count(*) 
		from #mighty_table, expiration
		where (expiration.exp_idtype = "DRV") and
				(expiration.exp_id in (#mighty_table.evt_driver1, #mighty_table.evt_driver2)) and
				(expiration.exp_completed = "N") and
				(expiration.exp_code =  "HOME") and
				(datediff(day,  @today,expiration.exp_expirationdate) <= @expiration_tolerence)
	
	   if (@days_out > 0) 
			select @days_out = 2
		else
			select @days_out = 0
	end 
else
	select @days_out = 1




                    

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
                             
SELECT 	@prihigh_messages	=   (SELECT count(*)  
											FROM MCMESSAGE  
						   				WHERE ( MCMESSAGE.MCM_SEQUENCE = 1 ) AND  
         										( MCMESSAGE.MCM_STATUS = 'T' ) AND  
         										( MCMESSAGE.MCM_RECIPIENTIDTYPE = 'USER' ) AND  
         										( MCMESSAGE.MCM_RECIPIENTID = @user_id ) AND  
										         ( MCMESSAGE.MCM_PRIORITY = 'HIGH' )  )
	
SELECT 	@prilow_messages	=   (SELECT count(*)  
											FROM MCMESSAGE  
						   				WHERE ( MCMESSAGE.MCM_SEQUENCE = 1 ) AND  
         										( MCMESSAGE.MCM_STATUS = 'T' ) AND  
         										( MCMESSAGE.MCM_RECIPIENTIDTYPE = 'USER' ) AND  
         										( MCMESSAGE.MCM_RECIPIENTID = @user_id ) AND  
										         ( MCMESSAGE.MCM_PRIORITY <> 'HIGH' )   )


               
select  @eta_late30 = count(distinct lgh_number)
from #mighty_table
where lgh_outstatus ='STD' AND
		lgh_etaalert1 = "Y" and
		lgh_etamins1 between 1 and 30 
										
select distinct @eta_late90 = count(distinct lgh_number)
from #mighty_table
where lgh_outstatus = 'STD' AND 
		lgh_etaalert1 = "Y" and
		lgh_etamins1 between 31 and 90 
										
select distinct @eta_reallate = count(distinct lgh_number)
from #mighty_table
where lgh_outstatus  = 'STD' AND
		lgh_etaalert1 = "Y" and
		lgh_etamins1 > 90 
										

select @inbound_trips Inbound, 
		@outbound_trips Outbound,
		@days_out DaysOut,
		@prihigh_messages High, 
		@prilow_messages Low,
		@pri1_drv_expirations Priority1, 
		@key_expirations KeyDates,
		@inboundview_id InboundView,
		@outboundview_id OutboundView,
		@eta_late30		ETA30	,		
		@eta_late90		ETA90,
		@eta_reallate	ETAREALLATE


return



GO
GRANT EXECUTE ON  [dbo].[d_dispatch_dashboard] TO [public]
GO
