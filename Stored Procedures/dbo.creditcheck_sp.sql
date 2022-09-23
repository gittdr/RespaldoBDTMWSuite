SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/*
DPETE PTS 16978 do not include master order amoutns in the total
*/
-- JTEUB PTS 36171, add new procedure to calculate amounts to be called from within other procedures
-- DPETE 47042 customer wants the former behaviour restored before PTS46027. JET agrees that an added switch would do the old
--   code by default and the new if set.  Add GI setting 'CreditCkAgingSummary' the value to do new processing will be 'ByMaster'
-- 48802 DPETE getting null object error in application when checking credit on a bill to compmany who has no records in the
--    credit check table when using hte "old" credit check method GI <> BYMASTER
-- 64048 use labelfile exclude_from_credit_check for ordInvStatus so custome cna USE XIN to suspend an order from invoicing
--      just for audit and not exclude from credit check
Create procedure [dbo].[creditcheck_sp] (@ps_billto varchar(8), @pl_currordhdrnumber int, @pdec_currordamt money, @crm_enabled as int) as

    DECLARE @cur_ord_status	varchar(6),  
            @cur_ord_amt	money, 
            @can_book		int, 
            @crm_type		varchar(6), 
            @loads_booked	int 

    -- JET - 7/17/09 - PTS46125, for CRM check the crm_type and load count to determine if customer can book order
    set @can_book = 1
    set @loads_booked = 0
    
    DECLARE @lbl_aging1 varchar(20), 
            @lbl_aging2 varchar(20), 
            @lbl_aging3 varchar(20), 
            @lbl_aging4 varchar(20), 
            @lbl_aging5 varchar(20), 
            @lbl_aging6 varchar(20) 

declare @switch varchar(20)

   DECLARE @credit_limit money, 
            @aged_total money, 
            @pending_order_amt money, 
            @pending_invoice_amt money, 
            @unrated_orders int,
            @aging1 money,  
            @aging2 money,  
            @aging3 money,  
            @aging4 money,  
            @aging5 money,  
            @aging6 money 
 DECLARE @mastercompany as varchar(8)

	--PTS 60199 JJF 20120222
	DECLARE @ord_over_credit_limit_approved varchar(1)
	DECLARE @ord_over_credit_limit_approved_by varchar(256)
	--END PTS 60199 JJF 20120222
	
	
 /* 64048  */
 DECLARE @ordInvStatus table (abbr varchar(6))
 INSERT into @OrdInvStatus(abbr) 
 SELECT abbr
 FROM labelfile
 WHERE labeldefinition = 'OrdInvStatus'
 AND Isnull(exclude_from_creditcheck,'N') = 'N'
 AND abbr <> 'UNK'


select @lbl_aging1 = min(name) from labelfile where labeldefinition = 'AgingPeriod1'
	select @lbl_aging2 = min(name) from labelfile where labeldefinition = 'AgingPeriod2'
	select @lbl_aging3 = min(name) from labelfile where labeldefinition = 'AgingPeriod3'
	select @lbl_aging4 = min(name) from labelfile where labeldefinition = 'AgingPeriod4'
	select @lbl_aging5 = min(name) from labelfile where labeldefinition = 'AgingPeriod5'
	select @lbl_aging6 = min(name) from labelfile where labeldefinition = 'AgingPeriod6'

select @pl_currordhdrnumber = IsNull(@pl_currordhdrnumber,0)
    
select @cur_ord_status = ord_status,
		--PTS 60199 JJF 20120222
		@ord_over_credit_limit_approved = ord_over_credit_limit_approved,
		@ord_over_credit_limit_approved_by = ord_over_credit_limit_approved_by
		--END PTS 60199 JJF 20120222
      from orderheader (nolock)
     where ord_hdrnumber = @pl_currordhdrnumber 
       and @pl_currordhdrnumber > 0 
    
IF @pl_currordhdrnumber = 0 
       set @cur_ord_status = 'AVL' 
    
