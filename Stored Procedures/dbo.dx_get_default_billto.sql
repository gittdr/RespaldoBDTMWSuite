SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[dx_get_default_billto]
	@shipper varchar(8),
	@@billto varchar(8) OUTPUT
as

declare @v_defaultbt varchar(8), @v_billtoflag char(1)
if isnull(@shipper,'') in ('UNKNOWN','')
	select @@billto = 'UNKNOWN'
else
begin
	select @v_defaultbt = cmp_defaultbillto
	     , @v_billtoflag = cmp_billto
	  from company
	 where cmp_id = @shipper

	if @@ROWCOUNT = 0
		select @@billto = 'UNKNOWN'
	else
	begin
		if isnull(@v_defaultbt,'') in ('UNKNOWN','')
			select @@billto = case isnull(@v_billtoflag,'N') when 'Y' then @shipper else 'UNKNOWN' end
		else
			select @@billto = @v_defaultbt
	end
end

return 1

GO
GRANT EXECUTE ON  [dbo].[dx_get_default_billto] TO [public]
GO
