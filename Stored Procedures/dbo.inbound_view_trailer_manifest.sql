SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[inbound_view_trailer_manifest] (
                                                 @p_startdate datetime,
                                                 @p_days_out int)
AS

/**
 * 
 * NAME:
 * dbo.inbound_view_trailer_manifest
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure displays the route buckets for trailer manifesting for a determined number of days out
 *
 *
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001   @p_startdate
 *       This paramater indicates the start date of the retrieval
 * 002 - @p_days_out int
 *       This parameter indicates the number of days out to display the route buckets
 *
 * 
 * REVISION HISTORY:
 * 05/31/2006.01 ? PTS33237 - Jason Bauwin ? Original Release
 *
 **/
declare @v_today datetime, @v_lastday datetime, @v_loopdate datetime
declare @v_counter int
declare @ls_displaycurr varchar(60)

declare @results table(
                       master_route_id			int,
                       route_description		varchar(50),
                       delivery_date			datetime,
                       lrm_batch				tinyint,
                       load_desc				varchar(1000),
                       consolidated_leg_count	int,
                       pallet_count				int,
                       case_count				int,
					   mileage					int,
					   count2					int,
					   volume					float,
					   weight					float,
					   total_charges			money
                      )

declare @temp table(
					lrh_id				int,
					lrm_date			datetime,
					lrm_batch			int,
					ord_hdrnumber		int,
					total_conv_charges	money
				    )
    


if @p_days_out > 7
begin
  set @p_days_out = 7
end

select @v_today = convert(datetime,convert(varchar(2),DATEPART(m, @p_startdate)) + '/' + convert(varchar(2),DATEPART(dd, @p_startdate)) + '/' + convert(varchar(10),DATEPART(yyyy, @p_startdate)))
select @v_lastday = dateadd(dd, @p_days_out, @v_today)



--first pull in all of the routes that are setup from the masters to display on the days provided
set @v_counter = 0
while @v_counter < @p_days_out
begin
   set @v_loopdate = dateadd(d, @v_counter, @v_today)
       INSERT INTO @results (master_route_id,
                             route_description,
                             delivery_date)
      select lrh_id, lrh_name, @v_loopdate
        from ltl_routeheader
       where ((select datepart(dw,convert(datetime,convert(varchar(2),DATEPART(m, @v_loopdate)) + '/' + convert(varchar(2),DATEPART(dd, @v_loopdate)) + '/' + convert(varchar(10),DATEPART(yyyy, @v_loopdate))))) = 1 and (lrh_avl_sun = 'Y')
          OR (select datepart(dw,convert(datetime,convert(varchar(2),DATEPART(m, @v_loopdate)) + '/' + convert(varchar(2),DATEPART(dd, @v_loopdate)) + '/' + convert(varchar(10),DATEPART(yyyy, @v_loopdate))))) = 2 and (lrh_avl_mon = 'Y')
          OR (select datepart(dw,convert(datetime,convert(varchar(2),DATEPART(m, @v_loopdate)) + '/' + convert(varchar(2),DATEPART(dd, @v_loopdate)) + '/' + convert(varchar(10),DATEPART(yyyy, @v_loopdate))))) = 3 and (lrh_avl_tue = 'Y')
          OR (select datepart(dw,convert(datetime,convert(varchar(2),DATEPART(m, @v_loopdate)) + '/' + convert(varchar(2),DATEPART(dd, @v_loopdate)) + '/' + convert(varchar(10),DATEPART(yyyy, @v_loopdate))))) = 4 and (lrh_avl_wed = 'Y')
          OR (select datepart(dw,convert(datetime,convert(varchar(2),DATEPART(m, @v_loopdate)) + '/' + convert(varchar(2),DATEPART(dd, @v_loopdate)) + '/' + convert(varchar(10),DATEPART(yyyy, @v_loopdate))))) = 5 and (lrh_avl_thu = 'Y')
          OR (select datepart(dw,convert(datetime,convert(varchar(2),DATEPART(m, @v_loopdate)) + '/' + convert(varchar(2),DATEPART(dd, @v_loopdate)) + '/' + convert(varchar(10),DATEPART(yyyy, @v_loopdate))))) = 6 and (lrh_avl_fri = 'Y')
          OR (select datepart(dw,convert(datetime,convert(varchar(2),DATEPART(m, @v_loopdate)) + '/' + convert(varchar(2),DATEPART(dd, @v_loopdate)) + '/' + convert(varchar(10),DATEPART(yyyy, @v_loopdate))))) = 7 and (lrh_avl_sat = 'Y'))
         AND @v_loopdate between lrh_effective_date and lrh_terminate_date

   SELECT @v_counter = @v_counter + 1
end
   

--now delete any default bucket that has a bucket already for that route and day
delete @results
  from @results r,
       ltl_route_mapping ltl 
 where r.delivery_date = ltl.lrm_date 
   and r.master_route_id = ltl.lrh_id

