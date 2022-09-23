SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[Load_MAReccomendation_fn]
(
	@CompanyID		VARCHAR(8),
	@TransactionID	BIGINT,
	@LghNumber		INTEGER
)
RETURNS VARCHAR(100)
AS
-- body of the function
BEGIN
	DECLARE	@Tour			INTEGER,
			@Assets			VARCHAR(30),
			@Reccomendation	VARCHAR(256),
			@CmpID			VARCHAR(8)
	
	SELECT	@CmpID = CASE 
						 WHEN RTRIM(ISNULL(@CompanyID, '')) = 'UNK' THEN ''
						 ELSE RTRIM(ISNULL(@CompanyID, ''))
					 END

	IF @CmpID = ''
	BEGIN			
		SELECT	TOP 1
				@Tour = ma_tour_number,
				@Reccomendation = 'TRC: ' + trc_number + '  DRV: ' + mpp_id + '  [' + dbo.Power_MAReccomendation_fn(@CmpID, ma_transaction_id, trc_number) + ']'
		  FROM	ma_optimals WITH(NOLOCK)
		 WHERE	ma_transaction_id = @TransactionID
		   AND	lgh_number = @LghNumber
		   AND	ma_load_type <> 'R' 
	END
	ELSE
	BEGIN
		SELECT	TOP 1
				@Tour = ma_tour_number,
				@Reccomendation = 'TRC: ' + trc_number + '  DRV: ' + mpp_id + '  [' + dbo.Power_MAReccomendation_fn(@CmpID, ma_transaction_id, trc_number) + ']'
		  FROM	ma_optimals WITH(NOLOCK)
		 WHERE	company_id = @CmpID
		   AND	ma_transaction_id = @TransactionID
		   AND	lgh_number = @LghNumber
		   AND	ma_load_type <> 'R' 
	END
			
	RETURN ISNULL(LEFT(@Reccomendation, 100), '')
END
GO
GRANT EXECUTE ON  [dbo].[Load_MAReccomendation_fn] TO [public]
GO
