SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_label_def_Info] 	@LabelDef varchar(20), 
											@Abbr varchar(6), 
											@Code varchar(10), 
											@Name varchar(20), 
											@UserLabelName varchar(20),
											@Flags varchar(12)
AS

SET NOCOUNT ON

DECLARE @iMultiFind int, 
		@iMultiMatchError int,
		@iFlags int

IF ISNULL(@Flags, '') = '' SELECT @Flags = '0'
SELECT @iFlags = CONVERT(int, @Flags)

SELECT @iMultiFind = 0
if (@iFlags & 1) <> 0
	SELECT @iMultiFind = 1

SELECT @iMultiMatchError = 0
if (@iFlags & 2) <> 0
	SELECT @iMultiMatchError = 1

SELECT @LabelDef = ISNULL(@LabelDef, '')
SELECT @Abbr = ISNULL(@Abbr, '')
SELECT @Code = ISNULL(@Code, '')
SELECT @Name = ISNULL(@Name, '')
SELECT @UserLabelName = ISNULL(@UserLabelName, '')


IF @LabelDef = '' 
	--need at least label def, Return structure only
	BEGIN
		SELECT * FROM LabelFile (NOLOCK) WHERE 1 = 2
		RETURN
	END

--See if the Abbr is passed in, if so try to find it with that
if @Abbr > ''
	if @iMultiFind = 0 OR EXISTS (SELECT * FROM LabelFile (NOLOCK) WHERE labeldefinition = @LabelDef AND abbr = @Abbr)
		BEGIN
			SELECT * FROM LabelFile (NOLOCK) WHERE labeldefinition = @LabelDef AND abbr = @Abbr
			RETURN
		END

--See if the code is passed in, if so try to find it with that
if @Code > ''
	if @iMultiFind = 0 OR EXISTS (SELECT * FROM LabelFile (NOLOCK) WHERE labeldefinition = @LabelDef AND code = @Code)
		BEGIN
			SELECT * FROM LabelFile WHERE labeldefinition = @LabelDef AND code = CONVERT(int, @Code)
			RETURN
		END

--See if the code is passed in, if so try to find it with that
if @Name > ''
	if @iMultiFind = 0 OR EXISTS (SELECT * FROM LabelFile (NOLOCK) WHERE labeldefinition = @LabelDef AND name = @Name)
		BEGIN
			SELECT * FROM LabelFile WHERE labeldefinition = @LabelDef AND name = @Name
			RETURN
		END

--See if the code is passed in, if so try to find it with that
if @UserLabelName > ''
	if @iMultiFind = 0 OR EXISTS (SELECT * FROM LabelFile (NOLOCK) WHERE labeldefinition = @LabelDef AND userlabelname = @UserLabelName)
		BEGIN
			SELECT * FROM LabelFile WHERE labeldefinition = @LabelDef AND userlabelname = @UserLabelName
			RETURN
		END

--nothing found, return structure

if @iMultiMatchError = 1
	if (SELECT count(*) FROM LabelFile (NOLOCK) WHERE  labeldefinition = @LabelDef) > 1
			BEGIN
			RAISERROR ('(TMWERROR:999) Multiple matches found for label definition %s', 16, 1, @LabelDef)
			RETURN
			END
	else
		SELECT * FROM LabelFile (NOLOCK) WHERE labeldefinition = @LabelDef
else
	SELECT * FROM LabelFile (NOLOCK) WHERE labeldefinition = @LabelDef

GO
GRANT EXECUTE ON  [dbo].[tmail_label_def_Info] TO [public]
GO
