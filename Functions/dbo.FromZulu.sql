SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[FromZulu] (@ZuluDate datetime, @BaseDateTZ int, @DSTCode int, @BaseDateTZAddlMins int)
RETURNS datetime 
    begin
    -- @BaseDate: datetime to convert
    -- @BaseDateTZ: base hours difference of that time from GST.  US EST is 5, US PST is 8, European CET is -1, Chinese is -8
    -- @DSTCode: A code for which rule to apply if Summer Time (DST) applies, -1 if it does not.
    --     See DSTStarts for list of Codes.
    -- @BaseDateTZAddlMins: Any additional minutes offset for the specific TimeZone from 
    --     the hours specified by the TZ.  NewFoundland Standard Time is 3:30 behind GST, 
    --     so their @BaseDateTZ is 3, and their @BaseDateTZAddlMins is 30.
    declare @WorkDate datetime, @DSTCheckLocal char(1), @DSTFlag char(1)
    SELECT @WorkDate = @ZuluDate, @DSTCheckLocal = 'N'
    IF (@BaseDateTZ is null) OR (@ZuluDate IS NULL)
        RETURN @ZuluDate
    SELECT @DSTCode = ISNULL(@DSTCode, 0)
    IF @DSTCode >= 0
        BEGIN
        SELECT @DSTCheckLocal = dbo.DSTSwitchBasedOnLocalTime (@DSTCode)
        IF @DSTCheckLocal = 'N'
            IF dbo.InDST (@WorkDate, @DSTCode) = 'Y'
                SELECT @WorkDate = DATEADD(hh, 1, @WorkDate)
        END
    SELECT @WorkDate = DATEADD(hh, -@BaseDateTZ, @WorkDate)
    SELECT @WorkDate = DATEADD(mi, -ISNULL(@BaseDateTZAddlMins, 0), @WorkDate)
    IF @DSTCheckLocal = 'Y'
        IF dbo.InDST (@WorkDate, @DSTCode) = 'Y'
            SELECT @WorkDate = DATEADD(hh, 1, @WorkDate)
    RETURN @WorkDate
    end
GO
GRANT EXECUTE ON  [dbo].[FromZulu] TO [public]
GO
GRANT REFERENCES ON  [dbo].[FromZulu] TO [public]
GO
