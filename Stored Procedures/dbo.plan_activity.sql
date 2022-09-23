SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[plan_activity]  @type  varchar (6), 
				  @id 	 varchar(13), 
				  @lgh   int OUT AS
Declare @mov_number int, @maxdt datetime

SELECT TOP 1 @lgh = lgh_number, @mov_number = mov_number
  FROM assetassignment with (nolock)
 WHERE ( ( assetassignment.asgn_type = @type ) AND  
         ( assetassignment.asgn_id = @id ) AND  
	   ( assetassignment.asgn_status in ('PLN', 'DSP') ) )
 ORDER BY asgn_enddate desc
select @mov_number = IsNull(@mov_number,-1)
select @lgh 	   = IsNull(@lgh,0)
return @mov_number


GO
GRANT EXECUTE ON  [dbo].[plan_activity] TO [public]
GO
