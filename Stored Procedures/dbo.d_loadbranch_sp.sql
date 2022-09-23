SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[d_loadbranch_sp] (
			@p_brn	varchar(40),
			@p_number int)
as

/**
 * 
 * NAME:
 * dbo.d_loadbranch_sp
 *
 * TYPE:
 * [StoredProcedure|
 *
 * DESCRIPTION:
 * for dw d_loadbranch_for_dddw
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * dw result set
 *
 * PARAMETERS:
 * 			@p_brn	varchar(40)	Branch ID Entered by User
 *			@p_number int		Number of rows to return
 *
 * 
 * REVISION HISTORY:
 * 08/12/05	DPH	PTS# 29334
 *
 **/

if @p_number = 1 
	set rowcount 1 
else if @p_number <= 8 
	set rowcount 8
else if @p_number <= 16
	set rowcount 16
else if @p_number <= 24
	set rowcount 24
else
	set rowcount 8

if exists ( SELECT brn_id FROM branch WHERE brn_id >= @p_brn	) 
	SELECT  brn_name , brn_id
		FROM branch 
		WHERE brn_id >= @p_brn	
		ORDER BY brn_id
else 
	SELECT 'UNKNOWN','UNKNOWN'

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadbranch_sp] TO [public]
GO
