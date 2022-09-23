SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [dbo].[d_stlmnt_rev_sp](
	@stringparm varchar(12),
	@numberparm int,
	@retrieve_by varchar(10))
AS
/****** Object:  Stored Procedure dbo.d_stlmnt_rev_sp    Script Date: 8/20/97 1:58:22 PM ******/
/* 070797 mf added where to make index selection on paydetail corrrectly 
/ 	(paydetail.ord_hdrnumber =* invoicedetail.ord_hdrnumber)	
/ Modified: 09/15/97 lor - corrected lesscharge 
/ Modified: 10/19/97 wsc - pts#3062 added return of ivh_invoicestatu
/ Modified: 10/22/97 wsc - pts#3062 fixed null column name for column 17 
/ Modified: 10/22/97 wsc - pts#3062 added return of ivh_mbstatus 
/ JD 2/15/00 rewrote procedure to avoid duplicates and unnecessary joins 
/ Vern Jewett	02/11/2002	PTS 12882	Label=vmj1	When orders are consolidated, sometimes only 1 ord_hdrnumber is being 
													returned, but we need multiple to show up.	
/ Vern Jewett	03/12/2002	PTS 12882	Label=vmj2	FIX, cross-docked moves are causing an error message, "One or more
													orders on this trip have not been invoiced.."	
/ Vern Jewett	07/30/2002	PTS 14924	Label=vmj3	Lengthen ivd_description from 30 to 60 chars.	
/ 11/07/2007.01 ? PTS40186 - JGUO ? convert old style outer join syntax to ansi outer join syntax. 
/ PTS 46271 - DJM - Added ivd_rate to the returned columns.
/ PTS 54191 SPN - added invoicedetail_tar_number
*/

Declare @ord_number char(12)

Create table #temp 
	   (cht_itemcode char(6) null,   
	    --vmj3+
   	    ivd_description varchar(60) null,   
--   	    ivd_description varchar(30) null ,   
	    --vmj3-
   	    ivd_charge money  null,   
   	    lesscharge money null,   
   	    ivd_payrevenue money null,   
   	    pyd_lessrevenue money null,   
   	    pyd_payrevenue money null,   
   	    pyd_number int null,   
   	    ivd_number int null,   
   	    cht_primary char(1) null,  
   	    pyd_revenueratio float null,   
   	    cmp_id varchar(8) null,   
   	    ord_hdrnumber int null,
	    pwork_required_count int null, 
 	    pwork_received_count int null,
   	    ivd_quantity float null,
	    ivh_invoicestatus varchar(6) null,
	    ivh_mbstatus varchar(6) null,
	    ivh_hdrnumber int null,
	    ivd_sequence int null,
	    orders_count int null,
	    ord_number char(12) null, 
        ord_revenue_pay money null, 
        ord_revenue_pay_fix int null, 
        inv_revenue_pay money null, 
        inv_revenue_pay_fix int null,
	    backouts money null,
        minimumcharge int default 0,
        cht_rollintolh  int     null,
		cht_lh_min		char(1) null,
		cht_lh_rev		char(1) null,
		cht_lh_stl		char(1) null,
		cht_lh_rpt		char(1) null,
		ivd_paylgh_number	int null,
		ivd_billable_flag	char (1) NULL,
		ivd_rate			money	null,	-- PTS 46271  - DJM
        cht_basis       varchar(6)
        , invoicedetail_tar_number   int null --PTS 54191 SPN
        )     --TGRIFFIT PTS#42170 12Jun08
        
create table #ord_hdr
      (ord_hdrnumber int null, 
       ord_revenue_pay money null, 
       ord_revenue_pay_fix int null)

insert into #ord_hdr (ord_hdrnumber, ord_revenue_pay, ord_revenue_pay_fix) 
  select distinct orderheader.ord_hdrnumber, orderheader.ord_revenue_pay, orderheader.ord_revenue_pay_fix 
    from stops, orderheader 
   where stops.mov_number = @numberparm and
         stops.ord_hdrnumber <> 0 and 
         orderheader.ord_hdrnumber = stops.ord_hdrnumber 

