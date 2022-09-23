SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[HVLISummaryManagementHeaderView]
AS
  SELECT 
      /*** The following columns MUST be present in view. Column names must be identical and are case-sensitive ***/
	  ord.ord_billto 'BillToId'
	 , ord.ord_billto +'-' + ord.ord_shipper 'BillToShipper'
	  /*** END required fields ***/
	 , bt.cmp_name 'BillToName'     
     , ord.ord_shipper as 'ShipperId'
	 ,SUBSTRING(convert(varchar(20), cmp.cmp_primaryphone), 1, 3) + '-' + 
				  SUBSTRING(convert(varchar(20), cmp.cmp_primaryphone), 4, 3) + '-' + 
						  SUBSTRING(convert(varchar(20), cmp.cmp_primaryphone), 7, 4) 'ShipperPhone'
		, case when isdate(cmp.cmp_misc1)=1 then
		case when datediff(mi, cast(cmp.cmp_misc1 as datetime), getdate())<60
			then convert(varchar(100), (60-(datediff(mi, cast(cmp.cmp_misc1 as datetime), getdate())))) + ' min' else 'NOW' end else '' end 'Call'

		-- Hours for this shipper for today.
		, case datepart(dw, getdate())
			when 1 then convert(varchar(10),cmp.cmp_opens_su) + ' - ' + convert(varchar(10),cmp.cmp_closes_su)
			when 2 then convert(varchar(10),cmp.cmp_opens_mo) + ' - ' + convert(varchar(10),cmp.cmp_closes_mo)
			when 3 then convert(varchar(10),cmp.cmp_opens_tu) + ' - ' + convert(varchar(10),cmp.cmp_closes_tu)
			when 4 then convert(varchar(10),cmp.cmp_opens_we) + ' - ' + convert(varchar(10),cmp.cmp_closes_we)
			when 5 then convert(varchar(10),cmp.cmp_opens_th) + ' - ' + convert(varchar(10),cmp.cmp_closes_th)
			when 6 then convert(varchar(10),cmp.cmp_opens_fr) + ' - ' + convert(varchar(10),cmp.cmp_closes_fr)
			when 7 then convert(varchar(10),cmp.cmp_opens_sa) + ' - ' + convert(varchar(10),cmp.cmp_closes_sa)
			else '9:00-5:00' end 'Time'
		, MAX(ord.ord_revtype1) 'RevType1'
		, MAX(ord.ord_revtype2)'RevType2'
		, MAX(ord.ord_revtype3) 'RevType3'
		, MAX(ord.ord_revtype4) 'RevType4'
		-- using cmp_misc2 to hold the number of loads they shipper has on the floor
		, isnull(case when ISNUMERIC(cmp.cmp_misc2) =1 Then convert(int, cmp.cmp_misc2) else NULL end , 0) 'Floor'


		-- using cmp_misc3 to hold the number of loads they have pre-loaded in trailers waiting to be picked up
		, isnull(case when ISNUMERIC(cmp.cmp_misc3) =1 then convert(int, cmp.cmp_misc3) else NULL end, 0) 'Trailer'

		-- number of trucks planned for this shipper
		, (select
			count(stp.stp_number)
			from stops stp
			inner join legheader lgh on lgh.lgh_number=stp.lgh_number
			inner join orderheader ord7 on stp.ord_hdrnumber=ord7.ord_hdrnumber and stp.cmp_id=ord.ord_shipper
			where 
			stp.stp_event in ('LLD','HPL')
			and lgh.lgh_outstatus in ('PLN','STD','DSP')
			and stp.stp_departure_status='OPN'
			and ord7.ord_billto=ord.ord_billto
			)  'Enroute'

		---- supposed to be a count of completed jobs today
		, sum (case ord.ord_status when 'CMP' then 1 else 0 end) 'Done'
		, isnull(case when ISNUMERIC(cmp.cmp_misc2) =1 Then convert(int, cmp.cmp_misc2) else NULL end , 0) +
		  isnull(case when ISNUMERIC(cmp.cmp_misc3) =1 then convert(int, cmp.cmp_misc3) else NULL end, 0) + 
		   (select
			count(stp.stp_number)
			from stops stp
			inner join legheader lgh on lgh.lgh_number=stp.lgh_number
			inner join orderheader ord7 on stp.ord_hdrnumber=ord7.ord_hdrnumber and stp.cmp_id=ord.ord_shipper
			where 
			stp.stp_event in ('LLD','HPL')
			and lgh.lgh_outstatus in ('PLN','STD','DSP')
			and stp.stp_departure_status='OPN'
			and ord7.ord_billto=ord.ord_billto
			) +
			sum (case ord.ord_status when 'CMP' then 1 else 0 end) 'Total'
		from orderheader ord
		inner join company cmp  (NOLOCK) on cmp.cmp_id=ord.ord_shipper
		inner join company bt  (NOLOCK) on bt.cmp_id=ord.ord_billto
		left join legheader lgh  (NOLOCK) on lgh.ord_hdrnumber   = ord.ord_hdrnumber		
		where ord.ord_billto in (select ord6.ord_billto from orderheader ord6 where not ord_status in ('job','mst')) 
      and ord_startdate between DATEADD(hour,-18,getDate()) and DATEADD(hour,18,getDate())

GROUP BY ord.ord_billto
	   , bt.cmp_name
	   , ord.ord_shipper
	   , cmp.cmp_primaryphone
	   , cmp.cmp_misc1
	   , cmp.cmp_opens_su
	   , cmp.cmp_closes_su
	   , cmp.cmp_opens_mo
	   , cmp.cmp_closes_mo
	   , cmp.cmp_opens_tu
	   , cmp.cmp_closes_tu
	   , cmp.cmp_opens_we
	   , cmp.cmp_closes_we
	   , cmp.cmp_opens_th
	   , cmp.cmp_closes_th
	   , cmp.cmp_opens_fr
	   , cmp.cmp_closes_fr
	   , cmp.cmp_opens_sa
	   , cmp.cmp_closes_sa  	   
	   , cmp.cmp_misc2
	   , cmp.cmp_misc3	
GO
GRANT INSERT ON  [dbo].[HVLISummaryManagementHeaderView] TO [public]
GO
GRANT SELECT ON  [dbo].[HVLISummaryManagementHeaderView] TO [public]
GO
GRANT UPDATE ON  [dbo].[HVLISummaryManagementHeaderView] TO [public]
GO
