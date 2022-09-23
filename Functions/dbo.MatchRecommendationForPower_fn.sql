SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[MatchRecommendationForPower_fn]
(
	@CompanyID		VARCHAR(8),
	@TransactionID	BIGINT,
	@Tractor		VARCHAR(8)	
)
RETURNS VARCHAR(100)
AS
-- body of the function
BEGIN
	DECLARE	@Tour			INTEGER,
			@Reccomendation	VARCHAR(256)

	SELECT	@Tour = MIN(ma_tour_number)
	  FROM	ma_optimals WITH(NOLOCK)
	 WHERE	company_id = @CompanyID
	   AND	ma_transaction_id = @TransactionID
	   AND	trc_number = @Tractor
		
	SELECT	@Reccomendation = ISNULL(@Reccomendation, '') + 
			CASE mo.ma_load_type
				WHEN 'S' THEN CASE WHEN ISNULL(@Reccomendation, '') = '' THEN 'Order(s): ' ELSE ', ' END + CASE WHEN lgh.ord_hdrnumber <> 0 THEN LTRIM(STR(lgh.ord_hdrnumber)) ELSE LTRIM(STR(mo.lgh_number)) + '(Leg)' END
				WHEN 'D' THEN CASE WHEN ISNULL(@Reccomendation, '') = '' THEN 'Order(s): ' ELSE ', ' END + CASE WHEN lgh.ord_hdrnumber <> 0 THEN LTRIM(STR(lgh.ord_hdrnumber)) ELSE LTRIM(STR(mo.lgh_number)) + '(Leg)' END + '(Relay - Drop @ ' + ma_relay_location + ')'
				WHEN 'R' THEN CASE WHEN ISNULL(@Reccomendation, '') = '' THEN 'Order(s): ' ELSE ', ' END + CASE WHEN lgh.ord_hdrnumber <> 0 THEN LTRIM(STR(lgh.ord_hdrnumber)) ELSE LTRIM(STR(mo.lgh_number)) + '(Leg)' END + '(Relay - Pickup @ ' + ma_relay_location + ')'
				WHEN 'F' THEN 'Future Forecasted Load'
				WHEN 'H' THEN CASE WHEN ISNULL(@Reccomendation, '') = '' THEN 'Send Home' ELSE ', Send Home' END
			END
	  FROM	ma_optimals mo WITH(NOLOCK)
				LEFT OUTER JOIN legheader lgh WITH(NOLOCK) ON lgh.lgh_number = mo.lgh_number
	 WHERE	mo.company_id = @CompanyID	
	   AND	mo.ma_transaction_id = @TransactionID 
	   AND	mo.ma_tour_number = @Tour
	ORDER BY mo.ma_tour_sequence ASC
	
	RETURN ISNULL(LEFT(@Reccomendation, 250), '')
END
GO
GRANT EXECUTE ON  [dbo].[MatchRecommendationForPower_fn] TO [public]
GO
