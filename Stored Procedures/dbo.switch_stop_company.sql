SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[switch_stop_company] (@stpNumber int, @newCmpId varchar(20))
as

--
--	If the specified company is a member of a group, and a different member 
--	of the same	group is currently on the stop, switch the stop's company
--	to the specified one.
--
--
--	By design, this bypasses the user interface and business logic for company selection on a stop.
--	Examples of business logic that will not be enforced include but are not limited to:
--		Shipper/consignee identification
--		Load Requirements
--		Notes
--		Mileage
--		Autodetention Notification
--		Credit Terms
--		SetRevType1DefaultFrom
--		SetRevType2DefaultFrom
--		SetRevType3DefaultFrom
--		SetRevType4DefaultFrom
--		SetTermsDefaultFrom
--		SetPriorityDefaultFrom
--		SetSubCompanyDefaultFrom
--		SetContactDefaultFrom
--		SetCurrencyDefaultFrom


declare 
	@stpCmpId varchar(8),
	@stp_status varchar(6)

select @newCmpId = upper(isnull(@newCmpId, '')),
	@stpNumber = isnull(@stpNumber, 0)
if (@stpNumber = 0)
	BEGIN
	RAISERROR ('Stop Number not supplied.  Stop Number: %d; New Company Id: %s', 16, 1, @stpNumber, @newCmpId)
	RETURN
	END
if (@newCmpId = '' or @newCmpId = 'UNKNOWN')
	return -- No new company ID supplied; nothing to switch to.

select @stpCmpId = cmp_id, @stp_status = stp_status from stops where stp_number = @stpNumber
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

update stops
	set
		stops.cmp_id =@newCmpId,
		stops.cmp_name = company.cmp_name,
		stops.stp_address = company.cmp_address1,
		stops.stp_address2 = company.cmp_address2,
		stops.stp_city = company.cmp_city,
		stops.stp_state = company.cmp_state,
		stops.stp_country = company.cmp_country,
		stops.stp_region1 = company.cmp_region1,
		stops.stp_region2 = company.cmp_region2,
		stops.stp_region3 = company.cmp_region3,
		stops.stp_region4 = company.cmp_region4,
		stops.stp_phonenumber = company.cmp_primaryphone,
		stops.stp_phonenumber2 = company.cmp_secondaryphone,
		stops.stp_contact = company.cmp_contact
	from company
	where stp_number = @stpNumber
		and company.cmp_id = @newCmpId

GO
GRANT EXECUTE ON  [dbo].[switch_stop_company] TO [public]
GO
