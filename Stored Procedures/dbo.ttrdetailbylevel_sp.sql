SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/*
         MODIFICATION LOG
 created 12/6/00 dpete PTS8863

*/


CREATE  PROCEDURE       [dbo].[ttrdetailbylevel_sp] 
	@ttrnumber int,
	@ttrdterminusnbr smallint,
	@ttrdlevel varchar(6)
	
	
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
WHERE ttrdetail.ttr_number = @ttrnumber AND
	ttrd_terminusnbr = @ttrdterminusnbr AND
	ttrd_level = @ttrdlevel
ORDER BY ttrd_sequence

GO
GRANT EXECUTE ON  [dbo].[ttrdetailbylevel_sp] TO [public]
GO
