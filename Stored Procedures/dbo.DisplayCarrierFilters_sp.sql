SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


/*   MODIFICATION

PTS 33184 BDH 8/29/2006 Original draft

*/
/*

exec DisplayCarrierFilters_sp 'q2003', 'defaults', 'haz1'

*/


create proc [dbo].[DisplayCarrierFilters_sp] @user_id varchar(20), @defaults varchar(10), @caf_viewid varchar(6) 
as
declare @string varchar (2000),
	@abbr varchar(20),
	@def varchar(20),
	@name varchar(50),
	@caf_car_type1 varchar(6),
	@caf_car_type2 varchar(6),
	@caf_car_type3 varchar(6),
	@caf_car_type4 varchar(6),
	@caf_liability_limit money,
	@caf_cargo_limit money,
	@caf_rate char(1),
	@caf_lane char(1),
	@caf_orig_state char(1),
	@caf_orig_city char(1),
	@caf_dest_state char(1),
	@caf_dest_city char(1),
	@caf_ins_cert char(1),
	@caf_w9 char(1),
	@caf_contract char(1),
	@caf_service_rating varchar(6),
	@caf_carrier varchar(8),
	@caf_history_only char(1)

set @string = ''


if isnull(@caf_viewid, '') = ''  -- no caf_viewid, therefore a user.
begin
	if @defaults = 'current'
	begin
		select @caf_car_type1 = caf_car_type1,
			@caf_car_type2 = caf_car_type2,
			@caf_car_type3 = caf_car_type3,
			@caf_car_type4 = caf_car_type4,
			@caf_liability_limit = caf_liability_limit,
			@caf_cargo_limit = caf_cargo_limit,
			@caf_rate = caf_rate,
			@caf_lane = caf_lane,
			@caf_orig_state = caf_orig_state,
			@caf_orig_city = caf_orig_city,
			@caf_dest_state = caf_dest_state,
			@caf_dest_city = caf_dest_city,
			@caf_ins_cert = caf_ins_cert,
			@caf_w9 = caf_w9,
			@caf_contract = caf_contract,
			@caf_service_rating = caf_service_rating,
			@caf_carrier = caf_carrier,
			@caf_history_only = caf_history_only
		from carrierfilter 
		where caf_userid = @user_id
		
		select @abbr = min(cfl_abbr)
		from carrierfilterlist
		where cfl_userid = @user_id
		
		while @abbr is not null and @abbr <> ''
		begin
			select @def = cfl_labeldef from carrierfilterlist where cfl_abbr = @abbr
			select @name = name from labelfile where abbr = @abbr and labeldefinition = @def
			set @string = @string + @name + ', ' 
			select @abbr = min(cfl_abbr) from carrierfilterlist where cfl_userid = @user_id and cfl_abbr > @abbr
		end
	end
	else  -- defaults
	begin
		select @caf_car_type1 = caf_car_type1 from carrierfilter where caf_userid = @user_id and caf_car_type1_def = 'Y'
		select @caf_car_type2 = caf_car_type2 from carrierfilter where caf_userid = @user_id and caf_car_type2_def = 'Y'
		select @caf_car_type3 = caf_car_type3 from carrierfilter where caf_userid = @user_id and caf_car_type3_def = 'Y'
		select @caf_car_type4 = caf_car_type4 from carrierfilter where caf_userid = @user_id and caf_car_type4_def = 'Y'
		select @caf_liability_limit = caf_liability_limit from carrierfilter where caf_userid = @user_id and caf_liability_limit_def = 'Y'
		select @caf_cargo_limit = caf_cargo_limit from carrierfilter where caf_userid = @user_id and caf_cargo_limit_def = 'Y'
		select @caf_rate = caf_rate from carrierfilter where caf_userid = @user_id and caf_rate_def = 'Y'
		select @caf_lane = caf_lane from carrierfilter where caf_userid = @user_id and caf_lane_def = 'Y'
		select @caf_orig_state = caf_orig_state from carrierfilter where caf_userid = @user_id and caf_orig_state_def = 'Y'
		select @caf_orig_city = caf_orig_city from carrierfilter where caf_userid = @user_id and caf_orig_city_def = 'Y'
		select @caf_dest_state = caf_dest_state from carrierfilter where caf_userid = @user_id and caf_dest_state_def = 'Y'
		select @caf_dest_city = caf_dest_city from carrierfilter where caf_userid = @user_id and caf_dest_city_def = 'Y'
		select @caf_ins_cert = caf_ins_cert from carrierfilter where caf_userid = @user_id and caf_ins_cert_def = 'Y'
		select @caf_w9 = caf_w9 from carrierfilter where caf_userid = @user_id and caf_w9_def = 'Y'
		select @caf_contract = caf_contract from carrierfilter where caf_userid = @user_id and caf_contract_def = 'Y'
		select @caf_service_rating = caf_service_rating from carrierfilter where caf_userid = @user_id and caf_service_rating_def = 'Y'
		select @caf_carrier = caf_carrier from carrierfilter where caf_userid = @user_id and caf_carrier_def = 'Y'
		select @caf_history_only = caf_history_only from carrierfilter where caf_userid = @user_id and caf_history_only_def = 'Y'	
		
		select @abbr = min(cfl_abbr)
		from carrierfilterlist
		where cfl_userid = @user_id and cfl_default = 'Y'
		
		while @abbr is not null and @abbr <> ''
		begin
			select @def = cfl_labeldef from carrierfilterlist where cfl_abbr = @abbr
			select @name = name from labelfile where abbr = @abbr and labeldefinition = @def
			set @string = @string + @name + ', ' 
	
			select @abbr = min(cfl_abbr) from carrierfilterlist where cfl_userid = @user_id and cfl_default = 'Y' and cfl_abbr > @abbr
		end
	end
