SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[getTSTIMEData_sp] @p_ord int,@p_tar int
as

/*
Assumption:
   There is a single tariff that contains all the rates to be applied for the order
   That tariff has a rows table with either a tractor or trailer type for allowing different rates by type of equipment
   Only orders billed to the same company as the order being rated are to be returned for computing the total loaded weight on the truck (Holland
       may have a truck go out to pick up the orders to be rated by leg, but during that trip do a quick side job. That order's cargo is 
       not to be included in the total weight 

Returns a list of all the orders on each leg of the trip that the passed order was on (orders billed to the same customer)
Returns information about the tractor and trailer on each of those legs including the
    tractor or trailer type value as indicated by the row match value for the tariff number passed (see first assumption) 


*/
/**
 * 
 * NAME:
 * dbo.getTripSegRateData_s
 *
 * TYPE:
 * [StoredProcedure]
 *
 * DESCRIPTION:
 * This procedure returns data needed to apply multiple charges for a charge unit basis TSTIME 
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * lgh_number int
 * lgh_tractor
 * lgh_primary_trailer
 * time decimal(9,1) in hours - either the hours manually set on the legheader or the difference in hours between lgh_startdate and lgh_enddate
 * matchvalue the tractor or trailer type (as indicated by the row match value of the passed tariff) of the equipment assigned to each leg
 * rate money - the rate for the equipement on the leg for the type as required by the tariff table
 * sum(ord_totalweight) - total weight of all orders on the leg (billed to the same company as the order being rated)
 *
 * PARAMETERS:
 * 001 - @p_ord int the ord_hdrnumber of the order being rated
 * 002 - @p_tar the tar_number of the tariff selected by the rating engine for this order
 *
 * REFERENCES: (NONE)

 * 
 * REVISION HISTORY:
 * 11/09/06.01 ? PTS34510- DPETE ? Created for new type of rating (by leg )
 * 3/6/7 - PTS 36053 DPETE if delivery leg is doen by a carrier there shoukd be no charge for that leg (additional custoemr requirement)
 * 4/30/07 PTS 37276 gettin charges for legs not on trip
 * 6/01/07 PTS 37767 EMK - This version contains a hot fix workaround for the problem of incorrect ord_totalweight that
 * 							dispatch puts in.
 * 3/1/609 DPETE  PTS46382 add count allocation as an option
 **/


declare @v_billto varchar(8),@v_roworcoltype varchar(6),@v_roworcol char(1) ,@cmprateallocation char(1)

create  table #legdata (lgh_number int null
,lgh_tractor varchar(8) null
,lgh_primary_trailer varchar(13) null
,time decimal(12,1) null
,matchvalue varchar(6)null
,Rate money null
,lgh_startdate datetime null)

declare @ords table (ord_hdrnumber int null)
 
select @v_billto = ord_billto ,@cmprateallocation = isnull(cmp_rateallocation,'W')
from orderheader
join company on ord_billto = cmp_id 
where ord_hdrnumber = @p_ord 



select @v_roworcol = 'R'
select @v_roworcoltype = tar_rowbasis from tariffheader where tar_number = @p_tar
If Left(@v_roworcoltype,2)  <> 'TL' and Left(@v_roworcoltype,2)  <> 'TC'
  BEGIN
  select @v_roworcoltype = tar_colbasis from tariffheader where tar_number = @p_tar
  select @v_roworcol = 'C'
  END

If Left(@v_roworcoltype,2)  = 'TL'
	insert into #legdata (lgh_number,lgh_tractor,lgh_primary_trailer,time,matchvalue,lgh_startdate)
	select distinct legheader.lgh_number
		 ,lgh_tractor
		 ,lgh_primary_trailer 
		 , time = case isnull(lgh_triphours,0) when 0 then round((datediff(mi,lgh_startdate,lgh_enddate)/60.0),1) else lgh_triphours end
		 ,matchvalue = case @v_roworcoltype 
		 when 'TL1' then trailerprofile.trl_type1
		 when 'TL2' then trailerprofile.trl_type2
		 when 'TL3' then trailerprofile.trl_type3
		 when 'TL4' then trailerprofile.trl_type4
		 end
         ,lgh_startdate
	 from legheader  
	 join (select distinct mov_number from stops where ord_hdrnumber = @p_ord) ordmov 
		 on legheader.mov_number = ordmov.mov_number
	 join trailerprofile on (legheader.lgh_primary_trailer = trailerprofile.trl_id and isnull(legheader.lgh_primary_trailer,'UNKNOWN') <> 'UNKNOWN')
     where exists (select 1 from stops where stops.lgh_number = legheader.lgh_number and ord_hdrnumber = @p_ord)



