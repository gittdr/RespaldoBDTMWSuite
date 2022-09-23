SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE  PROC [dbo].[deliverymanifest_rpt_sp] (@startdt DATETIME, @enddt DATETIME,
       @revtype1 VARCHAR(254), @revtype2 VARCHAR(254), @revtype3 VARCHAR(254), 
       @revtype4 VARCHAR(254), @origin VARCHAR(8) = 'UNKNOWN',
       @billto VARCHAR(8) = 'UNKNOWN') 
AS

   SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

   DECLARE @restricted_revtype1 VARCHAR(254),
           @restricted_revtype2 VARCHAR(254),
           @restricted_revtype3 VARCHAR(254),
           @restricted_revtype4 VARCHAR(254)

   -- obtain revenue restrictions assigned to the user.  If none assigned, let user have access to all data
   EXEC webrestrict_bydef 'RevType1', @restricted_revtype1 OUT
   EXEC webrestrict_bydef 'RevType2', @restricted_revtype2 OUT
   EXEC webrestrict_bydef 'RevType3', @restricted_revtype3 OUT
   EXEC webrestrict_bydef 'RevType4', @restricted_revtype4 OUT
 
   SELECT @revtype1 = ',' + LTRIM(RTRIM(ISNULL(@revtype1, ''))) + ','
   SELECT @revtype2 = ',' + LTRIM(RTRIM(ISNULL(@revtype2, '')))  + ','
   SELECT @revtype3 = ',' + LTRIM(RTRIM(ISNULL(@revtype3, '')))  + ','
   SELECT @revtype4 = ',' + LTRIM(RTRIM(ISNULL(@revtype4, '')))  + ','

   IF @origin IS NULL
      SELECT @origin = 'UNKNOWN'
   IF LTRIM(RTRIM(@origin)) = ''
      SELECT @origin = 'UNKNOWN'

   IF @billto IS NULL
      SELECT @billto = 'UNKNOWN'
   IF LTRIM(RTRIM(@billto)) = ''
      SELECT @billto = 'UNKNOWN'
   
   SET @enddt = CONVERT(DATETIME, CONVERT(VARCHAR(12), @enddt, 101) + ' 23:59')
   

	create table #temp2 (ord_hdrnumber int,
				ord_shipper varchar(8),
				date varchar(8),
				ord_number varchar(12),
				ord_tractor varchar(8),
				ord_trailer varchar(8),
				ord_billto varchar(8),
				ord_status varchar(6),
				ord_startdate datetime,
				ord_revtype1 varchar(6),
				ord_revtype2 varchar(6),
				ord_revtype3 varchar (6),
				ord_revtype4 varchar(6),
				stp_number int )

	create index dk_ordhdrnumber on #temp2 (ord_hdrnumber)
	create index dk_ord_tractor on #temp2 (ord_tractor)
	create index dk_ord_trailer on #temp2 (ord_trailer)


	Insert into #temp2 (ord_hdrnumber,
				ord_shipper,
				date,
				ord_number,
				ord_tractor,
				ord_trailer,
				ord_billto,
				ord_status,
				ord_startdate,
				ord_revtype1,
				ord_revtype2,
				ord_revtype3,
				ord_revtype4,
				stp_number)
