SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [dbo].[tripaudit_sp] 	@mov_number   INTEGER,
                                        @pay_types    VARCHAR(100),
                                        @asgn_type    VARCHAR(6),
                                        @asgn_id      VARCHAR(13),
                                        @start_date   DATETIME,
                                        @end_date     DATETIME
AS
SET NOCOUNT ON

CREATE TABLE #activity (
   ord_hdrnumber	INTEGER 	NULL,
   updated_by		VARCHAR(255)	NULL,
   updated_dt		DATETIME	NULL,
   activity		VARCHAR(20)	NULL,
   eaad_datetime	DATETIME	NULL,
   update_note		VARCHAR(255)	NULL,
   mov_number		INTEGER		NULL,
   lgh_number		INTEGER		NULL,
   ckc_cityname		VARCHAR(16)	NULL, --PTS68680 MBR 04/18/13
   ckc_state		VARCHAR(6)	NULL, --PTS68680 MBR 04/18/13
   ckc_tractor		VARCHAR(8)	NULL, --PTS68680 MBR 04/18/13
   ckc_asgntype		VARCHAR(6) 	NULL, --PTS68680 MBR 04/18/13
   ckc_asgnid		VARCHAR(13)	NULL  --PTS68680 MBR 04/18/13
)

CREATE TABLE #legs (
   lgh_number 		INTEGER		NULL,
   lgh_startdate	DATETIME	NULL,
   lgh_enddate		DATETIME	NULL,
   lgh_tractor		VARCHAR(8) 	NULL,
   lgh_driver1		VARCHAR(8)	NULL,
   lgh_primary_trailer	VARCHAR(13)	NULL,
   mov_number		INTEGER		NULL
)

CREATE TABLE #orders (
   ord_hdrnumber	INTEGER		NULL
)

IF LEN(@pay_types) > 0 
BEGIN
   SET @pay_types = ',' + @pay_types + ','
END
ELSE
BEGIN
   SET @pay_types = 'ALL'
END

