SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[TMW_PossibleLatSpan](@Miles float) RETURNS float
AS
BEGIN
-- This is actually very simple, since Latitude lines are parallel, one degree of latitude 
--      is always the same number of miles, so a simple division gives the answer we want.
      RETURN @Miles / 69.053951855155648865555
END
GO
GRANT EXECUTE ON  [dbo].[TMW_PossibleLatSpan] TO [public]
GO
