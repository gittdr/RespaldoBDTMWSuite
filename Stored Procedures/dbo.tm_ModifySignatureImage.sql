SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[tm_ModifySignatureImage]    Script Date: 03/30/2012 ******/
/**
 * 
 * NAME:
 * dbo.ModifySignatureImage
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * insert into or update tblSignatureCaptureImage table
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - @SID, int
 * 002 - @SignatureImageName, varchar [150]    
 * 003 - @SignatureImage, varbinary(MAX)
 *
 * REVISION HISTORY:
 * 06/25/12      - PTS 61925  JW - Created to insert or update Signature Capture Images
 * 09/15/14		 - PTS 74879  rwolfe -we should use the SN as a link, not the imageSID
 *
 **/

/* ModifySignatureImage **************************************************************
*********************************************************************************/

Create PROCEDURE [dbo].[tm_ModifySignatureImage]
	@SID int,
	@SignatureImageName varchar (150),
	@SignatureImage varbinary(MAX) = NULL

AS
DECLARE @SCDSN int
set @SCDSN = @SID

BEGIN TRY
	IF Exists (Select * from tblSignatureCaptureImage where SCD_SN = @SCDSN)
	BEGIN
		UPDATE tblSignatureCaptureImage set imagename = @SignatureImageName, signatureimage = @SignatureImage where SCD_SN = @SCDSN
	END
	ELSE
	BEGIN
		INSERT INTO tblSignatureCaptureImage (
			SCD_SN,
			imagename,
			signatureimage
		)
		VALUES
		(
			@SCDSN,
			@SignatureImageName,
			@SignatureImage
		)
	END
END Try
BEGIN CATCH 
	UPDATE tblSignatureCaptureData SET retrievecount = retrievecount + 1 WHERE SN = @SCDSN
END CATCH 


GO
GRANT EXECUTE ON  [dbo].[tm_ModifySignatureImage] TO [public]
GO
