SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[tmw_isserverindstmode_sp] @servermode char(1) output, @servergmtoffset int output
as

declare @standard_timeoffset 	decimal(2),
	@getdate		datetime,
	@getutcdate		datetime,	
	@curgmtdelta		int


begin
select @standard_timeoffset = convert(decimal(2), gi_string1),
	@getdate = getdate(),
	@getutcdate = getutcdate()
from	generalinfo
where 	gi_name = 'SysTZ'

select @curgmtdelta = datediff(hh, @getutcdate, @getdate)
select @servergmtoffset = @standard_timeoffset


If @curgmtdelta = @standard_timeoffset
	SELECT @servermode = 'N'
  else
	SELECT @servermode = 'Y'
end
GO
GRANT EXECUTE ON  [dbo].[tmw_isserverindstmode_sp] TO [public]
GO
