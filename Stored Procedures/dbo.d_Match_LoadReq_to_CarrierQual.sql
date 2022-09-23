SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


create PROC [dbo].[d_Match_LoadReq_to_CarrierQual] @ASSET_ID varchar(12) 
		
AS 
/**  Proc Created for PTS 46628
 *	 Pulls log file entries back for the 
	 d_laneauction_messagelog dwo on the 
	 summary tab of the lane auction window 
	 w_lane_auction_bid_manager
 *
 **/

set nocount on
declare @Asset_Source varchar(6)
select @Asset_Source = 'CAR'

create table #temp_qualifications (	qual_asset_type varchar(6) null,
									qual_req_type varchar(6) null, 
									qual_id varchar(12) null, 
									qual_source varchar(6) null,
									qual_expire_date datetime null,
									qual_expire_flag varchar(1) null ) 							

insert into #temp_qualifications
select 'CAR', caq_type, caq_carrier_id, 'CAR', caq_expire_date, caq_expire_flag
from carrierqualifications 
where caq_carrier_id = @ASSET_ID 
AND caq_expire_date >= GETDATE()
AND ISNULL(caq_expire_flag, 'N') <> 'Y'

Insert into #temp_qualifications
select 'TRL', ta_type, ta_trailer, ta_source, ta_expire_date , ta_expire_flag
from trlaccessories	
where ta_source = @Asset_Source
and ta_trailer = @ASSET_ID 
AND ta_expire_date >= GETDATE()
AND ISNULL(ta_expire_flag, 'N') <> 'Y'

Insert into #temp_qualifications
select 'TRC', tca_type, tca_tractor , tca_source, tca_expire_date, tca_expire_flag 
from tractoraccesories 
where tca_source = @Asset_Source
and tca_tractor = @ASSET_ID 
AND tca_expire_date >= GETDATE()
AND ISNULL(tca_expire_flag, 'N') <> 'Y'

Insert into #temp_qualifications
select 'DRV', drq_type,  drq_driver, drq_source, drq_expire_date, drq_expire_flag  
from driverqualifications 
where drq_source = @Asset_Source
and drq_driver = @ASSET_ID 
AND drq_expire_date >= GETDATE()
AND ISNULL(drq_expire_flag, 'N') <> 'Y'

select qual_asset_type, qual_req_type, qual_id from #temp_qualifications

GO
GRANT EXECUTE ON  [dbo].[d_Match_LoadReq_to_CarrierQual] TO [public]
GO
