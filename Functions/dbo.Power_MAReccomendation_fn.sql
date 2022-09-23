SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[Power_MAReccomendation_fn]
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
			@Reccomendation	VARCHAR(256),
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
		   AND	trc_number = @Tractor
		
		SELECT	@Reccomendation = ISNULL(@Reccomendation, '') + 
					CASE mo.ma_load_type
						WHEN 'S' THEN CASE WHEN ISNULL(@Reccomendation, '') = '' THEN 'Leg(s): ' ELSE ', ' END + LTRIM(STR(mo.lgh_number))
						WHEN 'D' THEN CASE WHEN ISNULL(@Reccomendation, '') = '' THEN 'Leg(s): ' ELSE ', ' END + LTRIM(STR(mo.lgh_number)) + '(Relay - Drop @ ' + ma_relay_location + ')'
						WHEN 'R' THEN CASE WHEN ISNULL(@Reccomendation, '') = '' THEN 'Leg(s): ' ELSE ', ' END + LTRIM(STR(mo.lgh_number)) + '(Relay - Pickup @ ' + ma_relay_location + ')'
						WHEN 'F' THEN 'Future Forecasted Load'
						WHEN 'H' THEN CASE WHEN ISNULL(@Reccomendation, '') = '' THEN 'Send Home' ELSE ', Send Home' END
					END
		  FROM	ma_optimals mo WITH(NOLOCK)
					LEFT OUTER JOIN legheader lgh WITH(NOLOCK) ON lgh.lgh_number = mo.lgh_number
		 WHERE	mo.ma_transaction_id = @TransactionID 
		   AND	mo.ma_tour_number = @Tour
		 ORDER BY mo.ma_tour_sequence ASC
	 END
	 ELSE
	 BEGIN
	 	SELECT	@Tour = MIN(ma_tour_number)
		  FROM	ma_optimals WITH(NOLOCK)
		 WHERE	company_id = @CmpID
		   AND	ma_transaction_id = @TransactionID
		   AND	trc_number = @Tractor
		
		SELECT	@Reccomendation = ISNULL(@Reccomendation, '') + 
					CASE mo.ma_load_type
						WHEN 'S' THEN CASE WHEN ISNULL(@Reccomendation, '') = '' THEN 'Leg(s): ' ELSE ', ' END + LTRIM(STR(mo.lgh_number))
						WHEN 'D' THEN CASE WHEN ISNULL(@Reccomendation, '') = '' THEN 'Leg(s): ' ELSE ', ' END + LTRIM(STR(mo.lgh_number)) + '(Relay - Drop @ ' + ma_relay_location + ')'
						WHEN 'R' THEN CASE WHEN ISNULL(@Reccomendation, '') = '' THEN 'Leg(s): ' ELSE ', ' END + LTRIM(STR(mo.lgh_number)) + '(Relay - Pickup @ ' + ma_relay_location + ')'
						WHEN 'F' THEN 'Future Forecasted Load'
						WHEN 'H' THEN CASE WHEN ISNULL(@Reccomendation, '') = '' THEN 'Send Home' ELSE ', Send Home' END
					END
		  FROM	ma_optimals mo WITH(NOLOCK)
					LEFT OUTER JOIN legheader lgh WITH(NOLOCK) ON lgh.lgh_number = mo.lgh_number
		 WHERE	mo.company_id = @CmpID	
		   AND	mo.ma_transaction_id = @TransactionID 
		   AND	mo.ma_tour_number = @Tour
		 ORDER BY mo.ma_tour_sequence ASC
	 END
	
	RETURN ISNULL(LEFT(@Reccomendation, 100), '')
END
GO
GRANT EXECUTE ON  [dbo].[Power_MAReccomendation_fn] TO [public]
GO
