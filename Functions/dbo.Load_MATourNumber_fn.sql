SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[Load_MATourNumber_fn]
(
	@CompanyID		VARCHAR(8),
	@TransactionID	BIGINT,
	@LghNumber		INTEGER
)
RETURNS INTEGER
AS
-- body of the function
BEGIN
	DECLARE	@Tour			INTEGER,
			@CmpID			VARCHAR(8)
	
	SELECT	@CmpID = CASE 
						 WHEN RTRIM(ISNULL(@CompanyID, '')) = 'UNK' THEN ''
						 ELSE RTRIM(ISNULL(@CompanyID, ''))
					 END

	IF @CmpID = ''
	BEGIN			
		SELECT	@Tour = MIN(ma_tour_number)
		  FROM	ma_optimals WITH(NOLOCK)
		 WHERE	ma_transaction_id = @TransactionID
		   AND	lgh_number = @LghNumber
		   AND	ma_load_type <> 'R'
	END
	ELSE
	BEGIN
		SELECT	@Tour = MIN(ma_tour_number)
		  FROM	ma_optimals WITH(NOLOCK)
		 WHERE	company_id = @CmpID
		   AND	ma_transaction_id = @TransactionID
		   AND	lgh_number = @LghNumber
		   AND	ma_load_type <> 'R'
	END
	
	RETURN @Tour
END
GO
GRANT EXECUTE ON  [dbo].[Load_MATourNumber_fn] TO [public]
GO
