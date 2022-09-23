SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_load_matchdisp_sp](@v_startdate datetime,@v_enddate datetime)

AS

BEGIN /* 1 */

/**********************************************************************************************/
/*Declaration and initialization of variables*/

 DECLARE @char19  VarChar(50),
	 @char16  VarChar(50),
	 @char17  Varchar(50),
	 @char18  Varchar(50),
	 @char15  datetime,
         @char1   char(1),
	 @minord  int,
         @minlgh  int  

 /*SELECT  @v_date1 = @v_date*/
 SELECT  @v_startdate = convert(varchar(8),@v_startdate,112) +' 00:00:00'
 SELECT  @v_enddate   = convert(varchar(8),@v_enddate, 112)   +' 23:59:59'
/**********************************************************************************************/
/*Create temporary table for Load Matching Report*/
   
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
       @char1  load_eqmnt,
       @char1  unload_eqmnt,
       legheader.ord_hdrnumber ord_hdrnumber,
       legheader.lgh_number lgh_number            
       
 INTO  #temp 

 FROM  legheader
WHERE  (lgh_startdate >= @v_startdate and lgh_startdate <= @v_enddate) and
       (lgh_enddate >= @v_startdate and lgh_enddate <= @v_enddate) and 
       (lgh_enddate >= lgh_startdate)
	 
/**********************************************************************************************/

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

	/* Unload equipment (Blower, Compressor, Pump) */ 
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
		
	  

	/* load equipment (Blower, Compressor, Pump) */	   
	IF (select count(*)
              from loadrequirement
             where ord_hdrnumber = @minord and lrq_equip_type = 'TRL' and 
                   lrq_type = 'PMP' ) > 0
		
	   BEGIN

		UPDATE #temp
		   SET load_eqmnt = 'P'
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
		   SET load_eqmnt = 'B'
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
		   SET load_eqmnt = 'C'
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
       orig_cty_name,load_date,load_eqmnt,unload_eqmnt,ord_hdrnumber
FROM #temp

GO
GRANT EXECUTE ON  [dbo].[d_load_matchdisp_sp] TO [public]
GO
