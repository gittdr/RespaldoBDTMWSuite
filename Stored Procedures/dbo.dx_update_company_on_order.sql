SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_update_company_on_order]
	@ord_number int,
	@stp_number int,
	@cmp_type varchar(2),
	@cmp_id varchar(8),
	@cmp_city int,
	@stp_event varchar(6) = '',
	@miles_from_prior_stop int = 0
AS

/*******************************************************************************************************************  
  Object Description:
  dx_update_company_on_order

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
  11/13/2016   David Wilks	    INT-200078   Suppress event changes that would put a LLD after a no trailer event (ect_bt_start=Y)
********************************************************************************************************************/

declare @v_movnum int, @v_setbillto varchar(8), @v_billto varchar(8), @v_miles int, 
		@v_maxseq int, @v_seq int, @v_type varchar(8), @stplghmiles int, @stpordmiles int,
		@ls_audit char(1),@orig_cmp_id varchar(8), @v_lghnum int,
		@ls_UseCompanyDefaultEventCodes char(1)

 SELECT @stplghmiles = 0, @stpordmiles = 0
 SELECT @ls_UseCompanyDefaultEventCodes = gi_string1 FROM generalinfo WHERE gi_name = 'UseCompanyDefaultEventCodes'
 
select @v_movnum = mov_number
  from orderheader
 where ord_hdrnumber = @ord_number

if isnull(@v_movnum, 0) = 0 return -1

select @v_maxseq = MAX(stp_sequence)
  from stops
 where ord_hdrnumber = @ord_number
 
if isnull(@cmp_id,'') = '' select @cmp_id = 'UNKNOWN'


