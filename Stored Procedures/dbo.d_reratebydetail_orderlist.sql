SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/* Provides a list of orders to be re rated.
 *  
 * 03/27/2008 - TGRIFFIT - PTS#38849 - params added and logic changes to allow a range of orders to be specified.
 * 
*/

	
CREATE PROCEDURE [dbo].[d_reratebydetail_orderlist]
	(@ratedstatus char(1),
	 @billto varchar(8),
	 @Bookdatestart datetime, 
	 @bookdateend datetime, 
	 @Shipdatestart datetime,
	 @shipdateend datetime, 
	 @orderstatus varchar(6),
	 @tarnumber int,  
	 @tariffnumber varchar(12), 
	 @tariffitem varchar(12), 
	 @revtype1 varchar(8),
	 @revtype2 varchar(8), 
	 @revtype3 varchar(8), 
	 @revtype4 varchar(8), 
	 @minord varchar(12), 
	 @maxord varchar(12),
	 @ord_invoice_effectivedate1 datetime,	-- 62719
	 @ord_invoice_effectivedate2 datetime)	-- 62719
AS


Select @tariffnumber =  RTRIM(IsNull(@tariffnumber,'')) 
Select @tariffitem = RTRIM(IsNull(@tariffitem,'')) 
Select @tarnumber = IsNull(@tarnumber,0)
Select @revtype1 = IsNull(@revtype1,'UNK')
Select @revtype2 = IsNull(@revtype2,'UNK')
Select @revtype3 = IsNull(@revtype3,'UNK')
Select @revtype4 = IsNull(@revtype4,'UNK')
--TGRIFFIT PTS#38849  
Select @minord = IsNull(@minord, '0')
Select @maxord = IsNull(@maxord, '0')

DECLARE @ordrangetype int

IF @minord > 0 AND @maxord > 0 
    SET @ordrangetype = 3
ELSE IF @maxord > 0
    SET @ordrangetype = 2
ELSE IF @minord > 0
    SET @ordrangetype = 1
ELSE
    SET @ordrangetype = 0
--END TGRIFFIT PTS#38849 

Create table #orderlist (
ord_hdrnumber int NULL,
ord_number char(12) null,
ord_billto varchar(8) null,
cmp_name		varchar(60) null,
cty_nmstct  varchar(25) null  ,
ord_bookdate datetime null,
ord_startdate datetime null,
ord_status varchar(6) null,
ord_rateby char(1) null,
tar_number int null,
tar_tariffnumber  varchar(12) null,
tar_tariffitem varchar(12) null,
ord_revtype1 varchar(6) null ,
ord_revtype2 varchar(6) null ,
ord_revtype3 varchar(6) null ,
ord_revtype4 varchar(6) null ,
ord_totalcharge money null,
ord_charge money null,
ord_accessorial_chrg money null,
ord_revtype1_t varchar(8) null,
ord_revtype2_t varchar(8) null,
ord_revtype3_t varchar(8) null,
ord_revtype4_t varchar(8) null
)
If @billto <> 'UNKNOWN'
		Insert Into #orderlist
		Select ord_hdrnumber,
		ord_number,
		ord_billto,
		cmp_name = SUBSTRING(bc.cmp_name,1,60),
		cty_nmstct = bc.cty_nmstct ,
		ord_bookdate,
		ord_startdate,
		ord_status,
		ord_rateby,
		@tarnumber,
		@tariffnumber,
		@tariffitem,
		ord_revtype1 ,
		ord_revtype2 ,
		ord_revtype3,
		ord_revtype4 ,
		ord_totalcharge,
		ord_charge,
		ord_accessorial_chrg,
		'RevType1','RevType2','RevType3','RevType4'
		From orderheader
            INNER JOIN company bc ON bc.cmp_id = ord_billto
		Where  @billto in ('UNKNOWN',ord_billto) 
		and ord_bookdate between @Bookdatestart and @bookdateend
		and ord_startdate between @shipdatestart and @shipdateend
		and	isnull(ord_invoice_effectivedate, '19500101 00:00') between @ord_invoice_effectivedate1 and @ord_invoice_effectivedate2 --62719
		and ord_rateby = 'D'
		and @revtype1 in ('UNK',ord_revtype1)
		and @revtype2 in ('UNK',ord_revtype2)
		and @revtype3 in ('UNK',ord_revtype3)
		and @revtype4 in ('UNK',ord_revtype4)
		and Charindex(ord_status,
        (case @orderstatus 
            When 'L' Then '^AVL^PLN^MPN^DSP^STD^CMP^' 
            When 'Q' Then '^QTE^' 
            When 'M' Then '^MST^' 
            When 'T' Then '^PLN^TND^' 
            Else '%%' End)) > 0
		and ord_invoicestatus in ('PND','AVL')