/* Used by d_stlmnt_rev datawindow */
IF (@retrieve_by = 'MOVE') 
BEGIN
	if exists (select * from generalinfo where gi_name = 'StlAllowZeroInvoice' and gi_string1='Y')
		Insert into #temp
				(cht_itemcode ,   
        		ivd_description ,   
        	    ivd_charge ,   
        	    lesscharge,
         	    ivd_payrevenue ,   
         	    pyd_lessrevenue ,   
         	    pyd_payrevenue ,   
         	    pyd_number ,   
         	    ivd_number ,   
         	    cht_primary ,  
          	    pyd_revenueratio ,   
         	    cmp_id ,   
         	    ord_hdrnumber ,
		 	    pwork_required_count , 
		 	    pwork_received_count ,
         	    ivd_quantity ,
			    ivh_invoicestatus,
		    	ivh_mbstatus ,
			    ivh_hdrnumber,
			    ivd_sequence ,
			    orders_count ,
		    	ord_number, 
                ord_revenue_pay, 
                ord_revenue_pay_fix, 
                inv_revenue_pay, 
                inv_revenue_pay_fix,
				cht_rollintolh,
				cht_lh_min,
				cht_lh_rev,
				cht_lh_stl,
				cht_lh_rpt,
				ivd_paylgh_number,
				ivd_billable_flag,
				ivd_rate,-- PTS 46271 - DJM
                cht_basis
                , invoicedetail_tar_number --PTS 54191 SPN
                )	--42170 TGRIFFIT
		  SELECT ivd.cht_itemcode,   
	         	ivd.ivd_description,   
    	    	ivd.ivd_charge,   
        		0 lesscharge,   
         		ivd.ivd_payrevenue,   
	         	0,   
    	     	0,   
        	 	0,   
         		ivd.ivd_number,   
	         	cht.cht_primary,  
    	      	0,   
        	 	ivd.cmp_id,   
         		ivd.ord_hdrnumber,
		 		0 pwork_required_count, 
			 	0 pwork_received_count,
        	 	ivd.ivd_quantity,
				IsNull(ivh.ivh_invoicestatus, '') ivh_invoicestatus,
				IsNull(ivh.ivh_mbstatus, '') ivh_mbstatus,
				ivd.ivh_hdrnumber,
				ivd.ivd_sequence,
				0 orders_count,
				@ord_number ord_number, 
                ord_revenue_pay, 
                ord_revenue_pay_fix, 
                inv_revenue_pay, 
                inv_revenue_pay_fix,
				ivd.cht_rollintolh,
				ivd.cht_lh_min,
				ivd.cht_lh_rev,
				ivd.cht_lh_stl,
				ivd.cht_lh_rpt,
				ivd.ivd_paylgh_number,
				ivd_billable_flag,
				ivd_rate,
                cht.cht_basis       --TGRIFFIT PTS#42170 12Jun08
                , ivd.tar_number --PTS 54191 SPN
		  FROM 	invoicedetail ivd  LEFT OUTER JOIN  invoiceheader ivh  ON  ivd.ivh_hdrnumber  = ivh.ivh_hdrnumber ,
				#ord_hdr oh,
				chargetype cht 
		  WHERE	oh.ord_hdrnumber = ivd.ord_hdrnumber	
			AND cht.cht_itemcode = ivd.cht_itemcode 
			AND ivd.cht_itemcode <> 'DEL' 
	else
		Insert into #temp
				(cht_itemcode ,   
       		    ivd_description ,   
       	    	ivd_charge ,   
	      	    lesscharge,
	       	    ivd_payrevenue ,   
    	   	    pyd_lessrevenue ,   
       		    pyd_payrevenue ,   
       	    	pyd_number ,   
	       	    ivd_number ,   
    	   	    cht_primary ,  
       		    pyd_revenueratio ,   
       	    	cmp_id ,   
	       	    ord_hdrnumber ,
		 	    pwork_required_count , 
	 		    pwork_received_count ,
       	    	ivd_quantity ,
			    ivh_invoicestatus,
			    ivh_mbstatus ,
			    ivh_hdrnumber,
		    	ivd_sequence ,
				orders_count ,
				ord_number, 
                ord_revenue_pay, 
                ord_revenue_pay_fix, 
                inv_revenue_pay, 
                inv_revenue_pay_fix,
				cht_rollintolh,
				cht_lh_min,
				cht_lh_rev,
				cht_lh_stl,
				cht_lh_rpt,
				ivd_paylgh_number,
				ivd_billable_flag,
				ivd_rate,
                cht_basis
                , invoicedetail_tar_number --PTS 54191 SPN
                )       --TGRIFFIT PTS#42170 12Jun08)
		  SELECT ivd.cht_itemcode,   
	         	ivd.ivd_description,   
    	    	ivd.ivd_charge,   
        		0 lesscharge,   
         		ivd.ivd_payrevenue,   
	         	0,   
    	     	0,   
        	 	0,   
         		ivd.ivd_number,   
	         	cht.cht_primary,  
    	      	0,   
        	 	ivd.cmp_id,   
         		ivd.ord_hdrnumber,
			 	0 pwork_required_count, 
			 	0 pwork_received_count,
        	 	ivd.ivd_quantity,
				IsNull(ivh.ivh_invoicestatus, '') ivh_invoicestatus,
				IsNull(ivh.ivh_mbstatus, '') ivh_mbstatus,
				ivd.ivh_hdrnumber,
				ivd.ivd_sequence,
				0 orders_count,
				@ord_number ord_number, 
                ord_revenue_pay, 
                ord_revenue_pay_fix, 
                inv_revenue_pay, 
                inv_revenue_pay_fix,
				ivd.cht_rollintolh,
				ivd.cht_lh_min,
				ivd.cht_lh_rev,
				ivd.cht_lh_stl,
				ivd.cht_lh_rpt,
				ivd.ivd_paylgh_number,
				ivd_billable_flag,
				ivd_rate,
                cht.cht_basis       --TGRIFFIT PTS#42170 12Jun08
                , ivd.tar_number --PTS 54191 SPN
		  FROM 	invoicedetail ivd  LEFT OUTER JOIN  invoiceheader ivh  ON  ivd.ivh_hdrnumber  = ivh.ivh_hdrnumber ,
				#ord_hdr oh,
				chargetype cht 
		  WHERE oh.ord_hdrnumber = ivd.ord_hdrnumber	
			AND cht.cht_itemcode = ivd.cht_itemcode 
			AND ivd.cht_itemcode <> 'DEL' 
			AND ( ivd.ivd_charge <> 0 OR ivd.ivd_quantity <> 0 OR ivd.ivd_rate <> 0 )

