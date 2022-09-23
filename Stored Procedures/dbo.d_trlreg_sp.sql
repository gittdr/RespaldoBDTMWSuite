SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_trlreg_sp    Script Date: 6/1/99 11:54:58 AM ******/
/*Create stored procedure */

CREATE PROC [dbo].[d_trlreg_sp](@v_startdate datetime,@v_enddate datetime,@v_region varchar(6),@v_trc_trl char(7))

AS

/**********************************************************************************************/
/*Declaration and initialization of variables*/

 DECLARE @char18  VarChar(3),
	 @char19  VarChar(8),
	 @char17  VarChar(8),
	 @char16  VarChar(30),
	 @char11  datetime,
	 @char10  VarChar(6),
	 @char9	 Char(1),
         @char13 varchar(13),
	 @char1   int,
	 @char15  real,
	 @minord  int,
	 @miles_load real,
	 @total_miles real,
	 @begin_num int,
	 @end_num int


 /*SELECT  @v_date1 = @v_date*/
 SELECT  @v_startdate = convert(char(12),@v_startdate) +'00:00:00'
 SELECT  @v_enddate   = convert(char(12),@v_enddate)   +'23:59:59'

/**********************************************************************************************/
/*Create temporary table for Tractor/Trailer utilization Report*/
 
if @v_trc_trl = 'tractor'

 SELECT tractorprofile.trc_number tractor,
        @char10 unload,
        @char15 revenue,
        @char15 miles_empty,
        @char15 miles_loaded,
        @char15 miles_total,
        @char15 hours_eph,
        @char15 hours_epm,
        @char15 hours_total,
        @char15 days_last_used,
        @char16 curr_loc,
        tractorprofile.trc_status reason,
        legheader.mov_number mov_number,
        legheader.lgh_startdate start_date,
        legheader.lgh_enddate end_date,                     
        @char1  ord_hdrnumber,
        trimac_hierarchy.trimac_terminal branch,
        trimac_hierarchy.trimac_region region,
        trimac_hierarchy.trimac_division division

 INTO  #region

 FROM  tractorprofile,trimac_hierarchy,legheader

 WHERE legheader.lgh_startdate >= @v_startdate and legheader.lgh_enddate <= @v_enddate and
       legheader.lgh_tractor = tractorprofile.trc_number and
       trimac_hierarchy.trimac_region = @v_region and
       trimac_hierarchy.trimac_terminal = tractorprofile.trc_terminal

 order by mov_number

else

 SELECT trailerprofile.trl_number trailer_id,
        @char10 unload,
        @char15 revenue,
        @char15 miles_empty,
        @char15 miles_loaded,
        @char15 miles_total,
        @char15 hours_eph,
        @char15 hours_epm,
        @char15 hours_total,
        @char15 days_last_used,
        @char16 curr_loc,
        trailerprofile.trl_status reason,
        legheader.mov_number mov_number,
        legheader.lgh_startdate start_date,
        legheader.lgh_enddate end_date,            
        @char1  ord_hdrnumber,
        trimac_hierarchy.trimac_terminal branch,
        trimac_hierarchy.trimac_region region,
        trimac_hierarchy.trimac_division division

 INTO  #region1

 FROM  trailerprofile,trimac_hierarchy,legheader

 WHERE legheader.lgh_startdate >= @v_startdate and legheader.lgh_enddate <= @v_enddate and
       legheader.lgh_primary_trailer = trailerprofile.trl_number and
       trimac_hierarchy.trimac_region = @v_region and
       trimac_hierarchy.trimac_terminal = trailerprofile.trl_terminal
             
       
 ORDER BY mov_number

/**********************************************************************************************/
/*Insert ord_hdrnumber associated with each mov_number,to allow for multiple relationships between 
  different tables.
  Extract the total revenue from the invoiceheader table unique by ord_hdrnumber. 
  Calculate the total number of hours for each trailer/tractor per move, determine the EPM and EPH per tractor/trailer.
  Calculate the total number of days since the trailer was last used, calculate the total miles, empty miles and loaded miles per tractor/trailer. 
  Determine the current location of the trailer per the trailerprofile table(trl_avail_cmp_id column) */
/**********************************************************************************************/

