SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[InDST_7] (@BaseDate datetime, @DSTCode int, @InDST char(1) out)
as
BEGIN
    -- Checks if @BaseDate is in the DST period for the specified DSTCode (see DSTStarts
    --     for a list of defined DSTCodes).  Assumes that @BaseDate has already been
    --     switched to the TimeZone appropriate for the DSTCode (For example, in US it
    --     should be in Local time, while for the EU it should be in WET/WEST.
    DECLARE @DSTStart datetime, @DSTEnd datetime, @YearNumber int
    SELECT @DSTCode = ISNULL(@DSTCode, 0)
    IF @DSTCode = -1
        begin
        select @InDST = 'N'
        RETURN
        end
    SELECT @YearNumber = YEAR(@BaseDate)
    exec dbo.DSTStarts_7 @YearNumber, @DSTCode, @DSTStart out
    exec dbo.DSTEnds_7 @YearNumber, @DSTCode, @DSTEnd out
    IF @DSTStart < @DSTEnd
        IF @BaseDate >= @DSTStart AND @BaseDate < @DSTEnd
            begin
            select @InDST = 'Y'
            RETURN
            end
        ELSE
            begin
            select @InDST = 'N'
            RETURN
            end
    ELSE
        IF @BaseDate >= @DSTEnd AND @BaseDate < @DSTStart
            begin
            select @InDST = 'N'
            RETURN
            end
        ELSE
        	begin
            select @InDST = 'Y'
            RETURN
            end
    select @InDST = 'N'
    RETURN
END
GO
GRANT EXECUTE ON  [dbo].[InDST_7] TO [public]
GO
