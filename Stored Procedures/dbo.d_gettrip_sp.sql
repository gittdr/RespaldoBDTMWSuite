SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[d_gettrip_sp]
	@id varchar(13),
	@type varchar(6),
        @status1 varchar(6),
	@status2 varchar(6),
	@status3 varchar(6),
	@status4 varchar(6),
	@action  char(1),
	@begindate datetime,
	@enddate   datetime
as
/**
 * DESCRIPTION:
 *
 * REVISION HISTORY:
 * 10/26/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/


  declare @mov_number  integer,
	  @lgh_number  integer
  
  if @action = 'L' begin
  execute @mov_number = get_activity @type,@id,@status1,@status2,@status3,@status4, @lgh_number output
 SELECT  distinct stops.stp_number, 
		stops.ord_hdrnumber, 
         	stops.stp_city stp_city, 
         	stops.cmp_id, 
        	stops.cmp_name, 
         	stops.lgh_number, 
         	stops.stp_mfh_sequence, 
         	city.cty_nmstct cty_nmstct, 
	 	stops.mov_number, 
         	stops.stp_state ,
         	stops.stp_zipcode, 
         	stops.stp_address,
	  	@id   id
	FROM  stops  LEFT OUTER JOIN  city  ON  stops.stp_city  = city.cty_code ,
		 assetassignment a 
	WHERE	 stops.lgh_number  = a.lgh_number
	 AND	a.mov_number  = @mov_number
	 AND	a.asgn_id  = @id
	 AND	a.asgn_type  = @type

   order by stops.stp_mfh_sequence
   end else begin
	SELECT  distinct stops.stp_number, 
		stops.ord_hdrnumber, 
         	stops.stp_city stp_city, 
         	stops.cmp_id, 
        	stops.cmp_name, 
         	stops.lgh_number, 
         	stops.stp_mfh_sequence, 
         	city.cty_nmstct cty_nmstct, 
	 	stops.mov_number, 
         	stops.stp_state ,
         	stops.stp_zipcode, 
         	stops.stp_address,
	  	@id   id
	FROM  stops  LEFT OUTER JOIN  city  ON  stops.stp_city  = city.cty_code ,
		 assetassignment a,
		 checkcall c 
	WHERE	 a.asgn_type  = @type
	 AND	a.asgn_id  = @id
	 AND	a.asgn_status  in ( 'cmp', 'std'  )
	 AND	stops.lgh_number  = ckc_lghnumber
	 AND	c.ckc_lghnumber  = a.lgh_number
	 AND	(c.ckc_date  >= @begindate
	 AND	c.ckc_date  <= @enddate)
   order by    stops.mov_number,stops.stp_mfh_sequence
end
GO
GRANT EXECUTE ON  [dbo].[d_gettrip_sp] TO [public]
GO
