SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[validate_outbound204] (@lgh_number 	INTEGER,
                                           @car_id	VARCHAR(8),
                                           @errtext	VARCHAR(255) OUTPUT)
AS
SET @errtext = ''
RETURN 1
GO
GRANT EXECUTE ON  [dbo].[validate_outbound204] TO [public]
GO
