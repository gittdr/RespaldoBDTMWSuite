SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[extrainfo_driverdata_data_sp] (@ord_hdrnumber INT, @mpp_id varchar(8))
AS

/**
 * NAME:
 * extrainfo_driverdata_data_sp
 * 
 * TYPE:
 * StoredProcedure
 * 
 * DESCRIPTION:
 * Update an ExtraInfo field (user defined via GeneralInfo setting) with information from the Driver Profile.
 * 
 * RETURN:
 * None.
 * 
 * RESULT SETS:
 * 	None.

 * PARAMETERS:
 * 01 @ord_hdrnumber	Integer		Order Header number
 * 02 @mpp_id		varchar(8)	Driver Id.

 * REFERENCES: (called by and calling references only, don't include table/view/object references)
 * CalledBy001 ? Trigger it_ordersave on Order Header table.
 

 * REVISION HISTORY:
 * 09/13/05 - PTS 27820 - Doug McRower - Initial release.

**/

Declare	@extra_id	int,
	@tab_id		int,
	@col_id		int,
	@col_row	int,
	@driver_phone	varchar(50)

Select @extra_id = gi_integer1,
	@tab_id = gi_integer2,
	@col_id = gi_integer3,
	@col_row = gi_integer4
from generalinfo
where gi_name = 'ExtraInfoData_driver'	
	and gi_string1 = 'Y'

select @driver_phone = isnull(mpp.mpp_alternatephone,'0000000000')
from manpowerprofile mpp
where mpp_id = @mpp_id

if exists (select 1 from extra_info_data where extra_id = @extra_id
		and tab_id = @tab_id
		and col_id = @col_id 
		and table_key = @ord_hdrnumber)

	Update extra_info_data
	set col_data = @driver_phone
	where extra_id = @extra_id
		and tab_id = @tab_id
		and col_id = @col_id 
		and table_key = @ord_hdrnumber
	

else
	Insert Into extra_info_data (extra_id, tab_id,col_id, col_data, table_key, col_row)
	Values(@extra_id,@tab_id,@col_id, @driver_phone, @ord_hdrnumber, @col_row)


GO
GRANT EXECUTE ON  [dbo].[extrainfo_driverdata_data_sp] TO [public]
GO
