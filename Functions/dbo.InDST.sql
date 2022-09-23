SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create function [dbo].[InDST] (@BaseDate datetime, @DSTCode int)
RETURNS char(1) 
BEGIN
    -- Checks if @BaseDate is in the DST period for the specified DSTCode (see DSTStarts
    --     for a list of defined DSTCodes).  Assumes that @BaseDate has already been
    --     switched to the TimeZone appropriate for the DSTCode (For example, in US it
    --     should be in Local time, while for the EU it should be in WET/WEST.
    DECLARE @DSTStart datetime, @DSTEnd datetime, @YearNumber int
    SELECT @DSTCode = ISNULL(@DSTCode, 0)
    IF @DSTCode = -1
        RETURN 'N'
    SELECT @YearNumber = YEAR(@BaseDate)
    SELECT @DSTStart = dbo.DSTStarts (@YearNumber, @DSTCode), @DSTEnd = dbo.DSTEnds (@YearNumber, @DSTCode)
    IF @DSTStart < @DSTEnd
        IF @BaseDate >= @DSTStart AND @BaseDate < @DSTEnd
            RETURN 'Y'
        ELSE
            RETURN 'N'
    ELSE
        IF @BaseDate >= @DSTEnd AND @BaseDate < @DSTStart
            RETURN 'N'
        ELSE
            RETURN 'Y'
    RETURN 'N'
END
GO
GRANT EXECUTE ON  [dbo].[InDST] TO [public]
GO
GRANT REFERENCES ON  [dbo].[InDST] TO [public]
GO
