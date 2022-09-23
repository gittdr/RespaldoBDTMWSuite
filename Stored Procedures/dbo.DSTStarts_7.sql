SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DSTStarts_7] (@Year int, @DSTCode int, @DSTStart datetime out)
as
BEGIN
    --Currently defined nation codes:
    -- 0: As of 1986: United States, Canada, Mexico, St. Johns, Bahamas, Turks and Caicos (1st Sunday in April)
    --    (2nd Sunday in March as of 2007)
    -- 1: EU, Russia (Last Sunday in March)
    -- 2: Brazil (Last Sunday in October)
    declare @DayOffset int

    SELECT @DSTCode = ISNULL(@DSTCode, 0)
    IF @DSTCode = 0
        BEGIN
        if @Year >=2007
			BEGIN
			select @DayOffset = (DATEPART(dw, DATEADD(yy, @Year-1900, '19000301 00:00') + @@DATEFIRST - 2)) % 7
	        SELECT @DSTStart = DATEADD(dd, -@DayOffset, DATEADD(yy, @Year-1900, '19000314 02:00'))
			END
		else
			BEGIN
			select @DayOffset = (DATEPART(dw, DATEADD(yy, @Year-1900, '19000401 00:00') + @@DATEFIRST - 2)) % 7
	        SELECT @DSTStart = DATEADD(dd, -@DayOffset, DATEADD(yy, @Year-1900, '19000407 02:00'))
	        END
        END
    IF @DSTCode = -1
        select @DSTStart = NULL
    IF @DSTCode = 1
        BEGIN
        select @DayOffset = (DATEPART(dw, DATEADD(yy, @Year-1900, '19000325 00:00') + @@DATEFIRST - 2)) % 7
        SELECT @DSTStart = DATEADD(dd, -@DayOffset, DATEADD(yy, @Year-1900, '19000331 01:00'))
        END
    IF @DSTCode = 2
        BEGIN
        select @DayOffset = (DATEPART(dw, DATEADD(yy, @Year-1900, '19001001 00:00') + @@DATEFIRST - 2)) % 7
        SELECT @DSTStart = DATEADD(dd, -@DayOffset, DATEADD(yy, @Year-1900, '19001007 02:00'))
        END
    return 
END
GO
GRANT EXECUTE ON  [dbo].[DSTStarts_7] TO [public]
GO
