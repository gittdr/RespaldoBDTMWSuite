SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[d_reratebydetail_invlist]
	(@ratedstatus char(1),
	 @billto varchar(8),
	 @BillDatestart datetime, 
	 @BillDateend datetime, 
	 @Shipdatestart datetime,
	 @shipdateend datetime, 
	 @invormbstatus varchar(6),
	 @tarnumber int,  
	 @tariffnumber varchar(12), 
	 @tariffitem varchar(12), 
	 @revtype1 varchar(8),
	 @revtype2 varchar(8), 
	 @revtype3 varchar(8), 
	 @revtype4 varchar(8), 
	 @sch_date1 datetime, 
	 @sch_date2 datetime, 
	 @masterorder varchar(8), 
	 @mbnumber int, 
	 @ivh_invoicenumber varchar(12),
	 @ord_invoice_effectivedate1 datetime,	-- 62719
	 @ord_invoice_effectivedate2 datetime)	-- 62719

AS

/**
 * 
 * NAME:
 * dbo.d_reratebydetail_invlist
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provides a list of invoices to be re rated.
 * Arguments and result set should match d_ratebydetail_invlist
 *
 * RETURNS:
 * dw result set
 *
 * PARAMETERS:
 * .....
 * 015 - @sch_date1 datetime	sch earliest datetime from
 * 016 - @sch_date1 datetime	sch earliest datetime to
 * 017 - @masterorder	varchar(8)	ord_number to match ord_fromorder
 * 018 - @mbnumber  int  match based upon mbnumber
 * 019 - @ivh_invoicenumber varchar(12) - Match based upon an invoicenumber.  This is used when adding invoicenumbers manually.
 * 
 * REVISION HISTORY:
 * LOR	PTS# 30053	added sch earliest dates
 * KMM  PTS# 32909	added Master Order search capability
 * DPETE PTS33311  do nto re rate credit memos 
 * PRB PTS33674 07/14/06 Removed stp_sequence = 1 in favour of selecting MIN stp_sequence
 * PRB PTS34429 12/16/06 Added MasterBill lookup ability.
 *
 **/

Select @tariffnumber =  RTRIM(IsNull(@tariffnumber,'')) 
Select @tariffitem = RTRIM(IsNull(@tariffitem,'')) 
Select @tarnumber = IsNull(@tarnumber,0)
Select @revtype1 = IsNull(@revtype1,'UNK')
Select @revtype2 = IsNull(@revtype2,'UNK')
Select @revtype3 = IsNull(@revtype3,'UNK')
Select @revtype4 = IsNull(@revtype4,'UNK')
Select @masterorder = IsNull(@masterorder, '')

Create table #invoicelist (
ivh_hdrnumber int NULL,
ivh_invoicenumber varchar(12) null,
ivh_mbnumber int null,
ivh_billto varchar(8) null,
cmp_name		varchar(60) null,
cty_nmstct  varchar(25) null  ,
ivh_BillDate datetime null,
ivh_ShipDate datetime null,
ivh_invoicestatus varchar(6) null,
ivh_mbstatus varchar(6) null,
ivh_rateby char(1) null,
tar_number int null,
tar_tariffnumber  varchar(12) null,
tar_tariffitem varchar(12) null,
ivh_revtype1 varchar(6) null ,
ivh_revtype2 varchar(6) null ,
ivh_revtype3 varchar(6) null ,
ivh_revtype4 varchar(6) null ,
ivh_totalcharge money null,
ivh_charge money null,
ivh_accessorial_chrg money null,
ivh_revtype1_t varchar(8) null,
ivh_revtype2_t varchar(8) null,
ivh_revtype3_t varchar(8) null,
ivh_revtype4_t varchar(8) null,
ord_number varchar(12) null,
has_credit char(1) null,
has_rebill char(1) null,
ivh_definition varchar(6) null
)

--PRB PTS34429 - Looking up Masterbills

