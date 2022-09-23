SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtOrd_TrackRevenue_sp]
(
  @inserted                 UtOrd READONLY,
  @deleted                  UtOrd READONLY,
  @TrackRevenueZeroChanges  CHAR(1),
  @tmwuser                  VARCHAR(254),
  @GETDATE                  DATETIME,
  @appname                  VARCHAR(30)
)
AS

SET NOCOUNT ON;

DECLARE @ord_hdrnumber      INTEGER,
        @newstatus          VARCHAR(6),
        @newstatusisactive  CHAR(1),
        @oldstatus          VARCHAR(6), 
        @oldstatusisactive  CHAR(1),
        @newrateby          CHAR(1),
        @oldrateby          CHAR(1),
        @newcharge          MONEY,
        @oldcharge          MONEY,
        @newchtitem         VARCHAR(6),
        @oldchtitem         VARCHAR(6),
				@currency						VARCHAR(6);

DECLARE OrderCursor CURSOR LOCAL FAST_FORWARD FOR 
  SELECT  i.ord_hdrnumber,
          i.ord_status,
          d.ord_status,
          i.ord_currency,
          i.ord_rateby,
          d.ord_rateby,
          COALESCE(i.ord_charge, 0.0),
          COALESCE(d.ord_charge, 0.0),
          COALESCE(i.cht_itemcode, ''),
          COALESCE(d.cht_itemcode, '')
    FROM  @inserted i
            INNER JOIN @deleted d ON d.ord_hdrnumber = i.ord_hdrnumber;
    
OPEN OrderCursor;
FETCH OrderCursor INTO @ord_hdrnumber, @newstatus, @oldstatus, @currency, @newrateby, 
                       @oldrateby, @newcharge, @oldcharge, @newchtitem, @oldchtitem;
   
