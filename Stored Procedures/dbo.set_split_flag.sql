SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[set_split_flag] (@mov int)
AS 

DECLARE	@final_lgh_number int,
		@minlgh int

IF (select count(*) from legheader where mov_number = @mov) > 1
BEGIN
	--PTS31400 MBR 01/19/06 Rewrote the select for finding the @final_lgh_number.
	SELECT @final_lgh_number = MAX(lgh_number)
	  FROM legheader
	 WHERE mov_number = @mov AND
           lgh_number = (SELECT lgh_number
                           FROM stops
                          WHERE mov_number = legheader.mov_number AND
                                stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
                                                      FROM stops
                                                     WHERE mov_number = legheader.mov_number))
	
	/*SELECT	@final_lgh_number = MAX(lgh_number)
	  FROM	legheader
	 WHERE	mov_number = @mov AND
			lgh_enddate = (SELECT	MAX(lgh_enddate) 
							 FROM	legheader l, stops s
							WHERE	l.mov_number = @mov AND
									s.lgh_number = l.lgh_number AND
									s.stp_type = 'DRP')*/

	SELECT	@minlgh = 0

	SELECT	@minlgh = MIN(lgh_number)
	  FROM	legheader
	 WHERE	mov_number = @mov AND
			lgh_number > @minlgh AND
			lgh_number <> @final_lgh_number

	WHILE ISNULL(@minlgh, 0) > 0
	BEGIN
		UPDATE	legheader 
		   SET	lgh_split_flag = 'S'
		 WHERE	lgh_number = @minlgh AND
			ISNULL(lgh_split_flag, 'X') <> 'S'  -- 29339, NULL does not compare with a literal, added ISNULL check

		SELECT	@minlgh = MIN(lgh_number)
		  FROM	legheader
		 WHERE	mov_number = @mov AND
				lgh_number > @minlgh AND
				lgh_number <> @final_lgh_number
	END

	UPDATE	legheader 
	   SET	lgh_split_flag = 'F'
	 WHERE	lgh_number = @final_lgh_number AND
			ISNULL(lgh_split_flag,'X') <> 'F'

END
ELSE
BEGIN
	UPDATE	legheader 
	   SET	lgh_split_flag = 'N'
	 WHERE	mov_number = @mov AND
			ISNULL(lgh_split_flag,'X') <> 'N'
END

GO
GRANT EXECUTE ON  [dbo].[set_split_flag] TO [public]
GO
