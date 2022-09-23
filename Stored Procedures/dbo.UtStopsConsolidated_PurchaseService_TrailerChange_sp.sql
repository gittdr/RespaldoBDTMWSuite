SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtStopsConsolidated_PurchaseService_TrailerChange_sp]
(
  @inserted UtStopsConsolidated READONLY,
  @deleted  UtStopsConsolidated READONLY
)
AS

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @PshNumber      INTEGER,
        @TrlId          VARCHAR(13),
        @MovNumber      INTEGER,
        @OrdHdrNumber   INTEGER,
        @TrlPshNumber   INTEGER,
        @TrlPshId       VARCHAR(17),
        @CmdCode        VARCHAR(8),
        @RefNum         VARCHAR(30);

DECLARE STOPS_CURSOR CURSOR LOCAL FAST_FORWARD FOR
  SELECT  i.psh_number,
          i.trl_id,
          i.mov_number
    FROM  @inserted i
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
   WHERE  i.trl_id <> d.trl_id
     AND  COALESCE(i.psh_number, 0) > 0;

OPEN STOPS_CURSOR;
FETCH STOPS_CURSOR INTO @PshNumber, @TrlId, @MovNumber;

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @OrdHdrNumber = 0; 
  
  SELECT  @OrdHdrNumber = MAX(ord_hdrnumber)
    FROM  dbo.stops WITH(NOLOCK)
   WHERE  mov_number = @MovNumber;
   
  IF @OrdHdrNumber > 0
    UPDATE  dbo.purchaseserviceheader
       SET  trl_id = @TrlId
     WHERE  psh_number = @PshNumber;
  ELSE
  BEGIN
    SELECT  @MovNumber = 0, @OrdHdrNumber = 0;

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

    IF COALESCE(@OrdHdrNumber, 0) > 0
    BEGIN
      SELECT  @TrlPshNumber = COALESCE(MAX(COALESCE(psh_number, 0)), 0)
        FROM  dbo.purchaseserviceheader WITH(NOLOCK)
       WHERE  ord_hdrnumber = @OrdHdrNumber;

      IF @TrlPshNumber > 0
        SELECT  @TrlPshId = RTRIM(@OrdHdrNumber) + CHAR(ASCII(RIGHT(psh_id, 1)) + 1)
          FROM  dbo.purchaseserviceheader WITH(NOLOCK)
         WHERE  psh_number = @TrlPshNumber;
      ELSE
        SELECT @TrlPshId = RTRIM(@OrdHdrNumber) + 'A';
    END

    UPDATE  dbo.purchaseserviceheader
       SET  trl_id = @TrlId,
            ord_hdrnumber = @OrdHdrNumber,
            psh_id = @TrlPshId
     WHERE  psh_number = @PshNumber;

    DELETE  dbo.purchaseservicedetail 
     WHERE  psh_number = @PshNumber;

    DECLARE trl_cmd_cursor CURSOR LOCAL FAST_FORWARD FOR
      SELECT  DISTINCT cmd_code, fgt_refnum
        FROM  dbo.freightdetail WITH(NOLOCK)
       WHERE  stp_number IN (SELECT stp_number
                               FROM dbo.stops WITH(NOLOCK)
                              WHERE mov_number = @MovNumber 
                                AND stp_type = 'PUP');

      OPEN trl_cmd_cursor;
      FETCH trl_cmd_cursor INTO @CmdCode, @RefNum;

      WHILE @@FETCH_STATUS = 0
      BEGIN
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
              FROM  dbo.commoditypurchaseservices WITH(NOLOCK)
             WHERE  cmd_code = @CmdCode;
        
        FETCH trl_cmd_cursor INTO @CmdCode, @RefNum;
      END

      CLOSE trl_cmd_cursor;
      DEALLOCATE trl_cmd_cursor;
  END
END
GO
GRANT EXECUTE ON  [dbo].[UtStopsConsolidated_PurchaseService_TrailerChange_sp] TO [public]
GO
