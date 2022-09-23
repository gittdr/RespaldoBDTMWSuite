SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[d_trlpool_summary_rpt_sp] 	(@from_date	datetime,
					 @to_date	datetime)
AS
/**
 * 
 * NAME:
 * dbo.d_trlpool_summary_rpt_sp 	
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Trailer Pool Accounting Summary Report for Bulkmatic
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/

SELECT	trl.pol_terminal, 
	l.name,
	trl.pol_pool, 
	convert(decimal(7,2),(count(pol_trailer_id)/convert(decimal(7,2),datediff(day,@from_date, @to_date) +1 ))),
	tch.tpc_maintenance,
	tch.tpc_interest, 
	tch.tpc_depreciation, 
	tch.tpc_rental, 
	tch.tpc_other
FROM	trailerpool_bulkm trl, labelfile l, trlpoolcharges_bulkm tch
WHERE 	trl.pol_arrival_date >= @from_date and
	trl.pol_arrival_date <= @to_date and
	l.labeldefinition = 'Terminal' and
	l.abbr = trl.pol_terminal and
	tch.tpc_trlpool_number = trl.pol_pool and
	(datediff(day,@to_date, tch.tpc_effective_date) >= 0 and 
	 datediff(day,@to_date, tch.tpc_effective_date) < 90)
	
GROUP BY	trl.pol_terminal, trl.pol_pool, l.name, tch.tpc_maintenance, tch.tpc_interest, 
		tch.tpc_depreciation, tch.tpc_rental, tch.tpc_other
ORDER BY trl.pol_terminal, trl.pol_pool

GO
GRANT EXECUTE ON  [dbo].[d_trlpool_summary_rpt_sp] TO [public]
GO
