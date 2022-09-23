SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GetTMFormID]	
					@sMobileCommSN	varchar (12), 
				  	@sMobileCommCode varchar(20), 
					@sMobileCommID varchar(50), 
					@sTMFormName varchar(30),
					@sTMFormDirection varchar(1),
					@sFlags varchar(12)
AS

SET NOCOUNT ON

DECLARE @lMobileCommSN int,
		@lFlags int

SET @lMobileCommSN =  CONVERT(int, @sMobileCommSN)
IF @lMobileCommSN = 0 AND ISNULL(@sMobileCommCode, '') <> ''
	SELECT @lMobileCommSN = ISNULL(SN, 0) 
	FROM tblMobileCommType (NOLOCK)
	WHERE MobileCommType = @sMobileCommCode

SET @lFlags = CONVERT(int, @sFlags)

SELECT ISNULL(FormID, 0) TMFormID
	FROM tblForms f (NOLOCK)
	INNER JOIN tblSelectedMobileComm s ON s.FormSN = f.SN
	WHERE f.NAME = CASE WHEN ISNULL(@sTMFormName, '') = '' THEN f.NAME ELSE @sTMFormName END
		AND f.FORWARD = CASE WHEN ISNULL(@sTMFormDirection, '') = '' THEN f.FORWARD ELSE 
			CASE WHEN ISNULL(@sTMFormDirection, '') = 'R' THEN 0 ELSE 1 END
		END
		AND s.MobileCommSN = CASE WHEN ISNULL(@lMobileCommSN, 0) = 0 THEN s.MobileCommSN ELSE @lMobileCommSN END
		AND s.ID = CASE WHEN ISNULL(@sMobileCommID, '') = '' THEN s.ID ELSE @sMobileCommID END
		AND s.Status = 'Current'
GO
GRANT EXECUTE ON  [dbo].[tm_GetTMFormID] TO [public]
GO
