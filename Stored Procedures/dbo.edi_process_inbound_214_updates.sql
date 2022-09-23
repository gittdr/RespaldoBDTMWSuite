SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- creates procedure  
CREATE PROCEDURE [dbo].[edi_process_inbound_214_updates]  
						@p_stpNumber		int,   
						@p_mov_number		int,
						@p_process_dt		datetime,   
						@p_edi_code			varchar(256),   
						@p_edi_reasoncode   varchar(256),   
						@p_lgh_outstatus    varchar(256),   
						@p_lgh_204status    varchar(256),   
						@p_Lgh_number       int,
						@p_process_status   varchar(256),   
						@p_stp_mfh_sequence int,   
						@p_a				int,
						@p_id_num           int,
						@p_city_name		varchar(256),
						@p_state			varchar(256),
						@p_longitude		varchar(256),
						@p_latitude			varchar(256),
						@p_car_edi_scac			varchar(256),
						@p_ord_hdrnumber	int,
						@p_ref_type			varchar(256),
						@p_ref_number		varchar(256),
						@p_invwhen			varchar(256)
 
AS  
  
Set NOCOUNT ON  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    

/*******************************************************************************************************************  
  Object Description:
  Process EDI inbound 214 updates

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  07/19/2016   John Richardson  PTS: 96037  Fixed bug that caused (AWC) functionality to actualize the departure stop
********************************************************************************************************************/

DECLARE   
	@v_abbr varchar(256),
	@v_arrivalcodes varchar(256),
	@v_departurecodes varchar(256),
	@v_appointmentcodes varchar(256),
	@v_miscdatescodes varchar(256),
	@v_checkcallcodes varchar(256),
	@v_stp_departure_status varchar(256),
	@v_stp_number_rend int,
	@v_stp_status varchar(256),
	@v_edi_code varchar(256),
	@v_updateby varchar(256),
	@v_city_code int, 
	@v_latseconds int,
	@v_longseconds int,
	@v_car_id varchar(256),
	@v_ckc_number int,
	@v_ref_count int,
	@v_ref_sequence int,
	@v_mov_number int,
	@v_stp_mfh_sequence int, 
	@v_next_stp_number int
	

if @p_edi_reasoncode = 'NS' 
	set @v_abbr = 'UNK'
else
	SELECT @v_abbr = ISNULL(abbr, 'UNK')
		FROM labelfile
		WHERE labeldefinition = 'reasonlate' AND
			edicode = @p_edi_reasoncode;

SELECT @v_arrivalcodes = gi_string1 FROM generalinfo WHERE gi_name = 'Inbound214Arrival'
SELECT @v_departurecodes = gi_string1 FROM generalinfo WHERE gi_name = 'Inbound214Departure'
SELECT @v_appointmentcodes = gi_string1 FROM generalinfo WHERE gi_name = 'Inbound214Appointment'
SELECT @v_miscdatescodes = gi_string1 FROM generalinfo WHERE gi_name = 'Inbound214MiscDates'
SELECT @v_checkcallcodes = gi_string1 FROM generalinfo WHERE gi_name = 'inbound214CheckCalls'

If IsNull(@p_invwhen,'') = ''
	set @p_invwhen = 'STD'

set @p_edi_code = ',' + UPPER(@p_edi_code) + ','

IF CHARINDEX(@p_edi_code, @v_arrivalcodes) > 0 
	BEGIN 
		if @p_lgh_outstatus = 'CMP' 
			RETURN 1
		
		if @p_process_status = 'ACC'
			BEGIN
				IF @p_stp_mfh_sequence > 1
					BEGIN
						SELECT @v_stp_departure_status = ISNULL(stp_departure_status, 'OPN')
							FROM stops
							WHERE stops.mov_number = @p_mov_number AND
								stops.stp_mfh_sequence = @p_stp_mfh_sequence - 1;

						IF @v_stp_departure_status <> 'DNE'
							RETURN -1
					END
				UPDATE stops SET stp_status = 'DNE', stp_arrivaldate = @p_process_dt, stp_reasonlate = @v_abbr
					WHERE stp_number = @p_stpNumber;
			END
		ELSE IF @p_process_status = 'AWC'
			BEGIN
				UPDATE stops SET stp_arrivaldate = @p_process_dt, stp_reasonlate = @v_abbr
					WHERE stp_number = @p_stpNumber;
			END
			
		UPDATE stops SET stp_departuredate = @p_process_dt
			WHERE stp_number = @p_stpNumber AND stp_departuredate < stp_arrivaldate;

		IF @p_lgh_outstatus <> 'TDA'
			UPDATE legheader set lgh_204status = 'TDA' 
				WHERE lgh_number = @p_lgh_number	
				
		exec update_assetassignment @p_mov_number 
		exec Update_move @p_mov_number
		exec Update_ord @p_mov_number, @p_invwhen 
	END
