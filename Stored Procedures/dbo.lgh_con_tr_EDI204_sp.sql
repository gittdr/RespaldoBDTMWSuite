SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[lgh_con_tr_EDI204_sp](
	@inserted UtLegheaderConsolidated READONLY
	,@deleted UtLegheaderConsolidated READONLY
)
AS

/*******************************************************************************************************************  
  Object Description:

  Revision History:

  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2017-01-27   Dan Clemens			        Handle logic for ProcessOutbound204, RequireAssignedTrailerEDI204,outbound204railbilling  GI setttings that are used in ut_legheader_consolidated.

********************************************************************************************************************/
DECLARE	
				@lgh_number											INTEGER,
				@new_lgh_carrier								VARCHAR(8),
				@old_lgh_carrier								VARCHAR(8),
				@new_lgh_tradingpartner					VARCHAR(8),
				@new_car_204flag								INTEGER,
				@new_car_type1									VARCHAR(6),
				@new_car_204update							VARCHAR(6),
				@old_car_204flag								INTEGER,
				@old_car_type1									VARCHAR(6),
				@old_car_204update							VARCHAR(6),
				@new_lgh_204validate						INTEGER,
				@old_lgh_204validate						INTEGER,
				@new_lgh_outstatus							VARCHAR(6),
				@origin_rail										CHAR(1),
				@dest_rail											CHAR(1),
				@edi204Created									CHAR(1),
				@send_204												CHAR(1),
				@RequireAssignedTrailerEDI204		CHAR(1),
				@edi204CarTypeField							VARCHAR(60),
				@edi204CarTypes									VARCHAR(60),
				@ProcessOutbound204							CHAR(1),
				@outbound204railbilling					CHAR(1),
				@check4trailer									CHAR(1),
				@lastcarrier204									VARCHAR(8),
				@new_trailer										VARCHAR(13),
				@old_trailer										VARCHAR(13),
				@new_lgh_204status							VARCHAR(6)

DECLARE	@edi204CarTypeStrings		TABLE (string NVARCHAR(512))


-- PTS64334 DMA 9/10/2012, PTS61858
SELECT	@edi204Created = 'N',
				@RequireAssignedTrailerEDI204 = 'N',
				@edi204CarTypeField = '',
				@edi204CarTypes = '',
				@send_204 = 'N'

SELECT	@ProcessOutbound204 = CASE 
																  WHEN gi_name = 'ProcessOutbound204'	THEN LEFT(COALESCE(gi_string1, 'N'), 1)
																  ELSE @ProcessOutbound204
															END,
				@RequireAssignedTrailerEDI204 = CASE 
																						WHEN gi_name = 'RequireAssignedTrailerEDI204'	THEN LEFT(COALESCE(gi_string1, 'N'), 1)
																						ELSE @RequireAssignedTrailerEDI204
																				END,
				@edi204CarTypeField = CASE 
																  WHEN gi_name = 'RequireAssignedTrailerEDI204'	THEN COALESCE(gi_string2, '')
																	ELSE @edi204CarTypeField
															END,
				@edi204CarTypes = CASE 
														  WHEN gi_name = 'RequireAssignedTrailerEDI204'	THEN COALESCE(gi_string3, '')
														  ELSE @edi204CarTypes
												  END,
				@outbound204railbilling = CASE
																		  WHEN gi_name = 'outbound204railbilling' THEN LEFT(COALESCE(gi_string1, 'N'), 1)
																			ELSE @outbound204railbilling
																  END
	FROM	generalinfo
 WHERE	gi_name IN ('ProcessOutbound204', 'RequireAssignedTrailerEDI204', 'outbound204railbilling');

IF @RequireAssignedTrailerEDI204 NOT IN ('Y', 'N')
BEGIN
  SET @RequireAssignedTrailerEDI204 = 'N';
END;

SET @check4trailer = CASE  
                     WHEN ISNULL(@edi204CarTypes,'') = '' THEN 'Y'
                     ELSE 'N'
                   END;

