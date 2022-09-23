SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_Add_Reason_Late] 	@sStopNumber varchar(12),
									   		@sReasonLateCode varchar(6),
									   		@sReasonLateDesc varchar(255),
									   		@sReasonLateType varchar(3),
									   		@sMinutesLate varchar(12),
									   		@sFlags varchar(12)
AS

SET NOCOUNT ON 

--Flags
-- 1 - Update existing Reason Late_Code

DECLARE @lFlags int, @lStopNumber int, @lMinutesLate int, @rltID int, @NextSeq int, @lMinutes int, @lCurMinutes int

SET @lFlags = CONVERT(int, ISNULL(@sFlags, 0))

if ISNUMERIC(@sStopNumber) = 0
	BEGIN
		RAISERROR('Reason Late: Stop number must be numeric: %s', 16, 1, @sStopNumber)
		RETURN
	END
else
	BEGIN
		SET @lStopNumber = CONVERT(int, @sStopNumber)
		IF @lStopNumber = 0 
			BEGIN
				RAISERROR('Reason Late: Stop number must be specified', 16, 1)
				RETURN
			END
	END

IF @sReasonLateType <> 'DEP' AND @sReasonLateType <> 'ARV'
	BEGIN
		RAISERROR('Reason Late: Type must be ARV or DEP: %s', 16, 1, @sReasonLateType)
		RETURN
	END

if ISNUMERIC(@sMinutesLate) = 1
	BEGIN
		SET @lMinutesLate = CONVERT(int, @sMinutesLate)

		if (@lMinutesLate = 0)	-- Try and figure out how late we really are 
			BEGIN
				if (@sReasonLateType = 'DEP')
					SELECT @lMinutes = DATEDIFF(n, stp_schdtlatest, stp_departuredate) 
					FROM stops (NOLOCK)
					WHERE stp_number = @lStopNumber
				else
					SELECT @lMinutes = DATEDIFF(n, stp_schdtearliest, stp_arrivaldate) 
					FROM stops (NOLOCK)
					WHERE stp_number = @lStopNumber

				-- Find current minutes logged for late/early for this stop
				SELECT @lCurMinutes = SUM(rlt_reasonlate_min) 
				FROM ReasonLate (NOLOCK)
				WHERE rlt_arv_dep = @sReasonLateType AND rlt_stp_number = @sStopNumber 

				if (@lMinutes > @lCurMinutes)
					SET @lMinutesLate = @lMinutes - @lCurMinutes
			END
	END
else
	BEGIN
		RAISERROR('Reason Late: Minutes Late must be numeric: %s', 16, 1, @sMinutesLate)
		RETURN
	END

IF (@lFlags & 1) = 1
	BEGIN 
		SELECT @rltID = rlt_id 
		FROM ReasonLate (NOLOCK)
		WHERE rlt_arv_dep = @sReasonLateType AND rlt_stp_number = @sStopNumber AND rlt_reasonlate = @sReasonLateCode
	END

if ISNULL(@rltID, 0) = 0
	BEGIN
		SELECT @NextSeq = ISNULL(MAX(rlt_arv_dep_seq), 0) + 1 
		FROM ReasonLate (NOLOCK)
		WHERE rlt_arv_dep = @sReasonLateType AND rlt_stp_number = @sStopNumber
		INSERT INTO ReasonLate (rlt_stp_number,  		--1
								rlt_arv_dep, 			--2
								rlt_arv_dep_seq, 		--3
								rlt_reasonlate, 		--4
								rlt_reasonlate_text, 	--5
								rlt_reasonlate_min) 	--6
						VALUES (@lStopNumber,   		--1
								@sReasonLateType, 		--2
								@NextSeq, 				--3
								@sReasonLateCode,		--4
								@sReasonLateDesc,		--5
								@lMinutesLate)			--6

		IF (@NextSeq = 1)	-- This is the first entry for this stop - need to update stop table
			BEGIN
				IF (@sReasonLateType = 'ARV')
					UPDATE stops 
						SET stp_reasonlate = @sReasonLateCode,
							stp_reasonlate_text = @sReasonLateDesc,
							stp_reasonlate_min = @lMinutesLate
						WHERE stp_number = @lStopNumber	
				ELSE
					UPDATE stops 
						SET stp_reasonlate_depart = @sReasonLateCode,
							stp_reasonlate_depart_text = @sReasonLateDesc,
							stp_reasonlate_depart_min = @lMinutesLate
						WHERE stp_number = @lStopNumber	
			END
	END
else
	BEGIN
		UPDATE ReasonLate 
			SET rlt_reasonlate = @sReasonLateCode,
				rlt_reasonlate_text = @sReasonLateDesc,
				rlt_reasonlate_min = @lMinutesLate
			WHERE rlt_id = @rltID

	END

GO
GRANT EXECUTE ON  [dbo].[tmail_Add_Reason_Late] TO [public]
GO
