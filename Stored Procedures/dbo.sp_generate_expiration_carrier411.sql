SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_generate_expiration_carrier411]
( @car_id   VARCHAR(8)
)
AS

/**
 *
 * NAME:
 * dbo.sp_generate_expiration_carrier411
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to Generate Carrier411 Expirations
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 * @car_id   VARCHAR(8)
 *
 * REVISION HISTORY:
 * PROJECT#          SPN Created 12/06/13
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @BATCH_ID INT

   DECLARE @Carrier TABLE
   ( id     INT IDENTITY
   , docket VARCHAR(12)
   , PRIMARY KEY(id)
   )

   IF @car_id IS NULL
      SELECT @car_id = ''

   SELECT @car_id = @car_id + '%'

   --BATCH_ID
   BEGIN TRAN sp_gecarrier411
      INSERT INTO carrier411ws(method,workflow_id) VALUES ('Carrier411RegenExp',-1)
      SELECT @BATCH_ID = SCOPE_IDENTITY()
   COMMIT TRAN sp_gecarrier411

   --Carriers to process
   INSERT INTO @Carrier
   ( docket
   )
   SELECT DISTINCT car_iccnum
     FROM carrier
    WHERE car_iccnum IS NOT NULL
      AND car_iccnum <> ''
      AND car_id LIKE @car_id

   INSERT INTO carrier411data
   ( BATCH_ID
   , submethod
   , docket
   )
   SELECT @BATCH_ID
        , '(none)'
        , docket
     FROM @Carrier

   --Update Expirations
   EXEC sp_carrier411_generate_expiration @BATCH_ID

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_generate_expiration_carrier411] TO [public]
GO
