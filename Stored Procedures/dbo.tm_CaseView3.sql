SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_CaseView3] @sInputValue varchar(255),
								 @Min1 varchar(255),
								 @Max1 varchar(255),
								 @Result1 varchar(255),
								 @Min2 varchar(255),
								 @Max2 varchar(255),
								 @Result2 varchar(255),
								 @Min3 varchar(255),
								 @Max3 varchar(255),
								 @Result3 varchar(255),
								 @Min4 varchar(255),
								 @Max4 varchar(255),
								 @Result4 varchar(255),
								 @Min5 varchar(255),
								 @Max5 varchar(255),
								 @Result5 varchar(255),
								 @Min6 varchar(255),
								 @Max6 varchar(255),
								 @Result6 varchar(255),
								 @Min7 varchar(255),
								 @Max7 varchar(255),
								 @Result7 varchar(255),
								 @Min8 varchar(255),
								 @Max8 varchar(255),
								 @Result8 varchar(255),
								 @Min9 varchar(255),
								 @Max9 varchar(255),
								 @Result9 varchar(255),
								 @Min10 varchar(255),
								 @Max10 varchar(255),
								 @Result10 varchar(255),
								 @CompareStyle varchar(10),
								 @Flags varchar(12),
								 @ElseResult varchar(255)

