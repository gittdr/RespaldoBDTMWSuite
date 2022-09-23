SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[TPLActiveObjectsQueue](
  @MoveNumber INT         = 0
, @Caller     VARCHAR(10) = 'UMPP')
AS
BEGIN

/*******************************************************************************************************************
  Object Description:
  dbo.TPLActiveObjectsQueue: Stored Procedure used to gather active objects from TMW

  Revision History:
  Date         Name              Label/PTS      Description
  -----------  ----------------  -------------  ----------------------------------------
  05/06/16     Suprakash Nandan  PTS:102052     Initial Version Created
  07/20/16     Suprakash Nandan  PTS:104278     Added (NOLOCK) after paydetail and payheader tables
  01/09/17     Eric Blinn        NSUITE-200626  Modified for performance and remove FFG code
  04/20/17     AV                NSUITE-201159  Widen pyh_paystatus to include XFR, prevent records
                                                simultaneously existing in CostDetailGen and PostStl active tables
  10/03/17     Eric T. Hammel    NSUITE-201942  Port (NSUITE-201895) of the removal of logic that filtered out 
                                                CostDetailGen records for trips that had existing pay/invoice/cost 
                                                details
  11/02/17     AV                NSUITE-202717  Add consideration for new Attempted field on active table
  10/03/17     Eric T. Hammel    NSUITE-201942  Port (NSUITE-201895) of the removal of logic that filtered out 
                                                CostDetailGen records for trips that had existing pay/invoice/cost 
                                                details
  11/01/17     Vince Herman      NSUITE-202718  Don't add records if the Billto/Carrier point to a CPU record with 
                                                ExcludeFromInvoice set
  03/12/18	   Mike Kunz         NSUITE-203624  Consideration for ActiveDate, Attempts, and LastAttemptDate columns 
                                                for TPLOrderCostDetailGenActive table
********************************************************************************************************************/

  SET NOCOUNT ON;

  BEGIN

    DECLARE 
      @TPLOrderCostDetailGenActive TABLE(ID                INT NOT NULL IDENTITY
                                       , mov_number        INT NOT NULL
                                       , ord_hdrnumber     INT NOT NULL
                                       , lgh_number        INT NOT NULL
                                       , hasExistingRecord BIT NOT NULL)

    DECLARE 
      @TPLBillPostSettlementsActive TABLE(ID            INT NOT NULL IDENTITY
                                        , mov_number    INT NOT NULL
                                        , ord_hdrnumber INT NOT NULL
                                        , lgh_number    INT NOT NULL
                                        , ord_ratemode  VARCHAR(6) NOT NULL
                                        , lgh_ratemode  VARCHAR(6) NOT NULL);

    DECLARE 
      @TPLBillPostSettlementsActive2 TABLE(ID            INT NOT NULL IDENTITY
                                         , mov_number    INT NOT NULL
                                         , ord_hdrnumber INT NOT NULL
                                         , lgh_number    INT NOT NULL
                                         , ord_ratemode  VARCHAR(6) NOT NULL
                                         , lgh_ratemode  VARCHAR(6) NOT NULL);

    DECLARE 
      @id INT
    , @max INT
    , @mov_number INT
    , @ord_hdrnumber INT
    , @lgh_number INT;

    INSERT
      @TPLOrderCostDetailGenActive
    SELECT DISTINCT 
      s.mov_number
    , s.ord_hdrnumber
    , s.lgh_number
    , (CASE WHEN x.mov_number IS NULL THEN 0 ELSE 1 END) AS hasExistingRecord
    FROM 
      stops s
        INNER JOIN
      orderheader o ON s.ord_hdrnumber = o.ord_hdrnumber
        INNER JOIN
      legheader l ON s.lgh_number = l.lgh_number
        INNER JOIN
      CompanyContractMgmt ccm ON o.ord_billto = ccm.cmp_id AND ccm.AllocationEligible = 1
        LEFT JOIN 
      TPLOrderCostDetailGenActive x ON x.mov_number = s.mov_number AND x.ord_hdrnumber = s.ord_hdrnumber AND x.lgh_number = s.lgh_number
    WHERE
      s.mov_number = @MoveNumber
        AND
      o.ord_status <> 'CAN'
        AND
      o.ord_invoicestatus IN('PND' , 'AVL' , '3PLHLD')
        AND
      (o.ord_ratemode IN('3PLINV' , 'ALLOC') OR l.lgh_ratemode IN('3PLINV' , 'ALLOC'))



   /*
   #1 WHEN Caller = UMPP
   Populate TPLOrderCostDetailGenActive (mov_number, ord_hdrnumber, lgh_number PKEY, orderheader.last_updatedate ->OrderLastUpdated, legheader.lgh_updatedon->LegLastUpdated)
   WHEN ord_invoicestatus = PND
   AND (orderheader.ord_ratemode IN ('3PLINV', 'ALLOC') OR legheader.lgh_ratemode IN ('3PLINV', 'ALLOC'))
   AND orderheader.ord_status  <> 'CAN'
   */

    IF @Caller = 'UMPP'
    BEGIN
       INSERT INTO TPLOrderCostDetailGenActive(
        mov_number
      , ord_hdrnumber
      , lgh_number
      , ActiveDate
      , Attempts
      , LastAttemptDate)
      SELECT 
        a.mov_number
      , a.ord_hdrnumber
      , a.lgh_number
      , GETDATE()
      , 0
      , NULL
      FROM 
        @TPLOrderCostDetailGenActive a
	  WHERE
         a.hasExistingRecord = 0
	  
       -- Reset prior processing attempts
       UPDATE a
       SET
         a.ActiveDate = GETDATE(),
         a.Attempts = 0,
         a.LastAttemptDate = NULL
       FROM TPLOrderCostDetailGenActive a
         INNER JOIN
       @TPLOrderCostDetailGenActive b on a.mov_number = b.mov_number AND a.lgh_number = b.lgh_number AND a.ord_hdrnumber = b.ord_hdrnumber
	  WHERE
         b.hasExistingRecord = 1
	    
        
       DELETE 
         a
       FROM 
         TPLOrderCostDetailGenActive a
           INNER JOIN
         @TPLOrderCostDetailGenActive b ON a.ord_hdrnumber = b.ord_hdrnumber AND a.mov_number <> b.mov_number;
       
      --Delete any Orders that might have changed status since last update
      DELETE @TPLOrderCostDetailGenActive;
      INSERT @TPLOrderCostDetailGenActive(
        mov_number
      , ord_hdrnumber
      , lgh_number
      , hasExistingRecord)
      SELECT DISTINCT 
        active.mov_number
      , active.ord_hdrnumber
      , active.lgh_number
      , 1
      FROM 
        TPLOrderCostDetailGenActive active
          INNER JOIN
        orderheader o ON active.ord_hdrnumber = o.ord_hdrnumber 
          LEFT OUTER JOIN
        legheader l ON active.lgh_number = l.lgh_number
      WHERE
        o.ord_invoicestatus NOT IN('PND' , 'AVL' , '3PLHLD') 
          OR 
        o.ord_ratemode NOT IN('3PLINV' , 'ALLOC') AND ISNULL(l.lgh_ratemode , o.ord_ratemode) NOT IN('3PLINV' , 'ALLOC')
          OR
        o.ord_status = 'CAN';
      BEGIN TRY
        DELETE TPLOrderCostDetailGenActive
        FROM @TPLOrderCostDetailGenActive t
        WHERE 
          TPLOrderCostDetailGenActive.mov_number = t.mov_number
          AND
          TPLOrderCostDetailGenActive.ord_hdrnumber = t.ord_hdrnumber
          AND
          TPLOrderCostDetailGenActive.lgh_number = t.lgh_number;
      END TRY
      BEGIN CATCH
      -- Do nothing
      END CATCH;
    END;

   /*
   #2 WHEN Caller = UMPP OR PAYHEADER
   Populate TPLBillPostSettlementsActive (mov_number, ord_hdrnumber, lgh_number PKEY)
   WHEN assetassignment.asgn_status ALL = 'CMP'
   */

  INSERT
    @TPLBillPostSettlementsActive2(
      mov_number
    , ord_hdrnumber
    , lgh_number
    , ord_ratemode
    , lgh_ratemode)
  SELECT DISTINCT 
    s.mov_number
  , s.ord_hdrnumber
  , s.lgh_number
  , ISNULL(oh.ord_ratemode , 'UNK') ord_ratemode
  , ISNULL(lh.lgh_ratemode , 'UNK') lgh_ratemode
  FROM 
    stops s WITH (NOLOCK) 
      INNER JOIN
    paydetail pd WITH (NOLOCK) ON s.lgh_number = pd.lgh_number
      INNER JOIN
    payheader ph WITH (NOLOCK) ON pd.pyh_number = ph.pyh_pyhnumber
      LEFT OUTER JOIN
    orderheader oh WITH (NOLOCK) ON s.ord_hdrnumber = oh.ord_hdrnumber
      LEFT OUTER JOIN
    legheader lh WITH (NOLOCK) ON s.lgh_number = lh.lgh_number
  WHERE
    s.mov_number = @MoveNumber
        AND
    pd.pyd_reconcile <> 1
        AND
    ph.pyh_paystatus IN ('REL', 'XFR')


    IF @Caller IN ('UMPP', 'PAYHEADER')
    BEGIN
      INSERT INTO @TPLBillPostSettlementsActive(
        mov_number
      , ord_hdrnumber
      , lgh_number
      , ord_ratemode
      , lgh_ratemode)
      SELECT DISTINCT 
        preactive.mov_number
      , preactive.ord_hdrnumber
      , preactive.lgh_number
      , preactive.ord_ratemode
      , preactive.lgh_ratemode
      FROM
        (
        -- Get all non-CPU legs that have closed settlements and no invoice header (passthrough)
        SELECT DISTINCT 
          a.mov_number
        , a.ord_hdrnumber
        , a.lgh_number
        , ISNULL(a.ord_ratemode , 'UNK') ord_ratemode
        , ISNULL(a.lgh_ratemode , 'UNK') lgh_ratemode
        FROM 
          @TPLBillPostSettlementsActive2 a
        WHERE
          NOT EXISTS(SELECT TOP 1 1 FROM invoiceheader ivh WHERE ivh.ord_hdrnumber = a.ord_hdrnumber)
        UNION
        -- Get all non-CPU legs that have been settled, and have an invoice header (reconcile)
        SELECT DISTINCT 
          a.mov_number
        , a.ord_hdrnumber
        , a.lgh_number
        , ISNULL(a.ord_ratemode , 'UNK') ord_ratemode
        , ISNULL(a.lgh_ratemode , 'UNK') lgh_ratemode
        FROM 
          @TPLBillPostSettlementsActive2 a
        WHERE
          EXISTS (SELECT TOP 1 1 FROM invoiceheader ivh WHERE ivh.ord_hdrnumber = a.ord_hdrnumber) 
            AND 
          EXISTS 
            (SELECT TOP 1 
               1 
             FROM 
               paydetail pd(NOLOCK)
                JOIN
              payheader ph(NOLOCK) ON pd.pyh_number = ph.pyh_pyhnumber
             WHERE
			   pd.lgh_number = a.lgh_number
			   AND
               pd.pyd_updatedon > (SELECT MAX(last_updatedate) FROM invoiceheader WHERE invoiceheader.ord_hdrnumber = a.ord_hdrnumber)
            )
        UNION
        -- Get all CPU legs that do not require settlements first, and no invoice header (passthrough)
        SELECT DISTINCT 
          s.mov_number
        , s.ord_hdrnumber
        , s.lgh_number
        , ISNULL(o.ord_ratemode , 'UNK')  ord_ratemode
        , ISNULL(lh.lgh_ratemode , 'UNK') lgh_ratemode
        FROM 
          stops s
            INNER JOIN
          assetassignment a ON s.lgh_number = a.lgh_number AND a.asgn_type = 'CAR' AND a.asgn_status = 'CMP'
            INNER JOIN
          orderheader o ON s.ord_hdrnumber = o.ord_hdrnumber 
            LEFT JOIN
          legheader lh ON s.lgh_number = lh.lgh_number
            INNER JOIN
          branch_assignedtype bat ON bat.bat_type = 'CPUCARRIER' AND bat.bat_value = a.asgn_id AND bat.bat_billto = o.ord_billto
        WHERE
          s.mov_number = @MoveNumber
            AND 
          NOT EXISTS(SELECT TOP 1 1 FROM invoiceheader WHERE invoiceheader.ord_hdrnumber = s.ord_hdrnumber)
      ) preactive
      WHERE NOT EXISTS
        (SELECT TOP 1 
           1
         FROM 
           TPLBillPostSettlementsActive x(NOLOCK)
         WHERE
           x.mov_number = preactive.mov_number
           AND
           x.ord_hdrnumber = preactive.ord_hdrnumber
           AND
           x.lgh_number = preactive.lgh_number
      )
            AND NOT EXISTS
        (SELECT TOP 1 
           1
         FROM 
           assetassignment a
         WHERE
           a.lgh_number = preactive.lgh_number
           AND
           a.asgn_status <> 'CMP'
      )
            --vjh NSUITE-202718 Possible code solution
            AND NOT EXISTS
      (
          SELECT TOP 1 1
          FROM assetassignment a
               JOIN orderheader o ON preactive.ord_hdrnumber = o.ord_hdrnumber
               JOIN branch_assignedtype bat ON bat.bat_type = 'CPUCARRIER'
                                               AND bat.bat_value = a.asgn_id
                                               AND bat.bat_billto = o.ord_billto
          WHERE a.lgh_number = preactive.lgh_number
                AND bat.bat_ExcludeFromInvoice = 'Y'
      );

      -- Remove non-3PLINV moves from potential active table entries
      DELETE 
        @TPLBillPostSettlementsActive
      WHERE 
        mov_number IN (
          SELECT DISTINCT 
            mov_number 
          FROM 
            @TPLBillPostSettlementsActive t1
          WHERE 
            NOT EXISTS
             (SELECT TOP 1 
                1
              FROM 
                @TPLBillPostSettlementsActive t2
              WHERE
                t2.mov_number = t1.mov_number
                AND (
                t2.ord_ratemode = '3PLINV'
                OR
                t2.lgh_ratemode = '3PLINV')
             )
        );
         
      INSERT INTO TPLBillPostSettlementsActive(
        mov_number
      , ord_hdrnumber
      , lgh_number
	  , ActiveDate
	  , Attempts
	  , LastAttemptDate)
      SELECT 
        a.mov_number
      , a.ord_hdrnumber
      , a.lgh_number
	  , GETDATE()
	  , 0
	  , NULL
      FROM 
        @TPLBillPostSettlementsActive a
      WHERE
		NOT EXISTS(
		  SELECT 1 
		    FROM TPLBillPostSettlementsActive b 
		    WHERE a.mov_number = b.mov_number 
			 AND a.ord_hdrnumber = b.ord_hdrnumber 
			 AND a.lgh_number = b.lgh_number
	     );

	  -- Reset prior processing attempts
       UPDATE a
       SET
         a.ActiveDate = GETDATE(),
         a.Attempts = 0,
         a.LastAttemptDate = NULL
       FROM TPLBillPostSettlementsActive a
         INNER JOIN
       @TPLBillPostSettlementsActive b on a.mov_number = b.mov_number AND a.lgh_number = b.lgh_number AND a.ord_hdrnumber = b.ord_hdrnumber
	  WHERE
         b.mov_number IS NOT NULL
		 
        
       DELETE 
         a
       FROM 
         TPLBillPostSettlementsActive a
           INNER JOIN
         @TPLBillPostSettlementsActive b ON a.ord_hdrnumber = b.ord_hdrnumber AND a.mov_number <> b.mov_number;

      -- If an active table record exists in both TPL tables,
      -- it should be removed from CostDetailGenActive because
      -- the PostSettlementsActive service is a superset of that
      -- functionality, and will eliminate needless double processing
      DELETE cdg
      FROM TPLOrderCostDetailGenActive cdg
      JOIN TPLBillPostSettlementsActive ps
        ON ps.lgh_number = cdg.lgh_number
          AND ps.ord_hdrnumber = cdg.ord_hdrnumber
          AND ps.mov_number = cdg.mov_number


    END;
  END;
END;

GO
GRANT EXECUTE ON  [dbo].[TPLActiveObjectsQueue] TO [public]
GO
