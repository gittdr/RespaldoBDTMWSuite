SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE 	PROCEDURE [dbo].[gettankcmplist_sp] 
		  @category		int = 2,
		  @dip_date		datetime = NULL,
		  @group_nbr		int = NULL,
		  @shift		char(2) = NULL,
		  @cmp_id		varchar(8) = NULL,
		  @status		int = 2

AS

/**
 * 
 * NAME:
 * gettankcmplist_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns result set of relevant companies based on certain criteria
 *
 * RETURNS: 	NONE
 *
 * RESULT SETS: Set of companies and their information based on category
 *		type, status type, date, group number, and shift ID.
 *
 * PARAMETERS:
 * @category	int		Category for companies chosen by user (numeric value)
 * @dip_date	datetime	Date for which to check for existing dip readings
 * @group_nbr	int		Group number assigned to companies that should be returned
 * @shift	char(2)		Shift (AM/PM) for which to check for existing dip readings
 * @cmp_id	varchar(8)	Company ID to return (specific ID or UNKNOWN)
 * @status	int = 2		Numeric value from application, used by the proc to determine result set
 *
 *
 * REVISION HISTORY:
 * 10/6/2005.01 ? PTS29687 - Dan Hudec ? Created Procedure
 *  8/2/2006.02 - PTS34109 - B Barker (Paul's Hauling) change to use dip log pts40762 JJF 20080428
 *
 **/

