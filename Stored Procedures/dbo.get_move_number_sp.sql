SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[get_move_number_sp]
	@type smallint, 
	--PTS 60171 JJF 20120227 accomodate driver name
	--@number varchar(13)
	@number varchar(55)
	--END PTS 60171 JJF 20120227
as

declare
	@move_number   int,
        @lgh_number    int,
	@numbervalue   int,
	@num_moves	int

-- default to not found
SELECT @move_number = -1

If @type in (3, 4)
	SELECT @numbervalue = convert(int, @number)

if @type = 1														-- order
	BEGIN													
		SELECT 	@num_moves = COUNT(distinct stops.mov_number)
		FROM	stops, orderheader
		WHERE	stops.ord_hdrnumber = orderheader.ord_hdrnumber
		  AND	orderheader.ord_number = @number
	IF @num_moves <= 1
		SELECT DISTINCT @move_number = mov_number
		  FROM orderheader
		 WHERE ord_number = @number
	ELSE
		SELECT @move_number = -2 -- indicate that this is cross docked
	END
else if @type = 2													-- invoice
		SELECT @move_number = orderheader.mov_number
		  FROM orderheader, invoiceheader
		 WHERE ivh_invoicenumber = @number AND
		       orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber
else if @type = 3													-- movement
		SELECT @move_number = @numbervalue
else if @type = 4													-- tripsegment
		SELECT DISTINCT @move_number = mov_number
		  FROM stops
		 WHERE lgh_number = @numbervalue
else if @type = 5													-- driver
		EXECUTE @move_number = cur_activity  'DRV', @number, @lgh_number
else if @type = 6													-- tractor
		EXECUTE @move_number = cur_activity  'TRC', @number, @lgh_number
else if @type = 7 													-- trailer
		EXECUTE @move_number = cur_activity  'TRL', @number, @lgh_number
else if @type = 8 													-- reference
		SELECT DISTINCT @move_number = mov_number
		  FROM stops
		 WHERE stp_refnum = @number
-- KM 3-1-99 PTS 5180 - Carrier ID
else if @type = 9
		EXECUTE @move_number = cur_activity  'CAR', @number, @lgh_number
-- END PTS 5180
--PTS 60171 JJF 20120227
else if @type = 14 BEGIN
	SELECT TOP 1 @number = mpp_id
	FROM	manpowerprofile
	WHERE	mpp_lastfirst + ': ' + mpp_id = @number
	
	EXECUTE @move_number = cur_activity  'DRV', @number, @lgh_number
END	
--END PTS 60171 JJF 20120227
return @move_number
GO
GRANT EXECUTE ON  [dbo].[get_move_number_sp] TO [public]
GO
