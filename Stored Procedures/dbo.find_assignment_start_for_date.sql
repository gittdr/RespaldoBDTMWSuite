SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  Stored Procedure dbo.find_assignment_start_for_date Script Date: 8/20/97 1:57:10 PM ******/
CREATE PROC [dbo].[find_assignment_start_for_date]
	@eqptype varchar(6), 
	@eqpid varchar(13),
	@startdate datetime,
	@excludemove int
AS
-- 05/24/01 DAG: Converting for international date format 
-- 09/26/11 DWG: PTS 57889  Added check to make sure the leg header is not a child 
-- 05/01/14 MC & HMA: PTS 76362  - reworked 57889 queries to seek stp_ico_stp_number_child without putting a hit on the query load
--     PTS 76362 requires us to create index ix_stops_ico_stp_number_child_lgh_number on stops (stp_ico_stp_number_child, lgh_number)


-- This routine finds the earliest startdate of any activity for the specified equipment that ends after the specified date and that is 
--     not on the specified move.

SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
  
  
DECLARE @nextstartdate datetime,  
 @workassignment int,  
 @thisassignment int,  
 @workmove int,  
 @nextenddate datetime,  
 @priorstartdate datetime,  
 @priorenddate datetime,  
 @priormove int,  
 @priorassignment int,  
 @priorendstop int,  
 @priorendevent varchar(20),  
 @nextstartevent varchar(20)  

    SELECT @nextstartdate = min(a.asgn_date)   
    FROM assetassignment a 
    inner join legheader l on a.lgh_number = l.lgh_number
    LEFT JOIN stops s on a.lgh_number = s.lgh_number AND s.stp_ico_stp_number_child > 0
    WHERE   
	a.asgn_type = @eqptype AND 
	a.asgn_id = @eqpid AND 
	a.asgn_status in ('CMP', 'STD') AND    
	l.mov_number <> @excludemove AND  
	s.lgh_number is null AND

	CASE  
	 WHEN isnull(asgn_enddate,'20491231') < '20491201' AND  
	 ISNULL(asgn_enddate,'19500101') > '19500131'   
	  then asgn_enddate  
	 ELSE  
	  asgn_date  
	END  >= @startdate 
	
  
    SELECT  @workmove = l.mov_number,   
	@workassignment = a.asgn_trl_first_asgn,  
	@thisassignment = a.asgn_number,  
	@nextenddate = a.asgn_enddate  
    FROM assetassignment a 
    inner join legheader l on a.lgh_number = l.lgh_number
    LEFT JOIN stops s on a.lgh_number = s.lgh_number AND s.stp_ico_stp_number_child > 0
    WHERE   
	a.asgn_type = @eqptype AND 
	a.asgn_id = @eqpid AND  
	a.asgn_date = @nextstartdate AND
	l.mov_number <> @excludemove AND  
	a.asgn_status in ('CMP', 'STD') AND 
	s.lgh_number is null  

    IF @eqptype = 'TRL'  
	BEGIN  
	WHILE (isnull(@workassignment, @thisassignment) <> @thisassignment AND ISNULL(@workassignment, 0)<>0)  
	 BEGIN  
	 -- This assetassignment is marked as a continuation of an earlier one, so load the data of that earlier one.  
	 IF exists (SELECT *   
	    FROM assetassignment (NOLOCK)  
	    WHERE asgn_number = @workassignment)  
	  SELECT  @thisassignment = asgn_number,   
	   @workassignment = asgn_trl_first_asgn,  
	   @nextstartdate = asgn_date  
	  FROM assetassignment (NOLOCK)  
	  WHERE asgn_number = @workassignment  
	 ELSE  -- Whoops, claimed prior doesn't exist.  Just keep what we have.  
	  SELECT @workassignment = 0  
	 END  
  
	-- Also need to check if prior trip ended with a DLT.  If so, that activity might actually still be continuing as well.  
	SELECT @priorstartdate = MAX(a.asgn_date)   
    FROM assetassignment a 
    inner join legheader l on a.lgh_number = l.lgh_number
    LEFT JOIN stops s on a.lgh_number = s.lgh_number AND s.stp_ico_stp_number_child > 0
	WHERE   
	 a.asgn_type = 'TRL' AND 
	 a.asgn_id = @eqpid AND  
	 a.asgn_status in ('CMP', 'STD') AND
	 a.asgn_date < @startdate AND    
	 l.mov_number <> @excludemove AND  
	 s.lgh_number is null  

	   -- If we found another trip AND it's startdate would be earlier than what we already found....  
	IF ISNULL(@priorstartdate, '20491231 23:59') < @nextstartdate  
	 BEGIN  
	 -- Find out when that prior activity ended.  
	 SELECT @priorenddate = max(ISNULL(a.asgn_enddate, '20491231 23:59'))  
       FROM assetassignment a 
	   inner join legheader l on a.lgh_number = l.lgh_number
	   LEFT JOIN stops s on a.lgh_number = s.lgh_number AND s.stp_ico_stp_number_child > 0
	 WHERE   
	  a.asgn_type = @eqptype AND 
	  a.asgn_id = @eqpid AND  
	  a.asgn_status in ('CMP', 'STD') AND   
	  a.asgn_date = @priorstartdate   AND
	  l.mov_number <> @excludemove AND  
	  s.lgh_number is null  

	 -- Find the move of that prior activity.  
	 SELECT @priormove = max(ISNULL(a.mov_number, 0)), @priorassignment = max(ISNULL(asgn_number, 0))  
       FROM assetassignment a 
	   inner join legheader l on a.lgh_number = l.lgh_number
	   LEFT JOIN stops s on a.lgh_number = s.lgh_number AND s.stp_ico_stp_number_child > 0
	 WHERE   
	  a.asgn_type = @eqptype AND 
	  a.asgn_id = @eqpid AND  
	  a.asgn_status in ('CMP', 'STD') AND   
	  a.asgn_date = @priorstartdate AND  
	  l.mov_number <> @excludemove AND  
	   ISNULL(a.asgn_enddate, '20491231 23:59') = @priorenddate AND
	  s.lgh_number is null  

	 -- Find the last stop on that move at or before that enddate that has the trailer on it.  
	 SELECT @priorendstop = max(stp_mfh_sequence)  
	 FROM stops  (NOLOCK)  
	  INNER JOIN event (NOLOCK) ON stops.stp_number = event.stp_number and event.evt_sequence = 1  
	 WHERE  
	  stops.mov_number = @priormove AND  
	  stops.stp_arrivaldate <= @priorenddate AND  
	  (event.evt_trailer1 = @eqpid OR event.evt_trailer2 = @eqpid)  
    
	 -- Get the event off that stop.  
	 SELECT @priorendevent = stp_event  
	 FROM stops (NOLOCK)  
	 WHERE stops.mov_number = @priormove AND stops.stp_mfh_sequence = @priorendstop  
    
	 -- Was it a DLT?  
	 IF @priorendevent = 'DLT'  
	  BEGIN  
	  -- Yes it was!  If there is a later HCT or HLT with that trailer, then that trip is to be considered as overlapping.  
	  IF EXISTS (  
	   SELECT *   
	   FROM stops (NOLOCK)  
	   INNER JOIN event (NOLOCK)ON stops.stp_number = event.stp_number and event.evt_sequence = 1  
	   WHERE stops.mov_number = @priormove AND   
		 stops.stp_mfh_sequence > @priorendstop AND   
		 (event.evt_trailer1 = @eqpid OR event.evt_trailer2 = @eqpid) AND  
		 (stops.stp_event = 'HCT' OR stops.stp_event = 'HLT'))  
	   SELECT    
	    @workmove = @priormove,   
	    @nextstartdate = @priorstartdate,   
	    @thisassignment = @priorassignment,   
	    @nextenddate = ISNULL(MAX(ISNULL(stp_arrivaldate, '20491231 23:59')), '20491231 23:59')  
	   FROM stops (NOLOCK)  
	   INNER JOIN event (NOLOCK)ON stops.stp_number = event.stp_number and event.evt_sequence = 1  
	   WHERE stops.mov_number = @priormove AND   
		 (event.evt_trailer1 = @eqpid OR event.evt_trailer2 = @eqpid)  
	  END  
	 END  
	END  
    SELECT  @workmove mov_number, @nextstartdate asgn_date, @thisassignment asgn_number, @nextenddate asgn_enddate  
    
GO
GRANT EXECUTE ON  [dbo].[find_assignment_start_for_date] TO [public]
GO
