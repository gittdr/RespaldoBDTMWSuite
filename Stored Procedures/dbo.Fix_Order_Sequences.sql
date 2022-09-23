SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Fix_Order_Sequences] @pMove int

AS

DECLARE @lFixOrderSeq int, @stp_number int, @stp_sequence int

SET @lFixOrderSeq = 0 

-- First check for dups
IF EXISTS (SELECT count(*), os.ord_hdrnumber, os.stp_sequence 
			FROM stops os 
			WHERE os.ord_hdrnumber in 
				(SELECT ms.ord_hdrnumber 
					FROM stops ms 
					WHERE ms.mov_number = @pMove 
						AND isnull(ms.ord_hdrnumber, 0)>0) 
				AND not (os.stp_event in ('XDL', 'XDU'))
			GROUP BY os.ord_hdrnumber, os.stp_sequence 
			HAVING count(*) > 1)
	SET @lFixOrderSeq  =1

-- No dups, check for missing entries: for each order should be min = 1 and max = count.
ELSE IF EXISTS (SELECT MAX(isnull(os.stp_sequence,0)), count(*), MIN(isnull(os.stp_sequence,0)) 
	FROM stops os 
	WHERE os.ord_hdrnumber in 
		(SELECT ms.ord_hdrnumber 
			FROM stops ms 
			WHERE ms.mov_number = @pMove 
				AND isnull(ms.ord_hdrnumber, 0)>0) 
		AND not (os.stp_event in ('XDL', 'XDU'))
	GROUP BY os.ord_hdrnumber 
	HAVING MAX(isnull(os.stp_sequence,0))<>count(*) 
			OR MIN(isnull(os.stp_sequence,0)) <> 1)
	SET @lFixOrderSeq  =1

IF @lFixOrderSeq = 1
	BEGIN
	SELECT @stp_number = 0
	WHILE (1=1)
		BEGIN
		SELECT @stp_number = MIN(stp_number) FROM stops WHERE 
			ord_hdrnumber in  
			(SELECT ms.ord_hdrnumber 
				FROM stops ms 
				WHERE ms.mov_number = @pMove 
					AND isnull(ms.ord_hdrnumber, 0)>0)
			AND stp_number > @stp_number
			AND not (stp_event in ('XDL', 'XDU'))

		IF ISNULL(@stp_number, 0) = 0
			BREAK

		SELECT @stp_sequence = 
			(SELECT count(*) 
				FROM stops ss 
				WHERE ss.ord_hdrnumber = stops.ord_hdrnumber and 
				(	ss.stp_arrivaldate < stops.stp_arrivaldate or
					(ss.stp_arrivaldate = stops.stp_arrivaldate and ss.lgh_number = stops.lgh_number and ss.stp_mfh_sequence < stops.stp_mfh_sequence) or
					(ss.stp_arrivaldate = stops.stp_arrivaldate and (ss.lgh_number <> stops.lgh_number or ss.stp_mfh_sequence = stops.stp_mfh_sequence) and ss.stp_number < stops.stp_number)
				)
				AND not (stp_event in ('XDL', 'XDU'))
			)+1		
		FROM stops 
		WHERE stops.stp_number = @stp_number

		UPDATE stops SET stp_sequence = @stp_sequence
		FROM stops 
		WHERE stops.stp_number = @stp_number
			AND stp_sequence <> @stp_sequence
		END
	END

	SELECT @stp_number = 0
	WHILE (1=1)
		BEGIN
		SELECT @stp_number = MIN(stp_number) 
			FROM stops 
			WHERE mov_number = @pMove AND 
				stp_number > @stp_number AND 
				(isnull(ord_hdrnumber, 0) = 0 OR stp_event IN ('XDL', 'XDU')) AND 
				ISNULL(stp_sequence, 0) <> 0 

		IF ISNULL(@stp_number, 0) = 0 BREAK
		--Update stop sequences for non-order stops
		UPDATE stops 
			SET stp_sequence = 0 
			WHERE stp_number = @stp_number
		END

GO
GRANT EXECUTE ON  [dbo].[Fix_Order_Sequences] TO [public]
GO
