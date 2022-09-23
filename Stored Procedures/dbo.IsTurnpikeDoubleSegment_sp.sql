SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[IsTurnpikeDoubleSegment_sp]
(
	@lgh_number	INTEGER,
	@status		BIT OUTPUT
)
AS
BEGIN
	IF EXISTS(SELECT	1
				FROM	stops
			   WHERE	mov_number = (SELECT	mov_number
										FROM	legheader 
									   WHERE	lgh_number = @lgh_number)
				 AND	stp_event IN ('XDT', 'XHT', 'XDE', 'XHE'))
	BEGIN
		SET @status = 1
	END
	ELSE
	BEGIN 
		SET @status = 0
	END
END
GO
GRANT EXECUTE ON  [dbo].[IsTurnpikeDoubleSegment_sp] TO [public]
GO
