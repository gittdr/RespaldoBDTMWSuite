SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE 	PROCEDURE [dbo].[gettankdipdetails_sp] 
		  @cmp_id		varchar(8),
		  @tank_loc		varchar(10),
		  @tank_dip_date	datetime = NULL,
		  @tank_dip_shift	char(2)= NULL
AS

	/**
 * 
 * NAME:
 * gettankdipdetails_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns current company and tank details based on supplied criteria
 *
 * RETURNS: 	NONE
 *
 * RESULT SETS: Set of current company and tank details based on supplied criteria
 *
 * PARAMETERS:
 * @cmp_id		varchar(8)		Company ID for which to look up information (specific ID or UNKNOWN)	
 * @tank_loc		varchar(10)		Tank ID for specific location
 * @tank_dip_date	datetime = NULL		Date of current dip reading(s)
 * @tank_dip_shift	char(2)= NULL		Shift (AM/PM) for which to return tank details
 *
 *
 * REVISION HISTORY:
 * 10/6/2005.01 ? PTS29687 - Dan Hudec ? Created Procedure
 *
 **/

	DECLARE @tank_nbr		int

	SELECT @tank_nbr = tank_nbr
	FROM   tank
	WHERE  cmp_id = @cmp_id
	AND    tank_loc = @tank_loc

	SELECT 	a.cmp_id,
		a.cmp_name,
		a.cmp_address1,
		a.cmp_address2,
		a.cmp_city,
		a.cmp_zip,
		a.cmp_state,
		a.cmp_primaryphone,
		tank_loc,
		DATENAME(dw, tank_dip_date) weekday,
		tank_dip_date,
		tank_dip_shift,
		tank_dip,
		tank_inventoryqty,
		tank_ullageqty,
		tank_deliveredqty,
		ord_hdrnumber,
		tank_sales,
		(SELECT AVG(tank_sales)
		 FROM   tankdiphistory b
		 WHERE b.tank_nbr = @tank_nbr
		 AND    DATENAME(dw, b.tank_dip_date) = DATENAME(dw, d.tank_dip_date))
	FROM	company a, compinvprofile b, tank c, tankdiphistory d
	WHERE	a.cmp_id = b.cmp_id
	AND	b.cmp_id = c.cmp_id
	AND	c.tank_nbr = d.tank_nbr
	AND	a.cmp_id  = @cmp_id
	AND     tank_loc = @tank_loc
	AND     tank_dip_date = ISNULL(@tank_dip_date, tank_dip_date)
	AND	tank_dip_shift = ISNULL(@tank_dip_shift, tank_dip_shift)
	ORDER BY tank_dip_date, tank_loc

	RETURN 0
GO
GRANT EXECUTE ON  [dbo].[gettankdipdetails_sp] TO [public]
GO
