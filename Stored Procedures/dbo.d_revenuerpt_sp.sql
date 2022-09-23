SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_revenuerpt_sp    Script Date: 6/1/99 11:54:53 AM ******/
/* create stored procedure */
CREATE PROC [dbo].[d_revenuerpt_sp](@v_date datetime,@v_date1 datetime,@v_branch varchar(6))

AS

BEGIN

/**********************************************************************************************/
/*Declaration and initialization of variables*/

DECLARE @char18  VarChar(8),	
	@char10  VarChar(13),	
	@char15  int,
        @char16  VarChar(30),
	@maxnum  int,
	@minord  int,
        @char12 money,
        @char11 real,
        @char8 varchar(30),
        @dis_miles real,
        @rev     money,
        @minmov  int,
        @minivh  int
	
/*select  @v_date1 = @v_date*/
 select  @v_date  = convert(char(12),@v_date) +'00:00:00'
 select  @v_date1 = convert(char(12),@v_date1)+'23:59:59'
/**********************************************************************************************/
/*Create temporary table for Daily Revenue Report*/
select invoiceheader.ivh_tractor tractor_id,
       invoiceheader.ivh_trailer trailor_id,
       @char10 pup,
       @char8 commodity1, 
       invoicedetail.cmd_code cmd_code,
       invoiceheader.ord_number waybills,      
       @char8 lload,       
       @char8 unld,      
       @char11 distance,
       @char12 revenue,	
       invoicedetail.ord_hdrnumber ord_hdrnumber,
       invoiceheader.ivh_billto billto_code,
       invoicedetail.cht_itemcode code,
       @char8 billto,
       @char12 tot_gst,
       @char12 tot_pst,
       @char8  lab_gst,
       @char8  lab_pst,
       invoiceheader.mov_number mov_number,
       invoiceheader.ivh_hdrnumber ivh_hdrnumber     
 
into	#temp 

from invoiceheader,invoicedetail
where (invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber)  and 
      (invoiceheader.ivh_billdate BETWEEN @v_date and @v_date1) and 
      (invoiceheader.ivh_revtype1 = @v_branch)

group by invoiceheader.ivh_tractor,
         invoiceheader.ivh_trailer,
         invoicedetail.cmd_code,
         invoiceheader.ord_number,
         invoicedetail.ord_hdrnumber,
         invoiceheader.ivh_billto,
         invoicedetail.cht_itemcode,
         invoiceheader.mov_number,
         invoiceheader.ivh_hdrnumber

/**********************************************************************************************/
  SELECT @minord = 0

  WHILE (SELECT COUNT(distinct ord_hdrnumber) FROM #temp
	   WHERE ord_hdrnumber > @minord) > 0

    BEGIN

	  SELECT @minord = min ( ord_hdrnumber )
	    FROM #temp
	   WHERE ord_hdrnumber > @minord

	
           /*find first frieght stop */
           UPDATE #temp
              SET lload = stops.cmp_name                     
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
              SET unld = stops.cmp_name                                              
             FROM stops
            WHERE stops.ord_hdrnumber = @minord AND #temp.ord_hdrnumber = @minord and
                  stops.stp_mfh_sequence = (SELECT MAX ( stp_mfh_sequence)
				 FROM stops, eventcodetable
				 WHERE stops.ord_hdrnumber = @minord AND
                                       stops.stp_type = "DRP" AND
                                       stops.stp_event = eventcodetable.abbr AND
                                       eventcodetable.ect_billable = "Y")


        /*insert pup trailor id*/
         UPDATE #temp
            SET #temp.pup = event.evt_trailer2
           FROM event
          WHERE event.ord_hdrnumber = @minord and #temp.ord_hdrnumber = @minord 


        /*insert commodity description*/
         UPDATE #temp
            SET #temp.commodity1 = orderheader.cmd_code
           FROM orderheader
          WHERE orderheader.ord_hdrnumber = @minord and #temp.ord_hdrnumber = @minord

        
      END


         /*insert billto name*/
         UPDATE #temp
            SET #temp.billto = company.cmp_name
           FROM company
          WHERE #temp.billto_code = company.cmp_id
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
  SELECT @minmov = 0

  WHILE (SELECT COUNT(distinct mov_number) FROM #temp
	   WHERE mov_number > @minmov) > 0

    BEGIN

	  SELECT @minmov = min ( mov_number )
	    FROM #temp
	   WHERE mov_number > @minmov

	
        /*total distance for all stops pertaining to a particular move*/
	  select @dis_miles = sum(stp_lgh_mileage)
            from stops
           where stops.mov_number = @minmov 
	
	
	  update #temp
             set distance = @dis_miles
	   where #temp.mov_number = @minmov

    end
/**********************************************************************************************/
  SELECT @minivh = 0

  WHILE (SELECT COUNT(distinct ivh_hdrnumber) FROM #temp
	   WHERE ivh_hdrnumber > @minivh) > 0

    BEGIN

	  SELECT @minivh = min ( ivh_hdrnumber )
	    FROM #temp
	   WHERE ivh_hdrnumber > @minivh


	/*total revenue ivh_archarge per invoice*/         
	select @rev = sum(ivh_archarge)
          from invoiceheader
         where invoiceheader.ivh_hdrnumber = @minivh    

	update #temp
           set revenue = @rev
	  where #temp.ivh_hdrnumber = @minivh

    end
/**********************************************************************************************/
END

SELECT DISTINCT
       tractor_id,
       trailor_id,
       pup,
       commodity1, 
       waybills,      
       lload,       
       unld,      
       distance,
       revenue,	
       ord_hdrnumber,
       billto_code,
       billto
      
    
from #temp
where code <> 'PST' and code <> 'GST'
ORDER BY waybills



GO
GRANT EXECUTE ON  [dbo].[d_revenuerpt_sp] TO [public]
GO
