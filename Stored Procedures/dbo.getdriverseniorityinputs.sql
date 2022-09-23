SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[getdriverseniorityinputs] @lgh_number int, @mpp_id varchar(8), @ord_hdrnumber int
AS

DECLARE
	@company char(4), 
	@driverotherid char(9), 
	@lgh_startdate char(23), 
	@payrollctrlgrp char(4),
	@billto varchar(8)
	
BEGIN

if	isnull(@lgh_number, 0) = 0
	select 	@lgh_startdate = lgh_startdate
	from	legheader
	where	lgh_number = (select min(lgh_number) from legheader where ord_hdrnumber = @ord_hdrnumber)
else
	select	@ord_hdrnumber = ord_hdrnumber,
			@lgh_startdate = lgh_startdate
	from	legheader
	where	lgh_number = @lgh_number

select	@billto = isnull(ord_billto, 'UNKNOWN')
from	orderheader
where	ord_hdrnumber = @ord_hdrnumber

select	@company = substring(isnull(cmp_altid, ''), 0, charindex('_', isnull(cmp_altid, '')))
from	company
where	cmp_id = @billto

select	@driverotherid = mpp_otherid
from	manpowerprofile
where	mpp_id = @mpp_id

select	@payrollctrlgrp = col_data
from	extra_info_data
where	table_key = @billto
and		col_id = (select gi_integer1 from generalinfo where gi_name = 'PayrollControlGroupColID')

select isnull(@company, ''), isnull(@driverotherid, ''), isnull(@lgh_startdate, '1900-01-01 00:00:00.000'), isnull(@payrollctrlgrp, '')
END
GO
GRANT EXECUTE ON  [dbo].[getdriverseniorityinputs] TO [public]
GO
