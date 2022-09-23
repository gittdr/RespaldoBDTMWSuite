SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_trlpool_charges_sp] 	(@trlpool	varchar(6),
					 @eff_date 	datetime)
AS

/*	Trailer Pool Charges Maintenance for Bulkmatic	*/

SELECT	* 
FROM	trlpoolcharges_bulkm, labelfile
WHERE	tpc_trlpool_number = @trlpool and
	tpc_effective_date = @eff_date and
	labeldefinition = 'TrlType1' and
	abbr = @trlpool

GO
GRANT EXECUTE ON  [dbo].[d_trlpool_charges_sp] TO [public]
GO
