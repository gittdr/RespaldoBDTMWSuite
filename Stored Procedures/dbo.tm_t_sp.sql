SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_t_sp]
	@sTranslate varchar(200) OUT,
	@iContext int,
	@sLanguage varchar(10)

AS

SET NOCOUNT ON 

DECLARE @matchcount int,
	@sOriginal varchar(200),
	@sKey varchar(10),
	@sText varchar(255)

IF @sLanguage = ''
  BEGIN
	SELECT @sLanguage = 'Language'
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
				WHERE English = @sOriginal 
					AND Language_id = @sLanguage)

	IF @matchcount > 1
	  BEGIN
		SET @sTranslate = 'zzz'		-- Initialize variable we're going to do SELECT into
		SET ROWCOUNT 1

		SELECT @sTranslate = ISNULL(Language, 'zzz')
		FROM language_text (NOLOCK)
		WHERE English = @sOriginal
		  AND Language_id = @sLanguage
		  AND Context = @iContext		

		IF @sTranslate = 'zzz'		--  Couldn't find match with context, so look without
		  BEGIN
			SET @sTranslate = @sOriginal
			SELECT @sTranslate = ISNULL(Language, '')
			FROM language_text (NOLOCK)
			WHERE English = @sOriginal
				AND Language_id = @sLanguage			
		  END
		SET ROWCOUNT 0
	  END

	ELSE IF  @matchcount = 0
       BEGIN
          SELECT @sTranslate = @sOriginal 
          SELECT @iContext = MAX(context) + 1 FROM language_text
          INSERT INTO language_text (english, language_id, language, context) VALUES (@sTranslate, @sLanguage, '', @iContext)
 	   END
	ELSE
		SELECT @sTranslate = ISNULL(Language, '') 
		FROM language_text (NOLOCK)
		WHERE English = @sOriginal 
			AND Language_id = @sLanguage

	IF @sTranslate = ''
		SELECT @sTranslate = @sOriginal
	
	IF UNICODE(@sTranslate) = 0
		SELECT @sTranslate = ''
  END

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[tm_t_sp] TO [public]
GO
