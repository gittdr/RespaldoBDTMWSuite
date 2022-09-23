SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tm_transfer_checkcall_xfc2]  @p_number_of_records int = 0, @po_records_togo int OUTPUT

AS
/* 06/13/00 MZ: Transfer checkcalls from tblLatLongs to tblCheckcallXfc
        Note: This is only used for clients that have split databases
          for PowerSuite and TotalMail                      
   09/28/00 MZ: Added tblRS lookup for checkcall deletion and checking of bit 1
        when pulling checkcalls to transfer     
   03/05/01 MZ: Added error logging to tblCheckcallError  
   05/25/01 DAG: Converting for international date format 
   08/27/01 DAG: Change state lengths to 6 for International (although not used for international, it should be consistent).
   12/10/01 DWG: Added Odometer Reading field
   01/24/06 TA: Add eight new fields.
   02/11/09 VMS - PTS45517 - Modify tblCheckcallXfc logic for new AssociatedMsgSN field.
   03/17/09 MZ: PTS45807 - Add support for ExtraData01-20 fields.
 
 * 03/06/2014 **** PTS74678 * HMA * Placing an input and an output PARAMETERs on this proc to dictate how many records in tblLatLongs to process. ZERO indicates process them ALL.   
 *            output param will indicate how many records left
 * 03/11/2014 PTS 74678 HMA - tm_transfer_checkcall_xfc is recreated to call THIS proc tm_transfer_checkcall_xfc2 with a parameter of 0
 
*/

SET NOCOUNT ON

--PRINT N'The parameters value is ' + CAST(@p_number_of_records as nvarchar(5))

DECLARE @CityName varchar(16),
            @Comment varchar(255),
            @DateAndTime datetime, 
            @Direction varchar(3),
            @ErrorInfo varchar(255),
            @LargeCityDirection varchar(3),
            @LargeCityMiles int,
            @LargeCityName varchar(16), 
            @LargeCityState varchar(6),
            @LargeCityZip varchar(9), 
            @LargeComment varchar(255),
            @Lat float,
            @Long float,
            @MctSN int,
            @Miles real,
            @SN int,
            @State varchar(6),
            @Truck varchar(20),
            @TruckSN int,
            @LinkSN int,
            @LinkType int,
            @VehicleIgnition char(1),
            @Zip varchar(9),
            @sT_1 varchar(200),    --Translation Strings
            @sT_2 varchar(20),
            @sT_dir varchar(10),
            @UpdateDisp int,
            @DeleteCkc varchar(5),    -- Should we delete the checkcall after transferring?
            @LatLongRemark varchar(256), --Added for TrailerTRACS event codes. Remark may have Check Call Event Abbr in the beging. Formated: [ABBR]
            @OdometerReading int,
            @TripStatus int,
            @odometer2 int,
            @speed int,
            @speed2 int,                 
            @heading float, 
            @gps_type int,                          
            @gps_miles float,          
            @fuel_meter float,
            @idle_meter int,
            @ErrsOccurred int,
            @Successfuls int,
            @MsgText varchar(4000),

            --PTS #35670 Start
            @SQLString nvarchar(1000),
            @SQLPara nvarchar(500),
            @TblRs_UsedLstTrc varchar(10),
            @TblRs_SPName varchar(256),
            --PTS #35670 End

	--PTS #38687 Start
            @ChkCallTZ varchar(10),	
            @ChkCallMinAdj varchar(10),
            @ChkCallDSTCd varchar(10),

            @SysTZ varchar(10),	
            @SysMinAdj varchar(10),
            @SysDSTCd varchar(10),
	--PTS #38687 End
			@AssociatedMsgSN	int,					-- PTS 45517 - VMS
			@ExtraData01 varchar(255), @ExtraData02 varchar(255), @ExtraData03 varchar(255), @ExtraData04 varchar(255), @ExtraData05 varchar(255),
			@ExtraData06 varchar(255), @ExtraData07 varchar(255), @ExtraData08 varchar(255), @ExtraData09 varchar(255), @ExtraData10 varchar(255), 
			@ExtraData11 varchar(255), @ExtraData12 varchar(255), @ExtraData13 varchar(255), @ExtraData14 varchar(255), @ExtraData15 varchar(255),
			@ExtraData16 varchar(255), @ExtraData17 varchar(255), @ExtraData18 varchar(255), @ExtraData19 varchar(255), @ExtraData20 varchar(255),
			
			@current_count int --pts #74678 to compare against @p_number_of_records
			