AS
-- 09/16/2004 DG Added @CompareStyle (PTS 26345 created for this 1/4/2005 for checkin)
-- 06/31/03 MZ Created tm_CaseView (original)
	
	-- Compare styles defined:
	--	 1 = INSTR type comparison of strings. Only @Min fields used - not @Max fields.

	DECLARE @InputValue int
	DECLARE @iFlags int

	SET @iFlags=0

	IF ISNUMERIC(@Flags)=1 
	BEGIN
		SET @iFlags = CONVERT(int,@Flags)
	END

	IF ISNULL(@CompareStyle, '') = '1'
	BEGIN
	    IF @sInputValue = '' 
			RAISERROR ('No input value assigned, cannot process Case.',16,1)
			
		IF ISNULL(@Min1,'') <> ''
			IF CHARINDEX(@sInputValue, @Min1, 1) > 0
			BEGIN
				SELECT @Result1 FinalResult
				RETURN 0
			END

		IF ISNULL(@Min2,'') <> ''
			IF CHARINDEX(@sInputValue, @Min2, 1) > 0
			BEGIN
				SELECT @Result2 FinalResult
				RETURN 0
			END

		IF ISNULL(@Min3,'') <> ''
			IF CHARINDEX(@sInputValue, @Min3, 1) > 0
			BEGIN
				SELECT @Result3 FinalResult
				RETURN 0
			END

		IF ISNULL(@Min4,'') <> ''
			IF CHARINDEX(@sInputValue, @Min4, 1) > 0
			BEGIN
				SELECT @Result4 FinalResult
				RETURN 0
			END

		IF ISNULL(@Min5,'') <> ''
			IF CHARINDEX(@sInputValue, @Min5, 1) > 0
			BEGIN
				SELECT @Result5 FinalResult
				RETURN 0
			END

		IF ISNULL(@Min6,'') <> ''
			IF CHARINDEX(@sInputValue, @Min6, 1) > 0
			BEGIN
				SELECT @Result6 FinalResult
				RETURN 0
			END

		IF ISNULL(@Min7,'') <> ''
			IF CHARINDEX(@sInputValue, @Min7, 1) > 0
			BEGIN
				SELECT @Result7 FinalResult
				RETURN 0
			END

		IF ISNULL(@Min8,'') <> ''
			IF CHARINDEX(@sInputValue, @Min8, 1) > 0
			BEGIN
				SELECT @Result8 FinalResult
				RETURN 0
			END

		IF ISNULL(@Min9,'') <> ''
			IF CHARINDEX(@sInputValue, @Min9, 1) > 0
			BEGIN
				SELECT @Result9 FinalResult
				RETURN 0
			END

		IF ISNULL(@Min10,'') <> ''
			IF CHARINDEX(@sInputValue, @Min10, 1) > 0
			BEGIN
				SELECT @Result10 FinalResult
				RETURN 0
			END

		IF (@Flags & 1) = 0
		BEGIN
			RAISERROR ('No match on Case view.',16,1)
			RETURN 1	
		END
		ELSE 
		BEGIN
			SELECT @ElseResult FinalResult
			Return 0
		END


	END
	ELSE
	BEGIN
		IF (ISNULL(CONVERT(int, @sInputValue), 0) = 0)
		  BEGIN
			RAISERROR ('No input value assigned, cannot process Case.',16,1)
			RETURN 1	
		  END
		
		SET @InputValue = CONVERT(int, @sInputValue)
		
		IF (ISNULL(@Min1,'') <> '' AND ISNULL(@Max1,'') <> '')
			IF @InputValue >= CONVERT(int,@Min1) AND @InputValue <= CONVERT(int,@Max1)
			  BEGIN
				SELECT @Result1 FinalResult
				RETURN 0
			  END
		
		IF (ISNULL(@Min2,'') <> '' AND ISNULL(@Max2,'') <> '')
			IF @InputValue >= CONVERT(int,@Min2) AND @InputValue <= CONVERT(int,@Max2)
			  BEGIN
				SELECT @Result2 FinalResult
				RETURN 0
			  END
		
		IF (ISNULL(@Min3,'') <> '' AND ISNULL(@Max3,'') <> '')
			IF @InputValue >= CONVERT(int,@Min3) AND @InputValue <= CONVERT(int,@Max3)
			  BEGIN
				SELECT @Result3 FinalResult
				RETURN 0
			  END
		
		IF (ISNULL(@Min4,'') <> '' AND ISNULL(@Max4,'') <> '')
			IF @InputValue >= CONVERT(int,@Min4) AND @InputValue <= CONVERT(int,@Max4)
			  BEGIN
				SELECT @Result4 FinalResult
				RETURN 0
			  END
		
		IF (ISNULL(@Min5,'') <> '' AND ISNULL(@Max5,'') <> '')
			IF @InputValue >= CONVERT(int,@Min5) AND @InputValue <= CONVERT(int,@Max5)
			  BEGIN
				SELECT @Result5 FinalResult
				RETURN 0
			  END
		
		IF (ISNULL(@Min6,'') <> '' AND ISNULL(@Max6,'') <> '')
			IF @InputValue >= CONVERT(int,@Min6) AND @InputValue <= CONVERT(int,@Max6)
			  BEGIN
				SELECT @Result6 FinalResult
				RETURN 0
			  END
		
		IF (ISNULL(@Min7,'') <> '' AND ISNULL(@Max7,'') <> '')
			IF @InputValue >= CONVERT(int,@Min7) AND @InputValue <= CONVERT(int,@Max7)
			  BEGIN
				SELECT @Result7 FinalResult
				RETURN 0
			  END
		
		IF (ISNULL(@Min8,'') <> '' AND ISNULL(@Max8,'') <> '')
			IF @InputValue >= CONVERT(int,@Min8) AND @InputValue <= CONVERT(int,@Max8)
			  BEGIN
				SELECT @Result8 FinalResult
				RETURN 0
			  END
		
		IF (ISNULL(@Min9,'') <> '' AND ISNULL(@Max9,'') <> '')
			IF @InputValue >= CONVERT(int,@Min9) AND @InputValue <= CONVERT(int,@Max9)
			  BEGIN
				SELECT @Result9 FinalResult
				RETURN 0
			  END
		
		IF (ISNULL(@Min10,'') <> '' AND ISNULL(@Max10,'') <> '')
			IF @InputValue >= CONVERT(int,@Min10) AND @InputValue <= CONVERT(int,@Max10)
			  BEGIN
				SELECT @Result10 FinalResult
				RETURN 0
			  END
				
		IF (@Flags & 1) = 0
		BEGIN
			RAISERROR ('No match on Case view.',16,1)
			RETURN 1	
		END
		ELSE
		BEGIN
			SELECT @ElseResult FinalResult
			Return 0
		END
	END


GO
GRANT EXECUTE ON  [dbo].[tm_CaseView3] TO [public]
GO
