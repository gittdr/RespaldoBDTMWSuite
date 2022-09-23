SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_trldiv_sp    Script Date: 6/1/99 11:54:58 AM ******/
/*Create stored procedure */

CREATE PROC [dbo].[d_trldiv_sp](@v_startdate datetime,@v_enddate datetime,@v_division varchar(6),@v_trc_trl char(7))

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
        @char16 reason,
        legheader.mov_number mov_number,
        legheader.lgh_startdate start_date,
        legheader.lgh_enddate end_date,                     
        @char1  ord_hdrnumber,
        trimac_hierarchy.trimac_terminal branch,
        trimac_hierarchy.trimac_region region,
        trimac_hierarchy.trimac_division division

 INTO  #division

 FROM  tractorprofile,trimac_hierarchy,legheader

 WHERE legheader.lgh_startdate >= @v_startdate and legheader.lgh_enddate <= @v_enddate and
       legheader.lgh_tractor = tractorprofile.trc_number and
       trimac_hierarchy.trimac_division = @v_division and
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
        @char16 reason,
        legheader.mov_number mov_number,
        legheader.lgh_startdate start_date,
        legheader.lgh_enddate end_date,            
        @char1  ord_hdrnumber,
        trimac_hierarchy.trimac_terminal branch,
        trimac_hierarchy.trimac_region region,
        trimac_hierarchy.trimac_division division

 INTO  #division1

 FROM  trailerprofile,trimac_hierarchy,legheader

 WHERE legheader.lgh_startdate >= @v_startdate and legheader.lgh_enddate <= @v_enddate and
       legheader.lgh_primary_trailer = trailerprofile.trl_number and
       trimac_hierarchy.trimac_division = @v_division and
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

   WHILE (SELECT COUNT(mov_number) FROM #division
          WHERE mov_number > @minord) > 0

      BEGIN /*2*/

          SELECT @minord = min(mov_number)
	     FROM #division
	    WHERE mov_number > @minord
        		
          UPDATE #division
             SET ord_hdrnumber = stops.ord_hdrnumber
            FROM stops
           WHERE (stops.mov_number = @minord) and (#division.mov_number = @minord) and (stops.ord_hdrnumber <> 0)


          UPDATE #division
             SET revenue = invoiceheader.ivh_totalcharge
	    FROM invoiceheader,#division
           WHERE invoiceheader.mov_number = @minord and #division.mov_number = @minord  


         IF(SELECT count(*) FROM #division
  	    WHERE (#division.mov_number = @minord) and (revenue is null ))> 0

		BEGIN
		  UPDATE #division
		     SET revenue = 0                         
                   WHERE #division.mov_number = @minord
	        END          
	 
                     
	  UPDATE #division
             SET curr_loc = company.cmp_name
	    FROM company,tractorprofile		 
           WHERE (#division.mov_number = @minord) and (#division.tractor = tractorprofile.trc_number) and
                 (tractorprofile.trc_avl_cmp_id  = company.cmp_id)   


          UPDATE #division
             SET unload = stops.cmp_id                             
            FROM stops
           WHERE (stops.mov_number = @minord) AND (#division.mov_number = @minord) and
                  stops.stp_mfh_sequence = (SELECT MAX ( stp_mfh_sequence)
				 FROM stops, eventcodetable
				 WHERE (stops.mov_number = @minord) AND 
                                       stops.stp_type = "DRP" AND
                                       stops.stp_event = eventcodetable.abbr AND
                                       eventcodetable.ect_billable = "Y")
	     
          SELECT @begin_num = stops.stp_mfh_sequence
            FROM stops,#division
           WHERE stops.mov_number = @minord and #division.mov_number = @minord and 
                 stops.stp_mfh_sequence = (SELECT MIN(stops.stp_mfh_sequence)
			                     FROM stops
	                                    WHERE mov_number = @minord and stops.stp_type = 'PUP')

	  SELECT @end_num = stops.stp_mfh_sequence
            FROM stops,#division
           WHERE stops.mov_number = @minord and #division.mov_number = @minord and 
                 stops.stp_mfh_sequence = (SELECT MAX(stops.stp_mfh_sequence)
	     	                             FROM stops
	                                    WHERE mov_number = @minord and stops.stp_type = 'DRP')           

          SELECT @total_miles = sum(stops.stp_lgh_mileage)
            FROM stops,#division
           WHERE stops.stp_lgh_mileage is not null and stops.mov_number = @minord and 
                 #division.mov_number = @minord   	

	

          SELECT @miles_load = sum(stops.stp_lgh_mileage)
            FROM stops,#division
           WHERE (stops.mov_number = @minord) and (#division.mov_number = @minord) and 
                 (stops.stp_mfh_sequence > @begin_num and stops.stp_mfh_sequence <= @end_num)	

           
	  UPDATE #division
             SET miles_loaded = @miles_load,
		 miles_empty  = @total_miles - @miles_load
           WHERE (#division.mov_number = @minord)  


          IF(SELECT count(*) FROM #division
	     WHERE (#division.mov_number = @minord) and (miles_loaded is null ))> 0

		BEGIN
		  UPDATE #division
		     SET miles_loaded = 0
                   WHERE #division.mov_number = @minord
	        END


          IF(SELECT count(*) FROM #division
              WHERE (#division.mov_number = @minord) and (miles_empty is null ))> 0

		BEGIN
		  UPDATE #division
		     SET miles_empty = 0                         
                   WHERE #division.mov_number = @minord
	        END           
            
          UPDATE #division
             SET miles_total = @total_miles
           WHERE (#division.mov_number = @minord)  


          UPDATE #division
             SET    hours_total = datediff(hh,start_date,end_date),
                 days_last_used = datediff(dd,end_date,getdate()) 
           WHERE #division.mov_number = @minord

          IF(SELECT count(*) FROM #division
             WHERE (hours_total = 0) and (#division.mov_number = @minord)) >0

         	BEGIN
                 UPDATE #division
                    SET hours_eph = 0
	          WHERE #division.mov_number = @minord
                END

          ELSE 

                BEGIN
         	 UPDATE #division
	            SET hours_eph = (revenue)/(hours_total)          
	          WHERE #division.mov_number = @minord
	        END

          IF(SELECT count(*) FROM #division
             WHERE (miles_total = 0) and (#division.mov_number = @minord)) >0
          
        	BEGIN
                 UPDATE #division
                    SET hours_epm = 0
	          WHERE #division.mov_number = @minord
                END

          ELSE 
 
                BEGIN
                 UPDATE #division
                    SET hours_epm = (revenue)/(miles_total)
	          WHERE #division.mov_number = @minord
                END  
  
      END /*2*/
 
 END /*temp*/

ELSE

 BEGIN /*temp1*/
 
   SELECT @minord = 0

   WHILE (SELECT COUNT(mov_number) FROM #division1
          WHERE mov_number > @minord) > 0

      BEGIN /*3*/

          SELECT @minord = min(mov_number)
	     FROM #division1
	    WHERE mov_number > @minord
        		
          UPDATE #division1
             SET ord_hdrnumber = stops.ord_hdrnumber
            FROM stops
           WHERE (stops.mov_number = @minord) and (#division1.mov_number = @minord) and (stops.ord_hdrnumber <> 0)


          UPDATE #division1
             SET revenue = invoiceheader.ivh_totalcharge
	    FROM invoiceheader,#division1
           WHERE invoiceheader.mov_number = @minord and #division1.mov_number = @minord  


         IF(SELECT count(*) FROM #division1
  	    WHERE (#division1.mov_number = @minord) and (revenue is null ))> 0

		BEGIN
		  UPDATE #division1
		     SET revenue = 0                         
                   WHERE #division1.mov_number = @minord
	        END          
	 
                     
	  UPDATE #division1
             SET curr_loc = company.cmp_name
	    FROM company,trailerprofile		 
           WHERE (#division1.mov_number = @minord) and (#division1.trailer_id = trailerprofile.trl_number) and
                 (trailerprofile.trl_avail_cmp_id = company.cmp_id)    


          UPDATE #division1
             SET unload = stops.cmp_id                             
            FROM stops
           WHERE (stops.mov_number = @minord) AND (#division1.mov_number = @minord) and
                  stops.stp_mfh_sequence = (SELECT MAX ( stp_mfh_sequence)
				 FROM stops, eventcodetable
				 WHERE (stops.mov_number = @minord) AND 
                                       stops.stp_type = "DRP" AND
                                       stops.stp_event = eventcodetable.abbr AND
                                       eventcodetable.ect_billable = "Y")
	     
          SELECT @begin_num = stops.stp_mfh_sequence
            FROM stops,#division1
           WHERE stops.mov_number = @minord and #division1.mov_number = @minord and 
                 stops.stp_mfh_sequence = (SELECT MIN(stops.stp_mfh_sequence)
			                     FROM stops
	                                    WHERE mov_number = @minord and stops.stp_type = 'PUP')

	  SELECT @end_num = stops.stp_mfh_sequence
            FROM stops,#division1
           WHERE stops.mov_number = @minord and #division1.mov_number = @minord and 
                 stops.stp_mfh_sequence = (SELECT MAX(stops.stp_mfh_sequence)
	     	                             FROM stops
	                                    WHERE mov_number = @minord and stops.stp_type = 'DRP')           

          SELECT @total_miles = sum(stops.stp_lgh_mileage)
            FROM stops,#division1
           WHERE stops.stp_lgh_mileage is not null and stops.mov_number = @minord and 
                 #division1.mov_number = @minord   	

	

          SELECT @miles_load = sum(stops.stp_lgh_mileage)
            FROM stops,#division1
           WHERE (stops.mov_number = @minord) and (#division1.mov_number = @minord) and 
                 (stops.stp_mfh_sequence > @begin_num and stops.stp_mfh_sequence <= @end_num)	

           
	  UPDATE #division1
             SET miles_loaded = @miles_load,
		 miles_empty  = @total_miles - @miles_load
           WHERE (#division1.mov_number = @minord)  


          IF(SELECT count(*) FROM #division1
	     WHERE (#division1.mov_number = @minord) and (miles_loaded is null ))> 0

		BEGIN
		  UPDATE #division1
		     SET miles_loaded = 0
                   WHERE #division1.mov_number = @minord
	        END


          IF(SELECT count(*) FROM #division1
              WHERE (#division1.mov_number = @minord) and (miles_empty is null ))> 0

		BEGIN
		  UPDATE #division1
		     SET miles_empty = 0                         
                   WHERE #division1.mov_number = @minord
	        END           
            
          UPDATE #division1
             SET miles_total = @total_miles
           WHERE (#division1.mov_number = @minord)  


          UPDATE #division1
             SET    hours_total = datediff(hh,start_date,end_date),
                 days_last_used = datediff(dd,end_date,getdate()) 
           WHERE #division1.mov_number = @minord

          IF(SELECT count(*) FROM #division1
             WHERE (hours_total = 0) and (#division1.mov_number = @minord)) >0

         	BEGIN
                 UPDATE #division1
                    SET hours_eph = 0
	          WHERE #division1.mov_number = @minord
                END

          ELSE 

                BEGIN
         	 UPDATE #division1
	            SET hours_eph = (revenue)/(hours_total)          
	          WHERE #division1.mov_number = @minord
	        END

          IF(SELECT count(*) FROM #division1
             WHERE (miles_total = 0) and (#division1.mov_number = @minord)) >0
          
        	BEGIN
                 UPDATE #division1
                    SET hours_epm = 0
	          WHERE #division1.mov_number = @minord
                END

          ELSE 
 
                BEGIN
                 UPDATE #division1
                    SET hours_epm = (revenue)/(miles_total)
	          WHERE #division1.mov_number = @minord
                END                 
      END /*3*/
END /*temp1*/

/**********************************************************************************************/

/* Display data from #division table */

if @v_trc_trl = 'tractor' 
  
   SELECT * FROM #division
   ORDER BY mov_number 
   
else

   SELECT * FROM #division1
   ORDER BY mov_number 



GO
GRANT EXECUTE ON  [dbo].[d_trldiv_sp] TO [public]
GO
