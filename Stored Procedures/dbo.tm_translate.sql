SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_translate]
	@sSource varchar(255),
	@sLanguage varchar(10),
	@sContext varchar(5) = '0'

AS
SET NOCOUNT ON

DECLARE @sTranslation varchar(255),
	 @iContext int 

select @sSource=rtrim(ltrim(@sSource))
select @iContext=isnull(convert(int,@sContext),0)

SELECT @sTranslation = ISNULL(Language, '') 
FROM language_text (NOLOCK) 
WHERE Language_id=@sLanguage 
   and English = @sSource
   and isnull(context,0) = @iContext

IF @@ROWCOUNT=0
BEGIN
	SELECT @sTranslation=@sSource

	INSERT INTO language_text (english, language_id, language, context) 
            VALUES (@sSource, @sLanguage, @sTranslation, @iContext)
END

SELECT @sTranslation Translation

GO
GRANT EXECUTE ON  [dbo].[tm_translate] TO [public]
GO
