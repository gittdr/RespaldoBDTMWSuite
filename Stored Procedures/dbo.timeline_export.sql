SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[timeline_export] 
as
SELECT (SELECT c.cmp_altid FROM company_alternates a LEFT OUTER JOIN company c ON a.ca_alt = c.cmp_id
	WHERE a.ca_alt = c.cmp_id and a.ca_id = tlh_supplier and c.cmp_revtype1 = tlh_branch) [DUNS],

 	(select cmp_name from company where cmp_id = Timeline_header.tlh_supplier) [Supplier], 
	--Timeline_header.tlh_supplier [Supplier], 

	(select UPPER((select cty_name from city where cty_code = (select cmp_city from company where cmp_id = tlh_supplier)) + ' ' + (select cty_state from city where cty_code = (select cmp_city from company where cmp_id = tlh_supplier)))) [CITY_STATE],

	(select tld_route from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number )) [PUP_RT],

--     case Timeline_header.tlh_DOW
--		when 0 THEN 'Daily'
--		when 1 THEN 'SU'
--		when 2 THEN 'MO'
--		when 3 THEN 'TU'
--		when 4 THEN 'WE'
--		when 5 THEN 'TH'
--		when 6 THEN 'FR'
--		when 7 THEN 'SA' 
--		end [PUP_DAY],

	'          '  [PUP_DAY], -- Place holder

-- Pickup
	(select tld_arrive_orig_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number )) [LEAD_TIME_PUP],

	(select substring(convert(varchar(23), tld_arrive_orig, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number )) [PUP_WINDOW_ARV],

	(select substring(convert(varchar(23), tld_depart_orig, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number )) [PUP_WINDOW_DPT],

--DayTip (Inbound) Inbound means that it is the destination.
	(select substring(convert(varchar(23), tld_arrive_yard, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'DAYTIP')) [DAYT_I],
	(select tld_arrive_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'DAYTIP')) [LEAD_TIME_I],
--Daytip (Outbound) Outbound means that it is the origin (as in outbound from the location)
	(select substring(convert(varchar(23), tld_arrive_orig, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_origin = 'DAYTIP')) [DAYT_O],
	(select tld_arrive_orig_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_origin = 'DAYTIP')) [LEAD_TIME_O],
-- Routes
-- [US SW]
	(select tld_route from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'WINWIN' and Timeline_detail.tld_origin = 'DAYTIP')) [US_SW],
-- [CAN SW]
	(select tld_route from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_origin = 'WINWIN' and Timeline_detail.tld_dest = 'IXDING')) [CAN_SW],

-- IXDING Inbound
	(select substring(convert(varchar(23), tld_arrive_yard, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'IXDING')) [ING_Y], ---MRH scheduled earliest
	(select substring(convert(varchar(23), tld_trl_unload_dt, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'IXDING')) [ING_I], ---MRH Trailer unload
--	(select tld_arrive_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
--		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'IXDING')) [LEAD_TIME_II],
	(select tld_trl_unload_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'IXDING')) [LEAD_TIME_II],
--IXDING Outbound
	(select substring(convert(varchar(23), tld_arrive_orig, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_origin = 'IXDING')) [ING_O],
	(select tld_arrive_orig_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_origin = 'IXDING')) [LEAD_TIME_IO],
