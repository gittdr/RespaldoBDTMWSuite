SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[field_popnotes_check_sp] (
	@table	VARCHAR(18),
	@data	VARCHAR(18))
AS

DECLARE	@note_count		INTEGER,
		@urgent_code	CHAR(1),
		@grace			INTEGER

SELECT	@grace = ISNULL(gi_integer1, 0)
  FROM	generalinfo
 WHERE	gi_name = 'showexpirednotesgrace'

SELECT	@note_count = 0
SELECT	@urgent_code = ''

SELECT	@urgent_code = MIN(ISNULL(not_urgent, 'N'))
  FROM	notes
 WHERE	ntb_table = @table AND
		nre_tablekey = @data AND
		GETDATE() <= ISNULL(DATEADD(dd, @grace, not_expires), GETDATE())

IF @urgent_code = 'A' 
BEGIN
	SELECT @note_count = -1
END
ELSE
BEGIN 
	IF @urgent_code = 'N'
	BEGIN
		SELECT @note_count = 1
	END
	ELSE IF @note_count = 0 
		SELECT @note_count = 0
END

RETURN	@note_count
GO
GRANT EXECUTE ON  [dbo].[field_popnotes_check_sp] TO [public]
GO
