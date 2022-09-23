SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[d_editlghtriphours_sp] @p_type char(1),@p_key int
as


/**
 * 
 * NAME:
 * dbo.d_editlghtriphours_sp
 *
 * TYPE:
 * [StoredProcedure]
 *
 * DESCRIPTION:
 * This procedure returns by order or by leg all the lgh_triphours fields.
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * lgh_number int
 * cmp_id_start varchar(8)
 * cmp_id_end varchar(8)
 * lgh_startdate datetime
 * lgh_enddate datetime
 * lgh_outstatus varchar(6)
 * lgh_triphours money
 * start_cmp_name  varchar(100)
 * end_cmp_name  varchar(100)
 *
 * PARAMETERS:
 * 001 - @p_type O for retrieve by order, L to retrieve by leg
 * 002 - @p_key  the ord_hdrnumber or lgh_number assovisted with the type
 *
 * REFERENCES: (NONE)

 * 
 * REVISION HISTORY:
 * 11/10/06.01 ? PTS34510- DPETE ? Created for new type of rating (by leg )
 *
 **/
If @p_type = 'O'
select lgh_number
 ,cmp_id_start
 ,cmp_id_end
 ,lgh_startdate
 ,lgh_enddate
 ,lgh_outstatus
 ,s.cmp_name
 ,e.cmp_name
 ,lgh_triphours
 ,actualtime = round((datediff(mi,lgh_startdate,lgh_enddate)/60.0),1)
from legheader
join company s on cmp_id_start = s.cmp_id
join company e on cmp_id_end = e.cmp_id
where lgh_number in ( 
   select distinct lgh_number from stops where ord_hdrnumber = @p_key
   )
order by lgh_startdate

If @p_type = 'M'
select lgh_number
 ,cmp_id_start
 ,cmp_id_end
 ,lgh_startdate
 ,lgh_enddate
 ,lgh_outstatus
 ,s.cmp_name
 ,e.cmp_name
 ,lgh_triphours
 ,actualtime = round((datediff(mi,lgh_startdate,lgh_enddate)/60.0),1)
from legheader
join company s on cmp_id_start = s.cmp_id
join company e on cmp_id_end = e.cmp_id
where lgh_number in ( 
   select distinct lgh_number from stops where mov_number = @p_key
   )
order by lgh_startdate


If @p_type = 'T'
select lgh_number
 ,cmp_id_start
 ,cmp_id_end
 ,lgh_startdate
 ,lgh_enddate
 ,lgh_outstatus
 ,s.cmp_name
 ,e.cmp_name
 ,lgh_triphours
 ,actualtime = round((datediff(mi,lgh_startdate,lgh_enddate)/60.0),1)
from legheader
join company s on cmp_id_start = s.cmp_id
join company e on cmp_id_end = e.cmp_id
where lgh_number = @p_key
order by lgh_startdate



GO
GRANT EXECUTE ON  [dbo].[d_editlghtriphours_sp] TO [public]
GO