DECLARE EDI204Cursor CURSOR LOCAL FAST_FORWARD FOR
		SELECT	i.lgh_number,
						COALESCE(i.lgh_carrier, 'UNKNOWN'),
						COALESCE(d.lgh_carrier, 'UNKNOWN'),
						COALESCE(i.lgh_204_tradingpartner, 'UNKNOWN'),
						COALESCE(newCarrier.car_204flag, 0),
						COALESCE(newCarrier.car_type1, 'UNK'),
						COALESCE(newCarrier.car_204update, 'ALL'),
						COALESCE(oldCarrier.car_204flag, 0),
						COALESCE(oldCarrier.car_type1, 'UNK'),
						COALESCE(oldCarrier.car_204update, 'ALL'),
						COALESCE(i.lgh_204validate, 1),
						COALESCE(d.lgh_204validate, 1),
						COALESCE(i.lgh_outstatus, 'AVL'),
						COALESCE(startCompany.cmp_railramp, 'N'),
						COALESCE(endCompany.cmp_railramp, 'N'),
						COALESCE(i.lgh_primary_trailer, 'UNKNOWN'),
						COALESCE(d.lgh_primary_trailer, 'UNKNOWN'),
						i.lgh_204status
		  FROM	@inserted i
								INNER JOIN @deleted d ON d.lgh_number = i.lgh_number
								INNER JOIN carrier newCarrier ON newCarrier.car_id = i.lgh_carrier
								INNER JOIN carrier oldCarrier ON oldCarrier.car_id = d.lgh_carrier
								INNER JOIN company startCompany ON startCompany.cmp_id = i.cmp_id_start
								INNER JOIN company endCompany ON endCompany.cmp_id = i.cmp_id_end
		 WHERE	(i.lgh_carrier <> d.lgh_carrier)
		    OR  (i.lgh_primary_trailer <> d.lgh_primary_trailer)
				OR	(i.lgh_204validate <> d.lgh_204validate);

OPEN EDI204Cursor;

FETCH NEXT FROM EDI204Cursor
		INTO @lgh_number,
				 @new_lgh_carrier,
				 @old_lgh_carrier,
				 @new_lgh_tradingpartner,
				 @new_car_204flag,
				 @new_car_type1,
				 @new_car_204update,
				 @old_car_204flag,
				 @old_car_type1,
				 @old_car_204update,
				 @new_lgh_204validate,
				 @old_lgh_204validate,
				 @new_lgh_outstatus,
				 @origin_rail,
				 @dest_rail,
				 @new_trailer,
				 @old_trailer,
				 @new_lgh_204status;

