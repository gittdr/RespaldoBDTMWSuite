SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_update_n104_from_stop]
	@stp_number int,
	@ord_orderby varchar(8)
AS

/*******************************************************************************************************************  
  Object Description:
  dx_update_n104_from_stop

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

declare @ls_n104ref varchar(3), @sN104LocCode varchar(30)

select @ls_n104ref = ifc_value from interface_constants
 where ifc_tablename = 'misc' and ifc_columnname = 'N104Ref'
select @ls_n104ref = ltrim(rtrim(isnull(@ls_n104ref,'')))

if @ls_n104ref <> ''
begin
	if isnull(@ord_orderby,'UNKNOWN') = 'UNKNOWN' return

	declare @stp_cmpid varchar(8)
	select @stp_cmpid = cmp_id from stops where stp_number = @stp_number
	if isnull(@stp_cmpid,'UNKNOWN') = 'UNKNOWN' return

	if (select count(1) from referencenumber 
	     where ref_tablekey = @stp_number and ref_type = @ls_n104ref and ref_table = 'stops') > 0
	begin
		select @sN104LocCode = max(ref_number) from referencenumber
		 where ref_tablekey = @stp_number and ref_type = @ls_n104ref and ref_table = 'stops'
		if isnull(@sN104LocCode,'') > ''
		begin
			if exists (select billto_cmp_id 
				     from cmpcmp 
				    where billto_cmp_id = @ord_orderby 
				      and cmp_id = @stp_cmpid)
				Update cmpcmp
				   set ediloc_code = @sN104LocCode 
				 where billto_cmp_id = @ord_orderby 
				   and cmp_id = @stp_cmpid
				   and ltrim(rtrim(ediloc_code)) <> @sN104LocCode
			else
				Insert into cmpcmp (billto_cmp_id, cmp_id, ediloc_code)
					select @ord_orderby, @stp_cmpid, @sN104LocCode
		end
		delete referencenumber
		 where ref_tablekey = @stp_number and ref_type = @ls_n104ref and ref_table = 'stops'
	end
end

return 1

GO
GRANT EXECUTE ON  [dbo].[dx_update_n104_from_stop] TO [public]
GO
