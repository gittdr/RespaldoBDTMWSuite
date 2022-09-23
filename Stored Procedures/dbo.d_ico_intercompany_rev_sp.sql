SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

--PTS 46682 JJF 20110526
CREATE PROC [dbo].[d_ico_intercompany_rev_sp](
	@mov_number_parent int,
	@lgh_number_parent int
)
AS

Declare @mov_number_child int
Declare @lgh_number_child int
Declare @ord_number char(12)

Create table #temp 
	   (cht_itemcode char(6) null,   
   	    ivd_description varchar(60) null,   
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
		ivd_rate			money	null,	
        cht_basis       varchar(6)
        , invoicedetail_tar_number   int null ,
        pyd_amount money null,
        pyd_description varchar(75) null
        )     
        
create table #ord_hdr
      (ord_hdrnumber int null, 
       ord_revenue_pay money null, 
       ord_revenue_pay_fix int null)

select distinct top 1 @mov_number_child = lgh_c.mov_number
from	legheader lgh_p 
		inner join stops stp_p on stp_p.lgh_number = lgh_p.lgh_number
		inner join stops stp_c on stp_c.stp_number = stp_p.stp_ico_stp_number_child
		inner join legheader lgh_c on lgh_c.lgh_number = stp_c.lgh_number
where	lgh_p.mov_number = @mov_number_parent


select distinct top 1 @lgh_number_child = lgh_c.lgh_number
from	legheader lgh_p 
		inner join stops stp_p on stp_p.lgh_number = lgh_p.lgh_number
		inner join stops stp_c on stp_c.stp_number = stp_p.stp_ico_stp_number_child
		inner join legheader lgh_c on lgh_c.lgh_number = stp_c.lgh_number
where	lgh_p.lgh_number = @lgh_number_parent

--insert into #ord_hdr (ord_hdrnumber, ord_revenue_pay, ord_revenue_pay_fix) 
--  select distinct orderheader.ord_hdrnumber, orderheader.ord_revenue_pay, orderheader.ord_revenue_pay_fix 
--    from stops, orderheader 
--   where stops.mov_number = @mov_number_child and
--        stops.ord_hdrnumber <> 0 and 
--         orderheader.ord_hdrnumber = stops.ord_hdrnumber 

insert into #ord_hdr (ord_hdrnumber, ord_revenue_pay, ord_revenue_pay_fix) 
  select distinct orderheader.ord_hdrnumber, orderheader.ord_revenue_pay, orderheader.ord_revenue_pay_fix 
    from stops, orderheader 
   where stops.lgh_number = @lgh_number_child and
        stops.ord_hdrnumber <> 0 and 
         orderheader.ord_hdrnumber = stops.ord_hdrnumber 

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
            cht_basis,
            invoicedetail_tar_number, --PTS 54191 SPN
            pyd_amount,
            pyd_description
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
            cht.cht_basis,       
            ivd.tar_number,
            0,
            ''
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
            cht_basis,
            invoicedetail_tar_number,
            pyd_amount,
            pyd_description
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
			ivd_rate,
            cht.cht_basis,       
            ivd.tar_number,
            0,
            ''
	  FROM 	invoicedetail ivd  LEFT OUTER JOIN  invoiceheader ivh  ON  ivd.ivh_hdrnumber  = ivh.ivh_hdrnumber ,
			#ord_hdr oh,
			chargetype cht 
	  WHERE oh.ord_hdrnumber = ivd.ord_hdrnumber	
		AND cht.cht_itemcode = ivd.cht_itemcode 
		AND ivd.cht_itemcode <> 'DEL' 
		AND ( ivd.ivd_charge <> 0 OR ivd.ivd_quantity <> 0 OR ivd.ivd_rate <> 0 )


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
            cht_basis,
            invoicedetail_tar_number, --PTS 54191 SPN
            pyd_amount,
            pyd_description
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
            cht.cht_basis,     
            ivd.tar_number,
            0,
            ''
	  FROM 	completion_invoicedetail ivd,
			#ord_hdr oh,
			chargetype cht
	  WHERE oh.ord_hdrnumber = ivd.ord_hdrnumber	
		AND cht.cht_itemcode = ivd.cht_itemcode 
		AND ivd.ivd_completion_billable_flag = 'N'


