SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Determines the outstatus of the specified legheader, but defines a distinct status (CMP-) for the situation where
-- the final stop has arrived but not departed.  If FuelMode is active, then any final Deadhead stop (EMT, EBT, IEMT,
-- or IEBT) is ignored when determining this status.
CREATE function [dbo].[tmail_get_eff_outstatus] (@lgh int, @FuelMode int)
	RETURNS varchar(6)
as
BEGIN
DECLARE @Retval varchar(6),@Arv varchar(6), @Dep varchar(6)
SELECT @RetVal = lgh_outstatus from legheader where lgh_number = @lgh
IF @Retval not in ('STD', 'CMP') RETURN @RetVal
SELECT TOP 1 @Arv = stp_status, @Dep =stp_departure_status 
  FROM stops WHERE lgh_number = @lgh AND (@FuelMode = 0 OR stp_event not in ('EMT', 'EBT', 'IEMT', 'IEBT'))
  order by stp_mfh_sequence desc
IF @Dep = 'DNE' RETURN 'CMP'
IF @Arv = 'DNE' RETURN 'CMP-'
RETURN 'STD'
END
GO
GRANT EXECUTE ON  [dbo].[tmail_get_eff_outstatus] TO [public]
GO
