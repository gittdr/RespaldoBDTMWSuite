SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_masterbill_sp    Script Date: 6/1/99 11:54:50 AM ******/
/* create stored procedure */
Create procedure  [dbo].[d_masterbill_sp](  @billto varchar(30),
                 	            @start_date datetime,
                        	    @end_date datetime,
	                            @print_status varchar(10),
        	                    @mbnumber int,
                	            @rpt_date datetime)
AS

BEGIN
/**********************************************************************************************/
/*Declaration and initialization of variables*/

DECLARE @char1  Varchar(30),
        @char2  int,
        @char3  datetime,
        @char4  real,
        @char5  money,
        @char6  Varchar(5),
        @char7  Varchar(13),
        @char8  Varchar(7),
	@minord int
	
select  @start_date  = convert(char(12),@start_date) +'00:00:00'
select  @end_date = convert(char(12),@end_date) +'23:59:59'

/**********************************************************************************************/
/*Create temporary table for MasterBill*/

SELECT ivh1.ivh_invoicenumber invoice_number, 
       ivh1.ivh_hdrnumber, 
       ivh1.ivh_revtype4, 
       ivh1.ivh_billdate, 
       ivh1.ivh_billto,
       ivh1.ivh_mbnumber,
       company.cmp_id cmp_billto_id,
       company.cmp_name cmp_billto_name,
       company.cmp_address1 cmp_billto_address1, 
       company.cmp_address2 cmp_billto_address2,
       company.cty_nmstct cmp_billto_cty_nmstct,
       company.cmp_zip cmp_billto_zip, 
       ivh1.ivh_carrier, 
       ivh1.ivh_totalcharge, 
       ivh1.ivh_shipdate,
       ivh1.ivh_ref_number,
       @rpt_date invoice_date, 
       car_name, 
       l.name, 
	ivd1.ivd_refnum,
/*
       (Select min(ref_number)    
          from referencenumber, 
               invoiceheader ivh2, 
               orderheader oh2, 
               stops 
         where ivh2.ivh_invoicenumber = ivh1.ivh_invoicenumber and ivh2.ord_hdrnumber = oh2.ord_hdrnumber
           and stops.ord_hdrnumber = oh2.ord_hdrnumber 	and stops.stp_number = referencenumber.ref_tablekey
           and referencenumber.ref_table = 'stops'and referencenumber.ref_type = 'BL#') stops_bl,
*/
       (Select min(ref_number) 	
          from referencenumber, 
               invoiceheader ivh3, 
               orderheader oh3 	
         where 	ivh3.ivh_invoicenumber = ivh1.ivh_invoicenumber 	and 
		ivh3.ord_hdrnumber = oh3.ord_hdrnumber  	   	and 
		oh3.ord_hdrnumber = referencenumber.ref_tablekey 	and 
		referencenumber.ref_table = 'stops'	and 
		referencenumber.ref_type = 'BL#') ordhdr_bl,
       ivd1.ord_hdrnumber ord_hdrnumber,
       @char2 carrier_order_num,
       @char1 unit_br,
       @char8 tractor,
       @char6 trailer,
       ivh1.ivh_consignee consignee_id,
       @char7 consignee,
       @char3 order_date,
       @char6 load_point,
       @char6 unld_point,
       ivd1.cmd_code product,
       ivd1.ivd_quantity quant,
       ivd1.ivd_rateunit um,
       ivd1.ivd_rate rate,
       @char4 freight_amount,
       ivd1.ivd_charge revenue,
       ivd1.cht_itemcode code,
       @char1 lab_gst,
       @char1 lab_pst,
       @char5 tot_gst,
       @char5 tot_pst,
       @char7 gst_number,
       @char7 branch_phone,
       @char1 cht_desc,
	ivd_sequence

 INTO #masterbill

 FROM company, 
      invoiceheader ivh1,
      invoicedetail ivd1, 
      city, 
      carrier, 
      labelfile l 
/* *************Commented jude 2/28/97***********	
 WHERE (ivd1.ord_hdrnumber = ivh1.ord_hdrnumber) AND 
***************Replaced by jude  2/28/97 with */
 WHERE (ivh1.ivh_hdrnumber = ivd1.ivh_hdrnumber  ) AND 
      (ivh1.ivh_billto = company.cmp_id ) AND 
      (ivh1.ivh_billto = @billto ) AND 
      (ivh_mbnumber is null OR ivh_mbnumber = 0 OR ivh_mbnumber = @mbnumber)AND 
      (ivh_mbstatus = @print_status OR (ivh_invoicestatus <> 'HLD' and ivh_mbstatus is null )) AND 
      (ivh_carrier = car_id ) AND 
      (l.labeldefinition = 'RevType4' )AND 
      (ivh_revtype4 = l.abbr )	and 
      (ivh1.ivh_shipdate between @start_date and @end_date) and 
      company.cmp_city = city.cty_code

