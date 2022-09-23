SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[LegPTAUpdate_sp] (
	@curLeg AS INT
	,@curTrc AS VARCHAR(8)
	,@ptaDate AS DATETIME
	,@utilCode AS VARCHAR(6)
	,@ptaType AS CHAR(1)
	)
AS
SET NOCOUNT ON
SET @ptaType = ISNULL(@ptaType, 'S')
SET @ptaDate = ISNULL(@ptaDate, '19500101')

DECLARE @requestedPtaType AS CHAR(1)
SELECT @requestedPtaType = @ptaType
DECLARE @PreProcessedtable TABLE (
	curLeg INT
	,ptaType CHAR(1)
	,utilCode VARCHAR(6)
	,newPTA DATETIME
	,calculatedMax DATETIME
	,curTrc VARCHAR(8)
	,today DATETIME
	,approved TINYINT
	,approvedBy VARCHAR(128)
	,approvedOn DATETIME
	,Dodataupdate BIT
	,outStatus VARCHAR(4)
	,existingLegPTA INT
	,messagedesc VARCHAR(500)
	,instructions VARCHAR(500)
	,pta_hard_max datetime
	,requested_date DATETIME
	,requested_user varchar(128)
	);

INSERT INTO @PreProcessedtable
EXEC dbo.LegPTAUpdate_sp_Preprocess @curLeg
	,@curTrc
	,@ptaDate
	,@utilCode
	,@ptaType

DECLARE @newPTA DATETIME
	,@existingLegPTA INT
	,@calculatedMax DATETIME
	,@today DATETIME
	,@approved TINYINT
	,@approvedBy VARCHAR(128)
	,@approvedOn DATETIME
	,@outStatus VARCHAR(4)
	,@Dodataupdate BIT
	,@messagedesc VARCHAR(500)
	,@instructions VARCHAR(500)
	,@pta_hard_max datetime 
	,@requested_date DATETIME
	,@requested_user varchar(128)

SELECT @curLeg = curLeg
	,@ptaType = ptaType
	,@utilCode = utilCode
	,@newPTA = newPTA
	,@calculatedMax = calculatedMax
	,@curTrc = curTrc
	,@today = today
	,@approved = approved
	,@approvedBy = approvedBy
	,@approvedOn = approvedOn
	,@Dodataupdate = Dodataupdate
	,@outStatus = outStatus
	,@existingLegPTA = existingLegPTA
	,@messagedesc = messagedesc
	,@instructions = instructions
	,@pta_hard_max = pta_hard_max
	,@requested_date = requested_date
	,@requested_user = requested_user
FROM @PreProcessedtable

--IF @ptaType = 'H' AND @ptaDate > @newPTA AND @approved = 0
--BEGIN
--	SET	@newPTA = @PTADate
--END

-- REMOVE_RECORD_AND_RECALCULATE_PTA_FOR_PREVIOUS_TRACTOR
if (@instructions like '%REMOVE_RECORD_AND_RECALCULATE_PTA_FOR_PREVIOUS_TRACTOR%')
begin
	-- Find the existing / previous tractor for this leg
	declare @tractor varchar(8)
	select @tractor = trc_number from legpta where lgh_number = @curLeg

	-- Remove the PTA record for this leg
	delete legpta where lgh_number = @curLeg

	declare @otherLeg int
	select @otherLeg = lgh_number from legpta where trc_number = @tractor

	-- Update all of the existing soft PTA records for that tractor
	exec LegPTAUpdate_sp @otherLeg, @tractor, null, null, null
end

IF (@Dodataupdate=1)
BEGIN

	IF @requestedPtaType = 'S' AND ((SELECT MAX(legpta.pta_date) from legpta where legpta.trc_number = @curTrc) < @newPTA)
	BEGIN
		SET @ptaType = 'S'
		SET @utilCode = (SELECT ISNULL(gi_string2, 'RE') FROM generalinfo where gi_name = 'SoftPTATime')
	END
		
	IF ISNULL(@newPTA, '19500101') > '19500101'
	BEGIN
		IF @existingLegPTA = 0
		BEGIN
			INSERT INTO legpta (
				lgh_number
				,pta_type
				,util_code
				,pta_date
				,pta_date_calculated
				,trc_number
				,update_date
				,update_user
				,create_date
				,create_user
				,pta_approved
				,pta_approved_by
				,pta_approved_date
				,pta_hard_max
				,requested_date
				,requested_user
				)
			VALUES (
				@curLeg
				,@ptaType
				,@utilCode
				,@newPTA
				,@calculatedMax
				,@curTrc
				,@today
				,SUSER_NAME()
				,@today
				,SUSER_NAME()
				,@approved
				,@approvedBy
				,@approvedOn
				,@pta_hard_max
				,@requested_date
				,@requested_user
				)

			SELECT @existingLegPTA = lpa_id
			FROM legpta
			WHERE lgh_number = @curLeg
		END
		ELSE
			UPDATE legpta
			SET pta_type = @ptaType
				,util_code = @utilCode
				,pta_date = @newPTA
				,pta_date_calculated = @calculatedMax
				,trc_number = @curTrc
				,update_date = @today
				,update_user = SUSER_NAME()
				,pta_approved = @approved
				,pta_approved_by = @approvedBy
				,pta_approved_date = @approvedOn
				,pta_denied = 0
				,pta_denied_date = '19500101'
				,pta_denied_by = ''
				,pta_cancelled = (
					CASE 
						WHEN @calculatedMax < GetDate()
							OR @outStatus = 'CMP'
							THEN 1
						ELSE 0
						END
					)
				,pta_hard_max = @pta_hard_max
				,requested_date = @requested_date
				,requested_user = @requested_user
			WHERE lgh_number = @curLeg

		SELECT lgh_number
		INTO #temp
		FROM legheader_active
		WHERE lgh_number <> @curLeg
			AND lgh_tractor = @curTrc
			AND lgh_outstatus <> 'CMP'

		UPDATE legpta
		SET pta_type = src.pta_type
			,util_code = src.util_code
			,pta_date = src.pta_date
			,pta_date_calculated = src.pta_date_calculated
			,update_date = src.update_date
			,update_user = src.update_user
			,pta_approved = src.pta_approved
			,pta_approved_by = src.pta_approved_by
			,pta_approved_date = src.pta_approved_date
			,pta_denied = src.pta_denied
			,pta_denied_date = src.pta_denied_date
			,pta_denied_by = src.pta_denied_by
			,pta_cancelled = src.pta_cancelled
			,pta_hard_max = src.pta_hard_max
		FROM legpta src
			,legpta
		INNER JOIN #temp ON (legpta.lgh_number = #temp.lgh_number)
		WHERE src.lgh_number = @curLeg
			AND @outStatus <> 'CMP'
	END

	-- store the PTA on the tractor profile in the trc_pta_date (was using trc_avl_date) field
	UPDATE tractorprofile
	SET trc_pta_date = (
			CASE 
				WHEN @newPTA > '20491231'
					THEN trc_pta_date
				ELSE @newPTA
				END
			)
	WHERE trc_number = @curTrc

	RETURN 1
END
ELSE
BEGIN
	RETURN 0
END
GO
GRANT EXECUTE ON  [dbo].[LegPTAUpdate_sp] TO [public]
GO
GRANT REFERENCES ON  [dbo].[LegPTAUpdate_sp] TO [public]
GO
