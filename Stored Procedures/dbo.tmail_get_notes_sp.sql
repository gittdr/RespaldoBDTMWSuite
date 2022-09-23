SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_notes_sp] @notetable varchar(18), @tablekey varchar(18) 

AS

BEGIN

SET NOCOUNT ON 

DECLARE 	@comments CHAR(255),
		@len smallint,
		@pos smallint,
		@seq smallint,
		@NoteNum int,
		@LastNoteNum int,
		@poscrlf smallint, 
		@temp varchar(255)

CREATE TABLE #t(
	notes char(38))

SELECT @seq = min(not_sequence)
FROM	notes (NOLOCK)
WHERE ntb_table = @notetable AND 
	nre_tablekey = @tablekey

SELECT	@NoteNum = min(not_number)
FROM	notes (NOLOCK)
WHERE 	ntb_table = @notetable AND 
	nre_tablekey = @tablekey AND
	not_sequence = @seq

WHILE ISNULL(@NoteNum, 0) > 0
	BEGIN
	SELECT @comments = not_text FROM Notes WHERE not_number = @NoteNum
	SELECT @len = datalength(RTRIM(@comments))

	SELECT @pos = 1
	WHILE @pos < @len
		BEGIN
		SELECT @poscrlf = 0
		SELECT @poscrlf = CHARINDEX(CHAR(13)+CHAR(10), substring(@comments, @pos, 38))
		IF ISNULL(@poscrlf, 0) > 0
			BEGIN
			INSERT #t
			VALUES (substring (@comments, @pos, @poscrlf - 1))
			SELECT @pos = @pos + @poscrlf + 1
			END
		ELSE
			BEGIN
			INSERT #t 
			VALUES (substring ( @comments, @pos, 38 ))			
			SELECT @pos = @pos + 38
			END
		END

	SELECT @LastNoteNum = @NoteNum 
	SELECT @NoteNum = 0
	SELECT	@NoteNum = min(not_number)
	FROM	notes (NOLOCK)
	WHERE 	ntb_table = @notetable AND 
		nre_tablekey = @tablekey AND
		not_sequence = @seq AND
		not_number > @LastNoteNum 

	IF IsNull(@NoteNum, 0) = 0
		BEGIN
		SELECT @seq = min(not_sequence)
		FROM	notes (NOLOCK)
		WHERE ntb_table = @notetable AND 
			nre_tablekey = @tablekey AND
			not_sequence > @seq

		SELECT	@NoteNum = min(not_number)
		FROM	notes (NOLOCK)
		WHERE 	ntb_table = @notetable AND 
			nre_tablekey = @tablekey AND
			not_sequence = @seq
		END
	END

SELECT @seq = 0
SELECT @seq = COUNT(*) FROM #t
IF @Seq = 0
	INSERT INTO #t VALUES ('')

SELECT * 
FROM #t

DROP TABLE #t

END    /* end of the proc    */

GO
GRANT EXECUTE ON  [dbo].[tmail_get_notes_sp] TO [public]
GO