ELSE IF CHARINDEX(@p_edi_code, @v_departurecodes) > 0 
	BEGIN
		IF @p_lgh_outstatus = 'CMP'
			BEGIN
				SELECT @v_stp_number_rend = stp_number_rend, @v_stp_departure_status = stp_departure_status
					FROM stops, legheader
					WHERE stops.stp_number = @p_stpNumber AND
						stops.lgh_number = legheader.lgh_number;
				
				IF ISNULL(@v_stp_departure_status, '') = ''
					SET @v_stp_departure_status = 'OPN'
			END
			IF @p_stpNumber = @v_stp_number_rend AND @v_stp_departure_status = 'OPN'
				BEGIN
					IF @p_process_status = 'ACC'
						BEGIN
							SELECT @v_stp_status = ISNULL(stp_status, 'OPN')
								FROM stops
								WHERE stp_number = @p_stpNumber
							
							IF @v_stp_status <> 'DNE'
								RETURN -1
								
							UPDATE stops SET stp_departure_status = 'DNE', stp_departuredate = @p_process_dt, stp_reasonlate_depart = @v_abbr
								WHERE stp_number = @p_stpNumber
						END
					ELSE IF @p_process_status = 'AWC'
						BEGIN
							UPDATE stops SET stp_departuredate = @p_process_dt, stp_reasonlate_depart = @v_abbr
								WHERE stp_number = @p_stpNumber
						END

			
					exec update_assetassignment @p_mov_number 
					exec Update_move @p_mov_number
					exec Update_ord @p_mov_number, @p_invwhen 
				END
		ELSE
			BEGIN
				SELECT @v_stp_status = ISNULL(stp_status, 'OPN')
					FROM stops
					WHERE stp_number = @p_stpNumber

				IF @p_process_status = 'ACC'
					BEGIN
						IF @v_stp_status <> 'DNE'
							RETURN -1
							
						UPDATE stops SET stp_departure_status = 'DNE', stp_departuredate = @p_process_dt, stp_reasonlate_depart = @v_abbr
							WHERE stp_number = @p_stpNumber
					END
				ELSE IF @p_process_status = 'AWC'
					BEGIN
						IF @v_stp_status <> 'DNE'
                            UPDATE stops SET stp_departuredate = @p_process_dt, stp_reasonlate_depart = @v_abbr
                                WHERE stp_number = @p_stpNumber
                        ELSE
                            UPDATE stops SET stp_departure_status = 'DNE', stp_departuredate = @p_process_dt, stp_reasonlate_depart = @v_abbr
                                    WHERE stp_number = @p_stpNumber

					END

				exec update_assetassignment @p_mov_number
				exec Update_move @p_mov_number
				exec Update_ord @p_mov_number, @p_invwhen 
			END
	END
ELSE IF CHARINDEX(@p_edi_code, @v_appointmentcodes) > 0 
	BEGIN 
		IF @p_lgh_outstatus = 'CMP'
			RETURN -1

		UPDATE stops SET stp_schdtearliest = @p_process_dt, stp_schdtlatest = @p_process_dt, stp_reasonlate = @v_abbr
			WHERE stp_number = @p_stpNumber
	
		IF @p_lgh_outstatus = 'PLN'
			UPDATE legheader SET lgh_outstatus = 'DSP',lgh_204status = 'TDA'
				WHERE lgh_number = @p_lgh_number
			
		exec update_assetassignment @p_mov_number 
		exec Update_move @p_mov_number
		exec Update_ord @p_mov_number, @p_invwhen 
	END
ELSE IF CHARINDEX(@p_edi_code, @v_miscdatescodes) > 0 
	BEGIN 
		set @v_edi_code = SUBSTRING(@p_edi_code, 2, LEN(@p_edi_code) - 2)
		SELECT @v_updateby = SYSTEM_USER
		INSERT INTO miscdates (mdt_table, mdt_tablekey, mdt_type, mdt_value, mdt_updateby, mdt_updatedate)
					   VALUES ('stops', @p_stpNumber, @v_edi_code, @p_process_dt, @v_updateby, GETDATE());
	END
