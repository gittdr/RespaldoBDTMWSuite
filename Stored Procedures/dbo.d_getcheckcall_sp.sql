SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[d_getcheckcall_sp]
	@id varchar(13),
	@type varchar(6),
	@action varchar(2),
	@begindate datetime,
	@enddate   datetime 
   	
as
/**
 * 
 * NAME:
 * dbo.d_getcheckcall_sp
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
 * Calls001:    
 * Calls002:    
 *
 * CalledBy001:  
 * CalledBy002:  
 *
 * 
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names
 *
 **/


  declare @mov_number  integer,
	  @lgh_number  integer,
	  @status varchar(6)
  if @action = 'L' begin
	execute @mov_number = get_activity @type,@id,'cmp',' ',' ',' ', @lgh_number output
	SELECT  checkcall.ckc_lghnumber,   
                checkcall.ckc_longseconds,   
                checkcall.ckc_latseconds,   
                checkcall.ckc_number,   
                checkcall.ckc_status,   
                checkcall.ckc_asgntype,   
         	checkcall.ckc_asgnid,   
         	checkcall.ckc_date,   
         	checkcall.ckc_event,   
         	checkcall.ckc_city,   
         	isNull(checkcall.ckc_comment,'None') ckc_comment,   
         	@id  ckc_tractor,   
         	checkcall.ckc_milesfrom,   
         	checkcall.ckc_directionfrom,   
         	checkcall.ckc_mtavailable,   
         	checkcall.ckc_minutes,   
         	checkcall.ckc_mileage,   
         	checkcall.ckc_cityname,   
         	checkcall.ckc_zip,   
         	checkcall.ckc_state,   
         	checkcall.ckc_commentlarge,   
         	checkcall.ckc_minutes_to_final,   
        	checkcall.ckc_miles_to_final,
		mov_number
    	   FROM assetassignment,   
         	checkcall  
   	   WHERE   ( assetassignment.mov_number = @mov_number ) AND  
         	   ( assetassignment.asgn_id = @id ) AND  
                   ( assetassignment.asgn_type = @type ) AND  
                   ( assetassignment.lgh_number = checkcall.ckc_lghnumber )    
          order by ckc_date
    end Else begin
   	  SELECT checkcall.ckc_lghnumber,   
                checkcall.ckc_longseconds,   
                checkcall.ckc_latseconds,   
                checkcall.ckc_number,   
                checkcall.ckc_status,   
                checkcall.ckc_asgntype,   
         	checkcall.ckc_asgnid,   
         	checkcall.ckc_date,   
         	checkcall.ckc_event,   
         	checkcall.ckc_city,   
         	isNull(checkcall.ckc_comment,'None') ckc_comment,   
         	@id ckc_tractor,   
         	checkcall.ckc_milesfrom,   
         	checkcall.ckc_directionfrom,   
         	checkcall.ckc_mtavailable,   
         	checkcall.ckc_minutes,   
         	checkcall.ckc_mileage,   
         	checkcall.ckc_cityname,   
         	checkcall.ckc_zip,   
         	checkcall.ckc_state,   
         	checkcall.ckc_commentlarge,   
         	checkcall.ckc_minutes_to_final,   
        	checkcall.ckc_miles_to_final,
		mov_number
    	   FROM  assetassignment,   
         	 checkcall  
   	   WHERE ( assetassignment.asgn_id = @id ) AND  
                 ( assetassignment.asgn_type = @type ) AND  
                 ( assetassignment.lgh_number = checkcall.ckc_lghnumber ) and
		 ( ckc_date >= @begindate and
		    ckc_date <=  @enddate	)	   
          order by mov_number,checkcall.ckc_lghnumber,ckc_date
end
GO
GRANT EXECUTE ON  [dbo].[d_getcheckcall_sp] TO [public]
GO