IF @mbnumber <> 0
	Insert Into #invoicelist
		Select i.ivh_hdrnumber,
		ivh_invoicenumber,
		ivh_mbnumber,
		ivh_billto,
		cmp_name = SUBSTRING(bc.cmp_name,1,60),
		cty_nmstct = bc.cty_nmstct ,
		ivh_BillDate,
		ivh_ShipDate,
		ivh_invoicestatus = case ivh_invoicestatus When 'PRO' Then 'PRN' Else ivh_invoicestatus End,
		ivh_mbstatus = case IsNull(ivh_mbstatus,'')  When 'PRO' Then 'PRN' Else IsNull(ivh_mbstatus,'') End,
		ivh_rateby,
		@tarnumber ,
		@tariffnumber ,
		@tariffitem ,
		ivh_revtype1 ,
		ivh_revtype2 ,
		ivh_revtype3,
		ivh_revtype4 ,
		ivh_totalcharge,
		ivh_charge,
		(ivh_totalcharge - ivh_charge ),
		'RevType1','RevType2','RevType3' ,'RevType4',
		i.ord_number,
		has_credit = (SELECT 'has_credit' = 
		 		CASE 
			  	  WHEN Count(ivh.ivh_hdrnumber) >= 1 THEN 'Y'
			  	  ELSE 'N'
	    		      	END
		     		 FROM invoiceheader ivh
		      		 WHERE ivh_definition = 'CRD'
		      		 AND ivh.ord_hdrnumber = i.ord_hdrnumber
		      		 AND ivh.ivh_hdrnumber >= i.ivh_hdrnumber),
		has_rebill = (SELECT 'has_rebill' = 
		 		CASE 
			  	  WHEN Count(ivh.ivh_hdrnumber) >= 1 THEN 'Y'
			  	  ELSE 'N'
	    		      	END
		      		  FROM invoiceheader ivh
		      		  WHERE ivh_definition = 'RBIL'
		      		  AND ivh.ord_hdrnumber = i.ord_hdrnumber
		      		  AND ivh.ivh_hdrnumber > i.ivh_hdrnumber),
		i.ivh_definition
		From invoiceheader i LEFT outer join orderheader oh on i.ord_hdrnumber = oh.ord_hdrnumber
			inner join company bc on i.ivh_billto = bc.cmp_id 
		Where  ivh_mbnumber = @mbnumber
--PRB looking up invoicenumber
Else If @ivh_invoicenumber <> ''
 	Insert Into #invoicelist
		Select ivh_hdrnumber,
		ivh_invoicenumber,
		ivh_mbnumber,
		ivh_billto,
		cmp_name = SUBSTRING(bc.cmp_name,1,60),
		bc.cty_nmstct,
		ivh_billdate,
		ivh_shipdate,
		ivh_invoicestatus = case ivh_invoicestatus When 'PRO' Then 'PRN' Else ivh_invoicestatus End,
		ivh_mbstatus = case IsNull(ivh_mbstatus,'') When 'PRO' Then 'PRN' Else IsNull(ivh_mbstatus,'')  End,
		ivh_rateby,
		i.tar_number,
		i.tar_tarriffnumber,
		i.tar_tariffitem,
		ivh_revtype1,
		ivh_revtype2,
		ivh_revtype3,
		ivh_revtype4,
		ivh_totalcharge,
		ivh_charge,
		ivh_accessorial_chrg = ivh_totalcharge - ivh_charge ,
		'RevType1','RevType2','RevType3','RevType4',
		i.ord_number,
		has_credit = (SELECT 'has_credit' = 
		 		CASE 
			  	  WHEN Count(ivh.ivh_hdrnumber) >= 1 THEN 'Y'
			  	  ELSE 'N'
	    		      	END
		     		 FROM invoiceheader ivh
		      		 WHERE ivh_definition = 'CRD'
		      		 AND ivh.ord_hdrnumber = i.ord_hdrnumber
		      		 AND ivh.ivh_hdrnumber >= i.ivh_hdrnumber),
		has_rebill = (SELECT 'has_rebill' = 
		 		CASE 
			  	  WHEN Count(ivh.ivh_hdrnumber) >= 1 THEN 'Y'
			  	  ELSE 'N'
	    		      	END
		      		  FROM invoiceheader ivh
		      		  WHERE ivh_definition = 'RBIL'
		      		  AND ivh.ord_hdrnumber = i.ord_hdrnumber
		      		  AND ivh.ivh_hdrnumber > i.ivh_hdrnumber),
		i.ivh_definition
		From invoiceheader i LEFT outer join orderheader oh on i.ord_hdrnumber = oh.ord_hdrnumber
			inner join company bc on i.ivh_billto = bc.cmp_id 
		Where  ivh_invoicenumber = @ivh_invoicenumber