--Delivery
	(select tld_route from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select max(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number )) [DEL_RT],
	-- This should not show in the result set but is used for the delivery day of week. tld_arrive_dest_lead
	(select tld_arrive_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select max(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number)) [DEL_LEAD],
	
	Timeline_header.tlh_DOW [DEL_DAY],

	(select substring(convert(varchar(23), tld_arrive_yard, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select max(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number )) [PLT_YARD],					---MRH scheduled earliest
--	Changed to header JIT
--	(select substring(convert(varchar(23), isnull(tld_trl_unload_dt, '00:00'), 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
--		(select max(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number )) [DEL_TIME],
	Timeline_header.tlh_jittime [DEL_TIME],

	Timeline_header.tlh_dock [DOCK],
	'          ' [DEL_DOW],
	tlh_number

    	INTO #TEMP FROM Timeline_header  
	WHERE Timeline_header.tlh_number in (select tlh_number from timeline_exports)
	ORDER BY Timeline_header.tlh_number ASC

----------------------------------------
--12/22/08 tlh_direction related changes.
--Need to loop through these.
-- Direction indicates pup or drop & whether to add or subtract the lead days.
-- It also needs to consider weekends.
----------------------------------------

--UPDATE #TEMP set [DEL_DAY] = [DEL_DAY] + [DEL_LEAD]

--UPDATE #TEMP set [DEL_DOW] =  case [DEL_DAY]
--		when 0 THEN 'Daily'
--		when 1 THEN 'SU'
--		when 2 THEN 'MO'
--		when 3 THEN 'TU'
--		when 4 THEN 'WE'
--		when 5 THEN 'TH'
--		when 6 THEN 'FR'
--		when 7 THEN 'SA' 
--		end

declare @tlh_number integer
declare @tlh_direction char(1)
declare @tlh_lead integer
declare @i integer
declare @tlh_DOW integer
declare @DOW integer
declare @Saturday char(1)
declare @Sunday char(1)

select @tlh_number = min(tlh_number) from #TEMP
while @tlh_number IS NOT NULL
begin
	select @tlh_DOW = isnull(tlh_DOW, 0),
		@Saturday = upper(isnull(tlh_saturday, 'N')),
		@Sunday = upper(isnull(tlh_sunday, 'N')),
		@tlh_direction = upper(isnull(tlh_direction, 'D')),
		@tlh_lead = isnull(tlh_leaddays, 1)
		from timeline_header where tlh_number = @tlh_number

	if isnull(@tlh_direction, 'D') = 'D'
	begin
		-- Set the drop day of week
 		UPDATE #TEMP set [DEL_DOW] =  case @tlh_DOW
				when 0 THEN 'Daily'
				when 1 THEN 'SU'
				when 2 THEN 'MO'
				when 3 THEN 'TU'
				when 4 THEN 'WE'
				when 5 THEN 'TH'
				when 6 THEN 'FR'
				when 7 THEN 'SA' 
				end
			where tlh_number = @tlh_number
		
		-- Calcuate the PUP day of week
		if @tlh_DOW <> 0	-- If not a daily timeline
		begin
			select @DOW = @tlh_DOW
			select @i = 1
			While @i < @tlh_lead -- For each lead day
			begin
				select @DOW = @DOW - 1

				if @DOW <= 0 
					select @DOW = 7

				if @DOW = 1 --Sunday
					if @Sunday <> 'Y'
						Select @DOW = 7
						
				if @DOW = 7 --Saturday
					if @Saturday <> 'Y'
						Select @DOW = 6

				select @i = @i + 1	-- Next lead day
			end
		     UPDATE #TEMP set [PUP_DAY] = 
				case @DOW
					when 0 THEN 'Daily'
					when 1 THEN 'SU'
					when 2 THEN 'MO'
					when 3 THEN 'TU'
					when 4 THEN 'WE'
					when 5 THEN 'TH'
					when 6 THEN 'FR'
					when 7 THEN 'SA'
					end
				where tlh_number = @tlh_number
		end
		else -- Daily timeline. Set to daily.
		begin
			UPDATE #TEMP set [PUP_DAY] = 'Daily' where tlh_number = @tlh_number
		end	
		select @tlh_number = min(tlh_number) from #TEMP where tlh_number > @tlh_number -- #Temp timeline loop control
	end
	else ----------- Pickup based
	begin
		-- Set the pickup day of week
 		UPDATE #TEMP set [PUP_DAY] =  case @tlh_DOW
				when 0 THEN 'Daily'
				when 1 THEN 'SU'
				when 2 THEN 'MO'
				when 3 THEN 'TU'
				when 4 THEN 'WE'
				when 5 THEN 'TH'
				when 6 THEN 'FR'
				when 7 THEN 'SA' 
				end
			where tlh_number = @tlh_number
		
		-- Calcuate the PUP day of week
		if @tlh_DOW <> 0	-- If not a daily timeline
		begin
			select @DOW = @tlh_DOW
			select @i = 1
			While @i < @tlh_lead -- For each lead day
			begin
				select @DOW = @DOW + 1

				if @DOW > 7 
					select @DOW = 1

				if @DOW = 7 --Saturday
					if @Saturday <> 'Y'
						Select @DOW = 1

				if @DOW = 1 --Sunday
					if @Sunday <> 'Y'
						Select @DOW = 2
						
				select @i = @i + 1	-- Next lead day
			end
		     UPDATE #TEMP set [DEL_DAY] = 
				case @DOW
					when 0 THEN 'Daily'
					when 1 THEN 'SU'
					when 2 THEN 'MO'
					when 3 THEN 'TU'
					when 4 THEN 'WE'
					when 5 THEN 'TH'
					when 6 THEN 'FR'
					when 7 THEN 'SA'
					end
				where tlh_number = @tlh_number
		end
		else -- Daily timeline. Set to daily.
		begin
			UPDATE #TEMP set [DEL_DAY] = 'Daily' where tlh_number = @tlh_number
		end	
		select @tlh_number = min(tlh_number) from #TEMP where tlh_number > @tlh_number -- #Temp timeline loop control
	end
end

--select * from #TEMP
select
DUNS,
Supplier,
CITY_STATE,
PUP_RT,
PUP_DAY,
LEAD_TIME_PUP,
PUP_WINDOW_ARV,
PUP_WINDOW_DPT,
DAYT_I,
LEAD_TIME_I,
DAYT_O,
LEAD_TIME_O,
US_SW,
CAN_SW,
ING_Y,
ING_I,
LEAD_TIME_II,
ING_O,
LEAD_TIME_IO,
DEL_RT,
DEL_DOW,
PLT_YARD,
DEL_TIME,
DOCK
From #TEMP

GO
GRANT EXECUTE ON  [dbo].[timeline_export] TO [public]
GO