IF @cur_ord_status in (select abbr from labelfile where labeldefinition = 'DISPSTATUS'
       AND IsNull(exclude_from_creditcheck, 'N') = 'Y')
       select @cur_ord_amt = 0
ELSE
       select @cur_ord_amt = @pdec_currordamt
    
  
select @mastercompany = cmp_mastercompany, 
       @crm_type = isnull(cmp_crmtype ,'UNK')
from company  (nolock)
where cmp_id = @ps_billto 
    
if isnull(@mastercompany, 'UNKNOWN') = 'UNKNOWN' 
select @mastercompany = @ps_billto
    
-- JET - 7/17/09 - PTS46125, for CRM check the crm_type and load count to determine if customer can
--		book this load (based on crm type, and number orders previously booked)

if @crm_enabled = 1
    begin
        set @can_book = 0
        if @crm_type = 'ACT' or @crm_type = 'PNDCDT' or @crm_type = 'NEW'
            set @can_book = 1
        
        if @crm_type = 'PNDCDT'
		begin
			-- check to make sure other orders have not been booked for this customer
            select @loads_booked = count(ord_hdrnumber) 
              from orderheader (nolock)
             where ord_billto = @ps_billto 
               and ord_status not in ('MST', 'QTE') 
               and ord_hdrnumber <> @pl_currordhdrnumber 
			
			-- if the order has not been saved yet, need it to be included in the count
			if @pl_currordhdrnumber > 0 
				set @loads_booked = @loads_booked + 1
		end
    end
    


select @switch = upper(gi_string1) from generalinfo where gi_name = 'CreditCkAgingSummary'


If @switch = 'BYMASTER'
  BEGIN

    
	exec creditcheck_calc_sp @ps_billto, @pl_currordhdrnumber, @credit_limit OUTPUT, @aged_total OUTPUT, 
                             @pending_order_amt OUTPUT, @pending_invoice_amt OUTPUT, @unrated_orders OUTPUT, 
                             @aging1 OUTPUT, @aging2 OUTPUT, @aging3 OUTPUT, 
                             @aging4 OUTPUT, @aging5 OUTPUT, @aging6 OUTPUT 

	Select a.cmp_id,
           a.cmp_name,
           IsNull(a.cmp_altid,a.cmp_id) cmp_acctid,
           a.cmp_primaryphone,
           a.cmp_contact,
           a.cmp_currency,
           a.cmp_creditavail_update, 
           --JET PTS 36171 use values returned by call to creditcheck_calc_sp
           -- IsNull(a.cmp_creditlimit, 0) cmp_creditlimit,
           @credit_limit cmp_creditlimit,
           IsNull(@aging1, 0) cmp_aging1,
           IsNull(@aging2, 0) cmp_aging2,
           IsNull(@aging3, 0) cmp_aging3,
           IsNull(@aging4, 0) cmp_aging4,
           IsNull(@aging5, 0) cmp_aging5,
           IsNull(@aging6, 0) cmp_aging6,

           CAST(@pending_order_amt AS FLOAT) pending_order_amt, -- this needs to be a temporary fix (no currency should be returned as float)
           @pending_invoice_amt pending_invoice_amt, 
           
           --DPH PTS 20640 added exclude_from_creditcheck clause
           @lbl_aging1 label_aging1, 
           @lbl_aging2 label_aging2, 
           @lbl_aging3 label_aging3, 
           @lbl_aging4 label_aging4, 
           @lbl_aging5 label_aging5, 
           @lbl_aging6 label_aging6, 
           @unrated_orders unrated_orders, 
           @cur_ord_amt current_order_amt, 
           @crm_enabled crm_enabled, 
           @can_book can_book, 
           @crm_type crm_type, 
           @loads_booked loads_booked 
      from company a (nolock) left outer join creditcheck b (nolock) on a.cmp_id = b.cmp_id
      where a.cmp_id = @mastercompany 
       and a.cmp_id <> 'UNKNOWN' -- @ps_billto 	
 
  END
