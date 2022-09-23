SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[getdropweightforleg_sp] (@pl_lgh int , @pdec_wgt decimal(19,4) output) as
  select 	@pdec_wgt = sum(fgt_weight) 
	from 	freightdetail,stops  
	where	stops.ord_hdrnumber > 0 and 
			stops.stp_number= freightdetail.stp_number and 
			stp_type = 'DRP' and 
			stops.lgh_number = @pl_lgh

GO
GRANT EXECUTE ON  [dbo].[getdropweightforleg_sp] TO [public]
GO
