SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[upd_ord_vin_event_import_sp]
as
/********************************************

exec dbo.upd_ord_vin_event_import_sp 

********************************************/

set nocount on

declare @ord_hdrnumber int,
	@col_id int, 
	@tab_id int,
	@vei_id int,
	@scandate datetime,
	@eid_error int,
	@ord_shipper varchar(20),
	@count int


-- temp table to hold all records ready for processing in the vin_event_import table.
create table #vin_import (
	vei_id int,
	vei_ord_hdrnumber int,
	scandate datetime)


--PTS35299 Scan vin_event_import table for any records with a 0 Ord_hdrnumber and stamp with an error status 
update vin_event_import 
set vei_processed_dt = getdate(), 
	vei_status = 9, 
	vei_error_msg = 'Order Number Does Not Pass Validation' 
where vei_ord_hdrnumber = 0 

-- PTS36790 Add check to orderheader.
update vin_event_import 
set vei_processed_dt = getdate(), 
	vei_status = 9, 
	vei_error_msg = 'Order Number Does Not Pass Validation' 
where vei_status <> 9
	and vei_ord_hdrnumber not in (select ord_hdrnumber from orderheader)


insert #vin_import(vei_id, vei_ord_hdrnumber, scandate)
select vei_id, vei_ord_hdrnumber, vei_event_date_time
from vin_event_import
where vei_status = 0		-- pending
and vei_event_code = 'S'	-- scan date

	select @vei_id = min(vei_id)
	from #vin_import

	while @vei_id is not null
	begin
		
		begin tran

		select @ord_hdrnumber = vei_ord_hdrnumber, 
			@scandate = scandate
		from #vin_import
		where vei_id = @vei_id
		
-- 		select @scandate = scandate
-- 		from #vin_import
-- 		where vei_id = @vei_id
	
		-- 36790
		Select @ord_shipper = ord_shipper 
		from orderheader
		where ord_hdrnumber =  @ord_hdrnumber

		select @count = (select count(*)
		from vin_event_assignment
		where vea_cmp_id = @ord_shipper
		and upper(ltrim(rtrim(vea_event_type))) = 'IMPORT')
		-- 36790 end

		if @count > 0
		Begin
			select @col_id = col_id, @tab_id = tab_id
			from extra_info_cols
			where extra_id = 7 -- orderheader table
			and ltrim(rtrim(col_name)) = 'SCANNED DATE'		
	
			-- update or insert extra_info_data with a scan date for that order.
			if exists(select 1 from extra_info_data
				where tab_id = @tab_id 
				and col_id = @col_id 
				and extra_id = 7 -- orderheader table
				and table_key = @ord_hdrnumber 
				and col_row = 1) 		
				
			begin	-- update
				update extra_info_data 
				--set col_data = @scandate 
				set col_datetime = @scandate --Dan Meek 08/02/06, changed to populate actual date 
				where tab_id = @tab_id 
				and col_id = @col_id 
				and extra_id = 7 -- orderheader table
				and table_key = @ord_hdrnumber 
				and col_row = 1 
			
				select @eid_error = @@error	
			end
			else
			begin	-- insert
				--insert extra_info_data(extra_id, tab_id, col_id, col_data, table_key, col_row)
				insert extra_info_data(extra_id, tab_id, col_id, col_datetime, table_key, col_row)--Dan Meek 08/02/06, changed to populate actual date 
				values(7, @tab_id, @col_id, @scandate, @ord_hdrnumber,1)
	           
				select @eid_error = @@error	
			end			
	
			if @eid_error <> 0
			begin	
				-- update vin_event_import to reflect an error.
				update vin_event_import
				set vei_processed_dt = getdate(),
				vei_status = 9,
				vei_error_msg = 'An error occured while updating table extra_info_data for this order'
				where vei_id = @vei_id
	
				rollback tran
			end
			else
			begin
				-- update vin_event_import to reflect success.
				update vin_event_import
				set vei_processed_dt = getdate(),
				vei_status = 1
				where vei_id = @vei_id
	
				commit tran
			end			
		end
		else  -- no priviledges from vin_event_assignment table
		begin
			-- update vin_event_import to reflect an error.
			update vin_event_import
			set vei_processed_dt = getdate(),
			vei_status = 9,
			vei_error_msg = 'Assignment Permissions for ' + @ord_shipper + ' could not be validated'
			where vei_id = @vei_id
		
			commit tran

			
		end	
		-- next record in temp table.
		select @vei_id = min(vei_id) from #vin_import where vei_id > @vei_id
	end		

drop table #vin_import

set nocount off

GO
GRANT EXECUTE ON  [dbo].[upd_ord_vin_event_import_sp] TO [public]
GO
