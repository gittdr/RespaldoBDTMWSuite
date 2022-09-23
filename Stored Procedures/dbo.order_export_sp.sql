SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[order_export_sp]
   @mov_number INT,
   @load_number INT,
   @est_date VARCHAR(10),
   @est_time VARCHAR(6)
AS
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/26/2007.01 ? PTS40189 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 40260 recode Pauls PH - PTS35279 - jguo - change index hint to new syntax. change "grant all"
*/


DECLARE   @min_lgh	INT,
          @lgh_count	INT,
          @count	INT,
          @firstleg	INT,
          @dltcmp	VARCHAR(8),
          @dltdate	VARCHAR(10),
          @dlttime	VARCHAR(4),
          @hltcmp	VARCHAR(8),
          @hltdate	VARCHAR(10),
          @hlttime	VARCHAR(4),
          @load		INT

CREATE TABLE #export
(
   ordid		VARCHAR(13) NULL,
   temp1		VARCHAR(8) NULL,
   ordtyp		VARCHAR(8) NULL,
   loadnum 		INT NOT NULL,
   evtcod		VARCHAR(6) NULL,
   movnum		INT NULL,
   pickdte		VARCHAR(10) NULL,
   picktme		VARCHAR(4) NULL,
   dropdte		VARCHAR(10) NULL,
   droptme		VARCHAR(4) NULL,
   drvrid		VARCHAR(8) NULL,
   trailnum		VARCHAR(8) NULL,
   trltyp		VARCHAR(8) NULL,
   tractnum		VARCHAR(8) NULL,
   dotloc		VARCHAR(5) NULL,
   shtoid		VARCHAR(10) NULL,
   fromid		VARCHAR(10) NULL,
   msgfield		VARCHAR(35) NULL,
   loadsts		VARCHAR(6) NULL,
   estdte		VARCHAR(10) NULL,
   esttme		VARCHAR(6) NULL,
   endload		CHAR(1) NULL,
   release_number   	VARCHAR(20) NULL,
   contact		VARCHAR(35) NULL,
   drvconf		VARCHAR(10) NULL,
   whsemsg		INT NULL,
   carrier		VARCHAR(8) NULL,
   userid		VARCHAR(20) NULL,
   pickup_event		VARCHAR(3) NULL,
   driveid2		VARCHAR(8) NULL,
   appinit		VARCHAR(3) NULL,
   splitevt		VARCHAR(6) NULL,
   lgh_number		INT NULL,
   tripseq		INTEGER NULL
   )

SELECT @lgh_count = COUNT(*)
  FROM legheader
 WHERE mov_number = @mov_number

--No split, process the old way
IF @lgh_count = 1
BEGIN
   INSERT INTO #export (ordid,temp1,ordtyp,loadnum,evtcod,movnum,
                        dropdte,droptme,drvrid,driveid2,trailnum,trltyp,tractnum,drvconf,
                        dotloc,shtoid,loadsts,estdte,esttme,endload,contact,release_number,
	                whsemsg, carrier, userid, msgfield, appinit, tripseq)
      SELECT ord_number,
             freightdetail.cmd_code,
             orderheader.ord_revtype3,
             CONVERT(int,ref1.ref_number),
             stops.stp_event,
             stops.mov_number,
             CONVERT(varchar(10),stops.stp_schdtearliest,101),
             SUBSTRING(CONVERT(varchar(8),stops.stp_schdtearliest,108),1,2) +
             SUBSTRING(CONVERT(varchar(8),stops.stp_schdtearliest,108),4,2),
             legheader.lgh_driver1,
	     legheader.lgh_driver2,
             legheader.lgh_primary_trailer,
             orderheader.trl_type1,
             legheader.lgh_tractor,
             legheader.lgh_type1,
             orderheader.ord_revtype1,
             stops.cmp_id,
             legheader.lgh_outstatus,
             @est_date,
             @est_time,
             0,
             orderheader.appt_contact,
             ref2.ref_number,
             stops.stp_OOA_stop,
             legheader.lgh_carrier,
             SUBSTRING(legheader.lgh_updatedby, 1, 20),
             SUBSTRING(orderheader.ord_remark, 1, 35),
             orderheader.appt_init,
             stops.stp_mfh_sequence
        FROM stops inner loop join orderheader 
             	      on  stops.ord_hdrnumber = orderheader.ord_hdrnumber
	        inner loop join freightdetail 
	              on stops.stp_number = freightdetail.stp_number
	        inner loop join referencenumber as ref1 --with(index=sk_ref_ship) 
             	      on stops.lgh_number = ref1.ref_tablekey AND 
		         ref1.ref_table = 'legheader' AND 
                         ref1.ref_sequence = 1
	        inner loop join legheader 
	              on stops.lgh_number = legheader.lgh_number
	        left outer loop join referencenumber as ref2 --with(index=sk_ref_ship) 
	              on stops.ord_hdrnumber = ref2.ref_tablekey AND
		         ref2.ref_table = 'orderheader' AND 
		         ref2.ref_sequence = 2
    WHERE stops.mov_number = @mov_number AND
          (stops.stp_type = 'DRP' or stp_event = 'XDU')

   UPDATE #export
      SET pickdte = CONVERT(varchar(10),stops.stp_schdtearliest,101),
          picktme = SUBSTRING(CONVERT(varchar(8),stops.stp_schdtearliest,108),1,2) +
                    SUBSTRING(CONVERT(varchar(8),stops.stp_schdtearliest,108),4,2),
          fromid = stops.cmp_id,
          pickup_event = stops.stp_event
     FROM orderheader,stops
    WHERE #export.ordid = orderheader.ord_number AND
          orderheader.ord_hdrnumber = stops.ord_hdrnumber AND
          stops.mov_number = @mov_number AND
         (stops.stp_type = 'PUP' or stops.stp_event = 'XDL') 
 
   INSERT INTO #export (loadnum,movnum,estdte,esttme,endload)
                VALUES (@load_number,@mov_number,@est_date,@est_time,1)
