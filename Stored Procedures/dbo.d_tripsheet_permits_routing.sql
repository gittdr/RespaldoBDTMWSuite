SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_tripsheet_permits_routing] (@p_p_id int)
AS

/**
 * 
 * NAME:
 * dbo.d_tripsheet_permits_routing
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns a result set for a permit trip sheet routing 
 * sub report it concatinates all the details into a comman delimited string
 *
 * RETURNS:
 * None.
 *
 * RESULT SETS: 
 * 
 * origin      City of Origin for the Route
 * dest        City of Dest for the Route
 * name        Name of the route
 * directions  concatinated directions
 * PARAMETERS:
 * 001 - @p_p_id permit ID that the route is attached to
 *
 * 
 *
 * Revision History
 * 4/12/05	-	Jason Bauwin	-	Inital Release
*/

declare @v_text varchar(8000)

set @v_text = ''

select @v_text = case 
				when len(@v_text) > 0 then @v_text + ', ' + isnull(prda_direction,'') + 
                                                   CASE  
                                                    WHEN len(isnull(prda_direction,'')) > 0 THEN ' on '
                                                    ELSE '' END + 
                                                 isnull(prda_route,'') + 
                                                 CASE 
                                                    WHEN len(isnull(prda_tointersection,'')) > 0 THEN ' to '
                                                    ELSE '' END + 
                                                 isnull(prda_tointersection,'')
				else  isnull(prda_direction,'') + 
                  CASE  
                   WHEN len(isnull(prda_direction,'')) > 0 THEN ' on '
                   ELSE '' END + 
                isnull(prda_route,'') + 
                CASE 
                   WHEN len(isnull(prda_tointersection,'')) > 0 THEN ' to '
                   ELSE '' END + 
                isnull(prda_tointersection,'') end
    from permit_route_altered 
    join permit_route_detail_altered on permit_route_detail_altered.prta_id = permit_route_altered.prta_id
   where permit_route_altered.p_id = @p_p_id
   order by prda_sequence

if len(rtrim(ltrim(@v_text))) < 1
select @v_text = case 
				when len(@v_text) > 0 then @v_text + ', ' + isnull(pdr_direction,'') + 
                                                   CASE  
                                                    WHEN len(isnull(pdr_direction,'')) > 0 THEN ' on '
                                                    ELSE '' END + 
                                                 isnull(pdr_route,'') + 
                                                 CASE 
                                                    WHEN len(isnull(pdr_tointersection,'')) > 0 THEN ' to '
                                                    ELSE '' END + 
                                                 isnull(pdr_tointersection,'')
				else  isnull(pdr_direction,'') + 
                  CASE  
                   WHEN len(isnull(pdr_direction,'')) > 0 THEN ' on '
                   ELSE '' END + 
                isnull(pdr_route,'') + 
                CASE 
                   WHEN len(isnull(pdr_tointersection,'')) > 0 THEN ' to '
                   ELSE '' END + 
                isnull(pdr_tointersection,'') end
    from permit_route
    join permits on permits.prt_id = permit_route.prt_id
    join permit_route_detail on permit_route_detail.prt_id = permit_route.prt_id
   where permits.p_id = @p_p_id 
   order by pdr_sequence

select (CASE  WHEN prta_originnmstct <> 'UNKNOWN' 
                  THEN left(prta_originnmstct, len(prta_originnmstct) -1) 
                ELSE prta_originnmstct END) as 'origin',
         (CASE  WHEN prta_DestinationNmstct <> 'UNKNOWN' 
                  THEN left(prta_DestinationNmstct, len(prta_DestinationNmstct) -1)
                ELSE prta_DestinationNmstct END) as 'dest',
        prta_name as 'name',
        @v_text as 'directions'
  from permit_route_altered
 where permit_route_altered.p_id = @p_p_id
UNION
select (CASE  WHEN prt_originnmstct <> 'UNKNOWN' 
                  THEN left(prt_originnmstct, len(prt_originnmstct) -1) 
                ELSE prt_originnmstct END) as 'origin',
         (CASE  WHEN prt_destinationnmstct <> 'UNKNOWN' 
                  THEN left(prt_destinationnmstct, len(prt_destinationnmstct) -1)
                ELSE prt_destinationnmstct END) as 'dest',
        prt_name as 'name',
        @v_text as 'directions'
  from permit_route
  join permits on permits.prt_id = permit_route.prt_id
 where permits.p_id = @p_p_id


GO
GRANT EXECUTE ON  [dbo].[d_tripsheet_permits_routing] TO [public]
GO