(	SELECT	orderheader.ord_hdrnumber,
		ord_shipper,
		CONVERT(VARCHAR(8), ord_startdate, 1),
		ord_number,
		ord_tractor,
		ord_trailer,
		ord_billto,
		ord_status,
		ord_startdate,
		ord_revtype1,
		ord_revtype2,
		ord_revtype3,
		ord_revtype4,
		s1.stp_number
--	FROM	orderheader (index = pk_ordhdrnum), stops s1 (index = sk_stp_ordnum), freightdetail (index = dk_shipment)
	FROM	orderheader , stops s1 , freightdetail
	WHERE	ord_status = 'CMP' AND 
        	ord_startdate BETWEEN @startdt AND @enddt AND 
       		(ord_shipper = @origin OR @origin = 'UNKNOWN') AND 
		(@revtype1 = ',,' OR @revtype1 = ',UNK,' OR CHARINDEX(',' + ord_revtype1 + ',', @revtype1) > 0 OR ord_revtype1 IS NULL) AND 
		(@revtype2 = ',,' OR @revtype2 = ',UNK,' OR CHARINDEX(',' + ord_revtype2 + ',', @revtype2) > 0 OR ord_revtype2 IS NULL) AND 
          (@revtype3 = ',,' OR @revtype3 = ',UNK,' OR CHARINDEX(',' + ord_revtype3 + ',', @revtype3) > 0 OR ord_revtype3 IS NULL) AND 
          (@revtype4 = ',,' OR @revtype4 = ',UNK,' OR CHARINDEX(',' + ord_revtype4 + ',', @revtype4) > 0 OR ord_revtype4 IS NULL) AND 
	  (@restricted_revtype1 = ',,' OR CHARINDEX(',' + ord_revtype1 + ',', @restricted_revtype1) > 0 OR ord_revtype1 IS NULL) AND 
          (@restricted_revtype2 = ',,' OR CHARINDEX(',' + ord_revtype2 + ',', @restricted_revtype2) > 0 OR ord_revtype2 IS NULL) AND 
          (@restricted_revtype3 = ',,' OR CHARINDEX(',' + ord_revtype3 + ',', @restricted_revtype3) > 0 OR ord_revtype3 IS NULL) AND 
          (@restricted_revtype4 = ',,' OR CHARINDEX(',' + ord_revtype4 + ',', @restricted_revtype4) > 0 OR ord_revtype4 IS NULL) AND 
          orderheader.ord_hdrnumber = s1.ord_hdrnumber AND 
          (s1.stp_type1 NOT IN ('SHP', 'CON') OR
           s1.stp_type1 IS NULL) AND
          s1.stp_number = freightdetail.stp_number AND
	  (@billto = 'UNKNOWN' OR orderheader.ord_billto = @billto)
)


   SELECT ord_shipper, 
          date, 
          ord_number, 
          ISNULL((SELECT MIN(ivh_mbnumber) 
                    FROM invoiceheader 
                   WHERE invoiceheader.ord_hdrnumber = #temp2.ord_hdrnumber AND 
                         invoiceheader.ivh_mbnumber <> 0), 0) ivh_mbnumber, 
          (SELECT MAX(evt_hubmiles) - MIN(evt_hubmiles) 
--             FROM stops s2 (index = sk_stp_ordnum), event (index = stop)
             FROM stops s2, event
            WHERE #temp2.ord_hdrnumber = s2.ord_hdrnumber AND 
                  s2.stp_number = event.stp_number AND 
                  evt_hubmiles IS NOT NULL) mileage,
           CASE (SELECT max(tractorprofile.trc_type1) 
                  FROM tractorprofile 
                 WHERE #temp2.ord_tractor = tractorprofile.trc_number) 
              WHEN 'STRTRB' THEN 'BOX' 
              WHEN 'STRTRF' THEN 'FLAT' 
              ELSE CASE (SELECT max(trailerprofile.trl_type1) 
                           FROM trailerprofile 
                          WHERE #temp2.ord_trailer = trailerprofile.trl_id) 
                       WHEN 'FLAT' THEN 'FLAT' 
                       ELSE CASE #temp2.ord_tractor 
                                WHEN 'UNKNOWN' THEN 'COURIER' 
                                ELSE 'BOX' 
                            END
                   END 
	  END equipment_type,
          (SELECT COUNT(*) - 2 
             FROM stops s2 
            WHERE s2.ord_hdrnumber = #temp2.ord_hdrnumber) total_stops, 
          ISNULL((SELECT sum(ivd_quantity)
--                    FROM invoicedetail (index = ord_number)
                    FROM invoicedetail
                    WHERE #temp2.ord_hdrnumber = invoicedetail.ord_hdrnumber AND 
                          cht_itemcode = 'MIN'), 0) min_stops_adj, 
          ISNULL((SELECT SUM(ivd_charge)
--                    FROM invoicedetail  (index = ord_number)
                    FROM invoicedetail
                    WHERE #temp2.ord_hdrnumber = invoicedetail.ord_hdrnumber AND 
                          cht_itemcode = 'TOLLS'), 0) toll_charge, 
          ISNULL((SELECT SUM(ivd_charge) 
--                    FROM invoicedetail (index = ord_number), chargetype 
                    FROM invoicedetail, chargetype 
                   WHERE #temp2.ord_hdrnumber = invoicedetail.ord_hdrnumber AND 
                         invoicedetail.cht_itemcode = chargetype.cht_itemcode AND 
                         chargetype.cht_crchg = 1), 0) credit_charge,
          ISNULL((SELECT SUM(stp_delayhours) 
--                    FROM stops s2 (index = sk_stp_ordnum)
                    FROM stops s2 
                   WHERE s2.ord_hdrnumber = #temp2.ord_hdrnumber AND 
                         (s2.stp_reasonlate IN ('ST', 'SHIP'))), 0) st_wait, 
          ISNULL((SELECT MAX(ivd_rate) 
                   -- FROM invoicedetail (index = ord_number)
		 FROM invoicedetail
                   WHERE cht_itemcode in ('DLHR1', 'SHPDLY') AND 
                         invoicedetail.ord_hdrnumber = #temp2.ord_hdrnumber), 0) st_wait_rate, 
          ISNULL((SELECT  sum(ivh_totalcharge) 
--                    FROM invoiceheader (index = dk_ivh_ord_hdrnum)
                    FROM invoiceheader
                    WHERE #temp2.ord_hdrnumber = invoiceheader.ord_hdrnumber), 0) total_charge, 
          st1.stp_mfh_sequence stop_seq, 
          CASE WHEN st1.stp_type1 = 'SHP' THEN 0
               WHEN st1.stp_type1 = 'CON' THEN 0
               WHEN st1.stp_type1 = 'FY' THEN 0
               WHEN st1.stp_type1 = 'TR' THEN 0
               WHEN st1.stp_type1 = 'DF' THEN 0
               WHEN st1.stp_ooa_stop = 1 THEN 0
               ELSE 1
          END reg_stop, 
          -- JET - 7/27/00 - PTS #8569, added charge type STOPS to list to pull in rate for COURIER stops.
          ISNULL((SELECT MAX(ivd_rate) 
                    FROM invoicedetail
                   WHERE cht_itemcode IN ('STPBX', 'STPFL', 'STOPS') AND 
                         invoicedetail.ord_hdrnumber = #temp2.ord_hdrnumber), 0) reg_stop_rate, 
          -- JET - 7/27/00 - PTS #8570, add check for OOA stops (only count FYs that are not also OOA)
          CASE WHEN stp_ooa_stop = 0 AND stp_type1 = 'FY' THEN 1
               ELSE 0
          END fy, 
          ISNULL((SELECT MAX(ivd_rate) 
                    FROM invoicedetail
                   WHERE cht_itemcode = 'STPFY' AND 
                         invoicedetail.ord_hdrnumber = #temp2.ord_hdrnumber), 0) fy_rate, 
          CASE st1.stp_type1 
               WHEN 'TR' THEN 1
               ELSE 0
          END tf, 
          ISNULL((SELECT MAX(ivd_rate) 
                    FROM invoicedetail
                   WHERE cht_itemcode = 'STPTR' AND 
                         invoicedetail.ord_hdrnumber = #temp2.ord_hdrnumber), 0) tf_rate, 
          -- JET - 7/27/00 - PTS #8570, add check for OOA stops (only count DFs that are not also OOA)
          CASE WHEN st1.stp_ooa_stop = 0 AND st1.stp_type1 = 'DF' THEN 1
               ELSE 0
          END diff, 
          ISNULL((SELECT MAX(ivd_rate) 
                    FROM invoicedetail
                   WHERE cht_itemcode = 'STPDF' AND 
                         invoicedetail.ord_hdrnumber = #temp2.ord_hdrnumber), 0) diff_rate, 
          st1.stp_ooa_stop ooa_stop, 
          ISNULL((SELECT MAX(ivd_rate) 
                    FROM invoicedetail
                   WHERE cht_itemcode = 'OOASTP' AND 
                         invoicedetail.ord_hdrnumber = #temp2.ord_hdrnumber), 0) ooa_stop_rate, 
          st1.stp_ooa_mileage ooa_mi, 
          ISNULL((SELECT MAX(ivd_rate) 
                    FROM invoicedetail
                   WHERE cht_itemcode = 'OOAMLS' AND 
                         invoicedetail.ord_hdrnumber = #temp2.ord_hdrnumber), 0) ooa_mi_rate, 
          ISNULL(fgt_carryins1, 0) flooring, 
          ISNULL((SELECT MAX(ivd_rate) 
                    FROM invoicedetail
                   WHERE cht_itemcode = 'CRYIN1' AND 
                         invoicedetail.ord_hdrnumber = #temp2.ord_hdrnumber), 0) flooring_rate, 
          ISNULL(fgt_carryins2, 0) drywall, 
          ISNULL((SELECT MAX(ivd_rate) 
                    FROM invoicedetail
                   WHERE cht_itemcode = 'CRYIN2' AND 
                         invoicedetail.ord_hdrnumber = #temp2.ord_hdrnumber), 0) drywall_rate, 
          ISNULL(stp_delayhours, 0) re_wait, 
          ISNULL((SELECT MAX(ivd_rate) 
                    FROM invoicedetail
                   WHERE cht_itemcode = 'DLHR2' AND 
                         invoicedetail.ord_hdrnumber = #temp2.ord_hdrnumber), 0) re_wait_rate, 
          st1.stp_redeliver redelv, 
          ISNULL(stp_osd, '') osd , 

		--  Added "TOP 1" to these subqueries to prevent multiple records
			--causing error. jt 1/29/2002  
          ISNULL(CONVERT(VARCHAR(12), (SELECT top 1 ref_number 
                                         FROM referencenumber --(index = dk_ref_tableandkey)
                                        WHERE ref_tablekey = st1.stp_number AND 
                                              ref_table = 'stops' AND 
                                              ref_sequence = 1)), '') po1, 
-- KMM  NEED to CREATE THIS INDEX
--create index dk_ref_tableandkey on referencenumber (ref_tablekey, ref_table)
--drop index referencenumber.dk_ref_tableandkey

          ISNULL(CONVERT(VARCHAR(12), (SELECT top 1 ref_number 
                                         FROM referencenumber --(index = dk_ref_tableandkey)
                       WHERE ref_tablekey = st1.stp_number AND 
                                              ref_table = 'stops' AND 
                                              ref_sequence = 2)), '') po2, 
          ISNULL(CONVERT(VARCHAR(12), (SELECT top 1 ref_number 
                                         FROM referencenumber --(index = dk_ref_tableandkey)
                                        WHERE ref_tablekey = st1.stp_number AND 
                                              ref_table = 'stops' AND 
                                              ref_sequence = 3)), '') po3, 
          ISNULL(CONVERT(VARCHAR(12), (SELECT top 1 ref_number 
                                         FROM referencenumber --(index = dk_ref_tableandkey)
                                        WHERE ref_tablekey = st1.stp_number AND 
                                              ref_table = 'stops' AND 
                                              ref_sequence = 4)), '') po4,  
          ISNULL(CONVERT(VARCHAR(12), (SELECT top 1 ref_number 
                                         FROM referencenumber --(index = dk_ref_tableandkey)
                                        WHERE ref_tablekey = st1.stp_number AND 
                                              ref_table = 'stops' AND 
                                              ref_sequence = 5)), '') po5 
     INTO #temp 
--     FROM #temp2, stops st1 (index=pk_stp_number), freightdetail (index = dk_shipment)
     FROM #temp2, stops st1 , freightdetail 
    WHERE #temp2.stp_number = st1.stp_number AND
          st1.stp_number = freightdetail.stp_number AND
	  (@billto = 'UNKNOWN' OR #temp2.ord_billto = @billto)
 ORDER BY ord_shipper, date, ord_number, stop_seq


   -- create an index on the equipment type field to reduce I/O on the next select statement
   CREATE INDEX temp_ordnumber on #temp (ord_number)

   -- create an index on the equipment type field to reduce I/O on the next select statement
   CREATE INDEX temp_eqtype on #temp (equipment_type)
   
   -- JET - 7/8/00 - PTS #8431, if the reg_stop_rate is 0 then try to pull from dedicated misc invoice
   -- JET - 7/27/00 - PTS #8569, only check the reg_stop_rate on FLAT and BOX stops.  Courier stops should be dropped out.
   IF (SELECT SUM(ISNULL(reg_stop_rate, 0)) 
         FROM #temp with(INDEX=temp_eqtype)
        WHERE equipment_type IN ('BOX', 'FLAT')) = 0
      BEGIN
         UPDATE #temp
            SET reg_stop_rate = ISNULL((SELECT MAX(ivd_rate) 
                                          FROM invoicedetail, invoiceheader ivh1
                                         WHERE #temp.ord_shipper = ivh1.ivh_shipper AND 
                                               #temp.ivh_mbnumber = ivh1.ivh_mbnumber AND 
                                               ivh1.ivh_hdrnumber = invoicedetail.ivh_hdrnumber AND 
                                               invoicedetail.cht_itemcode = 'TOTSTP'), 0)
          WHERE reg_stop_rate = 0 
         
         UPDATE #temp
            SET reg_stop_rate = ISNULL((SELECT MAX(ivd_rate) 
--                                          FROM invoiceheader, invoicedetail  (index=ivhdtl_formanifest)
                                          FROM invoiceheader, invoicedetail
                                         WHERE #temp.ord_shipper = invoiceheader.ivh_shipper AND 
                                               invoiceheader.ivh_mbnumber = 0 AND 
                                               invoiceheader.ivh_shipdate BETWEEN @startdt AND @enddt AND 
                                               invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber AND 
                                               invoicedetail.cht_itemcode = 'TOTSTP'), 0)
          WHERE reg_stop_rate = 0 
         
         UPDATE #temp 
            SET total_charge = (SELECT SUM((ISNULL(reg_stop, 0) * ISNULL(reg_stop_rate, 0)) + 
      (ISNULL(re_wait, 0) * ISNULL(re_wait_rate, 0)) + 
                                           (ISNULL(fy, 0) * ISNULL(fy_rate, 0)) + 
                                           (ISNULL(tf, 0) * ISNULL(tf_rate, 0)) + 
                                           (ISNULL(diff, 0) * ISNULL(diff_rate, 0)) + 
                                           (ISNULL(ooa_stop, 0) * ISNULL(ooa_stop_rate, 0)) + 
                                           (ISNULL(ooa_mi, 0) * ISNULL(ooa_mi_rate, 0)) + 
                                           (ISNULL(flooring, 0) * ISNULL(flooring_rate, 0)) + 
                                           (ISNULL(drywall, 0) * ISNULL(drywall_rate, 0))) 
                                  FROM #temp t2 with(index=temp_ordnumber)
                                 WHERE t2.ord_number = t1.ord_number) 
            FROM #temp t1 

         UPDATE #temp 
            SET total_charge = total_charge + (SELECT MIN(ISNULL(toll_charge, 0) + 
                                                          ISNULL(credit_charge, 0) + 
                                                          (ISNULL(min_stops_adj, 0) * ISNULL(reg_stop_rate, 0)) + 
                                                          (ISNULL(st_wait, 0) * ISNULL(st_wait_rate, 0))) 
                                                 FROM #temp t2 with(index=temp_ordnumber)
                                                WHERE t2.ord_number = t1.ord_number) 
            FROM #temp t1
      END

   SELECT ord_shipper, 
          date, 
          ord_number, 
          mileage, 
          equipment_type, 
          total_stops, 
          min_stops_adj, 
          toll_charge, 
          credit_charge, 
          st_wait, 
          st_wait_rate, 
          total_charge, 
          stop_seq, 
          reg_stop, 
          reg_stop_rate, 
          fy, 
          fy_rate, 
          tf, 
          tf_rate, 
          diff, 
          diff_rate, 
          ooa_stop, 
          ooa_stop_rate, 
          ooa_mi, 
          ooa_mi_rate, 
          flooring, 
          flooring_rate, 
          drywall, 
          drywall_rate, 
          re_wait, 
          re_wait_rate, 
          redelv, 
          osd, 
          po1, 
          po2, 
          po3, 
          po4,  
          po5 
     FROM #temp 
GO
GRANT EXECUTE ON  [dbo].[deliverymanifest_rpt_sp] TO [public]
GO
