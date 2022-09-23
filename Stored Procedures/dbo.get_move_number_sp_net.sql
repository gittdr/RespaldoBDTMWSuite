SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[get_move_number_sp_net]
	@type smallint, 
	@number varchar(100)
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
	IF @num_moves > 1
	BEGIN
		SELECT	TOP 1 @move_number = s.mov_number
		  FROM	orderheader oh
					INNER JOIN event e on e.ord_hdrnumber = oh.ord_hdrnumber
					INNER JOIN stops s on s.stp_number = e.stp_number
					INNER JOIN (SELECT	s.mov_number, e.ord_hdrnumber, MAX(CASE WHEN e.stp_mfh_number IS NULL THEN s.mfh_number ELSE e.stp_mfh_number END) mfh_number 
								  FROM	orderheader oh
											INNER JOIN event e ON e.ord_hdrnumber = oh.ord_hdrnumber
											INNER JOIN stops s ON s.stp_number = e.stp_number
								 WHERE	oh.ord_number = @number GROUP BY s.mov_number, e.ord_hdrnumber) m ON m.mov_number = s.mov_number and m.ord_hdrnumber = e.ord_hdrnumber 
		 WHERE	oh.ord_number = @number
		   AND	s.stp_status = 'OPN'
		ORDER BY m.mfh_number, s.stp_mfh_sequence

		IF ISNULL(@move_number, -1) = -1
		BEGIN
			SELECT DISTINCT @move_number = mov_number
			  FROM orderheader
			 WHERE ord_number = @number
		END
	END
	ELSE
	BEGIN
		SELECT DISTINCT @move_number = mov_number
		  FROM orderheader
		 WHERE ord_number = @number
	END
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
		SELECT @move_number = (SELECT DISTINCT  mov_number
		  from 	orderheader AS o INNER JOIN referencenumber AS r ON 
		r.ref_tablekey = o.ord_hdrnumber
	where   r.ref_number = @number and
	      	r.ref_table = 'orderheader')
-- KM 3-1-99 PTS 5180 - Carrier ID
else if @type = 9
		EXECUTE @move_number = cur_activity  'CAR', @number, @lgh_number
-- END PTS 5180

return @move_number
GO
GRANT EXECUTE ON  [dbo].[get_move_number_sp_net] TO [public]
GO
