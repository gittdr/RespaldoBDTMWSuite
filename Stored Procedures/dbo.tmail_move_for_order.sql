SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[tmail_move_for_order] @pOrderHdr int, @Tractor varchar(20), @RetVal int OUT

AS

SET NOCOUNT ON

	DECLARE @OrderHdr int
	SELECT @RetVal = 0, @OrderHdr = ABS(@pOrderHdr)

	SELECT @RetVal = max(mov_number) 
	FROM assetassignment (NOLOCK) 
	WHERE 	asgn_status = 'STD' AND 
		asgn_id = @Tractor AND asgn_type = 'TRC' and 
		mov_number in (SELECT mov_number FROM stops WHERE ord_hdrnumber = @OrderHdr) and 
		asgn_date = 
			(SELECT min(asgn_date) 
			FROM assetassignment (NOLOCK) 
			WHERE 
				asgn_status = 'STD' AND 
				asgn_id = @Tractor AND asgn_type = 'TRC' and 
				mov_number in (SELECT mov_number FROM stops WHERE ord_hdrnumber = @OrderHdr))
	IF ISNULL(@RetVal, 0) = 0 AND @OrderHdr <> @pOrderHdr
		SELECT @RetVal = max(mov_number) 
		FROM assetassignment (NOLOCK) 
		WHERE 	asgn_status = 'CMP' AND 
			asgn_id = @Tractor AND asgn_type = 'TRC' and 
			mov_number in (SELECT mov_number 
							FROM stops (NOLOCK)
							WHERE ord_hdrnumber = @OrderHdr) and 
			asgn_date = 
				(SELECT max(asgn_date) 
				FROM assetassignment (NOLOCK) 
				WHERE 
					asgn_status = 'CMP' AND 
					asgn_id = @Tractor AND asgn_type = 'TRC' and 
					mov_number in (SELECT mov_number 
									FROM stops (NOLOCK)
									WHERE ord_hdrnumber = @OrderHdr))
	IF ISNULL(@RetVal, 0) = 0
		SELECT @RetVal = max(mov_number) 
		FROM assetassignment (NOLOCK) 
		WHERE 	asgn_status = 'DSP' AND 
			asgn_id = @Tractor AND asgn_type = 'TRC' and 
			mov_number in (SELECT mov_number 
							FROM stops (NOLOCK)
							WHERE ord_hdrnumber = @OrderHdr) and 
			asgn_date = 
				(SELECT min(asgn_date) 
				FROM assetassignment (NOLOCK) 
				WHERE 
					asgn_status = 'DSP' AND 
					asgn_id = @Tractor AND asgn_type = 'TRC' and 
					mov_number in (SELECT mov_number 
									FROM stops (NOLOCK)
									WHERE ord_hdrnumber = @OrderHdr))
	IF ISNULL(@RetVal, 0) = 0
		SELECT @RetVal = max(mov_number) FROM assetassignment 
		WHERE 	asgn_status = 'PLN' AND 
			asgn_id = @Tractor AND asgn_type = 'TRC' and 
			mov_number in (SELECT mov_number 
							FROM stops (NOLOCK)
							WHERE ord_hdrnumber = @OrderHdr) and 
			asgn_date = 
				(SELECT min(asgn_date) 
				FROM assetassignment (NOLOCK) 
				WHERE 
					asgn_status = 'PLN' AND 
					asgn_id = @Tractor AND asgn_type = 'TRC' and 
					mov_number in (SELECT mov_number 
									FROM stops (NOLOCK)
									WHERE ord_hdrnumber = @OrderHdr))
	IF ISNULL(@RetVal, 0) = 0 AND @OrderHdr = @pOrderHdr
		SELECT @RetVal = max(mov_number) 
		FROM assetassignment (NOLOCK)
		WHERE 	asgn_status = 'CMP' AND 
			asgn_id = @Tractor AND asgn_type = 'TRC' and 
			mov_number in (SELECT mov_number 
							FROM stops (NOLOCK)
							WHERE ord_hdrnumber = @OrderHdr) and 
			asgn_date = 
				(SELECT max(asgn_date) 
				FROM assetassignment (NOLOCK) 
				WHERE 
					asgn_status = 'CMP' AND 
					asgn_id = @Tractor AND asgn_type = 'TRC' and 
					mov_number in (SELECT mov_number 
					FROM stops (NOLOCK)
					WHERE ord_hdrnumber = @OrderHdr))
	IF ISNULL(@RetVal, 0) = 0
		SELECT @RetVal = max(mov_number) 
		FROM legheader (NOLOCK) 
		WHERE 	mov_number in (SELECT mov_number 
								FROM stops (NOLOCK)
								WHERE ord_hdrnumber = @OrderHdr) and
			lgh_outstatus = 'AVL' and
			lgh_startdate = 
				(SELECT min(lgh_startdate) 
				FROM legheader (NOLOCK)
				WHERE 	mov_number in (SELECT mov_number 
										FROM stops (NOLOCK)
										WHERE ord_hdrnumber = @OrderHdr) and
					lgh_outstatus = 'AVL')
	IF ISNULL(@RetVal, 0) = 0
		SELECT @RetVal = min(mov_number) 
		FROM stops (NOLOCK)
		WHERE ord_hdrnumber = @OrderHdr

	SELECT @RetVal = ISNULL(@RetVal, 0)
GO
GRANT EXECUTE ON  [dbo].[tmail_move_for_order] TO [public]
GO