--PTS #35670 Start
SELECT @TblRs_UsedLstTrc = isnull(Text,'') 
	FROM TblRS (NOLOCK)
	WHERE Keycode ='UseLastTrc'
IF @TblRs_UsedLstTrc = '2' 
	BEGIN
		SELECT @TblRs_SPName = isnull(Text,'') 
		from TblRS (NOLOCK)
		where Keycode ='ckcSPName'
	END
--PTS #35670 End

--PTS #38687 Start
Select @ChkCallTZ = isnull(Text, '') 
from TblRs (NOLOCK)
where Keycode = 'CkCalTZ'

if isnumeric(@ChkCallTZ) = 1 
	if convert(int, @ChkCallTZ) <> 0 
	Begin
		Select @ChkCallMinAdj = isnull(Text, '') from TblRs where Keycode = 'CkCalMin'
		Select @ChkCallDSTCd = isnull(Text, '') from TblRs where Keycode = 'CkCalDSTCd'

		Select @SysTZ = isnull(Text, '') from TblRs where Keycode = 'SysTZ'
		Select @SysDSTCd = isnull(Text, '') from TblRs where Keycode = 'SysDSTCode'
		Select @SysMinAdj = isnull(Text, '') from TblRs where Keycode = 'SysTZMins'
	end
--PTS #38687 End
	
-- Check if we should delete the checkcall after transferring
SET @DeleteCkc = 'True'
SELECT @DeleteCkc = ISNULL(text, 'True')  -- We'll default to true, delete it
FROM tblRS 
WHERE keyCode = 'CkcDelete'

SELECT @ErrorInfo = '', @ErrsOccurred = 0, @Successfuls = 0, @current_count = 0 -- Initialize

-- Pull min(sn) for checkcalls with bit 1 set (transfer to dispatch)

--  extra AND clause is to ensure that the correct index is used.

SELECT @SN = ISNULL(MIN(SN), -1)
  FROM dbo.tblLatLongs (NOLOCK)
  WHERE    UpdateDisp & 1 = 1 
    AND UpdateDisp > 0
    AND DateAndTime = (SELECT ISNULL(MIN(DateAndTime),'19500101')
												FROM dbo.tblLatLongs
											    WHERE UpdateDisp & 1 = 1   
														AND UpdateDisp > 0)
														
