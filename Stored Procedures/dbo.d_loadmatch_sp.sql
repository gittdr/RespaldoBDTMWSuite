SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [dbo].[d_loadmatch_sp](@v_startdate datetime,@v_enddate datetime,@v_branch varchar(6))

AS
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/29/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

BEGIN /* 1 */

/**********************************************************************************************/
/*Declaration and initialization of variables*/

 DECLARE @char19  VarChar(50),
	 @char16  VarChar(50),
	 @char17  Varchar(50),
	 @char18  Varchar(50),
         @char15  datetime,
         @char1   char(1),
	 @minord  int ,
         @minlgh  int 


 /*SELECT  @v_date1 = @v_date*/
 SELECT  @v_startdate = convert(varchar(8),@v_startdate) +' 00:00:00'
 SELECT  @v_enddate   = convert(varchar(8),@v_enddate)   +' 23:59:59'
/**********************************************************************************************/
 /*Create temporary table for Load Matching Report*/
   
 /* select @char15 delivery_date,
       @char19 tractor,
       @char16 trl,
       @char17 consignee,
       @char18 del_cty_name,	
       legheader.cmd_code products,
       @char17 shipper,
       @char18 orig_cty_name,
       @char15 load_date,
       @char1  unload_eqmnt,
       legheader.ord_hdrnumber ord_hdrnumber            
       
       INTO  #temp */

 select legheader.lgh_enddate delivery_date,
       legheader.lgh_tractor tractor,
       legheader.lgh_primary_trailer trl,
       @char17 consignee,
       legheader.lgh_endcity del_cty_name_id,
       @char18 del_cty_name,	
       legheader.cmd_code products,
       @char17 shipper,
       legheader.lgh_startcity orig_cty_name_id,
       @char18 orig_cty_name,
       legheader.lgh_startdate load_date,
       @char1  unload_eqmnt,
       legheader.ord_hdrnumber ord_hdrnumber,
       legheader.lgh_number lgh_number,            
       orderheader.ord_revtype1 branch      
 INTO  #temp 



 FROM  legheader LEFT OUTER JOIN orderheader ON orderheader.ord_hdrnumber = legheader.ord_hdrnumber
WHERE  (lgh_startdate >= @v_startdate and lgh_startdate <= @v_enddate) and
       (lgh_enddate >= @v_startdate and lgh_enddate <= @v_enddate) and 
       (lgh_enddate >= lgh_startdate) 
       --(orderheader.ord_hdrnumber =* legheader.ord_hdrnumber) 	 
