SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[insert_vin_event_export_sp](
	@p_vee_ord_hdrnumber int,
	@p_vee_event_code char(1),
	@p_vee_event_date datetime,
	@p_vee_event_data2 varchar(255),
	@p_vee_event_data3 varchar(255)	
)
as

declare @v_vee_origin varchar(6),
	@v_vee_brand varchar(6),
	@v_vee_vin varchar(25),
	@v_vee_shipper varchar(8),
	@v_ord_bookedby varchar(20),
	@count int


select  @v_vee_origin = ord_company, 
	@v_vee_shipper = ord_shipper, 
	@v_vee_brand = ord_revtype1, 
	@v_vee_vin = ord_refnum,
	@v_ord_bookedby = ord_bookedby
	from orderheader
	where ord_hdrnumber = @p_vee_ord_hdrnumber

-- 36790
select @count = (select count(*) 
	from vin_event_assignment
	where  vea_cmp_id = @v_vee_shipper
	AND vea_event_code = @p_vee_event_code
	and upper(ltrim(rtrim(vea_event_type))) = 'EXPORT')

if @count > 0 
begin
	if ltrim(rtrim(@v_ord_bookedby)) = 'IMPORT'
	begin
	
		if @p_vee_event_code = 'L'  --load/carrier assignment, called from legheader trigger.
		begin
			insert dbo.vin_event_export(
			vee_creation_dt,
			vee_status,	
			vee_origin,
			vee_brand,
			vee_vin,
			vee_ord_hdrnumber,
			vee_event_code,
			vee_event_name,
			vee_event_data1,
			vee_event_data2,
			vee_event_data3)
		
			values(
			getdate(),
			0,
			@v_vee_origin,
			@v_vee_brand,
			@v_vee_vin,
			@p_vee_ord_hdrnumber,
			@p_vee_event_code,
			'LOAD ASSIGNED',
			@v_vee_shipper,
			@p_vee_event_data2,
			@p_vee_event_data3)
		
		
		end
		if @p_vee_event_code = 'D'	-- delivered, called from stops paperwork.
		begin
			insert dbo.vin_event_export(
			vee_creation_dt,
			vee_status,	
			vee_origin,
			vee_brand,
			vee_vin,
			vee_ord_hdrnumber,
			vee_event_code,
			vee_event_name,
			vee_event_date_time,
			vee_event_data1)
		
			values(
			getdate(),
			0,
			@v_vee_origin,
			@v_vee_brand,
			@v_vee_vin,
			@p_vee_ord_hdrnumber,
			@p_vee_event_code,
			'DELIVERED',
			@p_vee_event_date,
			@v_vee_shipper)
		
		end
		if @p_vee_event_code = 'V'	-- REAL TIMW delivered, called from stops trigger.
		begin
			insert dbo.vin_event_export(
			vee_creation_dt,
			vee_status,	
			vee_origin,
			vee_brand,
			vee_vin,
			vee_ord_hdrnumber,
			vee_event_code,
			vee_event_name,
			vee_event_date_time,
			vee_event_data1,
		        vee_event_data2)
			
			values(
			getdate(),
			0,
			@v_vee_origin,
			@v_vee_brand,
			@v_vee_vin,
			@p_vee_ord_hdrnumber,
			@p_vee_event_code,
			'REAL TIME DELIVERED',
			@p_vee_event_date,
			@v_vee_shipper,
			@p_vee_event_data2 )
		
		end
		if @p_vee_event_code = 'X'  -- Post Yard Exit, called from paperwork trigger.
		begin
			insert dbo.vin_event_export(
			vee_creation_dt,
			vee_status,	
			vee_origin,
			vee_brand,
			vee_vin,
			vee_ord_hdrnumber,
			vee_event_code,
			vee_event_name,
			vee_event_date_time,
			vee_event_data1,
			vee_event_data2)
		
			values(
			getdate(),
			0,
			@v_vee_origin,
			@v_vee_brand,
			@v_vee_vin,
			@p_vee_ord_hdrnumber,
			@p_vee_event_code,
			'POST YARD EXIT',
			@p_vee_event_date,
			@v_vee_shipper,
			@p_vee_event_data2)
		
		end
		if @p_vee_event_code = 'Y'  -- REAL TIME Yard Exit, called from STOPS trigger.
		begin
			insert dbo.vin_event_export(
			vee_creation_dt,
			vee_status,	
			vee_origin,
			vee_brand,
			vee_vin,
			vee_ord_hdrnumber,
			vee_event_code,
			vee_event_name,
			vee_event_date_time,
			vee_event_data1,
			vee_event_data2)
		
			values(
			getdate(),
			0,
			@v_vee_origin,
			@v_vee_brand,
			@v_vee_vin,
			@p_vee_ord_hdrnumber,
			@p_vee_event_code,
			'REAL TIME YARD EXIT',
			@p_vee_event_date,
			@v_vee_shipper,
			@p_vee_event_data2)
		
		end
		if @p_vee_event_code = 'C' 	-- order/vin comments, called from orderheader trigger.
		begin
			insert dbo.vin_event_export(
			vee_creation_dt,
			vee_status,	
			vee_origin,
			vee_brand,
			vee_vin,
			vee_ord_hdrnumber,
			vee_event_code,
			vee_event_name,
			vee_event_data1,
			vee_event_data2)
		
			values(
			getdate(),
			0,
			@v_vee_origin,
			@v_vee_brand,
			@v_vee_vin,
			@p_vee_ord_hdrnumber,
			@p_vee_event_code,
			'COMMENTS UPDATED',
			@v_vee_shipper,
			@p_vee_event_data2)
		
		end
	end
end
--else
--begin
--	insert vin_event_export(
--	vee_creation_dt,
--	vee_processed_dt,
--	vee_status,
--	vee_error_msg)

--	values(
--	getdate(),
--	getdate(),
--	9,
--	'Assignment Permissions for shipper ' + @v_vee_shipper + ' could not be validated')
--end
GO
GRANT EXECUTE ON  [dbo].[insert_vin_event_export_sp] TO [public]
GO
