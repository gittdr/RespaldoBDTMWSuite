SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[MatchRecommendationForLoad_fn]
(
	@CompanyID		VARCHAR(8),
	@TransactionID	BIGINT,
	@LghNumber		INTEGER
)
RETURNS VARCHAR(250)
AS
-- body of the function
BEGIN
	DECLARE	@Tour			INTEGER,
			@Assets			VARCHAR(30),
			@Reccomendation	VARCHAR(256)

	SELECT	TOP 1
			@Tour = ma_tour_number,
			@Reccomendation = 'TRC: ' + trc_number + '  [' + dbo.MatchRecommendationForPower_fn(@CompanyID, ma_transaction_id, trc_number) + ']'
		FROM	ma_optimals WITH(NOLOCK)
		WHERE	company_id = @CompanyID
		AND	ma_transaction_id = @TransactionID
		AND	lgh_number = @LghNumber
		AND	ma_load_type <> 'R' 
			
	RETURN ISNULL(LEFT(@Reccomendation, 100), '')
END
GO
GRANT EXECUTE ON  [dbo].[MatchRecommendationForLoad_fn] TO [public]
GO
