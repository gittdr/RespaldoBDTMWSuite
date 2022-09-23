SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[timeline_export_all] 
as
--declare @lead_days_dock int
--declare @Dock_dow int
--tld_arrive_orig_lead, tld_arrive_dest_lead, tld_arrive_lead, tld_depart_orig_lead

 SELECT (SELECT c.cmp_altid FROM company_alternates a LEFT OUTER JOIN company c ON a.ca_alt = c.cmp_id
	WHERE a.ca_alt = c.cmp_id and a.ca_id = tlh_supplier and c.cmp_revtype1 = tlh_branch) [DUNS],

 	--(select cmp_name from company where cmp_id = Timeline_header.tlh_supplier) [Supplier], 
	Timeline_header.tlh_supplier [Supplier], 

	(select UPPER((select cty_name from city where cty_code = (select cmp_city from company where cmp_id = tlh_supplier)) + ' ' + (select cty_state from city where cty_code = (select cmp_city from company where cmp_id = tlh_supplier)))) [CITY_STATE],

	(select tld_route from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number )) [PUP_RT],

	isnull(Timeline_header.tlh_sunday, 'N') tlh_sunday,
	
	isnull(Timeline_header.tlh_saturday, 'N') tlh_saturday,

         case Timeline_header.tlh_DOW
		when 0 THEN 'Daily'
		when 1 THEN 'SU'
		when 2 THEN 'MO'
		when 3 THEN 'TU'
		when 4 THEN 'WE'
		when 5 THEN 'TH'
		when 6 THEN 'FR'
		when 7 THEN 'SA' 
		end [PUP_DAY],
-- Pickup
	(select tld_arrive_orig_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number )) [LEAD_TIME_PUP],

	(select substring(convert(varchar(23), tld_arrive_orig, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number )) [PUP_WINDOW_ARV],

	(select substring(convert(varchar(23), tld_depart_orig, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number )) [PUP_WINDOW_DPT],

--DayTip (Inbound) Inbound means that it is the destination.
	(select substring(convert(varchar(23), tld_arrive_yard, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest IN ('DAYTIP', 'DAYTIPY'))) [DAYT_I],
	(select tld_arrive_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest IN ('DAYTIP', 'DAYTIPY'))) [LEAD_TIME_I],
--Daytip (Outbound) Outbound means that it is the origin (as in outbound from the location)
	(select substring(convert(varchar(23), tld_arrive_orig, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_origin IN ('DAYTIP', 'DAYTIPY'))) [DAYT_O],
	(select tld_arrive_orig_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_origin IN ('DAYTIP', 'DAYTIPY'))) [LEAD_TIME_O],
-- Routes
-- [US SW]
	(select tld_route from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'WINWIN' and Timeline_detail.tld_origin IN ('DAYTIP', 'DAYTIPY'))) [US_SW],
-- [CAN SW]
	(select tld_route from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_origin = 'WINWIN' and Timeline_detail.tld_dest = 'IXDING')) [CAN_SW],

