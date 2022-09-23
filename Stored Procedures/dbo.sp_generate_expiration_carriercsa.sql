SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_generate_expiration_carriercsa]
( @car_id   VARCHAR(8)
)
AS

/**
 *
 * NAME:
 * dbo.sp_generate_expiration_carriercsa
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to Generate CSA Expirations
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

	DECLARE @id                         INT
	DECLARE @maxid                      INT
	
	DECLARE @docket                     VARCHAR(12)
	DECLARE @CarrierCSALogHdr_id        INT
	DECLARE @CarrierCSALogDtl_id        INT

	DECLARE @Carrier TABLE
	( id     INT IDENTITY
	, docket VARCHAR(12)
	, PRIMARY KEY(id)
	)
   
	IF @car_id IS NULL 
		SELECT @car_id = ''
   
	SELECT @car_id = @car_id + '%'

	--CSALog
	EXEC dbo.sp_CarrierCSALogHdr 'Carrier411', @CarrierCSALogHdr_id OUT

	--Carriers to process
	INSERT INTO @Carrier
	( docket
	)
	SELECT DISTINCT car_iccnum
	  FROM carrier
	 WHERE car_iccnum IS NOT NULL
		AND car_iccnum <> ''
		AND car_id LIKE @car_id

	SELECT @id = 0
	SELECT @maxid = MAX(id) FROM @Carrier
	WHILE @id < @maxid
	BEGIN
		SELECT @id = MIN(id) FROM @Carrier WHERE id > @id
		SELECT @docket = docket
		  FROM @Carrier 
		 WHERE id = @id

		EXEC dbo.sp_CarrierCSALogDtl @CarrierCSALogHdr_id, @docket, @CarrierCSALogDtl_id OUT

		UPDATE CarrierCSA
			SET CarrierCSALogDtl_id = @CarrierCSALogDtl_id
		 WHERE docket = @docket
	END

	--Update Expirations
	EXEC sp_carriercsa_generate_expiration @CarrierCSALogHdr_id
   
	RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_generate_expiration_carriercsa] TO [public]
GO
