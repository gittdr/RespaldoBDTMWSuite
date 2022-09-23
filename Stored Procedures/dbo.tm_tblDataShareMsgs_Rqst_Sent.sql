SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_tblDataShareMsgs_Rqst_Sent] 
							(
							 @TrailerID				AS VARCHAR(8),
							 @SCAC					AS VARCHAR(4),
							 @RqstSent				AS VARCHAR(1)
							 )
AS

	BEGIN
		------------------------------------------------------------------------
		-- Find the record in tblDataShareMsgs and make modification.
		IF EXISTS( SELECT SN
					 FROM dbo.tblDataShareMsgs 
					WHERE TrailerID = @TrailerID
					  AND SCAC = @SCAC
					  AND RqstSent = 'N'
					  AND AckSent = 'N')

			BEGIN

				UPDATE	dbo.tblDataShareMsgs
				   SET
						RqstSent = @RqstSent ,
						DtRqstSent = GETDATE(),
						Updatedon = GETDATE()
				 WHERE 
						TrailerID = @TrailerID
				   AND
						SCAC = @SCAC
				   AND	
						RqstSent = 'N'
				   AND	
						AckSent = 'N'

			END
			
	END

GO
GRANT EXECUTE ON  [dbo].[tm_tblDataShareMsgs_Rqst_Sent] TO [public]
GO
