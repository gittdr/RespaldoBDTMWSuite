SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_get_legheader_mpp_types_sp]
		@as_driver 	  varchar(8),
        @ai_lgh_number int
AS

/**
 *
 * NAME:
 * dbo.d_get_legheader_mpp_types_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 
 * RETURNS:
 *		The mpp_driver types from legheader if they exist, if not
 *              the mpp_driver types from manpowerprofile for lgh_driver1
 *
 * RESULT SETS:
 *
 * REVISION HISTORY:
 * Date ? 	PTS# - 	AuthorName ? Revision Description
 * 10/23/2007	36985	SLM	     Original Code
*/ 

declare @li_count int
SELECT @li_count = count(*)
	FROM legheader
WHERE (lgh_number = @ai_lgh_number
AND ((mpp_type1 = 'UNK' OR mpp_type1 IS NULL) AND
	 (mpp_type2 = 'UNK' OR mpp_type2 IS NULL) AND
	 (mpp_type3 = 'UNK' OR mpp_type3 IS NULL) AND
	 (mpp_type4 = 'UNK' OR mpp_type4 IS NULL) ))
--   WHERE lgh_driver2 = @as_driver

if @li_count > 0
Begin
	select mpp_id lgh_driver1, mpp_type1, mpp_type2, mpp_type3, mpp_type4
	from manpowerprofile
	where mpp_id = @as_driver
End
Else
Begin
	select lgh_driver1,mpp_type1, mpp_type2, mpp_type3, mpp_type4, lgh_number, mov_number
	from legheader
	WHERE lgh_driver1 = @as_driver
	AND lgh_number = @ai_lgh_number
End
GO
GRANT EXECUTE ON  [dbo].[d_get_legheader_mpp_types_sp] TO [public]
GO