END
ELSE
--Move is split, process the split export
BEGIN
   SET @firstleg = 1
   SET @min_lgh = 0

   WHILE 1 = 1
   BEGIN

      SELECT @min_lgh = MIN(lgh_number)
        FROM legheader
       WHERE mov_number = @mov_number AND
             lgh_number > @min_lgh
   
      IF @min_lgh IS NULL
         BREAK
      
      IF @firstleg = 1
      BEGIN
         SELECT @dltcmp = stops.cmp_id,
                @dltdate = CONVERT(varchar(10),stops.stp_schdtearliest,101),
                @dlttime = SUBSTRING(CONVERT(varchar(8),stops.stp_schdtearliest,108),1,2) +
                           SUBSTRING(CONVERT(varchar(8),stops.stp_schdtearliest,108),4,2)
           FROM stops
          WHERE lgh_number = @min_lgh and
                stp_event = 'DLT'

         INSERT INTO #export (ordid, loadnum, movnum, estdte, esttme, lgh_number, splitevt)
            SELECT DISTINCT orderheader.ord_number,
                   CONVERT(int, ref1.ref_number),
                   @mov_number,
                   @est_date,
                   @est_time,
                   @min_lgh,
                   'DLT'
              FROM stops JOIN orderheader ON stops.ord_hdrnumber = orderheader.ord_hdrnumber
                         JOIN referencenumber as ref1 ON stops.lgh_number = ref1.ref_tablekey AND 
		                                         ref1.ref_table = 'legheader' AND 
                                                         ref1.ref_sequence = 1
             WHERE stops.lgh_number = @min_lgh AND
                   stops.ord_hdrnumber > 0

         UPDATE #export
            SET temp1 = freightdetail.cmd_code,
                ordtyp = orderheader.ord_revtype3,
                evtcod = stops.stp_event,
                dropdte = CONVERT(varchar(10),stops.stp_schdtearliest,101),
                droptme = SUBSTRING(CONVERT(varchar(8),stops.stp_schdtearliest,108),1,2) +
                          SUBSTRING(CONVERT(varchar(8),stops.stp_schdtearliest,108),4,2),
                drvrid = legheader.lgh_driver1,
                driveid2 = legheader.lgh_driver2,
                trailnum = legheader.lgh_primary_trailer,
                trltyp = orderheader.trl_type1,
                tractnum = legheader.lgh_tractor,
                drvconf = legheader.lgh_type1,
                dotloc = orderheader.ord_revtype1,
                shtoid = stops.cmp_id,
                loadsts = legheader.lgh_outstatus,
                estdte = @est_date,
                esttme = @est_time,
                endload = 0,
                contact = orderheader.appt_contact,
                release_number = ref2.ref_number,
                whsemsg = stops.stp_OOA_stop,
                carrier = legheader.lgh_carrier,
                userid = SUBSTRING(legheader.lgh_updatedby, 1, 20),
                msgfield = SUBSTRING(orderheader.ord_remark, 1, 35),
                appinit = orderheader.appt_init,
                tripseq = stops.stp_mfh_sequence
           FROM stops  LEFT OUTER JOIN  referencenumber ref2  ON  (stops.ord_hdrnumber  = ref2.ref_tablekey AND ref2.ref_table = 'orderheader' AND ref2.ref_sequence = 2),
				orderheader,
				legheader,
				freightdetail 
          WHERE #export.ordid = orderheader.ord_number AND
               (orderheader.ord_hdrnumber = stops.ord_hdrnumber AND
                stops.lgh_number = #export.lgh_number AND
                (stops.stp_type = 'DRP' or stp_event = 'XDU')) AND
                stops.lgh_number = legheader.lgh_number AND
                stops.stp_number = freightdetail.stp_number 
