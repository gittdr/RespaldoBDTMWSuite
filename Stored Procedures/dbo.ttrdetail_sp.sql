SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/*
         MODIFICATION LOG
 created 12/10/00 dpete PTS8863

*/


CREATE  PROCEDURE       [dbo].[ttrdetail_sp] 
	@ttrnumber int
	
	
AS

SELECT ttrd_number,
	ttrdetail.ttr_number,
	ttrd_terminusnbr,
	ttrd_level,
	ttrd_include_or_exclude,
	ttrd_sequence,
	ttrd_value,
	ttrd_intvalue
FROM ttrdetail
WHERE ttrdetail.ttr_number = @ttrnumber 


GO
GRANT EXECUTE ON  [dbo].[ttrdetail_sp] TO [public]
GO
