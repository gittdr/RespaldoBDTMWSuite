SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[TMW_PossibleLongSpan](@Latitude FLOAT, @Miles FLOAT) RETURNS FLOAT
AS
BEGIN
   DECLARE @MilesPerDegree   FLOAT,
           @RetVal           FLOAT
   IF @Latitude < 0 
      SELECT @Latitude = -@Latitude

   SELECT @Latitude = @Latitude + @Miles / 69.053951855155648865555

   IF @Latitude > 90 
      RETURN 180.0

   IF @Latitude = 90 
      RETURN 90.0

   SELECT @MilesPerDegree = 69.053951855155648865555 * COS(@Latitude * 3.1415926535897932 /180)
   SELECT @RetVal = @Miles / @MilesPerDegree 
   IF @RetVal > 90 
      SELECT @Retval = 90

   RETURN @Retval
END
GO
GRANT EXECUTE ON  [dbo].[TMW_PossibleLongSpan] TO [public]
GO
