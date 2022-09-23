SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_tRev_sp]
	@sTranslate varchar(200) OUT,
	@sLanguage varchar(10)

AS

SET NOCOUNT ON

DECLARE @matchcount int,
	@sOriginal varchar(200),
	@sKey varchar(10),
	@sText varchar(255)

IF @sLanguage = ''
  BEGIN
	SELECT @sLanguage = 'english'
	EXEC dbo.GetRSValue_sp @sLanguage, @sText out
	SELECT @sLanguage = @sText
  END

SELECT @sOriginal = @sTranslate

IF ISNULL(@sLanguage, '') = '' OR ISNULL(@sLanguage, '') = 'english'
	SELECT @sTranslate = @sOriginal
ELSE
  BEGIN
	SELECT @matchcount = (SELECT COUNT(*) 
							FROM language_text (NOLOCK)
							WHERE Language = @sOriginal AND Language_id = @sLanguage)

	IF @matchcount > 1
	  BEGIN
		SET @sTranslate = 'zzz'		-- Initialize variable we're going to do SELECT into
		SET ROWCOUNT 1

		SELECT @sTranslate = ISNULL(English, 'zzz')
		FROM language_text (NOLOCK)
		WHERE English = @sOriginal AND Language_id = @sLanguage	

		IF @sTranslate = 'zzz'		--  Couldn't find match with context, so look without
		  BEGIN
			SET @sTranslate = @sOriginal
			SELECT @sTranslate = ISNULL(English, '')
			FROM language_text (NOLOCK)
			WHERE Language = @sOriginal AND Language_id = @sLanguage	
		  END

		SET ROWCOUNT 0
	  END

	ELSE
	  BEGIN

		SELECT @sTranslate = ISNULL(English, '') 
		FROM language_text (NOLOCK)
		WHERE Language = @sOriginal	AND Language_id = @sLanguage

	  END
	IF @sTranslate = ''
		SELECT @sTranslate = @sOriginal
	
	IF UNICODE(@sTranslate) = 0
		SELECT @sTranslate = ''
  END
GO
GRANT EXECUTE ON  [dbo].[tm_tRev_sp] TO [public]
GO