if @cmp_type = 'ST' and @stp_number > 0
begin
	select @v_seq = stp_sequence, @v_lghnum = lgh_number
	  from stops with(NOLOCK)
	 where stp_number = @stp_number
	
	IF @v_seq <> 1  
		BEGIN  
		IF (SELECT COUNT(1) FROM stops  with(NOLOCK) 
		WHERE mov_number = @v_movnum AND stp_sequence = @v_seq - 1 AND cmp_id = @cmp_id AND stp_city = @cmp_city) = 0  
		SELECT @stplghmiles = CASE ISNULL(@miles_from_prior_stop,0) WHEN 0 THEN -1 ELSE @miles_from_prior_stop END  
		, @stpordmiles = CASE ISNULL(@miles_from_prior_stop,0) WHEN 0 THEN -1 ELSE @miles_from_prior_stop END  
	END  

	select	@ls_audit = isnull(upper(substring(g1.gi_string1, 1, 1)), 'N')
		from	generalinfo g1
		where	g1.gi_name = 'FingerprintAudit'
		and	g1.gi_datein = (select	max(g2.gi_datein)
						  from	generalinfo g2
						  where	g2.gi_name = 'FingerprintAudit'
							and	g2.gi_datein <= getdate())

	if @ls_audit = 'Y' 
		declare @evt_contact varchar(30), @evt_startdate datetime, @evt_enddate datetime
		select top 1 @evt_contact = IsNull(evt_contact,''), @evt_startdate = evt_startdate, @evt_enddate = evt_enddate from event 
		where stp_number = @stp_number
		and evt_eventcode= 'SAP' 
		and evt_reason <> 'INIT' 
		and evt_sequence <> 1 
		order by evt_sequence desc

		if @evt_startdate is not null
	        begin
				select @orig_cmp_id = cmp_id from stops where stp_number = @stp_number 
				if @orig_cmp_id <> @cmp_id 
					insert into expedite_audit
						(ord_hdrnumber
						,updated_by
						,activity
						,updated_dt
						,update_note
						,key_value
						,mov_number
						,lgh_number
						,join_to_table_name)
					select @ord_number
						,'DX'
						,'Appt CompId Updated'
						,getdate()
						,'Company ID ' + @orig_cmp_id + ' -> ' + 
							@cmp_id + '. Appointment event with ''' +  @evt_contact + 
							''' between ' + convert(varchar, @evt_startdate, 1) + ' ' + convert(varchar, @evt_startdate, 8) 
							+ ' and ' + convert(varchar, @evt_enddate, 1) + ' ' + convert(varchar, @evt_enddate, 8) + ' may be invalid.'
						,convert(varchar(20), @stp_number)
						,isnull(@v_movnum, 0)
						,isnull(@v_lghnum, 0) 
						,'stops'
			end


	if isnull(@stp_event,'') > ''
	begin
		select @v_type = fgt_event from eventcodetable where abbr = @stp_event
		if @v_type is null
			select @v_type = stp_type, @stp_event = stp_event from stops where stp_number = @stp_number

  	    IF @ls_UseCompanyDefaultEventCodes = 'Y'
		  BEGIN
		  IF @v_type = 'PUP'
			  SELECT @stp_event = IsNull(ltsl_default_pickup_event,@stp_event)
			FROM company WHERE cmp_id = @cmp_id and ltsl_default_pickup_event <> ''
		  IF @v_type = 'DRP'
			  SELECT @stp_event = IsNull(ltsl_default_delivery_event,@stp_event)
	   		FROM company WHERE cmp_id = @cmp_id and ltsl_default_delivery_event <> ''
		  END

  	    if @stp_event = 'LLD' -- keep current event value if previous stop is a "no trailer event" so does not support LLD on the current stop
		begin
		  select @stp_event = s.stp_event 
		  from stops s with (nolock) 
		  left join stops s1 with (nolock) on s1.stp_mfh_sequence = s.stp_mfh_sequence - 1 and s1.mov_number = @v_movnum 
		  join eventcodetable ect with (nolock) on s1.stp_event = ect.abbr and ect_bt_start = 'Y'
		  where s.stp_number = @stp_number
		end

		update stops
		   set stops.cmp_id = @cmp_id
			 , stops.cmp_name = LEFT(c.cmp_name,30)
			 , stops.stp_city = case @cmp_id when 'UNKNOWN' then @cmp_city else c.cmp_city end
			 , stops.stp_zipcode = c.cmp_zip
			 , stops.stp_address = LEFT(c.cmp_address1,40)
			 , stops.stp_address2 = LEFT(c.cmp_address2,40)
			 , stops.stp_contact = LEFT(c.cmp_contact,30)
			 , stops.stp_phonenumber = c.cmp_primaryphone
			 , stops.stp_ord_mileage = @stpordmiles 
			 , stops.stp_lgh_mileage = @stplghmiles 
			 , stops.stp_type = @v_type
			 , stops.stp_event = @stp_event
		  from company c
		 where stops.stp_number = @stp_number
		   and c.cmp_id = @cmp_id
	end
	else
		update stops
		   set stops.cmp_id = @cmp_id
			 , stops.cmp_name = LEFT(c.cmp_name,30)
			 , stops.stp_city = case @cmp_id when 'UNKNOWN' then @cmp_city else c.cmp_city end
			 , stops.stp_zipcode = c.cmp_zip
			 , stops.stp_address = LEFT(c.cmp_address1,40)
			 , stops.stp_address2 = LEFT(c.cmp_address2,40)
			 , stops.stp_contact = LEFT(c.cmp_contact,30)
			 , stops.stp_phonenumber = c.cmp_primaryphone
			 , stops.stp_ord_mileage = @stpordmiles 
			 , stops.stp_lgh_mileage = @stplghmiles 
		  from company c
		 where stops.stp_number = @stp_number
		   and c.cmp_id = @cmp_id

	if @cmp_id <> 'UNKNOWN'
		exec dx_update_n104_from_stop @stp_number, @cmp_id
	
	select @cmp_type = case @v_seq when 1 then 'S' when @v_maxseq then 'CO' else 'ST' end
end

if @cmp_type = 'S'
	update orderheader
	   set ord_originpoint = @cmp_id
	     , ord_showshipper = @cmp_id
	     , ord_shipper = @cmp_id
	     , ord_origincity = case @cmp_id when 'UNKNOWN' then @cmp_city else c.cmp_city end
	     , ord_origin_zip = c.cmp_zip
	  from company c
	 where ord_hdrnumber = @ord_number
	   and c.cmp_id = @cmp_id
	   
if @cmp_type = 'SU'
	update orderheader
	   set ord_supplier = @cmp_id
	  from company c
	 where ord_hdrnumber = @ord_number
	   and c.cmp_id = @cmp_id


if @cmp_type = 'CO'
	update orderheader
	   set ord_destpoint = @cmp_id
	     , ord_showcons = @cmp_id
	     , ord_consignee = @cmp_id
	     , ord_destcity = case @cmp_id when 'UNKNOWN' then @cmp_city else c.cmp_city end
	     , ord_dest_zip = c.cmp_zip
	  from company c
	 where ord_hdrnumber = @ord_number
	   and c.cmp_id = @cmp_id

if @cmp_type = 'SH'
begin
	select @v_setbillto = 'UNKNOWN'
	select @v_billto = ord_billto
	  from orderheader with(NOLOCK)
	 where ord_hdrnumber = @ord_number
	if @v_billto = 'UNKNOWN'
		exec dx_get_default_billto @cmp_id, @v_setbillto OUTPUT
	update orderheader
	   set ord_company = @cmp_id
	 where ord_hdrnumber = @ord_number
	if @v_setbillto <> 'UNKNOWN'
		select @cmp_id = @v_setbillto, @cmp_type = 'BT'
end

if @cmp_type = 'BT'
begin
	update orderheader
	   set ord_billto = @cmp_id
	     , ord_mileagetable = case isnull(c.cmp_mileagetable,0) when 0 then ord_mileagetable else c.cmp_mileagetable end
	  from company c
	 where ord_hdrnumber = @ord_number
	   and c.cmp_id = @cmp_id
	if @cmp_id <> 'UNKNOWN'
	begin
		declare @v_stpnum int
		select @v_stpnum = 0
		while 1=1
		begin
			select @v_stpnum = MIN(stp_number) from stops where ord_hdrnumber = @ord_number and stp_number > @v_stpnum
			if @v_stpnum is null break
			exec dx_update_n104_from_stop @v_stpnum, @cmp_id
		end
	end
end

exec dbo.update_ord @v_movnum, 'UNK'
exec dbo.update_move @v_movnum

return 1

GO
GRANT EXECUTE ON  [dbo].[dx_update_company_on_order] TO [public]
GO