Else
	Insert Into #orderlist
		Select ord_hdrnumber,
		ord_number,
		ord_billto,
		cmp_name = SUBSTRING(bc.cmp_name,1,60),
		cty_nmstct = bc.cty_nmstct ,
		ord_bookdate,
		ord_startdate,
		ord_status,
		ord_rateby,
		@tarnumber,
		@tariffnumber,
		@tariffitem,
		ord_revtype1 ,
		ord_revtype2 ,
		ord_revtype3,
		ord_revtype4 ,
		ord_totalcharge,
		ord_charge,
		ord_accessorial_chrg,
		'RevType1','RevType2','RevType3','RevType4'
		From orderheader 
            INNER JOIN company bc ON  bc.cmp_id = ord_billto
		Where  ord_bookdate between @Bookdatestart and @bookdateend
		and ord_startdate between @shipdatestart and @shipdateend
		and	isnull(ord_invoice_effectivedate, '19500101 00:00') between @ord_invoice_effectivedate1 and @ord_invoice_effectivedate2 --62719
		and ord_rateby = 'D'
		and @revtype1 in ('UNK',ord_revtype1)
		and @revtype2 in ('UNK',ord_revtype2)
		and @revtype3 in ('UNK',ord_revtype3)
		and @revtype4 in ('UNK',ord_revtype4)
		and Charindex(ord_status,
        (case @orderstatus 
            When 'L' Then '^AVL^PLN^MPN^DSP^STD^CMP^' 
            When 'Q' Then '^QTE^' 
            When 'M' Then '^MST^' 
            When 'T' Then '^PLN^TND^' 
            Else '%%' End)) > 0
		and ord_invoicestatus in ('PND','AVL')
  
If @ratedstatus = 'N' Delete From #orderlist Where ord_charge > 0
Else
  Begin
	If @ratedstatus = 'R' 
		Delete From #orderlist Where ord_charge = 0
	If @tarnumber > 0 
			Delete from #orderlist where Not Exists (Select tar_number from freightdetail ft,stops st
			Where st.ord_hdrnumber = #orderlist.ord_hdrnumber and ft.stp_number = st.stp_number
			and ft.tar_number = @tarnumber)
	If @tariffnumber > '' 
			Delete from #orderlist where Not Exists (Select tar_tariffnumber from freightdetail ft,stops st
			Where st.ord_hdrnumber = #orderlist.ord_hdrnumber and ft.stp_number = st.stp_number
			and ft.tar_tariffnumber = @tariffnumber)
	 End

--TGRIFFIT PTS#38849     
If @ordrangetype = 1 OR @ordrangetype = 3 
    --min ord number range entered
    DELETE FROM #orderlist WHERE ord_hdrnumber < @minord


If @ordrangetype > 1  
    --max ord number range entered
    DELETE FROM #orderlist WHERE ord_hdrnumber > @maxord  
--END TGRIFFIT PTS#38849 

Select ord_hdrnumber ,
ord_number ,
ord_billto ,
cmp_name		,
cty_nmstct  ,
ord_bookdate ,
ord_startdate,
ord_status ,
ord_rateby,
tar_number,
tar_tariffnumber ,
tar_tariffitem ,
ord_revtype1  ,
ord_revtype2  ,
ord_revtype3  ,
ord_revtype4  ,
ord_totalcharge ,
ord_charge,
ord_accessorial_chrg ,
ord_revtype1_t ,
ord_revtype2_t ,
ord_revtype3_t ,
ord_revtype4_t
from #orderlist


Drop table #orderlist


GO
GRANT EXECUTE ON  [dbo].[d_reratebydetail_orderlist] TO [public]
GO
