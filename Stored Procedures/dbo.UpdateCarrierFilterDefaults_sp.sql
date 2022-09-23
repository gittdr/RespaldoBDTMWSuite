SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[UpdateCarrierFilterDefaults_sp] @userid varchar (10)
as

--declare @userid varchar (10)
--set @userid = 'q2003'


delete from carrierfilterlist
where cfl_userid = @userid
and upper(cfl_default) <> 'Y'


declare @caf_car_type1_def char(1), 
	@caf_car_type2_def char(1), 
	@caf_car_type3_def char(1), 
	@caf_car_type4_def char(1), 
	@caf_liability_limit_def char(1), 
	@caf_cargo_limit_def char(1), 
	@caf_rate_def char(1), 
	@caf_lane_def char(1), 
	@caf_orig_state_def char(1), 
	@caf_orig_city_def char(1), 
	@caf_dest_state_def char(1), 
	@caf_dest_city_def char(1), 
	@caf_ins_cert_def char(1), 
	@caf_w9_def char(1), 
	@caf_contract_def char(1), 
	@caf_service_rating_def char(1), 
	@caf_carrier_def char(1), 
	@caf_history_only_def char(1)


select @caf_car_type1_def = caf_car_type1_def,
	@caf_car_type2_def = caf_car_type2_def,
	@caf_car_type3_def = caf_car_type3_def,
	@caf_car_type4_def = caf_car_type4_def,
	@caf_liability_limit_def = caf_liability_limit_def,
	@caf_cargo_limit_def = caf_cargo_limit_def,
	@caf_rate_def = caf_rate_def,
	@caf_lane_def = caf_lane_def,
	@caf_orig_state_def = caf_orig_state_def,
	@caf_orig_city_def = caf_orig_city_def,
	@caf_dest_state_def = caf_dest_state_def,
	@caf_dest_city_def = caf_dest_city_def,
	@caf_ins_cert_def = caf_ins_cert_def,
	@caf_w9_def = caf_w9_def,
	@caf_contract_def = caf_contract_def,
	@caf_service_rating_def = caf_service_rating_def,
	@caf_carrier_def = caf_carrier_def,
	@caf_history_only_def = caf_history_only_def
from carrierfilter 
where caf_userid = @userid

if @caf_car_type1_def = 'N'
	update carrierfilter
	set caf_car_type1 = ''
	where caf_userid = @userid

if @caf_car_type2_def = 'N'
	update carrierfilter
	set caf_car_type2 = ''
	where caf_userid = @userid

if @caf_car_type3_def = 'N'
	update carrierfilter
	set caf_car_type3 = ''
	where caf_userid = @userid

if @caf_car_type4_def = 'N'
	update carrierfilter
	set caf_car_type4 = ''
	where caf_userid = @userid

if @caf_liability_limit_def = 'N'
	update carrierfilter
	set caf_liability_limit = 0
	where caf_userid = @userid

if @caf_cargo_limit_def = 'N'
	update carrierfilter
	set caf_cargo_limit = 0
	where caf_userid = @userid

if @caf_rate_def = 'N'
	update carrierfilter
	set caf_rate = 'N'
	where caf_userid = @userid

if @caf_lane_def = 'N'
	update carrierfilter
	set caf_lane = 'N'
	where caf_userid = @userid

if @caf_orig_state_def = 'N'
	update carrierfilter
	set caf_orig_state = 'N'
	where caf_userid = @userid

if @caf_orig_city_def = 'N'
	update carrierfilter
	set caf_orig_city = 'N'
	where caf_userid = @userid

if @caf_dest_state_def = 'N'
	update carrierfilter
	set caf_dest_state = 'N'
	where caf_userid = @userid

if @caf_dest_city_def = 'N'
	update carrierfilter
	set caf_dest_city = 'N'
	where caf_userid = @userid

if @caf_ins_cert_def = 'N'
	update carrierfilter
	set caf_ins_cert = 'N'
	where caf_userid = @userid

if @caf_w9_def = 'N'
	update carrierfilter
	set caf_w9 = 'N'
	where caf_userid = @userid

if @caf_contract_def = 'N'
	update carrierfilter
	set caf_contract = 'N'
	where caf_userid = @userid

if @caf_service_rating_def = 'N'
	update carrierfilter
	set caf_service_rating = ''
	where caf_userid = @userid

if @caf_carrier_def = 'N'
	update carrierfilter
	set caf_carrier = ''
	where caf_userid = @userid

if @caf_history_only_def = 'N'
	update carrierfilter
	set caf_history_only = 'N'
	where caf_userid = @userid
GO
GRANT EXECUTE ON  [dbo].[UpdateCarrierFilterDefaults_sp] TO [public]
GO
