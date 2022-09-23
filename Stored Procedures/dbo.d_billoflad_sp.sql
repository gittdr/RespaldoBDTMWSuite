SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_billoflad_sp    Script Date: 6/1/99 11:54:43 AM ******/
/* create stored procedure */

CREATE PROC [dbo].[d_billoflad_sp](@v_date datetime,@v_date1 datetime,@v_branch varchar(6))

AS

BEGIN

/**********************************************************************************************/
/*Declaration and initialization of variables*/

DECLARE @char18  VarChar(8),
	@char19  VarChar(8),
	@char17  VarChar(8),
	@char16  VarChar(8),
        @char20  Varchar(30),
	@char11  datetime,
	@char10  VarChar(6),
	@char9	 Char(1),
	@char1   Char(1),
	@char15  int,
        @char12  money,
        @char8  varchar(30),
	@maxnum  int,
	@minord  int,
        @minmov  int,
	@num	 int,
        @rate    real

	
select  @v_date  = convert(char(12),@v_date) +'00:00:00'
select  @v_date1 = convert(char(12),@v_date1) +'23:59:59'
select  @num = 0

/**********************************************************************************************/
/*Create temporary table for Bill of Lading Report*/
  
 
select invoiceheader.ivh_tractor unit,
       @char9  irr, 
       invoiceheader.ivh_invoicenumber inv_number,
       invoiceheader.ord_number bill_no,
       @char11 departure_date,
       @char15 origin_c,
       @char8  origin_city,
       @char10 origin_state,       
       @char15 lload_c,
       @char8  lload_city,
       @char10 lload_state,       
       @char15 unld_c,
       @char8  unld_city,
       @char10 unld_state,
       @char15 dest_c,
       @char8  dest_city,
       @char10 dest_state,       
       invoiceheader.ivh_billto custid,
       @char20 cust,
       @char10 br, 
       invoicedetail.cmd_code prod_id,
       @char8 prod,
       invoicedetail.ivd_rateunit um,
       invoicedetail.ivd_quantity quantity,
       invoicedetail.ivd_rate rate,
       sum(invoicedetail.ivd_charge) revenue,	
       invoicedetail.ord_hdrnumber ord_hdrnumber,
       @char1 multidrp,
       @char15 cnt,
       invoicedetail.cht_itemcode code,
       @char12 tot_gst,
       @char12 tot_pst,
       @char8 lab_gst,
       @char8 lab_pst,
       invoiceheader.ivh_archarge archarge,
       invoiceheader.ivh_totalcharge totalcharge,
       @char12 cdn_revenue,
       invoiceheader.mov_number mov_number
       
    	 
into	#temp 

from  invoiceheader,invoicedetail
where (invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber)  and 
      (invoiceheader.ivh_billdate BETWEEN @v_date and @v_date1) and
      (invoiceheader.ivh_revtype1 = @v_branch) and
      (invoiceheader.ivh_invoicestatus = "PRN" OR invoiceheader.ivh_mbstatus = 'PRN') 

group by invoiceheader.ivh_tractor, 
         invoiceheader.ivh_invoicenumber,
         invoiceheader.ord_number,
         invoiceheader.ivh_billto,
         invoicedetail.cmd_code,
         invoicedetail.ivd_rateunit,
         invoicedetail.ivd_quantity,
         invoicedetail.ivd_rate,
         invoicedetail.ord_hdrnumber,
         invoicedetail.stp_number,
         invoicedetail.cht_itemcode,
         invoiceheader.ivh_archarge,
         invoiceheader.ivh_totalcharge,
         invoiceheader.mov_number
        
       
/**********************************************************************************************/
  SELECT @minord = 0


  WHILE (SELECT COUNT(distinct ord_hdrnumber) FROM #temp
	   WHERE ord_hdrnumber > @minord) > 0

    BEGIN

	  SELECT @num = @num + 1
	  SELECT @minord = min ( ord_hdrnumber )
	    FROM #temp
	   WHERE ord_hdrnumber > @minord
	
