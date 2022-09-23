SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[dx_add_load_requirement] @ord_number varchar(12), @equiptype varchar(6), @reqtype varchar(6), 
	@mustflag char(1), @haveflag char(1), @quantity int = 0, @stp_number int = 0, @fgt_number int = 0
	
as

declare @mov_number int, @ord_hdrnumber int, @seq int
declare @cmp_id varchar(8), @cmd_code varchar(8), @stp_type varchar(6)

select @mov_number = isnull(mov_number, 0), @ord_hdrnumber = isnull(ord_hdrnumber, 0)
  from orderheader where ord_number = @ord_number

if @ord_hdrnumber = 0 return -1

if isnull(@stp_number, 0) = 0
	select @cmp_id = 'UNKNOWN', @stp_type = 'BOTH'
else
	select @cmp_id = cmp_id, @stp_type = stp_type
	  from stops where stp_number = @stp_number

select @cmp_id = ISNULL(@cmp_id,'UNKNOWN'), @stp_type = ISNULL(@stp_type,'BOTH')

if isnull(@fgt_number, 0) = 0
	select @cmd_code = 'UNKNOWN'
else
	select @cmd_code = cmd_code
	  from freightdetail where fgt_number = @fgt_number

select @cmd_code = ISNULL(@cmd_code, 'UNKNOWN')

if rtrim(@equiptype) = 'CAR'
begin
	if (select count(1) from labelfile where labeldefinition = 'CARQUAL' and edicode = @reqtype) = 1
		select @reqtype = abbr from labelfile where labeldefinition = 'CARQUAL' and edicode = @reqtype
end
else
begin
	if (select count(1) from labelfile where labeldefinition = rtrim(@equiptype) + 'ACC' and edicode = @reqtype) = 1
		select @reqtype = abbr from labelfile where labeldefinition = rtrim(@equiptype) + 'ACC' and edicode = @reqtype
end

delete loadrequirement 
 where ord_hdrnumber = @ord_hdrnumber
   and lrq_equip_type = @equiptype and lrq_type = @reqtype
   and cmp_id = @cmp_id and def_id_type = @stp_type and cmd_code = @cmd_code

select @seq = max(lrq_sequence) from loadrequirement where ord_hdrnumber = @ord_hdrnumber
if @seq is null
	select @seq = 1
else
	select @seq = @seq + 1

insert loadrequirement
	(ord_hdrnumber, lrq_sequence, lrq_equip_type, lrq_type, lrq_not, lrq_manditory, lrq_quantity, cmp_id, 
	 def_id_type, mov_number, lrq_default, cmd_code, lrq_expire_date) 
values (@ord_hdrnumber, @seq, @equiptype, @reqtype, @haveflag, @mustflag, @quantity, @cmp_id,
	 @stp_type, @mov_number, 'N', @cmd_code, '2049-12-31 23:59')

return 1

GO
GRANT EXECUTE ON  [dbo].[dx_add_load_requirement] TO [public]
GO
