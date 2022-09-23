SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[tm_GetExtendedErrMsg] (@DefaultErrorMsg VARCHAR(255) )

AS

SET NOCOUNT ON

  IF NOT EXISTS(SELECT SN 
				FROM tblErrMsgText (NOLOCK)
				WHERE RawText = @DefaultErrorMsg)
    BEGIN
      INSERT INTO tblErrMsgText (RawText) VALUES (@DefaultErrorMsg)
      SELECT @DefaultErrorMsg, @@IDENTITY
    END
  ELSE
     SELECT CASE WHEN ErrText IS NULL THEN @DefaultErrorMsg ELSE @DefaultErrorMsg + CHAR(13) + CHAR(10) + ErrText END, SN
	 --SELECT CASE WHEN ErrText IS NULL THEN ErrText END, SN
      FROM tblErrMsgText (NOLOCK)
	  WHERE RawText = @DefaultErrorMsg

GO
GRANT EXECUTE ON  [dbo].[tm_GetExtendedErrMsg] TO [public]
GO