else
  BEGIN -- original behavior
	SELECT 	@cur_ord_status = ord_status,
			--PTS 60199 JJF 20120222
			@ord_over_credit_limit_approved = ord_over_credit_limit_approved,
			@ord_over_credit_limit_approved_by = ord_over_credit_limit_approved_by
			--END PTS 60199 JJF 20120222
	FROM	orderheader (nolock)
	WHERE	ord_hdrnumber = @pl_currordhdrnumber

	IF (@cur_ord_status in (select abbr from labelfile where labeldefinition = 'DISPSTATUS'
				and IsNull(exclude_from_creditcheck, 'N') = 'Y'))
		select @cur_ord_amt = 0
	ELSE
		select @cur_ord_amt = @pdec_currordamt
	 	

	select @pl_currordhdrnumber = IsNull(@pl_currordhdrnumber,0)
	Select 	a.cmp_id,
		a.cmp_name,
		IsNull(a.cmp_altid,a.cmp_id) cmp_acctid,
		a.cmp_primaryphone,
		a.cmp_contact,
		a.cmp_currency,
		a.cmp_creditavail_update,
		a.cmp_creditlimit,
		isnull(b.cmp_aging1,0) cmp_aging1,
		isnull(b.cmp_aging2,0) cmp_aging2,
		isnull(b.cmp_aging3,0) cmp_aging3,
		isnull(b.cmp_aging4,0) cmp_aging4,
		isnull(b.cmp_aging5,0) cmp_aging5,
		isnull(b.cmp_aging6,0) cmp_aging6,

		--DPH PTS 20640 added exclude_from_creditcheck clause
		isnull((Select sum(ord_totalcharge) 
         from    orderheader WITH (NOLOCK) 
         join @ordInvStatus istatus on orderheader.ord_invoicestatus = istatus.abbr -- 64048
			where 	ord_billto = @ps_billto and
					-- 64048 ord_invoicestatus in ('AVL','PND') and
					ord_hdrnumber <> @pl_currordhdrnumber and ord_status in 
						(select abbr from labelfile where labeldefinition = 'DispStatus' and
						 Isnull(exclude_from_creditcheck,'N') = 'N')),0) pending_order_amt,

		isnull((Select sum(ivh_totalcharge) 
			from 	invoiceheader  WITH (NOLOCK) 
			where 	ivh_billto = @ps_billto and
					ivh_invoicestatus in 
					(select abbr from labelfile where labeldefinition = 'InvoiceStatus' and
					 IsNull(exclude_from_creditcheck, 'N') = 'N')),0) pending_invoice_amt,
		--DPH PTS 20640 added exclude_from_creditcheck clause
		@lbl_aging1 label_aging1,
		@lbl_aging2 label_aging2,
		@lbl_aging3 label_aging3,
		@lbl_aging4 label_aging4,
		@lbl_aging5 label_aging5,
		@lbl_aging6 label_aging6,
		(Select count(*) 
                   from orderheader WITH (NOLOCK) 
                  where ord_billto = @ps_billto and	
                        IsNull(ord_totalcharge,0)= 0 and
                        ord_status in (SELECT abbr
                                         FROM labelfile (nolock)
                                        WHERE labeldefinition = 'DispStatus' AND
                                              code BETWEEN 210 AND 400)) unrated_orders,		
		@cur_ord_amt current_order_amt	, 
           @crm_enabled crm_enabled, 
           @can_book can_book, 
           @crm_type crm_type, 
           @loads_booked loads_booked,
		--PTS 60199 JJF 20120222
		@ord_over_credit_limit_approved,
		@ord_over_credit_limit_approved_by
		--END PTS 60199 JJF 20120222

    From company a (nolock)
    left outer join creditcheck b (nolock) on a.cmp_id = b.cmp_id
    where a.cmp_id =  @ps_billto
/*
	From	company a, creditcheck b
	Where   a.cmp_id = @ps_billto and
			a.cmp_id = b.cmp_id
*/
  END  -- original behavior


GO
GRANT EXECUTE ON  [dbo].[creditcheck_sp] TO [public]
GO
