SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[d_ace_tripdata] @p_ordnum varchar(13),@p_mov_number int

AS
/**
 * 
 * NAME:
 * dbo.d_ace_tripdata
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Retrieves trip detail information for the ace 309/358 creation window in visual dispatch.
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * All columns in temp table #tripdata
 *
 * PARAMETERS:
 * 001 - @p_ordnum, varchar(13), input;
 *       This parameter indicates the order number in which related data is being retrieved
 * 002 - @p_mov_number int input not null;
 * 	 Move number for which data is being retrieved.
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * Calls001    ? Name of Proc / Function Called
 * 
 * REVISION HISTORY:
 * 03/1/2006.01 ? PTS31886 - A. Rossman ? Initial Release
 * 04/23/2006.02  - PTS 32601 - A.Rossman - Added move number to input parameter list
 * 05/06/2008.03 -  PTS 41738 - A.Rossman - updated for round trips
 * 06/30/2010.04 - PTS 53038 - AR - Fix for company retrieval. Name length restriction.
 *
 **/
DECLARE	@origin	varchar(30),@destination varchar(30), @port varchar(12)

DECLARE @orig_city varchar(30),@orig_state varchar(6), @orig_arv datetime, @orig_dep datetime

DECLARE @dest_city varchar(30), @dest_state varchar(6), @dest_arv datetime, @dest_dep datetime

DECLARE @port_id varchar(12), @port_early datetime, @port_late datetime,@port_city varchar(30), @port_state varchar(6)
DECLARE @v_mov_number int,@v_ord_hdrnumber int,@v_MT char(1)



CREATE TABLE #tripdata(
			orig_name	varchar(30) NULL,
			orig_city	varchar(30) NULL,
			orig_state	varchar(6)  NULL,
			orig_arv	datetime    NULL,
			orig_dep	datetime    NULL,
			dest_name	varchar(30) NULL,
			dest_city	varchar(30) NULL,
			dest_state	varchar(6)  NULL,
			dest_arv	datetime    NULL,
			dest_dep	datetime    NULL,
			port_id		varchar(13) NULL,
			port_early	datetime    NULL,
			port_late	datetime    NULL,
			port_city	varchar(30) NULL,
			port_state	varchar(6)  NULL
			)
			
CREATE TABLE #movs( mov_number int NOT NULL)



--Use the input move number when necessary.
IF @p_mov_number > 0
	SELECT @v_mov_number = @p_mov_number,
		@v_ord_hdrnumber = MAX(DISTINCT(ord_hdrnumber ))
	FROM	legheader
	WHERE	mov_number = @p_mov_number
ELSE	
	SELECT @v_mov_number = mov_number,
		@v_ord_hdrnumber = ord_hdrnumber
	FROM 	orderheader WHERE ord_number = @p_ordnum
	
--insert into the moves temp table.  All move numbers associated with this trip.
INSERT #movs 
SELECT stops.mov_number FROM stops INNER join stops stops2 ON stops.ord_hdrnumber = stops2.ord_hdrnumber
WHERE stops2.mov_number = @v_mov_number AND stops2.ord_hdrnumber > 0
GROUP BY stops.mov_number

--determine the move number that contains the border crossing.
SELECT @v_mov_number  =  ISNULL(stops.mov_number,@v_mov_number)
FROM 	   stops
	INNER JOIN #movs on stops.mov_number =  #movs.mov_number
WHERE	stp_event in ('NBCST','BCST')	

--determine if this is an empty move or not.
IF @v_ord_hdrnumber = 0
	SET @v_MT = 'Y'
ELSE 
	SET @v_MT = 'N'