/*find first frieght stop */


           UPDATE #temp
              SET lload_c = stops.stp_city,
                  lload_state = stops.stp_state              
             FROM stops
            WHERE stops.ord_hdrnumber = @minord AND #temp.ord_hdrnumber = @minord and
                  stops.stp_mfh_sequence = (SELECT MIN ( stp_mfh_sequence )
				FROM stops, eventcodetable
				WHERE stops.ord_hdrnumber = @minord AND
                                      stops.stp_type = "PUP" AND
                                      stops.stp_event = eventcodetable.abbr AND
         			      eventcodetable.ect_billable = "Y" )

/*find last frieght stop*/  

           UPDATE #temp
              SET unld_c = stops.stp_city,
                  unld_state = stops.stp_state                             
             FROM stops
            WHERE stops.ord_hdrnumber = @minord AND #temp.ord_hdrnumber = @minord and
                  stops.stp_mfh_sequence = (SELECT MAX ( stp_mfh_sequence)
				 FROM stops, eventcodetable
				 WHERE stops.ord_hdrnumber = @minord AND
                                       stops.stp_type = "DRP" AND
                                       stops.stp_event = eventcodetable.abbr AND
                                       eventcodetable.ect_billable = "Y")

/*determine if the move contains multiple drops*/

	IF(select count(*)
	   FROM	 stops
	   WHERE stops.ord_hdrnumber = @minord and
	         stops.stp_type = "DRP") > 1

	 BEGIN
	   UPDATE #temp
              SET #temp.multidrp = 'Y'
             FROM stops
            WHERE stops.ord_hdrnumber = @minord and #temp.ord_hdrnumber = @minord 
 	 END
		   
        /*Insert departure date from stops table*/
           UPDATE #temp
              SET #temp.departure_date = event.evt_startdate
             FROM event
            WHERE event.ord_hdrnumber = @minord AND #temp.ord_hdrnumber = @minord 



	/*Insert branch that owns the unit from tractorprofile table*/
          UPDATE #temp
             SET br = orderheader.ord_revtype1
            FROM #temp,orderheader
           WHERE orderheader.ord_hdrnumber = @minord and #temp.ord_hdrnumber = @minord

	/* determine the rate for each invoicedetail line and multiply the rate by the revenue amount*/
	select @rate = archarge/totalcharge
          from #temp
         where #temp.ord_hdrnumber = @minord

	update #temp
           set cdn_revenue = @rate * #temp.revenue
          where #temp.ord_hdrnumber = @minord




      END 

/*update table with a distinct number of bills */
UPDATE #temp
   SET cnt = @num



/**********************************************************************************************/
/* find origin stop*/  

  SELECT @minmov = 0

  WHILE ( SELECT COUNT(distinct mov_number) FROM #temp
	   WHERE mov_number > @minmov ) > 0
	
	Begin
	
	  SELECT @minmov = min ( mov_number )
	    FROM #temp
	   WHERE mov_number > @minmov
	


  

      IF(select count(*)
	   FROM	 stops
	   WHERE stops.mov_number = @minmov and
	         stops.stp_mfh_sequence = 1 AND
		 stops.stp_type = "NONE") > 0		
	BEGIN

          UPDATE  #temp
             SET  origin_c = stops.stp_city,
                  origin_state = stops.stp_state 
            FROM  stops
           WHERE  stops.mov_number = @minmov AND #temp.mov_number = @minmov and
                  stops.stp_mfh_sequence = 1  and stops.stp_type = "NONE"
	END

     ELSE

	BEGIN
          UPDATE #temp
             SET #temp.origin_c = #temp.lload_c,
                 #temp.origin_state = #temp.lload_state                 
       	END		   
	    	   					      

  END
