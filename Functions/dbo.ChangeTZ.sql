SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[ChangeTZ]( @SourceDate datetime, @SourceTZ int, @SourceDSTCode int, @SourceTZAddlMins int, @DestTZ int, @DestDSTCode int, @DestTZAddlMins int)
RETURNS datetime 
BEGIN
    DECLARE @ZuluDate datetime
    IF (@SourceTZ is NULL) OR (@DestTZ is NULL) OR (@SourceDate IS NULL)
        RETURN @SourceDate
    SELECT @ZuluDate = dbo.ToZulu (@SourceDate, @SourceTZ, @SourceDSTCode, @SourceTZAddlMins)
    RETURN dbo.FromZulu(@ZuluDate, @DestTZ, @DestDSTCode, @DestTZAddlMins)
END
GO
GRANT EXECUTE ON  [dbo].[ChangeTZ] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ChangeTZ] TO [public]
GO
