SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[get_activity] @type VARCHAR(6), 
                              @id VARCHAR(13),
										@status1 varchar(6),
										@status2 varchar(6),
										@status3 varchar(6), 
										@status4 varchar(6),
                              @lgh INT OUT
AS
/**
 * 
 * NAME:
 * dbo.get_activity 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/

DECLARE	@mov_number INT, 
        @maxdt DATETIME

 select  @status1 = isnull(@status1,' ')
 select  @status2 = isnull(@status2,' ')
select  @status3 = isnull(@status3,' ')
select  @status4 = isnull(@status4,' ')
if @type = 'TRC' or @Type = 'DRV' or @type = 'CAR' begin
	SELECT @maxdt = MAX(asgn_enddate) 
  	 FROM assetassignment 
  WHERE asgn_type = @type AND 
          asgn_id = @id AND 
     (asgn_status =  @status1   or
		asgn_status =  @status2 or
		asgn_status =  @status3 or
	   asgn_status =  @status4)
SET ROWCOUNT 1
SELECT @lgh = lgh_number, 
       @mov_number = mov_number 
  FROM assetassignment 
 WHERE asgn_type = @type AND 
       asgn_id = @id AND 
       (asgn_status =  @status1   or
			asgn_status =  @status2 or
			asgn_status =  @status3 or
	asgn_status =  @status4)  AND 
       asgn_enddate = @maxdt
SET ROWCOUNT 0
end 
else if @type = 'Ord' begin
	select @lgh = lgh.lgh_number, 
      	 @mov_number = ord.mov_number 
	from   orderheader ord,legheader lgh
	where  lgh.mov_number = ord.mov_number
	and    ord.ord_number = @id
end
	

IF @lgh < 1 OR @lgh IS NULL
   BEGIN
        SELECT @lgh = 0
        RETURN -1
   END

IF @mov_number < 1 OR @mov_number IS NULL
   SELECT @mov_number = mov_number 
     FROM legheader
    WHERE lgh_number = @lgh

IF @mov_number < 1 OR @mov_number IS NULL
   RETURN -1

RETURN @mov_number
GO
GRANT EXECUTE ON  [dbo].[get_activity] TO [public]
GO
