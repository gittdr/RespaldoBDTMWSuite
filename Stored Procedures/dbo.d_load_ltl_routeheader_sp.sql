SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_load_ltl_routeheader_sp] (
                                             @name varchar(50),
                                             @number int
                                            )
AS

/**
 * 
 * NAME:
 * dbo.del_notes
 *
 * TYPE:
 * [StoredProcedure|Trigger|UDF] (in this case, StoredProcedure)
 *
 * DESCRIPTION:
 * This procedure deletes note data for the specified
 * registration.
 *
 * RETURNS:
 * [N/A] | [Values specified in the ?Return? statement]
 *
 * RESULT SETS: 
 * [None] | [See selection list] | [Actual list].
 *
 * PARAMETERS:
 * 001 - @name, varchar(50), input;
 *       This parameter indicates is the partial name of the ltl route header that is to be found
 * 002 - @number, int, input;
 *       This parameter indicates  the max number of matches to be returned
 * 
 * REVISION HISTORY:
 * 06/12/2006 ? PTS33344 - Jason Bauwin ? Original release
 *
 **/

DECLARE @match_rows int
if @number = 1 
	set rowcount 1 
else if @number <= 8 
	set rowcount 8
else if @number <= 16
	set rowcount 16
else if @number <= 24
	set rowcount 24
else
	set rowcount 8
if exists(SELECT lrh_name FROM ltl_routeheader WHERE lrh_name LIKE @name + '%')
	SELECT @match_rows = 1
else
	SELECT @match_rows = 0
if @match_rows > 0

	SELECT lrh_name, lrh_id
		FROM ltl_routeheader 
		WHERE lrh_name LIKE @name + '%'
		ORDER BY lrh_name 
else 
	SELECT lrh_name, lrh_id
		FROM ltl_routeheader 
		WHERE lrh_name = 'UNKNOWN' 
set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_load_ltl_routeheader_sp] TO [public]
GO
