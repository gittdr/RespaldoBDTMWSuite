SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtOrd_Auto214Flag_sp]
(
  @inserted                   UtOrd READONLY,
  @deleted                    UtOrd READONLY,
  @ord_hdrnumber              INTEGER,
  @LtlEnabled                 CHAR(1),
  @EdiNotificationProcessType INTEGER,
  @tmwuser                    VARCHAR(255),
  @GETDATE                    DATETIME,
  @AppName                    VARCHAR(128)
)
AS

SET NOCOUNT ON;

DECLARE @AdvCarSCAC       VARCHAR(4),
        @214Activity      VARCHAR(6),
        @newstatus        VARCHAR(6),
        @oldstatus        VARCHAR(6),
        @newcode          INTEGER,
        @oldcode          INTEGER,
        @newconsignee     VARCHAR(8),
        @oldconsignee     VARCHAR(8),
        @newavailabledate DATETIME,
        @oldavailabledate DATETIME,
        @MatchCount       INTEGER,
        @Consolidation    CHAR(1),
        @stp_number       INTEGER,
        @stp_sequence     INTEGER,
        @stp_arrivaldate  DATETIME;

WITH CTE AS
(
  SELECT  abbr,
          code
    FROM  labelfile
   WHERE  labeldefinition = 'DispStatus'
)
SELECT  @newstatus = i.ord_status,
        @oldstatus = d.ord_status,
        @newcode = new.code,
        @oldcode = old.code,
        @newconsignee = i.ord_consignee,
        @oldconsignee = d.ord_consignee,
        @newavailabledate = i.ord_availabledate,
        @oldavailabledate = d.ord_availabledate
  FROM  @inserted i
          INNER JOIN @deleted d ON d.ord_hdrnumber = i.ord_hdrnumber
          INNER JOIN CTE new ON new.abbr = i.ord_status
          INNER JOIN CTE old ON old.abbr = d.ord_status
 WHERE  i.ord_hdrnumber = @ord_hdrnumber

IF @LtlEnabled = 'Y'
  SELECT  @AdvCarSCAC = car_scac
    FROM  legheader_brokered WITH(NOLOCK)
						INNER JOIN carrier WITH(NOLOCK) ON ord_booked_carrier = car_id
   WHERE  lgh_number = (SELECT  TOP 1 s.lgh_number
                          FROM  event e WITH(NOLOCK)
                                  INNER JOIN stops s WITH(NOLOCK) ON s.stp_number = e.stp_number
                         WHERE  e.ord_hdrnumber = @ord_hdrnumber
                           AND  e.evt_pu_dr = 'PUP'
                        ORDER BY s.stp_sequence);

SELECT @AdvCarSCAC = ISNULL(@AdvCarSCAC, '')

SELECT @214Activity =	CASE 
                        WHEN @newstatus = 'DSP' AND @newcode > @oldcode	THEN 'DISP'
				                WHEN @newstatus = 'PLN' AND @newcode > @oldcode THEN 'PLAN'
					              WHEN @newstatus = 'ICO' THEN 'CAN'
				                WHEN @newstatus = 'CMP' AND @newcode > @oldcode THEN 'COMP'
				                WHEN @newstatus = 'AVL' AND @newcode > @oldcode	THEN 'AVLORD'
				                WHEN @newstatus = 'CAN' THEN 'ORDCAN'
				                WHEN @newstatus = 'DPT' THEN 'DPT'
				                WHEN @newstatus = 'OFD' THEN 'OFD'
				                WHEN @newstatus = 'DCK' AND @AdvCarSCAC > '' THEN 'RCV'
				                ELSE ''
				              END

IF @newavailabledate <> @oldavailabledate
  SELECT  @214Activity = 'ORDAVL'

IF @oldconsignee <> 'UNKNOWN' AND  @newconsignee <> @oldconsignee
  SELECT @214activity = 'UPDCON'

IF @newstatus = 'CMP' OR @newstatus = 'CAN' OR @newstatus = 'ICO' 
  DELETE  edi_214_locationtracking
   WHERE  ord_hdrnumber = @ord_hdrnumber

