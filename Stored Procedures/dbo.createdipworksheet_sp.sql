SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE 	PROCEDURE [dbo].[createdipworksheet_sp] 
		  @cmp_id		varchar(8) = NULL,
		  @cmp_group_nbr	int = NULL,
		  @tank_dip_date	datetime = NULL,
		  @tank_dip_shift	char(2)= NULL
AS

/**
 * 
 * NAME:
 * createdipworksheet_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns information (company/tank) to be displayed on the Dip Worksheet
 *
 * RETURNS: 	NONE
 *
 * RESULT SETS: Company & Tank Information based on parameters that will display on a printed Dip Worksheet
 *
 * PARAMETERS:
 * @cmp_id		varchar(8)	Company ID to display (Specific ID or UNKNOWN)
 * @cmp_group_nbr	int		Group number to display	(further restricts result set)
 * @tank_dip_date	datetime	Date for which to display most recent readings
 * @tank_dip_shift	char(2)		Shift to display (further restricts result set)
 *
 *
 * REVISION HISTORY:
 * 10/6/2005.01 ? PTS29687 - Dan Hudec ? Created Procedure
 *
 **/

DECLARE	@v_gi_hours_setting 	int,
	@v_temp_tank_nbr	int,
	@v_tank_dip_date	datetime,
	@v_hours_diff		int,
	@v_temp_dip		int,
	@v_number_rows		int,
	@v_i			int
	
CREATE TABLE #TEMP (
	cmp_id			varchar(8) NULL, 
	cmp_group_nbr		tinyint NULL,
	cmp_name		varchar(100) NULL,
	cmp_address1		varchar(100) NULL,
	cmp_address2		varchar(100) NULL,
	cty_name		varchar(18) NULL,
	cmp_state		varchar(6) NULL,
	cmp_zip			varchar(10) NULL,
	cmp_primaryphone	varchar(20) NULL,
	tank_loc		varchar(10) NULL,
	tank_cmd_code		varchar(8) NULL,
	cmd_name		varchar(60) NULL,
	dip_date		datetime NULL,
	shift			char(2) NULL,
	tank_nbr		int NULL,
	dip_reading		smallint)

--	LOR	PTS# 25483
If @cmp_id = 'UNKNOWN' select @cmp_id = null
--
	INSERT INTO #TEMP
	SELECT 	a.cmp_id, 
		a.cmp_group_nbr,
		c.cmp_name,
		cmp_address1 = ISNULL(c.cmp_address1, ''),
		cmp_address2 = ISNULL(c.cmp_address2, ''),
		cty_name = ISNULL(d.cty_name, ''),
		cmp_state = ISNULL(c.cmp_state, ''),
		cmp_zip = ISNULL(c.cmp_zip, ''),
		c.cmp_primaryphone,
		b.tank_loc,
		b.tank_cmd_code,
		e.cmd_name,
		dip_date = @tank_dip_date,
		shift = @tank_dip_shift,
		b.tank_nbr,
		0 dip_reading
	FROM    compinvprofile a, tank b, company c, city d, commodity e
	WHERE   a.cmp_id        = b.cmp_id
	AND     a.cmp_id        = c.cmp_id
	AND     c.cmp_city      = d.cty_code
	AND	b.tank_cmd_code = e.cmd_code
	AND     a.cmp_id        = ISNULL(@cmp_id, a.cmp_id)
	AND     a.cmp_group_nbr = ISNULL(@cmp_group_nbr, a.cmp_group_nbr)
	AND     b.tank_inuse    = 'Y'
-- 	AND NOT EXISTS (SELECT tank_nbr
-- 			FROM   tankdiphistory
-- 			WHERE  tank_nbr       = b.tank_nbr
-- 			AND    tank_dip_date  = @tank_dip_date
-- 			AND    tank_dip_shift = ISNULL(@tank_dip_shift, tank_dip_shift))
	ORDER BY cmp_name, tank_loc


	SELECT 	@v_gi_hours_setting = gi_string1
	FROM	generalinfo
	WHERE	gi_name = 'CurrentDipReadingHours'

	SELECT 	@v_temp_tank_nbr = 0

	SELECT	@v_number_rows = count(*)
	FROM	#TEMP

	SELECT 	@v_temp_tank_nbr = min(tank_nbr)
	FROM	#temp
	WHERE	tank_nbr > @v_temp_tank_nbr

	SELECT 	@v_i = 1
	
	WHILE 	@v_i <= @v_number_rows
	 BEGIN
		SELECT 	@v_tank_dip_date = max(dl_updatedon)
		FROM	diplog
		WHERE	tank_nbr = @v_temp_tank_nbr

		SELECT	@v_hours_diff = datediff(hh, @v_tank_dip_date, getdate())

		If @v_hours_diff <= @v_gi_hours_setting
		 BEGIN
			SELECT	@v_temp_dip = dl_dipreading
			FROM	diplog
			WHERE	tank_nbr = @v_temp_tank_nbr
			AND	dl_updatedon = @v_tank_dip_date

			UPDATE 	#TEMP
			SET	dip_reading = @v_temp_dip,
				dip_date = @v_tank_dip_date
			WHERE	tank_nbr = @v_temp_tank_nbr
		  END

		SELECT 	@v_temp_tank_nbr = min(tank_nbr)
		FROM	#temp
		WHERE	tank_nbr > @v_temp_tank_nbr

		SELECT @v_i = @v_i + 1
	 END


SELECT *
FROM #TEMP

DROP TABLE #TEMP

RETURN 0
GO
GRANT EXECUTE ON  [dbo].[createdipworksheet_sp] TO [public]
GO