If Left(@v_roworcoltype,2)  = 'TC'
	insert into #legdata (lgh_number,lgh_tractor,lgh_primary_trailer,time,matchvalue,lgh_startdate)
	select distinct legheader.lgh_number
		 ,lgh_tractor
		 ,lgh_primary_trailer 
		 , time = case isnull(lgh_triphours,0) when 0 then round((datediff(mi,lgh_startdate,lgh_enddate)/60.0),1) else lgh_triphours end
         ,matchvalue = case @v_roworcoltype 
         when 'TC1' then tractorprofile.trc_type1
         when 'TC2' then tractorprofile.trc_type2
         when 'TC3' then tractorprofile.trc_type3
         when 'TC4' then tractorprofile.trc_type4
         end
         ,lgh_startdate
	     from legheader  
		 join (select distinct mov_number from stops where ord_hdrnumber = @p_ord) ordmov 
			 on legheader.mov_number = ordmov.mov_number
         join tractorprofile on (legheader.lgh_tractor = tractorprofile.trc_number and isnull(legheader.lgh_tractor,'UNKNOWN') <> 'UNKNOWN')
         where exists (select 1 from stops where stops.lgh_number = legheader.lgh_number and ord_hdrnumber = @p_ord)



/* for future allow for a tariff with no table If Left(@v_roworcoltype,2)  = 'NOT' */
If @v_roworcol = 'R'
  update #legdata
  set rate = tra_rate
  from tariffrate
  where tar_number = @p_tar
  and trc_number_row = (select trc_number 
                      from tariffrowcolumn 
                      where tar_number = @p_tar
                      and trc_rowcolumn =  'R'  
                      and trc_matchvalue = #legdata.matchvalue)
else
  update #legdata
  set rate = tra_rate
  from tariffrate
  where tar_number = @p_tar
  and trc_number_col = (select trc_number 
                      from tariffrowcolumn 
                      where tar_number = @p_tar
                      and trc_rowcolumn =  'C'  
                      and trc_matchvalue = #legdata.matchvalue)

select  lgh_number
  ,lgh_tractor
  ,lgh_primary_trailer
  ,time
  ,matchvalue
  ,rate
  -- PTS 37767 6/1/07 EMK 
 -- ,totalweight = (select sum(isnull(ord_totalweight,0)) from orderheader where ord_hdrnumber in
 --                  (select distinct ord_hdrnumber from stops where stops.lgh_number = #legdata.lgh_number) and ord_billto = @v_billto)
	,totalweight = (Select sum(isnull(fgt_weight,0)) from freightdetail where stp_number in
 (select stp_number from stops where ord_hdrnumber IN (select distinct stops.ord_hdrnumber from stops
														join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber 
														where stops.ord_hdrnumber > 0
                                                        and stops.lgh_number = #legdata.lgh_number
														and orderheader.ord_billto = @v_billto) 
	and stp_type = 'DRP'))
-- PTS 37767
,totalcount = (Select sum(isnull(fgt_count,0)) from freightdetail where stp_number in
 (select stp_number from stops where ord_hdrnumber IN (select distinct stops.ord_hdrnumber from stops
														join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber 
														where  stops.ord_hdrnumber > 0
                                                        and stops.lgh_number = #legdata.lgh_number
														and orderheader.ord_billto = @v_billto) 
	and stp_type = 'DRP'))
,@cmprateallocation cmp_rateallocation

from #legdata  
order by lgh_startdate

drop table #legdata
GO
GRANT EXECUTE ON  [dbo].[getTSTIMEData_sp] TO [public]
GO
