SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_comm_alloc_sp]( @start_dt datetime, @end_dt datetime)

AS
/**
 * 
 * NAME:
 * dbo.d_comm_alloc_sp
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001:    
 * Calls002:    
 *
 * CalledBy001:  
 * CalledBy002:  
 *
 * 
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names
 *
 **/


-- Begin create_Procedure
BEGIN

DECLARE @cnt int,
        @payment real ,
	@abbr varchar(6)



-- get all the terminals from the labelfile
   SELECT labelfile.abbr term_no,
          labelfile.name term_nm,
          @cnt           ld_given,
          @payment       tenperccomm,
          @cnt           ld_taken,
          @payment       tenpercfee,
          @payment       netpymnt
   INTO #temp_tbl
   FROM labelfile
   WHERE labeldefinition = 'RevType1'
   AND   name <> 'UNKNOWN'
   AND   name <> '999' 



-- Create the temp table to load the orders
create table #temp_orders 
(ord_hdrnumber int null,
 ord_rateby varchar(1) null,	
 uid_revtype varchar(8) null,
 drv_id varchar(8) null,
 drv_revtype varchar(8) null,
 inv_total real null)

select @abbr = ''

while ((select count(*) from #temp_tbl where term_no > @abbr) > 0 )
begin

select @abbr = min(term_no) from #temp_tbl where term_no > @abbr

insert into #temp_orders (ord_hdrnumber,ord_rateby,uid_revtype)
  (select o.ord_hdrnumber ,o.ord_rateby,t.usr_type1
 from 	orderheader o,ttsusers t
where  
   o.ord_revtype1 = @abbr and
   o.ord_completiondate >= @start_dt and
   o.ord_completiondate <= @end_dt and
   o.ord_invoicestatus  = 'PPD'	and
   o.ord_bookedby = t.usr_userid)



-- delete orders driven by more than 1 driver 
delete from #temp_orders where
ord_hdrnumber in 
	( select min(l.ord_hdrnumber) 
	from legheader l,assetassignment a,#temp_orders t
	where 	t.ord_hdrnumber = l.ord_hdrnumber and
		a.lgh_number = l.lgh_number and
		a.asgn_type = 'DRV' 
	having count(a.asgn_id) > 1 )
		
	      
-- update the driver id field

update #temp_orders 
set drv_id = ( select min(a.asgn_id)
		from assetassignment a,legheader l
		where 	#temp_orders.ord_hdrnumber = l.ord_hdrnumber and
			l.lgh_number = a.lgh_number and
			a.asgn_type = 'DRV')

-- update drivers revtype1 from manpowerprofile

update #temp_orders
set	drv_revtype = (select m.mpp_type1 from manpowerprofile m 
			where m.mpp_id = #temp_orders.drv_id)


-- invoicedetails

update 	#temp_orders 
set	inv_total = (select 	sum(ivd_charge)
		        from 	invoicedetail
		        where 	invoicedetail.ord_hdrnumber = #temp_orders.ord_hdrnumber 
		        and 	ivd_type = 
			substring('SUBDRP',isnull(4/(sign( charindex ('D',#temp_orders.ord_rateby))),1),
					   isnull(6/(sign( charindex ('D',#temp_orders.ord_rateby))),3)))	
	
-- Update main tableloads taken

update #temp_tbl set ld_taken = 
(select count(*) from #temp_orders where
uid_revtype <> drv_revtype)
where #temp_tbl.term_no = @abbr

update #temp_tbl set tenpercfee = 
(select sum(inv_total) * 0.1 from #temp_orders where 
 uid_revtype <> drv_revtype)
where  #temp_tbl.term_no = @abbr 


-- Update main table loads given

update #temp_tbl set ld_given = 
(select count(*) from #temp_orders where
uid_revtype = drv_revtype)
where #temp_tbl.term_no = @abbr

update #temp_tbl set tenperccomm = 
(select sum(inv_total) * 0.1 from #temp_orders where 
 uid_revtype = drv_revtype)
where  #temp_tbl.term_no = @abbr 

-- Net Payment 
update #temp_tbl set netpymnt = tenperccomm - tenpercfee

delete #temp_orders

end


--eliminate orders with more than 1 driver

SELECT  term_no,
        term_nm,
        ld_given,
        tenperccomm,
        ld_taken,
        tenpercfee,
        Netpymnt
   FROM #temp_tbl  

end
GO
GRANT EXECUTE ON  [dbo].[d_comm_alloc_sp] TO [public]
GO
