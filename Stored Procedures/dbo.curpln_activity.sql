SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE  PROCEDURE [dbo].[curpln_activity] @asgntype VARCHAR(6), 
                              @asgnid VARCHAR(13), 
	         @start_dt DATETIME,
	         @lgh_number INT,
                              @lgh_out INT OUT,
	         @mov_out INT OUT,
	         @ord_num int OUT,
	         @cmp_id varchar(12) OUT,
	         @city	int OUT,
	         @status varchar(6) OUT, 	
      	         @start_date datetime OUT,
      	         @end_date datetime OUT,
	         @primary_trailer  varchar(13) OUT,
	         @primary_pup varchar(13) OUT,
	         @event char(6) OUT,
	         @ord varchar(12) OUT,
	         @end_trailer varchar(13) OUT
AS

DECLARE @maxdt DATETIME 

SELECT @maxdt = MAX(asgn_enddate) 
  FROM assetassignment 
 WHERE asgn_type = @asgntype AND 
       asgn_id = @asgnid AND 
       asgn_status IN ('STD', 'CMP', 'PLN') AND
       asgn_enddate < @start_dt AND
       lgh_number <> @lgh_number

SET ROWCOUNT 1
SELECT 	@mov_out = legheader.mov_number,   
	@ord_num = legheader.ord_hdrnumber ,
	@lgh_out = legheader.lgh_number, 
	@cmp_id = legheader.cmp_id_end, 
	@city = legheader.lgh_endcity,
	@status = assetassignment.asgn_status, 
      	@start_date = assetassignment.asgn_date,
      	@end_date = assetassignment.asgn_enddate,
	@primary_trailer = legheader.lgh_primary_trailer,
	@primary_pup = legheader.lgh_primary_pup,
	@event = stops.stp_event
FROM 	assetassignment, stops, legheader  
WHERE 	assetassignment.lgh_number = legheader.lgh_number and  
                      legheader.stp_number_end = stops.stp_number and  
                      assetassignment.asgn_type = @asgntype AND  
                      assetassignment.asgn_id = @asgnid AND  
	 assetassignment.asgn_status IN ('STD', 'CMP', 'PLN') AND
	 assetassignment.asgn_enddate = @maxdt

SELECT @ord = orderheader.ord_number
FROM	orderheader
WHERE 	orderheader.ord_hdrnumber = @ord_num

SELECT @end_trailer = evt_trailer1
    FROM event, stops
  WHERE stops.lgh_number = @lgh_out AND
                    stops.stp_mfh_sequence = (SELECT Max(stp_mfh_sequence)
                                                                                 FROM stops
                                                                              WHERE stops.lgh_number = @lgh_out) AND
                     event.evt_sequence = 1 AND
                     stops.stp_number = event.stp_number


SET ROWCOUNT 0

IF @mov_out < 1 OR @mov_out IS NULL
   BEGIN
      SELECT @mov_out = 0
      RETURN -1
   END

GO
GRANT EXECUTE ON  [dbo].[curpln_activity] TO [public]
GO
