SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_settlement_sheet_delayrejects] 
      (
       @payperiod DATETIME,
       @drv_id VARCHAR(8))
AS

/*
Created PTS25189 DPETE (DSK recommends passing pyh_payperiod from settle sheet rather than
      periodstart and periodend - report only has records for a single period)

*/


SELECT ord_number= IsNull(ord_number,''), pyd_transdate, pyd_quantity, pyd_description = IsNull(pyd_description,''), xsh_comment = isNull(xsh_comment,'')
FROM (Select distinct lgh_number From paydetail Where pyh_payperiod = @payperiod
       AND paydetail.asgn_type = 'DRV' AND paydetail.asgn_ID = @drv_id) #LEGS
     JOIN Excesshours on excesshours.lgh_number = #LEGS.lgh_number 
     LEFT JOIN Orderheader on orderheader.ord_hdrnumber = excesshours.ord_hdrnumber
     WHERE 
		 excesshours.xsh_acceptflag = 'R'

  
GO
GRANT EXECUTE ON  [dbo].[d_settlement_sheet_delayrejects] TO [public]
GO
