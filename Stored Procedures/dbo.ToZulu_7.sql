SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ToZulu_7]( @LocalDate datetime, @BaseDateTZ int, @DSTCode int, @BaseDateTZAddlMins int, @DestDate datetime out)
as
BEGIN
    -- @BaseDate: datetime to convert
    -- @BaseDateTZ: base hours difference of that time from GST.  US EST is 5, US PST is 8, European CET is -1, Chinese is -8
    -- @DSTCode: A code for which rule to apply if Summer Time (DST) applies, -1 if it does not.
    --     See DSTStarts for list of Codes.
    -- @BaseDateTZAddlMins: Any additional minutes offset for the specific TimeZone from 
    --     the hours specified by the TZ.  NewFoundland Standard Time is 3:30 behind GST, 
    --     so their @BaseDateTZ is 3, and their @BaseDateTZAddlMins is 30.
    declare @WorkDate datetime, @DSTCheckLocal char(1), @IsInDST char(1)
    SELECT @WorkDate = @LocalDate, @DSTCheckLocal = 'Y'
    IF (@BaseDateTZ is null) OR (@LocalDate IS NULL)
		begin
        select @DestDate = @LocalDate
        RETURN 
		end
    SELECT @DSTCode = ISNULL(@DSTCode, 0)
    IF @DSTCode >= 0
        BEGIN
        exec dbo.DSTSwitchBasedOnLocalTime_7 @DSTCode, @DSTCheckLocal out
        IF @DSTCheckLocal = 'Y'
            begin
			exec dbo.InDST_7 @WorkDate, @DSTCode, @IsInDST out
            IF @IsInDST = 'Y'
                SELECT @WorkDate = DATEADD(hh, -1, @WorkDate)
			end
        END
    SELECT @WorkDate = DATEADD(hh, @BaseDateTZ, @WorkDate)
    SELECT @WorkDate = DATEADD(mi, ISNULL(@BaseDateTZAddlMins, 0), @WorkDate)
    IF @DSTCheckLocal = 'N'
        begin
		exec dbo.InDST_7 @WorkDate, @DSTCode, @IsInDST out
        IF @IsInDST = 'Y'
            SELECT @WorkDate = DATEADD(hh, -1, @WorkDate)
		end
	select @DestDate = @WorkDate
    RETURN 
END
GO
GRANT EXECUTE ON  [dbo].[ToZulu_7] TO [public]
GO