ELSE IF CHARINDEX(@p_edi_code, @v_checkcallcodes) > 0 
	BEGIN 
		SELECT TOP 1 @v_city_code = ISNULL(cty_code, 0)
			FROM city
			WHERE cty_name = @p_city_name AND cty_state = @p_state
			
		IF ISNULL(@p_longitude, '') = ''
			SET @p_longitude = '0'
			
		if ISNULL(@p_latitude, '') = ''
			SET @p_latitude = '0'

		SET @v_longseconds = ROUND(CAST(@p_longitude AS DECIMAL) * 3600, 0)
		SET @v_latseconds = ROUND(CAST(@p_latitude AS DECIMAL) * 3600, 0)

		SELECT @v_car_id = ISNULL(car_id, '') FROM carrier WHERE car_scac = @p_car_edi_scac
		
		if @v_car_id = ''
			set @v_car_id = @p_car_edi_scac
		
		exec @v_ckc_number = getsystemnumber 'CKCNUM', ' '

		SELECT @v_updateby = SYSTEM_USER
				
		INSERT INTO checkcall (ckc_number, ckc_status, ckc_asgntype, ckc_asgnid, ckc_date, ckc_latseconds, 
							   ckc_longseconds, ckc_lghnumber, ckc_city, ckc_cityname, ckc_state, ckc_updatedon, 
							   ckc_updatedby, ckc_event, ckc_tractor)
					   VALUES (@v_ckc_number, 'HIST', 'CAR', @v_car_id, @p_process_dt, @v_latseconds,
						       @v_longseconds, @p_lgh_number, @v_city_code, @p_city_name, @p_state, GETDATE(), 
						       @v_updateby, 'TRP', 'UNKNOWN');
	END
