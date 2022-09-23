SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cloneordershipconditions](@source_mov_number INT,
                                          @new_mov_number INT)
AS
DECLARE @minoldlgh	INT,
	@minnewlgh	INT

SET @minoldlgh = 0
SET @minnewlgh = 0
WHILE 1=1
BEGIN
   SELECT @minoldlgh = MIN(lgh_number)
     FROM legheader
    WHERE mov_number = @source_mov_number AND
          lgh_number > @minoldlgh

   SELECT @minnewlgh = MIN(lgh_number)
     FROM legheader
    WHERE mov_number = @new_mov_number AND
          lgh_number > @minnewlgh

   IF @minoldlgh IS NULL OR @minnewlgh IS NULL
      BREAK

   INSERT INTO ship_conditions (lgh_number, sc_code, sc_group, sc_quantity, sc_units, updatedt, 
                                updatedby)
   SELECT @minnewlgh, sc_code, sc_group, sc_quantity, sc_units, GETDATE(), USER_NAME()
     FROM ship_conditions
    WHERE lgh_number = @minoldlgh

END
	
GO
GRANT EXECUTE ON  [dbo].[cloneordershipconditions] TO [public]
GO
