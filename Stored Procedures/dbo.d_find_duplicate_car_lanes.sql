SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create PROC [dbo].[d_find_duplicate_car_lanes]	@Origintype int, 
										@OriginID varchar(100), 
										@Desttype int, 
										@DestID varchar(100)	
AS 

/**
*    Proc created for PTS 46628
*    @type values can be:   
*		type 	1 = companyid 
*				2 = citycode (numeric)
*				3 = zippart 
*				4 = county
*				5 = stateabbr 
*				6 = countrycode 
 **/
 
Create table #temp_origin_car_lanes ( laneid  int null, lanecode varchar(15) null , lanename varchar(50) null) 
Create table #temp_dest_car_lanes ( laneid  int null, lanecode varchar(15) null , lanename varchar(50) null)   
 --======================================================================== 
 IF @Origintype = 1
 BEGIN
		Insert Into #temp_origin_car_lanes 
			select laneid, lanecode, lanename 			
			from core_lane	
			where laneid in (select laneid from core_lanelocation 
											where isorigin = 1 and
												type  = 1
												and   companyid = @OriginID ) 	
END 

IF @Origintype = 2
 BEGIN
		Insert Into #temp_origin_car_lanes 
			select laneid, lanecode, lanename 			
			from core_lane	
			where laneid in (select laneid from core_lanelocation 
											where isorigin = 1 and
												type  = 2
												and   citycode = convert ( integer, @OriginID ) ) 
END 

IF @Origintype = 3
 BEGIN
		Insert Into #temp_origin_car_lanes 
			select laneid, lanecode, lanename 			
			from core_lane	
			where laneid in (select laneid from core_lanelocation 
											where isorigin = 1 and
												type  = 3
												and   zippart  = @OriginID ) 
END 

IF @Origintype = 4
 BEGIN
		Insert Into #temp_origin_car_lanes 
			select laneid, lanecode, lanename 			
			from core_lane	
			where laneid in (select laneid from core_lanelocation 
											where isorigin = 1 and
												type  = 4
												and   county  = @OriginID ) 
END 

IF @Origintype = 5
 BEGIN
		Insert Into #temp_origin_car_lanes 
			select laneid, lanecode, lanename 			
			from core_lane	
			where laneid in (select laneid from core_lanelocation 
											where isorigin = 1 and
												type  = 5
												and   stateabbr = @OriginID ) 
END 

IF @Origintype = 6
 BEGIN
		Insert Into #temp_origin_car_lanes 
			select laneid, lanecode, lanename 			
			from core_lane	
			where laneid in (select laneid from core_lanelocation 
											where isorigin = 1 and
												type  = 6
												and    countrycode  = @OriginID ) 
END 
 
 --========================================================================

IF @Desttype = 1
 BEGIN
		Insert Into #temp_dest_car_lanes
			select laneid, lanecode, lanename 			
			from core_lane	
			where laneid in (select laneid from core_lanelocation 
											where isorigin = 2 and
												type  = 1
												and   companyid = @DestID ) 	
END 

IF @Desttype = 2
 BEGIN
		Insert Into #temp_dest_car_lanes
			select laneid, lanecode, lanename 			
			from core_lane	
			where laneid in (select laneid from core_lanelocation 
											where isorigin = 2 and
												type  = 2
												and   citycode = convert ( integer, @DestID ) ) 
END 

IF @Desttype = 3
 BEGIN
		Insert Into #temp_dest_car_lanes
			select laneid, lanecode, lanename 			
			from core_lane	
			where laneid in (select laneid from core_lanelocation 
											where isorigin = 2 and
												type  = 3
												and   zippart  = @DestID ) 
END 

IF @Desttype = 4
 BEGIN
		Insert Into #temp_dest_car_lanes
			select laneid, lanecode, lanename 			
			from core_lane	
			where laneid in (select laneid from core_lanelocation 
											where isorigin = 2 and
												type  = 4
												and   county  = @DestID ) 
END 

IF @Desttype = 5
 BEGIN
		Insert Into #temp_dest_car_lanes
			select laneid, lanecode, lanename 			
			from core_lane	
			where laneid in (select laneid from core_lanelocation 
											where isorigin = 2 and
												type  = 5
												and   stateabbr = @DestID ) 
END 

IF @Desttype = 6
 BEGIN
		Insert Into #temp_dest_car_lanes
			select laneid, lanecode, lanename 			
			from core_lane	
			where laneid in (select laneid from core_lanelocation 
											where isorigin =2 and
												type  = 6
												and    countrycode  = @DestID ) 
END 
 --========================================================================

select lanecode, lanename 	 
from #temp_origin_car_lanes 
where laneid in (select laneid from #temp_dest_car_lanes) 

drop table #temp_origin_car_lanes
drop table #temp_dest_car_lanes

GO
GRANT EXECUTE ON  [dbo].[d_find_duplicate_car_lanes] TO [public]
GO
