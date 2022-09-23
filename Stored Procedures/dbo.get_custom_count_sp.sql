SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[get_custom_count_sp] (@pl_lgh_number int , @pdc_count decimal(19,4) output, @ps_count_unit varchar(6) output) 
as

Select @pdc_count = 0, @ps_count_unit = 'PCS'
/*
Select @pdc_count = isnull(SUM(stp_count),0),
		@ps_count_unit = IsNull(min(stp_countunit), 'PCS')
From stops 
Where lgh_number = @pl_lgh_number and stp_event in ('LLD', 'XDL')
*/
--	Per Bryan Brinegar at C.A.R. Transport
SELECT @pdc_count = isnull(SUM(orh.ord_totalpieces), 0),
		@ps_count_unit = IsNull(min(orh.ord_totalcountunits), 'PCS')
FROM legheader lgh INNER JOIN orderheader orh ON orh.mov_number = lgh.mov_number AND 
	(lgh.lgh_startdate BETWEEN orh.ord_startdate AND orh.ord_completiondate OR orh.ord_startdate BETWEEN lgh.lgh_startdate AND lgh.lgh_enddate) 
WHERE lgh.lgh_number = @pl_lgh_number

GO
GRANT EXECUTE ON  [dbo].[get_custom_count_sp] TO [public]
GO
