SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GetTMFormID2]	
					@sMobileCommSN	varchar (12), 
				  	@sMobileCommCode varchar(20), 
					@sMobileCommID varchar(50), 
					@sTMFormName varchar(30),
					@sTMFormDirection varchar(1),
					@sFlags varchar(12),
					@sTMFormID varchar(12)
AS

SET NOCOUNT ON

DECLARE @lMobileCommSN int,
		@lFlags int,
		@lTMFormID int

SET @lMobileCommSN =  CONVERT(int, @sMobileCommSN)
SET @lMobileCommSN = ISNULL(@lMobileCommSN,0)
IF @lMobileCommSN = 0 AND ISNULL(@sMobileCommCode, '') <> ''
	SELECT @lMobileCommSN = ISNULL(SN, 0) 
	FROM tblMobileCommType (NOLOCK)
	WHERE MobileCommType = @sMobileCommCode

SET @lFlags = CONVERT(int, @sFlags)

SET @lTMFormID = 0
IF ISNUMERIC(@sTMFormID) = 1
	SET @lTMFormID = CONVERT(int, @sTMFormID)

SELECT ISNULL(FormID, 0) TMFormID, ISNULL(ID, '') MCFormID
	FROM tblForms f (NOLOCK)
	INNER JOIN tblSelectedMobileComm s (NOLOCK) ON s.FormSN = f.SN
	WHERE f.NAME = CASE WHEN ISNULL(@sTMFormName, '') = '' THEN f.NAME ELSE @sTMFormName END
		AND f.FORWARD = CASE WHEN ISNULL(@sTMFormDirection, '') = '' THEN f.FORWARD ELSE 
			CASE WHEN ISNULL(@sTMFormDirection, '') = 'R' THEN 0 ELSE 1 END
		END
		AND s.MobileCommSN = CASE WHEN ISNULL(@lMobileCommSN, 0) = 0 THEN s.MobileCommSN ELSE @lMobileCommSN END
		AND s.ID = CASE WHEN ISNULL(@sMobileCommID, '') = '' THEN s.ID ELSE @sMobileCommID END
		AND f.FormID = CASE WHEN ISNULL(@lTMFormID, 0) = 0 THEN f.FormID ELSE @lTMFormID END
		AND s.Status = 'Current'

GO
GRANT EXECUTE ON  [dbo].[tm_GetTMFormID2] TO [public]
GO
