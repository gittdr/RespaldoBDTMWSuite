SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_create_container_assignments]
	@ord_hdrnumber 	INTEGER, 
	@trl_number	    VARCHAR (8), 
	@trl_ilt_scac	CHAR (4),
	@trl_owner		VARCHAR (12)
AS
BEGIN                              
	DECLARE @ll_count 				INTEGER,
			@dt_apocalypse			DATETIME,
			@dt_create_date			DATETIME,
			@dt_pickup				DATETIME,
			@b_enabled 				CHAR (1),
	        @intermodalmode			CHAR (1),
			@l_first_pup			INTEGER,
			@l_first_drp			INTEGER,
			@pup_city			    INTEGER,
			@drp_city		        INTEGER,
			@exp_pri   				INTEGER,
			@trl_id					VARCHAR (13),
			@curr_user				VARCHAR (20),
			@exp_route				VARCHAR (12),
			@drp_cmp_id				VARCHAR (12),
			@pup_cmp_id				VARCHAR (12),
			@ord_billto				VARCHAR (12),
			@exp_type				VARCHAR (6),
			@mov_number				INTEGER,
			@l_first_trl_stop 		INTEGER,
			@description			VARCHAR (100),
			@port					CHAR (1),
			@exp_key				INTEGER

	SET NOCOUNT ON
	
	-- Initialize settings	
	SELECT  @dt_apocalypse = convert(datetime,'20491231 23:59:00'), 
			@curr_user = LEFT (dbo.gettmwuser_fn(), 20),
			@b_enabled = 'N', @intermodalmode = 'N',
			@exp_pri = 9
	SELECT  @b_enabled = ISNULL (LEFT (gi_string1, 1), 'N'),
			@exp_pri  = CAST (ISNULL (gi_string4, '9') AS INTEGER)
		FROM generalinfo
		WHERE gi_name = 'IntermodalEDI'
	/* 06/02/2010 MDH PTS 51051: Added for in service and off hire expirations (Intermodal Mode 2) */
	SELECT  @exp_type = ISNULL (LEFT (gi_string2, 6), 'FREE'),
	        @intermodalmode = ISNULL (LEFT (gi_string1, 1), 'N')
		FROM generalinfo
		WHERE gi_name = 'IntermodalMode'
    
    -- give up if we're not enabled.
	IF @b_enabled = 'N' OR @intermodalmode = 'N'
		RETURN

	-- Give up if null/empty parameters
	IF ISNULL (@trl_ilt_scac, '') = '' OR ISNULL (@trl_number, '') = '' OR
		ISNULL (@ord_hdrnumber, 0) = 0 OR ISNULL (@trl_owner, '') = ''
		RETURN
	
	-- Create trailer ID
	SELECT @trl_id = LEFT (@trl_ilt_scac + '    ', 4) + ',' + @trl_number

	-- Check to see if owner exists
	SELECT @ll_count = COUNT (*) FROM payto WHERE pto_id = @trl_owner;
	IF @ll_count = 0
	BEGIN
		INSERT INTO payto  (pto_id				, 
							pto_lname           ,
							pto_misc4           ,
							pto_updatedby       ,
							pto_updateddate     ,
							pto_startdate       ,
							pto_terminatedate   ,
							pto_createdate      )
			VALUES		(@trl_owner				/* pto_id			*/	, 
						 @trl_owner				/* pto_lname        */   ,
						'Created by EDI import'	/* pto_misc4        */   ,
						@curr_user       		/* pto_updatedby    */   ,
						CURRENT_TIMESTAMP 		/* pto_updateddate  */   ,
						CURRENT_TIMESTAMP		/* pto_startdate    */   ,
						@dt_apocalypse			/* pto_terminatedate*/   ,
						CURRENT_TIMESTAMP		/* pto_createdate   */   )
	END
	
	-- Make sure the trailer exists
	SELECT @ll_count = COUNT (*) FROM trailerprofile WHERE trl_ilt_scac = @trl_ilt_scac AND trl_number = @trl_number;
	IF @ll_count = 0 
	BEGIN
		INSERT INTO trailerprofile (trl_number, 
							trl_owner, 
							trl_make, 
							trl_model, 
							trl_currenthub, 
							trl_type1, 
							trl_type2, 
							trl_type3, 
							trl_type4, 
							trl_company, 
							trl_fleet, 
							trl_division, 
							trl_terminal, 
							cmp_id, 
							trl_status, 
							trl_updatedby, 
							trl_ilt, 
							trl_startdate, 
							trl_retiredate, 
							cty_code, 
							trl_mtwgt, 
							trl_grosswgt, 
							trl_axles, 
							trl_ht, 
							trl_len, 
							trl_wdth, 
							trl_origcost, 
							trl_opercostmile, 
							trl_sch_cmp_id, 
							trl_sch_city, 
							trl_sch_status, 
							trl_avail_cmp_id, 
							trl_fix_record, 
							trl_avail_city, 
							trl_last_stop, 
							trl_id, 
							trl_cur_mileage, 
							trl_avail_date, 
							trl_updateon, 
							trl_createdate, 
							trl_pupid, 
							trl_quickentry, 
							trl_manualupdate, 
							trl_ilt_scac, 
							trl_equipmenttype ) 
							VALUES ( 
							@trl_number,                       /* trl_number,       */
							@trl_owner,                        /* trl_owner,        */
							'UNK',                             /* trl_make,         */
							'UNK',                             /* trl_model,        */
							0,                                 /* trl_currenthub,   */
							'UNK',                             /* trl_type1,        */
							'UNK',                             /* trl_type2,        */
							'UNK',                             /* trl_type3,        */
							'UNK',                             /* trl_type4,        */
							'UNK',                             /* trl_company,      */
							'UNK',                             /* trl_fleet,        */
							'UNK',                             /* trl_division,     */
							'UNK',                             /* trl_terminal,     */
							'UNKNOWN',                         /* cmp_id,           */
							'AVL',                             /* trl_status,       */
							@curr_user,                        /* trl_updatedby,    */
							'Y',                               /* trl_ilt,          */
							CURRENT_TIMESTAMP,                 /* trl_startdate,    */
							@dt_apocalypse,                    /* trl_retiredate,   */
							0,                                 /* cty_code,         */
							0,                                 /* trl_mtwgt,        */
							0,                                 /* trl_grosswgt,     */
							0,                                 /* trl_axles,        */
							0,                                 /* trl_ht,           */
							0,                                 /* trl_len,          */
							0,                                 /* trl_wdth,         */
							0,                                 /* trl_origcost,     */
							0,                                 /* trl_opercostmile, */
							'UNKNOWN',                         /* trl_sch_cmp_id,   */
							0,                                 /* trl_sch_city,     */
							'AVL',                             /* trl_sch_status,   */
							'UNKNOWN',                         /* trl_avail_cmp_id, */
							'N',                               /* trl_fix_record,   */
							0,                                 /* trl_avail_city,   */
							0,                                 /* trl_last_stop,    */
							@trl_id,						   /* trl_id,           */
							0,                                 /* trl_cur_mileage,  */
							CURRENT_TIMESTAMP,                 /* trl_avail_date,   */
							CURRENT_TIMESTAMP,                 /* trl_updateon,     */
							CURRENT_TIMESTAMP,                 /* trl_createdate,   */
							'UNKNOWN',                         /* trl_pupid,        */
							'Y',                               /* trl_quickentry,   */
							'N',                               /* trl_manualupdate, */
							@trl_ilt_scac,                     /* trl_ilt_scac,     */
							'CONTAINER' )					   /* trl_equipmenttype	*/		
	END

	-- Get move number
	SELECT @mov_number = mov_number, 
		   @description = 'Auto Created by EDI 204, Move ' + CAST (mov_number AS VARCHAR(12))
		FROM orderheader
		WHERE ord_hdrnumber = @ord_hdrnumber
	-- Find first stop w/trailer
	SELECT @l_first_trl_stop = MIN (stp_mfh_sequence) 
		FROM stops
		WHERE mov_number = @mov_number
		AND   stops.stp_loadstatus IN ('LD','MT')
	-- find first pup 
	SELECT @l_first_pup = MIN (stp_mfh_sequence) 
		FROM stops
		WHERE ord_hdrnumber = @ord_hdrnumber
		AND stops.stp_type = 'PUP'
	-- find first drp after pup
	SELECT @l_first_drp = MIN (stp_mfh_sequence)
		FROM stops
		WHERE ord_hdrnumber = @ord_hdrnumber
		AND stops.stp_type = 'DRP'
		AND stops.stp_mfh_sequence > @l_first_pup
	-- Get cities for expirations in case we need them.
	SELECT @pup_city = stp_city, @exp_route = cmp_id, @dt_pickup = stp_schdtearliest, @pup_cmp_id = cmp_id
		FROM stops
		WHERE mov_number = @mov_number
		AND stp_mfh_sequence = @l_first_trl_stop
	-- Check if PUP is a port
	SELECT @port = cmp_port
		FROM stops join company on stops.cmp_id = company.cmp_id
		WHERE mov_number = @mov_number
		AND stp_mfh_sequence = @l_first_pup
	SELECT @drp_city = stp_city 
		FROM stops
		WHERE ord_hdrnumber = @ord_hdrnumber
		AND stp_mfh_sequence = @l_first_drp 
	SELECT @ord_billto = ord_billto
		FROM orderheader 
		WHERE ord_hdrnumber = @ord_hdrnumber
	
	-- Assign trailer to order, on all stops from first trl to first drp after first pup.
	-- Note: Must do one by one.
	-- 07/22/2010 MDH PTS 51051: changed to use first trl stop incase of BMT
	WHILE @l_first_trl_stop <= @l_first_drp
	BEGIN
		UPDATE event 
			SET evt_trailer1 = @trl_id
			FROM stops
			WHERE stops.stp_number = event.stp_number
			AND stops.stp_mfh_sequence = @l_first_trl_stop 
			AND stops.mov_number = @mov_number
			AND (stops.ord_hdrnumber = @ord_hdrnumber OR stops.ord_hdrnumber = 0)
		UPDATE stops
			SET trl_id = @trl_id
			WHERE stops.stp_mfh_sequence = @l_first_trl_stop 
			AND stops.mov_number = @mov_number
			AND (stops.ord_hdrnumber = @ord_hdrnumber OR stops.ord_hdrnumber = 0)
			
		SET @l_first_trl_stop = @l_first_trl_stop + 1
	END /* while */
	
	/* Update move */
	exec update_move @mov_number
	
	/* 06/02/2010 MDH PTS 51051: Create mode 2 expirations */
	IF @intermodalmode = '2'
	BEGIN
		IF @port = 'Y'
		BEGIN 
			SET @exp_key = NULL
			SELECT @exp_key = exp_key
				FROM expiration 
				WHERE exp_idtype = 'TRL' 
				  AND exp_id = @trl_id
				  AND exp_code = 'INS'
				  AND exp_description = @description
			IF @exp_key IS NULL 
			BEGIN
				INSERT INTO expiration
					(
					exp_idtype,
					exp_id,
					exp_code,
					exp_lastdate,
					exp_expirationdate,
					exp_routeto,
					exp_completed,
					exp_priority, 
					exp_compldate,
					exp_updateby,
					exp_updateon,
					exp_description,
					exp_city, 
					mov_number,
					exp_control_avl_date,
					exp_auto_created
					)
					VALUES 
					(
					'TRL',                                /* exp_idtype,          */
					@trl_id,                              /* exp_id,              */
					'INS',                                /* exp_code,            */
					@dt_create_date,                      /* exp_lastdate,        */
					@dt_pickup,                      	  /* exp_expirationdate,  */
					@exp_route,                           /* exp_routeto,         */
					'Y',                                  /* exp_completed,       */
					1,                                    /* exp_priority,        */
					@dt_pickup,                      	  /* exp_compldate,       */
					@curr_user,                           /* exp_updateby,        */
					CURRENT_TIMESTAMP,                    /* exp_updateon,        */
					@description,                         /* exp_description,     */
					@pup_city,                            /* exp_city,            */
					@mov_number,                          /* mov_number,          */
					'N',                                  /* exp_control_avl_date,*/
					'Y'                                   /* exp_auto_created     */
					)
			END 
			ELSE /* expiration exists, update it */
			BEGIN
				UPDATE expiration
					SET exp_expirationdate = @dt_pickup,
					    exp_routeto = @exp_route,
					    exp_compldate = @dt_pickup,
					    exp_updateby = @curr_user,
					    exp_updateon = CURRENT_TIMESTAMP,
					    exp_city = @pup_city,
					    mov_number = @mov_number 
					WHERE exp_key = @exp_key
			END
		END /* if at a port */

		-- Complete any open expirations for free time.
		UPDATE expiration
			SET exp_completed = 'Y'
			WHERE exp_idtype = 'TRL' 
			  AND exp_id = @trl_id
			  AND exp_code = @exp_type
			  AND exp_completed = 'N'
			  AND exp_description <> @description
	
		/* Create or update free time expiration */
		SET @exp_key = NULL
		SELECT @exp_key = exp_key
			FROM expiration 
			WHERE exp_idtype = 'TRL' 
			  AND exp_id = @trl_id
			  AND exp_code = @exp_type
			  AND exp_description = @description
		IF @exp_key IS NULL 
		BEGIN
			INSERT INTO expiration
				(
				exp_idtype,
				exp_id,
				exp_code,
				exp_lastdate,
				exp_expirationdate,
				exp_routeto,
				exp_completed,
				exp_priority, 
				exp_compldate,
				exp_updateby,
				exp_updateon,
				exp_description,
				exp_city, 
				mov_number,
				exp_control_avl_date,
				exp_auto_created
				)
				VALUES 
				(
				'TRL',                                /* exp_idtype,          */
				@trl_id,                              /* exp_id,              */
				@exp_type,                            /* exp_code,            */
				@dt_create_date,                      /* exp_lastdate,        */
				@dt_apocalypse,                       /* exp_expirationdate,  */
				@exp_route,                           /* exp_routeto,         */
				'N',                                  /* exp_completed,       */
				@exp_pri,                             /* exp_priority,        */
				@dt_apocalypse,                       /* exp_compldate,       */
				@curr_user,                           /* exp_updateby,        */
				CURRENT_TIMESTAMP,                    /* exp_updateon,        */
				@description,                         /* exp_description,     */
				@drp_city,                            /* exp_city,            */
				@mov_number,                          /* mov_number,          */
				'N',                                  /* exp_control_avl_date,*/
				'Y'                                   /* exp_auto_created     */
				)
		END 
		ELSE /* expiration exists, update it */
		BEGIN
			UPDATE expiration
				SET exp_expirationdate = @dt_apocalypse,
				    exp_routeto = @exp_route,
				    exp_compldate = @dt_apocalypse,
				    exp_updateby = @curr_user,
				    exp_updateon = CURRENT_TIMESTAMP,
				    exp_city = @drp_city,
				    mov_number = @mov_number,
				    exp_completed = 'N' 
				WHERE exp_key = @exp_key
		END
	END
END

GO
GRANT EXECUTE ON  [dbo].[edi_create_container_assignments] TO [public]
GO