WHILE @@FETCH_STATUS = 0
BEGIN
  SELECT  @newstatusisactive = RTRIM(dbo.fn_statusisactive(COALESCE(@newstatus, 'AVL'))),
          @oldstatusisactive = RTRIM(dbo.fn_statusisactive(COALESCE(@oldstatus, 'AVL')));

  IF COALESCE(@newstatus, '') <> COALESCE(@oldstatus, '')
    INSERT INTO revenue_tracker
      (
        ord_hdrnumber,
        ivh_hdrnumber,
        ivh_definition,
        rvt_date,
        cht_itemcode,
        rvt_amount,
        tar_number,
        cur_code,
        rvt_isbackout,
        ord_status,
        ivh_invoicestatus,
        rvt_updatedby,
        rvt_updatesource,
        rvt_appname,
        rvt_quantity,
        ivd_number,
        rvt_rateby,
        rvt_billmiles, 
        rvt_billemptymiles
      )
      SELECT  @ord_hdrnumber,
              0,
              'PRERATE',
              @GETDATE,
              'UNK',
              0,
              0,
              @currency,
              'N',
              COALESCE(@newstatus, 'AVL'),
              '???',
              @tmwuser,
              'ut_ord ' + CASE @oldstatusisactive + @newstatusisactive
                            WHEN 'YN' THEN 'status active to inactive' 
                            WHEN 'NY' THEN 'status inactive to active'
                            ELSE 'status changed'
                          END,
              @appname,
              0,
              0,
              @newrateby,
              0.0,
              0.0

  IF NOT EXISTS(SELECT 1 FROM invoiceheader WHERE ord_hdrnumber = @ord_hdrnumber)
  BEGIN
    IF COALESCE(@newstatus, '') <> COALESCE(@oldstatus, '')
    BEGIN
      IF @oldstatusisactive = 'N' AND @newstatusisactive = 'Y'
        EXECUTE dbo.CreateRevenueForOrder @ord_hdrnumber, 'ADD', @tmwuser, 'ut_ord inactive to active'
    
      IF @oldstatusisactive = 'Y' AND @newstatusisactive = 'N'
        EXECUTE dbo.CreateRevenueForOrder @ord_hdrnumber, 'BACKOUT', @tmwuser, 'ut_ord active to inactive'
    END

    IF @oldstatusisactive = 'Y' AND @newstatusisactive = 'Y'
    BEGIN
      IF @oldrateby = 'T' AND (@oldcharge <> @newcharge OR @oldchtitem <> @newchtitem OR @newrateby = 'D')
      BEGIN
        INSERT INTO revenue_tracker
          (
            ord_hdrnumber,
            ivh_hdrnumber,
            ivh_definition,
            rvt_date,
            cht_itemcode,
            rvt_amount,
            tar_number,
            cur_code,
            rvt_isbackout,
            ord_status,
            ivh_invoicestatus,
            rvt_updatedby,
            rvt_updatesource,
            rvt_appname,
            rvt_quantity,
            ivd_number,rvt_rateby,
            rvt_billmiles, 
            rvt_billemptymiles
          )
          SELECT  d.ord_hdrnumber,
                  0,
                  'PRERATE',
                  @GETDATE,
                  d.cht_itemcode,
                  d.ord_charge * -1,
                  d.tar_number,
                  d.ord_currency,
                  'Y',
                  '???',
                  '???',
                  @tmwuser,
                  CASE @newrateby 
                    WHEN 'D' THEN 'ut_ord rateby change to D' 
                    ELSE 'ut_ord charge, or cht change' 
                  END,
                  @appname,
                  d.ord_quantity,
                  0,
                  d.ord_rateby,
                  0.0,
                  0.0
            FROM  @deleted d  
           WHERE  d.ord_hdrnumber = @ord_hdrnumber
             AND  COALESCE(d.ord_charge, 0.0) <> 0.0 
              OR  @TrackRevenueZeroChanges = 'Y'

        IF @oldrateby = 'T' AND @newrateby = 'D'
          INSERT INTO revenue_tracker
            (
              ord_hdrnumber,
              ivh_hdrnumber,
              ivh_definition,
              rvt_date,
              cht_itemcode,
              rvt_amount,
              tar_number,
              cur_code,
              rvt_isbackout,
              ord_status,
              ivh_invoicestatus,
              rvt_updatedby,
              rvt_updatesource,
              rvt_appname,
              rvt_quantity,
              ivd_number,
              rvt_rateby,
              rvt_billmiles,
              rvt_billemptymiles
            )
            SELECT  i.ord_hdrnumber,
                    0,
                    'PRERATE',
                    @GETDATE,
                    f.cht_itemcode,
                    f.fgt_charge,
                    f.tar_number,
                    i.ord_currency,
                    'N',
                    '???',
                    '???',
                    @tmwuser,
                    'ut_ord rateby change to D',
                    @appname,
                    f.fgt_quantity,
                    0,
                    i.ord_rateby,
                    0.0,
                    0.0
              FROM  @inserted i 
                      INNER JOIN stops s ON s.ord_hdrnumber = i.ord_hdrnumber
                      INNER JOIN freightdetail f on f.stp_number = s.stp_number
             WHERE  i.ord_hdrnumber = @ord_hdrnumber
               AND  s.stp_type = 'DRP'
               AND  (f.fgt_charge <> 0 
                OR   @TrackRevenueZeroChanges = 'Y')
      END
      IF @newrateby = 'T' AND (@oldcharge <> @newcharge OR @oldchtitem <> @newchtitem OR @oldrateby = 'D')
        INSERT INTO revenue_tracker
          (
            ord_hdrnumber,
            ivh_hdrnumber,
            ivh_definition,
            rvt_date,
            cht_itemcode,
            rvt_amount,
            tar_number,
            cur_code,
            rvt_isbackout,
            ord_status,
            ivh_invoicestatus,
            rvt_updatedby,
            rvt_updatesource,
            rvt_appname,
            rvt_quantity,
            ivd_number,
            rvt_rateby,
            rvt_billmiles, 
            rvt_billemptymiles
          )
          SELECT  i.ord_hdrnumber,
                  0,
                  'PRERATE',
                  @GETDATE,
                  i.cht_itemcode,
                  i.ord_charge, 
                  COALESCE(i.tar_number,0),
                  i.ord_currency,
                  'N',
                  '???',
                  '???',
                  @tmwuser,
                  CASE @oldrateby 
                    WHEN 'D' THEN 'ut_ord rateby change to T' 
                    ELSE 'ut_ord charge, or cht change' 
                  END,
                  @appname,
                  i.ord_quantity,
                  0,
                  i.ord_rateby,
                  0.0,
                  0.0
            FROM  @inserted i
           WHERE  i.ord_hdrnumber = @ord_hdrnumber
             AND  (COALESCE(i.ord_charge, 0.0) <> 0.0 
              OR   @TrackRevenueZeroChanges = 'Y');
      END
  END

  FETCH OrderCursor INTO @ord_hdrnumber, @newstatus, @oldstatus, @currency, @newrateby, 
                         @oldrateby, @newcharge, @oldcharge, @newchtitem, @oldchtitem;
END

CLOSE OrderCursor;
DEALLOCATE OrderCursor;
GO
GRANT EXECUTE ON  [dbo].[UtOrd_TrackRevenue_sp] TO [public]
GO
