SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[HVLISiteManagementHeaderView]
AS
  SELECT
      /*** The following columns MUST be present in view. Column names must be identical and are case-sensitive ***/
       ord.ord_consignee as LocationId
	  /*** END required fields ***/

     , sum(case ord.ord_status when 'CMP' then ord.ord_totalweight else 0 end) 'WeightToday'
     , sum (case ord.ord_status when 'CMP' then 1 else 0 end) 'Jobs'
		-- Jobs left to deliver here today
	 , isnull((select sum(ord7.ord_job_remaining) from orderheader ord7 where ord7.ord_consignee=ord.ord_consignee), 0) 'Remaining'
     , case datepart(dw, getdate())
			when 1 then convert(varchar(10),cmp.cmp_opens_su) + ' - ' + convert(varchar(10),cmp.cmp_closes_su)
			when 2 then convert(varchar(10),cmp.cmp_opens_mo) + ' - ' + convert(varchar(10),cmp.cmp_closes_mo)
			when 3 then convert(varchar(10),cmp.cmp_opens_tu) + ' - ' + convert(varchar(10),cmp.cmp_closes_tu)
			when 4 then convert(varchar(10),cmp.cmp_opens_we) + ' - ' + convert(varchar(10),cmp.cmp_closes_we)
			when 5 then convert(varchar(10),cmp.cmp_opens_th) + ' - ' + convert(varchar(10),cmp.cmp_closes_th)
			when 6 then convert(varchar(10),cmp.cmp_opens_fr) + ' - ' + convert(varchar(10),cmp.cmp_closes_fr)
			when 7 then convert(varchar(10),cmp.cmp_opens_sa) + ' - ' + convert(varchar(10),cmp.cmp_closes_sa)
			else '' end 'Time'
     -- Drivers Completed at this location
	, (select count(distinct ord7.ord_hdrnumber) from orderheader ord7
		inner join stops stp7 on stp7.ord_hdrnumber=ord7.ord_hdrnumber
		where stp7.stp_event in ('LUL','DRL')
			and stp7.stp_departure_status='CMP'
			and stp7.cmp_id=ord.ord_consignee) 'Completed'

		-- Drivers Arrived at this location THIS ONE IS NOT RIGHT.
		, (select count(distinct ord7.ord_hdrnumber) from orderheader ord7
			inner join stops stp7 on stp7.ord_hdrnumber=ord7.ord_hdrnumber
			where stp7.stp_event in ('LUL','DRL')
			and stp7.stp_departure_status='ARV'
			and stp7.cmp_id=ord.ord_consignee) 'Unloading'


		-- Drivers enroute or currently at this location
		, (select count(distinct ord7.ord_hdrnumber) from orderheader ord7
			inner join stops stp7 on stp7.ord_hdrnumber=ord7.ord_hdrnumber
			where stp7.stp_event in ('LUL','DRL')
			and stp7.stp_departure_status='OPN'
			and stp7.cmp_id=ord.ord_consignee) 'Enroute'

		-- Drivers loading at this location THIS ONE IS NOT RIGHT.
		, (select count(distinct ord7.ord_hdrnumber) from orderheader ord7
			inner join stops stp7 on stp7.ord_hdrnumber=ord7.ord_hdrnumber
			where stp7.stp_event in ('LLD','HLT')
			and stp7.stp_departure_status='ACT'
			and stp7.cmp_id=ord.ord_consignee) 'Loading'

		-- Drivers loading at this location THIS ONE IS NOT RIGHT.
		, (select count(distinct ord7.ord_hdrnumber) from orderheader ord7
			inner join stops stp7 on stp7.ord_hdrnumber=ord7.ord_hdrnumber
			where stp7.stp_event in ('LLD','HLT')
			and stp7.stp_departure_status='OPN'
			and stp7.cmp_id=ord.ord_consignee) 'Waiting'
    from orderheader ord
		inner join company cmp (NOLOCK) on cmp.cmp_id=ord.ord_consignee
		left join legheader lgh (NOLOCK) on lgh.ord_hdrnumber   = ord.ord_hdrnumber
   where ord_status not in ('MST','QTE')
	 and ord_startdate between DATEADD(hour,-18,getDate()) and DATEADD(hour,18,getDate()) 
GROUP BY ord.ord_consignee
	   , cmp_opens_su
	   , cmp_closes_su
	   , cmp_opens_mo
	   , cmp_closes_mo
	   , cmp_opens_tu
	   , cmp_closes_tu
	   , cmp_opens_we
	   , cmp_closes_we
	   , cmp_opens_th
	   , cmp_closes_th
	   , cmp_opens_fr
	   , cmp_closes_fr
	   , cmp_opens_sa
	   , cmp_closes_sa  	   
GO
GRANT INSERT ON  [dbo].[HVLISiteManagementHeaderView] TO [public]
GO
GRANT SELECT ON  [dbo].[HVLISiteManagementHeaderView] TO [public]
GO
GRANT UPDATE ON  [dbo].[HVLISiteManagementHeaderView] TO [public]
GO