--                stops.ord_hdrnumber *= ref2.ref_tablekey AND
--                ref2.ref_table = 'orderheader' AND
--                ref2.ref_sequence = 2
          
         UPDATE #export
            SET ordtyp = orderheader.ord_revtype3,
                drvrid = legheader.lgh_driver1,
                driveid2 = legheader.lgh_driver2,
                trailnum = legheader.lgh_primary_trailer,
                trltyp = orderheader.trl_type1,
                tractnum = legheader.lgh_tractor,
                drvconf = legheader.lgh_type1,
                dotloc = orderheader.ord_revtype1,
                loadsts = legheader.lgh_outstatus,
                estdte = @est_date,
                esttme = @est_time,
                endload = 0,
                contact = orderheader.appt_contact,
                release_number = ref2.ref_number,
                carrier = legheader.lgh_carrier,
                userid = SUBSTRING(legheader.lgh_updatedby, 1, 20),
                msgfield = SUBSTRING(orderheader.ord_remark, 1, 35),
                pickdte = CONVERT(varchar(10),stops.stp_schdtearliest,101),
                picktme = SUBSTRING(CONVERT(varchar(8),stops.stp_schdtearliest,108),1,2) +
                          SUBSTRING(CONVERT(varchar(8),stops.stp_schdtearliest,108),4,2),
                fromid = stops.cmp_id,
                pickup_event = stops.stp_event
           FROM stops  LEFT OUTER JOIN  referencenumber ref2  ON (stops.ord_hdrnumber = ref2.ref_tablekey  AND ref2.ref_table = 'orderheader' AND ref2.ref_sequence = 2),
				orderheader,
				legheader 
          WHERE #export.ordid = orderheader.ord_number AND
               (orderheader.ord_hdrnumber = stops.ord_hdrnumber AND
                stops.lgh_number = #export.lgh_number AND
                (stops.stp_type = 'PUP' or stops.stp_event = 'XDL')) AND
                stops.lgh_number = legheader.lgh_number 
--                stops.ord_hdrnumber *= ref2.ref_tablekey AND  
--                ref2.ref_table = 'orderheader' AND
--                ref2.ref_sequence = 2
         
         UPDATE #export
            SET shtoid = @dltcmp,
                dropdte = @dltdate,
                droptme = @dlttime
          WHERE #export.lgh_number = @min_lgh AND
                shtoid IS NULL

         SELECT @load = loadnum
           FROM #export
          WHERE lgh_number = @min_lgh
         IF @load IS NULL
            SET @load = 0
         

         INSERT INTO #export (movnum,loadnum, estdte,esttme,endload)
                      VALUES (@mov_number, @load, @est_date,@est_time,1)

         SET @firstleg = @firstleg + 1

      END
      ELSE
      BEGIN
         SELECT @hltcmp = stops.cmp_id,
                @hltdate = CONVERT(varchar(10),stops.stp_schdtearliest,101),
                @hlttime = SUBSTRING(CONVERT(varchar(8),stops.stp_schdtearliest,108),1,2) +
                           SUBSTRING(CONVERT(varchar(8),stops.stp_schdtearliest,108),4,2)
           FROM stops
          WHERE lgh_number = @min_lgh and
                stp_event = 'HLT'

         INSERT INTO #export (ordid, loadnum, movnum, estdte, esttme, lgh_number, splitevt)
            SELECT DISTINCT orderheader.ord_number,
                   CONVERT(int, ref1.ref_number),
                   @mov_number,
                   @est_date,
                   @est_time,
                   @min_lgh,
                   'HLT'
              FROM stops JOIN orderheader ON stops.ord_hdrnumber = orderheader.ord_hdrnumber
                         JOIN referencenumber as ref1 ON stops.lgh_number = ref1.ref_tablekey AND 
		                                         ref1.ref_table = 'legheader' AND 
                                                         ref1.ref_sequence = 1
             WHERE stops.lgh_number = @min_lgh AND
                   stops.ord_hdrnumber > 0

         UPDATE #export
            SET temp1 = freightdetail.cmd_code,
                ordtyp = orderheader.ord_revtype3,
                evtcod = stops.stp_event,
                dropdte = CONVERT(varchar(10),stops.stp_schdtearliest,101),
                droptme = SUBSTRING(CONVERT(varchar(8),stops.stp_schdtearliest,108),1,2) +
                          SUBSTRING(CONVERT(varchar(8),stops.stp_schdtearliest,108),4,2),
                drvrid = legheader.lgh_driver1,
                driveid2 = legheader.lgh_driver2,
                trailnum = legheader.lgh_primary_trailer,
                trltyp = orderheader.trl_type1,
                tractnum = legheader.lgh_tractor,
                drvconf = legheader.lgh_type1,
                dotloc = orderheader.ord_revtype1,
                shtoid = stops.cmp_id,
                loadsts = legheader.lgh_outstatus,
                estdte = @est_date,
                esttme = @est_time,
                endload = 0,
                contact = orderheader.appt_contact,
                release_number = ref2.ref_number,
                whsemsg = stops.stp_OOA_stop,
                carrier = legheader.lgh_carrier,
                userid = SUBSTRING(legheader.lgh_updatedby, 1, 20),
                msgfield = SUBSTRING(orderheader.ord_remark, 1, 35),
                appinit = orderheader.appt_init,
                tripseq = stops.stp_mfh_sequence
           FROM stops  LEFT OUTER JOIN  referencenumber ref2  ON  (stops.ord_hdrnumber  = ref2.ref_tablekey AND ref2.ref_table = 'orderheader' AND ref2.ref_sequence = 2),
				orderheader,
				legheader,
				freightdetail 
          WHERE #export.ordid = orderheader.ord_number AND
               (orderheader.ord_hdrnumber = stops.ord_hdrnumber AND
                stops.lgh_number = #export.lgh_number AND
                (stops.stp_type = 'DRP' or stp_event = 'XDU')) AND
                stops.lgh_number = legheader.lgh_number AND
                stops.stp_number = freightdetail.stp_number 
