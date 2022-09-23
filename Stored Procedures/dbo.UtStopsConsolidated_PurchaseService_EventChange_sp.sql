SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtStopsConsolidated_PurchaseService_EventChange_sp]
(
  @inserted                 UtStopsConsolidated READONLY,
  @deleted                  UtStopsConsolidated READONLY,
  @PurchaseServiceNumbering CHAR(1)
)
AS

/*******************************************************************************************************************
  Revision History:
  Date         Name   Label/PTS      Description
  -----------  ----   ------------   ----------------------------------------
  10/11/2017   MIZ    NSUITE202576   Variables for cursor were in the wrong order (RE - Rechecked in to get a build record).

********************************************************************************************************************/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @OrdHdrNumber   INTEGER,
        @MovNumber      INTEGER,
        @TrlId          VARCHAR(13),
        @CmpId          VARCHAR(8),
        @VendorId       VARCHAR(8),
        @VendorPsCount  INTEGER,
        @CmdCode        VARCHAR(8),
        @RefNum         VARCHAR(30),
        @Count          INTEGER,
        @PshNumber      INTEGER,
        @PshId          VARCHAR(17),
        @StpNumber      INTEGER,
        @StpEvent       VARCHAR(6),
        @StpArrival     DATETIME,
        @StpDeparture   DATETIME

DECLARE STOPS_CURSOR CURSOR LOCAL FAST_FORWARD FOR
  SELECT  i.ord_hdrnumber,
          i.mov_number,
          COALESCE(i.trl_id, 'UNKNOWN'),
          COALESCE(tpp.tpr_id, 'UNKNOWN'),
          i.stp_event,
          i.stp_number,
          i.stp_arrivaldate,
          i.stp_departuredate
    FROM  @inserted i 
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
            INNER JOIN dbo.eventcodetable ect WITH(NOLOCK) ON ect.abbr = i.stp_event
            LEFT OUTER JOIN dbo.thirdpartyprofile tpp WITH(NOLOCK) ON tpp.tpr_id  = i.cmp_id
            LEFT OUTER JOIN dbo.company c WITH(NOLOCK) ON c.cmp_id = i.cmp_id AND c.cmp_service_location = 'Y' AND COALESCE(c.cmp_service_location_own , 'N') = 'N'
   WHERE  i.stp_event <> d.stp_event
     AND  COALESCE(ect.ect_purchase_service, 'N') = 'Y';

OPEN STOPS_CURSOR;
FETCH STOPS_CURSOR INTO @OrdHdrNumber, @MovNumber, @TrlId, @VendorId, @StpEvent, @StpNumber, @StpArrival, @StpDeparture;

