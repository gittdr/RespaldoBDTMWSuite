SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[tm_SelectSignaturesWithoutImages]    Script Date: 03/30/2012 ******/
/**
 * 
 * NAME:
 * dbo.tm_SelectSignaturesWithoutImages
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 *  Select Signatures Without Images
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 *
 * REVISION HISTORY:
 * 06/25/12      - PTS 61925  JW - Created to SelectSignaturesWithoutImages
 * 09/15/14		 - PTS 74879  rwolfe -in some cases we will only have a name and not an image
 * 11/30/15		 - PTS 96938  rwolfe -ajust for multi-vendor
 **/

/* tm_SelectSignaturesWithoutImages **************************************************************
*********************************************************************************/

Create PROCEDURE [dbo].[tm_SelectSignaturesWithoutImages]
	@Vendor varchar(6) = 'PNET' --used to only be used by PNET, now D2link support exists

AS
select 
SCD.SN as oSCDSN, 
SCD.stp_number,
SCD.msg_SN,
SCD.signatureid,
SCD.signaturename,
SCD.retrievecount,
SCD.receiveddate,
SCI.SN as SCISN,
SCI.SCD_SN,
SCI.imagename,
SCI.signatureimage
from tblSignatureCaptureData SCD
left join tblSignatureCaptureImage SCI
on SCD.SN = SCI.SCD_SN
where SCI.signatureimage is NULL AND SCI.imagename IS NULL AND SCD.vendor = @Vendor

GO
GRANT EXECUTE ON  [dbo].[tm_SelectSignaturesWithoutImages] TO [public]
GO
