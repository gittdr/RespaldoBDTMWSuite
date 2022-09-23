SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[getinvcomplist_sp] 
	@group_nbr		int = NULL
AS

/**
 * 
 * NAME:
 * getinvcomplist_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns set of company information based on a supplied group number
 *
 * RETURNS: 	NONE
 *
 * RESULT SETS: Set company information based on the group number supplied to the procedure
 *
 * PARAMETERS:
 * @group_nbr	int	Group number for which to find relevant company's
 *
 *
 * REVISION HISTORY:
 * 10/6/2005.01 ? PTS29687 - Dan Hudec ? Created Procedure
 * 4/19/08 40260 Recodes Pauls change grant form all to exectute
 **/

	SELECT  a.cmp_id,
		a.cmp_name,
		a.cmp_address1,
		a.cmp_address2,
		a.cmp_city,
		a.cmp_zip,
		a.cmp_state,
		a.cmp_primaryphone,
		b.cmp_lastsiteplandate,
		b.cmp_recommordersize,
		b.cmp_group_nbr
	FROM	company a, compinvprofile b
	WHERE	a.cmp_id = b.cmp_id
	AND	b.cmp_group_nbr = ISNULL(@group_nbr, b.cmp_group_nbr)
	AND	a.cmp_id IN (SELECT DISTINCT cmp_id
			     FROM   tank
			     WHERE  tank_inuse = 'Y')
	
	RETURN
GO
GRANT EXECUTE ON  [dbo].[getinvcomplist_sp] TO [public]
GO