WHILE @@FETCH_STATUS = 0
BEGIN
  IF @OrdHdrNumber = 0
    SELECT  @OrdHdrNumber = MAX(ord_hdrnumber)
      FROM  dbo.stops WITH(NOLOCK)
     WHERE  mov_number = @MovNumber
       AND  stp_type = 'PUP'

  IF @OrdHdrNumber = 0 AND @TrlId <> 'UNKNOWN'
    SELECT TOP 1
            @MovNumber = s.mov_number,
            @OrdHdrNumber = s.ord_hdrnumber
      FROM  dbo.assetassignment aa WITH(NOLOCK)
              INNER JOIN dbo.stops s WITH(NOLOCK) ON s.lgh_number = aa.lgh_number
              INNER JOIN dbo.event e WITH(NOLOCK) ON e.stp_number = s.stp_number AND e.evt_sequence = 1 AND e.evt_trailer1 = aa.asgn_id
     WHERE  aa.asgn_type = 'TRL'
       AND  aa.asgn_id = @TrlId
       AND  s.stp_type = 'DRP' 
       AND  s.stp_status = 'DNE'
       AND  s.ord_hdrnumber > 0
    ORDER BY aa.asgn_date DESC;

  IF @VendorId <> 'UNKNOWN'
  BEGIN
    SELECT  @VendorPsCount = COUNT(1)
      FROM  dbo.vendorpurchaseservices WITH(NOLOCK)
     WHERE  cmp_id = @VendorId;

    DECLARE CMD_CURSOR CURSOR LOCAL FAST_FORWARD FOR
      SELECT  DISTINCT f.cmd_code, f.fgt_refnum
        FROM  dbo.stops s WITH(NOLOCK)
                INNER JOIN dbo.freightdetail f WITH(NOLOCK) ON f.stp_number = s.stp_number
        WHERE  s.mov_number = @MovNumber
          AND  s.stp_type = 'PUP';

    OPEN cmd_cursor;
    FETCH NEXT FROM cmd_cursor INTO @CmdCode , @RefNum;

    SET @count = 1;

    WHILE @@FETCH_STATUS = 0
    BEGIN
      IF @VendorPsCount > 0 OR EXISTS(SELECT 1 FROM dbo.commoditypurchaseservices WHERE cmd_code = @CmdCode)
      BEGIN
        IF @Count = 1
        BEGIN
          SELECT  @PshNumber = COALESCE(MAX(psh_number) , 0)
            FROM  dbo.purchaseserviceheader WITH(NOLOCK)
           WHERE  ord_hdrnumber = @OrdHdrNumber;          

          IF @PurchaseServiceNumbering = '1'
          BEGIN
            SELECT  @PshId = CASE CHARINDEX('-' , psh_id , 1)
                               WHEN 0 THEN RIGHT(psh_id , 1)
                               ELSE SUBSTRING(psh_id , CHARINDEX('-' , psh_id , 1)+1 , LEN(psh_id))
                             END
              FROM  dbo.purchaseserviceheader WITH(NOLOCK)
             WHERE  psh_number = @PshNumber;

            SET @PshId = COALESCE(@PshId , '');

            IF LEN(@PshId) = 0
              SET @PshId = RTRIM(@OrdHdrNumber) + '-0001';
            ELSE
              IF LEN(@PshId) = 1
                SET @PshId = RTRIM(@OrdHdrNumber) + CHAR(ASCII(RIGHT(@PshId, 1)) + 1);
              ELSE
                IF CAST(@PshId AS INT) >= 9999
                  SET @PshId = RTRIM(@OrdHdrNumber)+'-9999';
                ELSE
                  SET @PshId = RTRIM(@OrdHdrNumber) + '-' + RIGHT('0000' + CAST(CAST(@PshId AS INT) + 1 AS VARCHAR(4)), 4);

          END
          ELSE
            IF @PshNumber > 0
              SELECT  @pshid = RTRIM(@OrdHdrnumber) + CHAR(ASCII(RIGHT(psh_id, 1)) + 1)
                FROM  dbo.purchaseserviceheader WITH(NOLOCK)
               WHERE  psh_number = @PshNumber;
            ELSE
              SET @PshId = RTRIM(@OrdHdrNumber) + 'A';

          EXECUTE @PshNumber = dbo.getsystemnumber 'PURCHSRV', '';
          
          INSERT INTO dbo.purchaseserviceheader
            (
              psh_id,
              psh_number,
              psh_status,
              psh_vendor_id,
              psh_drop_dt,
              psh_pickup_dt,
              psh_promised_dt,
              ord_hdrnumber,
              psh_service,
              stp_number,
              trl_id
            )
          VALUES
            (
              @PshId,
              @PshNumber,
              'HLD',
              @VendorId,
              @StpArrival,
              DATEADD(HOUR, 6, @StpDeparture),
              DATEADD(HOUR, 6, @StpDeparture),
              @OrdHdrNumber,
              @StpEvent,
              @StpNumber,
              @TrlId);

          SET @count = 2;
        END
      
        INSERT INTO dbo.purchaseservicedetail
          (
            psh_number,
            psd_type,
            psd_qty,
            psd_estrate,
            psd_heelqty,
            psd_rate,
            cmd_code,
            fgt_refnum
          )
          SELECT  @PshNumber,
                  psd_type,
                  1,
                  cps_estrate,
                  1,
                  0,
                  @CmdCode,
                  @RefNum
            FROM  dbo.commoditypurchaseservices
           WHERE  cmd_code = @CmdCode;
      END
      
      FETCH NEXT FROM cmd_cursor INTO @cmdcode , @RefNum;
    END

    CLOSE cmd_cursor;
    DEALLOCATE cmd_cursor;

    UPDATE  dbo.purchaseservicedetail
       SET  psd_estrate = vendorpurchaseservices.vps_estrate
      FROM  dbo.vendorpurchaseservices WITH(NOLOCK)
     WHERE  purchaseservicedetail.psh_number = @PshNumber
       AND  purchaseservicedetail.psd_type = vendorpurchaseservices.psd_type
       AND  vendorpurchaseservices.cmp_id = @VendorId;
            
    UPDATE  dbo.stops
       SET  psh_number = @PshNumber
     WHERE  stp_number = @StpNumber;
  END

  FETCH STOPS_CURSOR INTO @OrdHdrNumber, @MovNumber, @TrlId, @VendorId, @StpEvent, @StpNumber, @StpArrival, @StpDeparture;
END

CLOSE STOPS_CURSOR;
DEALLOCATE STOPS_CURSOR;
GO
GRANT EXECUTE ON  [dbo].[UtStopsConsolidated_PurchaseService_EventChange_sp] TO [public]
GO
