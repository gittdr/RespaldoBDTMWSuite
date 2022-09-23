SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[tmail_switch_stop_company] (@stpNumber int, @newCmpId varchar(25))-- PTS 61189 enhance cmp_id to 25 length
as

/***
	If the specified company is a member of a group, and a different member 
	of the same	group is currently on the stop, switch the stop's company
	to the specified one.
***/

declare 
	@cmp_mastercompany varchar(8),
	@cmp_parent char(1),
	@newCmpName varchar(30),
	@newMasterCompany varchar(8),
	@stpCmpId varchar(25),-- PTS 61189 enhance cmp_id to 25 length
	@groupCmpId varchar(25),-- PTS 61189 enhance cmp_id to 25 length
	@stp_status varchar(6)

if not (select upper(gi_string1) from generalinfo (NOLOCK) where gi_name = 'TMSwitchStpCmpWithinGrp') = 'Y'
	RETURN

select @newCmpId = upper(isnull(@newCmpId, '')),
	@stpNumber = isnull(@stpNumber, 0)
if (@stpNumber = 0)
	BEGIN
	RAISERROR ('Stop Number not supplied.  Stop Number: %d; New Company Id: %s', 16, 1, @stpNumber, @newCmpId)
	RETURN
	END
if (@newCmpId = '' or @newCmpId = 'UNKNOWN')
	return -- No new company ID supplied; nothing to switch to.

select @stpCmpId = cmp_id, @stp_status = stp_status from stops (NOLOCK) where stp_number = @stpNumber
set @stpCmpId = upper(isnull(@stpCmpId, ''))
set @stp_status = upper(isnull(@stp_status, ''))
if (@stp_status <> 'OPN') 
	BEGIN
	RAISERROR ('Stop is not open; cannot update stop.  Stop Number: %d; Stop Status: %s; New Company Id: %s', 16, 1, @stpNumber, @stp_status, @newCmpId)
	RETURN
	END
if (@stpCmpId = '' or @stpCmpId = 'UNKNOWN')
	BEGIN
	RAISERROR ('Stop is not at a company; cannot switch stop to a company.  Stop Number: %d; New Company Id: %s', 16, 1, @stpNumber, @newCmpId)
	RETURN
	END

if (@stpCmpId = @newCmpId)
	return -- New company same as old; no switch needed.

select @cmp_mastercompany = cmp_mastercompany, @cmp_parent = cmp_parent from company (NOLOCK) where cmp_id = @stpCmpId
set @cmp_mastercompany = isnull(@cmp_mastercompany, '')
if (upper(@cmp_parent) = 'Y')
	set @groupCmpId = upper(@stpCmpId)
else
	set @groupCmpId = upper(@cmp_mastercompany)
if (@groupCmpId = '' or @groupCmpId = 'UNKNOWN')
	BEGIN
	RAISERROR ('Stop is not at a grouping or member company; cannot switch stop''s company.  Stop Number: %d; Stop''s Company ID: %s; New Company Id: %s', 16, 1, @stpNumber, @stpCmpId, @newCmpId)
	RETURN
	END

select @newMasterCompany = cmp_mastercompany, 
	@newCmpName = cmp_name 
	from company where cmp_id = @newCmpId and isnull(cmp_billto,'N') <> 'Y'
set @newMasterCompany = isnull(@newMasterCompany, '')
if @newMasterCompany <> @groupCmpId
	BEGIN
	RAISERROR ('New company is not a member of the stop company''s group or is a bill-to.  Stop Number: %d; Stop''s Company ID: %s; Stop''s Group: %s; New Company Id: %s; New Group: %s', 16, 1, @stpNumber, @stpCmpId, @groupCmpId, @newCmpId, @newMasterCompany)
	RETURN
	END

exec dbo.switch_stop_company @stpNumber, @newCmpId

GO
GRANT EXECUTE ON  [dbo].[tmail_switch_stop_company] TO [public]
GO
