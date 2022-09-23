SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DSTSwitchBasedOnLocalTime_7] (@DSTCode int, @DSTSwitch char(1) out)
as
begin
    -- Returns a flag whether the specified Nation determines the time to switch to DST
    --     based on:
    --         Y: the Local Time (US, Canada) (DSTCodes: 0)
    --         N: A time in a particular TimeZone (EU, DSTStart and DSTEnd routines will 
    --              return GST values for switchover datetimes) (DSTCodes: 1)
    SELECT @DSTCode = ISNULL(@DSTCode, 0)
    IF @DSTCode = 0 OR @DSTCode = 2
        begin
        select @DSTSwitch = 'Y'
        RETURN
        end
    select @DSTSwitch = 'N'
    RETURN
end
GO
GRANT EXECUTE ON  [dbo].[DSTSwitchBasedOnLocalTime_7] TO [public]
GO
