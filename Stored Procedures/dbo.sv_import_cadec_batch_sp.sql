SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sv_import_cadec_batch_sp] (@batch	INTEGER)
AS
DECLARE	@mov_number	VARCHAR(32)

SELECT	@mov_number = MIN(trip_num)
  FROM	sv_import_cadec_actual_route
 WHERE	trip_num > ''

SELECT	@mov_number = ISNULL(@mov_number, '')

WHILE @mov_number <> ''
BEGIN
	BEGIN TRAN
	EXEC sv_import_cadec_actuals_sp @mov_number
	COMMIT TRAN

	SELECT	@mov_number = MIN(trip_num)
	  FROM	sv_import_cadec_actual_route
	 WHERE	trip_num > @mov_number

	SELECT	@mov_number = ISNULL(@mov_number, '')
END

GO