-- IXDING Inbound
	(select substring(convert(varchar(23), tld_arrive_yard, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'IXDING')) [ING_Y], ---MRH scheduled earliest
	(select substring(convert(varchar(23), tld_trl_unload_dt, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'IXDING')) [ING_I], ---MRH Trailer unload
	(select tld_arrive_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
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
	(select substring(convert(varchar(23), isnull(tld_trl_unload_dt, '00:00'), 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select max(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number )) [DEL_TIME],
	Timeline_header.tlh_dock [DOCK],
	'          ' [DEL_DOW],
	Timeline_header.tlh_number,   
         Timeline_header.tlh_name,
         Timeline_header.tlh_effective,   
         Timeline_header.tlh_expires,   
         Timeline_header.tlh_plant,   
         --Timeline_header.tlh_dock,   
         Timeline_header.tlh_jittime,   
         Timeline_header.tlh_leaddays,   
         Timeline_header.tlh_leadbasis,   
         --Timeline_header.tlh_sequence,   
         Timeline_header.tlh_direction,   
         --Timeline_header.tlh_sunday,   
         --Timeline_header.tlh_saturday,   
         Timeline_header.tlh_branch,   
         Timeline_header.tlh_timezone,   
         Timeline_header.tlh_SubrouteDomicle,   
         Timeline_header.tlh_specialist,   
         Timeline_header.tlh_updatedby,   
         Timeline_header.tlh_updatedon,   
         Timeline_header.tlh_effective_basis,   
         --Timeline_detail.tlh_number
         --Timeline_detail.tld_number,   
         --Timeline_detail.tld_sequence,   
         --Timeline_detail.tld_master_ordnum,   
         --Timeline_detail.tld_route,   
         --Timeline_detail.tld_origin,   
         --Timeline_detail.tld_arrive_orig,   
--          Timeline_detail.tld_arrive_orig_lead,   
--          Timeline_detail.tld_depart_orig,   
--          Timeline_detail.tld_depart_orig_lead,   
--          Timeline_detail.tld_dest,   
--          Timeline_detail.tld_arrive_yard,   
--          Timeline_detail.tld_arrive_lead,   
--          Timeline_detail.tld_arrive_dest,   
--          Timeline_detail.tld_arrive_dest_lead,   
--          Timeline_detail.tld_trl_unload_dt,   
--          Timeline_detail.tld_trl_unload_lead
-- Need the lead days for the switch routes for the import.
	(select tld_arrive_orig_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_origin = 'WINWIN' and Timeline_detail.tld_dest = 'IXDING')) [CAN_SW_LEAD],
	(select substring(convert(varchar(23), tld_arrive_orig, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_origin = 'WINWIN' and Timeline_detail.tld_dest = 'IXDING')) [CAN_SW_ARV],
	(select substring(convert(varchar(23), tld_depart_orig, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_origin = 'WINWIN' and Timeline_detail.tld_dest = 'IXDING')) [CAN_SW_DPT],
	(select tld_arrive_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'WINWIN' and Timeline_detail.tld_origin IN ('DAYTIP', 'DAYTIPY'))) [US_SW_LEAD],
	(select substring(convert(varchar(23), tld_arrive_yard, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'WINWIN' and Timeline_detail.tld_origin IN ('DAYTIP', 'DAYTIPY'))) [US_SW_ARV],
	(select substring(convert(varchar(23), tld_arrive_dest, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'WINWIN' and Timeline_detail.tld_origin IN ('DAYTIP', 'DAYTIPY'))) [US_SW_DPT],
-- MRH New data I need to properly rebuild the timelines.
--pup_master
	(select tld_master_ordnum from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number )) pup_master,
--USSW_master
	(select tld_master_ordnum from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'WINWIN' and Timeline_detail.tld_origin IN ('DAYTIP', 'DAYTIPY'))) USSW_master,
--CAN_master
	(select tld_master_ordnum from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_origin = 'WINWIN' and Timeline_detail.tld_dest = 'IXDING')) CAN_master,
--del_master
	(select tld_master_ordnum from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select max(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number )) del_master,

--tld_arrive_orig_lead, tld_arrive_dest_lead, tld_arrive_lead, tld_depart_orig_lead

--pup_dep_lead
	(select tld_arrive_dest_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number )) pup_dep_lead,
--dayt_i_dep_lead
	(select tld_depart_orig_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest IN ('DAYTIP', 'DAYTIPY'))) dayt_i_dep_lead,
--dayt_i_dep_time
	(select substring(convert(varchar(23), tld_arrive_dest, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest IN ('DAYTIP', 'DAYTIPY'))) dayt_i_dep_time,
--dayt_o_dep_lead
	(select tld_arrive_dest_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_origin IN ('DAYTIP', 'DAYTIPY'))) dayt_o_dep_lead,
--dayt_o_dep_time
	(select substring(convert(varchar(23), tld_depart_orig, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_origin IN ('DAYTIP', 'DAYTIPY'))) dayt_o_dep_time,
--ing_i_dep_lead
	(select tld_depart_orig_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'IXDING')) ing_i_dep_lead,
--ing_i_dep_time
	(select substring(convert(varchar(23), tld_arrive_dest, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'IXDING')) ing_i_dep_time,
--ing_o_dep_lead
	(select tld_arrive_dest_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_origin = 'IXDING')) ing_o_dep_lead,
--ing_o_dep_time
	(select substring(convert(varchar(23), tld_depart_orig, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_origin = 'IXDING')) ing_o_dep_time,
--del_dep_lead
	(select tld_depart_orig_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select max(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number)) del_dep_lead,
--del_dep_time
	(select substring(convert(varchar(23), tld_arrive_dest, 14), 1, 5) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select max(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number )) del_dep_time,
--can_sw_dep_lead
	(select tld_arrive_dest_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_origin = 'WINWIN' and Timeline_detail.tld_dest = 'IXDING')) [can_sw_dep_lead],
--us_sw_dep_lead
	(select tld_depart_orig_lead from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and timeline_detail.tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'WINWIN' and Timeline_detail.tld_origin IN ('DAYTIP', 'DAYTIPY'))) [us_sw_dep_lead],
--MRH 4/14/08 daytipy
	(select case tld_dest when 'DAYTIPY' then 'N' else '' end from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and tld_sequence = 
		(select min(tld_sequence) from timeline_detail where timeline_detail.tlh_number = Timeline_header.tlh_number and Timeline_detail.tld_dest = 'DAYTIPY')) [DAYTIPY]

    	INTO #TEMP FROM Timeline_header  
	WHERE Timeline_header.tlh_number in (select tlh_number from timeline_exports)
	ORDER BY Timeline_header.tlh_number ASC

UPDATE #TEMP set [DEL_DAY] = [DEL_DAY] + [DEL_LEAD]

UPDATE #TEMP set [DEL_DOW] =  case [DEL_DAY]
		when 0 THEN 'Daily'
		when 1 THEN 'SU'
		when 2 THEN 'MO'
		when 3 THEN 'TU'
		when 4 THEN 'WE'
		when 5 THEN 'TH'
		when 6 THEN 'FR'
		when 7 THEN 'SA' 
		end

select * from #TEMP
GO
GRANT EXECUTE ON  [dbo].[timeline_export_all] TO [public]
GO
