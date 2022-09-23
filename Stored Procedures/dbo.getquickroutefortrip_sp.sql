SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Arrange on report to send both args as zero except on firts row
   so we can return no rows and autosoze height to nothing
DPETE

*/

CREATE 	PROCEDURE [dbo].[getquickroutefortrip_sp] @mov int,@leg int
AS

If @mov > 0 
  Select  stops.cmp_name
  ,cityname =  cty_name
  ,state = cty_state
  ,stp_event
  ,stp_arrivaldate
  ,eventname = eventcodetable.name
  From stops
  Join city on cty_code = stp_city
  JOIN eventcodetable on abbr = stp_event
  Where mov_number =  @mov
  And stp_event not in ('RTP','TRP')
  Order by stp_arrivaldate
If @mov = 0 and @leg > 0 
  Select  stops.cmp_name
  ,cityname =  cty_name
  ,state = cty_state
  ,stp_event
  ,stp_arrivaldate
  ,eventname = eventcodetable.name
  From stops
  Join city on cty_code = stp_city
  JOIN eventcodetable on abbr = stp_event
  Where lgh_number =  @leg
  And stp_event not in ('RTP','TRP')
  Order by stp_arrivaldate
/*  neeeded to do this to make report size zero for all but first row */
If @mov = 0 and @leg = 0
  Select  stops.cmp_name
  ,cityname =  ''
  ,state = ''
  ,stp_event
  ,stp_arrivaldate
  ,eventname = ''
  From stops
  Where 0 = 1

GO
GRANT EXECUTE ON  [dbo].[getquickroutefortrip_sp] TO [public]
GO