IF @v_MT = 'N'
BEGIN /*1*/
	SELECT	@origin = LEFT(company.cmp_name,30),
		@orig_state = stp_state,
		@orig_arv = stp_arrivaldate,
		@orig_dep = stp_departuredate,
		@orig_city = cty_name
	FROM	stops
	INNER JOIN city
		ON cty_code = stp_city
	INNER JOIN company
		ON stops.cmp_id = company.cmp_id
	WHERE	ord_hdrnumber = @v_ord_hdrnumber
		    AND stp_number = (SELECT MIN(stp_number) FROM stops where ord_hdrnumber = @v_ord_hdrnumber and stp_type = 'PUP')

	SELECT @destination = LEFT(company.cmp_name,30),
		@dest_state = stp_state,
		@dest_arv = stp_arrivaldate,
		@dest_dep = stp_departuredate,
		@dest_city = cty_name
	FROM	stops
	INNER JOIN city
		ON cty_code = stp_city
	INNER JOIN company
		ON stops.cmp_id = company.cmp_id
	WHERE	ord_hdrnumber = @v_ord_hdrnumber
		    AND stp_number = (SELECT MAX(stp_number) FROM stops WHERE ord_hdrnumber = @v_ord_hdrnumber and stp_type = 'DRP')

	SELECT @port = company.cmp_altid,
		@port_early =  CASE stp_schdtearliest
				 WHEN '1/1/1950 00:00' Then stp_arrivaldate
				 ELSE stp_schdtearliest
			       END,
		@port_late  = CASE stp_schdtlatest
				WHEN '12/31/2049 23:59' Then stp_departuredate
				ELSE stp_schdtlatest
			      END,
		@port_city  = cty_name,
		@port_state = stp_state
	FROM	stops
	INNER JOIN city
		ON cty_code = stp_city
	INNER JOIN company
		ON stops.cmp_id = company.cmp_id
	WHERE	mov_number = @v_mov_number
		   	AND stp_event in ('BCST','NBCST')
		   	and stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @v_mov_number AND stp_event in ('BCST','NBCST')
			AND stp_state IN (SELECT stc_state_c FROM statecountry WHERE stc_country_c ='USA'))
	
	INSERT INTO #tripdata
	VALUES( @origin,
		@orig_city,
		@orig_state,
		@orig_arv,
		@orig_dep,
		@destination,
		@dest_city,
		@dest_state,
		@dest_arv,
		@dest_dep,
		@port,
		@port_early,
		@port_late,
		@port_city,
		@port_state)
	
END /*1*/
ELSE	--retrieve data for empty moves
BEGIN	/*2*/	
	SELECT		@origin = LEFT(company.cmp_name,30),
			@orig_state = stp_state,
			@orig_arv = stp_arrivaldate,
			@orig_dep = stp_departuredate,
			@orig_city = cty_name
		FROM	stops
		INNER JOIN city
			ON cty_code = stp_city
		INNER JOIN company
			ON stops.cmp_id = company.cmp_id
		WHERE	mov_number = @p_mov_number
		    	AND stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops where mov_number = @p_mov_number )
	SELECT @destination = LEFT(company.cmp_name,30),
		@dest_state = stp_state,
		@dest_arv = stp_arrivaldate,
		@dest_dep = stp_departuredate,
		@dest_city = cty_name
	FROM	stops
	INNER JOIN city
		ON cty_code = stp_city
	INNER JOIN company
		ON stops.cmp_id = company.cmp_id
	WHERE	mov_number = @p_mov_number
		    AND stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence) FROM stops WHERE mov_number = @p_mov_number )		    	

	SELECT 	@port = company.cmp_altid,
		@port_early =  CASE stp_schdtearliest
				 WHEN '1/1/1950 00:00' Then stp_arrivaldate
				 ELSE stp_schdtearliest
			       END,
		@port_late  = CASE stp_schdtlatest
				WHEN '12/31/2049 23:59' Then stp_departuredate
				ELSE stp_schdtlatest
			      END,
		@port_city  = cty_name,
		@port_state = stp_state
	FROM	stops
	INNER JOIN city
		ON cty_code = stp_city
	INNER JOIN company
		ON stops.cmp_id = company.cmp_id
	WHERE	mov_number = @p_mov_number
		    AND stp_number = (SELECT MIN(stp_number) FROM stops where mov_number = @p_mov_number and stp_event in ('BCST','NBCST'))		    	
    
	INSERT INTO #tripdata
	VALUES( @origin,
		@orig_city,
		@orig_state,
		@orig_arv,
		@orig_dep,

		@destination,
		@dest_city,
		@dest_state,
		@dest_arv,
		@dest_dep,
		@port,
		@port_early,
		@port_late,
		@port_city,
		@port_state)

END /*2*/	
	
SELECT 	orig_name,
	orig_city,
	orig_state,
	orig_arv,
	orig_dep,
	dest_name,
	dest_city,
	dest_state,
	dest_arv,
	dest_dep,
	port_id,
	port_early,
	port_late,
	port_city,
	port_state
FROM 	#tripdata	

GO
GRANT EXECUTE ON  [dbo].[d_ace_tripdata] TO [public]
GO
