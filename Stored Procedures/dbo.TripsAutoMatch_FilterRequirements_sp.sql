SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[TripsAutoMatch_FilterRequirements_sp]
(
	@car_id	varchar(8)
)

AS
/**
 * 
 * NAME:
 * dbo.TripsAutoMatch_FilterRequirements_sp
 *
 * TYPE:
 * Stored Proc
 *
 * DESCRIPTION:
 * 
 * Adjusts existing temp table #matching_trips, created by caller, and removes trips that cannot be assigned to passed in carrier
 *
 * PTS 46005/46541/46341/47752 JJF 20090428
 *
 **/

BEGIN

	DECLARE @Debug char(1)

	SELECT @Debug = 'N'


	DECLARE @current_item int
	DECLARE @lgh_number int
	DECLARE	@mov_number int
	DECLARE @trip_startdate datetime
	DECLARE @trip_enddate datetime
	DECLARE @reldate datetime

	DECLARE @current_lrq_id int
	DECLARE @lrq_equip_type varchar(6)
	DECLARE @lrq_not char(1)
	DECLARE @lrq_type varchar(6)
	DECLARE @lrq_mandatory char(1)
	DECLARE @lrq_quantity int
	DECLARE @lrq_expire_date datetime
	declare @check_loadreqs varchar(1)
  
	CREATE TABLE #temp_loadreqs(
					lrq_id int identity,
					drv1 varchar(8), 
					drv1_pri1soon int, 
					drv1_pri2soon int, 
					drv1_pri1now int, 
					drv1_pri2now int, 
					drv2 varchar(8), 
					drv2_pri1soon int, 
					drv2_pri2soon int,
					drv2_pri1now int, 
					drv2_pri2now int, 
					trc varchar(8), 
					trc_pri1soon int, 
					trc_pri2soon int,  
					trc_pri1now int,  
					trc_pri2now int,
					trl1 varchar(13), 
					trl1_pri1soon int, 
					trl1_pri2soon int, 
					trl1_pri1now int, 
					trl1_pri2now int, 
					trl2 varchar(13), 
					trl2_pri1soon int, 
					trl2_pri2soon int,
					trl2_pri1now int, 
					trl2_pri2now int,		
					lrq_equip_type varchar(6),
					lrq_not char(1), 
					lrq_type varchar(6),
					lrq_mandatory char(1), 
					requirement varchar(80), 
					asgn_id varchar(13),
					car varchar(8), 
					car_pri1soon int, 
					car_pri2soon int,
					car_pri1now int, 
					car_pri2now int, 
					lrq_quantity int,	
					lrq_availqty int, 
					lrq_inventory_item char(1),			
					lrq_expire_date datetime, 
					lgh_enddate datetime, 
					lgh_startdate datetime,
					chassis varchar(13),	
					chassis_pri1soon int,		
					chassis_pri2soon int,		
					chassis_pri1now int,
					chassis_pri2now int,
					chassis2 varchar(13),
					chassis2_pri1soon int,	
					chassis2_pri2soon int,	
					chassis2_pri1now int,
					chassis2_pri2now int,
					dolly varchar(13),		
					dolly_pri1soon int,			
					dolly_pri2soon int,			
					dolly_pri1now int,		
					dolly_pri2now int,
					dolly2 varchar(13),	
					dolly2_pri1soon int,		
					dolly2_pri2soon int,		
					dolly2_pri1now int,		
					dolly2_pri2now int,
					trailer3 varchar(13),
					trailer3_pri1soon int,	
					trailer3_pri2soon int,	
					trailer3_pri1now int,
					trailer3_pri2now int,
					trailer4 varchar(13),
					trailer4_pri1soon int,	
					trailer4_pri2soon int,	
					trailer4_pri1now int,
					trailer4_pri2now int,
					def_id_type			VARCHAR(6)
	)

	SELECT @check_loadreqs = Upper(Left(IsNull(gi_string1, 'N'), 1)) 
	FROM generalinfo 
	WHERE gi_name = 'IncludeLoadReqsinACS'

	IF @Debug = 'Y' BEGIN			
		PRINT '@check_loadreqs: ' + @check_loadreqs
	END 

	IF @check_loadreqs = 'N' BEGIN
		RETURN
	END
	
	SELECT @current_item = MIN(mt_id)
	FROM #matching_trips
	OPTION (KEEP PLAN)

	WHILE ISNULL(@current_item, 0) > 0 BEGIN
			DELETE #temp_loadreqs

			SELECT	@lgh_number = mt.lgh_number,
					@mov_number = mt.mov_number
			FROM	#matching_trips mt
			WHERE	mt.mt_id = @Current_item

			SELECT	@trip_startdate = lgh_startdate,
					@trip_enddate = lgh_enddate
			FROM	legheader_active lgh
			WHERE	lgh_number = @lgh_number

			INSERT #temp_loadreqs 
			EXEC d_notices_lrq_sp_with_car 
					'',--@drv1		VARCHAR(8), 
					'',--@drv2		VARCHAR(8), 
					'',--@trc		VARCHAR(8), 
					'',--@trl1		VARCHAR(13), 
					'',--@trl2		VARCHAR(13), 
					@car_id,--@car		VARCHAR(8), 
					@trip_startdate,
					@trip_enddate,
					@reldate,
					'',--@trl1_startdate DATETIME,
					'',--@trl1_enddate	DATETIME,
					'',--@trl2_startdate DATETIME,
					'',--@trl2_enddate	DATETIME,	
					@lgh_number, --3172
					@mov_number,  --2961
					'',--@chassis,
					@reldate, --@chassis_startdate,
					@reldate, --@chassis_enddate,
					'',--@chassis2,
					@reldate, --@chassis2_startdate,
					@reldate, --@chassis2_enddate,
					'',--@dolly,
					@reldate, --@dolly_startdate,
					@reldate, --@dolly_enddate,
					'',--@dolly2,
					@reldate, --@dolly2_startdate,
					@reldate, --@dolly2_enddate,
					'',--@trailer3,
					@reldate, --@trailer3_startdate,
					@reldate, --@trailer3_enddate,
					'',--@trailer4,
					@reldate, --@trailer4_startdate,
					@reldate --@trailer4_enddate

			IF @Debug = 'Y' BEGIN
				PRINT '@car_id: ' + @car_id
				PRINT '@lgh_number: ' + CONVERT(VARCHAR(10), @lgh_number)
				PRINT '@mov_number: ' + CONVERT(VARCHAR(10), @mov_number)

				SELECT * 
				FROM #temp_loadreqs		
			END

			IF (	SELECT count(*) 
					FROM #temp_loadreqs 
					WHERE isnull(lrq_equip_type, '') <> '') > 0 BEGIN

				SELECT	@current_lrq_id = isnull(min(lrq_id), 0) 
				FROM	#temp_loadreqs
				
				WHILE @current_lrq_id > 0 BEGIN
					SELECT	@lrq_equip_type = lrq_equip_type,
							@lrq_not = lrq_not,
							@lrq_type = lrq_type,
							@lrq_mandatory = lrq_mandatory,
							@lrq_quantity = lrq_quantity,
							@lrq_expire_date = lrq_expire_date
					FROM	#temp_loadreqs 
					WHERE	lrq_id = @current_lrq_id

					IF @Debug = 'Y' BEGIN			
						PRINT 'Checking requirement...'
						PRINT '@lrq_equip_type: ' + @lrq_equip_type
						PRINT '@lrq_not: ' + @lrq_not
						PRINT '@lrq_type: ' + @lrq_type
						PRINT '@lrq_mandatory: ' + @lrq_mandatory
						PRINT '@lrq_quantity: ' + convert(varchar(20), @lrq_quantity)
						PRINT '@lrq_expire_date: ' + convert(varchar(20), @lrq_expire_date)
						
					END

					IF @check_loadreqs in ('M', 'S') BEGIN
						IF @lrq_expire_date < @trip_startdate BEGIN
							GOTO skiploadreq
						END

						IF @check_loadreqs = 'M' and @lrq_mandatory = 'N' BEGIN-- not mandatory
							GOTO skiploadreq
						END
						ELSE BEGIN
							IF @lrq_not = 'N' BEGIN  -- Should/Must NOT have
								IF @lrq_equip_type = 'DRV' BEGIN
									IF @Debug = 'Y' BEGIN
										 PRINT 'Deleting carrier(s) because of driver load requirement (N)'
									END

									DELETE FROM #matching_trips
									WHERE	@car_id in (SELECT DISTINCT drq.drq_driver 
															FROM	driverqualifications drq
															WHERE	drq.drq_source = 'CAR'
																		and	drq.drq_type = @lrq_type
																		and drq.drq_expire_date >= @trip_startdate
															)
											and #matching_trips.mt_id = @current_item
								END

								IF @lrq_equip_type = 'TRC' BEGIN
									IF @Debug = 'Y' BEGIN
										PRINT 'Deleting carrier(s) because of tractor load requirement (N)'
									END
									
									DELETE FROM #matching_trips
									WHERE	@car_id in (SELECT DISTINCT tca.tca_tractor 
															FROM	tractoraccesories tca
															WHERE	tca.tca_source = 'CAR'
																	and tca.tca_type = @lrq_type
																	and tca.tca_expire_date >= @trip_startdate
															)
											and #matching_trips.mt_id = @current_item
								END

								IF @lrq_equip_type = 'TRL' BEGIN
									IF @Debug = 'Y' BEGIN
										PRINT 'Deleting carrier(s) because of trailer load requirement (N)'
									END
									
									DELETE FROM #matching_trips
									WHERE	@car_id in (SELECT DISTINCT ta.ta_trailer 
															FROM trlaccessories ta
															WHERE	ta.ta_source = 'CAR'
																	and ta.ta_type = @lrq_type
																	and ta.ta_expire_date >= @trip_startdate
															)
											and #matching_trips.mt_id = @current_item
								END

								IF @lrq_equip_type = 'CAR' BEGIN
									IF @Debug = 'Y' BEGIN
										PRINT 'Deleting carrier(s) because of carrier load requirement (N)'
									END

									DELETE FROM #matching_trips
									WHERE	@car_id in (SELECT DISTINCT caq.caq_carrier_id 
															FROM	carrierqualifications caq
															WHERE	caq.caq_type = @lrq_type
																	and caq.caq_expire_date >= @trip_startdate
															)
											and #matching_trips.mt_id = @current_item
								END
							END

							IF @lrq_not = 'Y' BEGIN  -- Should/Must have.
								IF @lrq_equip_type = 'DRV' BEGIN
									IF @Debug = 'Y' BEGIN
										PRINT 'Deleting carrier(s) because of driver load requirement (Y)'
									END

									DELETE #matching_trips
									WHERE	@car_id not in (SELECT DISTINCT drq.drq_driver 
																FROM	driverqualifications drq
																WHERE	drq.drq_source = 'CAR'
																		and drq.drq_type = @lrq_type
 																		and drq.drq_expire_date >= @trip_enddate
																)
											and #matching_trips.mt_id = @current_item
								END

								IF @lrq_equip_type = 'TRC' BEGIN
									IF @Debug = 'Y' BEGIN
										PRINT 'Deleting carrier(s) because of tractor load requirement (Y)'
									END
									
									DELETE	#matching_trips
									WHERE	@car_id not in (SELECT DISTINCT tca.tca_tractor 
																FROM	tractoraccesories tca
																WHERE	tca.tca_source = 'CAR'
																		and tca.tca_type = @lrq_type
																		and tca.tca_expire_date >= @trip_enddate
																)
											and #matching_trips.mt_id = @current_item
								END

								IF @lrq_equip_type = 'TRL' BEGIN
									IF @Debug = 'Y' BEGIN
										PRINT 'Deleting carrier(s) because of trailer load requirement (Y)'
									END

									DELETE	#matching_trips
									WHERE	@car_id not in (SELECT DISTINCT ta.ta_trailer 
																FROM	trlaccessories ta
																WHERE	ta.ta_source = 'CAR'
																		and ta.ta_type = @lrq_type
																		and ta.ta_expire_date >= @trip_enddate
																)
											and #matching_trips.mt_id = @current_item
								END

								IF @lrq_equip_type = 'CAR' BEGIN
									IF @Debug = 'Y' BEGIN
										PRINT 'Deleting carrier(s) because of carrier load requirement (Y)'
									END

									DELETE	#matching_trips
									WHERE	@car_id not in (SELECT DISTINCT	caq_carrier_id 
															FROM	carrierqualifications caq
															WHERE	caq_type = @lrq_type
																	and caq_expire_date >= @trip_enddate)
											and #matching_trips.mt_id = @current_item
								END
							END

						END
					END

					skiploadreq:

					SELECT	@current_lrq_id = isnull(min(lrq_id), 0) 
					FROM #temp_loadreqs 
					WHERE lrq_id  > @current_lrq_id
					OPTION (KEEP PLAN)

				END
			END

			--Remove those otherwise failing expirations
			IF EXISTS(	SELECT	*
						FROM	#temp_loadreqs
						WHERE	(drv1_pri1now > 0)
								OR (drv1_pri2now > 0)
								OR (trc_pri1now > 0)
								OR (trc_pri2now > 0)
								OR (trl1_pri1now > 0)
								OR (trl1_pri2now > 0)
								OR (trl2_pri1now > 0)
								OR (trl2_pri2now > 0)
								OR (car_pri1now > 0)
								OR (car_pri2now > 0)) BEGIN
				DELETE #matching_trips
				WHERE mt_id = @current_item
			END

		SELECT @current_item = MIN(mt.mt_id)
		FROM #matching_trips mt
		WHERE mt.mt_id > @current_item

	END

	
	DROP TABLE #temp_loadreqs

	RETURN 
END
GO
GRANT EXECUTE ON  [dbo].[TripsAutoMatch_FilterRequirements_sp] TO [public]
GO