Else If @billto <> 'UNKNOWN'
		Insert Into #invoicelist
			Select i.ivh_hdrnumber,
			ivh_invoicenumber,
			ivh_mbnumber,
			ivh_billto,
			cmp_name = SUBSTRING(bc.cmp_name,1,60),
			cty_nmstct = bc.cty_nmstct ,
			ivh_BillDate,
			ivh_ShipDate,
			ivh_invoicestatus = case ivh_invoicestatus When 'PRO' Then 'PRN' Else ivh_invoicestatus End,
			ivh_mbstatus = case IsNull(ivh_mbstatus,'')  When 'PRO' Then 'PRN' Else IsNull(ivh_mbstatus,'') End,
			ivh_rateby,
			@tarnumber ,
			@tariffnumber ,
			@tariffitem ,
			ivh_revtype1 ,
			ivh_revtype2 ,
			ivh_revtype3,
			ivh_revtype4 ,
			ivh_totalcharge,
			ivh_charge,
			(ivh_totalcharge - ivh_charge ),
			'RevType1','RevType2','RevType3' ,'RevType4',
			i.ord_number,
			has_credit = (SELECT 'has_credit' = 
		 		CASE 
			  	  WHEN Count(ivh.ivh_hdrnumber) >= 1 THEN 'Y'
			  	  ELSE 'N'
	    		      	END
		     		 FROM invoiceheader ivh
		      		 WHERE ivh_definition = 'CRD'
		      		 AND ivh.ord_hdrnumber = i.ord_hdrnumber
		      		 AND ivh.ivh_hdrnumber >= i.ivh_hdrnumber),
			has_rebill = (SELECT 'has_rebill' = 
		 		CASE 
			  	  WHEN Count(ivh.ivh_hdrnumber) >= 1 THEN 'Y'
			  	  ELSE 'N'
	    		      	END
		      		  FROM invoiceheader ivh
		      		  WHERE ivh_definition = 'RBIL'
		      		  AND ivh.ord_hdrnumber = i.ord_hdrnumber
		      		  AND ivh.ivh_hdrnumber > i.ivh_hdrnumber),
			i.ivh_definition
			From invoiceheader i LEFT outer join orderheader oh on i.ord_hdrnumber = oh.ord_hdrnumber
				inner join company bc on i.ivh_billto = bc.cmp_id 
			Where  @billto = ivh_billto
			and isnull(ivh_definition,'XX') <> 'CRD' 
			and ivh_BillDate between @BillDatestart and @BillDateend
			and ivh_ShipDate between @shipdatestart and @shipdateend
			and	isnull(oh.ord_invoice_effectivedate, '19500101 00:00') between @ord_invoice_effectivedate1 and @ord_invoice_effectivedate2 --62719
			and ivh_rateby = 'D'
			and @revtype1 in ('UNK',ivh_revtype1)
			and @revtype2 in ('UNK',ivh_revtype2)
			and @revtype3 in ('UNK',ivh_revtype3)
			and @revtype4 in ('UNK',ivh_revtype4)
			and Charindex(ivh_invoicestatus,(case @invormbstatus When 'L' Then '^HLD^RTP^NTP^' 
									     When 'A' Then '^HLD^RTP^NTP^PRO^PRN^' 
									     When 'H' Then '^HLA^'  
									     When 'X' Then '^XFR^' Else '%%' 
							 End)) > 0
			and ivh_creditmemo <> 'Y'  and
		(((select min(stp_schdtearliest )
		from stops 
		where stops.ord_hdrnumber = i.ord_hdrnumber and stp_sequence = (SELECT MIN(stp_sequence) --PTS33674 was stp_sequence = 1
		 									    FROM stops
		 									    WHERE stops.ord_hdrnumber = i.ord_hdrnumber) )
			between @sch_date1 and @sch_date2 ) or
		i.ord_hdrnumber = 0) AND
		isnull(oh.ord_fromorder, '') = case @masterorder when '' then isnull(oh.ord_fromorder,'') else @masterorder end

ELSE IF @ratedstatus = '?'
BEGIN
	Insert Into #invoicelist VALUES (
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		'RevType1','RevType2','RevType3','RevType4',
		NULL,
		'N',
		'N',
		NULL)
END
		
