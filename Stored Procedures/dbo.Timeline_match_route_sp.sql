SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE PROC [dbo].[Timeline_match_route_sp]
	@tlh_number int
AS

/**
 * 
 * NAME:
 * dbo.Timeline_match_route_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * You really don't want to know.
  *
 * RETURNS: 
 *	-1
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @tlh_number int  			timeline to copy.
 * 002 - @tlh_effective datetime		Effective date of the new timeline
 * 003 - @tlh_expires datetime			Expiration date of teh new timeline
 * 
 * REVISION HISTORY:
 * 06/14/2006.01 - MRH ? Created
**/

-- Figure out the min / max dates that can be on the master order

-- Use the expirations route and pup / drp to find the appropreate Master order.
declare @tld_number int
declare @ord_hdrnumber int
declare @tld_origin varchar(8)
declare @tld_dest varchar(8)
declare @tld_route varchar(15)
declare @branch varchar(12)
declare @v_user VARCHAR(255)
declare @v_msg VARCHAR(255)
declare @arrivelead int
declare @departlead int
declare @direction char(1)
declare @tlh_effective datetime
declare @tlh_expires datetime

EXEC gettmwuser @v_user OUTPUT
SET @v_user = LEFT(@v_user, 10) --30581

select @direction = tlh_direction, @tlh_effective = tlh_effective, @tlh_expires = tlh_expires from timeline_header where tlh_number = @tlh_number

-- expire routes at xxxx-xx-xx 23:59:59
select @tlh_expires = dateadd(n, 23*60+59, @tlh_expires)
select @tlh_expires = dateadd(s, 59, @tlh_expires)

select @tld_number = min(tld_number) from timeline_detail where tlh_number = @tlh_number
while @tld_number is not null
begin

-- Validate that the lead days will not invalidate the master order. 
	select @tld_route = tld_route, @tld_origin = tld_origin, @tld_dest = tld_dest from timeline_detail where tld_number = @tld_number
	select @arrivelead = max(tld_arrive_dest_lead) from timeline_detail where tlh_number = @tlh_number
	select @departlead = max(tld_arrive_orig_lead) from timeline_detail where tlh_number = @tlh_number

	if @direction = 'P'
		select @ord_hdrnumber = ord_hdrnumber from orderheader where ord_route = @tld_route and ord_status = 'MST' and ord_hdrnumber in 
			(select ord_hdrnumber from stops where (cmp_id = @tld_origin and stp_type = 'PUP')) and ord_hdrnumber in (select ord_hdrnumber from stops where (cmp_id = @tld_dest and stp_type = 'DRP'))
			and ord_route_effc_date >= @tlh_effective and (dateadd(d, @departlead, ord_route_exp_date) <= @tlh_expires)
	else
		select @ord_hdrnumber = ord_hdrnumber from orderheader where ord_route = @tld_route and ord_status = 'MST' and ord_hdrnumber in 
			(select ord_hdrnumber from stops where (cmp_id = @tld_origin and stp_type = 'PUP')) and ord_hdrnumber in (select ord_hdrnumber from stops where (cmp_id = @tld_dest and stp_type = 'DRP'))
			and (dateadd(d, -@arrivelead, ord_route_effc_date) >= @tlh_effective) and ord_route_exp_date <= @tlh_expires


	if @ord_hdrnumber is not null
		update timeline_detail set tld_master_ordnum = @ord_hdrnumber where tld_number = @tld_number
	else
	begin
		-- Log the error.
		SET @v_msg = 'No master order match for timeline detail.  Timeline: ' + convert(varchar(30), @tlh_number)
		INSERT INTO tts_errorlog (
			  err_batch   
			, err_user_id 
			, err_message                                                                                                                                                                                                                                               
     
			, err_date                                               
			, err_number  
			, err_title
			, err_type)
		VALUES (
			  0
			, @v_user
			, @v_msg
			, GETDATE()
			, 10110
			, 'Timeline Route Match'
			, 'TLR')
	end

	select @tld_number = min(tld_number) from timeline_detail where tlh_number = @tlh_number and tld_number > @tld_number

end
GO
GRANT EXECUTE ON  [dbo].[Timeline_match_route_sp] TO [public]
GO
