SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_delete_record_from_archive]
	(@dx_field001 varchar(200),
	 @dx_field003 varchar(200),
	 @dx_field004 varchar(200),
	 @dx_orderhdrnumber int,
	 @dx_movenumber int,
	 @dx_stopnumber int,
	 @dx_freightnumber int)
AS

/*******************************************************************************************************************  
  Object Description:
  dx_delete_record_from_archive

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

if isnull(@dx_movenumber,0) = 0 return -1 --no move to look up, so inform the user

if @dx_field001 = '03'
begin
	if isnull(@dx_stopnumber,0) = 0 return 1  --no stop to delete, so move on

	if (select count(*) from stops where stp_number = @dx_stopnumber) = 0 return 1  --no stop to delete, so move on

	if (select count(*) from stops where stp_number = @dx_stopnumber
		and mov_number = @dx_movenumber) = 0 return -2  --stop is on a different move (xdock), so no delete

	if (select count(*) from orderheader where mov_number = @dx_movenumber) > 1 return -3  --stops is consolidated, so no delete

	declare @max_stp_mfh_seq int
	select @max_stp_mfh_seq = max(stp_mfh_sequence) 
	  from stops
	 where mov_number = @dx_movenumber
	if isnull(@max_stp_mfh_seq,0) < 3 return -4  --can't delete a stop if its move only has two stops

	declare @stp_mfh_seq int
	select @stp_mfh_seq = stp_mfh_sequence
	  from stops
	 where stp_number = @dx_stopnumber

	delete freightdetail
	 where stp_number = @dx_stopnumber

	delete event
	 where stp_number = @dx_stopnumber

   delete StopSchedulesHistory where sch_id in (select sch_id from StopSchedules where stp_number = @dx_stopnumber)

   delete StopSchedules
	 where stp_number = @dx_stopnumber

   delete stops
	 where stp_number = @dx_stopnumber

	declare @stp_num int
	while @stp_mfh_seq < @max_stp_mfh_seq
	begin
		select @stp_num = 0, @stp_mfh_seq = @stp_mfh_seq + 1
		select @stp_num = max(stp_number)
		  from stops
		 where mov_number = @dx_movenumber
		   and stp_mfh_sequence = @stp_mfh_seq
		if isnull(@stp_num,0) = 0 break
		update stops
		   set stp_sequence = case stp_sequence when 0 then 0 else stp_sequence - 1 end
		     , stp_mfh_sequence = stp_mfh_sequence - 1
		     , stp_lgh_mileage = -1
		     , stp_ord_mileage = -1
		     , skip_trigger = 1
		  from stops
		 where stp_number = @stp_num
	end

	exec update_assetassignment @dx_movenumber
	exec update_ord @dx_movenumber, 'UNK', 0
	exec update_move @dx_movenumber
end

if @dx_field001 = '04'
begin
	if isnull(@dx_freightnumber, 0) = 0 return 1  --no freight to delete, so move on
	
	--can't delete freight is it doesn't exist
	if (select count(*)
	      from freightdetail
	     where stp_number = @dx_stopnumber
	       and fgt_number = @dx_freightnumber) = 0 return 1  --yes, assume user removed freight

	delete referencenumber
	 where ref_table = 'freightdetail'
	   and ref_tablekey = @dx_freightnumber

	if (select count(*)
	      from freightdetail
	     where stp_number = @dx_stopnumber) < 2  --can't delete a solitary freightdetail, but it can be zeroed
		update freightdetail
		   set cmd_code = 'UNKNOWN', fgt_description = 'UNKNOWN', fgt_reftype = 'UNK',
		       fgt_refnum = '', fgt_pallets_in = 0, fgt_pallets_out = 0, fgt_pallets_on_trailer = 0,
		       fgt_carryins1 = 0, fgt_carryins2 = 0, fgt_quantity = 0,
		       fgt_weight = 0, fgt_weightunit = 'LBS', fgt_count = 0,
		       fgt_countunit = 'PCS', fgt_volume = 0, fgt_volumeunit = 'CUB',
		       fgt_rate = 0, fgt_rateunit = 'UNK', fgt_charge = 0, fgt_unit = 'PCS', cht_itemcode = 'UNK'
		 where fgt_number = @dx_freightnumber
	else
	begin
		declare @fgt_seq int
		select @fgt_seq = fgt_sequence from freightdetail where fgt_number = @dx_freightnumber
		delete freightdetail
		 where fgt_number = @dx_freightnumber
		update freightdetail
		   set fgt_sequence = fgt_sequence - 1, skip_trigger = 1
		 where stp_number = @dx_stopnumber
		   and fgt_sequence > @fgt_seq
	end
end

if @dx_field001 = '05'
begin
	set rowcount 1
	if @dx_field003 = '_RM'
	begin
		if isnull(@dx_freightnumber, 0) > 0
			delete notes
			 where ntb_table = 'freightdetail'
			   and nre_tablekey = @dx_freightnumber
			   and not_text = @dx_field004
		else
		begin
			if isnull(@dx_stopnumber, 0) > 0
				delete notes
				 where ntb_table = 'stops'
				   and nre_tablekey = @dx_stopnumber
				   and not_text = @dx_field004
		end
		delete notes
		 where ntb_table = 'orderheader'
		   and nre_tablekey = @dx_orderhdrnumber
		   and not_text = @dx_field004
	end
	else
	begin
		if isnull(@dx_freightnumber, 0) > 0
			delete referencenumber
			 where ref_table = 'freightdetail'
			   and ref_tablekey = @dx_freightnumber
			   and ref_type = @dx_field003
			   and ref_number = @dx_field004
		else
		begin
			if isnull(@dx_stopnumber, 0) > 0
				delete referencenumber
				 where ref_table = 'stops'
				   and ref_tablekey = @dx_stopnumber
				   and ref_type = @dx_field003
				   and ref_number = @dx_field004
			else
				delete referencenumber
				 where ref_table = 'orderheader'
				   and ref_tablekey = @dx_orderhdrnumber
				   and ref_type = @dx_field003
				   and ref_number = @dx_field004
		end
	end
	set rowcount 0
end

if @dx_field001 = '08'
begin
	set rowcount 1
	declare @cmp_id varchar(8), @stp_type varchar(6), @cmd_code varchar(8)
	if isnull(@dx_stopnumber, 0) = 0
		select @cmp_id = 'UNKNOWN', @stp_type = 'BOTH'
	else
		select @cmp_id = cmp_id, @stp_type = stp_type from stops where stp_number = @dx_stopnumber

	select @cmp_id = ISNULL(@cmp_id,'UNKNOWN'), @stp_type = ISNULL(@stp_type,'BOTH')

	if isnull(@dx_freightnumber, 0) = 0
		select @cmd_code = 'UNKNOWN'
	else
		select @cmd_code = cmd_code from freightdetail where fgt_number = @dx_freightnumber

	select @cmd_code = ISNULL(@cmd_code, 'UNKNOWN')

	delete loadrequirement
	 where ord_hdrnumber = @dx_orderhdrnumber
	   and lrq_equip_type = @dx_field003
	   and lrq_type = @dx_field004
	   and cmp_id = @cmp_id
	   and def_id_type = @stp_type
	   and cmd_code = @cmd_code
	set rowcount 0   
end

--all other record types are not checked for duplicates
--note: 06 company records are handled with the deletion of the stop

return 1

GO
GRANT EXECUTE ON  [dbo].[dx_delete_record_from_archive] TO [public]
GO