--	LOR	PTS# 33652
	If (SELECT count(*) FROM completion_invoicedetail c, #ord_hdr o 
		WHERE c.ord_hdrnumber = o.ord_hdrnumber and
				c.ivd_completion_billable_flag = 'N') > 0
		Insert into #temp
				(cht_itemcode ,   
       		    ivd_description ,   
       	    	ivd_charge ,   
	      	    lesscharge,
	       	    ivd_payrevenue ,   
    	   	    pyd_lessrevenue ,   
       		    pyd_payrevenue ,   
       	    	pyd_number ,   
	       	    ivd_number ,   
    	   	    cht_primary ,  
       		    pyd_revenueratio ,   
       	    	cmp_id ,   
	       	    ord_hdrnumber ,
		 	    pwork_required_count , 
	 		    pwork_received_count ,
       	    	ivd_quantity ,
			    ivh_invoicestatus,
			    ivh_mbstatus ,
			    ivh_hdrnumber,
		    	ivd_sequence ,
				orders_count ,
				ord_number, 
                ord_revenue_pay, 
                ord_revenue_pay_fix, 
                inv_revenue_pay, 
                inv_revenue_pay_fix,
				cht_rollintolh,
				cht_lh_min,
				cht_lh_rev,
				cht_lh_stl,
				cht_lh_rpt,
				ivd_paylgh_number,
				ivd_billable_flag,
				ivd_rate,
                cht_basis
                , invoicedetail_tar_number --PTS 54191 SPN
                )
		  SELECT ivd.cht_itemcode,   
	         	ivd.ivd_description,   
    	    	ivd.ivd_charge,   
        		0 lesscharge,   
         		ivd.ivd_payrevenue,   
	         	0,   
    	     	0,   
        	 	0,   
         		ivd.ivd_number,   
	         	cht.cht_primary,  
    	      	0,   
        	 	ivd.cmp_id,   
         		ivd.ord_hdrnumber,
			 	0 pwork_required_count, 
			 	0 pwork_received_count,
        	 	ivd.ivd_quantity,
				'' ivh_invoicestatus,
				'' ivh_mbstatus,
				ivd.ivh_hdrnumber,
				ivd.ivd_sequence,
				0 orders_count,
				@ord_number ord_number, 
                ord_revenue_pay, 
                ord_revenue_pay_fix, 
                0, 
                0,
				ivd.cht_rollintolh,
				ivd.cht_lh_min,
				ivd.cht_lh_rev,
				ivd.cht_lh_stl,
				ivd.cht_lh_rpt,
				ivd.ivd_paylgh_number,
				ivd_completion_billable_flag,
				ivd_rate,
                cht.cht_basis       --TGRIFFIT PTS#42170 12Jun08
                , ivd.tar_number --PTS 54191 SPN
		  FROM 	completion_invoicedetail ivd,
				#ord_hdr oh,
				chargetype cht
		  WHERE oh.ord_hdrnumber = ivd.ord_hdrnumber	
			AND cht.cht_itemcode = ivd.cht_itemcode 
			AND ivd.ivd_completion_billable_flag = 'N'
