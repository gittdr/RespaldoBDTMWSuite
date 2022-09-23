SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create function [dbo].[DSTEnds] (@Year int, @DSTCode int)
returns datetime 
begin
    --Currently defined nation codes:
    -- 0: As of 1986: United States, Canada, Mexico, St. Johns, Bahamas, Turks and Caicos (Last Sunday in October)
    --    (1 week later as of 2007)
    -- 1: EU, Russia (Last Sunday in October)
    -- 2: Brazil (Last Sunday in February)
    declare @DayOffset int, @DSTEnd datetime
    
    SELECT @DSTCode = ISNULL(@DSTCode, 0)
    IF @DSTCode = 0 
        BEGIN
        select @DayOffset = (DATEPART(dw, DATEADD(yy, @Year-1900, '19001025') + @@DATEFIRST - 2)) % 7
        IF @Year>=2007
			SELECT @DSTEnd = DATEADD(dd, -@DayOffset, DATEADD(yy, @Year-1900, '19001107 02:00'))
		else
			SELECT @DSTEnd = DATEADD(dd, -@DayOffset, DATEADD(yy, @Year-1900, '19001031 02:00'))
        END
    IF @DSTCode = 1
        BEGIN
        select @DayOffset = (DATEPART(dw, DATEADD(yy, @Year-1900, '19001025') + @@DATEFIRST - 2)) % 7
        SELECT @DSTEnd = DATEADD(dd, -@DayOffset, DATEADD(yy, @Year-1900, '19001031 01:00'))
        END
    IF @DSTCode = -1
        BEGIN
        RETURN NULL
        END
    IF @DSTCode = 2
        BEGIN
        select @DayOffset = (DATEPART(dw, DATEADD(yy, @Year-1900, '19000222') + @@DATEFIRST - 2)) % 7
        SELECT @DSTEnd = DATEADD(dd, -@DayOffset, DATEADD(yy, @Year-1900, '19000228 02:00'))
        IF @DSTEnd = DATEADD(yy, @Year-1900, '19000222 02:00')
            -- On leap years, 2/22 dates change to 2/29.  So check if this is a leap year.
            IF ((@Year % 400) = 0) OR (((@Year % 100) <> 0) AND ((@Year % 4) = 0))
                SELECT @DSTEnd = DATEADD(dd, 7, @DSTEnd) -- Is a leap year
        END
    RETURN @DSTEnd
end
GO
GRANT EXECUTE ON  [dbo].[DSTEnds] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DSTEnds] TO [public]
GO
