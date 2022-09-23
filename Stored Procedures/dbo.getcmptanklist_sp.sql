SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE 	PROCEDURE [dbo].[getcmptanklist_sp] 
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
 * getcmptanklist_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns result set of relevant tanks based on certain criteria
 *
 * RETURNS: 	NONE
 *
 * RESULT SETS: Set of tanks and their information based on category
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
 *
 * 04/10/2006  ? PTS32542 - AuthorName ? Revision - wnat diplog date of dip returned instead of the updated on date
 *               pick up delivered quantity  from diplog . Sales used to be kept on
 *               tnak dip history, but is now on diplog and thee is no need to retrieve
 *               since it not displayed and the sales for the dip readin on this
 *               window will be computed once the dip is entered.
 * 05/18/2006 - PTS32885 - PRB - Made an alteration due to PH writting records into the diplog table.  dip was
 *                               coming in o.k. but the ullage was not.  Fixed status 3 to handle new situation
 *                               this will need redone when PH joins core.
 *
 * 07/21/06 - PTS 33840 - Brad Barker changes to sort sequence
 **/

--PTS 40762 JJF 20080409 centralize declare
	DECLARE @v_tank_dip_date 	datetime,
		@v_temp_tank_nbr	int,
		@v_gi_hours_setting	int,
		@v_hours_diff		int,
		@v_temp_dip		int,
		@v_number_rows		int,
		@v_i			int
	DECLARE @v_diplogdate	datetime
	DECLARE	--Added These PRB
		@v_tank_ullageqty INT,
		@v_tank_inventoryqty INT,
		@v_tank_deliveredqty INT,
		@v_tank_sales INT,
		@v_high_dip INT,
		@v_temp_tank_loc VARCHAR(10),
		@v_tank_model_id VARCHAR(12)

--END PTS 40762 JJF 20080409 centralize declare

CREATE TABLE #TEMP (
	cmp_id			varchar(8) NULL,
	cmp_name		varchar(100) NULL,
	cmp_address1		varchar(100) NULL,
	cmp_address2		varchar(100) NULL,
	cty_name		varchar(18) NULL,
	cmp_state		varchar(6) NULL,
	cmp_zip			varchar(10) NULL,
	cmp_primaryphone	varchar(20) NULL,
	cmp_group_nbr		tinyint NULL,
	cmp_lastsiteplandate	datetime NULL,
	cmp_recommordersize	int NULL,
	tank_loc		varchar(10) NULL,
	cmd_name		varchar(60) NULL,
	cmd_code		varchar(8) NULL,
	tank_nbr		int NULL,
	ordered_volume		int NULL,
	ordered_weight		int NULL,
	tank_model_id		varchar(12) NULL,
	tank_dip_date		datetime NULL,
	dip			smallint NULL,
	inventory		int NULL,
	ullage			int NULL,
	delivered		int NULL,
	tank_dip_shift		char(2) NULL,
	tank_highdip		smallint NULL,
	tank_warndip		smallint NULL,
	tank_lowdip		smallint NULL,
	tank_dip_unit		varchar(6) NULL,
	tank_capacity		int NULL,
	tank_cap_unit		varchar(6) NULL,
	ord_hdrnumber		int NULL,
	dip_level		int NULL,
	tank_sales		int NULL
	)

--PTS 40762 JJF 20080409
SELECT 	@v_gi_hours_setting = gi_string1
FROM	generalinfo
WHERE	gi_name = 'CurrentDipReadingHours'

if @group_nbr = 0  select @group_nbr = NULL
--END PTS 40762 JJF 20080409

--	LOR	PTS# 25483
If @cmp_id = 'UNKNOWN' select @cmp_id = null
--

IF @status = 2
   SELECT @category = 2

--PTS 40762 JJF 20080409
/*Added to allow use of status 3 for Edit Dip/View Dip PRB */

IF @status = 1
  SELECT @status = 3

IF @category = 5
  SELECT @status = 3 
-- END PRB
--END PTS 40762 JJF 20080409

