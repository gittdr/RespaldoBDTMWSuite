SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE	procedure [dbo].[set_firm_appointment_flag_part1_sp]  @stp_number int, @rtn_value char(1) output
AS 

/**
 *
 * NAME:
 * dbo.set_firm_appointment_flag_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * For drop events only on a stop, return null or 'Y' to set the firm_appointment_flag
 * PTS 41569 - GAP 47  6-9-2008
 *
 * RETURNS:
 * @rtn_value as output (possible return values = null or 'Y')
 *
 * Expected Table Values for cmp_firm_appt_value and/or brn_firm_appt_value are:
 *		NULL, UNKNOWN, ALL_UNLOADS, FIRST_UNLOAD, NEVER, CHECK_BRANCH (this value on comp table only)
 *
 **/


select	ord_hdrnumber, stp_mfh_sequence, 
		stp_firm_appt_flag, stp_event, stp_type, cmp_id, 
(select cmp_firm_appt_value from company where company.cmp_id = stops.cmp_id) as 'cmp_firm_appt_value',
(select ord_booked_revtype1 from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber) as 'branch_id',
(select brn_firm_appt_value from branch
		where brn_id = (select ord_booked_revtype1 from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber) ) as 'brn_firm_appt_value'
into #temp_firm_appts
from stops where stops.stp_number = @stp_number
--and stp_firm_appt_flag is null 
and stp_type = 'DRP'

declare @ord_hdrnumber int
declare @cmp_id varchar(8)
declare @brn_id varchar(12)
declare @first_drop char(1)
declare @first_LUL int
declare @stp_mfh_sequence int

set @ord_hdrnumber = ( select ord_hdrnumber from #temp_firm_appts )
set @cmp_id = ( select cmp_id from #temp_firm_appts )
set @stp_mfh_sequence = (select stp_mfh_sequence from #temp_firm_appts )

set @brn_id = ( select ord_booked_revtype1 from orderheader where orderheader.ord_hdrnumber = @ord_hdrnumber)
set @first_LUL = (select min(stp_mfh_sequence) from stops where ord_hdrnumber = @ord_hdrnumber and stp_event = 'LUL' )


set @first_drop = 'N'
IF @stp_mfh_sequence = @first_LUL 
	BEGIN
		set @first_drop = 'Y'
	END  


Exec set_firm_appointment_flag_part2_sp  @cmp_id,  @brn_id, @first_drop,  @rtn_value  output


RETURN 


GO
GRANT EXECUTE ON  [dbo].[set_firm_appointment_flag_part1_sp] TO [public]
GO
