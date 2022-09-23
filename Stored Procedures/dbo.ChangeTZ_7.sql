SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ChangeTZ_7](@SourceDate datetime, @SourceTZ int, @SourceDSTCode int, @SourceTZAddlMins int, @DestTZ int, @DestDSTCode int, @DestTZAddlMins int, @DestDate datetime out)
AS
BEGIN
    DECLARE @ZuluDate datetime
    IF (@SourceTZ is NULL) OR (@DestTZ is NULL) OR (@SourceDate IS NULL)
        begin
		select @DestDate = @SourceDate
        RETURN
		end
    exec dbo.ToZulu_7 @SourceDate, @SourceTZ, @SourceDSTCode, @SourceTZAddlMins, @ZuluDate out
    exec dbo.FromZulu_7 @ZuluDate, @DestTZ, @DestDSTCode, @DestTZAddlMins, @DestDate out
    RETURN 
END
GO
GRANT EXECUTE ON  [dbo].[ChangeTZ_7] TO [public]
GO