if (SELECT COUNT(*) from #temp) >0
BEGIN
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
				  where	mov_number = @mov_number_child
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

--select * from #temp

--update	#temp
--set		pyd_amount = pyd_p.pyd_amount,
--		pyd_number = pyd_p.pyd_number
--from	paydetail pyd_p
--		inner join invoicedetail ivd_c on pyd_p.pyd_ico_ivd_number_child = ivd_c.ivd_number
--where	pyd_p.mov_number = @mov_number_parent	
--		and #temp.ivd_number = ivd_c.ivd_number	

update	#temp
set		pyd_amount = pyd_p.pyd_amount,
		pyd_number = pyd_p.pyd_number,
		pyd_description = pyd_p.pyd_description
from	paydetail pyd_p
		inner join invoicedetail ivd_c on pyd_p.pyd_ico_ivd_number_child = ivd_c.ivd_number
where	pyd_p.lgh_number = @lgh_number_parent	
		and #temp.ivd_number = ivd_c.ivd_number	
		
--update	#temp
--set		pyd_amount = pyd_p.pyd_amount,
--		pyd_number = pyd_p.pyd_number
--from	paydetail pyd_p
--		inner join paytype pyt_p on pyd_p.pyt_itemcode = pyt_p.pyt_itemcode
--		inner join legheader lgh_p on lgh_p.lgh_number = pyd_p.lgh_number
--		inner join stops stp_p on lgh_p.lgh_number = stp_p.lgh_number
--		inner join stops stp_c on stp_c.stp_number = stp_p.stp_ico_stp_number_child
--		inner join legheader lgh_c on stp_c.lgh_number = lgh_c.lgh_number
--		inner join orderheader oh_c on oh_c.mov_number = lgh_c.mov_number
--		inner join invoicedetail ivd_c on (ivd_c.ord_hdrnumber = oh_c.ord_hdrnumber and pyt_p.cht_itemcode = ivd_c.cht_itemcode)
--where	lgh_p.mov_number = @mov_number_parent
--		and pyd_p.pyd_ico_ivd_number_child = -1
--		and  pyt_p.pyt_basis = 'LGH'	
--		and #temp.ivd_number = ivd_c.ivd_number	

update	#temp
set		pyd_amount = pyd_p.pyd_amount,
		pyd_number = pyd_p.pyd_number,
		pyd_description = pyd_p.pyd_description
from	paydetail pyd_p
		inner join paytype pyt_p on pyd_p.pyt_itemcode = pyt_p.pyt_itemcode
		inner join legheader lgh_p on lgh_p.lgh_number = pyd_p.lgh_number
		inner join stops stp_p on lgh_p.lgh_number = stp_p.lgh_number
		inner join stops stp_c on stp_c.stp_number = stp_p.stp_ico_stp_number_child
		inner join legheader lgh_c on stp_c.lgh_number = lgh_c.lgh_number
		inner join orderheader oh_c on oh_c.mov_number = lgh_c.mov_number
		inner join invoicedetail ivd_c on (ivd_c.ord_hdrnumber = oh_c.ord_hdrnumber and pyt_p.cht_itemcode = ivd_c.cht_itemcode)
where	lgh_p.lgh_number = @lgh_number_parent
		and pyd_p.pyd_ico_ivd_number_child = -1
		and  pyt_p.pyt_basis = 'LGH'	
		and #temp.ivd_number = ivd_c.ivd_number	


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
        cht_basis,
        invoicedetail_tar_number,
        pyd_amount,
        pyd_description
  FROM #temp


GO
GRANT EXECUTE ON  [dbo].[d_ico_intercompany_rev_sp] TO [public]
GO
