SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE  proc [dbo].[create_timeline_export_detail]
as
-- Timeline Export
-- Kinda tricky.
-- Export the header information
-- Find the max number of details in the export set then make the export x details wide.
-- Export the details starting on the right of the max (set x) then left (set 1).
--   Work from right then left working toward the middle. If there are less rows than the max, leave them null.

-- Working vars
Declare @debug integer
Declare @max_details integer
Declare @det_count integer
Declare @ted_id integer
Declare @SQL nvarchar(2048)
	-- Header
Declare @DUNS varchar(25),
	@tlh_number int ,
	@tlh_supplier varchar(8),
	@tlh_branch varchar(12)
-- 	-- Detail
declare @tld_master_ordnum varchar(15)
declare @tld_route varchar(12)
declare @tld_origin varchar(8)
declare @tld_arrive_orig datetime
declare @tld_arrive_orig_lead integer
declare @tld_depart_orig datetime
declare @tld_depart_orig_lead integer
declare @tld_dest varchar(8)
declare @tld_arrive_dest datetime
declare @tld_arrive_dest_lead integer
declare @tld_arrive_yard datetime
declare @tld_arrive_lead integer
declare @tld_trl_unload_dt datetime
declare @tld_trl_unload_lead integer
declare @tld_saturday char(1)
declare @tld_sunday char(1)
----
declare @RightColumn integer
declare @LeftColumn integer
declare @RightOLeft Char(1)
declare @Right_detail_seq integer
declare @Left_detail_seq integer
declare @TotalDetails integer
declare @i integer
-----

set @debug = 0 -- Debug on = 1

--Clear the working table
delete from timeline_export_detail

--loop to find the max details
set @max_details = 0
set @det_count = 0
select @tlh_number = min(tlh_number) from timeline_exports
while @tlh_number is not null
begin
	select @det_count = count(0) from timeline_detail where tlh_number = @tlh_number
	if @det_count > @max_details
		select @max_details = @det_count
	select @tlh_number = min(tlh_number) from timeline_exports where tlh_number > @tlh_number
end

if @debug = 1
	Print 'Max details: ' + Convert(varchar(50), @max_details)

