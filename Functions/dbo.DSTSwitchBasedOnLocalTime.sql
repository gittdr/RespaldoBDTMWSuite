SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create function [dbo].[DSTSwitchBasedOnLocalTime] (@DSTCode int)
returns char(1)
begin
    -- Returns a flag whether the specified Nation determines the time to switch to DST
    --     based on:
    --         Y: the Local Time (US, Canada) (DSTCodes: 0)
    --         N: A time in a particular TimeZone (EU, DSTStart and DSTEnd routines will 
    --              return GST values for switchover datetimes) (DSTCodes: 1)
    SELECT @DSTCode = ISNULL(@DSTCode, 0)
    IF @DSTCode = 0 OR @DSTCode = 2
        RETURN 'Y'
    RETURN 'N'
end
GO
GRANT EXECUTE ON  [dbo].[DSTSwitchBasedOnLocalTime] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DSTSwitchBasedOnLocalTime] TO [public]
GO