/**********************************************************************************************/
/* find destination stop*/  

  SELECT @minmov = 0

  WHILE ( SELECT COUNT(distinct mov_number) FROM #temp
	   WHERE mov_number > @minmov  ) > 0

	Begin
	
	  SELECT @minmov = min ( mov_number )
	    FROM #temp
	   WHERE mov_number > @minmov
	


  
       select @maxnum = max(stp_mfh_sequence)
         from stops
        where stops.mov_number = @minmov and stops.stp_type = "NONE"       


      IF(select count(*)
	   FROM	 stops
	   WHERE stops.mov_number = @minmov and
	         stops.stp_mfh_sequence = @maxnum AND
		 stops.stp_type = "NONE") > 0		
	BEGIN
          UPDATE  #temp
             SET  dest_c = stops.stp_city,
                  dest_state = stops.stp_state  
            FROM  stops
           WHERE  stops.mov_number = @minmov AND #temp.mov_number = @minmov and
                  stops.stp_mfh_sequence = @maxnum  and stops.stp_type = "NONE"
	END

     ELSE

	BEGIN
          UPDATE #temp
             SET #temp.dest_c = #temp.unld_c,
                 #temp.dest_state = #temp.unld_state                 
       	END		   
	    	   					      
  END
/**********************************************************************************************/
/*determine if the trip is an irregular haul(more than one trailor)*/

 SELECT @minord = 0
 
 WHILE ( SELECT COUNT(distinct ord_hdrnumber) FROM #temp
	   WHERE ord_hdrnumber > @minord  ) > 0
  BEGIN
	  SELECT @minord = min(ord_hdrnumber)
	    FROM #temp
	   WHERE ord_hdrnumber > @minord
	
 	      
      if (select count(distinct event.evt_trailer1)
            from stops, event
           where (stops.ord_hdrnumber = @minord) and 
                 (stops.stp_number = event.stp_number) and (event.evt_trailer1 <> 'UNKNOWN')) <> 1
	BEGIN
	  UPDATE  #temp
             SET  irr = 'Y'
            FROM  stops,#temp
           WHERE  stops.ord_hdrnumber = @minord AND #temp.ord_hdrnumber = @minord  
        END         
	

     ELSE

	BEGIN
          UPDATE  #temp
             SET  irr = 'N'
            FROM  stops,#temp
           WHERE  stops.ord_hdrnumber = @minord AND #temp.ord_hdrnumber = @minord 
          
       	END		   
	    	   					      
  END


 /*insert company description*/
         UPDATE #temp
            SET #temp.cust = company.cmp_altid
           FROM company
          WHERE #temp.custid = company.cmp_id


/*insert city name from the city table*/
	update #temp
           set lload_city = city.cty_name
               
          from city 
	  where lload_c = city.cty_code 

          update #temp
              set unld_city = city.cty_name
               
          from city 
	  where unld_c = city.cty_code 


        update #temp
           set origin_city = city.cty_name
               
          from city 
	  where origin_c = city.cty_code 

          update #temp
              set dest_city = city.cty_name
               
          from city 
	  where dest_c = city.cty_code 

 /*insert company description*/
         UPDATE #temp
            SET #temp.prod = commodity.cmd_name
           FROM commodity
          WHERE #temp.prod_id = commodity.cmd_code
                  
/**********************************************************************************************/
/*calculate total gst and pst*/

  update #temp
     set tot_gst = (select sum(revenue) 
                      from #temp,labelfile
                     where #temp.code = labelfile.abbr and  labelfile.labeldefinition = 'TaxType1')  
  update #temp
     set tot_pst = (select sum(revenue) 
                      from #temp,labelfile
                     where #temp.code = labelfile.abbr and  labelfile.labeldefinition = 'TaxType2')  
  

  update #temp
     set lab_gst = (select labelfile.abbr 
                      from labelfile
                     where labelfile.labeldefinition = 'TaxType1')  
  update #temp
     set lab_pst = (select labelfile.abbr 
                      from labelfile
                     where labelfile.labeldefinition = 'TaxType2')  


/**********************************************************************************************/
END

select  unit,
        irr, 
        inv_number,
        bill_no,
        departure_date,
        origin_city,
        origin_state,
        lload_city,    
        lload_state,
        unld_city,
        unld_state,
        dest_city,
        dest_state,
        custid,
        cust,
        br, 
        prod,
        um,
        quantity,
        rate,
        revenue,	
        ord_hdrnumber,
        multidrp,
        cnt,
        tot_gst,
        tot_pst,
        lab_gst,
        lab_pst,
        cdn_revenue
        
from #temp
where #temp.code <> 'PST' and #temp.code <> 'GST'
order by ord_hdrnumber


GO
GRANT EXECUTE ON  [dbo].[d_billoflad_sp] TO [public]
GO