-- Header loop
select @tlh_number = min(tlh_number) from timeline_exports
while @tlh_number is not null
begin

	if @debug = 1
		Print 'Inserting tlh_number: ' + Convert(varchar(50), @tlh_number)

	select @tlh_supplier = tlh_supplier, @tlh_branch = tlh_branch from timeline_header where tlh_number = @tlh_number
	-- Populate the header data
	select @DUNS = c.cmp_altid FROM company_alternates a LEFT OUTER JOIN company c ON a.ca_alt = c.cmp_id
		WHERE a.ca_alt = c.cmp_id and a.ca_id = @tlh_supplier and c.cmp_revtype1 = @tlh_branch

	insert timeline_export_detail (
		DUNS,
		tlh_number,
		tlh_name,
		tlh_effective,
		tlh_expires,
		tlh_supplier,
		tlh_plant,
		tlh_dock,
		tlh_jittime,
		tlh_leaddays,
		tlh_leadbasis,
		tlh_sequence,
		tlh_direction,
		tlh_sunday,
		tlh_saturday,
		tlh_branch,
		tlh_timezone,
		tlh_subroutedomicle,
		tlh_dow,
		tlh_specialist,
		tlh_updatedby,
		tlh_updatedon,
		tlh_effective_basis)
		select @DUNS,
			tlh_number,
			tlh_name,
			tlh_effective,
			tlh_expires,
			tlh_supplier,
			tlh_plant,
			tlh_dock,
			tlh_jittime,
			tlh_leaddays,
			tlh_leadbasis,
			tlh_sequence,
			tlh_direction,
			tlh_sunday,
			tlh_saturday,
			tlh_branch,
			tlh_timezone,
			tlh_subroutedomicle,
			tlh_dow,
			tlh_specialist,
			tlh_updatedby,
			tlh_updatedon,
			tlh_effective_basis
		FROM Timeline_header  
			WHERE Timeline_header.tlh_number = @tlh_number


	set @RightOLeft = 'R'
	-- Columns
	set @RightColumn = @max_details
	set @LeftColumn = 1
	-- Right and left rows
	select @Right_detail_seq = max(tld_sequence) from timeline_detail where tlh_number = @tlh_number
	select @Left_detail_seq = min(tld_sequence) from timeline_detail where tlh_number = @tlh_number
	-- loop control
	select @totaldetails = count(0) from timeline_detail where tlh_number = @tlh_number
	set @i = 1

	-- Detail loop
	while @i <= @TotalDetails 
	begin
		if @RightOLeft = 'R'
		begin
			if @debug = 1
				Print 'Updating right column: ' + Convert(varchar(50), @Right_detail_seq)

			-- Process the column
			select @tld_master_ordnum = tld_master_ordnum,
				@tld_route = tld_route,
				@tld_saturday = tld_saturday,
				@tld_sunday = tld_sunday,
				@tld_origin = tld_origin,
				@tld_arrive_orig = tld_arrive_orig,
				@tld_arrive_orig_lead = tld_arrive_orig_lead,
				@tld_depart_orig = tld_depart_orig,
				@tld_depart_orig_lead = tld_depart_orig_lead,
				@tld_dest = tld_dest,
				@tld_arrive_dest = tld_arrive_dest,
				@tld_arrive_dest_lead = tld_arrive_dest_lead,
				@tld_arrive_yard = tld_arrive_yard,
				@tld_arrive_lead = tld_arrive_lead,
				@tld_trl_unload_dt = tld_trl_unload_dt,
				@tld_trl_unload_lead = tld_trl_unload_lead
				From timeline_detail where tlh_number = @tlh_number and tld_sequence = @Right_detail_seq

			select @SQL = 'update timeline_export_detail '
				+ 'set Detail' + convert(varchar(20), @RightColumn) + '_tld_master_ordnum = ''' + isnull(convert(varchar(20), @tld_master_ordnum), '') + ''''
				+ ', Detail' + convert(varchar(20), @RightColumn) + '_tld_route = ''' + isnull(convert(varchar(20), @tld_route), '') + ''''
				+ ', Detail' + convert(varchar(20), @RightColumn) + '_tld_saturday = ''' + isnull(convert(varchar(20), @tld_saturday), '') + ''''
				+ ', Detail' + convert(varchar(20), @RightColumn) + '_tld_sunday = ''' + isnull(convert(varchar(20), @tld_sunday), '') + ''''
				+ ', Detail' + convert(varchar(20), @RightColumn) + '_tld_origin = ''' + isnull(convert(varchar(20), @tld_origin), '') + ''''
				+ ', Detail' + convert(varchar(20), @RightColumn) + '_tld_arrive_orig = ''' + isnull(convert(varchar(20),@tld_arrive_orig), '') + ''''
				+ ', Detail' + convert(varchar(20), @RightColumn) + '_tld_arrive_org_lead = ' + isnull(convert(varchar(20),@tld_arrive_orig_lead), 0)
				+ ', Detail' + convert(varchar(20), @RightColumn) + '_tld_depart_orig = ''' + isnull(convert(varchar(20),@tld_depart_orig), '') + ''''
				+ ', Detail' + convert(varchar(20), @RightColumn) + '_tld_depart_org_lead = ' + isnull(convert(varchar(20),@tld_depart_orig_lead), 0)	--MRH
				+ ', Detail' + convert(varchar(20), @RightColumn) + '_tld_dest = ''' + isnull(convert(varchar(20),@tld_dest), '') + ''''
				+ ', Detail' + convert(varchar(20), @RightColumn) + '_tld_arrive_yard = ''' + isnull(convert(varchar(20),@tld_arrive_yard), '') + ''''
				+ ', Detail' + convert(varchar(20), @RightColumn) + '_tld_arrive_lead = ' + isnull(convert(varchar(20),@tld_arrive_lead), 0)
				+ ', Detail' + convert(varchar(20), @RightColumn) + '_tld_arrive_dest = ''' + isnull(convert(varchar(20),@tld_arrive_dest), '') + ''''
				+ ', Detail' + convert(varchar(20), @RightColumn) + '_tld_arrive_dest_lead = ' + isnull(convert(varchar(20),@tld_arrive_dest_lead), 0)
				+ ', Detail' + convert(varchar(20), @RightColumn) + '_tld_trl_unload = ''' + isnull(convert(varchar(20),@tld_trl_unload_dt), '') + ''''
				+ ', Detail' + convert(varchar(20), @RightColumn) + '_tld_trl_unload_lead = ' + isnull(convert(varchar(20),@tld_trl_unload_lead), 0)
				+ ' where tlh_number = ' + convert(varchar(20), @tlh_number)

			if @debug = 1 print @SQL
			exec sp_executesql @SQL			
			-- Move to next column
			select @Right_detail_seq = max(tld_sequence) from timeline_detail where tlh_number = @tlh_number and tld_sequence < @Right_detail_seq
			set @RightColumn = @RightColumn - 1
			set @RightOLeft = 'L'
		end
		else
		begin
			if @debug = 1
				Print 'Updating left column: ' + Convert(varchar(50), @Left_detail_seq)
		
			select @tld_master_ordnum = tld_master_ordnum,
				@tld_route = tld_route,
				@tld_saturday = tld_saturday,
				@tld_sunday = tld_sunday,
				@tld_origin = tld_origin,
				@tld_arrive_orig = tld_arrive_orig,
				@tld_arrive_orig_lead = tld_arrive_orig_lead,
				@tld_depart_orig = tld_depart_orig,
				@tld_depart_orig_lead = tld_depart_orig_lead,
				@tld_dest = tld_dest,
				@tld_arrive_dest = tld_arrive_dest,
				@tld_arrive_dest_lead = tld_arrive_dest_lead,
				@tld_arrive_yard = tld_arrive_yard,
				@tld_arrive_lead = tld_arrive_lead,
				@tld_trl_unload_dt = tld_trl_unload_dt,
				@tld_trl_unload_lead = tld_trl_unload_lead
				From timeline_detail where tlh_number = @tlh_number and tld_sequence = @Left_detail_seq

			select @SQL = 'update timeline_export_detail '
				+ 'set Detail' + convert(varchar(20), @LeftColumn) + '_tld_master_ordnum = ''' + isnull(convert(varchar(20), @tld_master_ordnum), '') + ''''
				+ ', Detail' + convert(varchar(20), @LeftColumn) + '_tld_route = ''' + isnull(convert(varchar(20), @tld_route), '') + ''''
				+ ', Detail' + convert(varchar(20), @LeftColumn) + '_tld_saturday = ''' + isnull(convert(varchar(20), @tld_saturday), '') + ''''
				+ ', Detail' + convert(varchar(20), @LeftColumn) + '_tld_sunday = ''' + isnull(convert(varchar(20), @tld_sunday), '') + ''''
				+ ', Detail' + convert(varchar(20), @LeftColumn) + '_tld_origin = ''' + isnull(convert(varchar(20), @tld_origin), '') + ''''
				+ ', Detail' + convert(varchar(20), @LeftColumn) + '_tld_arrive_orig = ''' + isnull(convert(varchar(20),@tld_arrive_orig), '') + ''''
				+ ', Detail' + convert(varchar(20), @LeftColumn) + '_tld_arrive_org_lead = ' + isnull(convert(varchar(20),@tld_arrive_orig_lead), 0)
				+ ', Detail' + convert(varchar(20), @LeftColumn) + '_tld_depart_orig = ''' + isnull(convert(varchar(20),@tld_depart_orig), '') + ''''
				+ ', Detail' + convert(varchar(20), @LeftColumn) + '_tld_depart_org_lead = ' + isnull(convert(varchar(20),@tld_depart_orig_lead), 0)  --MRH 
				+ ', Detail' + convert(varchar(20), @LeftColumn) + '_tld_dest = ''' + isnull(convert(varchar(20),@tld_dest), '') + ''''
				+ ', Detail' + convert(varchar(20), @LeftColumn) + '_tld_arrive_yard = ''' + isnull(convert(varchar(20),@tld_arrive_yard), '') + ''''
				+ ', Detail' + convert(varchar(20), @LeftColumn) + '_tld_arrive_lead = ' + isnull(convert(varchar(20),@tld_arrive_lead), 0)
				+ ', Detail' + convert(varchar(20), @LeftColumn) + '_tld_arrive_dest = ''' + isnull(convert(varchar(20),@tld_arrive_dest), '') + ''''
				+ ', Detail' + convert(varchar(20), @LeftColumn) + '_tld_arrive_dest_lead = ' + isnull(convert(varchar(20),@tld_arrive_dest_lead), 0)
				+ ', Detail' + convert(varchar(20), @LeftColumn) + '_tld_trl_unload = ''' + isnull(convert(varchar(20),@tld_trl_unload_dt), '') + ''''
				+ ', Detail' + convert(varchar(20), @LeftColumn) + '_tld_trl_unload_lead = ' + isnull(convert(varchar(20),@tld_trl_unload_lead), 0)
				+ ' where tlh_number = ' + convert(varchar(20), @tlh_number)

			if @debug = 1 print @SQL
			exec sp_executesql @SQL			
			-- Move to next column
			select @Left_detail_seq = min(tld_sequence) from timeline_detail where tlh_number = @tlh_number and tld_sequence > @Left_detail_seq
			set @LeftColumn = @LeftColumn + 1
			set @RightOLeft = 'R'
		end -- @RightOLeft
		set @i = @i + 1
	end -- Detail loop
	select @tlh_number = min(tlh_number) from timeline_exports where tlh_number > @tlh_number
end -- Header loop

select * from timeline_export_detail

GO
GRANT EXECUTE ON  [dbo].[create_timeline_export_detail] TO [public]
GO