/**********************************************************************************************/
/* Code used to create report initially,code has been commented out to allow new code to account for 0 
   ord_hdrnumbers within the legheader
   SELECT @minord = 0

   WHILE (SELECT COUNT(ord_hdrnumber) FROM #temp
          WHERE ord_hdrnumber > @minord) > 0

      BEGIN /*2*/

          SELECT @minord = min(ord_hdrnumber)
	     FROM #temp
	    WHERE ord_hdrnumber > @minord

		UPDATE #temp
		   SET delivery_date = orderheader.ord_completiondate,
		       load_date = orderheader.ord_startdate
	          FROM orderheader,#temp	
		 WHERE orderheader.ord_hdrnumber = @minord and #temp.ord_hdrnumber = @minord

		UPDATE #temp
                   SET trl = legheader.lgh_primary_trailer
                  FROM legheader,#temp
                 WHERE legheader.ord_hdrnumber = @minord and #temp.ord_hdrnumber = @minord

		UPDATE #temp
                   SET tractor = event.evt_tractor
                  FROM event
                 WHERE (trl = event.evt_trailer1) and (event.ord_hdrnumber = @minord) and 
		       (#temp.ord_hdrnumber = @minord)

		UPDATE #temp
                   SET del_cty_name =city.cty_name
                  FROM city,orderheader
                 WHERE (orderheader.ord_destcity = city.cty_code) and 
                       (#temp.ord_hdrnumber = @minord) and (orderheader.ord_hdrnumber = @minord)

                UPDATE #temp
                   SET orig_cty_name =city.cty_name
                  FROM city, orderheader
                 WHERE (orderheader.ord_origincity = city.cty_code) and  
	               (#temp.ord_hdrnumber = @minord) and (orderheader.ord_hdrnumber = @minord)

		UPDATE #temp
		   SET consignee = company.cmp_name
                  FROM orderheader,company
	         WHERE (orderheader.ord_hdrnumber = @minord) and (#temp.ord_hdrnumber = @minord) and
                       (orderheader.ord_consignee = company.cmp_id)

		UPDATE #temp
		   SET shipper = company.cmp_name
                  FROM orderheader,company
	         WHERE (orderheader.ord_hdrnumber = @minord) and (#temp.ord_hdrnumber = @minord) and
                       (orderheader.ord_shipper = company.cmp_id) */

/* New code inserted to allow for 0 ord_hdrnumber within the legheader table*/
SELECT @minord = 0

   WHILE (SELECT COUNT(ord_hdrnumber) FROM #temp
          WHERE ord_hdrnumber > @minord) > 0

      BEGIN /*2*/

          SELECT @minord = min(ord_hdrnumber)
	     FROM #temp
	    WHERE ord_hdrnumber > @minord


		UPDATE #temp
		   SET consignee = company.cmp_name
                  FROM orderheader,company
	         WHERE (orderheader.ord_hdrnumber = @minord) and (#temp.ord_hdrnumber = @minord) and
                       (orderheader.ord_consignee = company.cmp_id)

		UPDATE #temp
		   SET shipper = company.cmp_name
                  FROM orderheader,company
	         WHERE (orderheader.ord_hdrnumber = @minord) and (#temp.ord_hdrnumber = @minord) and
                       (orderheader.ord_shipper = company.cmp_id)



	/* unload equipment (Blower, Compressor, Pump) */
	IF (select count(*)
              from loadrequirement
             where ord_hdrnumber = @minord and lrq_equip_type = 'TRL' and 
                   lrq_type = 'PMP' ) > 0
		
	   BEGIN

		UPDATE #temp
		   SET unload_eqmnt = 'P'
                  FROM loadrequirement,#temp
	         WHERE (loadrequirement.ord_hdrnumber = @minord) and (#temp.ord_hdrnumber = @minord) and
                       (loadrequirement.lrq_equip_type = 'TRL') and
                       (loadrequirement.lrq_type = 'PMP')
           END

       IF (select count(*)
             from loadrequirement
             where ord_hdrnumber = @minord and lrq_equip_type = 'TRL' and 
                   lrq_type = 'BLW' ) > 0
	  
           BEGIN
         	UPDATE #temp
		   SET unload_eqmnt = 'B'
                  FROM loadrequirement,#temp
	         WHERE (loadrequirement.ord_hdrnumber = @minord) and (#temp.ord_hdrnumber = @minord) and 
                       (loadrequirement.lrq_equip_type = 'TRL') and

                       (loadrequirement.lrq_type = 'BLW')
	   END



      IF (select count(*)
              from loadrequirement
             where ord_hdrnumber = @minord and lrq_equip_type = 'TRL' and 
                   lrq_type = 'CMP') > 0
	
           BEGIN
		UPDATE #temp
		   SET unload_eqmnt = 'C'
                  FROM loadrequirement,#temp
	         WHERE (loadrequirement.ord_hdrnumber = @minord) and (#temp.ord_hdrnumber = @minord) and 
                       (loadrequirement.lrq_equip_type = 'TRL') and
                       (loadrequirement.lrq_type = 'CMP')

  	   END

      END /*2*/	


 SELECT @minlgh = 0

   WHILE (SELECT COUNT(lgh_number) FROM #temp
          WHERE lgh_number > @minlgh) > 0

      BEGIN /*3*/

          SELECT @minlgh = min(lgh_number)
	     FROM #temp
	    WHERE lgh_number > @minlgh


		UPDATE #temp
                   SET del_cty_name =city.cty_name
                  FROM city
                 WHERE (#temp.del_cty_name_id = city.cty_code) and 
                       (#temp.lgh_number = @minlgh) 

                UPDATE #temp
                   SET orig_cty_name =city.cty_name
                  FROM city
                 WHERE (#temp.orig_cty_name_id = city.cty_code) and  
	               (#temp.lgh_number = @minlgh) 
      END /*3*/		


/**********************************************************************************************/

END /*1*/

/* Display data from #temp table */
SELECT delivery_date,tractor,trl,consignee,del_cty_name,products,shipper,
       orig_cty_name,load_date,unload_eqmnt,ord_hdrnumber
FROM  #temp
where #temp.branch = @v_branch  

GO
GRANT EXECUTE ON  [dbo].[d_loadmatch_sp] TO [public]
GO
