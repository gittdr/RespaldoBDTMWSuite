SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[get_overridedate] @overridetype char(3), @ord_hdrnumber int, @override_datetime datetime output
AS   


/*	This stored procedure is to find and output the invoice effective date based on the order's billto
	setting stored in the company.cmp_schdearliestdateoverride field
	created by:		NQIAO
	create date:	12/15/2012
	PTS:			62179
*/

declare @billto			varchar(8),
	@cmp_overridecode	char(1),
	@stp_sequence		int,
	@mov_number		INTEGER

select @override_datetime = null

if @ord_hdrnumber > 0 	
	if @overridetype = 'INV'	-- get invoice effective date code	
		select	@cmp_overridecode = isnull(cmp_schdearliestdateoverride, '')
		from	company
		where	cmp_id = (select ord_billto from orderheader where ord_hdrnumber = @ord_hdrnumber)
	else if @overridetype = 'AVG'
		select	@cmp_overridecode = isnull(cmp_avgfuelpricedateoverride, '')
		from	company
		where	cmp_id = (select ord_billto from orderheader where ord_hdrnumber = @ord_hdrnumber)

if @cmp_overridecode > '' 
begin
	if @cmp_overridecode = 'A'		-- departure last stop: last stops.stp_departuredate for DRP
		begin
			select	@stp_sequence = max(stp_sequence)
			from	stops
			where	ord_hdrnumber = @ord_hdrnumber
			and		stp_type = 'DRP'
			
			select	@override_datetime = stp_departuredate
			from	stops
			where	ord_hdrnumber = @ord_hdrnumber
			and		stp_sequence = @stp_sequence
			and		stp_type = 'DRP'
		end
	
	else if @cmp_overridecode = 'B'	-- book date: orderheader.ord_bookdate
		select	@override_datetime = ord_bookdate
		from	orderheader
		where	ord_hdrnumber = @ord_hdrnumber
	
	else if @cmp_overridecode = 'D'	-- last delivery arrival date: last stops.stp_arrivaldate for DRP
		begin
			select	@stp_sequence = max(stp_sequence)
			from	stops
			where	ord_hdrnumber = @ord_hdrnumber
			and		stp_type = 'DRP'
			
			select	@override_datetime = stp_arrivaldate
			from	stops
			where	ord_hdrnumber = @ord_hdrnumber
			and		stp_sequence = @stp_sequence
			and		stp_type = 'DRP'
		end
		
	else if @cmp_overridecode = 'F'	-- arrival first stop: first stops.stp_arrivaldate for PUP
		begin
			select	@stp_sequence = min(stp_sequence)
			from	stops
			where	ord_hdrnumber = @ord_hdrnumber
			and		stp_type = 'PUP'
			
			select	@override_datetime = stp_arrivaldate
			from	stops
			where	ord_hdrnumber = @ord_hdrnumber
			and		stp_sequence = @stp_sequence
			and		stp_type = 'PUP'
		end
	
	else if @cmp_overridecode = 'I'	-- departure first stop: first stops.stp_departuredate for PUP
		begin
			select	@stp_sequence = min(stp_sequence)
			from	stops
			where	ord_hdrnumber = @ord_hdrnumber
			and		stp_type = 'PUP'
			
			select	@override_datetime = stp_departuredate
			from	stops
			where	ord_hdrnumber = @ord_hdrnumber
			and		stp_sequence = @stp_sequence
			and		stp_type = 'PUP'
		end

	else if @cmp_overridecode = 'M' --departure date from the last stop on the move that the last order stop is on.
	begin
		SELECT @mov_number = mov_number
		  FROM stops
		 WHERE ord_hdrnumber = @ord_hdrnumber AND
		       stp_sequence = (SELECT MAX(stp_sequence)
		                         FROM stops
		                        WHERE ord_hdrnumber = @ord_hdrnumber)
		IF @mov_number > 0
		BEGIN
			SELECT @override_datetime = stp_departuredate
			  FROM stops
			 WHERE mov_number = @mov_number AND
			       stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
			                             FROM stops
			                            WHERE mov_number = @mov_number)
		END
	end
	
	else if @cmp_overridecode = 'N'	-- default
		select	@override_datetime = @override_datetime
	
	else if @cmp_overridecode = 'P'	-- first pickup scheduled date: first stops.stp_schdearliest for PUP
		begin
			select	@stp_sequence = min(stp_sequence)
			from	stops
			where	ord_hdrnumber = @ord_hdrnumber
			and		stp_type = 'PUP'
			
			select	@override_datetime = stp_schdtearliest
			from	stops
			where	ord_hdrnumber = @ord_hdrnumber
			and		stp_sequence = @stp_sequence
			and		stp_type = 'PUP'
		end
		
	else if @cmp_overridecode = 'V'	-- available date: orderheader.ord_availabledate
		select	@override_datetime = ord_availabledate
		from	orderheader
		where	ord_hdrnumber = @ord_hdrnumber
	
	else if @cmp_overridecode = 'Y'	-- earliest scheduled stop: first stops.stp_schdearliest for stp_sequence = 1 regardless the type
		select	@override_datetime = stp_schdtearliest
		from	stops
		where	ord_hdrnumber = @ord_hdrnumber
		and		stp_sequence = 1
end

GO
GRANT EXECUTE ON  [dbo].[get_overridedate] TO [public]
GO