if @v_trc_trl = 'tractor' 

 BEGIN /*temp*/

   SELECT @minord = 0

   WHILE (SELECT COUNT(mov_number) FROM #region
          WHERE mov_number > @minord) > 0

      BEGIN /*2*/

          SELECT @minord = min(mov_number)
	     FROM #region
	    WHERE mov_number > @minord
        		
          UPDATE #region
             SET ord_hdrnumber = stops.ord_hdrnumber
            FROM stops
           WHERE (stops.mov_number = @minord) and (#region.mov_number = @minord) and (stops.ord_hdrnumber <> 0)


          UPDATE #region
             SET revenue = invoiceheader.ivh_totalcharge
	    FROM invoiceheader,#region
           WHERE invoiceheader.mov_number = @minord and #region.mov_number = @minord  


         IF(SELECT count(*) FROM #region
  	    WHERE (#region.mov_number = @minord) and (revenue is null ))> 0

		BEGIN
		  UPDATE #region
		     SET revenue = 0                         
                   WHERE #region.mov_number = @minord
	        END          
	 
                     
	  UPDATE #region
             SET curr_loc = company.cmp_name
	    FROM company,tractorprofile		 
           WHERE (#region.mov_number = @minord) and (#region.tractor = tractorprofile.trc_number) and
                 (tractorprofile.trc_avl_cmp_id  = company.cmp_id)    


          UPDATE #region
             SET unload = stops.cmp_id                             
            FROM stops
           WHERE (stops.mov_number = @minord) AND (#region.mov_number = @minord) and
                  stops.stp_mfh_sequence = (SELECT MAX ( stp_mfh_sequence)
				 FROM stops, eventcodetable
				 WHERE (stops.mov_number = @minord) AND 
                                       stops.stp_type = "DRP" AND
                                       stops.stp_event = eventcodetable.abbr AND
                                       eventcodetable.ect_billable = "Y")
	     
          SELECT @begin_num = stops.stp_mfh_sequence
            FROM stops,#region
           WHERE stops.mov_number = @minord and #region.mov_number = @minord and 
                 stops.stp_mfh_sequence = (SELECT MIN(stops.stp_mfh_sequence)
			                     FROM stops
	                                    WHERE mov_number = @minord and stops.stp_type = 'PUP')

	  SELECT @end_num = stops.stp_mfh_sequence
            FROM stops,#region
           WHERE stops.mov_number = @minord and #region.mov_number = @minord and 
                 stops.stp_mfh_sequence = (SELECT MAX(stops.stp_mfh_sequence)
	     	                             FROM stops
	                                    WHERE mov_number = @minord and stops.stp_type = 'DRP')           

          SELECT @total_miles = sum(stops.stp_lgh_mileage)
            FROM stops,#region
           WHERE stops.stp_lgh_mileage is not null and stops.mov_number = @minord and 
                 #region.mov_number = @minord   	

	

          SELECT @miles_load = sum(stops.stp_lgh_mileage)
            FROM stops,#region
           WHERE (stops.mov_number = @minord) and (#region.mov_number = @minord) and 
                 (stops.stp_mfh_sequence > @begin_num and stops.stp_mfh_sequence <= @end_num)	

           
	  UPDATE #region
             SET miles_loaded = @miles_load,
		 miles_empty  = @total_miles - @miles_load
           WHERE (#region.mov_number = @minord)  


          IF(SELECT count(*) FROM #region
	     WHERE (#region.mov_number = @minord) and (miles_loaded is null ))> 0

		BEGIN
		  UPDATE #region
		     SET miles_loaded = 0
                   WHERE #region.mov_number = @minord
	        END


          IF(SELECT count(*) FROM #region
              WHERE (#region.mov_number = @minord) and (miles_empty is null ))> 0

		BEGIN
		  UPDATE #region
		     SET miles_empty = 0                         
                   WHERE #region.mov_number = @minord
	        END           
            
          UPDATE #region
             SET miles_total = @total_miles
           WHERE (#region.mov_number = @minord)  


          UPDATE #region
             SET    hours_total = datediff(hh,start_date,end_date),
                 days_last_used = datediff(dd,end_date,getdate()) 
           WHERE #region.mov_number = @minord

          IF(SELECT count(*) FROM #region
             WHERE (hours_total = 0) and (#region.mov_number = @minord)) >0

         	BEGIN
                 UPDATE #region
                    SET hours_eph = 0
	          WHERE #region.mov_number = @minord
                END

          ELSE 

                BEGIN
         	 UPDATE #region
	            SET hours_eph = (revenue)/(hours_total)          
	          WHERE #region.mov_number = @minord
	        END

          IF(SELECT count(*) FROM #region
             WHERE (miles_total = 0) and (#region.mov_number = @minord)) >0
          
        	BEGIN
                 UPDATE #region
                    SET hours_epm = 0
	          WHERE #region.mov_number = @minord
                END

          ELSE 
 
                BEGIN
                 UPDATE #region
                    SET hours_epm = (revenue)/(miles_total)
	          WHERE #region.mov_number = @minord
                END  
  
      END /*2*/
 
 END /*temp*/

ELSE

 BEGIN /*temp1*/
 
   SELECT @minord = 0

   WHILE (SELECT COUNT(mov_number) FROM #region1
          WHERE mov_number > @minord) > 0

      BEGIN /*3*/

          SELECT @minord = min(mov_number)
	     FROM #region1
	    WHERE mov_number > @minord
        		
          UPDATE #region1
             SET ord_hdrnumber = stops.ord_hdrnumber
            FROM stops
           WHERE (stops.mov_number = @minord) and (#region1.mov_number = @minord) and (stops.ord_hdrnumber <> 0)


          UPDATE #region1
             SET revenue = invoiceheader.ivh_totalcharge
	    FROM invoiceheader,#region1
           WHERE invoiceheader.mov_number = @minord and #region1.mov_number = @minord  


         IF(SELECT count(*) FROM #region1
  	    WHERE (#region1.mov_number = @minord) and (revenue is null ))> 0

		BEGIN
		  UPDATE #region1
		     SET revenue = 0                         
                   WHERE #region1.mov_number = @minord
	        END          
	 
                     
	  UPDATE #region1
             SET curr_loc = company.cmp_name
	    FROM company,trailerprofile		 
           WHERE (#region1.mov_number = @minord) and (#region1.trailer_id = trailerprofile.trl_number) and
                 (trailerprofile.trl_avail_cmp_id = company.cmp_id)    


          UPDATE #region1
             SET unload = stops.cmp_id                             
            FROM stops
           WHERE (stops.mov_number = @minord) AND (#region1.mov_number = @minord) and
                  stops.stp_mfh_sequence = (SELECT MAX ( stp_mfh_sequence)
				 FROM stops, eventcodetable
				 WHERE (stops.mov_number = @minord) AND 
                                       stops.stp_type = "DRP" AND
                                       stops.stp_event = eventcodetable.abbr AND
                                       eventcodetable.ect_billable = "Y")
	     
          SELECT @begin_num = stops.stp_mfh_sequence
            FROM stops,#region1
           WHERE stops.mov_number = @minord and #region1.mov_number = @minord and 
                 stops.stp_mfh_sequence = (SELECT MIN(stops.stp_mfh_sequence)
			                     FROM stops
	                                    WHERE mov_number = @minord and stops.stp_type = 'PUP')

	  SELECT @end_num = stops.stp_mfh_sequence
            FROM stops,#region1
           WHERE stops.mov_number = @minord and #region1.mov_number = @minord and 
                 stops.stp_mfh_sequence = (SELECT MAX(stops.stp_mfh_sequence)
	     	                             FROM stops
	                                    WHERE mov_number = @minord and stops.stp_type = 'DRP')           

          SELECT @total_miles = sum(stops.stp_lgh_mileage)
            FROM stops,#region1
           WHERE stops.stp_lgh_mileage is not null and stops.mov_number = @minord and 
                 #region1.mov_number = @minord   	

	

          SELECT @miles_load = sum(stops.stp_lgh_mileage)
            FROM stops,#region1
           WHERE (stops.mov_number = @minord) and (#region1.mov_number = @minord) and 
                 (stops.stp_mfh_sequence > @begin_num and stops.stp_mfh_sequence <= @end_num)	

           
	  UPDATE #region1
             SET miles_loaded = @miles_load,
		 miles_empty  = @total_miles - @miles_load
           WHERE (#region1.mov_number = @minord)  


          IF(SELECT count(*) FROM #region1
	     WHERE (#region1.mov_number = @minord) and (miles_loaded is null ))> 0

		BEGIN
		  UPDATE #region1
		     SET miles_loaded = 0
                   WHERE #region1.mov_number = @minord
	        END


          IF(SELECT count(*) FROM #region1
              WHERE (#region1.mov_number = @minord) and (miles_empty is null ))> 0

		BEGIN
		  UPDATE #region1
		     SET miles_empty = 0                         
                   WHERE #region1.mov_number = @minord
	        END           
            
          UPDATE #region1
             SET miles_total = @total_miles
           WHERE (#region1.mov_number = @minord)  


          UPDATE #region1
             SET    hours_total = datediff(hh,start_date,end_date),
                 days_last_used = datediff(dd,end_date,getdate()) 
           WHERE #region1.mov_number = @minord

          IF(SELECT count(*) FROM #region1
             WHERE (hours_total = 0) and (#region1.mov_number = @minord)) >0

         	BEGIN
                 UPDATE #region1
                    SET hours_eph = 0
	          WHERE #region1.mov_number = @minord
                END

          ELSE 

                BEGIN
         	 UPDATE #region1
	            SET hours_eph = (revenue)/(hours_total)          
	          WHERE #region1.mov_number = @minord
	        END

          IF(SELECT count(*) FROM #region1
             WHERE (miles_total = 0) and (#region1.mov_number = @minord)) >0
          
        	BEGIN
                 UPDATE #region1
                    SET hours_epm = 0
	          WHERE #region1.mov_number = @minord
                END

          ELSE 
 
                BEGIN
                 UPDATE #region1
                    SET hours_epm = (revenue)/(miles_total)
	          WHERE #region1.mov_number = @minord
                END                 
      END /*3*/
END /*temp1*/

/**********************************************************************************************/

/* Display data from #region table */

if @v_trc_trl = 'tractor' 
  
   SELECT * FROM #region
   ORDER BY mov_number 
   
else

   SELECT * FROM #region1
   ORDER BY mov_number 



GO
GRANT EXECUTE ON  [dbo].[d_trlreg_sp] TO [public]
GO
