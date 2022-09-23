SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  StoredProcedure [dbo].[tm_ModifySignatureAttemptCount]    Script Date: 03/30/2012 ******/
/**
 * 
 * NAME:
 * dbo.tm_ModifySignatureAttemptCount
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * update tblSignatureCaptureData table
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - @SID, int
 *
 * REVISION HISTORY:
 * 06/25/12      - PTS 61925  JW - Created to insert or update Signature Capture Retrieval count attempts
 *
 **/

/* tm_ModifySignatureAttemptCount **************************************************************
*********************************************************************************/

Create PROCEDURE [dbo].[tm_ModifySignatureAttemptCount]
	@SID int

AS
DECLARE @RCount int
set @RCount = (Select retrievecount + 1 from tblSignatureCaptureData where SignatureId = @SID)

UPDATE tblSignatureCaptureData set retrievecount = @RCount where SignatureId = @SID

GO
GRANT EXECUTE ON  [dbo].[tm_ModifySignatureAttemptCount] TO [public]
GO
