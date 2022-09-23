SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--	DAG 3/12/02 Removed NoWrap flag functionality and replaced with StopCommentNoWrap field.
--  DAG 12/26/01 Created stored proc: tmail_get_stop_comment2
--  MZ 11/30/00 Created stored proc (original)
CREATE PROCEDURE [dbo].[tmail_get_stop_comment] (@stp_number int)

AS

SET NOCOUNT ON 

DECLARE 	@comments char(255),
		@len smallint,		-- Length of the entire comment
		@pos smallint,		-- Current position in the comment
		@poscrlf smallint,
		@temp varchar(255), 
		@sn int

CREATE TABLE dbo.#t(	StopComment char(38), sn int identity)
SELECT @comments = ISNULL(stp_comment, '') 
FROM dbo.stops (NOLOCK)
WHERE stp_number = @stp_number
SELECT @len = DATALENGTH(RTRIM(@comments))

SELECT @pos = 1
WHILE @pos < @len
	BEGIN
		SELECT @poscrlf = 0
		SELECT @poscrlf = CHARINDEX(CHAR(13)+CHAR(10), SUBSTRING(@comments, @pos, 38))

		IF ISNULL(@poscrlf, 0) > 0
		  -- There was a crlf in this 38 char chunk, so handle it
			BEGIN
				INSERT dbo.#t (StopComment)
				VALUES (SUBSTRING (@comments, @pos, @poscrlf - 1))

				SELECT @pos = @pos + @poscrlf + 1	-- Increment to just past the crlf
			END
		ELSE
		  -- No crlf in this chunk, so just insert into #t
			BEGIN
				INSERT dbo.#t (StopComment)
				VALUES (SUBSTRING (@comments, @pos, 38))			

				SELECT @pos = @pos + 38
			END
	END

	SELECT StopComment, @Comments AS StopCommentNoWrap FROM dbo.#t
GO
GRANT EXECUTE ON  [dbo].[tmail_get_stop_comment] TO [public]
GO
