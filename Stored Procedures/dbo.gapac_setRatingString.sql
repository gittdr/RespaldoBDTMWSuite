SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[gapac_setRatingString] (@ord_number varchar (20), 
	                                          @rating_string VARCHAR(800))
AS
BEGIN
   SET NOCOUNT ON;
   SELECT @ord_number, @rating_string
END
GO
GRANT EXECUTE ON  [dbo].[gapac_setRatingString] TO [public]
GO