--get the default display currency
select @ls_displaycurr = gi_string1
  from generalinfo
 where gi_name = 'TrailerManifestDisplayCurrency'

--now get all the buckets that have already been started for the day
insert into @results (master_route_id,
                      route_description,
                      delivery_date,
                      lrm_batch,
                      consolidated_leg_count,
                      pallet_count,
                      case_count,
					  count2,
					  volume,
					  weight
                     )
select ltl.lrh_id,
       ltl.lrm_name,
       ltl.lrm_date,
       ltl.lrm_batch,
       (select count(distinct lgh_number) 
          from ltl_route_mapping ltl2 
         where ltl.lrh_id = ltl2.lrh_id
           and ltl.lrm_date = ltl2.lrm_date
           and ltl.lrm_batch = ltl2.lrm_batch),
       sum(isnull(f.fgt_pallets_out,0)),
       sum(isnull(f.fgt_count,0)),
       sum(isnull(f.fgt_count2,0)),
       sum(isnull(f.fgt_volume,0.00)),
       sum(isnull(f.fgt_weight,0.00))

  from ltl_route_mapping ltl
  join ltl_routeheader lrh on lrh.lrh_id = ltl.lrh_id
  left outer join legheader l on ltl.lgh_number = l.lgh_number
  left outer join stops s on s.lgh_number = l.lgh_number  and s.ord_hdrnumber > 0 and (s.stp_type = 'DRP' OR stp_event = 'XDU')
  left outer join freightdetail f on f.stp_number = s.stp_number
  --left outer join ltl_route_detail ltld on ltld.stp_number = s.stp_number
  where isnull(ltl.mov_number, 0) = 0
  group by ltl.lrh_id, ltl.lrm_name, ltl.lrm_date, ltl.lrm_batch

update @results set mileage = (select sum(lrd_mileage)
                                 from ltl_route_detail ltld
                                 join ltl_route_mapping ltlm on ltlm.lrm_id = ltld.lrm_id
                                 join legheader l on l.lgh_number = ltlm.lgh_number
                                where ltlm.lrh_id = r.master_route_id
                                  and ltlm.lrm_date = r.delivery_date
                                  and ltlm.lrm_batch = r.lrm_batch)
 from @results r

insert into @temp (lrh_id, lrm_date, lrm_batch, ord_hdrnumber, total_conv_charges)
select lrm.lrh_id, lrm.lrm_date, lrm.lrm_batch, s.ord_hdrnumber, dbo.fn_currency_conversion(ord_totalcharge, getdate(), ord_currency, @ls_displaycurr)
  from ltl_route_mapping lrm
  join ltl_route_detail lrd on lrm.lrm_id = lrd.lrm_id
  join stops s on s.stp_number = lrd.stp_number
  join orderheader o on s.ord_hdrnumber = o.ord_hdrnumber
 where lrm.mov_number is null
   and s.ord_hdrnumber > 0
   and (s.stp_type = 'DRP' or s.stp_event = 'XDU')
group by lrm.lrh_id, lrm.lrm_date, lrm.lrm_batch, s.ord_hdrnumber, dbo.fn_currency_conversion(ord_totalcharge, getdate(), ord_currency, @ls_displaycurr)

update @results
   set total_charges = (select sum(total_conv_charges) 
                          from @temp t 
                         where r.master_route_id = t.lrh_id 
                           and r.delivery_date = t.lrm_date 
                           and r.lrm_batch = t.lrm_batch)
  from @results r

select r.master_route_id,
       r.route_description,
       r.delivery_date,
       r.lrm_batch,
       r.consolidated_leg_count,
       r.pallet_count,
       r.case_count,
       lrh_max_orders,
       lrh.lrh_max_count,
       lrh.lrh_max_count_uom,
       lrh.lrh_max_weight,
       lrh.lrh_max_weight_uom,
       lrh.lrh_max_volume,
       lrh.lrh_max_volume_uom,
       lrh.lrh_warn_orders,
       lrh.lrh_warn_count,
       lrh.lrh_warn_count_uom,
       lrh.lrh_warn_weight,
       lrh.lrh_warn_weight_uom,
       lrh.lrh_warn_volume,
       lrh.lrh_warn_volume_uom,
       lrh.lrh_warn_count2,
       lrh.lrh_warn_count2_uom,
	   isnull(r.mileage,1) as 'mileage',
	   isnull(r.total_charges,0.00) as total_charges,
	   isnull(r.total_charges,0.00)/isnull(r.mileage,1) as 'RevPerMile',
	   isnull(r.count2, 0.00) as 'count2',
	   isnull(volume, 0.00) as 'volume',
	   isnull(weight, 0.00) as 'weight'
    from @results r
  join ltl_routeheader lrh on r.master_route_id = lrh.lrh_id
 order by delivery_date, isnull(lrm_batch,1), r.consolidated_leg_count desc


GO
GRANT EXECUTE ON  [dbo].[inbound_view_trailer_manifest] TO [public]
GO
