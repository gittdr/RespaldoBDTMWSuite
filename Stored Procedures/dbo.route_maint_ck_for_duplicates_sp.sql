SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[route_maint_ck_for_duplicates_sp]
@cmp_id_1 varchar(8), @cty_code_1 int, @rtd_zip_1 varchar(10),
@cmp_id_z varchar(8), @cty_code_z int, @rtd_zip_z varchar(10),
@rowcount_in int
AS

/**
 * 
 * NAME:
 * dbo.route_maint_ck_for_duplicates_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:  Retuns route details to dwo for duplicate route comparison in Route Maintenance.
 * 
 * RETURNS:
 * route details result set.
 *
 * RESULT SETS: 
 * route details result set.
 *
 * PARAMETERS: beginning and ending route detail lines.
 *
 * 
 * REVISION HISTORY:
 * 01/29/2009:  PTS 44867 Proc Created.
 *
 **/


create table #rth_id (rth_id int null, max_id int null) 

insert into #rth_id  (rth_id, max_id)
select rth_id, max(rtd_sequence) from routedetail
where rth_id    > 0
group by rth_id
having max(rtd_sequence) = @rowcount_in

CREATE TABLE #temp_routedetail (rth_name varchar(30) null,  
							    rth_id int null,
						        rtd_id int null,
						        cmp_id varchar(8) null,
							    cty_code int null,
							    cty_nmstct varchar(25) null,
				                rtd_zip varchar(10) null,
						        ttr_number  int null,
							    rtd_sequence smallint null )


insert into #temp_routedetail (rth_name,rth_id,rtd_id,cmp_id,cty_code,cty_nmstct,rtd_zip,ttr_number,rtd_sequence)
select rh.rth_name, rd.rth_id, rd.rtd_id, rd.cmp_id, rd.cty_code, rd.cty_nmstct, rd.rtd_zip, rd.ttr_number, rd.rtd_sequence
from routeheader rh , routedetail rd
where rh.rth_id  = rd.rth_id  
and rd.rth_id in (select rth_id from #rth_id) 

select * from #temp_routedetail

GO
GRANT EXECUTE ON  [dbo].[route_maint_ck_for_duplicates_sp] TO [public]
GO
