SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**
 * 
 * NAME:
 * dbo.tm_Get_MCType_Info
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls Mobile Communication information for a specified vendor
 *
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * tblMobileCommType record information
 *
 * PARAMETERS:
 * 001 - @sMCommSN, varchar(12);
 *       SN of a tblMobileCommtype to pull. May be blank if @sMCommType is set.
 * 002 - @sMCommType, varchar(20);
 *		 Mobile comm type of pull. May be blank if @sMCommSN is set.
 * 003 - @sFlags, varchar(12);
 *		 Flags to use when pulling records. None currently defined.
 *
 * REVISION HISTORY:
 * 02/04/06      - 30449    - DWG - Created for Get MCType Info View
 *
 **/

/* tm_Get_MCType_Info **************************************************************
** 
*********************************************************************************/

CREATE PROCEDURE [dbo].[tm_Get_MCType_Info] @sMCommSN varchar(12),
									@sMCommType varchar(20),
									@sFlags varchar(12)

AS

SET NOCOUNT ON

DECLARE @lMCommSN int

--Check to make sure we have either a SN or Type
IF (ISNUMERIC(@sMCommSN) = 0 OR ISNULL(@sMCommSN, '') = '') AND ISNULL(@sMCommType, '') = '' 
	BEGIN
		RAISERROR ('Mobile Communication SN or Type must be set', 16, 1)
		RETURN
	END

--if we have a SN, make sure it is numeric
IF (ISNUMERIC(@sMCommSN) = 0 AND ISNULL(@sMCommSN, '') > '') 
	BEGIN
		RAISERROR ('Mobile Communication SN must be numeric', 16, 1)
		RETURN
	END

--Convert the SN to int if we have a SN
IF ISNULL(@sMCommSN, '') > ''
	SET @lMCommSN = CONVERT(int, @sMCommSN)

IF @lMCommSN > 0
	SELECT SN MobileCommSNOut, MobileCommType MobileCommTypeOut, DisplayName
		FROM tblmobilecommtype (NOLOCK)
		WHERE SN = @lMCommSN
ELSE
	SELECT SN MobileCommSNOut, MobileCommType MobileCommTypeOut, DisplayName
		FROM tblmobilecommtype (NOLOCK)
		WHERE MobileCommType = @sMCommType

GO
GRANT EXECUTE ON  [dbo].[tm_Get_MCType_Info] TO [public]
GO
