SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[TPLDeleteInvoicesForMovement](
  @MoveNumber INT         = 0)
AS
BEGIN

/*******************************************************************************************************************
  Object Description:
  dbo.TPLDeleteInvoicesForMovement: Stored Procedure used to delete all invoices associated to a movement that is
                                    part of 3PL Billing. This will only delete invoices when all invoices associated
                                    to the move are in HLD/HLA status, and the move is related to a 3PLINV ratemode

  Revision History:
  Date         Name              Label/PTS      Description
  -----------  ----------------  -------------  ----------------------------------------
  11/06/17     AV                NSUITE-202713  Creation of stored proc
********************************************************************************************************************/

  SET NOCOUNT ON;

  BEGIN

    DECLARE @errMsg VARCHAR(255);

    -- Only delete invoices when they are related to a 3PL Billing passthru/reconcile movement
    IF NOT EXISTS (SELECT 1 FROM orderheader oh (NOLOCK) 
                   JOIN stops s (NOLOCK) 
                     ON oh.ord_hdrnumber = s.ord_hdrnumber 
                   WHERE s.mov_number = @MoveNumber 
                     AND oh.ord_ratemode IN ('3PLINV', 'ALLOC')
                  )
       AND NOT EXISTS (SELECT 1 FROM legheader lh (NOLOCK) 
                       WHERE lh.mov_number = @MoveNumber 
                         AND lh.lgh_ratemode IN ('3PLINV', 'ALLOC')
                      )
    BEGIN
      SET @errMsg = 'No ALLOC/3PLINV Rate Mode found for mov_number ' +  CAST(@MoveNumber AS varchar(16));
      RAISERROR (@errMsg, 11, 1);
      RETURN;
    END;

    -- Only delete invoices when all invoices associated to mov_number are not beyond HLD/HLA status
    IF EXISTS (SELECT 1 FROM invoiceheader ivh (NOLOCK) 
               JOIN orderheader oh (NOLOCK) 
                 ON ivh.ord_hdrnumber = oh.ord_hdrnumber 
               JOIN stops s (NOLOCK) 
                 ON oh.ord_hdrnumber = s.ord_hdrnumber 
               WHERE s.mov_number = @MoveNumber
                 AND ivh.ivh_invoicestatus NOT IN ('HLD', 'HLA')
              )
    BEGIN
      SET @errMsg = '3PL Billing invoice has status beyond HLD/HLA for mov_number ' +  CAST(@MoveNumber AS varchar(16));
      RAISERROR (@errMsg, 11, 1);
      RETURN;
    END;

    DECLARE 
      @invoiceIds TABLE(ID INT NOT NULL IDENTITY
                        , ivh_hdrnumber     INT NOT NULL
                        , ord_hdrnumber     INT NOT NULL);

    -- Get invoice headers to delete
    INSERT INTO @invoiceIds
    (ivh_hdrnumber, ord_hdrnumber)
    SELECT DISTINCT ivh.ivh_hdrnumber, oh.ord_hdrnumber 
    FROM invoiceheader ivh (NOLOCK) 
    JOIN orderheader oh (NOLOCK) 
      ON ivh.ord_hdrnumber = oh.ord_hdrnumber 
    JOIN stops s (NOLOCK) 
      ON oh.ord_hdrnumber = s.ord_hdrnumber 
    WHERE s.mov_number = @MoveNumber

    IF NOT EXISTS (SELECT 1 FROM @invoiceIds)
    BEGIN
      SET @errMsg = 'No invoices found for mov_number ' +  CAST(@MoveNumber AS varchar(16));
      RAISERROR (@errMsg, 11, 1);
      RETURN;
    END;

    BEGIN TRANSACTION;

    -- Delete invoicedetails
    DELETE ivd
    FROM invoicedetail ivd
    JOIN @invoiceIds i
      ON ivd.ivh_hdrnumber = i.ivh_hdrnumber

    -- Delete invoice ref #'s
    DELETE rn
    FROM referencenumber rn
    JOIN @invoiceIds i
      ON rn.ref_tablekey = i.ivh_hdrnumber
    WHERE
      rn.ref_table = 'invoiceheader'

    -- Delete invoiceheaders
    DELETE ivh
    FROM invoiceheader ivh
    JOIN @invoiceIds i
      ON ivh.ivh_hdrnumber = i.ivh_hdrnumber

    -- Set orderheaders back to 3PLHLD invoice status for passthru scenarios
    IF EXISTS (SELECT 1 FROM orderheader oh (NOLOCK) 
                JOIN stops s (NOLOCK) 
                  ON oh.ord_hdrnumber = s.ord_hdrnumber 
                WHERE s.mov_number = @MoveNumber 
                  AND oh.ord_ratemode = '3PLINV'
              )
       OR EXISTS (SELECT 1 FROM legheader lh (NOLOCK) 
                  WHERE lh.mov_number = @MoveNumber 
                    AND lh.lgh_ratemode = '3PLINV'
                 )
    BEGIN
      UPDATE oh
      set oh.ord_invoicestatus = '3PLHLD'
      FROM orderheader oh
      JOIN @invoiceIds i
        ON oh.ord_hdrnumber = i.ord_hdrnumber
    END;

    IF @@ERROR <> 0
    BEGIN
	 ROLLBACK;

	 RAISERROR ('Error deleting invoices from database', 11, 1);
	 RETURN;
    END;

    COMMIT TRANSACTION;

  END;
END;

GO
GRANT EXECUTE ON  [dbo].[TPLDeleteInvoicesForMovement] TO [public]
GO