IF @mov_number > 0
BEGIN

   INSERT INTO #activity (ord_hdrnumber, updated_by, updated_dt, activity, eaad_datetime,
                          update_note, mov_number, lgh_number)
      SELECT ord_hdrnumber, updated_by, updated_dt, activity, eaad_datetime,
             update_note, mov_number, lgh_number
        FROM expedite_audit_view
       WHERE mov_number = @mov_number AND
             activity <> 'CHECKCALL'

   INSERT INTO #legs (lgh_number, lgh_startdate, lgh_enddate, lgh_tractor, lgh_driver1, lgh_primary_trailer)
      SELECT lgh_number, lgh_startdate, lgh_enddate, lgh_tractor, lgh_driver1, lgh_primary_trailer
        FROM legheader 
       WHERE legheader.mov_number = @mov_number

   INSERT INTO #orders
      SELECT ord_hdrnumber
        FROM orderheader 
       WHERE orderheader.mov_number = @mov_number

   INSERT INTO #activity (updated_by, updated_dt, activity, lgh_number, update_note, ckc_cityname, ckc_state,
                          ckc_tractor, ckc_asgntype, ckc_asgnid)
      SELECT ckc_updatedby, ckc_date, 'CHECKCALL', ckc_lghnumber,
             RTRIM(ckc_asgntype) + ' ' + ISNULL(ckc_asgnid, '') + ' ' + RTRIM(ISNULL(ckc_comment, '')),
             ckc_cityname, ckc_state, ckc_tractor, ckc_asgntype, ckc_asgnid
        FROM checkcall c JOIN #legs ON ((#legs.lgh_tractor = c.ckc_asgnid AND c.ckc_asgntype = 'TRC' AND c.ckc_asgnid <> 'UNKNOWN') OR
                                        (#legs.lgh_driver1 = c.ckc_asgnid AND c.ckc_asgntype = 'DRV' AND c.ckc_asgnid <> 'UNKNOWN') OR
                                        (#legs.lgh_primary_trailer = c.ckc_asgnid and c.ckc_asgntype = 'TRL' AND c.ckc_asgnid <> 'UNKNOWN')) AND
                                         c.ckc_date BETWEEN #legs.lgh_startdate AND #legs.lgh_enddate
       WHERE ISNULL(ckc_lghnumber, 0) = 0
      UNION
      SELECT ckc_updatedby, ckc_date, 'CHECKCALL', ckc_lghnumber,
             RTRIM(ckc_asgntype) + ' ' + ISNULL(ckc_asgnid, '') + ' ' + RTRIM(ISNULL(ckc_comment, '')),
             ckc_cityname, ckc_state, ckc_tractor, ckc_asgntype, ckc_asgnid
        FROM checkcall c JOIN #legs ON c.ckc_lghnumber = #legs.lgh_number AND
                                     ((#legs.lgh_tractor = c.ckc_asgnid AND c.ckc_asgntype = 'TRC' AND c.ckc_asgnid <> 'UNKNOWN') OR
                                      (#legs.lgh_driver1 = c.ckc_asgnid AND c.ckc_asgntype = 'DRV' AND c.ckc_asgnid <> 'UNKNOWN') OR
                                      (#legs.lgh_primary_trailer = c.ckc_asgnid and c.ckc_asgntype = 'TRL' AND c.ckc_asgnid <> 'UNKNOWN'))

   INSERT INTO #activity (updated_by, updated_dt, activity, ord_hdrnumber, lgh_number, update_note)
      SELECT pyd_updatedby, pyd_transdate, 'PAYDETAIL', ord_hdrnumber, paydetail.lgh_number,
             RTRIM(ISNULL(asgn_type, '')) + ' ' + RTRIM(ISNULL(asgn_id, '')) + ' ' + RTRIM(ISNULL(pyt_itemcode, '')) +
             ' ' + RTRIM(ISNULL(pyd_description, '')) + ' ' + RTRIM(CAST(pyd_amount AS VARCHAR(15)))
        FROM paydetail JOIN #legs ON #legs.lgh_number = paydetail.lgh_number
       WHERE (CHARINDEX(',' + pyt_itemcode + ',', @pay_types) > 0 OR
              @pay_types = 'ALL')

   INSERT INTO #activity (updated_by, updated_dt, activity, ord_hdrnumber, lgh_number, update_note)
      SELECT pyd_updatedby, pyd_transdate, 'PAYDETAIL', paydetail.ord_hdrnumber, lgh_number,
             RTRIM(ISNULL(asgn_type, '')) + ' ' + RTRIM(ISNULL(asgn_id, '')) + ' ' + RTRIM(ISNULL(pyt_itemcode, '')) +
             ' ' + RTRIM(ISNULL(pyd_description, '')) + ' ' + RTRIM(CAST(pyd_amount AS VARCHAR(15)))
        FROM paydetail JOIN #orders ON #orders.ord_hdrnumber = paydetail.ord_hdrnumber
       WHERE paydetail.lgh_number = 0 AND
          (CHARINDEX(',' + pyt_itemcode + ',', @pay_types) > 0 OR 
           @pay_types = 'ALL')

   INSERT INTO #activity (updated_by, updated_dt, activity, ord_hdrnumber, lgh_number, update_note)
      SELECT f.fp_enteredby, f.fp_date, 'FUEL PURCHASE', f.ord_hdrnumber, f.lgh_number,
             'ID: ' + RTRIM(ISNULL(fp_id, ' ')) + ' CARD: ' + RTRIM(ISNULL(fp_cardnumber, ' ')) + 
             ' CAC_ID: ' + RTRIM(ISNULL(fp_cac_id, ' ')) + ' CCD_ID: ' + RTRIM(ISNULL(fp_ccd_id, ' ')) + 
             ' QTY: ' + RTRIM(CAST(fp_quantity AS VARCHAR(7))) + ' ' + ISNULL(fp_uom, ' ') + ' @ ' + 
             RTRIM(CAST(fp_cost_per as VARCHAR(8))) + ' TOTAL: ' + RTRIM(CAST(fp_amount AS VARCHAR(10)))
        FROM fuelpurchased f JOIN #legs ON ((#legs.lgh_tractor = f.trc_number AND f.trc_number <> 'UNKNOWN') OR
                                            (#legs.lgh_driver1 = f.mpp_id AND f.mpp_id <> 'UNKNOWN') OR
                                            (#legs.lgh_primary_trailer = f.trl_number AND f.trl_number <> 'UNKNOWN')) AND
                                            f.fp_date BETWEEN #legs.lgh_startdate AND #legs.lgh_enddate
END

IF @mov_number = 0 AND LEN(@asgn_type) > 0 AND LEN(@asgn_id) > 0
BEGIN
   INSERT INTO #legs (lgh_number, lgh_startdate, lgh_enddate, lgh_tractor, lgh_driver1, lgh_primary_trailer,
                      mov_number)
      SELECT a.lgh_number, l.lgh_startdate, l.lgh_enddate, l.lgh_tractor, l.lgh_driver1, l.lgh_primary_trailer,
             l.mov_number
        FROM assetassignment a JOIN legheader l ON a.lgh_number = l.lgh_number
       WHERE a.asgn_type = @asgn_type AND
             a.asgn_id = @asgn_id AND
             a.asgn_date BETWEEN @start_date AND @end_date

   INSERT INTO #activity (ord_hdrnumber, updated_by, updated_dt, activity, eaad_datetime,
                          update_note, mov_number, lgh_number)
      SELECT ord_hdrnumber, updated_by, updated_dt, activity, eaad_datetime,
             update_note, mov_number, lgh_number
        FROM expedite_audit_view
       WHERE mov_number IN (SELECT mov_number
                              FROM #legs) AND
             updated_dt BETWEEN @start_date AND @end_date AND
             activity <> 'CHECKCALL'
   
   --PTS68680 MBR 04/18/13 if asgntype is TRC then pull checkcalls by asgnid and ckc_tractor.
   IF @asgn_type <> 'TRC'
   BEGIN
      INSERT INTO #activity (updated_by, updated_dt, activity, lgh_number, update_note, ckc_cityname, ckc_state,
                             ckc_tractor, ckc_asgntype, ckc_asgnid)
         SELECT ckc_updatedby, ckc_date, 'CHECKCALL', ckc_lghnumber,
                RTRIM(ckc_asgntype) + ' ' + ISNULL(ckc_asgnid, '') + ' ' + RTRIM(ISNULL(ckc_comment, '')),
                ckc_cityname, ckc_state, ckc_tractor, ckc_asgntype, ckc_asgnid
           FROM checkcall
          WHERE ckc_asgntype = @asgn_type AND
                ckc_asgnid = @asgn_id AND
                ckc_date BETWEEN @start_date AND @end_date
   END
   ELSE
   BEGIN
      INSERT INTO #activity (updated_by, updated_dt, activity, lgh_number, update_note, ckc_cityname, ckc_state,
                             ckc_tractor, ckc_asgntype, ckc_asgnid)
         SELECT ckc_updatedby, ckc_date, 'CHECKCALL', ckc_lghnumber,
                RTRIM(ckc_asgntype) + ' ' + ISNULL(ckc_asgnid, '') + ' ' + RTRIM(ISNULL(ckc_comment, '')),
                ckc_cityname, ckc_state, ckc_tractor, ckc_asgntype, ckc_asgnid
           FROM checkcall
          WHERE ckc_asgntype = @asgn_type AND
                ckc_asgnid = @asgn_id AND
                ckc_date BETWEEN @start_date AND @end_date
         UNION
         SELECT ckc_updatedby, ckc_date, 'CHECKCALL', ckc_lghnumber,
                RTRIM(ckc_asgntype) + ' ' + ISNULL(ckc_asgnid, '') + ' ' + RTRIM(ISNULL(ckc_comment, '')),
                ckc_cityname, ckc_state, ckc_tractor, ckc_asgntype, ckc_asgnid
           FROM checkcall
          WHERE ckc_tractor = @asgn_id AND
                ckc_date BETWEEN @start_date AND @end_date
   END

   INSERT INTO #activity (updated_by, updated_dt, activity, ord_hdrnumber, lgh_number, update_note)
      SELECT pyd_updatedby, pyd_transdate, 'PAYDETAIL', ord_hdrnumber, paydetail.lgh_number,
             RTRIM(ISNULL(asgn_type, '')) + ' ' + RTRIM(ISNULL(asgn_id, '')) + ' ' + RTRIM(ISNULL(pyt_itemcode, '')) +
             ' ' + RTRIM(ISNULL(pyd_description, '')) + ' ' + RTRIM(CAST(pyd_amount AS VARCHAR(15)))
        FROM paydetail 
       WHERE asgn_type = @asgn_type AND
             asgn_id = @asgn_id AND
             pyd_transdate BETWEEN @start_date AND @end_date AND
            (CHARINDEX(',' + pyt_itemcode + ',', @pay_types) > 0 OR 
             @pay_types = 'ALL')

   INSERT INTO #activity (updated_by, updated_dt, activity, ord_hdrnumber, lgh_number, update_note)
      SELECT fp_enteredby, fp_date, 'FUEL PURCHASE', ord_hdrnumber, lgh_number,
             'ID: ' + RTRIM(ISNULL(fp_id, ' ')) + ' CARD: ' + RTRIM(ISNULL(fp_cardnumber, ' ')) + 
             ' CAC_ID: ' + RTRIM(ISNULL(fp_cac_id, ' ')) + ' CCD_ID: ' + RTRIM(ISNULL(fp_ccd_id, ' ')) + 
             ' QTY: ' + RTRIM(CAST(fp_quantity AS VARCHAR(7))) + ' ' + ISNULL(fp_uom, ' ') + ' @ ' + 
             RTRIM(CAST(fp_cost_per as VARCHAR(8))) + ' TOTAL: ' + RTRIM(CAST(fp_amount AS VARCHAR(10)))
        FROM fuelpurchased 
       WHERE ((@asgn_type = 'TRC' AND trc_number = @asgn_id) OR
              (@asgn_type = 'TRL' AND trl_number = @asgn_id) OR
              (@asgn_type = 'DRV' AND mpp_id = @asgn_id)) AND
             fp_date BETWEEN @start_date AND @end_date

END

SELECT ISNULL(orderheader.ord_number, '0') ord_number,
       RTRIM(updated_by) updated_by,
       updated_dt,
       activity,
       eaad_datetime,
       ISNULL(update_note, ' ') update_note, 
       ISNULL(#activity.mov_number, 0) mov_number,
       ISNULL(#activity.lgh_number, 0) lgh_number,
       ISNULL(ckc_cityname, ' ') ckc_cityname,
       ISNULL(ckc_state, ' ') ckc_state,
       ISNULL(ckc_tractor, ' ') ckc_tractor,
       ISNULL(ckc_asgntype, ' ') ckc_asgntype,
       ISNULL(ckc_asgnid, ' ') ckc_asgnid
  FROM #activity LEFT OUTER JOIN orderheader ON #activity.ord_hdrnumber = orderheader.ord_hdrnumber
ORDER BY updated_dt DESC	

GO
GRANT EXECUTE ON  [dbo].[tripaudit_sp] TO [public]
GO