WHILE @@FETCH_STATUS = 0
BEGIN

		IF @RequireAssignedTrailerEDI204 = 'Y' AND @check4trailer = 'N'
		BEGIN   
				INSERT @edi204CarTypeStrings (string) 
						SELECT	*  
							FROM	dbo.CSVStringsToTable_fn(@edi204CarTypes);

				IF @edi204CarTypeField = 'CARTYPE1' AND EXISTS(SELECT car_id FROM dbo.carrier WHERE car_id = @new_lgh_carrier AND car_Type1 IN (SELECT * FROM @edi204CarTypeStrings))
						 OR
					 @edi204CarTypeField = 'CARTYPE2' AND EXISTS(SELECT car_id FROM dbo.carrier WHERE car_id = @new_lgh_carrier AND car_Type2 IN (SELECT * FROM @edi204CarTypeStrings)) 
						 OR
					 @edi204CarTypeField = 'CARTYPE3' AND EXISTS(SELECT car_id FROM dbo.carrier WHERE car_id = @new_lgh_carrier AND car_Type3 IN (SELECT * FROM @edi204CarTypeStrings))
						 OR
					 @edi204CarTypeField = 'CARTYPE4' AND EXISTS(SELECT car_id FROM dbo.carrier WHERE car_id = @new_lgh_carrier AND car_Type4 IN (SELECT * FROM @edi204CarTypeStrings))
				BEGIN
					SET @check4trailer = 'Y';
				END;
		END;

		SET	@lastcarrier204 = 'UNKNOWN'
		
		IF @check4trailer = 'Y'
		BEGIN
				SELECT TOP 1 
								@lastcarrier204 = car_id
				  FROM	edi_outbound204_order 
				 WHERE	edi_code = '00'
				   AND	edi_message_type = '204'
					 AND lgh_number = @lgh_number
				ORDER BY created_dt DESC
    END

		IF @RequireAssignedTrailerEDI204 = 'N' OR (@RequireAssignedTrailerEDI204 = 'Y' and @check4trailer = 'Y' and @new_trailer <> 'UNKNOWN') OR (@RequireAssignedTrailerEDI204 = 'Y' and @check4trailer = 'N') 
		BEGIN
				set @send_204 = 'Y'
		END

		IF @new_lgh_carrier <> 'UNKNOWN' AND @new_lgh_carrier <> @old_lgh_carrier AND @old_lgh_carrier = 'UNKNOWN' AND @new_lgh_tradingpartner = 'UNKNOWN' 
		BEGIN
				IF @new_car_204flag = 1 AND @new_lgh_204validate = 1 AND @send_204 = 'Y'
				BEGIN
						IF @outbound204railbilling = 'N'
						BEGIN
								IF @new_lgh_outstatus <> 'STD'
								BEGIN
										EXEC create_outbound204 @lgh_number, @new_lgh_carrier, 'ADD'
										SELECT @edi204Created = 'Y'
								END
						END
						ELSE
						BEGIN
								IF @origin_rail <> 'Y' OR @dest_rail <> 'Y' OR @new_car_type1 <> 'RAL'
								BEGIN
										IF @new_car_204flag = 1 and @new_lgh_204validate = 1 and @send_204 = 'Y'
										BEGIN
												EXEC create_outbound204 @lgh_number, @new_lgh_carrier, 'ADD'
												SELECT @edi204Created = 'Y'
										END
								END 
						END
				END
		END

		IF @new_lgh_carrier = 'UNKNOWN' AND @new_lgh_carrier <> @old_lgh_carrier AND @old_lgh_carrier <> 'UNKNOWN' AND @new_lgh_tradingpartner = 'UNKNOWN'
		BEGIN
				IF @old_car_204flag = 1 AND @old_lgh_204validate = 1 AND (@old_car_204update = 'ALL' OR @old_car_204update = 'CAN')
				BEGIN
						IF @new_lgh_204status = 'TND' OR @new_lgh_204status = 'TDA' or @new_lgh_204status = 'TDR' or @new_lgh_204status = 'TDC' 
						BEGIN
								IF @check4trailer = 'N' OR @lastcarrier204 = @old_lgh_carrier
								BEGIN
										EXEC create_outbound204 @lgh_number, @old_lgh_carrier, 'CANCEL'
								END
						END
						IF @new_lgh_204status <> 'TDR' OR @new_lgh_204status IS NULL
						BEGIN
								UPDATE legheader
									 SET lgh_204status = null,
											 lgh_204date = null,
											 lgh_car_rate = 0,
											 lgh_car_charge = 0,
											 lgh_car_accessorials = 0,
											 lgh_car_totalcharge = 0,
											 lgh_acc_fsc = 0,
											 lgh_spot_rate = '0',
											 lgh_spot_rate_updateddt = NULL,
											 lgh_spot_rate_updatedby = NULL,
											 lgh_railtemplatedetail_id = NULL 
								 WHERE lgh_number = @lgh_number
		         END
						 IF @new_lgh_204status = 'TDR'
						 BEGIN
								UPDATE legheader
									 SET lgh_car_rate = 0,
											 lgh_car_charge = 0,
											 lgh_car_accessorials = 0,
											 lgh_car_totalcharge = 0,
											 lgh_acc_fsc = 0,
											 lgh_spot_rate = '0',
											 lgh_spot_rate_updateddt = NULL,
											 lgh_spot_rate_updatedby = NULL,
											 lgh_railtemplatedetail_id = NULL
								 WHERE lgh_number = @lgh_number
						 END    
				END
		END
 
		IF @new_lgh_carrier <> 'UNKNOWN' AND @old_lgh_carrier <> 'UNKNOWN' AND @new_lgh_carrier <> @old_lgh_carrier  AND @new_lgh_tradingpartner = 'UNKNOWN'
		BEGIN
				IF @old_car_204flag = 1 AND @old_lgh_204validate = 1 AND (@old_car_204update = 'ALL' OR @old_car_204update = 'CAN')
				BEGIN
						IF @new_lgh_204status = 'TND' OR @new_lgh_204status = 'TDA' or @new_lgh_204status = 'TDC' 
						BEGIN
								IF @check4trailer = 'N' OR @lastcarrier204 = @old_lgh_carrier
								BEGIN
										EXEC create_outbound204 @lgh_number, @old_lgh_carrier, 'CANCEL'
								END

								IF @new_lgh_outstatus = 'DSP'
								BEGIN
										UPDATE legheader
											 SET lgh_204status = null,
													 lgh_204date = null,
													 lgh_outstatus = 'PLN'
										 WHERE lgh_number = @lgh_number
								END
								ELSE
								BEGIN
										UPDATE legheader
											 SET lgh_204status = null,
													 lgh_204date = null
										 WHERE lgh_number = @lgh_number
								END
						END
				END
				IF @outbound204railbilling = 'N'
				BEGIN
		         IF @new_car_204flag = 1 AND @new_lgh_204validate = 1
						 BEGIN
								IF @send_204 = 'Y' 
								BEGIN
										EXEC create_outbound204 @lgh_number, @new_lgh_carrier, 'ADD'
										SELECT @edi204Created = 'Y'
								END
						END
						ELSE
						BEGIN
								UPDATE	legheader
								   SET	lgh_204status = null,
												lgh_204date = null
								 WHERE	lgh_number = @lgh_number
						END
				END
				ELSE
				BEGIN
		        IF @origin_rail <> 'Y' OR @dest_rail <> 'Y' OR @new_car_type1 <> 'RAL'
						BEGIN
								IF @new_car_204flag = 1 and @new_lgh_204validate = 1
								BEGIN
							      IF @send_204 = 'Y' 
										BEGIN
												EXEC create_outbound204 @lgh_number, @new_lgh_carrier, 'ADD'
												SELECT @edi204Created = 'Y'
										END
								END
								ELSE
								BEGIN
										UPDATE	legheader
										   SET	lgh_204status = null,
														lgh_204date = null
		                 WHERE	lgh_number = @lgh_number
								END
						END
				END
		END

		IF @new_car_204flag = 1 AND @new_lgh_204validate = 1
		BEGIN
				IF @old_trailer = 'UNKNOWN' AND @new_trailer <> 'UNKNOWN' AND @new_trailer <> @old_trailer AND @new_lgh_carrier <> 'UNKNOWN' AND @edi204Created = 'N'
				BEGIN
						IF @RequireAssignedTrailerEDI204 = 'Y' and @check4trailer = 'Y' AND @send_204 = 'Y' AND @lastcarrier204 <> @new_lgh_carrier
						BEGIN
								IF @outbound204railbilling = 'N'
								BEGIN
										EXEC create_outbound204 @lgh_number, @new_lgh_carrier, 'ADD'
										SELECT @edi204Created = 'Y'
								END
								ELSE
								BEGIN
										IF @origin_rail <> 'Y' OR @dest_rail <> 'Y' OR @new_car_type1 <> 'RAL'
										BEGIN
												EXEC create_outbound204 @lgh_number, @new_lgh_carrier, 'ADD'
												SELECT @edi204Created = 'Y'
										END   
								END
						END
				END
		END

		IF @old_lgh_204validate = 0 AND @new_lgh_204validate = 1 AND @old_lgh_carrier = @new_lgh_carrier AND @new_lgh_carrier <> 'UNKNOWN'
		BEGIN
				IF @new_car_204flag = 1 AND @new_lgh_204validate = 1 AND @send_204 = 'Y' 
				BEGIN
						EXEC create_outbound204 @lgh_number, @new_lgh_carrier, 'ADD'
				END
		END

		FETCH NEXT FROM EDI204Cursor
				INTO @lgh_number,
						 @new_lgh_carrier,
						 @old_lgh_carrier,
						 @new_lgh_tradingpartner,
						 @new_car_204flag,
						 @new_car_type1,
						 @new_car_204update,
						 @old_car_204flag,
						 @old_car_type1,
						 @old_car_204update,
						 @new_lgh_204validate,
						 @old_lgh_204validate,
						 @new_lgh_outstatus,
						 @origin_rail,
						 @dest_rail,
						 @new_trailer,
						 @old_trailer,
						 @new_lgh_204status
END
CLOSE EDI204Cursor

DEALLOCATE EDI204Cursor
GO
GRANT EXECUTE ON  [dbo].[lgh_con_tr_EDI204_sp] TO [public]
GO
