SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[dx_send_totalmail_message]
	@msg_To varchar(100),
	@msg_From varchar(100),
	@msg_Subject varchar(254),
	@msd_Text varchar(8000)
as

if rtrim(isnull(@msd_Text,'')) = '' return

declare @msg_id int, @msg_filter varchar(254), @msg_date datetime, @msg_seq int, @msg_line varchar(254)

select @msg_date = getdate(), @msg_seq = 0

select @msg_filter = @msg_Subject + ' ' + convert(varchar, @msg_date, 121)

begin transaction

insert into TMSQLMessage(msg_Date, msg_FormID, msg_To, msg_ToType, msg_FilterData, 
	msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject)
values (@msg_date, 0, @msg_To, 0, @msg_Filter, 1, @msg_From, 0, @msg_Subject)

select @msg_id = SCOPE_IDENTITY()

while len(@msd_Text) > 0
begin
	select @msg_line = left(@msd_Text, 254)
	select @msg_seq = @msg_seq + 1
	insert into TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
	values (@msg_id, @msg_seq, 'Text', @msg_line)
	select @msd_Text = substring(@msd_Text, 255, 8000)
end

commit transaction

return

GO
GRANT EXECUTE ON  [dbo].[dx_send_totalmail_message] TO [public]
GO