--8/2/2006.02 - PTS34109 - B Barker (Paul's Hauling) change to use dip log pts40762 JJF 20080428
DECLARE @v_gi_hours_setting	int

SELECT 	@v_gi_hours_setting = gi_string1
FROM	generalinfo
WHERE	gi_name = 'CurrentDipReadingHours'
--END 8/2/2006.02 - PTS34109 - B Barker (Paul's Hauling) change to use dip log pts40762 JJF 20080428

--	LOR	PTS# 25483
If @cmp_id = 'UNKNOWN' select @cmp_id = null
--

IF @status = 2
   SELECT @category = 2

IF @category = 2
BEGIN	/* record new dip */
	SELECT 	DISTINCT a.cmp_id,
		c.cmp_name,
		cmp_address1 = ISNULL(c.cmp_address1, ''),
		cmp_address2 = ISNULL(c.cmp_address2, ''),
		cty_name = ISNULL(d.cty_name, ''),
		cmp_state = ISNULL(c.cmp_state, ''),
		cmp_zip = ISNULL(c.cmp_zip, ''),
		c.cmp_primaryphone,
		a.cmp_group_nbr,
		a.cmp_lastsiteplandate,
		a.cmp_recommordersize,
                ''
	FROM compinvprofile a
			inner join tank b on a.cmp_id = b.cmp_id 
			inner join company c on a.cmp_id = c.cmp_id
			inner join city d on c.cmp_city = d.cty_code
	WHERE 	a.cmp_id = ISNULL(@cmp_id, a.cmp_id)
	  AND	a.cmp_group_nbr = ISNULL(@group_nbr, cmp_group_nbr)
	  AND 	b.tank_inuse = 'Y'
	  AND	b.tank_nbr NOT IN 
			--8/2/2006.02 - PTS34109 - B Barker (Paul's Hauling) change to use dip log pts40762 JJF 20080428
			/*(SELECT tank_nbr
			from tankdiphistory
			WHERE datepart(dy, tank_dip_date) = datepart(dy, @dip_date)
			AND tank_dip_shift = ISNULL(@shift, tank_dip_shift)
			AND tank_dip > 0)
			*/
			(SELECT tank_nbr
				FROM DipLog
				WhERE dl_date> dateadd(hh,-@v_gi_hours_setting,GETDATE())
				and dl_dipreading>0)
			--END 8/2/2006.02 - PTS34109 - B Barker (Paul's Hauling) change to use dip log pts40762 JJF 20080428

END	/* record new dip */
ELSE	
BEGIN	/* edit or view history */
	IF @status = 3
	BEGIN	/* dip recorded but not planned */
		SELECT 	DISTINCT a.cmp_id,
			c.cmp_name,
			cmp_address1 = ISNULL(c.cmp_address1, ''),
			cmp_address2 = ISNULL(c.cmp_address2, ''),
			cty_name = ISNULL(d.cty_name, ''),
			cmp_state = ISNULL(c.cmp_state, ''),
			cmp_zip = ISNULL(c.cmp_zip, ''),
			c.cmp_primaryphone,
			a.cmp_group_nbr,
			a.cmp_lastsiteplandate,
			a.cmp_recommordersize,
			--8/2/2006.02 - PTS34109 - B Barker (Paul's Hauling) change to use dip log pts40762 JJF 20080428
            --ord_number = ''
            ord_number = IsNull(o.ord_number,'')
			--END 8/2/2006.02 - PTS34109 - B Barker (Paul's Hauling) change to use dip log pts40762 JJF 20080428
		FROM compinvprofile a
				inner join tank b on a.cmp_id = b.cmp_id 
				inner join company c on a.cmp_id = c.cmp_id
				inner join city d on c.cmp_city = d.cty_code
				inner join tankdiphistory e on b.tank_nbr = e.tank_nbr
				--8/2/2006.02 - PTS34109 - B Barker (Paul's Hauling) change to use dip log pts40762 JJF 20080428
				left outer join orderheader o on o.ord_hdrnumber = e.ord_hdrnumber
				--END 8/2/2006.02 - PTS34109 - B Barker (Paul's Hauling) change to use dip log pts40762 JJF 20080428
		WHERE 	a.cmp_id = ISNULL(@cmp_id, a.cmp_id)
		  AND	a.cmp_group_nbr = ISNULL(@group_nbr, cmp_group_nbr)
		  AND	b.tank_inuse = 'Y'
		  AND	e.tank_dip_date >= ISNULL(@dip_date, tank_dip_date)
		  AND	e.tank_dip_shift = ISNULL(@shift, tank_dip_shift)
		  AND	e.ord_hdrnumber IS NULL
		  AND	ISNULL(e.tank_dip, 0) > 0
	END	/* dip recorded but not planned */
	IF @status = 4
	BEGIN	/* dip completed */
		SELECT 	DISTINCT a.cmp_id,
			c.cmp_name,
			cmp_address1 = ISNULL(c.cmp_address1, ''),
			cmp_address2 = ISNULL(c.cmp_address2, ''),
			cty_name = ISNULL(d.cty_name, ''),
			cmp_state = ISNULL(c.cmp_state, ''),
			cmp_zip = ISNULL(c.cmp_zip, ''),
			c.cmp_primaryphone,
			a.cmp_group_nbr,
			a.cmp_lastsiteplandate,
			a.cmp_recommordersize,
            ord_number
		FROM compinvprofile a
				inner join tank b on a.cmp_id = b.cmp_id 
				inner join company c on a.cmp_id = c.cmp_id
				inner join city d on c.cmp_city = d.cty_code
				inner join tankdiphistory e on b.tank_nbr = e.tank_nbr
				--8/2/2006.02 - PTS34109 - B Barker (Paul's Hauling) change to use dip log pts40762 JJF 20080428
				left outer join orderheader o on o.ord_hdrnumber = e.ord_hdrnumber
				--END 8/2/2006.02 - PTS34109 - B Barker (Paul's Hauling) change to use dip log pts40762 JJF 20080428
		WHERE 	a.cmp_id = ISNULL(@cmp_id, a.cmp_id)
		  AND	a.cmp_group_nbr = ISNULL(@group_nbr, cmp_group_nbr)
		  AND 	b.tank_inuse = 'Y'
		  AND	e.tank_dip_date >= ISNULL(@dip_date, tank_dip_date)
		  AND	e.tank_dip_shift = ISNULL(@shift, tank_dip_shift)
		  AND	IsNull(e.ord_hdrnumber,0) > 0
		  AND	ISNULL(e.tank_dip, 0) > 0
	END	/* dip completed */
	IF @status = 1
	BEGIN	/* all regardless the status */
		SELECT 	a.cmp_id,
			c.cmp_name,
			cmp_address1 = ISNULL(c.cmp_address1, ''),
			cmp_address2 = ISNULL(c.cmp_address2, ''),
			cty_name = ISNULL(d.cty_name, ''),
			cmp_state = ISNULL(c.cmp_state, ''),
			cmp_zip = ISNULL(c.cmp_zip, ''),
			c.cmp_primaryphone,
			a.cmp_group_nbr,
			a.cmp_lastsiteplandate,
			a.cmp_recommordersize,
            '' ord_number
		FROM compinvprofile a
				inner join tank b on a.cmp_id = b.cmp_id
				inner join company c on a.cmp_id = c.cmp_id
				inner join city d on c.cmp_city = d.cty_code
		WHERE	a.cmp_id = ISNULL(@cmp_id, a.cmp_id)
		  AND	a.cmp_group_nbr = ISNULL(@group_nbr, cmp_group_nbr)
		  AND 	b.tank_inuse = 'Y'
		  AND	b.tank_nbr NOT IN 
					(SELECT tank_nbr
					from tankdiphistory
					WHERE tank_nbr = b.tank_nbr
					AND tank_dip_date = @dip_date
					AND tank_dip_shift = ISNULL(@shift, tank_dip_shift)
					AND tank_dip > 0)
		UNION

		SELECT 	a.cmp_id,
			c.cmp_name,
			cmp_address1 = ISNULL(c.cmp_address1, ''),
			cmp_address2 = ISNULL(c.cmp_address2, ''),
			cty_name = ISNULL(d.cty_name, ''),
			cmp_state = ISNULL(c.cmp_state, ''),
			cmp_zip = ISNULL(c.cmp_zip, ''),
			c.cmp_primaryphone,
			a.cmp_group_nbr,
			a.cmp_lastsiteplandate,
			a.cmp_recommordersize,
			'' ord_number
		FROM compinvprofile a
				inner join tank b on a.cmp_id = b.cmp_id
				inner join company c on a.cmp_id = c.cmp_id
				inner join city d on c.cmp_city = d.cty_code
				inner join tankdiphistory e on b.tank_nbr = e.tank_nbr
		WHERE	a.cmp_id = ISNULL(@cmp_id, a.cmp_id)
		  AND	a.cmp_group_nbr = ISNULL(@group_nbr, cmp_group_nbr)
		  AND 	b.tank_inuse = 'Y'
		  AND	e.tank_dip_date >= ISNULL(@dip_date, tank_dip_date)
		  AND	e.tank_dip_shift = ISNULL(@shift, tank_dip_shift)
		  AND	ISNULL(e.tank_dip, 0) >= 0
	END	/* all regardless the status */
END	/* edit or view history */


RETURN 0
GO
GRANT EXECUTE ON  [dbo].[gettankcmplist_sp] TO [public]
GO
