SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[trl_inservice] @trl char ( 13 ), @city integer, @cmpid char ( 8 ), @date datetime, @exp_key int

AS

/**
 * 
 * NAME:
 * dbo.trl_inservice
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure creates in-service moves for Trailers.
 *
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @trl, varchar(13), input, null;
 *       This parameter is the Trailer to create the in-service move for. The value must be 
 *       non-null and non-empty.
 * 002 - @city, integer, input, null;
 *       This parameter is the city location for the in-service move. The value must be non-null and 
 *       non-empty.
 * 003 - @cmpid, varchar(8), input, null;
 *       This parameter is the company location for the in-service move. The value must be non-null and 
 *       non-empty.
 * 004 - @date, datetime, input, null;
 *       This parameter is the datetime for the in-service move. The value must be non-null and 
 *       non-empty.
 * 005 - @exp_key, integer, input, null;
 *       This parameter is primary key value of the expiration that is associated with the in-service move. 
 *       The value must be non-null and non-empty.
 *
 * REFERENCES:  
 * Calls001    ? UPDATE_MOVE
 * Calls002    ? GETSYSTEMNUMBER
 *
 * REVISION HISTORY:
 * 09/12/05 --  PTS29758 -- Bryan Levon -- NEW proc
 *
 **/

DECLARE @lgh integer,
	@stpnum integer,
	@mov integer,
	@evt varchar (6),
	@bug varchar (12),
	@status varchar(6),
	--PTS 26385 Optionally create in service move
	@Create_Move char(1),
	@Carrier varchar(8),
	@first_cmp_id varchar(8),
	@first_stp_city integer


/* PTS 4280 - added update to lgh_active to make sure lgh_active status is function correctly 
		added isnull so that if a tractor is not onfile no lgh is created*/
SELECT	@status = ISNULL(trl_status, 'XXX')
  FROM	trailerprofile 
 WHERE	trl_id = @trl
	
--IF @status <> 'AVL' AND @status <> 'PLN' AND @status <> 'DSP'
--	RETURN

SELECT @Carrier = gi_string2
FROM generalinfo 
WHERE gi_name = 'Trailer_Inservice'

SELECT @evt = ''
--EXECUTE @mov = cur_activity 'TRL', @trl, @lgh OUT 

-- Get last Trailer location from previous activity to use as
--	the location on 1st stop for 'inservice' move
SELECT @first_cmp_id = stops.cmp_id,
	@first_stp_city = stops.stp_city,
	@lgh = stops.lgh_number,
	@mov = stops.mov_number
From assetassignment INNER JOIN event on assetassignment.last_evt_number = event.evt_number
		INNER JOIN stops on stops.stp_number = event.stp_number
WHERE asgn_status in ('CMP', 'STD')
and asgn_type = 'TRL'
and asgn_id = @trl
and asgn_date = (SELECT max(asgn_date)
		FROM assetassignment a
		WHERE	a.asgn_type = assetassignment.asgn_type
		and a.asgn_id = assetassignment.asgn_id
		AND asgn_date < @date)

IF @lgh > 0 
	BEGIN
	SELECT @evt = MIN ( stp_event )
	FROM stops
	WHERE lgh_number = @lgh 

	IF @evt = 'INSERV'
		BEGIN
		UPDATE stops
		SET cmp_id = @cmpid,
	           	cmp_name = @cmpid,
			stp_city = @city,
			stp_schdtearliest = @date,   
		        stp_origschdt = @date,   
           		stp_arrivaldate = @date,   
           		stp_departuredate = @date,   
           		stp_schdtlatest = @date   
		WHERE lgh_number = @lgh AND
			stp_mfh_sequence = 1
		UPDATE stops
		SET cmp_id = @cmpid,
	           	cmp_name = @cmpid,
			stp_city = @city,
			stp_schdtearliest = @date,   
		        stp_origschdt = @date,   
           		stp_arrivaldate = @date,   
           		stp_departuredate = @date,   
           		stp_schdtlatest = @date   
		WHERE lgh_number = @lgh AND
			stp_mfh_sequence = 2
		END
	END
	
