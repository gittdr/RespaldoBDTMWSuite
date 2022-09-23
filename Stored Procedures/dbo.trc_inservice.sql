SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/****** Object:  Stored Procedure dbo.trc_inservice    Script Date: 8/20/97 2:00:07 PM ******/
/* PTS 4212 - added update for assign status to fix lgh_instatus */
/* PTS 4280 - added update to lgh_active to make sure lgh_active status is function correctly */
/* PTS 48889 - Wrapped delete legheader in IF statement for INSERVICE
*/

CREATE PROCEDURE [dbo].[trc_inservice] @trc char ( 8 ), @city integer, @cmpid char ( 8 ), @date datetime, @exp_key int

AS

DECLARE @lgh integer,
	@stpnum integer,
	@mov integer,
	@evt varchar (6),
	@bug varchar (12),
	@status varchar(6),
	--PTS 26385 Optionally create in service move
	@Create_Move char(1)


/* PTS 4280 - added update to lgh_active to make sure lgh_active status is function correctly 
		added isnull so that if a tractor is not onfile no lgh is created*/
SELECT	@status = ISNULL(trc_status, 'XXX')
  FROM	tractorprofile 
 WHERE	trc_number = @trc
	
IF @status <> 'AVL' AND @status <> 'PLN' AND @status <> 'DSP'

	RETURN

SELECT @evt = ''
EXECUTE @mov = cur_activity 'TRC', @trc, @lgh OUT 
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
	
IF @evt <> 'INSERV' BEGIN
	--PTS 26385 Determine if this expiration is set to automatically create move when placed inservice
	--Get create move status for expiration code
	SELECT	@Create_Move = lbl.create_move
	FROM	labelfile lbl INNER JOIN expiration exp ON lbl.abbr = exp.exp_code
	WHERE	(lbl.labeldefinition = 'TRCEXP') AND (exp.exp_key = @exp_key)	

	IF (@Create_Move = 'Y' or @Create_Move is null) BEGIN

		SELECT @evt = 'INSERV' -- RE - PTS #45470

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
				   stp_departure_status,   
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
			@cmpid,
			null,   
			'DNE', 
			'DNE',  
			null,   
			null )
		
		UPDATE event  
		SET evt_tractor = @trc,
			evt_driver1 = trc_driver,
			evt_driver2 = trc_driver2
		FROM tractorprofile  
		WHERE event.stp_number = @stpnum AND
			trc_number = @trc
	
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
			    stp_departure_status,  
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
				'DNE',
		        null,   
		        null )
		
		UPDATE event  
		SET evt_tractor = @trc,
			evt_driver1 = trc_driver,
			evt_driver2 = trc_driver2
		FROM tractorprofile  
		WHERE event.stp_number = @stpnum AND
			trc_number = @trc
	
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

-- SGB PTS 48889 BEGIN
IF @evt = 'INSERV'
BEGIN
	delete legheader
	where lgh_number = @lgh
END
-- SGB PTS 48889 END


EXECUTE update_move @mov

-- RE - 5/3/01 - PTS 10798
-- RE - PTS #45470 BEGIN
IF @evt = 'INSERV'
BEGIN
	UPDATE  assetassignment  
	   SET  pyd_status = 'PPD',
		asgn_status = 'CMP'
	 WHERE 	lgh_number = @lgh
END
-- RE - PTS #45470 END

RETURN

GO
GRANT EXECUTE ON  [dbo].[trc_inservice] TO [public]
GO
