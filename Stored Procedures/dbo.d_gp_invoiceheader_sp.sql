SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_gp_invoiceheader_sp] (
 @pdtm_crupstart datetime,
 @pdtm_crupend datetime,
 @ps_revtype1 varchar(6),
 @ps_revtype2 varchar(6),
 @ps_revtype3 varchar(6),
 @ps_revtype4 varchar(6),
 @ps_transferred varchar(1),
 @ps_docdate varchar(20),
 @ps_postdate varchar(20),
 @ps_retrieveby varchar(20),
 @ps_company varchar(8))
AS
 
/**
 * 
 * NAME:
 * dbo.d_gp_invoiceheader_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Proc for dw d_gp_invoiceheader
 *
 * RETURNS:
 * dw result set
 *
 * PARAMETERS:
 * ...
 * 
 * REVISION HISTORY:
 * LOR	PTS# 30053	createsd to accomodate sch earliest date
 *
 **/

create table #tt_1 (
		ivh_invoicenumber	varchar(12) not null, 
 		ivh_mbnumber		int null, 
        ivh_billto			varchar(8) null, 
		creditterms			varchar(20) null, 
        ivh_totalcharge		money null, 
		ivh_creditmemo		char(1) null, 
		ivh_revtype1		varchar(6) null, 
		ivh_revtype2		varchar(6) null, 
		ivh_currency		varchar(6) null, 
		ivh_ref_number		varchar(30) null, 
        ivh_billdate		datetime null, 
		transfer			int null, 
		ivh_invoicestatus	varchar(6) null, 
		invhdrtotal			money null, 
	    invhdrins			int null, 
		ivh_tractor			varchar(8) null, 
		ord_hdrnumber		int null,
        cmp_othertype1		varchar(6) null, 
        cmp_othertype2		varchar(6) null, 
        bill_miles			float(15) null, 
        altid				varchar(25) null, 
        postdate			datetime null,
        totaltax			money null,
    	ivh_applyto			varchar(12) null,
		ivh_shipdate		datetime null, 
        ivh_deliverydate	datetime null, 
        invoice_ivh_billdate	datetime null)

INSERT into #tt_1
SELECT ivh_invoicenumber, 
 		  ivh_mbnumber, 
        ivh_billto, 
		  (SELECT name 
           FROM labelfile 
          WHERE ivh_terms = abbr AND 
                labeldefinition = 'CreditTerms') creditterms, 
        ivh_totalcharge, 
		  ivh_creditmemo, 
		  ivh_revtype1, 
		  ivh_revtype2, 
		  ivh_currency, 
		  ivh_ref_number, 
        CASE @ps_docdate WHEN 'Start Date' Then ivh_shipdate 
                         WHEN 'Completion Date' Then ivh_deliverydate 
                         ELSE ivh_billdate END ivh_billdate, 
		  1 transfer, 
		  ivh_invoicestatus, 
		  convert (money, 0) invhdrtotal, 
	     convert (smallint, 0) invhdrins, 
		  ivh_tractor, 
		  invoiceheader.ord_hdrnumber,
        cmp_othertype1, 
        cmp_othertype2, 
        ISNULL((SELECT SUM(ivd_distance) 
                  FROM invoicedetail, chargetype
                 WHERE ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND 
                       invoicedetail.cht_itemcode = chargetype.cht_itemcode AND 
                       cht_basis = 'DEL'), 0) bill_miles, 
        cmp_altid altid, 
        CASE @ps_postdate WHEN 'Start Date' Then ivh_shipdate 
                          WHEN 'Completion Date' Then ivh_deliverydate 
                          ELSE ivh_billdate END postdate,
        isnull ((select sum (ivd_charge)
						FROM invoicedetail, chargetype
                 WHERE ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND 
                       invoicedetail.cht_itemcode = chargetype.cht_itemcode AND 
                       (gp_tax = 1 or gp_tax = 2)), 0) totaltax,
    	  ivh_applyto,
		ivh_shipdate, 
         ivh_deliverydate, 
         ivh_billdate invoice_ivh_billdate
