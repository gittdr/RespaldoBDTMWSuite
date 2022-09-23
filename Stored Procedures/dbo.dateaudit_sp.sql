SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[dateaudit_sp] @mindate datetime, @maxdate datetime
AS

DECLARE @movnumber int,
        @movnumber2 int,
        @lghnumber int,
        @ordhdrnumber int,
        @stpnumber int,
        @mfhseq int,
        @evtseq int,
        @lghstartdate datetime,
        @lghenddate datetime,
        @stpstartdate datetime,
        @stpenddate datetime,
        @evtstartdate datetime,
        @evtenddate datetime,
        @stpstartdate_hld datetime,
        @stpenddate_hld datetime,
        @evtstartdate_hld datetime,
        @evtenddate_hld datetime,
        @drv char(8),
        @trc char(8),
        @status char(6),
        @movstring char(10)

SELECT DISTINCT lh.mov_number 
  INTO #temp
  FROM legheader lh, stops st, event evt
 WHERE lh.mov_number = st.mov_number AND
       st.stp_number = evt.stp_number AND 
       (lgh_startdate > lgh_enddate OR stp_arrivaldate > stp_departuredate  OR
        evt_startdate > evt_enddate) AND 
       (lgh_startdate BETWEEN @mindate AND @maxdate)

SELECT DISTINCT lh.mov_number 
  INTO #temp2
  FROM legheader lh, stops st, event evt
 WHERE lh.mov_number = st.mov_number AND
       st.stp_number = evt.stp_number AND 
       lgh_startdate <= lgh_enddate AND 
       stp_arrivaldate <= stp_departuredate AND
       evt_startdate <= evt_enddate AND 
       (lgh_startdate BETWEEN @mindate AND @maxdate)

DELETE FROM #temp2 
      WHERE mov_number IN (SELECT t1.mov_number FROM #temp t1)

DECLARE moves CURSOR FOR
 SELECT mov_number FROM #temp2

OPEN moves
    FETCH NEXT FROM moves INTO @movnumber
    WHILE @@FETCH_STATUS = 0
    BEGIN
         DECLARE stops CURSOR FOR
          SELECT lgh_driver1, lgh_tractor, lh.mov_number, lh.lgh_number, lh.ord_hdrnumber, 
                 lgh_outstatus, lgh_startdate, lgh_enddate, 
                 st.stp_number, stp_mfh_sequence, stp_arrivaldate, stp_departuredate,
                 evt_sequence, evt_startdate, evt_enddate 
            FROM legheader lh, stops st, event evt
           WHERE @movnumber = lh.mov_number AND
                 lh.mov_number = st.mov_number AND
                 st.stp_number = evt.stp_number

         OPEN stops
             FETCH NEXT FROM stops INTO @drv, @trc, @movnumber2, @lghnumber, @ordhdrnumber,
                   @status, @lghstartdate, @lghenddate, @stpnumber, @mfhseq, @stpstartdate, 
                   @stpenddate, @evtseq, @evtstartdate, @evtenddate
             SELECT @stpstartdate_hld = @stpstartdate
             SELECT @stpenddate_hld = @stpenddate
             SELECT @evtstartdate_hld = @evtstartdate
             SELECT @evtenddate_hld = @evtenddate
             WHILE @@FETCH_STATUS = 0
             BEGIN
                  FETCH NEXT FROM stops INTO @drv, @trc, @movnumber2, @lghnumber, @ordhdrnumber,
                        @status, @lghstartdate, @lghenddate, @stpnumber, @mfhseq, @stpstartdate, 
                        @stpenddate, @evtseq, @evtstartdate, @evtenddate
                  IF @@FETCH_STATUS < 0
                     CONTINUE
                  IF @stpstartdate < @stpstartdate_hld OR @stpenddate < @stpenddate_hld OR
                     @evtstartdate < @evtstartdate_hld OR @evtenddate < @evtenddate_hld
                  BEGIN
                       INSERT INTO #temp
                            VALUES (@movnumber2)
                       BREAK
                  END
                  SELECT @stpstartdate_hld = @stpstartdate
                  SELECT @stpenddate_hld = @stpenddate
                  SELECT @evtstartdate_hld = @evtstartdate
                  SELECT @evtenddate_hld = @evtenddate
             END
         CLOSE stops
         DEALLOCATE stops
         FETCH NEXT FROM moves INTO @movnumber
    END
CLOSE moves
DEALLOCATE moves

DROP TABLE #temp2

SELECT lgh_driver1, lgh_tractor, lh.mov_number, lh.lgh_number, lh.ord_hdrnumber, 
       lgh_outstatus, lgh_startdate, lgh_enddate, 
       st.stp_event, stp_mfh_sequence, stp_arrivaldate, stp_departuredate,
       evt_sequence, evt_startdate, evt_enddate 
  FROM legheader lh, stops st, event evt, #temp
 WHERE #temp.mov_number = lh.mov_number AND
       lh.mov_number = st.mov_number AND
       st.stp_number = evt.stp_number

DROP TABLE #temp

GO
GRANT EXECUTE ON  [dbo].[dateaudit_sp] TO [public]
GO
