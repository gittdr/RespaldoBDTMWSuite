SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWOrdersCostDetailGenView] AS
/*******************************************************************************************************************
  Object Description:
  This view is for 3PL Cost Detail Generation Queue.
  It is responsible for finding orders and/or legs flagged with rate mode of 3PLINV or ALLOC, and in need of a
  recompute of their cost, pay, and invoice detail records. Leveraged by 3PL Billing functionality in
  TMW Operations and 3PL AutoGen Windows Service.

  Revision History:
  Date         Name             Label/PTS     Description
  -----------  ---------------  ----------    ----------------------------------------
  04/01/2016   AV               PTS:          Initial Release
  05/16/2016   Suprakash Nandan PTS: 102052   Revised queries to join to active tables instead of stops table
  10/31/2017   AV               NSUITE-202717 Filter out active table records that have already been attempted
********************************************************************************************************************/

   SELECT active.ord_hdrnumber
        , active.lgh_number
        , active.mov_number
     FROM TPLOrderCostDetailGenActive active (NOLOCK)
     WHERE ISNULL(active.Attempts, 0) = 0

GO
GRANT SELECT ON  [dbo].[TMWOrdersCostDetailGenView] TO [public]
GO
