SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_prnt_tripsheet_sp    Script Date: 6/1/99 11:54:52 AM ******/
/* create stored procedure */
CREATE PROC [dbo].[d_prnt_tripsheet_sp](@v_ordnumber char(12))

AS

/**********************************************************************************************/
/*Declaration and initialization of variables*/

DECLARE @char18  VarChar(10),
	@char11  datetime,
	@char10  VarChar(20),
	@char9	 varChar(50),
        @char6   Varchar(50),
	@char15  real,
        @char12  int,
	@char13  Varchar(255),
	@char14  Varchar(50),
	@char16  Varchar(255),
        @char17  Char(12),
        @char8   Varchar(50),
        @char7   Varchar(50),
	@maxnum  int,
	@minord  int,
        @minstp  int,
        @total_miles real,
        @origin_date datetime,
        @load_date datetime,
	@num	 int,
        @drp_bill int,
        @test varchar(255),
        @test1 varchar(255),
        @test2 varchar(255),
        @test3 varchar(255)

/* 
  print tripsheet for the current day, no input parameters would be needed 
  @v_startdate datetime, 
  @v_enddate   datetime       
  select  @v_startdate  = convert(char(12),today()) +'00:00:00'
  select  @v_enddate = convert(char(12),today())+'23:59:59' 
  select  @v_startdate  = convert(char(12),@v_startdate) +'00:00:00'
  select  @v_enddate = convert(char(12),@v_enddate)+'23:59:59'
*/

/**********************************************************************************************/
/*Create temporary waybill table for Printing of waybills process*/
   
SELECT @char10 tractor,
       @char10 trailer,
       @char17 bl_number,
       @char11 load_date,	
       @char11 del_date,
       @char18 shipper_id, 
       @char9  shipper_name,
       @char7  shipper_address,
       @char12 shipper_city,
       @char6  shipper_city_state,
       @char10 shipper_phone,
       @char18 consignee_id,
       @char9  consignee_name,
       @char7  consignee_address,
       @char12 consignee_city,
       @char6  consignee_city_state,
       @char10 consignee_phone, 
       @char14 broker,
       @char13 instructions1,
       @char13 instructions2,
       orderheader.ord_hdrnumber ord_hdrnumber
       	 
 INTO  #tripsheet 

 FROM  orderheader

WHERE  (orderheader.ord_number = @v_ordnumber) 

