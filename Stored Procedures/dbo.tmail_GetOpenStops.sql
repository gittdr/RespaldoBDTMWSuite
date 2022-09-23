SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_GetOpenStops] (@AsgnID AS VARCHAR(30), @AsgnType AS VARCHAR(20), @Flags AS VARCHAR(255), @LAFlags AS VARCHAR(255))

AS

/*
Flags
	1 - Exclude STD
	2 - Exclude DSP
	4 - Include PLN
	8 - Delete Duplicate Stops Between Legheaders
	16 - Delete First Stop in Open Stops
*/

	EXEC tmail_GetOpenStops2 @AsgnID, @AsgnType, @Flags, @LAFlags, '0', '0'

GO
GRANT EXECUTE ON  [dbo].[tmail_GetOpenStops] TO [public]
GO