-- PTS 31747 -- BL (start)
if isnull(@lgh, 0) = 0
	SELECT 	@first_cmp_id = @cmpid,
		@first_stp_city = @city
-- PTS 31747 -- BL (end)
	
IF @evt <> 'INSERV' BEGIN
	--PTS 26385 Determine if this expiration is set to automatically create move when placed inservice
	--Get create move status for expiration code
	SELECT	@Create_Move = lbl.create_move
	FROM	labelfile lbl INNER JOIN expiration exp ON lbl.abbr = exp.exp_code
	WHERE	(lbl.labeldefinition = 'TRLEXP') AND (exp.exp_key = @exp_key)	

	IF (@Create_Move = 'Y' or @Create_Move is null) BEGIN

		EXECUTE @mov = getsystemnumber 'MOVNUM', ''	
		EXECUTE @lgh = getsystemnumber  'LEGHDR', '' 
		
		EXECUTE @stpnum = getsystemnumber 'STPNUM', '' 

		UPDATE	expiration
		SET	mov_number = @mov
		WHERE	exp_key	= @exp_key

		INSERT INTO stops  
		         ( ord_hdrnumber,   
	        	   stp_number,   
		           cmp_id,   
		           stp_region1,   
		           stp_region2,   
		           stp_region3,   
		           stp_city,   
		           stp_state,   
		           stp_schdtearliest,   
		           stp_origschdt,   
		           stp_arrivaldate,   
		           stp_departuredate,   
		           stp_reasonlate,   
		           stp_schdtlatest,   
		           lgh_number,   
		           mfh_number,   
		           stp_type,   
		           stp_paylegpt,   
		           shp_hdrnumber,   
		           stp_sequence,   
		           stp_region4,   
		           stp_lgh_sequence,   
		           trl_id,   
		           stp_mfh_sequence,   
		           stp_event,   
		           stp_mfh_position,   
		           stp_lgh_position,   
		           stp_mfh_status,   
		           stp_lgh_status,   
		           stp_ord_mileage,   
		           stp_lgh_mileage,   
		           stp_mfh_mileage,   
		           mov_number,   
		           stp_loadstatus,   
		           stp_weight,   
		           stp_weightunit,   
		           cmd_code,   
		           stp_description,   
		           stp_count,   
		           stp_countunit,   
		           cmp_name,   
		           stp_comment,   
		           stp_status,   
		           stp_departure_status, /* 07/07/2009 MDH PTS 43226: Added */
		           stp_reftype,   
		           stp_refnum )  
		  VALUES ( 0,   
			@stpnum,  
			@first_cmp_id,   
	        	'UNK',   
	        	'UNK',   
	        	'UNK',   
			@first_stp_city, 
	        	null,   
	        	@date,
	        	@date,
	        	@date,
	        	@date,
	        	'UNK',   
	        	@date,
			@lgh,
	        	0,   
	        	'UNK',   
	        	null,   
	        	null,   
			0,   
	        	null,   
			null,   
	        	'UNKNOWN',   
			1,   
	        	'INSERV',   
	        	null,   
	        	null,   
	        	'DNE',   
	        	'DNE',   
	        	0,   
	        	0,   
	        	0,   
			@mov,
			null,   
			0,   
			'LBS',   
			'UNKNOWN',   
			null,   
	        	0,              
			'PCS',   
			@first_cmp_id,
			null,   
			'DNE',   
			'DNE',   /* 07/07/2009 MDH PTS 43226: Added */
			null,   
			null )
		
		UPDATE event  
		SET evt_carrier = @Carrier,
			evt_trailer1 = @trl
		WHERE event.stp_number = @stpnum 
	
		/* this update is done seperatly because the assetasignment records 
		are created by the event insert trigger */
		-- RE - 5/3/01 - PTS 10798 moved to after update_move
		--UPDATE assetassignment  
		--SET pyd_status = 'PPD'
		--FROM event ,assetassignment 
		--WHERE evt_tractor = @trc and 
		--event.stp_number = @stpnum and
		--event.evt_number  = assetassignment.evt_number
	
		/* now do second stop on dummy move */
		EXECUTE @stpnum = getsystemnumber 'STPNUM', '' 
		INSERT INTO stops  
	         	( ord_hdrnumber,   
	           	stp_number,   
	           	cmp_id,   
	           	stp_region1,   
	           	stp_region2,   
	           	stp_region3,   
	           	stp_city,   
	           	stp_state,   
	           	stp_schdtearliest,   
	           	stp_origschdt,   
	           	stp_arrivaldate,   
	           	stp_departuredate,   
	           	stp_reasonlate,   
	           	stp_schdtlatest,   
	           	lgh_number,   
	           	mfh_number,   
	           	stp_type,   
	           	stp_paylegpt,   
	           	shp_hdrnumber,   
	           	stp_sequence,   
	           	stp_region4,   
	           	stp_lgh_sequence,   
	           	trl_id,   
	           	stp_mfh_sequence,   
	           	stp_event,   
	           	stp_mfh_position,   
	           	stp_lgh_position,   
	           	stp_mfh_status,   
	           	stp_lgh_status,   
	           	stp_ord_mileage,   
	           	stp_lgh_mileage,   
	           	stp_mfh_mileage,   
	           	mov_number,   
	           	stp_loadstatus,   
	           	stp_weight,   
	           	stp_weightunit,   
	           	cmd_code,   
	           	stp_description,   
	           	stp_count,   
	           	stp_countunit,   
	           	cmp_name,   
	           	stp_comment,   
	           	stp_status,   
                stp_departure_status, /* 07/07/2009 MDH PTS 43226: Added */
	           	stp_reftype,   
	           	stp_refnum )  
		  VALUES ( 0,   
			@stpnum,  
			@cmpid,   
	           	'UNK',   
	           	'UNK',   
	           	'UNK',   
			@city, 
	           	null,   
	         	@date,
	         	@date,
	         	@date,
	         	@date,
	           	'UNK',   
	         	@date,
			@lgh,
	           	0,   
	           	'UNK',   
	           	null,   
	           	null,   
			0,   
	           	null,   
			null,   
	           	'UNKNOWN',   
			2,   
	           	'INSERV',   
	           	null,   
	           	null,   
	           	'DNE',   
	           	'DNE',   
	           	0,   
	           	0,   
		        0,   
			@mov,
		        null,   
		        0,   
		        'LBS',   
		        'UNKNOWN',   
		        null,   
		        0,   
		        'PCS',   
			@cmpid,
		        null,   
		        'DNE',   
		        'DNE',   /* 07/07/2009 MDH PTS 43226: Added */
		        null,   
		        null )
		
		UPDATE event  
		SET evt_carrier = @Carrier,
			evt_trailer1 = @trl
		WHERE event.stp_number = @stpnum 
	
		/* this update is done seperatly because the assetasignment records 
		are created by the event insert trigger */
		/* PTS 4212 - added update for assign status to fix lgh_instatus */
		-- RE - 5/3/01 - PTS 10798 moved to after update_move
		--UPDATE assetassignment  
		--SET pyd_status = 'PPD',
	   	--	asgn_status = 'CMP'
		--FROM event ,assetassignment 
		--WHERE evt_tractor = @trc and 
		--event.stp_number = @stpnum and
		--event.evt_number  = assetassignment.evt_number
	END

END  /* inserting new one instead of updating existing dummy move */

-- RE - 5/3/01 - PTS 10798
--EXECUTE update_move @mov

/* PTS 4212 - Running update move twice because it seems to work */

delete legheader
where lgh_number = @lgh

EXECUTE update_move @mov

-- RE - 5/3/01 - PTS 10798
UPDATE  assetassignment  
   SET  pyd_status = 'PPD',
	asgn_status = 'CMP'
 WHERE 	lgh_number = @lgh

RETURN

GO
GRANT EXECUTE ON  [dbo].[trl_inservice] TO [public]
GO