IF @category = 2
BEGIN	/* record new dip */
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
		b.tank_loc,
		e.cmd_name,
		e.cmd_code,
		b.tank_nbr,
		0 ordered_volume,
		0 ordered_weight,
		b.tank_model_id,
		@dip_date tank_dip_date,
		null dip,
		null inventory,
		null ullage,
		--PTS 40762 JJF 20080409
		--null delivered,
		(Select sum(isnull(dl_delivervolume,0)) from diplog where tank_nbr = b.tank_nbr
                 and dl_date > (select max(tank_dip_date) from tankdiphistory tdh2 
                     where tdh2.tank_nbr = b.tank_nbr)) , --null delivered,
		--END PTS 40762 JJF 20080409
		@shift tank_dip_shift,
		b.tank_highdip,
		b.tank_warndip,
		b.tank_lowdip,
		b.tank_dip_unit,
		b.tank_capacity,
		b.tank_cap_unit,
		null ord_hdrnumber,
		null dip_level,
		null tank_sales
	FROM compinvprofile a, tank b, company c, city d, commodity e
	WHERE 	a.cmp_id = b.cmp_id
	AND	a.cmp_id = c.cmp_id
	AND	c.cmp_city = d.cty_code
	AND	b.tank_cmd_code = e.cmd_code
	AND	a.cmp_id = ISNULL(@cmp_id, a.cmp_id)
	AND	a.cmp_group_nbr = ISNULL(@group_nbr, cmp_group_nbr)
	AND 	b.tank_inuse = 'Y'
	AND	b.tank_nbr NOT IN 
		(SELECT tank_nbr
		from tankdiphistory
		WHERE datepart(dy, tank_dip_date) = datepart(dy, @dip_date)
		AND tank_dip_shift = ISNULL(@shift, tank_dip_shift)
		AND tank_dip > 0)
	--PTS 40762 JJF 20080409
	ORDER BY c.cmp_ID,b.tank_loc
	--END PTS 40762 JJF 20080409