/**********************************************************************************************/

  SELECT @minord = 0

  WHILE (SELECT COUNT(distinct ord_hdrnumber) FROM #masterbill
	   WHERE ord_hdrnumber > @minord) > 0

    BEGIN

	  SELECT @minord = min ( ord_hdrnumber )
	    FROM #masterbill
	   WHERE ord_hdrnumber > @minord
	
      /*find first frieght stop */

           UPDATE #masterbill
              SET load_point = stops.cmp_name              
             FROM stops
            WHERE stops.ord_hdrnumber = @minord AND #masterbill.ord_hdrnumber = @minord and
                  stops.stp_mfh_sequence = (SELECT MIN ( stp_mfh_sequence )
				FROM stops, eventcodetable
				WHERE stops.ord_hdrnumber = @minord AND
                                      stops.stp_type = "PUP" AND
                                      stops.stp_event = eventcodetable.abbr AND
         			      eventcodetable.ect_billable = "Y" )

      /*find last frieght stop*/  

           UPDATE #masterbill
              SET unld_point = stops.cmp_name                             
             FROM stops
            WHERE stops.ord_hdrnumber = @minord AND #masterbill.ord_hdrnumber = @minord and
                  stops.stp_mfh_sequence = (SELECT MAX ( stp_mfh_sequence)
				 FROM stops, eventcodetable
				 WHERE stops.ord_hdrnumber = @minord AND
                                       stops.stp_type = "DRP" AND
                                       stops.stp_event = eventcodetable.abbr AND
                                       eventcodetable.ect_billable = "Y")

     /*find tractor and trailer from the event table for each invoice*/
  
	   UPDATE #masterbill
              SET tractor = event.evt_tractor,
                  trailer = event.evt_trailer1
             FROM event
            WHERE event.ord_hdrnumber = @minord and #masterbill.ord_hdrnumber = @minord

     /*find order date from the orderheader table for each invoice*/

           UPDATE #masterbill
              SET order_date = orderheader.ord_datetaken
             FROM orderheader
            WHERE orderheader.ord_hdrnumber = @minord and #masterbill.ord_hdrnumber = @minord
                  

     /*find freight amount for each order for each invoice*/

           UPDATE #masterbill
              SET freight_amount = revenue
             from #masterbill,labelfile
            WHERE #masterbill.ord_hdrnumber = @minord 
                  

     /*find consignee for each order for each invoice*/

           UPDATE #masterbill
              SET consignee = company.cmp_name
             FROM company
            WHERE #masterbill.ord_hdrnumber = @minord and
                  #masterbill.consignee_id = company.cmp_id

 /**********************************************************************************************/
    /* GST and PST calculations */
	update #masterbill
           set tot_gst = (select sum(revenue) 
                            from #masterbill,labelfile
                           where #masterbill.ord_hdrnumber = @minord AND
                                 #masterbill.code = labelfile.abbr and  labelfile.labeldefinition = 'TaxType1')  
        from labelfile,#masterbill
        where #masterbill.ord_hdrnumber = @minord AND
              #masterbill.code = labelfile.abbr and  labelfile.labeldefinition = 'TaxType1'  
        


        update #masterbill
           set tot_pst = (select sum(revenue) 
                            from #masterbill,labelfile
                           where #masterbill.ord_hdrnumber = @minord AND
                                 #masterbill.code = labelfile.abbr and  labelfile.labeldefinition = 'TaxType2')  
        from labelfile,#masterbill
        where #masterbill.ord_hdrnumber = @minord AND
              #masterbill.code = labelfile.abbr and  labelfile.labeldefinition = 'TaxType2' 

    

         update #masterbill
            set lab_gst = (select labelfile.abbr 
                             from labelfile
                            where #masterbill.ord_hdrnumber = @minord and #masterbill.code = labelfile.abbr and
                                  labelfile.labeldefinition = 'TaxType1')

          from labelfile,#masterbill
         where #masterbill.ord_hdrnumber = @minord and #masterbill.code = labelfile.abbr and 
               labelfile.labeldefinition = 'TaxType1'

         update #masterbill
            set lab_pst = (select labelfile.abbr 
                             from labelfile
                            where #masterbill.ord_hdrnumber = @minord and #masterbill.code = labelfile.abbr and
                                  labelfile.labeldefinition = 'TaxType2')

          from labelfile,#masterbill
         where #masterbill.ord_hdrnumber = @minord and #masterbill.code = labelfile.abbr and 
               labelfile.labeldefinition = 'TaxType2'
 
/**********************************************************************************************/	
/*GST*/
	update #masterbill
           set #masterbill.product = #masterbill.code
          from #masterbill, labelfile
         where #masterbill.code = labelfile.abbr and labelfile.labeldefinition = 'TaxType1' and
               #masterbill.ord_hdrnumber = @minord

	update #masterbill
           set #masterbill.quant = (select sum(a.freight_amount) 
                                      from #masterbill a, labelfile b, labelfile c
                                     where  b.labeldefinition = 'TaxType1' and
                                            c.labeldefinition = 'TaxType2' and
                                            b.abbr <> a.code and c.abbr <> a.code)
	                                         
	 from #masterbill, labelfile
        where #masterbill.code = labelfile.abbr and labelfile.labeldefinition = 'TaxType1' and
              #masterbill.ord_hdrnumber = @minord

	update #masterbill
           set #masterbill.freight_amount = #masterbill.tot_gst
          from #masterbill, labelfile
         where #masterbill.code = labelfile.abbr and labelfile.labeldefinition = 'TaxType1' and
               #masterbill.ord_hdrnumber = @minord  
	
/**********************************************************************************************/
/*PST*/
	update #masterbill
           set #masterbill.product = #masterbill.code
          from #masterbill, labelfile
         where #masterbill.code = labelfile.abbr and labelfile.labeldefinition = 'TaxType2' and
               #masterbill.ord_hdrnumber = @minord

	update #masterbill
           set #masterbill.quant = (select sum(a.freight_amount) 
                                      from #masterbill a, labelfile b, labelfile c
                                     where  b.labeldefinition = 'TaxType1' and
                                            c.labeldefinition = 'TaxType2' and
                                            b.abbr <> a.code and c.abbr <> a.code)
	                                         
	 from #masterbill, labelfile
        where #masterbill.code = labelfile.abbr and labelfile.labeldefinition = 'TaxType2' and
              #masterbill.ord_hdrnumber = @minord

	update #masterbill
           set #masterbill.freight_amount = #masterbill.tot_pst
          from #masterbill, labelfile
         where #masterbill.code = labelfile.abbr and labelfile.labeldefinition = 'TaxType2' and
               #masterbill.ord_hdrnumber = @minord  


       /*Charge type description for accessorial charges*/
      
       update #masterbill
          set cht_desc = chargetype.cht_description
         from #masterbill,chargetype
        where #masterbill.code = chargetype.cht_itemcode and ord_hdrnumber = @minord


	
 END