Else
		Insert Into #invoicelist
			Select i.ivh_hdrnumber,
			ivh_invoicenumber,
			ivh_mbnumber,
			ivh_billto,
			cmp_name = SUBSTRING(bc.cmp_name,1,60),
			cty_nmstct = bc.cty_nmstct ,
			ivh_BillDate,
			ivh_ShipDate,
			ivh_invoicestatus = case ivh_invoicestatus When 'PRO' Then 'PRN' Else ivh_invoicestatus End,
			ivh_mbstatus = case IsNull(ivh_mbstatus,'')  When 'PRO' Then 'PRN' Else IsNull(ivh_mbstatus,'') End,
			ivh_rateby,
			@tarnumber ,
			@tariffnumber ,
			@tariffitem ,
			ivh_revtype1 ,
			ivh_revtype2 ,
			ivh_revtype3,
			ivh_revtype4 ,
			ivh_totalcharge,
			ivh_charge,
			(ivh_totalcharge - ivh_charge ),
			'RevType1','RevType2','RevType3' ,'RevType4',
			i.ord_number,
			has_credit = (SELECT 'has_credit' = 
		 		CASE 
			  	  WHEN Count(ivh.ivh_hdrnumber) >= 1 THEN 'Y'
			  	  ELSE 'N'
	    		      	END
		     		 FROM invoiceheader ivh
		      		 WHERE ivh_definition = 'CRD'
		      		 AND ivh.ord_hdrnumber = i.ord_hdrnumber
		      		 AND ivh.ivh_hdrnumber >= i.ivh_hdrnumber),
			has_rebill = (SELECT 'has_rebill' = 
		 		CASE 
			  	  WHEN Count(ivh.ivh_hdrnumber) >= 1 THEN 'Y'
			  	  ELSE 'N'
	    		      	END
		      		  FROM invoiceheader ivh
		      		  WHERE ivh_definition = 'RBIL'
		      		  AND ivh.ord_hdrnumber = i.ord_hdrnumber
		      		  AND ivh.ivh_hdrnumber > i.ivh_hdrnumber),
			i.ivh_definition
			From invoiceheader i LEFT outer join orderheader oh on i.ord_hdrnumber = oh.ord_hdrnumber
				inner join company bc on i.ivh_billto = bc.cmp_id 
			Where  ivh_BillDate between @BillDatestart and @BillDateend
			and ivh_ShipDate between @shipdatestart and @shipdateend
			and	isnull(oh.ord_invoice_effectivedate, '19500101 00:00') between @ord_invoice_effectivedate1 and @ord_invoice_effectivedate2 --62719
			and isnull(ivh_definition,'XX') <> 'CRD' 
			and ivh_rateby = 'D'
			and @revtype1 in ('UNK',ivh_revtype1)
			and @revtype2 in ('UNK',ivh_revtype2)
			and @revtype3 in ('UNK',ivh_revtype3)
			and @revtype4 in ('UNK',ivh_revtype4)
			and Charindex(ivh_invoicestatus,(case @invormbstatus When 'L' Then '^HLD^RTP^NTP^' 
									     When 'A' Then '^HLD^RTP^NTP^PRO^PRN^' 
									     When 'H' Then '^HLA^'  
									     When 'X' Then '^XFR^' Else '%%' 
							 End)) > 0
			and ivh_creditmemo <> 'Y' and
		(((select min(stp_schdtearliest )
		from stops 
		where stops.ord_hdrnumber = i.ord_hdrnumber and stp_sequence = (SELECT MIN(stp_sequence) --PTS33674 was stp_sequence = 1
		 									    FROM stops
		 									    WHERE stops.ord_hdrnumber = i.ord_hdrnumber) )
			between @sch_date1 and @sch_date2 ) or
		i.ord_hdrnumber = 0) AND
		isnull(oh.ord_fromorder, '') = case @masterorder when '' then isnull(oh.ord_fromorder,'') else @masterorder end

If @mbnumber = 0
BEGIN
	If @ratedstatus = 'N' Delete From #invoicelist Where ivh_charge <> 0
	Else
	  Begin
		If @ratedstatus = 'R' 
			Delete From #invoicelist Where ivh_charge = 0
		If @tarnumber > 0 
				Delete from #invoicelist where Not Exists (Select tar_number from invoicedetail
				Where invoicedetail.ivh_hdrnumber = #invoicelist.ivh_hdrnumber and invoicedetail.tar_number = @tarnumber)
		If @tariffnumber > '' 
				Delete from #invoicelist where Not Exists (Select tar_tariffnumber from invoicedetail
				Where invoicedetail.ivh_hdrnumber = #invoicelist.ivh_hdrnumber and invoicedetail.tar_tariffnumber = @tariffnumber)
		If @tariffitem > '' 
				Delete from #invoicelist where Not Exists (Select tar_tariffitem from invoicedetail
				Where invoicedetail.ivh_hdrnumber = #invoicelist.ivh_hdrnumber and invoicedetail.tar_tariffitem = @tariffitem)
		 End
      END
      ELSE
      BEGIN
			DELETE FROM #invoicelist WHERE ivh_definition = 'CRD'
      END


Select  ivh_hdrnumber ,
ivh_invoicenumber ,
ivh_mbnumber,
ivh_billto ,
cmp_name		,
cty_nmstct  ,
ivh_BillDate ,
ivh_ShipDate,
ivh_invoicestatus ,
ivh_mbstatus,
ivh_rateby,
tar_number,
tar_tariffnumber ,
tar_tariffitem ,
ivh_revtype1  ,
ivh_revtype2  ,
ivh_revtype3  ,
ivh_revtype4  ,
ivh_totalcharge ,
ivh_charge,
ivh_accessorial_chrg ,
ivh_revtype1_t ,
ivh_revtype2_t ,
ivh_revtype3_t ,
ivh_revtype4_t,
ord_number,
has_credit,
has_rebill,
ivh_definition
from #invoicelist

Drop table #invoicelist


GO
GRANT EXECUTE ON  [dbo].[d_reratebydetail_invlist] TO [public]
GO
