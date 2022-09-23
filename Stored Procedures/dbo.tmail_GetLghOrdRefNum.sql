SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_GetLghOrdRefNum]
						@lLghNum int, 
						@sRefType varchar(6)
AS

SET NOCOUNT ON 

DECLARE @FirstStopWithCorrectRefTypeOnOrder int

SELECT @FirstStopWithCorrectRefTypeOnOrder = MIN(stp_mfh_sequence) 
FROM stops (NOLOCK)
INNER JOIN orderheader (NOLOCK) ON stops.ord_hdrnumber = orderheader.ord_hdrnumber
WHERE stops.lgh_number = @lLghNum AND ISNULL(orderheader.ord_refnum, '') <> ''
		AND ord_reftype = @sRefType

IF ISNULL(@FirstStopWithCorrectRefTypeOnOrder,0) = 0
	BEGIN
		SELECT ''
		RETURN	
	END

SELECT ord_refnum 
FROM stops (NOLOCK)
INNER JOIN orderheader (NOLOCK) ON stops.ord_hdrnumber = orderheader.ord_hdrnumber
WHERE stops.lgh_number = @lLghNum AND stp_mfh_sequence = @FirstStopWithCorrectRefTypeOnOrder

GO
GRANT EXECUTE ON  [dbo].[tmail_GetLghOrdRefNum] TO [public]
GO