/**********************************************************************************************/
   /*find branch */
   
       update #masterbill
	   set unit_br = orderheader.ord_revtype1
	  from orderheader
         where orderheader.ord_billto = @billto



   /*find branch tax id and branch phone*/

       update #masterbill
          set gst_number = branch.brn_tax_id,
              branch_phone = branch.brn_phone
         from branch,#masterbill
        where #masterbill.unit_br = branch.brn_id


END


/* get exchange */
INSERT INTO #masterbill

SELECT ivh1.ivh_invoicenumber invoice_number, 
       ivh1.ivh_hdrnumber, 
       '',
       ivh1.ivh_billdate, 
       '',
       0,
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       0,
       ivh1.ivh_shipdate,
       '',
       @rpt_date invoice_date, 
       '',
       '',
       '',
       '',
       ivh1.ord_hdrnumber ord_hdrnumber,
       0,
       '',
       '',
       '',
       '',
       '',
       @char3 order_date,
       '',
       '',
       'Exchange',
       ivh1.ivh_totalcharge,
	'%',
       (ivh1.ivh_archarge / ivh_totalcharge ), 
       (ivh_archarge - ivh1.ivh_totalcharge ), 
       (ivh_archarge - ivh1.ivh_totalcharge), 
       '',
       '',
       '',
       0,
       0,
       '',
       '',
       '',
	999

 FROM invoiceheader ivh1

WHERE (ivh1.ivh_billto = @billto ) AND 
      (ivh_mbnumber is null OR ivh_mbnumber = 0 OR ivh_mbnumber = @mbnumber)AND 
      (ivh_mbstatus = @print_status OR ivh_mbstatus is null ) AND 
      (ivh1.ivh_shipdate between @start_date and @end_date) and 
	ivh_archarge <> ivh_totalcharge


SELECT * from #masterbill
ORDER BY invoice_number, ivd_sequence


GO
GRANT EXECUTE ON  [dbo].[d_masterbill_sp] TO [public]
GO
