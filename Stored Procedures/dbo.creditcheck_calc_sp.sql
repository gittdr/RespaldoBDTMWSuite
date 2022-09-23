SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- JTEUB PTS 36171, add new procedure to do the calculations and return values as output variables.  
--		This is so this can be called from within another procedure

Create procedure [dbo].[creditcheck_calc_sp] (@ps_billto varchar(8),@pl_currordhdrnumber int, @credit_limit money OUTPUT, @aged_total money OUTPUT, 
                                      @pending_order_amt money OUTPUT, @pending_invoice_amt money OUTPUT, @unrated_orders int OUTPUT, 
                                      @aging1 money OUTPUT, @aging2 money OUTPUT, @aging3 money OUTPUT, 
                                      @aging4 money OUTPUT, @aging5 money OUTPUT, @aging6 money OUTPUT) as
    /*
     PTS 64048 use exclude_from_credit_check for OrdInvStatus                               
  */
 
  DECLARE @ordInvStatus table (abbr varchar(6))
  INSERT into @OrdInvStatus(abbr) 
  SELECT abbr
  FROM labelfile
  WHERE labeldefinition = 'OrdInvStatus'
  AND Isnull(exclude_from_creditcheck,'N') = 'N'
  AND abbr <> 'UNK'

  
	-- do not run if a billto was not provided
	if isnull(@ps_billto, 'UNKNOWN') = 'UNKNOWN' 
		RETURN
	-- null ord_hdrnumber = 0
	select @pl_currordhdrnumber = IsNull(@pl_currordhdrnumber, 0)
	
	-- locate the master/parent company id
	DECLARE	@mastercompany	varchar(8) 
    select @mastercompany = isnull(cmp_mastercompany, 'UNKNOWN')  
      from company 
     where cmp_id = @ps_billto 
	-- lookup accounting for the parent, not the child
	if @mastercompany <> 'UNKNOWN'
       select @ps_billto = @mastercompany

	-- build list including the parent and  companies the are children of the parent
	CREATE TABLE #temp 
         (cmp_id varchar(8))
	INSERT INTO #temp (cmp_id)
           SELECT cmp_id 
             FROM company WITH (NOLOCK) 
            WHERE cmp_mastercompany = @ps_billto --@mastercompany
	INSERT INTO #temp (cmp_id) 
           SELECT cmp_id 
             FROM company WITH (NOLOCK) 
            WHERE cmp_id = @ps_billto -- @mastercompany 

	-- gather totals for unbilled orders that have a status that is marked to include in credit check
	select @pending_order_amt = IsNull(sum(orderheader.ord_totalcharge), 0) 
      from orderheader WITH (NOLOCK) join #temp on (orderheader.ord_billto = #temp.cmp_id) 
      join @ordInvStatus Istatus on orderheader.ord_invoicestatus = Istatus.abbr  /* 64048 use label file status with flags */
     where --orderheader.ord_invoicestatus in ('AVL','PND') 64048
	   orderheader.ord_hdrnumber <> @pl_currordhdrnumber 
	   and orderheader.ord_status in (select abbr 
	                                    from labelfile 
	                                   where labeldefinition = 'DispStatus' 
	                                     and Isnull(exclude_from_creditcheck,'N') = 'N') 
	
	-- gather total for invoices that have been computed but not printer/transfered
	select @pending_invoice_amt = IsNull(sum(invoiceheader.ivh_totalcharge), 0) 
      from invoiceheader with (NOLOCK) join #temp on (invoiceheader.ivh_billto = #temp.cmp_id)
     where invoiceheader.ivh_invoicestatus in (select abbr 
	                                             from labelfile 
	                                            where labeldefinition = 'InvoiceStatus' 
	                                              and IsNull(exclude_from_creditcheck, 'N') = 'N') 
	
	-- count unrated orders for all the bill to companies 
	select @unrated_orders = count(orderheader.ord_hdrnumber) 
	  from orderheader WITH (NOLOCK) join #temp on (orderheader.ord_billto = #temp.cmp_id) 
	  join @ordInvStatus Istatus on orderheader.ord_invoicestatus = Istatus.abbr  /* 64048 use label file status with flags */
	 where IsNull(ord_totalcharge, 0)= 0 
	  /* 64048 use label file 
	  and orderheader.ord_invoicestatus in ('AVL','PND')  --44502 pmill only count orders that have not been invoiced
	  */
	
	-- store the total credit limit for all the bill to companies
	select @credit_limit = IsNull(sum(company.cmp_creditlimit), 0) 
      from company WITH (NOLOCK) join #temp on (company.cmp_id = #temp.cmp_id) 
	
	-- sum the aging bucket data for all the bill to companies
	select @aging1 = IsNull(sum(creditcheck.cmp_aging1), 0), 
	       @aging2 = IsNull(sum(creditcheck.cmp_aging2), 0), 
	       @aging3 = IsNull(sum(creditcheck.cmp_aging3), 0), 
	       @aging4 = isNull(sum(creditcheck.cmp_aging4), 0), 
	       @aging5 = IsNull(sum(creditcheck.cmp_aging5), 0), 
	       @aging6 = IsNull(sum(creditcheck.cmp_aging6), 0) 
      from creditcheck WITH (NOLOCK) join #temp on (creditcheck.cmp_id = #temp.cmp_id) 
		-- total all the aging amounts
	select @aged_total = (@aging1 + @aging2 + @aging3 + @aging4 + @aging5 + @aging6)
GO
GRANT EXECUTE ON  [dbo].[creditcheck_calc_sp] TO [public]
GO
