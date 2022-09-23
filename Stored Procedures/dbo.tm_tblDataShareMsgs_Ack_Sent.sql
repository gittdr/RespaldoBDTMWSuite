SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_tblDataShareMsgs_Ack_Sent] 
							(
							 @TrailerID				AS VARCHAR(13),
							 @SCAC					AS VARCHAR(4)
							 )
AS

	BEGIN
		------------------------------------------------------------------------
		-- Find the record in tblDataShareMsgs and make modification.
		IF EXISTS( SELECT SN
					 FROM dbo.tblDataShareMsgs 
					WHERE TrailerID = @TrailerID
					  AND SCAC = @SCAC
					  AND RqstSent IN ('Y','X')
					  AND AckSent = 'N')

			BEGIN

				UPDATE	dbo.tblDataShareMsgs
				   SET
						AckSent = 'Y' ,
						DTAckSent = GETDATE(),
						Updatedon = GETDATE()
				 WHERE 
						TrailerID = @TrailerID
				   AND	
						SCAC = @SCAC
				   AND
						RqstSent IN ('Y', 'X')
				   AND	
						AckSent = 'N'

			END
			
	END

GO
GRANT EXECUTE ON  [dbo].[tm_tblDataShareMsgs_Ack_Sent] TO [public]
GO
