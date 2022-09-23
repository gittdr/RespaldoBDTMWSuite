SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_cur_activity2_sp]
					@type			varchar (6), 
				  	@id				varchar(13), 
					@mov_number		int, 
					@lgh_number		int,
				  	@lgh_out		int 		OUT,
					@mov_out		int 		OUT,
					@ord_num		int 		OUT,
					@cmp_id			varchar(25)	OUT, --PTS 67926 RS: Changed size to 25, supposed to have been done in PTS 61189
					@city			int 		OUT,
					@status			varchar(6)	OUT, 	
  					@start_date		datetime	OUT,
  					@end_date		datetime	OUT,
					@last_trailer	varchar(13)	OUT,
					@last_pup		varchar(13)	OUT,
					@event			char(6)		OUT,
					@state			varchar(6)	OUT,
					@city_name		varchar(18)	OUT
AS
/***
      08/08/2008: VMS modified to call tmail_get_cur_activity3_sp - PTS44045 
***/

DECLARE @city_zipcode varchar(10)

EXEC dbo.tmail_get_cur_activity3_sp 
			@type, 
			@id, 
			@mov_number, 
			@lgh_number, 
			@lgh_out		OUT, 
			@mov_out		OUT, 
			@ord_num		OUT, 
			@cmp_id			OUT, 
			@city			OUT, 
			@status			OUT, 
			@start_date		OUT, 
			@end_date		OUT, 
			@last_trailer	OUT, 
			@last_pup		OUT, 
			@event			OUT,
			@state			OUT, 
			@city_name		OUT, 
			@city_zipcode	OUT
GO
GRANT EXECUTE ON  [dbo].[tmail_get_cur_activity2_sp] TO [public]
GO