IF @214Activity > ''
BEGIN
  SELECT TOP 1
          @stp_number = stp_number,
          @stp_sequence = stp_sequence,
          @stp_arrivaldate = stp_arrivaldate
    FROM  stops WITH(NOLOCK)
    WHERE  ord_hdrnumber = @ord_hdrnumber 
      AND  stp_type = 'PUP'
  ORDER BY stp_sequence;

  IF @214Activity in ('ORDCAN','AVLORD') AND @EdiNotificationProcessType = 2
		INSERT INTO edi_214_pending 
      (
				e214p_ord_hdrnumber,
				e214p_billto,
				e214p_level,
				e214p_ps_status,
				e214p_stp_number,
				e214p_dttm,
				e214p_activity,
				e214p_arrive_earlyorlate,
				e214p_depart_earlyorlate,
				e214p_stpsequence,
				ckc_number,
				e214p_firstlastflags,
				e214p_created,
				e214p_source,
				e214p_user
      )
			SELECT DISTINCT 
              @ord_hdrnumber,
				      e214_cmp_id,
				      'NON',
				      ' ',
				      @stp_number,
				      @stp_arrivaldate,
				      @214activity,
					    '',
				      '',
				      @stp_sequence,
				      0,
				      '0,1,99',
				      @GETDATE,
						  @AppName,
						  @tmwuser
				FROM  dbo.edi_214_profile e WITH(NOLOCK) 
       WHERE  e.e214_cmp_id IN (SELECT  cmp_id
                                  FROM  (SELECT ord_company,
                                                ord_billto,
                                                ord_consignee,
                                                ord_shipper
                                           FROM @inserted 
                                          WHERE ord_hdrnumber = @ord_hdrnumber) c
                                         UNPIVOT (cmp_id FOR cmp_ids IN (ord_company, ord_billto, ord_consignee, ord_shipper)) AS Companies)
         AND  e.e214_triggering_activity = @214activity 
         AND  e.orderby_role_flag = 'Y'
  ELSE
  BEGIN
    SELECT  @MatchCount = COUNT(1),
						@Consolidation = MIN(e214_consolidationlevel) 
		  FROM  dbo.edi_214_profile WITH(NOLOCK)
              INNER JOIN @inserted i ON i.ord_billto = e214_cmp_id
		 WHERE  e214_triggering_activity = @214activity ;

		IF @MatchCount > 0
 		  INSERT edi_214_pending 
        (
					e214p_ord_hdrnumber,
					e214p_billto,
					e214p_level,
					e214p_ps_status,
					e214p_stp_number,
					e214p_dttm,
					e214p_activity,
					e214p_arrive_earlyorlate,
					e214p_depart_earlyorlate,
					e214p_stpsequence,
					ckc_number,
					e214p_firstlastflags,
					e214p_created,
					e214p_source,
					e214p_user
        )
				SELECT DISTINCT 
                @ord_hdrnumber,
						    i.ord_billto,
						    'NON',
						    ' ',
						    @stp_number,
						    CASE @214activity
							    WHEN 'ORDAVL' THEN i.ord_availabledate
							    WHEN 'COMP' THEN COALESCE(i.ord_completiondate, @GETDATE)
							    WHEN 'UPDCON' THEN @GETDATE
							    WHEN 'RVC'THEN @GETDATE
							    WHEN 'DPT' THEN @GETDATE
							    WHEN 'OFD' THEN @GETDATE
    							ELSE @stp_arrivaldate
						    END,
						    @214activity,
						    '',
						    '',
						    @stp_sequence,
							  0,
						    '0,1,99',
						    @GETDATE,
						    @AppName,
						    @tmwuser
          FROM  @inserted i
         WHERE  i.ord_hdrnumber = @ord_hdrnumber;
  END
END

IF @newstatus = 'CAN'
	DELETE  edi_214_pending 
	 WHERE  e214p_ord_hdrnumber = @ord_hdrnumber 
     AND  e214p_activity <> 'ORDCAN'
GO
GRANT EXECUTE ON  [dbo].[UtOrd_Auto214Flag_sp] TO [public]
GO
