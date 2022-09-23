SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[d_getcurrentposition_sp]
	@id varchar(13),
	@type varchar(6)
   	
as
declare @last_date datetime,
	@ckc_number integer

select  @last_date = max( ckc_date)
FROM 	assetassignment,   
     	checkcall  
WHERE   ( assetassignment.asgn_id = @id ) AND  
        ( assetassignment.asgn_type = @type ) AND  
        ( assetassignment.lgh_number = checkcall.ckc_lghnumber )
 
SELECT   checkcall.ckc_lghnumber,   
         checkcall.ckc_longseconds,   
         checkcall.ckc_latseconds,   
         checkcall.ckc_number,   
         checkcall.ckc_status,   
         checkcall.ckc_asgntype,   
         checkcall.ckc_asgnid,   
         checkcall.ckc_date,   
         checkcall.ckc_event,   
         checkcall.ckc_city,   
         checkcall.ckc_comment,   
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
   WHERE ( assetassignment.asgn_id = @id ) AND  
         ( assetassignment.asgn_type = @type ) AND  
         ( assetassignment.lgh_number = checkcall.ckc_lghnumber ) and
           ckc_date = @last_date
GO
GRANT EXECUTE ON  [dbo].[d_getcurrentposition_sp] TO [public]
GO