-- pts 74678 added AND + 2nd clause - oh and this loop actually processes @p_number_of_records + 1 records 
WHILE (@SN <> -1) AND (@p_number_of_records >= @current_count)
	BEGIN
		SELECT  @DateAndTime = ISNULL(ll.DateAndTime,'19500101'),
			@TruckSN = ISNULL(cu.Truck,-1),
			@LinkSN = ISNULL(cu.LinkedObjSN, -1),
			@LinkType = ISNULL(cu.LinkedAddrType, 4),
			@Lat = ISNULL(ll.Lat,0),
			@Long = ISNULL(ll.Long,0),
			@Miles = ISNULL(ll.Miles,0),
			@Direction = ISNULL(ll.Direction,''),
			@Zip = ISNULL(ll.Zip,''),
			@CityName = ISNULL(ll.CityName,''),
			@State = ISNULL(ll.State,''),
			@LargeCityName = ISNULL(ll.NearestLargeCityName,''),
			@LargeCityState = ISNULL(ll.NearestLargeCityState,''),
			@LargeCityZip = ISNULL(ll.NearestLargeCityZip,''),
			@LargeCityDirection = ISNULL(ll.NearestLargeCityDirection,''),
			@LargeCityMiles = ISNULL(ll.NearestLargeCityMiles,0),
			@VehicleIgnition = ISNULL(ll.VehicleIgnition,'X'),
			@MctSN = ISNULL(ll.Unit, -1),
			@UpdateDisp = ISNULL(ll.UpdateDisp, 1),
			@LatLongRemark = ISNULL(ll.Remark, ''),
			@OdometerReading = ISNULL(ll.Odometer, 0),
			@TripStatus = ISNULL(ll.TripStatus,0),
			@odometer2 = ll.odometer2,
			@speed = ll.speed,
			@speed2 = ll.speed2,
			@heading = ll.heading,
			@gps_type = ll.gps_type,
			@gps_miles = ll.gps_miles,
			@fuel_meter = ll.fuel_meter,
			@idle_meter = ll.idle_meter,
			@AssociatedMsgSN = ll.AssociatedMsgSN,		-- PTS 45517 - VMS
			@ExtraData01 = ISNULL(ll.ExtraData01, ''),
			@ExtraData02 = ISNULL(ll.ExtraData02, ''),
			@ExtraData03 = ISNULL(ll.ExtraData03, ''),
			@ExtraData04 = ISNULL(ll.ExtraData04, ''),
			@ExtraData05 = ISNULL(ll.ExtraData05, ''),
			@ExtraData06 = ISNULL(ll.ExtraData06, ''),
			@ExtraData07 = ISNULL(ll.ExtraData07, ''),
			@ExtraData08 = ISNULL(ll.ExtraData08, ''),
			@ExtraData09 = ISNULL(ll.ExtraData09, ''),
			@ExtraData10 = ISNULL(ll.ExtraData10, ''),
			@ExtraData11 = ISNULL(ll.ExtraData11, ''),
			@ExtraData12 = ISNULL(ll.ExtraData12, ''),
			@ExtraData13 = ISNULL(ll.ExtraData13, ''),
			@ExtraData14 = ISNULL(ll.ExtraData14, ''),
			@ExtraData15 = ISNULL(ll.ExtraData15, ''),
			@ExtraData16 = ISNULL(ll.ExtraData16, ''),
			@ExtraData17 = ISNULL(ll.ExtraData17, ''),
			@ExtraData18 = ISNULL(ll.ExtraData18, ''),
			@ExtraData19 = ISNULL(ll.ExtraData19, ''),
			@ExtraData20 = ISNULL(ll.ExtraData20, '')
		FROM dbo.tblCabUnits cu, dbo.tblLatLongs ll
		WHERE cu.SN = ll.Unit
			AND ll.SN = @SN

		-- Remove bit 1 to signal that we've tried to 
		--  send this checkcall to the dispatch system
		SELECT @UpdateDisp = @UpdateDisp - 1
		IF (ISNULL(@TruckSN, -1) = -1) AND (ISNULL(@LinkType, 4) = 4) SELECT @TruckSN = @LinkSN
		IF (ISNULL(@LinkType, 4) = 5) AND (ISNULL(@LinkSN, -1) <> -1) SELECT @TruckSN = -2

		-- Make sure to not put NULL values into checkcall table.
		IF ISNULL(@TruckSN, -1) <> -1
			BEGIN
				SELECT @Truck = ''

				-- Find the Truck Name
				IF @TblRs_UsedLstTrc = '2' and len(@TblRs_SPName) > 0  --2 = TM Stored Procedure.
					BEGIN
					   --PTS #35670 Start
						set @SQLPara = N'@pUnitId varchar(256), @pTrcID varchar(256) output'
						set @SQLString = N'Exec ' + @TblRs_SPName + ' @pUnitId, @pTrcID output'
						EXECUTE sp_executesql  @SQLString, @SQLPara, @pUnitId = @MctSN,  @pTrcID = @Truck output                      
						set @Truck = isnull(@Truck,'')
					END --PTS #35670 End

				ELSE IF @TruckSN = -2  --Driver
					BEGIN
						SELECT @Truck = 'DRV:' + ISNULL(DispSysDriverID, '') 
						FROM tblDrivers (NOLOCK)
						WHERE SN = @LinkSN
						IF ISNULL(@Truck, 'DRV:') = 'DRV:' SELECT @Truck = ''
					END

				ELSE  --Truck/Trailer
					SELECT @Truck = ISNULL(DispSysTruckID,'')
						FROM dbo.tblTrucks (NOLOCK)
						WHERE SN = @TruckSN

				-- Make sure (again) to not put NULL values into checkcall table.
				IF ISNULL(@Truck, '') = '' 
					SELECT @ErrorInfo = 'Couldn''t locate DispSysTruckID for this TruckSN'
				ELSE IF LEFT(@Truck, 4) = 'TRL:' AND DATALENGTH(@Truck) > 17
					SELECT @ErrorInfo = 'Trailer ID too long: ' + @Truck
				ELSE IF LEFT(@Truck, 4) = 'DRV:' AND DATALENGTH(@Truck) > 12
					SELECT @ErrorInfo = 'Driver ID too long:' + @Truck
				ELSE IF LEFT(@Truck, 4) <> 'TRL:' AND LEFT(@Truck, 4) <> 'DRV:' AND DATALENGTH(@Truck) > 8 
					SELECT @ErrorInfo = 'Truck ID too long:' + @Truck
				ELSE
					BEGIN
						IF (SELECT CONVERT(int, ISNULL(MIN(text),'0')) 
						FROM tblRS (NOLOCK)
						WHERE keyCode = 'MCommLocs') <> 0 AND ISNULL(@LatLongRemark, '') <> ''
							BEGIN
								SELECT @Comment = @LatLongRemark
							END
						ELSE
							BEGIN
								-- Construct the Nearest city string
								IF (ROUND(@Miles, 0) = 0 OR @Direction = '@')
									SET @Comment = '@ ' + @CityName + ', ' + @State
								ELSE IF @Direction > ''
									BEGIN
										SET @sT_1 = '~1 miles ~2 of ~3, ~4'  -- Translate this string as is
										EXEC dbo.tm_t_sp @sT_1 out, 1, ''                

										SET @sT_dir = @Direction    -- Translate the direction
										EXEC dbo.tm_t_sp @sT_dir out, 1, ''                

										SET @sT_2 = CONVERT(varchar(8), ROUND(@Miles, 0))    -- Convert the miles to a string                 
										EXEC dbo.tm_sprint @sT_1 out, @sT_2, @sT_dir, @CityName, @State, '', '', '', '', '', ''

										SET @Comment = @sT_1
									END
								ELSE
									BEGIN
										SET @sT_1 = '~1 miles from ~2, ~3'    -- Translate this string as is
										EXEC dbo.tm_t_sp @sT_1 out, 1, ''                 

										SET @sT_2 = CONVERT(varchar(8), ROUND(@Miles, 0))    -- Convert the miles to a string                
										EXEC dbo.tm_sprint @sT_1 out, @sT_2, @CityName, @State, '', '', '', '', '', '' ,''

										SET @Comment = @sT_1                    
									END             

								--DWG: Get Check call Abbr and remark from LatLongRemark
								If Left(@LatLongRemark, 1) = '[' 
									If CHARINDEX(']', @LatLongRemark) > 0 And CHARINDEX(']', @LatLongRemark) < 9
										SELECT @Comment = @LatLongRemark + @Comment
							END           

						-- Construct the nearest large city string
						IF @LargeCityName = ''
							SET @LargeComment = ''
						ELSE
							IF @LargeCityMiles = 0
								SET @LargeComment = '@ ' + @LargeCityName + ', ' + @LargeCityState
							ELSE
								BEGIN
									SET @sT_1 = '~1 miles ~2 of ~3, ~4'    -- Translate this string as is
									EXEC dbo.tm_t_sp @sT_1 out, 1, ''    

									SET @sT_dir = @LargeCityDirection    -- Translate the direction
									EXEC dbo.tm_t_sp @sT_dir out, 1, ''
				    
									SET @sT_2 = CONVERT(varchar(8), @LargeCityMiles)    -- Convert the miles to a string
									EXEC dbo.tm_sprint @sT_1 out, @sT_2, @sT_dir, @LargeCityName, @LargeCityState, '', '', '', '', '', ''

									SET @LargeComment = @sT_1                
								END
						
						--PTS #38687 Start						
						if CONVERT(int, @ChkCallTZ) <> 0 
						Begin
							set @DateAndTime = dbo.ChangeTZ(@DateAndTime, @SysTZ, @SysDSTCd, @SysMinAdj, @ChkCallTZ, @ChkCallDSTCd, @ChkCallMinAdj)
						end
						--PTS #38687 End
				
						-- Insert the record into tblCheckcallXfc	
						INSERT INTO dbo.tblCheckcallXfc (Tractor,
							DateAndTime,
							Lat,
							Long,
							Miles,        --5
							
							Direction,    
							CityName,
							State,
							Zip,
							Comments,    --10
							
							LargeComments,
							VehicleIgnition,
							Odometer,
							TripStatus,
							odometer2,	--15
					
							speed,
							speed2,		
							heading, 	
							gps_type,			
							gps_miles,		--20
					
							fuel_meter,
							idle_meter,
							AssociatedMsgSN,		-- PTS 45517 - VMS
							ckc_ExtraData01,
							ckc_ExtraData02,	--25

							ckc_ExtraData03,
							ckc_ExtraData04,
							ckc_ExtraData05,
							ckc_ExtraData06,
							ckc_ExtraData07,	--30

							ckc_ExtraData08,
							ckc_ExtraData09,
							ckc_ExtraData10,
							ckc_ExtraData11,
							ckc_ExtraData12,	--35

							ckc_ExtraData13,
							ckc_ExtraData14,
							ckc_ExtraData15,
							ckc_ExtraData16,
							ckc_ExtraData17,	--40

							ckc_ExtraData18,
							ckc_ExtraData19,
							ckc_ExtraData20)	--43
						VALUES (@Truck,
							@DateAndTime,
							@Lat,
							@Long,
							@Miles,            --5
			    
							@Direction,
							@CityName,
							@State,
							@Zip,
							@Comment,        --10

							@LargeComment,
							@VehicleIgnition,
							@OdometerReading,
							@TripStatus,
							@odometer2,	--15
					
							@speed,
							@speed2,		
							@heading, 	
							@gps_type,			
							@gps_miles,	--20
					
							@fuel_meter,
							@idle_meter,
							@AssociatedMsgSN,		-- PTS 45517 - VMS
							@ExtraData01,
							@ExtraData02,	--25

							@ExtraData03,
							@ExtraData04,
							@ExtraData05,
							@ExtraData06,
							@ExtraData07,	--30

							@ExtraData08,
							@ExtraData09,
							@ExtraData10,
							@ExtraData11,
							@ExtraData12,	--35

							@ExtraData13,
							@ExtraData14,
							@ExtraData15,
							@ExtraData16,
							@ExtraData17,	--40

							@ExtraData18,
							@ExtraData19,
							@ExtraData20)	--43
						SELECT @Successfuls = @Successfuls  + 1
					END    -- @Truck <> ''

			END  -- @TruckSN <> -1

		ELSE
			SELECT @ErrorInfo = 'Couldn''t locate TruckSN for this MCT'

		-- Log error if there was one
		IF (@ErrorInfo <> '') 
			BEGIN        
				-- There has been an error, so insert record into tblCheckCallError table
				INSERT INTO dbo.tblCheckCallError (
						DateAndTime,
						DateInserted,
						TruckSN,
						Truck,
						MctSN,            --5

						Driver,            
						lgh_date,
						lgh_number,
						Lat,
						Long,            --10

						City,
						State,
						Zip,
						Direction,
						Miles,            --15

						LargeCity,
						LargeState,
						LargeZip,
						LargeDirection,
						LargeMiles,        --20

						VehicleIgnition,
						ErrorNote,        
						Odometer,
						odometer2,
						speed,		--25
				
						speed2,		
						heading, 	
						gps_type,			
						gps_miles,	
						fuel_meter,	--30
				
						idle_meter,
						AssociatedMsgSN,		-- PTS 45517 - VMS
						ckc_ExtraData01,
						ckc_ExtraData02,	--35

						ckc_ExtraData03,
						ckc_ExtraData04,
						ckc_ExtraData05,
						ckc_ExtraData06,
						ckc_ExtraData07,	--40

						ckc_ExtraData08,
						ckc_ExtraData09,
						ckc_ExtraData10,
						ckc_ExtraData11,
						ckc_ExtraData12,	--45

						ckc_ExtraData13,
						ckc_ExtraData14,
						ckc_ExtraData15,
						ckc_ExtraData16,
						ckc_ExtraData17,	--50

						ckc_ExtraData18,
						ckc_ExtraData19,
						ckc_ExtraData20)	--53		        
				VALUES (@DateAndTime,
						GETDATE(),
						@TruckSN,
						@Truck,
						@MctSN,            --5
						
						NULL,
						NULL,
						NULL,
						@Lat,
						@Long,            --10
						
						@CityName,            
						@State,
						@Zip,
						@Direction,
						@Miles,            --15
						
						@LargeCityName,
						@LargeCityState,
						@LargeCityZip,
						@LargeCityDirection,
						@LargeCityMiles,    --20
						
						@VehicleIgnition,
						@ErrorInfo,       
						@OdometerReading,
						@odometer2,	
						@speed,		--25
				
						@speed2,		
						@heading, 	
						@gps_type,			
						@gps_miles,
						@fuel_meter,	--30
				
						@idle_meter,
						@AssociatedMsgSN,		-- PTS 45517 - VMS
						@ExtraData01,
						@ExtraData02,	--35

						@ExtraData03,
						@ExtraData04,
						@ExtraData05,
						@ExtraData06,
						@ExtraData07,	--40

						@ExtraData08,
						@ExtraData09,
						@ExtraData10,
						@ExtraData11,
						@ExtraData12,	--45

						@ExtraData13,
						@ExtraData14,
						@ExtraData15,
						@ExtraData16,
						@ExtraData17,	--50

						@ExtraData18,
						@ExtraData19,
						@ExtraData20)	--53
				SELECT @ErrorInfo = '', @ErrsOccurred = @ErrsOccurred + 1        -- Re-initialize for next loop
			END    
		
		-- Delete the position report from tblLatLongs
		IF (@UpdateDisp = 0 AND @DeleteCkc = 'True')
			DELETE dbo.tblLatLongs
				WHERE SN = @SN
		ELSE
			UPDATE dbo.tblLatLongs
				SET UpdateDisp = @UpdateDisp
				WHERE SN = @SN

		-- Get next position report
		SELECT @SN = ISNULL(MIN(SN), -1) 
			FROM dbo.tblLatLongs (NOLOCK)
			WHERE    UpdateDisp & 1 = 1
				AND UpdateDisp > 0
				AND DateAndTime = (SELECT ISNULL(MIN(DateAndTime),'19500101')
									FROM dbo.tblLatLongs (NOLOCK)
									WHERE UpdateDisp & 1 = 1
										AND UpdateDisp > 0)
										
	IF (@p_number_of_records > 0) --if we dont have the default parameter then increment our counter
		SET @current_count	= @current_count + 1
		
	END --While

-- Send an Admin message
IF @ErrsOccurred > 0
	BEGIN
		SELECT @MsgText = CONVERT(varchar(20), @ErrsOccurred) + ' Position Reports (of ' + CONVERT(varchar(20), 
		@ErrsOccurred + @Successfuls) + ') failed to transfer to TMWSuite interface.  See TotalMail''s tblCheckCallError for details.'
		EXEC dbo.tm_AdminMessage 'Admin', 1, 'Position Report transfer problems', @MsgText
	END

Select @po_records_togo = (CASE @SN WHEN -1 THEN 0 ELSE 1 END)

GO
GRANT EXECUTE ON  [dbo].[tm_transfer_checkcall_xfc2] TO [public]
GO
