SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_trctrlutil_sp    Script Date: 6/1/99 11:54:57 AM ******/
/*Create stored procedure */

CREATE PROC [dbo].[d_trctrlutil_sp](@v_startdate datetime,@v_enddate datetime,@v_branch varchar(6),@v_region varchar(6),@v_division varchar(6))

AS

BEGIN /* 1 */

/**********************************************************************************************/
/*Declaration and initialization of variables*/

 DECLARE @char18  VarChar(3),
	 @char19  VarChar(8),
	 @char17  VarChar(8),
	 @char16  VarChar(30),
	 @char11  datetime,
	 @char10  VarChar(6),
	 @char9	 Char(1),
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
 
 SELECT legheader.lgh_tractor tractor,
        legheader.lgh_primary_trailer trailer_id,
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
        @char1  ord_hdrnumber 

 INTO #temp

 FROM legheader,trailerprofile

 WHERE (trailerprofile.trl_type1 = @v_branch) and
       (trailerprofile.trl_number = legheader.lgh_primary_trailer) and
       (legheader.lgh_startdate >= @v_startdate and legheader.lgh_enddate <= @v_enddate) 
             
 
 ORDER BY mov_number

/**********************************************************************************************/
/*Insert ord_hdrnumber associated with each mov_number,to allow for multiple relationships between 
  different tables.
  Extract the total revenue from the invoiceheader table unique by ord_hdrnumber. 
  Calculate the total number of hours for each trailer/tractor per move, determine the EPM and EPH per tractor/trailer.
  Calculate the total number of days since the trailer was last used, calculate the total miles, empty miles and loaded miles per tractor/trailer. 
  Determine the current location of the trailer per the trailerprofile table(trl_avail_cmp_id column) */
/**********************************************************************************************/
   SELECT @minord = 0

   WHILE (SELECT COUNT(mov_number) FROM #temp
          WHERE mov_number > @minord) > 0

      BEGIN /*2*/

          SELECT @minord = min(mov_number)
	     FROM #temp
	    WHERE mov_number > @minord
        		
          UPDATE #temp
             SET ord_hdrnumber = stops.ord_hdrnumber
            FROM stops
           WHERE (stops.mov_number = @minord) and (#temp.mov_number = @minord) and (stops.ord_hdrnumber <> 0)


          UPDATE #temp
             SET revenue = invoiceheader.ivh_totalcharge
	    FROM invoiceheader,#temp
           WHERE invoiceheader.mov_number = @minord and #temp.mov_number = @minord  


         IF(SELECT count(*) FROM #temp
  	    WHERE (#temp.mov_number = @minord) and (revenue is null ))> 0

		BEGIN
		  UPDATE #temp
		     SET revenue = 0                         
                   WHERE #temp.mov_number = @minord
	        END          
	 
                     
	  UPDATE #temp
             SET curr_loc = company.cmp_name
	    FROM company,trailerprofile		 
           WHERE (#temp.mov_number = @minord) and (#temp.trailer_id = trailerprofile.trl_number) and
                 (trailerprofile.trl_avail_cmp_id = company.cmp_id)    


          UPDATE #temp
             SET unload = stops.cmp_id                             
            FROM stops
           WHERE (stops.mov_number = @minord) AND (#temp.mov_number = @minord) and
                  stops.stp_mfh_sequence = (SELECT MAX ( stp_mfh_sequence)
				 FROM stops, eventcodetable
				 WHERE (stops.mov_number = @minord) AND 
                                       stops.stp_type = "DRP" AND
                                       stops.stp_event = eventcodetable.abbr AND
                                       eventcodetable.ect_billable = "Y")
	     
          SELECT @begin_num = stops.stp_mfh_sequence
            FROM stops,#temp
           WHERE stops.mov_number = @minord and #temp.mov_number = @minord and 
                 stops.stp_mfh_sequence = (SELECT MIN(stops.stp_mfh_sequence)
			                     FROM stops
	                                    WHERE mov_number = @minord and stops.stp_type = 'PUP')

	  SELECT @end_num = stops.stp_mfh_sequence
            FROM stops,#temp
           WHERE stops.mov_number = @minord and #temp.mov_number = @minord and 
                 stops.stp_mfh_sequence = (SELECT MAX(stops.stp_mfh_sequence)
	     	                             FROM stops
	                                    WHERE mov_number = @minord and stops.stp_type = 'DRP')           

          SELECT @total_miles = sum(stops.stp_lgh_mileage)
            FROM stops,#temp
           WHERE stops.stp_lgh_mileage is not null and stops.mov_number = @minord and 
                 #temp.mov_number = @minord   	

	

          SELECT @miles_load = sum(stops.stp_lgh_mileage)
            FROM stops,#temp
           WHERE (stops.mov_number = @minord) and (#temp.mov_number = @minord) and 
                 (stops.stp_mfh_sequence > @begin_num and stops.stp_mfh_sequence <= @end_num)	

           
	  UPDATE #temp
             SET miles_loaded = @miles_load,
		 miles_empty  = @total_miles - @miles_load
           WHERE (#temp.mov_number = @minord)  


          IF(SELECT count(*) FROM #temp
	     WHERE (#temp.mov_number = @minord) and (miles_loaded is null ))> 0

		BEGIN
		  UPDATE #temp
		     SET miles_loaded = 0
                   WHERE #temp.mov_number = @minord
	        END


          IF(SELECT count(*) FROM #temp
              WHERE (#temp.mov_number = @minord) and (miles_empty is null ))> 0

		BEGIN
		  UPDATE #temp
		     SET miles_empty = 0                         
                   WHERE #temp.mov_number = @minord
	        END           
            
          UPDATE #temp
             SET miles_total = @total_miles
           WHERE (#temp.mov_number = @minord)  


          UPDATE #temp
             SET    hours_total = datediff(hh,start_date,end_date),
                 days_last_used = datediff(dd,end_date,getdate()) 
           WHERE #temp.mov_number = @minord

          IF(SELECT count(*) FROM #temp
             WHERE (hours_total = 0) and (#temp.mov_number = @minord)) >0

         	BEGIN
                 UPDATE #temp
                    SET hours_eph = 0
	          WHERE #temp.mov_number = @minord
                END

          ELSE 

                BEGIN
         	 UPDATE #temp
	            SET hours_eph = (revenue)/(hours_total)          
	          WHERE #temp.mov_number = @minord
	        END

          IF(SELECT count(*) FROM #temp
             WHERE (miles_total = 0) and (#temp.mov_number = @minord)) >0
          
        	BEGIN
                 UPDATE #temp
                    SET hours_epm = 0
	          WHERE #temp.mov_number = @minord
                END

          ELSE 
 
                BEGIN
                 UPDATE #temp
                    SET hours_epm = (revenue)/(miles_total)
	          WHERE #temp.mov_number = @minord
                END  
  
 
         
               
      END /*2*/

 END /*1*/
/**********************************************************************************************/

/* Display data from #temp table */

SELECT * FROM #temp
ORDER BY mov_number


GO
GRANT EXECUTE ON  [dbo].[d_trctrlutil_sp] TO [public]
GO