END	/* record new dip */
ELSE	
BEGIN	/* category 3, edit or view history */
	IF @status = 3
	BEGIN	/* dip recorded but not planned */
		--PTS 40762 JJF 20080409
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
			b.tank_loc,
			e.cmd_name,
			e.cmd_code,
			b.tank_nbr,
			0 ordered_volume,
			0 ordered_weight,
			b.tank_model_id,
			@dip_date tank_dip_date,
			null dip,
			null inventory,
			null ullage,
	        delivered = (Select sum(isnull(dl_delivervolume,0)) from diplog where tank_nbr = b.tank_nbr
                    and dl_date > (select max(tank_dip_date) from tankdiphistory tdh2 
                    where tdh2.tank_nbr = b.tank_nbr)) ,  --null delivered,
			@shift tank_dip_shift,
			b.tank_highdip,
			b.tank_warndip,
			b.tank_lowdip,
			b.tank_dip_unit,
			b.tank_capacity,
			b.tank_cap_unit,
			null ord_hdrnumber,
			null dip_level,
			null tank_sales
		INTO	#tempcalc	
		FROM 	compinvprofile a, tank b, company c, city d, commodity e
		WHERE 	a.cmp_id = b.cmp_id
		AND	a.cmp_id = c.cmp_id
		AND	c.cmp_city = d.cty_code
		AND	b.tank_cmd_code = e.cmd_code
		AND	a.cmp_id = ISNULL(@cmp_id, a.cmp_id)
		AND	a.cmp_group_nbr = ISNULL(@group_nbr, cmp_group_nbr)
		AND 	b.tank_inuse = 'Y'

		SELECT	@v_temp_tank_nbr = 0

		SELECT	@v_number_rows = count(*)
		FROM	#tempcalc

		SELECT 	@v_temp_tank_nbr = min(tank_nbr)
		FROM	#tempcalc
		WHERE	tank_nbr > @v_temp_tank_nbr

		SELECT 	@v_i = 1
	
		WHILE 	@v_i <= @v_number_rows
		 BEGIN
			SELECT 	@v_tank_dip_date =  max(dl_date) --max(dl_updatedon)
			FROM	diplog
			WHERE	tank_nbr = @v_temp_tank_nbr

			SELECT	@v_hours_diff = datediff(hh, @v_tank_dip_date, getdate())

			If @v_hours_diff <= @v_gi_hours_setting
			 BEGIN
				SELECT	@v_temp_dip = l.dl_dipreading,
				        @v_diplogdate = l.dl_date
				FROM	diplog l, tankdiphistory h
				WHERE	l.tank_nbr = @v_temp_tank_nbr
				AND	l.dl_date = @v_tank_dip_date --dl_updatedon = @v_tank_dip_date
				AND     h.tank_nbr = @v_temp_tank_nbr

				SET @v_high_dip = (SELECT tank_highdip
						   FROM #tempcalc WHERE
						   tank_nbr = @v_temp_tank_nbr)

				SET @v_temp_tank_loc = (SELECT tank_loc FROM tank
							WHERE tank_nbr = @v_temp_tank_nbr)

				SET @v_tank_model_id = (SELECT tank_model_id FROM tank
							WHERE tank_nbr = @v_temp_tank_nbr)

				exec calculateullage_sp @cmp_id, @v_temp_tank_loc, @v_tank_model_id, @dip_date, @v_temp_dip, @v_high_dip, 
				@v_tank_inventoryqty OUTPUT, @v_tank_ullageqty OUTPUT, @v_tank_deliveredqty OUTPUT, @v_tank_sales OUTPUT ,1--@v_dip_level OUTPUT
				

				UPDATE 	#tempcalc
				SET	dip = @v_temp_dip,
					tank_dip_date = @v_diplogdate, --@v_tank_dip_date
					inventory = @v_tank_inventoryqty,
					ullage = @v_tank_ullageqty
				WHERE	tank_nbr = @v_temp_tank_nbr
		 	 END

			SELECT 	@v_temp_tank_nbr = min(tank_nbr)
			FROM	#tempcalc
			WHERE	tank_nbr > @v_temp_tank_nbr

			SELECT @v_i = @v_i + 1
		 END

		SELECT  cmp_id,
		        cmp_name,
			cmp_address1,
			cmp_address2,
			cty_name,
			cmp_state,
			cmp_zip,
			cmp_primaryphone,
			cmp_group_nbr,
			cmp_lastsiteplandate,
			cmp_recommordersize,
			tank_loc,
			cmd_name,
			cmd_code,
			tank_nbr,
			ordered_volume,
			ordered_weight,
			tank_model_id,
			tank_dip_date,
			dip,
			inventory,
			ullage,
		        ISNULL(delivered, 0) AS delivered,
			tank_dip_shift,
			tank_highdip,
			tank_warndip,
			tank_lowdip,
			tank_dip_unit,
			tank_capacity,
			tank_cap_unit,
			ord_hdrnumber,
            dip_level,
			tank_sales
		FROM #tempcalc
		ORDER BY cmp_ID,tank_loc

		DROP TABLE #tempcalc

		/*
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
			b.tank_loc,
			f.cmd_name,
			f.cmd_code,
			b.tank_nbr,
			0 ordered_volume,
			0 ordered_weight,
			b.tank_model_id,
			e.tank_dip_date tank_dip_date,
			g.dl_dipreading dip,
			e.tank_inventoryqty inventory,
			e.tank_ullageqty ullage,
			e.tank_deliveredqty delivered,
			e.tank_dip_shift,
			b.tank_highdip,
			b.tank_warndip,
			b.tank_lowdip,
			b.tank_dip_unit,
			b.tank_capacity,
			b.tank_cap_unit,
			e.ord_hdrnumber ord_hdrnumber,
			e.tank_sales tank_sales,
			null dip_level
		FROM compinvprofile a, tank b, company c, city d, tankdiphistory e, commodity f, diplog g
		WHERE 	a.cmp_id = b.cmp_id
		AND	a.cmp_id = c.cmp_id
		AND	c.cmp_city = d.cty_code
		AND	b.tank_nbr = e.tank_nbr
		AND	b.tank_cmd_code = f.cmd_code
		AND	a.cmp_id = ISNULL(@cmp_id, a.cmp_id)
		AND	a.cmp_group_nbr = ISNULL(@group_nbr, cmp_group_nbr)
		AND 	b.tank_inuse = 'Y'
		AND	e.tank_dip_date >= ISNULL(@dip_date, tank_dip_date)
		AND	e.tank_dip_shift = ISNULL(@shift, tank_dip_shift)
		AND	e.ord_hdrnumber IS NULL
		AND	ISNULL(g.dl_dipreading, 0) > 0
		AND	g.tank_nbr = b.tank_nbr
		AND	g.dl_updatedon = (SELECT max(dl_updatedon)
					  FROM	 diplog
					  WHERE	 tank_nbr = b.tank_nbr)
		*/

	END	/* dip recorded but not planned */
	IF @status = 4
	BEGIN	/* dip completed */
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
			b.tank_loc,
			f.cmd_name,
			f.cmd_code,
			b.tank_nbr,
			0 ordered_volume,
			0 ordered_weight,
			b.tank_model_id,
			--PTS 40762 JJF 20080409
			--e.tank_dip_date tank_dip_date,
			--g.dl_dipreading dip,
			g.dl_date tank_dip_date,  --e.tank_dip_date tank_dip_date,
			g.dl_dipreading dip,  --e.tank_dip dip,  PRB Corrected
			--PTS 40762 JJF 20080409
			e.tank_inventoryqty inventory,
			e.tank_ullageqty ullage,
			e.tank_deliveredqty delivered,
			e.tank_dip_shift,
			b.tank_highdip,
			b.tank_warndip,
			b.tank_lowdip,
			b.tank_dip_unit,
			b.tank_capacity,
			b.tank_cap_unit,
			e.ord_hdrnumber ord_hdrnumber,
			null dip_level,
			e.tank_sales tank_sales
		FROM compinvprofile a, tank b, company c, city d, tankdiphistory e, commodity f, diplog g
		WHERE 	a.cmp_id = b.cmp_id
			AND	a.cmp_id = c.cmp_id
			AND	c.cmp_city = d.cty_code
			AND	b.tank_nbr = e.tank_nbr
			AND	b.tank_cmd_code = f.cmd_code
			AND	a.cmp_id = ISNULL(@cmp_id, a.cmp_id)
			AND	a.cmp_group_nbr = ISNULL(@group_nbr, cmp_group_nbr)
			AND 	b.tank_inuse = 'Y'
			AND	e.tank_dip_date >= ISNULL(@dip_date, tank_dip_date)
			AND	e.tank_dip_shift = ISNULL(@shift, tank_dip_shift)
	/* DPETE 27505
			AND	e.ord_hdrnumber >= 0
	*/
					AND	IsNull(e.ord_hdrnumber,0) > 0 
			AND	ISNULL(g.dl_dipreading, 0) > 0
			AND	g.tank_nbr = b.tank_nbr
			AND	g.dl_updatedon = (SELECT max(dl_updatedon)
						  FROM	 diplog
						  WHERE	 tank_nbr = b.tank_nbr)
		--PTS 40762 JJF 20080409
		ORDER BY c.cmp_ID, b.tank_loc
		--END PTS 40762 JJF 20080409

                

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
			b.tank_loc,
			e.cmd_name,
			e.cmd_code,
			b.tank_nbr,
			0 ordered_volume,
			0 ordered_weight,
			b.tank_model_id,
			@dip_date tank_dip_date,
			null dip,
			null inventory,
			null ullage,
			--PTS 40762 JJF 20080409
			--null delivered,
			(Select sum(isnull(dl_delivervolume,0)) from diplog where tank_nbr = b.tank_nbr
                        and dl_date > (select max(tank_dip_date) from tankdiphistory tdh2 
                        where tdh2.tank_nbr = b.tank_nbr)) ,  --null delivered,
			--PTS 40762 JJF 20080409
			@shift tank_dip_shift,
			b.tank_highdip,
			b.tank_warndip,
			b.tank_lowdip,
			b.tank_dip_unit,
			b.tank_capacity,
			b.tank_cap_unit,
			null ord_hdrnumber,
			null dip_level,
			null tank_sales
		FROM compinvprofile a, tank b, company c, city d, commodity e
		WHERE 	a.cmp_id = b.cmp_id
		AND	a.cmp_id = c.cmp_id
		AND	c.cmp_city = d.cty_code
		AND	b.tank_cmd_code = e.cmd_code
		AND	a.cmp_id = ISNULL(@cmp_id, a.cmp_id)
		AND	a.cmp_group_nbr = ISNULL(@group_nbr, cmp_group_nbr)
		AND 	b.tank_inuse = 'Y'
		AND	b.tank_nbr NOT IN 
			(SELECT tank_nbr
			from tankdiphistory
			WHERE datepart(dy, tank_dip_date) = datepart(dy, @dip_date)
			AND tank_dip_shift = ISNULL(@shift, tank_dip_shift)
			AND ISNULL(tank_dip, 0) >= 0)

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
			b.tank_loc,
			f.cmd_name,
			f.cmd_code,
			b.tank_nbr,
			0 ordered_volume,
			0 ordered_weight,	
			b.tank_model_id,
			--PTS 40762 JJF 20080409
			--e.tank_dip_date tank_dip_date,
			g.dl_date tank_dip_date,  --e.tank_dip_date tank_dip_date,
			--END PTS 40762 JJF 20080409
			g.dl_dipreading dip,
			e.tank_inventoryqty inventory,
			e.tank_ullageqty ullage,
			e.tank_deliveredqty delivered,
			e.tank_dip_shift,
			b.tank_highdip,
			b.tank_warndip,
			b.tank_lowdip,
			b.tank_dip_unit,
			b.tank_capacity,
			b.tank_cap_unit,
			e.ord_hdrnumber ord_hdrnumber,
			null dip_level,
			e.tank_sales tank_sales
		FROM compinvprofile a, tank b, company c, city d, tankdiphistory e, commodity f, diplog g
		WHERE 	a.cmp_id = b.cmp_id
		AND	a.cmp_id = c.cmp_id
		AND	c.cmp_city = d.cty_code
		AND	b.tank_nbr = e.tank_nbr
		AND	b.tank_cmd_code = f.cmd_code
		AND	a.cmp_id = ISNULL(@cmp_id, a.cmp_id)
		AND	a.cmp_group_nbr = ISNULL(@group_nbr, cmp_group_nbr)
		AND 	b.tank_inuse = 'Y'
		AND	e.tank_dip_date >= ISNULL(@dip_date, tank_dip_date)
		AND	e.tank_dip_shift = ISNULL(@shift, tank_dip_shift)
		AND	ISNULL(e.tank_dip, 0) >= 0
		AND	g.tank_nbr = b.tank_nbr
		AND	g.dl_updatedon = (SELECT max(dl_updatedon)
					  FROM	 diplog
					  WHERE	 tank_nbr = b.tank_nbr)
	END	/* all regardless the status */


	If @status = 5
	 BEGIN
		--PTS 40762 JJF 20080409 centralize declares
		--DECLARE @v_tank_dip_date 	datetime,
		--	@v_temp_tank_nbr	int,
		--	@v_gi_hours_setting	int,
		--	@v_hours_diff		int,
		--	@v_temp_dip		int,
		--	@v_number_rows		int,
		--	@v_i			int
		--END PTS 40762 JJF 20080409 centralize declares
		INSERT INTO #TEMP
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
			b.tank_loc,
			e.cmd_name,
			e.cmd_code,
			b.tank_nbr,
			0 ordered_volume,
			0 ordered_weight,
			b.tank_model_id,
			@dip_date tank_dip_date,
			null dip,
			null inventory,
			null ullage,
			--PTS 40762 JJF 20080409
			--null delivered,
	        delivered = (Select sum(isnull(dl_delivervolume,0)) from diplog where tank_nbr = b.tank_nbr
                    and dl_date > (select max(tank_dip_date) from tankdiphistory tdh2 
                    where tdh2.tank_nbr = b.tank_nbr)) ,  --null delivered,
			--PTS 40762 JJF 20080409
			@shift tank_dip_shift,
			b.tank_highdip,
			b.tank_warndip,
			b.tank_lowdip,
			b.tank_dip_unit,
			b.tank_capacity,
			b.tank_cap_unit,
			null ord_hdrnumber,
			null dip_level,
			null tank_sales
		FROM 	compinvprofile a, tank b, company c, city d, commodity e
		WHERE 	a.cmp_id = b.cmp_id
		AND	a.cmp_id = c.cmp_id
		AND	c.cmp_city = d.cty_code
		AND	b.tank_cmd_code = e.cmd_code
		AND	a.cmp_id = ISNULL(@cmp_id, a.cmp_id)
		AND	a.cmp_group_nbr = ISNULL(@group_nbr, cmp_group_nbr)
		AND 	b.tank_inuse = 'Y'

		--PTS 40762 JJF 20080409 moved upward
		--SELECT 	@v_gi_hours_setting = gi_string1
		--FROM	generalinfo
		--WHERE	gi_name = 'CurrentDipReadingHours'
		--END PTS 40762 JJF 20080409 moved upward

		SELECT	@v_temp_tank_nbr = 0

		SELECT	@v_number_rows = count(*)
		FROM	#TEMP

		SELECT 	@v_temp_tank_nbr = min(tank_nbr)
		FROM	#temp
		WHERE	tank_nbr > @v_temp_tank_nbr

		SELECT 	@v_i = 1
	
		WHILE 	@v_i <= @v_number_rows
		 BEGIN
			--PTS 40762 JJF 20080409
			SELECT 	@v_tank_dip_date =  max(dl_date) --max(dl_updatedon)
			--SELECT 	@v_tank_dip_date = max(dl_updatedon)
			--END PTS 40762 JJF 20080409
			FROM	diplog
			WHERE	tank_nbr = @v_temp_tank_nbr

			SELECT	@v_hours_diff = datediff(hh, @v_tank_dip_date, getdate())

			If @v_hours_diff <= @v_gi_hours_setting
			 BEGIN
				--PTS 40762 JJF 20080409
				--SELECT	@v_temp_dip = dl_dipreading
				--FROM	diplog
				--WHERE	tank_nbr = @v_temp_tank_nbr
				--AND	dl_updatedon = @v_tank_dip_date

				--UPDATE 	#TEMP
				--SET	dip = @v_temp_dip,
				--	tank_dip_date = @v_tank_dip_date
				--WHERE	tank_nbr = @v_temp_tank_nbr
				SELECT	@v_temp_dip = dl_dipreading,
				        @v_diplogdate = dl_date
				FROM	diplog
				WHERE	tank_nbr = @v_temp_tank_nbr
				AND	dl_date = @v_tank_dip_date --dl_updatedon = @v_tank_dip_date

				UPDATE 	#TEMP
				SET	dip = @v_temp_dip,
					tank_dip_date = @v_diplogdate --@v_tank_dip_date
				WHERE	tank_nbr = @v_temp_tank_nbr
				--END PTS 40762 JJF 20080409
		 	 END

			SELECT 	@v_temp_tank_nbr = min(tank_nbr)
			FROM	#temp
			WHERE	tank_nbr > @v_temp_tank_nbr

			SELECT @v_i = @v_i + 1
		 END

		--PTS 40762 JJF 20080409
		--SELECT *
		--FROM #TEMP
		SELECT cmp_id,
			cmp_name,
			cmp_address1,
			cmp_address2,
			cty_name,
			cmp_state,
			cmp_zip,
			cmp_primaryphone,
			cmp_group_nbr,
			cmp_lastsiteplandate,
			cmp_recommordersize,
			tank_loc,
			cmd_name,
			cmd_code,
			tank_nbr,
			ordered_volume,
			ordered_weight,
			tank_model_id,
			tank_dip_date,
			dip,
			inventory,
			ullage,
	        delivered,
			tank_dip_shift,
			tank_highdip,
			tank_warndip,
			tank_lowdip,
			tank_dip_unit,
			tank_capacity,
			tank_cap_unit,
			ord_hdrnumber,
			dip_level,
			tank_sales
		FROM #TEMP
		ORDER BY cmp_ID,tank_loc

		--END PTS 40762 JJF 20080409
	 END

END	/* edit or view history */

DROP TABLE #TEMP

RETURN 0
GO
GRANT EXECUTE ON  [dbo].[getcmptanklist_sp] TO [public]
GO
