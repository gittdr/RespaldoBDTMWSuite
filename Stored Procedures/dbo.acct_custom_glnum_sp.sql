SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[acct_custom_glnum_sp]
	@tts_co varchar(10),
	@gltype varchar(10),
	@colval1 varchar(20),
	@colval2 varchar(20),
	@colval3 varchar(20),
	@colval4 varchar(20),
	@colval5 varchar(20),
	@colval6 varchar(20),
	@colval7 varchar(20),
	@colval8 varchar(20),
	@colval9 varchar(20),
	@colval10 varchar(20)

AS

DECLARE @gl_rows integer,
	@seq1 integer,
	@seq2 integer,
	@seq3 integer,
	@seq4 integer,
	@seg1 varchar(30),
	@seg2 varchar(30),
	@seg3 varchar(30),
	@seg4 varchar(30)

SELECT sequence_id,
	gl_key1,
	gl_key2,
	gl_key3,
	gl_key4,
	gl_key5,
	gl_key6,
	gl_key7,
	gl_key8,
	gl_key9,
	gl_key10,
	seg1,
	seg2,
	seg3,
	seg4
INTO #temp_glnum
FROM acct_glnum
WHERE tts_co = @tts_co
AND acct_type = @gltype
AND (@colval1 like gl_key1 or gl_key1 is null or gl_key1 = '')
AND (@colval2 like gl_key2 or gl_key2 is null or gl_key2 = '')
AND (@colval3 like gl_key3 or gl_key3 is null or gl_key3 = '')
AND (@colval4 like gl_key4 or gl_key4 is null or gl_key4 = '')
AND (@colval5 like gl_key5 or gl_key5 is null or gl_key5 = '')
AND (@colval6 like gl_key6 or gl_key6 is null or gl_key6 = '')
AND (@colval7 like gl_key7 or gl_key7 is null or gl_key7 = '')
AND (@colval8 like gl_key8 or gl_key8 is null or gl_key8 = '')
AND (@colval9 like gl_key9 or gl_key9 is null or gl_key9 = '')
AND (@colval10 like gl_key10 or gl_key10 is null or gl_key10 = '')

IF (SELECT COUNT(*) FROM #temp_glnum) > 0
  	BEGIN
		SELECT @seq1 = (SELECT MAX(sequence_id) FROM #temp_glnum WHERE seg1 IS NOT null)
		IF @seq1 IS NOT null
			SELECT @seg1 = (SELECT seg1 FROM #temp_glnum WHERE sequence_id = @seq1)
		SELECT @seq2 = (SELECT MAX(sequence_id) FROM #temp_glnum WHERE seg2 IS NOT null)
		IF @seq1 IS NOT null
			SELECT @seg2 = (SELECT seg2 FROM #temp_glnum WHERE sequence_id = @seq2)
		SELECT @seq3 = (SELECT MAX(sequence_id) FROM #temp_glnum WHERE seg3 IS NOT null)
		IF @seq1 IS NOT null
			SELECT @seg3 = (SELECT seg3 FROM #temp_glnum WHERE sequence_id = @seq3)
		SELECT @seq4 = (SELECT MAX(sequence_id) FROM #temp_glnum WHERE seg4 IS NOT null)
		IF @seq1 IS NOT null
			SELECT @seg4 = (SELECT seg4 FROM #temp_glnum WHERE sequence_id = @seq4)
  	END	
	
SELECT @seg1, @seg2, @seg3, @seg4

GO
GRANT EXECUTE ON  [dbo].[acct_custom_glnum_sp] TO [public]
GO