FROM invoiceheader, company 
WHERE  (@ps_company in (select ord_subcompany from orderheader where ord_hdrnumber = invoiceheader.ord_hdrnumber)
			or @ps_company = 'UNK') AND
        (ivh_revtype1 = @ps_revtype1 OR @ps_revtype1 = 'UNK') AND 
		  (ivh_revtype2 = @ps_revtype2 OR @ps_revtype2 = 'UNK') AND 
		  (ivh_revtype3 = @ps_revtype3 OR @ps_revtype3 = 'UNK') AND 
		  (ivh_revtype4 = @ps_revtype4 OR @ps_revtype4 = 'UNK') AND 
        ivh_invoicestatus <> 'CAN' AND 
 		  ((ivh_invoicestatus = 'PRN' AND ivh_mbstatus <> 'XFR') OR
			(ivh_invoicestatus = 'PRO' AND ivh_mbstatus <> 'XFR') OR
			(ivh_invoicestatus = 'RTP' and ivh_mbstatus <> 'XFR' and company.cmp_invoicetype = 'NONE') OR
         (ivh_invoicestatus = 'XFR' AND ivh_mbstatus <> 'XFR' AND @ps_transferred ='1') OR
		   (ivh_invoicestatus = 'XFR' and ivh_mbstatus <> 'XFR' and @ps_transferred ='1'and 
			 company.cmp_invoicetype = 'NONE' ) OR 
         ((ivh_invoicestatus = 'RTP' OR ivh_invoicestatus = 'NTP' OR ivh_invoicestatus = 'PRN') AND 
          (ivh_mbstatus = 'PRN' OR ivh_mbstatus ='PRO') AND @ps_transferred = '0') OR
			(ivh_invoicestatus = 'GLONLY' AND ivh_mbstatus <> 'XFR')) AND 
        company.cmp_id = ivh_billto AND 
        (cmp_transfertype = 'INV' OR 
         (cmp_transfertype = 'MAS' AND ivh_mbstatus = 'NTP' AND ivh_invoicestatus = 'PRN') OR 
         (cmp_transfertype = 'MAS' AND ivh_mbstatus = 'NTP' AND ivh_invoicestatus = 'XFR' AND @ps_transferred = '1')) 

--select * from #tt_1 order by ord_hdrnumber

If @ps_retrieveby = 'Sch Earliest Date'
select distinct ivh_invoicenumber, 
 		  ivh_mbnumber, 
        ivh_billto, 
		  creditterms, 
        ivh_totalcharge, 
		  ivh_creditmemo, 
		  ivh_revtype1, 
		  ivh_revtype2, 
		  ivh_currency, 
		  ivh_ref_number, 
        ivh_billdate, 
		  transfer, 
		  ivh_invoicestatus, 
		  invhdrtotal, 
	     invhdrins, 
		  ivh_tractor, 
		  #tt_1.ord_hdrnumber,
        cmp_othertype1, 
        cmp_othertype2, 
        bill_miles, 
        altid, 
        postdate,
        totaltax,
    	  ivh_applyto 
from #tt_1, stops
where (stops.stp_schdtearliest BETWEEN @pdtm_crupstart AND @pdtm_crupend) and
		(#tt_1.ord_hdrnumber = 0 or
			(stops.ord_hdrnumber = #tt_1.ord_hdrnumber and 
			stops.stp_sequence = 1 and
			#tt_1.ord_hdrnumber > 0))
Else
select distinct ivh_invoicenumber, 
 		  ivh_mbnumber, 
        ivh_billto, 
		  creditterms, 
        ivh_totalcharge, 
		  ivh_creditmemo, 
		  ivh_revtype1, 
		  ivh_revtype2, 
		  ivh_currency, 
		  ivh_ref_number, 
        ivh_billdate, 
		  transfer, 
		  ivh_invoicestatus, 
		  invhdrtotal, 
	     invhdrins, 
		  ivh_tractor, 
		  #tt_1.ord_hdrnumber,
        cmp_othertype1, 
        cmp_othertype2, 
        bill_miles, 
        altid, 
        postdate,
        totaltax,
    	  ivh_applyto 
from #tt_1
where (case @ps_retrieveby 
			When 'Completion Date' Then ivh_deliverydate 
			When 'Start Date' Then ivh_shipdate
        Else invoice_ivh_billdate End) BETWEEN @pdtm_crupstart AND @pdtm_crupend 

GO
GRANT EXECUTE ON  [dbo].[d_gp_invoiceheader_sp] TO [public]
GO
