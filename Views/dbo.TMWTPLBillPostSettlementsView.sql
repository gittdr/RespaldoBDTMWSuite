SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWTPLBillPostSettlementsView] AS
/*******************************************************************************************************************
  Object Description:
  This view is for 3PL Post Settlement Queue.
  This returns 3PL Billing orders set up for passthrough or reconcile billing, and are now ready for invoice creation
  because settlements of their associated legs has occurred. Leveraged by 3PL Billing functionality in
  TMW Operations and 3PL AutoGen Windows Service.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  04/01/2016   Andy Vanek       PTS:         Initial Release
  05/16/2016   Suprakash Nandan PTS: 102052  Revised queries to join to active tables instead of stops table
********************************************************************************************************************/

   SELECT active.ord_hdrnumber
        , active.lgh_number
        , active.mov_number
     FROM TPLBillPostSettlementsActive active (NOLOCK)
GO
GRANT SELECT ON  [dbo].[TMWTPLBillPostSettlementsView] TO [public]
GO