/**********************************************************************************************/
 SELECT @minord = 0

 WHILE (SELECT COUNT(distinct ord_hdrnumber) FROM #tripsheet
         WHERE ord_hdrnumber > @minord) > 0

 BEGIN /*1*/

      SELECT @minord = min ( ord_hdrnumber )
	FROM #tripsheet
       WHERE ord_hdrnumber > @minord 
	
         /* find waybill number for the order */ 

     	  UPDATE #tripsheet
	     SET bl_number = orderheader.ord_number                         	
            FROM orderheader,#tripsheet
           WHERE orderheader.ord_hdrnumber = @minord and 
                 #tripsheet.ord_hdrnumber = @minord	
		

   
         /* find first freight stop */ 

           UPDATE #tripsheet
              SET shipper_id = stops.cmp_id,
                  shipper_city = stops.stp_city,
                  load_date = stops.stp_schdtearliest           
             FROM stops
            WHERE stops.ord_hdrnumber = @minord AND #tripsheet.ord_hdrnumber = @minord and
                  stops.stp_mfh_sequence = (SELECT MIN ( stp_mfh_sequence )
				FROM stops, eventcodetable
				WHERE stops.ord_hdrnumber = @minord AND
                                      stops.stp_type = "PUP" AND
                                      stops.stp_event = eventcodetable.abbr AND
        			      eventcodetable.ect_billable = "Y" )
	    UPDATE #tripsheet
	       SET shipper_name = company.cmp_name,
                   shipper_address = company.cmp_address1,
		   shipper_city_state= company.cty_nmstct+' ,'+company.cmp_zip, 
                   shipper_phone = company.cmp_primaryphone	
              FROM company,#tripsheet
	     WHERE #tripsheet.ord_hdrnumber = @minord and 
                   #tripsheet.shipper_id = company.cmp_id 
                   

     
        /* find last freight stop */  

           UPDATE #tripsheet
              SET consignee_id = stops.cmp_id,
                  consignee_city = stops.stp_city,
                  del_date = stops.stp_schdtearliest                         
             FROM stops

            WHERE stops.ord_hdrnumber = @minord AND #tripsheet.ord_hdrnumber = @minord and
                  stops.stp_mfh_sequence = (SELECT MAX ( stp_mfh_sequence)
				              FROM stops, eventcodetable
				             WHERE stops.ord_hdrnumber = @minord AND
                                                   stops.stp_type = "DRP" AND
                                                   stops.stp_event = eventcodetable.abbr AND
                                                   eventcodetable.ect_billable = "Y")

	 UPDATE #tripsheet
	    SET consignee_name = company.cmp_name,
                consignee_address = company.cmp_address1,
                consignee_city_state= company.cty_nmstct+' ,'+company.cmp_zip ,
                consignee_phone = company.cmp_primaryphone	
           FROM company,#tripsheet
          WHERE #tripsheet.ord_hdrnumber = @minord and 
                #tripsheet.consignee_id = company.cmp_id 
               
       /* find tractor and trailer for the order */  

	UPDATE #tripsheet
	    SET tractor = event.evt_tractor,
                trailer = event.evt_trailer1                	
           FROM stops,event,#tripsheet
          WHERE stops.ord_hdrnumber = @minord and #tripsheet.ord_hdrnumber = @minord and 
                stops.stp_number = event.stp_number and 
                stops.stp_mfh_sequence  = (SELECT min (stp_mfh_sequence)
			 	               FROM stops, eventcodetable
				              WHERE stops.ord_hdrnumber = @minord AND
                                                    stops.stp_type = "PUP" AND
                                                    stops.stp_event = eventcodetable.abbr AND
                                                    eventcodetable.ect_billable = "Y") 
 
--old whereclause to extract tractor and trailer for tripsheet
-- where event.ord_hdrnumber = @minord and 
--       #tripsheet.ord_hdrnumber = @minord


   /*
      find instructions for the order from orderheader table
    
	IF(select count(*)
	      FROM orderheader
	     WHERE orderheader.ord_hdrnumber = @minord) >0

	 BEGIN
          
	  UPDATE #tripsheet
	     SET instructions = orderheader.ord_remark                          	
            FROM orderheader,#tripsheet
           WHERE orderheader.ord_hdrnumber = @minord and 
                 #tripsheet.ord_hdrnumber = @minord	
         END
	
        
   
      find instructions for the order from notes table
    

    	IF(SELECT count(*)
	     FROM notes
	    WHERE convert(int,notes.nre_tablekey) = @minord and
                  ntb_table = 'orderheader') > 0
         BEGIN

 	  UPDATE #tripsheet
	     SET instructions1 = notes.not_text                          	
            FROM notes,#tripsheet
           WHERE convert(int,notes.nre_tablekey) = @minord and
                 notes.ntb_table = 'orderheader' and 
                 #tripsheet.ord_hdrnumber = @minord	
	 END

   
      find instructions for the order from company table
    
	IF(SELECT count(*)
	     FROM company,#tripsheet
	    WHERE company.cmp_id = #tripsheet.consignee_id and
                  #tripsheet.ord_hdrnumber = @minord) >0

	 BEGIN

          UPDATE #tripsheet
             SET instructions2 = convert(varchar(255),company.cmp_directions)                          	
            FROM company,#tripsheet
           WHERE company.cmp_id = #tripsheet.consignee_id and 
                 #tripsheet.ord_hdrnumber = @minord	
	 END 
	*/
 END /*1*/


SELECT tractor,trailer,bl_number,shipper_id,shipper_name,shipper_address,shipper_city_state,
       shipper_phone,consignee_id,consignee_name,consignee_address,consignee_city_state,
       consignee_phone,load_date,del_date,instructions1,instructions2,
       ord_hdrnumber

 FROM #tripsheet
ORDER BY ord_hdrnumber

GO
GRANT EXECUTE ON  [dbo].[d_prnt_tripsheet_sp] TO [public]
GO