ELSE IF  @p_edi_code = ',REFNUM,'
	BEGIN 
		IF @p_ord_hdrnumber > 0
			BEGIN
				SELECT @v_ref_count = COUNT(*) FROM referencenumber
					WHERE ref_table = 'orderheader' AND ref_tablekey = @p_ord_hdrnumber
					
				IF @v_ref_count > 0
					BEGIN
					
						SELECT @v_ref_sequence = ISNULL(Min(ref_sequence), 0)
							FROM referencenumber
							WHERE ref_table = 'orderheader' AND ref_tablekey = @p_ord_hdrnumber AND ref_type = @p_ref_type;
							
						IF @v_ref_sequence = 0
							BEGIN
								INSERT INTO referencenumber (ref_table, ref_tablekey, ref_type, ref_number, ref_sequence, ord_hdrnumber)
									VALUES ('orderheader', @p_ord_hdrnumber, @p_ref_type, @p_ref_number, @v_ref_count + 1, @p_ord_hdrnumber);
							END
						ELSE IF @v_ref_sequence = 1 
							BEGIN
								UPDATE referencenumber SET ref_number = @p_ref_number
									WHERE ref_table = 'orderheader' AND ref_tablekey = @p_ord_hdrnumber AND
										  ref_type = @p_ref_type AND ref_sequence = @v_ref_sequence;
									   
								UPDATE orderheader SET ord_refnum = @p_ref_number
									WHERE ord_hdrnumber = @p_ord_hdrnumber;
							END
						ELSE IF @v_ref_sequence > 1 
							BEGIN
								UPDATE referencenumber SET ref_number = @p_ref_number
									WHERE ref_table = 'orderheader' AND ref_tablekey = @p_ord_hdrnumber AND
									 	  ref_type = @p_ref_type AND ref_sequence = @v_ref_sequence;
							END
					END
				ELSE IF @v_ref_count = 0
					BEGIN
						INSERT INTO referencenumber (ref_table, ref_tablekey, ref_type, ref_number, ref_sequence, ord_hdrnumber)
							VALUES ('orderheader', @p_ord_hdrnumber, @p_ref_type, @p_ref_number, 1, @p_ord_hdrnumber);
			
						UPDATE orderheader SET ord_reftype = @p_ref_type, ord_refnum = @p_ref_number
							WHERE ord_hdrnumber = @p_ord_hdrnumber;
					END
			END
		ELSE IF @p_stpNumber > 0
			BEGIN
				SELECT @v_ref_count = COUNT(*) FROM referencenumber 
					WHERE ref_table = 'stops' AND ref_tablekey = @p_stpNumber
					
				IF @v_ref_count > 0
					BEGIN
						SELECT @v_ref_sequence = ISNULL(MIN(ref_sequence),0)
							FROM referencenumber
							WHERE ref_table = 'stops' AND ref_tablekey = @p_stpNumber AND ref_type = @p_ref_type
							
						if @v_ref_sequence = 0
							BEGIN
								INSERT INTO referencenumber (ref_table, ref_tablekey, ref_type, ref_number, ref_sequence)
									VALUES ('stops', @p_stpNumber, @p_ref_type, @p_ref_number, @v_ref_count + 1);
							END
						ELSE IF @v_ref_sequence = 1
							BEGIN 
							
								UPDATE referencenumber SET ref_number = @p_ref_number
									WHERE ref_table = 'stops' AND ref_tablekey = @p_stpNumber AND
										  ref_type = @p_ref_type AND ref_sequence = @v_ref_sequence
						 
						 		UPDATE stops SET stp_refnum = @p_ref_number
									WHERE stp_number = @p_stpNumber
							
							END
						ELSE IF @v_ref_sequence > 1
							BEGIN
								UPDATE referencenumber SET ref_number = @p_ref_number
									WHERE ref_table = 'stops' AND ref_tablekey = @p_stpNumber AND
										  ref_type = @p_ref_type AND ref_sequence = @v_ref_sequence
							END
					END
				ELSE IF @v_ref_count = 0
					BEGIN
						INSERT INTO referencenumber (ref_table, ref_tablekey, ref_type, ref_number, ref_sequence)
							VALUES ('stops', @p_stpNumber, @p_ref_type, @p_ref_number, 1);
			
						UPDATE stops SET stp_reftype = @p_ref_type, stp_refnum = @p_ref_number
							WHERE stp_number = @p_stpNumber;
					END
					
				SELECT @v_mov_number = mov_number, @v_stp_mfh_sequence = stp_mfh_sequence 
					FROM stops WHERE stp_number = @p_stpNumber
				
				SELECT @v_next_stp_number = ISNULL(stp_number, 0)
					FROM stops WHERE stp_number = @p_stpNumber AND stp_mfh_sequence = @v_stp_mfh_sequence + 1
					
				IF @v_next_stp_number > 0
					BEGIN
						SELECT @v_ref_count = COUNT(*) FROM referencenumber 
							WHERE ref_table = 'stops' AND ref_tablekey = @p_stpNumber
							
						IF @v_ref_count > 0
							BEGIN
								SELECT @v_ref_sequence = ISNULL(MIN(ref_sequence),0)
									FROM referencenumber 
									WHERE ref_table = 'stops' AND ref_tablekey = @v_next_stp_number AND ref_type = @p_ref_type
									
								IF @v_ref_sequence = 0
									BEGIN
										INSERT INTO referencenumber (ref_table, ref_tablekey, ref_type, ref_number, ref_sequence)
											VALUES ('stops', @v_next_stp_number, @p_ref_type, @p_ref_number, @v_ref_count + 1);
									END
								ELSE IF @v_ref_sequence = 1
									BEGIN
										UPDATE referencenumber SET ref_number = @p_ref_number
											WHERE ref_table = 'stops' AND ref_tablekey = @v_next_stp_number AND
												  ref_type = @p_ref_type AND ref_sequence = @v_ref_sequence;
					
										UPDATE stops SET stp_refnum = @p_ref_number
											WHERE stp_number = @v_next_stp_number;
									END
								ELSE IF @v_ref_sequence > 0
									BEGIN
										UPDATE referencenumber SET ref_number = @p_ref_number
											WHERE ref_table = 'stops' AND ref_tablekey = @v_next_stp_number AND
												  ref_type = @p_ref_type AND ref_sequence = @v_ref_sequence;
									END
							END
						ELSE IF @v_ref_count = 0
							BEGIN
								INSERT INTO referencenumber (ref_table, ref_tablekey, ref_type, ref_number,	ref_sequence)
									VALUES ('stops', @v_next_stp_number, @p_ref_type, @p_ref_number, 1);
				
								UPDATE stops SET stp_reftype = @p_ref_type, stp_refnum = @p_ref_number
									WHERE stp_number = @v_next_stp_number;
							END
					END
			END	
	END

RETURN 1
	
GO
GRANT EXECUTE ON  [dbo].[edi_process_inbound_214_updates] TO [public]
GO