--                stops.ord_hdrnumber *= ref2.ref_tablekey AND
--                ref2.ref_table = 'orderheader' AND
--                ref2.ref_sequence = 2
          
         UPDATE #export
            SET ordtyp = orderheader.ord_revtype3,
                drvrid = legheader.lgh_driver1,
                driveid2 = legheader.lgh_driver2,
                trailnum = legheader.lgh_primary_trailer,
                trltyp = orderheader.trl_type1,
                tractnum = legheader.lgh_tractor,
                drvconf = legheader.lgh_type1,
                dotloc = orderheader.ord_revtype1,
                loadsts = legheader.lgh_outstatus,
                estdte = @est_date,
                esttme = @est_time,
                endload = 0,
                contact = orderheader.appt_contact,
                release_number = ref2.ref_number,
                carrier = legheader.lgh_carrier,
                userid = SUBSTRING(legheader.lgh_updatedby, 1, 20),
                msgfield = SUBSTRING(orderheader.ord_remark, 1, 35),
                pickdte = CONVERT(varchar(10),stops.stp_schdtearliest,101),
                picktme = SUBSTRING(CONVERT(varchar(8),stops.stp_schdtearliest,108),1,2) +
                          SUBSTRING(CONVERT(varchar(8),stops.stp_schdtearliest,108),4,2),
                fromid = stops.cmp_id,
                pickup_event = stops.stp_event
           FROM stops  LEFT OUTER JOIN  referencenumber ref2  ON (stops.ord_hdrnumber  = ref2.ref_tablekey AND ref2.ref_table = 'orderheader' AND ref2.ref_sequence = 2),
				orderheader,
				legheader 
          WHERE #export.ordid = orderheader.ord_number AND
               (orderheader.ord_hdrnumber = stops.ord_hdrnumber AND
                stops.lgh_number = #export.lgh_number AND
                (stops.stp_type = 'PUP' or stops.stp_event = 'XDL')) AND
                stops.lgh_number = legheader.lgh_number 
--                stops.ord_hdrnumber *= ref2.ref_tablekey AND
--                ref2.ref_table = 'orderheader' AND
--                ref2.ref_sequence = 2
         
         UPDATE #export
            SET fromid = @hltcmp,
                pickdte = @hltdate,
                picktme = @hlttime
          WHERE #export.lgh_number = @min_lgh AND
                fromid IS NULL

         SELECT @load = loadnum
           FROM #export
          WHERE lgh_number = @min_lgh
         IF @load IS NULL
            SET @load = 0
         
         INSERT INTO #export (movnum,loadnum, estdte,esttme,endload)
                      VALUES (@mov_number, @load, @est_date,@est_time,1)
      END
   END
END

INSERT INTO pstrnup
   SELECT ordid, temp1, ordtyp, loadnum, evtcod, movnum, pickdte, picktme,
          dropdte, droptme, drvrid, trailnum, trltyp, tractnum, dotloc,
          shtoid, fromid, msgfield, loadsts, estdte, esttme, endload,
          release_number, contact, drvconf, whsemsg, carrier, userid,
          pickup_event, driveid2, appinit, splitevt, tripseq
     FROM #export

DROP TABLE #export

GO
GRANT EXECUTE ON  [dbo].[order_export_sp] TO [public]
GO
