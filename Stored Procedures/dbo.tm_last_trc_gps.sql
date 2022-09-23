SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_last_trc_gps]	@PositionDate datetime,
					@Truck varchar (8)

AS
/* 08/17/99 MZ: Find closest valid position to @PositionDate from checkcall table. 
   01/03/00 MZ: Added check for checkcall at exactly @PositionDate  
   05/24/01 DAG: Converting for international date format 
   05/22/03 TD: Ignore checkcalls more than 24 hours old. */

SET NOCOUNT ON 


DECLARE @CheckcallDate datetime,
	@Lat int,
	@Long int,
	@LatTemp int,
	@LongTemp int,
	@ckc_number int, 
	@ckc_numberTemp int,
	@LoopDate datetime,
	@DateTemp datetime, 
	@RemarksTemp varchar(254),
	@Remarks varchar(254),
	@OldDate datetime


    -- Initialize variables
    SELECT @Lat = 0
    SELECT @Long = 0
    SELECT @ckc_number = 0
    SELECT @CheckcallDate = '19500101'
    SELECT @Remarks = '' --DWG, would be null if new tractor. Do not allow this.

	SELECT @OldDate = DATEADD(hh, -24, @PositionDate)

    -- First check if there is a checkcall at exactly @PositionDate
    IF EXISTS (SELECT ckc_number 
				FROM checkcall (NOLOCK)
				WHERE ckc_date = @PositionDate AND ckc_tractor = @Truck)
        SELECT  @ckc_number = ckc_number,
		@CheckcallDate = ckc_date, 
		@Lat = ckc_latseconds,
		@Long = ckc_longseconds,
		@Remarks = ckc_comment 
    	FROM checkcall  (NOLOCK)
		WHERE ckc_date = @PositionDate
		AND ckc_tractor = @Truck        

    IF (ISNULL(@Lat, 0) = 0 OR ISNULL(@Long, 0) = 0) 
      BEGIN
	    -- Fnd the closest checkcall before @PositionDate
	    SELECT @LoopDate = @PositionDate
	    WHILE 1 = 1
	      BEGIN
		IF EXISTS(SELECT ckc_number 
			  FROM checkcall (NOLOCK) 
			  WHERE ckc_date = (SELECT MAX(ckc_date) 
					    FROM checkcall (NOLOCK) 
					    WHERE ckc_date < @LoopDate 
						AND ckc_tractor = @Truck)
						AND ckc_tractor = @Truck
						AND ckc_date >= @OldDate)
		  BEGIN
	            SELECT @ckc_numberTemp = ckc_number,
			   @DateTemp = ckc_date, 
			   @LatTemp = ckc_latseconds,
			   @LongTemp = ckc_longseconds,
			   @RemarksTemp = ckc_comment 
		    FROM checkcall (NOLOCK)
		    WHERE ckc_date = (SELECT MAX(ckc_date) 
					FROM checkcall (NOLOCK)
					WHERE ckc_date < @LoopDate 
						AND ckc_tractor = @Truck
						AND ckc_date >= @OldDate) 
    					AND ckc_tractor = @Truck
		    
		    IF (ISNULL(@LatTemp, 0) <> 0 AND ISNULL(@LongTemp, 0) <> 0) 
		      BEGIN
		        SELECT @Lat = @LatTemp
	   	        SELECT @Long = @LongTemp
		        SELECT @ckc_number = @ckc_numberTemp
		        SELECT @CheckcallDate = @DateTemp
				SELECT @Remarks = @RemarksTemp
		
		        BREAK
	              END
		    ELSE
		        SELECT @LoopDate = @DateTemp
		  END
		ELSE
		    BREAK  
	      END
	       
	    -- Now see if the closest checkcall after @PositionDate is closer than the one
	    --  we found closest before @PositionDate
	    SELECT @LoopDate = @PositionDate    
	    WHILE 1 = 1
	      BEGIN
	        IF EXISTS(SELECT ckc_number 
			  FROM checkcall 
			  WHERE ckc_date = (SELECT MIN(ckc_date) 
					    FROM checkcall (NOLOCK)
					    WHERE ckc_date > @LoopDate 
						AND ckc_tractor = @Truck) 
						AND ckc_tractor = @Truck)
		  BEGIN
		    SELECT @ckc_numberTemp = ckc_number,
			   @DateTemp = ckc_date, 
			   @LatTemp = ckc_latseconds, 
			   @LongTemp = ckc_longseconds, 
			   @RemarksTemp = ckc_comment 
		    FROM checkcall (NOLOCK)
		    WHERE ckc_date = (SELECT MIN(ckc_date) 
					FROM checkcall (NOLOCK)
					WHERE ckc_date > @LoopDate 
						AND ckc_tractor = @Truck) 
						AND ckc_tractor = @Truck
	
		    IF (ISNULL(@LatTemp, 0) <> 0 AND ISNULL(@LongTemp, 0) <> 0) 
	  	      BEGIN
	                IF (ABS(DATEDIFF(ss, @DateTemp, @PositionDate)) < ABS(DATEDIFF(ss, @CheckcallDate, @PositionDate)))
	  	          BEGIN
	 	            SELECT @Lat = @LatTemp
	   	            SELECT @Long = @LongTemp
		            SELECT @ckc_number  = @ckc_numberTemp
		            SELECT @CheckcallDate = @DateTemp  	    
					SELECT @Remarks = @RemarksTemp
		          END   
		        BREAK
	              END
		    ELSE
		        SELECT @LoopDate = @DateTemp
		  END
		ELSE
		    BREAK
	      END
      END

    SELECT @Lat, @Long, @ckc_number, @CheckcallDate, @Remarks
GO
GRANT EXECUTE ON  [dbo].[tm_last_trc_gps] TO [public]
GO
