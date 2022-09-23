SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************  
  Object Description:
  dx_add_refnumber

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/04/2016   John Richardson  PTS: 78247   Added check of edicode for 'retired'
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

CREATE PROCEDURE [dbo].[dx_add_refnumber]
	@ref_table varchar(18),
	@ref_key int,
	@ref_type varchar(6),
	@ref_number varchar(30),
	@ref_sid char(1) = '',
	@ref_update varchar(30) = '',
	@ord_orderby varchar(8) = ''
as

declare @retcode int, @ref_keystring varchar(12), @ref_seq int, @ls_edictkey varchar(6), @exp_date varchar(23), @skip_n104 char(1)
select @skip_n104 = 'N'

if isnull(@ref_key, 0) = 0 return -4

select @ref_keystring = convert(varchar(12), @ref_key)
select @retcode = -5

if lower(left(@ref_table,3)) = 'ord'
begin
	if @ref_type = 'RES' and @ref_number like '20[0-1][0-9][0-1][0-9][0-3][0-9][0-2][0-9][0-5][0-9]%'
	begin
		select @exp_date = substring(@ref_number, 1,4) + '-' + substring(@ref_number, 5,2) + '-' + substring(@ref_number, 7, 2)
			+ ' ' + substring(@ref_number, 9, 2) + ':' + substring(@ref_number, 11, 2) + ':00.000'
		if isdate(@exp_date) = 1
		begin
			if (select count(1) from expiration where exp_idtype = 'ORD' and exp_id = @ref_keystring) > 0
				delete expiration where exp_idtype = 'ORD' and exp_id = @ref_keystring
			insert expiration (exp_idtype, exp_id, exp_code, exp_expirationdate, exp_routeto, exp_priority, exp_compldate, exp_completed)
			values ('ORD', @ref_keystring, @ref_type, @exp_date, 'UNKNOWN', 2, '2049-12-31 23:59', 'N')
			return 1
		end
	end

	if left(@ref_type,2) = '_E'
	begin
		declare @ei int
		select @ei = case isnumeric(substring(@ref_type,3,1)) 
				when 1 then convert(int, substring(@ref_type,3,1))
				else ascii(upper(substring(@ref_type,3,1))) - 55 end
		if @ei between 1 and 15
		begin
			if (select count(1) from extra_info_cols where ord_field_num = @ei) = 1
			begin
				declare @extra_id int, @tab_id int, @col_id int
				select @extra_id = extra_id, @tab_id = tab_id, @col_id = col_id from extra_info_cols where ord_field_num = @ei
				if @ei > 1
				begin
					declare @e1_extra_id int, @e1_tab_id int, @e1_col_id int
					select @e1_extra_id = extra_id, @e1_tab_id = tab_id, @e1_col_id = col_id from extra_info_cols where ord_field_num = 1
					if (select count(1) from extra_info_data where extra_id = @e1_extra_id and tab_id = @e1_tab_id and col_id = @e1_col_id) = 0
						insert extra_info_data (extra_id, tab_id, col_id, col_data, table_key, col_row)
						values (@extra_id, @e1_tab_id, @e1_col_id, '', @ref_keystring, 1)
				end
				if (select count(1) from extra_info_data where extra_id = @extra_id and tab_id = @tab_id and col_id = @col_id and table_key = @ref_keystring and col_row = 1) = 0
					insert extra_info_data (extra_id, tab_id, col_id, col_data, table_key, col_row)
					values (@extra_id, @tab_id, @col_id, @ref_number, @ref_keystring, 1)
				else
					update extra_info_data
					   set col_data = @ref_number
					 where extra_id = @extra_id and tab_id = @tab_id and col_id = @col_id and table_key = @ref_keystring and col_row = 1
			end
			else
			begin
				declare @sql varchar(1000)
				select @ref_number = replace(@ref_number, '''', '''''')
				select @sql = 'update orderheader set ord_extrainfo' + ltrim(convert(varchar(2), @ei)) 
					+ ' = ''' + @ref_number + ''' where ord_hdrnumber = ' + @ref_keystring
				exec (@sql)
			end
			return 1
		end
	end
	
	if @ref_type in ('_R1','_R2','_R3','_R4','_T1','_L1') and isnull(@ref_number,'') > ''
	begin
		set @ref_number = substring(@ref_number,0,6)
		if @ref_type = '_R1'
			update orderheader set ord_revtype1 = @ref_number where ord_hdrnumber = @ref_key
		if @ref_type = '_R2'
			update orderheader set ord_revtype2 = @ref_number where ord_hdrnumber = @ref_key
		if @ref_type = '_R3'
			update orderheader set ord_revtype3 = @ref_number where ord_hdrnumber = @ref_key
		if @ref_type = '_R4'
			update orderheader set ord_revtype4 = @ref_number where ord_hdrnumber = @ref_key
		if @ref_type = '_T1'
			update orderheader set trl_type1 = @ref_number where ord_hdrnumber = @ref_key
		if @ref_type = '_L1'
			update legheader set lgh_type1 = @ref_number where ord_hdrnumber = @ref_key
		else
			update legheader
			   set lgh_class1 = ord_revtype1, lgh_class2 = ord_revtype2, lgh_class3 = ord_revtype3, lgh_class4 = ord_revtype4, legheader.trl_type1 = orderheader.trl_type1
			  from orderheader
			 where legheader.ord_hdrnumber = orderheader.ord_hdrnumber
			   and orderheader.ord_hdrnumber = @ref_key
		return 1
	end
	
	if isnull(@ord_orderby,'') IN ('','UNKNOWN')
		select @ord_orderby = ord_billto FROM orderheader WHERE ord_hdrnumber = @ref_key
end

if lower(left(@ref_table,4)) = 'stop' and isnull(@ord_orderby,'') IN ('','UNKNOWN')
	SELECT @ord_orderby = orderheader.ord_billto FROM orderheader 
	 INNER JOIN stops ON orderheader.ord_hdrnumber = stops.ord_hdrnumber
	 WHERE stops.stp_number = @ref_key
	 
if lower(left(@ref_table,7)) = 'freight' and isnull(@ord_orderby,'') IN ('','UNKNOWN')
	SELECT @ord_orderby = orderheader.ord_billto FROM orderheader
	 INNER JOIN stops ON orderheader.ord_hdrnumber = stops.ord_hdrnumber
	 INNER JOIN freightdetail ON stops.stp_number = freightdetail.stp_number
	 WHERE freightdetail.fgt_number = @ref_key

if lower(left(@ref_table,3)) = 'ord' and (@ref_type = 'EDICT#' or @ref_sid = 'Y')
begin
	select @ls_edictkey = ifc_value from interface_constants 
	 where ifc_tablename = 'misc' and ifc_columnname = 'edictkey'
	select @ref_type = case isnull(@ref_type,'') when '' then isnull(@ls_edictkey,'EDICT#') else @ref_type end
end
else
begin
--20081209 AR - Remove translation to outbound reference codes.  This should be handled on outbound document translation.
--	if (select count(1) from edireferencenumber where cmp_id = @ord_orderby and edi_ref_code = @ref_type) = 1
--	begin
--		select @ref_type = ref_code from edireferencenumber where cmp_id = @ord_orderby and edi_ref_code = @ref_type
--	end
--  else
-- PTS 78247 JRICH
    begin
		if (SELECT count(1) FROM labelfile WHERE labeldefinition = 'ReferenceNumbers' AND edicode = @ref_type AND ISNULL(retired, 'N') <> 'Y') = 1
			SELECT @ref_type = abbr FROM labelfile WHERE labeldefinition = 'ReferenceNumbers' AND edicode = @ref_type AND ISNULL(retired, 'N') <> 'Y'
	end
end

if isnull(@ref_update,'') <> '' and isnull(@ref_update,'') <> '^INSERT' --EDI UPDATE ROUTINE
begin
	declare @OldValueFound int
	set @OldValueFound = 0
	select @OldValueFound = count(1)
	  from referencenumber
	 where ref_table = @ref_table
	   and ref_tablekey = @ref_key
	   and ref_type = @ref_type
	   and ref_number = @ref_update
	if @OldValueFound > 0
	begin
		select @ref_seq = max(ref_sequence)
		  from referencenumber
		 where ref_table = @ref_table
		   and ref_tablekey = @ref_key
		   and ref_type = @ref_type
		   and ref_number = @ref_update
		if isnull(@ref_seq, 0) > 0
		begin
			set rowcount 1
			update referencenumber
			   set ref_number = @ref_number
			 where ref_table = @ref_table
			   and ref_tablekey = @ref_key
			   and ref_type = @ref_type
			   and ref_sequence = @ref_seq
			set rowcount 0
			if @ref_seq = 1 and @ref_key > 0
				exec denormalize_refnumbers @ref_table, @ref_key
			--if lower(left(@ref_table,4)) = 'stop' and @ref_key > 0
			--	exec dbo.dx_update_n104_from_stop @ref_key, @ord_orderby
			return 1
		end
	end
	else
	begin
		select @ref_seq = max(ref_sequence)
		  from referencenumber
		 where ref_table = @ref_table
		   and ref_tablekey = @ref_key
		   and ref_type = @ref_type
		if isnull(@ref_seq, 0) > 0
		begin
			set rowcount 1
			update referencenumber
			   set ref_number = @ref_number
			 where ref_table = @ref_table
			   and ref_tablekey = @ref_key
			   and ref_type = @ref_type
			   and ref_sequence = @ref_seq
			set rowcount 0
			if @ref_seq = 1 and @ref_key > 0
				exec denormalize_refnumbers @ref_table, @ref_key
			--if lower(left(@ref_table,4)) = 'stop' and @ref_key > 0
			--	exec dbo.dx_update_n104_from_stop @ref_key, @ord_orderby
			return 1
		end
	end
	select @skip_n104 = 'Y'
end

if lower(left(@ref_table,3)) = 'ord'
	exec @retcode = dbo.dx_add_refnumber_to_order @ref_keystring, @ref_type, @ref_number, @ref_sid, 'Y'
else
begin
	if lower(left(@ref_table,4)) = 'stop'
	begin
			
		exec @retcode = dbo.dx_add_refnumber_to_stop @ref_key, @ref_type, @ref_number
		if @retcode = 1 and @skip_n104 <> 'Y'
			exec dbo.dx_update_n104_from_stop @ref_key, @ord_orderby
	end
	if lower(left(@ref_table,7)) = 'freight'
		exec @retcode = dbo.dx_add_refnumber_to_freight @ref_key, @ref_type, @ref_number
end


return @retcode

GO
GRANT EXECUTE ON  [dbo].[dx_add_refnumber] TO [public]
GO
