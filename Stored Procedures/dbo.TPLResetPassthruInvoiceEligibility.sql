SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[TPLResetPassthruInvoiceEligibility](
  @MoveNumber INT         = 0)
AS
BEGIN

/*******************************************************************************************************************
  Object Description:
  dbo.TPLResetPassthruInvoiceEligibility: Stored Procedure used to re-add orders on a given movement back into the
                                          TPLBillPostSettlementsActive table if eligible. The pyd_reconcile flag
                                          on paydetails will also be reset for all associated pay to the move.

  Revision History:
  Date         Name              Label/PTS      Description
  -----------  ----------------  -------------  ----------------------------------------
  11/06/17     AV                NSUITE-202713  Creation of stored proc
********************************************************************************************************************/

  SET NOCOUNT ON;

  BEGIN

    DECLARE @errMsg VARCHAR(255);

    -- Do not reset reconcile flag if invoices still exist
    IF EXISTS (SELECT 1 FROM invoiceheader ivh (NOLOCK)
                JOIN orderheader oh (NOLOCK) 
                  ON ivh.ord_hdrnumber = oh.ord_hdrnumber
                JOIN stops s (NOLOCK) 
                  ON oh.ord_hdrnumber = s.ord_hdrnumber 
                WHERE s.mov_number = @MoveNumber
              )
    BEGIN
      SET @errMsg = 'Invoices still exist for orders related to mov_number ' +  CAST(@MoveNumber AS varchar(16));
      RAISERROR (@errMsg, 11, 1);
      RETURN;
    END;

    -- Do not reset reconcile flag if move is not related to a 3PL Billing passthru/reconcile movement
    IF NOT EXISTS (SELECT 1 FROM orderheader oh (NOLOCK) 
                   JOIN stops s (NOLOCK) 
                     ON oh.ord_hdrnumber = s.ord_hdrnumber 
                   WHERE s.mov_number = @MoveNumber 
                     AND oh.ord_ratemode = '3PLINV'
                  )
       AND NOT EXISTS (SELECT 1 FROM legheader lh (NOLOCK) 
                       WHERE lh.mov_number = @MoveNumber 
                         AND lh.lgh_ratemode = '3PLINV'
                      )
    BEGIN
      SET @errMsg = 'No 3PLINV Rate Mode found for mov_number ' +  CAST(@MoveNumber AS varchar(16));
      RAISERROR (@errMsg, 11, 1);
      RETURN;
    END;

    BEGIN TRANSACTION;

    UPDATE pd
    SET pd.pyd_reconcile = 0
    FROM paydetail pd
    JOIN legheader lh ON pd.lgh_number = lh.lgh_number
    WHERE lh.mov_number = @MoveNumber

    IF @@ERROR <> 0
    BEGIN
	 ROLLBACK;

	 RAISERROR ('Error reseting reconcile flags on paydetails in database', 11, 1);
	 RETURN;
    END;

    COMMIT TRANSACTION;

    -- Call existing stored proc to re-add orders to the post-settlement queue
    EXEC TPLActiveObjectsQueue @MoveNumber, 'PAYHEADER'

  END;
END;

GO
GRANT EXECUTE ON  [dbo].[TPLResetPassthruInvoiceEligibility] TO [public]
GO
