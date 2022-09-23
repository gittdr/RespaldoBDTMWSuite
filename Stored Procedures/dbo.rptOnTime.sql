SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[rptOnTime]
	(
	@StartDate 	datetime,
	@EndDate 	datetime,
	@Revclass1 	varchar(6),
	@Revclass2 	varchar(6),
	@Revclass3 	varchar(6),
	@Revclass4 	varchar(6),
	@Shipper	varchar(8),
	@Consignee	varchar(8),
	@Billto		varchar(8)
	)
AS

Select distinct ord_hdrnumber ordHNum
into #t
from legheader 
where
	lgh_startdate >=@StartDate and
	lgh_startdate <=@EndDate


Select 
	distinct Orderheader.mov_number	MoveNum,
	Orderheader.Ord_hdrnumber	OrdNumber,		
	C1.cmp_name 			ShipperName,
	C1.cty_nmstct 			ShipperCity,
	C2.cmp_name 			ConsigneeName,
	C2.cty_nmstct 			ConsigneeCity,
	ord_origin_latestdate 		SchedPU,
	ord_startdate			ActualPU,
	ord_dest_latestdate		SchedDEL,
	ord_completiondate		ActualDel,
	Datediff(mi, 
		ord_origin_latestdate,
		ord_startdate)		PUVar,
	Datediff(mi, 
		ord_dest_latestdate,
		ord_completiondate)	DelVar,
	s1.stp_reasonlate		PUCode,
	s2.stp_reasonlate		DelCode

From
	#t,
	Orderheader,
	company C1,
	Company C2,
	stops	s1 with(index=sk_stp_ordnum),
	stops	s2 with(index=sk_stp_ordnum)
Where
	#t.ordHNum =Orderheader.ord_hdrNumber
	and 
	ord_startdate >@StartDate
	and
	ord_startdate <@EndDate
	AND
	C1.cmp_id =ord_shipper
	AND
	c2.cmp_id=ord_consignee	
	AND
	s1.Ord_hdrNumber=orderheader.ord_hdrnumber
	AND
	S1.stp_type='DRP'
	and
	s2.Ord_hdrNumber=orderheader.ord_hdrnumber
	and
	S2.stp_type='PUP'
	AND
	(@Revclass1 =ord_revtype1 or @Revclass1='')
	AND
	(@Revclass2 =ord_revtype2 or @Revclass2='')
	AND
	(@Revclass3 =ord_revtype2 or @Revclass3='')
	AND
	(@Revclass4 =ord_revtype4 or @Revclass4='')
	AND
	(@Shipper =ord_shipper or @Shipper='')
	AND
	(@Consignee =ord_consignee or @Consignee='')
	AND
	(@Billto =ord_billto or @Billto='')
Order by Orderheader.Ord_hdrnumber

Drop table #t
GO
GRANT EXECUTE ON  [dbo].[rptOnTime] TO [public]
GO
