SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[intercompany_ico_mov_number_top_fn]	(
	@mov_number int
)
RETURNS int
BEGIN

	--Given passed in trip number, return corresponding top level trip on ico trip
	DECLARE @result AS int
   
	DECLARE	@mov_number_next_parent int
	
	
	--find highlest level correspding trip 
	SELECT @mov_number_next_parent = @mov_number
	
	WHILE @mov_number_next_parent > 0 BEGIN
	
		SELECT  @mov_number_next_parent = 0
		
		SELECT	@mov_number_next_parent = stp_p.mov_number
		FROM	legheader lgh_c with (NOLOCK)		--PTS62031 added with no lock
				inner join stops stp_c with (NOLOCK) on lgh_c.lgh_number = stp_c.lgh_number
				INNER JOIN stops stp_p with (NOLOCK) on stp_p.stp_number = stp_c.stp_ico_stp_number_parent
		WHERE	lgh_c.mov_number = @mov_number
	
		IF ISNULL(@mov_number_next_parent, 0) > 0 BEGIN
			SELECT @mov_number = @mov_number_next_parent
		END
	END

	RETURN @mov_number
	
   
END
GO
GRANT EXECUTE ON  [dbo].[intercompany_ico_mov_number_top_fn] TO [public]
GO
