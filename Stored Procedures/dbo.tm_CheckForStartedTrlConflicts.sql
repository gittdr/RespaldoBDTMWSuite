SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tm_CheckForStartedTrlConflicts]
		@MoveNum		BIGINT,			--
		@TrailerNum		VARCHAR(20)	--

AS

/**
 * 
 * NAME:
 * dbo.[tm_CheckForStartedTrlConflicts]
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Checks if the Trailer is in use on any started trips.
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * @MoveNum			VARCHAR(20),	-- CER SN
 * @TrailerNum		VARCHAR(20),	-- Parent Message SN
 *
 * REVISION HISTORY:
 * 7/8/15					- PTS 93176 JJN - Created Stored Procedure for CR England.
 * 9/25/15					- PTS 95045 AB  - Updated the stored proc to compare 
 *											  against a move instead of an order. Moreover,
 *											  I removed the unused variables.
 **/

BEGIN

	SELECT TOP 1 o.ord_hdrnumber
	FROM orderheader o (NOLOCK)
	LEFT JOIN legheader l (NOLOCK)
	ON o.ord_hdrnumber = l.ord_hdrnumber
	WHERE 
		o.ord_status = 'STD' 
		AND lgh_primary_trailer = @TrailerNum
		AND o.mov_number <> @MoveNum
END	

GRANT EXECUTE ON tm_CheckForStartedTrlConflicts TO PUBLIC
GO
