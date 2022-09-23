SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

Create proc [dbo].[ConsolidateTripsGE] (
	@FirstOrd_hdrnumber int,
	@SecondOrd_hdrnumber int,
	@Return INT OUTPUT)
AS
-- Error returns
--  -1 Order 1 not found or is split (more or less than one leg header)
--  -2 Order 2 not found or is split (more or less than one leg header)
--  -3 Tractor already assigned to trip
--  -4 Trailer already assigned to trip
--  -5 Driver1 already assinged to trip
--  -6 Driver2 already assigned to trip
--  -7 2nd trip has a TR number.
BEGIN
Declare @stpmfhSequence int
Declare @stpSequence int
Declare @movnumber int
Declare @lghnumber1 int
Declare @lghnumber2 int
Declare @tractor varchar(8)
Declare @trailer1 varchar(13)
Declare @driver1 varchar(8)
Declare @driver2 varchar(8)
Declare @maxSequence int
Declare @evt_number int
Declare @cmp_id1 varchar(8)
Declare @cmp_id2 varchar(8)

select @Return = 0
-- Verify trips exist and are not split
if (Select count(0) from legheader where ord_hdrnumber = @FirstOrd_hdrnumber) <> 1
	select @Return = -1
if (Select count(0) from legheader where ord_hdrnumber = @SecondOrd_hdrnumber) <> 1
	select @Return = -2
-- Check for resources on the second trip
if (Select count(0) from legheader where ord_hdrnumber = @SecondOrd_hdrnumber and isnull(lgh_tractor, 'UNKNOWN') <> 'UNKNOWN') > 0
	select @Return = -3
if (Select count(0) from legheader where ord_hdrnumber = @SecondOrd_hdrnumber and isnull(lgh_primary_trailer, 'UNKNOWN') <> 'UNKNOWN') > 0
	select @Return = -4
if (Select count(0) from legheader where ord_hdrnumber = @SecondOrd_hdrnumber and isnull(lgh_driver1, 'UNKNOWN') <> 'UNKNOWN') > 0
	select @Return = -5
if (Select count(0) from legheader where ord_hdrnumber = @SecondOrd_hdrnumber and isnull(lgh_driver2, 'UNKNOWN') <> 'UNKNOWN') > 0
	select @Return = -6
-- Check for a TR number on the second trip
if (Select count(0) from orderheader where ord_hdrnumber = @SecondOrd_hdrnumber and isnull(ord_reftype, '') = 'TR') > 0
	select @Return = -7
-- Probably should check the trip status....
if @Return <> 0
	Return @Return

-- Get working vars
select @movnumber = (select mov_number from legheader where ord_hdrnumber = @FirstOrd_hdrnumber)
select @lghnumber1 = (select lgh_number from legheader where ord_hdrnumber = @FirstOrd_hdrnumber)
select @stpmfhSequence = (select max(stp_mfh_sequence) from stops where ord_hdrnumber = @FirstOrd_hdrnumber)
select @stpSequence = (select max(stp_sequence) from stops where ord_hdrnumber = @FirstOrd_hdrnumber)
select @lghnumber2 = (select lgh_number from legheader where ord_hdrnumber = @SecondOrd_hdrnumber)
select @driver1 = (select lgh_driver1 from legheader where ord_hdrnumber = @FirstOrd_hdrnumber)
select @driver2 = (select lgh_driver2 from legheader where ord_hdrnumber = @FirstOrd_hdrnumber)
select @tractor = (select lgh_tractor from legheader where ord_hdrnumber = @FirstOrd_hdrnumber)
select @trailer1 = (select lgh_primary_trailer from legheader where ord_hdrnumber = @FirstOrd_hdrnumber)
select @maxSequence = (select max(stp_mfh_sequence) from stops where ord_hdrnumber = @SecondOrd_hdrnumber)
select @cmp_id1 = (select cmp_id from stops where ord_hdrnumber = @FirstOrd_hdrnumber and stp_mfh_sequence = @stpmfhSequence)
select @cmp_id2 = (select cmp_id from stops where ord_hdrnumber = @SecondOrd_hdrnumber and stp_mfh_sequence = @maxSequence)

-- Compair company on the last stop on the first trip with the first stop on the last trip
--  if they are the same, delete the last stop on the first trip.
Begin tran
if @cmp_id1 = @cmp_id2
Begin
	-- The companies are the same delete the stop and events. 
	-- There should not be frieght. (could test)
	-- Test to validate event (could test)
	Delete from event where stp_number = (select stp_number from stops where ord_hdrnumber = @FirstOrd_hdrnumber and stp_mfh_sequence = @stpmfhSequence)
	Delete from stops where ord_hdrnumber = @FirstOrd_hdrnumber and stp_mfh_sequence = @stpmfhSequence
	select @stpmfhSequence = @stpmfhSequence - 1
End

-- Update the stops
update stops set stp_mfh_sequence = stp_mfh_sequence + @stpmfhSequence, stp_sequence = stp_sequence + @stpSequence,
	ord_hdrnumber = @FirstOrd_hdrnumber, lgh_number = @lghnumber1, mov_number = @movnumber
	where ord_hdrnumber = @SecondOrd_hdrnumber

-- Update the events
update event set ord_hdrnumber = @FirstOrd_hdrnumber, evt_mov_number = @movnumber,
	evt_driver1 = @driver1, evt_driver2 = @driver2, evt_tractor = @tractor, evt_trailer1 = @trailer1
	where ord_hdrnumber = @SecondOrd_hdrnumber

-- Update the freight
--update freightdetail set ord_hdrnumber = @FirstOrd_hdrnumber, lgh_number = @lghnumber1, mov_number = @movnumber
--	where ord_hdrnumber = @SecondOrd_hdrnumber

-- Delete the orderheader
Delete orderheader where ord_hdrnumber = @SecondOrd_hdrnumber

-- delete the legheader
Delete legheader where lgh_number = @lghnumber2

-- No need to change the orderheader at this time.
--    Correct TR number is in the remaining ord_refnumber
-- Reference number table should alread refer to the correct order.
commit tran
exec update_move @movnumber

END
GO
GRANT EXECUTE ON  [dbo].[ConsolidateTripsGE] TO [public]
GO