end
else  -- not going for user, going for caf_viewid  
begin
	select @caf_car_type1 = caf_car_type1,
		@caf_car_type2 = caf_car_type2,
		@caf_car_type3 = caf_car_type3,
		@caf_car_type4 = caf_car_type4,
		@caf_liability_limit = caf_liability_limit,
		@caf_cargo_limit = caf_cargo_limit,
		@caf_rate = caf_rate,
		@caf_lane = caf_lane,
		@caf_orig_state = caf_orig_state,
		@caf_orig_city = caf_orig_city,
		@caf_dest_state = caf_dest_state,
		@caf_dest_city = caf_dest_city,
		@caf_ins_cert = caf_ins_cert,
		@caf_w9 = caf_w9,
		@caf_contract = caf_contract,
		@caf_service_rating = caf_service_rating,
		@caf_carrier = caf_carrier,
		@caf_history_only = caf_history_only
	from carrierfilter 
	where caf_viewid = @caf_viewid
	
	select @abbr = min(cfl_abbr)
	from carrierfilterlist
	where caf_viewid = @caf_viewid
	
	while @abbr is not null and @abbr <> ''
	begin
		select @def = cfl_labeldef from carrierfilterlist where cfl_abbr = @abbr
		select @name = name from labelfile where abbr = @abbr and labeldefinition = @def
		set @string = @string + @name + ', ' 
		select @abbr = min(cfl_abbr) from carrierfilterlist where caf_viewid = @caf_viewid and cfl_abbr > @abbr
	end
end



if len(@caf_car_type1) > 0 and @caf_car_type1 <> 'UNK' and @caf_car_type1 is not null
begin
	select @name = name from labelfile where abbr = @caf_car_type1 and labeldefinition = 'cartype1'
	set  @string = @string + @name + ', ' 
end
if len(@caf_car_type2) > 0 and @caf_car_type2 <> 'UNK' and @caf_car_type2 is not null
begin
	select @name = name from labelfile where abbr = @caf_car_type2 and labeldefinition = 'cartype2'
	set  @string = @string + @name + ', ' 
end
if len(@caf_car_type3) > 0 and @caf_car_type3 <> 'UNK' and @caf_car_type3 is not null
begin
	select @name = name from labelfile where abbr = @caf_car_type3 and labeldefinition = 'cartype3'
	set  @string = @string + @name + ', ' 
end
if len(@caf_car_type4) > 0 and @caf_car_type4 <> 'UNK' and @caf_car_type4 is not null
begin
	select @name = name from labelfile where abbr = @caf_car_type4 and labeldefinition = 'cartype4'
	set  @string = @string + @name + ', ' 
end
if @caf_liability_limit > 0 set @string = @string + 'Liability Limit = ' + cast(@caf_liability_limit as varchar(20)) + ', ' 
if @caf_cargo_limit > 0 set @string = @string + 'Cargo Limit = ' + cast(@caf_cargo_limit as varchar(20)) + ', ' 
if upper(@caf_rate) = 'Y' set @string = @string + 'Rate, '
if upper(@caf_lane) = 'Y' set @string = @string + 'Lane, '
if upper(@caf_orig_state) = 'Y' set @string = @string + 'Origin State, '
if upper(@caf_orig_city) = 'Y' set @string = @string + 'Origin City, '
if upper(@caf_dest_state) = 'Y' set @string = @string + 'Dest State, '
if upper(@caf_dest_city) = 'Y' set @string = @string + 'Dest City, '
if upper(@caf_ins_cert) = 'Y' set @string = @string + 'Insurance Certificate, '
if upper(@caf_w9) = 'Y' set @string = @string + 'W9, '
if upper(@caf_contract) = 'Y' set @string = @string + 'Contract, '	
if len(@caf_carrier) > 0 and @caf_carrier <> 'UNK' and @caf_carrier is not null set @string = @string + 'Carrier = ' + @caf_carrier + ', ' 
if upper(@caf_history_only) = 'Y' set @string = @string + 'Carriers used within recent History, '
if len(@caf_service_rating) > 0 and @caf_service_rating <> 'UNK' and @caf_service_rating is not null
begin
	select @name = name from labelfile where abbr = @caf_service_rating and labeldefinition = 'carrierservicerating'
	set  @string = @string + @name + ', ' 
end




if right(@string, 2) = ', '
set @string = left(@string, len(@string) -1 ) + '.'

if len(@string) = 0 set @string = 'None.'

if isnull(@caf_viewid, '') = ''
begin
	set @string = 'Current Carrier Filters in effect for user ' + @user_id + ':  ' + @string
end
else
begin
	if upper(@caf_viewid) = 'UNK'
		set @string = 'No External Equipment views in effect.'
	else
		set @string = 'Carrier Filters in effect for External Equipment filter view ' + upper(@caf_viewid) + ':  ' + @string
end


select @string

GO
GRANT EXECUTE ON  [dbo].[DisplayCarrierFilters_sp] TO [public]
GO