--	LOR	PTS# 33652

	if (SELECT COUNT(*) from #temp) >0
	BEGIN
		--vjh 27130 paperwork required should not count retired label file entries
		UPDATE #temp
		SET pwork_required_count =(SELECT count(*) 
                         			FROM labelfile lbf
						WHERE lbf.labeldefinition = 'PaperWork'	
							and (lbf.retired <> 'Y'
							or lbf.retired is NULL))
		UPDATE #temp			   
		SET pwork_received_count = (SELECT count(pwk.pw_received) 
			 			FROM paperwork pwk
						WHERE pwk.ord_hdrnumber = #temp.ord_hdrnumber
							AND pwk.pw_received = 'Y')
		update #temp
		  set	orders_count = 
					(select	count(distinct ord_hdrnumber)
					  from	stops
					  where	mov_number = @numberparm
						and	ord_hdrnumber <> 0)

		UPDATE #temp 
		SET    ord_number = orderheader.ord_number 
		FROM   orderheader where #temp.ord_hdrnumber = orderheader.ord_hdrnumber

		UPDATE #temp
		SET    backouts = 
				(SELECT sum (ibo_backoutamt)
				   FROM invoicebackouts
			          WHERE invoicebackouts.ord_hdrnumber = #temp.ord_hdrnumber AND 
                                        (ibo_ivh_hdrnumber = ivh_hdrnumber OR 
                                         ivh_hdrnumber = 0 OR
                                         ivh_hdrnumber IS NULL))

		update #temp
                set minimumcharge  =  (select count (ivd_number)
                                       from invoicedetail, #ord_hdr
                                      where invoicedetail.ord_hdrnumber = #ord_hdr.ord_hdrnumber
                                            and invoicedetail.cht_itemcode = 'MIN')

                update #temp
                   set ord_revenue_pay = 0, 
                       ord_revenue_pay_fix = 0, 
                       inv_revenue_pay = 0, 
                       inv_revenue_pay_fix = 0, 
                       backouts = NULL
                 where cht_itemcode <> 'MIN' AND 
-- LOR                       minimumcharge = 1
                       minimumcharge > 0
	END
END

IF (@retrieve_by = 'ESTIMATE') 
BEGIN
	Insert into #temp
			(cht_itemcode ,   
       	    ivd_description ,   
       	    ivd_charge ,   
       	    lesscharge,
       	    ivd_payrevenue ,   
       	    pyd_lessrevenue ,   
       	    pyd_payrevenue ,   
       	    pyd_number ,   
       	    ivd_number ,   
       	    cht_primary ,  
       	    pyd_revenueratio ,   
       	    cmp_id ,   
       	    ord_hdrnumber ,
	 	    pwork_required_count , 
	 	    pwork_received_count ,
       	    ivd_quantity ,
		    ivh_invoicestatus,
		    ivh_mbstatus ,
		    ivh_hdrnumber,
		    ivd_sequence ,
		    orders_count ,
		    ord_number, 
            ord_revenue_pay, 
            ord_revenue_pay_fix, 
            inv_revenue_pay, 
            inv_revenue_pay_fix,
			cht_rollintolh,
			cht_lh_min,
			cht_lh_rev,
			cht_lh_stl,
			cht_lh_rpt,
			ivd_paylgh_number,
			ivd_billable_flag,
				ivd_rate
            , invoicedetail_tar_number --PTS 54191 SPN
            )
	  SELECT ivd.cht_itemcode,   
         	ivd.ivd_description,   
        	ivd.ivd_charge,   
        	0 lesscharge,   
         	ivd.ivd_payrevenue,   
         	0,   
         	0,   
         	0,   
         	ivd.ivd_number,   
         	cht.cht_primary,  
          	0,   
         	ivd.cmp_id,   
         	ivd.ord_hdrnumber,
		 	0 pwork_required_count, 
		 	0 pwork_received_count,
         	ivd.ivd_quantity,
			IsNull(ivh.ivh_invoicestatus, '') ivh_invoicestatus,
			IsNull(ivh.ivh_mbstatus, '') ivh_mbstatus,
			ivd.ivh_hdrnumber,
			ivd.ivd_sequence,
			0 orders_count,
			@ord_number ord_number, 
            ord_revenue_pay, 
            ord_revenue_pay_fix, 
            inv_revenue_pay, 
            inv_revenue_pay_fix,
			ivd.cht_rollintolh,
			ivd.cht_lh_min,
			ivd.cht_lh_rev,
			ivd.cht_lh_stl,
			ivd.cht_lh_rpt,
			ivd.ivd_paylgh_number,
			ivd_billable_flag,
			ivd_rate
         , ivd.tar_number --PTS 54191 SPN
	  FROM 	invoicedetail ivd  LEFT OUTER JOIN  invoiceheader ivh  ON  ivd.ivh_hdrnumber  = ivh.ivh_hdrnumber ,
			#ord_hdr oh,
			chargetype cht
	  WHERE	oh.ord_hdrnumber = ivd.ord_hdrnumber	
		AND cht.cht_itemcode = ivd.cht_itemcode 
		AND ivd.cht_itemcode <> 'DEL' --17485 JD
		AND ( ivd.ivd_charge <> 0 OR ivd.ivd_quantity <> 0 OR ivd.ivd_rate <> 0 ) --17485JD

	  UNION 
	  SELECT ord.cht_itemcode,
			'', 
			ord.ord_charge, 		
			0 , 		
			0,		
			0,		
			0,		
			0, 		
			0, 
			cht.cht_primary,		
			0, 
			ord.ord_destpoint, 	
			ord.ord_hdrnumber,
	        0 pwork_required_count, 
	        0 pwork_received_count,
            ord.ord_quantity,
			'',
			'',
			0,
			0,
			0,
			@ord_number, 
            oh.ord_revenue_pay, 
            oh.ord_revenue_pay_fix, 
            0, 
            0,
			cht.cht_rollintolh,
			cht.cht_lh_min,
			cht.cht_lh_rev,
			cht.cht_lh_stl,
			cht.cht_lh_rpt,
			0,
			'',
			0
         , NULL --PTS 54191 SPN
	  FROM 	orderheader ord, 
			chargetype cht,
			#ord_hdr oh
	  WHERE cht.cht_itemcode = ord.cht_itemcode
		AND ord.ord_hdrnumber = oh.ord_hdrnumber
		AND ord.ord_invoicestatus <> 'PPD'

	if (select count(*) from #temp) > 0
	BEGIN
		UPDATE #temp
		SET pwork_required_count =(SELECT count(*)
                          			FROM  labelfile lbf
						WHERE lbf.labeldefinition = 'PaperWork')
		
		UPDATE #temp
		SET pwork_received_count = (SELECT count(pwk.pw_received)
			  			FROM paperwork pwk
			 			WHERE pwk.ord_hdrnumber = #temp.ord_hdrnumber
							AND pwk.pw_received = 'Y')
		update #temp
		  set	orders_count = 
					(select	count(distinct ord_hdrnumber)
					  from	stops
					  where	mov_number = @numberparm
						and	ord_hdrnumber <> 0)
		UPDATE #temp
		SET    ord_number = orderheader.ord_number 
		FROM   orderheader where #temp.ord_hdrnumber = orderheader.ord_hdrnumber

		UPDATE #temp
		SET    backouts = 
			(SELECT sum (ibo_backoutamt)
			   FROM invoicebackouts
		          WHERE invoicebackouts.ord_hdrnumber = #temp.ord_hdrnumber)
		
		update #temp
      set minimumcharge  =  (select count (ivd_number)
                             from invoicedetail, #ord_hdr
                            where invoicedetail.ord_hdrnumber = #ord_hdr.ord_hdrnumber
                                  and invoicedetail.cht_itemcode = 'MIN')

        update #temp
           set ord_revenue_pay = 0, 
               ord_revenue_pay_fix = 0, 
               inv_revenue_pay = 0, 
               inv_revenue_pay_fix = 0, 
               backouts = NULL
         where cht_itemcode <> 'MIN' AND 
-- LOR                       minimumcharge = 1
               minimumcharge > 0
	END
END /* IF ESTIMATE PAY */

UPDATE #temp 
   SET ivd_charge = (CASE WHEN inv_revenue_pay_fix = 1 AND cht_primary = 'Y' THEN inv_revenue_pay 
                          WHEN ord_revenue_pay_fix = 1 AND cht_primary = 'Y' THEN ord_revenue_pay 
                          ELSE ivd_charge
                     END)

update #temp
   set lesscharge = ISNULL(ivd_charge, 0) - ISNULL(ivd_payrevenue, 0)
-- - ISNULL(backouts, 0)
 where ivd_payrevenue > 0
       AND ivd_charge <> 0 

SELECT cht_itemcode, 
       ivd_description, 
       ivd_charge, 
       lesscharge, 
       ivd_payrevenue, 
       pyd_lessrevenue, 
       pyd_payrevenue, 
       pyd_number, 
       ivd_number, 
       cht_primary, 
       pyd_revenueratio, 
       cmp_id, 
       ord_hdrnumber, 
       pwork_required_count, 
       pwork_received_count, 
       ivd_quantity, 
       ivh_invoicestatus, 
       ivh_mbstatus, 
       ivh_hdrnumber, 
       ivd_sequence, 
       orders_count, 
       ord_number,
       backouts, 
       minimumcharge,
		cht_rollintolh,
		cht_lh_min,
		cht_lh_rev,
		cht_lh_stl,
		cht_lh_rpt,
		ivd_paylgh_number,
		ivd_billable_flag,
		ivd_rate,
        cht_basis --42170
        , invoicedetail_tar_number --PTS 54191 SPN
  FROM #temp


GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_rev_sp] TO [public]
GO
