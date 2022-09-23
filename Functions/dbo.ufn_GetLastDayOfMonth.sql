SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[ufn_GetLastDayOfMonth] ( @pInputDate    DATETIME )
RETURNS DATETIME
BEGIN

    DECLARE @vOutputDate        DATETIME

    SET @vOutputDate = CAST(YEAR(@pInputDate) AS VARCHAR(4)) + '/' + 
                       CAST(MONTH(@pInputDate) AS VARCHAR(2)) + '/01'
    SET @vOutputDate = DATEADD(DD, -1, DATEADD(M, 1, @vOutputDate))

    RETURN @vOutputDate

END
GO
