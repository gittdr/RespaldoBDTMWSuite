SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[get_FurthestDistanceCommodityCode_sp] (
	@ord_hdrnumber	int,
	@cmd_code		varchar(8) output
	)
AS

DECLARE	@temp TABLE (
		cmd_code		varchar(8),
		total_volume	float)
	
DECLARE @cmp_blended_min_qty	decimal,
		@bill_to				varchar(8),
		@total_fgt_volume		float

SELECT	@bill_to = ord_billto
FROM	orderheader
WHERE	ord_hdrnumber = @ord_hdrnumber

SELECT	@cmp_blended_min_qty = isnull(cmp_blended_min_qty, 0)
FROM	company
WHERE	cmp_id = @bill_to

IF	@cmp_blended_min_qty > 0
BEGIN 
	SELECT	@total_fgt_volume = SUM(isnull(fgt_volume, 0))
	FROM	freightdetail 
	WHERE	stp_number in(
			SELECT stp_number
			FROM	stops
			WHERE	ord_hdrnumber = @ord_hdrnumber
			AND		stp_type = 'DRP')

	IF	@total_fgt_volume > @cmp_blended_min_qty
	BEGIN
		INSERT	INTO @temp
		SELECT	cmd_code, SUM(isnull(fgt_volume, 0)) 
		FROM	freightdetail
		WHERE	stp_number IN (SELECT stp_number FROM stops WHERE ord_hdrnumber = @ord_hdrnumber AND stp_type = 'DRP')
		GROUP BY cmd_code

		IF	@@ROWCOUNT > 0
		SELECT	@cmd_code = MAX(cmd_code)
		FROM	@temp
		WHERE	total_volume = (SELECT MAX(total_volume) FROM @temp)
	END
END
GO
GRANT EXECUTE ON  [dbo].[get_FurthestDistanceCommodityCode_sp] TO [public]
GO
