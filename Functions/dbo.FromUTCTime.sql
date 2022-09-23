SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[FromUTCTime]
(
    @UTCDateTime datetime
)
RETURNS datetime
BEGIN


RETURN CONVERT(datetime, 
               SWITCHOFFSET(CONVERT(datetimeoffset, 
                                    @UTCDateTime), 
                            DATENAME(TzOffset, SYSDATETIMEOFFSET())))
END





GO
