SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_cur_activity_sp]	
					@type       	varchar (6), 
				  	@id 	    	varchar(13), 
					@mov_number 	int, 
					@lgh_number 	int,
				  	@lgh_out    	int 		OUT,
					@mov_out		int 		OUT,
					@ord_num		int 		OUT,
					@cmp_id			varchar(25) 	OUT, --PTS 67926 RS: Changed size to 25 - supposed to have been done in PTS 61189
					@city			int 		OUT,
					@status			varchar(6)	OUT, 	
      				@start_date 	datetime	OUT,
      				@end_date 		datetime	OUT,
					@primary_trailer varchar(13)	OUT,
					@primary_pup	varchar(13)	OUT,
					@event			char(6)		OUT,
					@state			varchar(6)		OUT,
					@city_name		varchar(18)	OUT
AS
/***
      8/30/2001: DAG Changed state to length 6 for International 
***/

EXEC tmail_get_cur_activity2_sp	@type, 
				  	@id, 
					@mov_number, 
					@lgh_number,
				  	@lgh_out,
					@mov_out,
					@ord_num,
					@cmp_id,
					@city,
					@status, 	
      				@start_date,
      				@end_date,
					@primary_trailer,
					@primary_pup,
					@event,
					@state,
					@city_name

GO
GRANT EXECUTE ON  [dbo].[tmail_get_cur_activity_sp] TO [public]
GO
