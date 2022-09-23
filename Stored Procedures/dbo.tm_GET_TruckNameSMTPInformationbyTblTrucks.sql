SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TruckNameSMTPInformationbyTblTrucks]
	@TRname varchar (15)
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_TruckNameSMTPInformationbyTblTrucks]
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls PropSN, FldType and TypeName value base on a EntryType and PropSN
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * PropSN, FldType and TypeName fields
 *
 * PARAMETERS:
 * 001 - @TRname varchar(15)
 * 
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_TruckNameSMTPInformationbyTblTrucks]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT SN, MAPIProfile, SMTPReplyAddress, SMTPPassword, SMTPLogin, AlternateID, 
DispSysTruckID 
FROM dbo.tblTrucks 
WHERE TruckName = @TRname

GO
GRANT EXECUTE ON  [dbo].[tm_GET_TruckNameSMTPInformationbyTblTrucks] TO [public]
GO
