SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_cur_activity3_sp]	
					@type			varchar (6), 
				  	@id				varchar(13), 
					@mov_number		int, 
					@lgh_number		int,
				  	@lgh_out		int 		OUT,
					@mov_out		int 		OUT,
					@ord_num		int 		OUT,
					@cmp_id			varchar(25)	OUT, -- PTS 61189 enhance cmp_id to 25 length
					@city			int 		OUT,
					@status			varchar(6)	OUT, 	
  					@start_date		datetime	OUT,
  					@end_date		datetime	OUT,
					@last_trailer	varchar(13)	OUT,
					@last_pup		varchar(13)	OUT,
					@event			char(6)		OUT,
					@state			varchar(6)	OUT,
					@city_name		varchar(18)	OUT,
					@city_zipcode	varchar(10)	OUT
AS
/***
      08/07/2008: VMS - Changed to retrieve city_zipcode
***/

EXEC dbo.get_cur_activity_sp @type, @id, @mov_number, @lgh_number , @lgh_out OUT, @mov_out OUT, @ord_num OUT, @cmp_id OUT, @city OUT, @status OUT, @start_date OUT, @end_date OUT, @last_trailer OUT, @last_pup OUT, @event OUT, @state OUT, @city_name OUT
IF ISNULL(@lgh_out, 0) > 0
	BEGIN
		SELECT @last_trailer = e.evt_Trailer1, @last_pup = e.evt_Trailer2
			FROM stops s (NOLOCK)
			INNER JOIN event e (NOLOCK) ON e.stp_number = s.stp_number
			WHERE s.stp_mfh_sequence = (SELECT max(ss.stp_mfh_sequence) FROM stops ss WHERE ss.lgh_number = @lgh_out) 
				AND s.lgh_number = @lgh_out
				AND e.evt_sequence = 1
	END

IF ISNULL(@city, 0) > 0
	BEGIN
		SELECT @city_zipcode = c.cty_zip
			FROM city c (NOLOCK)
			WHERE c.cty_code = @city
	END

SELECT	@lgh_out, 
		@mov_out, 
		@ord_num, 
		@cmp_id, 
		@city, 
		@status, 
		@start_date, 
		@end_date, 
		@last_trailer, 
		@last_pup, 
		@event, 
		@state, 
		@city_name, 
		@city_zipcode

GO
GRANT EXECUTE ON  [dbo].[tmail_get_cur_activity3_sp] TO [public]
GO
