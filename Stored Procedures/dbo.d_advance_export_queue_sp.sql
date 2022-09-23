SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/** 02/Agosto/2013**/
/** JR se agrego la linea and asgn_controlling = 'Y' para que se generara solo anticipos a operadores principales **/
/**26/Mayo/2016**/
/** Se agrego la linea and pyd.asgn_id  not in (select mpp_id from driverdocument where drd_doctype = 'TDDE' and drd_default = 'Y')
 esto para excluir los operadores que ya tengan tarjeta de viaticos atte JR**/
--exec d_advance_export_queue_sp
CREATE procedure [dbo].[d_advance_export_queue_sp]
as 

declare @ls_advancepaytype				varchar(6),
        @ls_100_percent_paytype_list	varchar(200),
		@ls_0_percent_paytype_list		varchar(200)

declare @rowcount						int,
		@rowcounter						int,
		@rounding_factor				int,
		@maxrow							int

declare @adv_percentage					money,
		@temp_advance					money

declare @lgh_list table (lgh_ident				int identity(1, 1)	not null,
						 lgh_number				int null,
						 ord_hdrnumber			int null,
						 asgn_type				char(3) null,
						 asgn_id				varchar(13) null,
						 total_tolls			money null,
						 total_pay_wo_tolls		money null,
						 total_pay_full_advance	money null,
						 expected_advance		money null,
						 previous_advance		money null,
						 Ope_principal			Char(1))

--get the paytypes to exclude from the precentage calculations and the advance paytype
select @ls_100_percent_paytype_list = isnull(gi_string1, ''),
       @ls_advancepaytype = isnull(gi_string2, ''),
	   @ls_0_percent_paytype_list = isnull(gi_string3, ''),
       @adv_percentage = gi_integer1 * .01,
       @rounding_factor = gi_integer2	   
  from generalinfo
 where gi_name = 'BankExportConfigSettings'
select @ls_100_percent_paytype_list = ',' + @ls_100_percent_paytype_list + ','
select @ls_0_percent_paytype_list = ',' + @ls_0_percent_paytype_list + ','

--debug
--select @adv_percentage,@rounding_factor

insert into @lgh_list (lgh_number, asgn_type, asgn_id, ord_hdrnumber, Ope_principal)
select a.lgh_number, a.asgn_type, a.asgn_id, pyd.ord_hdrnumber, a.asgn_controlling
  from assetassignment a
  left outer join paydetail pyd on pyd.asgn_type = a.asgn_type and pyd.asgn_id = pyd.asgn_id and a.lgh_number = pyd.lgh_number
 where a.asgn_status in ('STD') --'CMP'
	--and asgn_controlling = 'Y'
   and a.actg_type in ('A','P')
   and a.asgn_date < getdate()+1
   and a.asgn_date  > dateadd(wk, -2, getdate())
   and pyd.pyd_status not in ('REL', 'PND', 'XFR')
   and pyd.asgn_id  not in (select mpp_id from driverdocument where drd_doctype = 'TDDE' and drd_default = 'Y')
 --  UNION
 --  select a.lgh_number, a.asgn_type, a.asgn_id, pyd.ord_hdrnumber, a.asgn_controlling
 -- from assetassignment a
 -- left outer join paydetail pyd on pyd.asgn_type = a.asgn_type and pyd.asgn_id = pyd.asgn_id and a.lgh_number = pyd.lgh_number
 --where a.asgn_status in ('PLN','DSP') --'CMP'
	----and asgn_controlling = 'Y'
 --  and a.actg_type in ('A','P')
 --  and a.asgn_date < getdate()+5
 --  and a.asgn_date  > dateadd(wk, -2, getdate())
 --  and pyd.pyd_status not in ('REL', 'PND', 'XFR')
 group by a.lgh_number, a.asgn_type, a.asgn_id, pyd.ord_hdrnumber,a.asgn_controlling

select @rowcount = count(*)
  from @lgh_list

if @rowcount < 1
begin
	select NULL as 'status',
	   0 as lgh_number,
	   'NON' as asgn_type,
	   'UNKNOWN' as asgn_id,
	   0.00 as total_tolls,
	   0.00 as total_pay_wo_tolls,
	   0.00 as expected_advance,
	   0.00 as previous_advance,
	   0.00 as 'new_advance',
		0 as ord_hdrnumber
	return
end
/* now that we can be creating bogus paydetails for card tolls we need to do this differently
update @lgh_list
   set total_tolls = (select sum(pyd_amount)
					   from paydetail p
					   join @lgh_list l on l.lgh_number = p.lgh_number and l.asgn_type = p.asgn_type and l.asgn_id = p.asgn_id
					  where p.pyt_itemcode in (select distinct pyt_itemcode
                                                 from tollbooth))
*/
	update @lgh_list
	   set total_tolls = (select sum(th_cash_toll)
							from toll_history
						   where lgh.lgh_number = toll_history.lgh_number)
	  from @lgh_list lgh where lgh.Ope_principal = 'Y'


/*JR
update @lgh_list
   set total_pay_wo_tolls = (select sum(pyd_amount)
							   from paydetail
							  where lgh.lgh_number = paydetail.lgh_number 
							    and CHARINDEX(',' + pyt_itemcode + ',', @ls_100_percent_paytype_list) = 0
								and pyt_itemcode not in ('CASIAV')
--(select distinct pyt_itemcode from tollbooth where tb_ident > 0)
								and CHARINDEX(',' + pyt_itemcode + ',', @ls_0_percent_paytype_list) = 0
                                and pyt_itemcode <> @ls_advancepaytype)
  from @lgh_list lgh
JR*/

	update @lgh_list
	   set total_pay_wo_tolls = (select sum(pyd_amount)
								   from paydetail
								  where lgh.lgh_number = paydetail.lgh_number and 
										lgh.asgn_id = paydetail.asgn_id
									and CHARINDEX(',' + pyt_itemcode + ',', @ls_100_percent_paytype_list) = 0
									and pyt_itemcode not in (select distinct pyt_itemcode
															   from tollbooth
															  where tb_ident > 0)
									and CHARINDEX(',' + pyt_itemcode + ',', @ls_0_percent_paytype_list) = 0
									and pyt_itemcode <> @ls_advancepaytype)
	  from @lgh_list lgh --where lgh.asgn_id = paydetail.asgn_id

/*
--need to remove the tolls from the pay to be advanced since they are already seperated out
update @lgh_list
   set total_pay_wo_tolls = total_pay_wo_tolls - (select sum(th_card_toll)
                                                    from toll_history
                                                   where lgh.lgh_number = toll_history.lgh_number)
  from @lgh_list lgh
select total_pay_wo_tolls from @lgh_list
--now that we can be creating bogus paydetails for card tolls we need to subtract out the total card pay
if left((select gi_string1 from generalinfo where gi_name = 'TollsFuelPay'),1) = 'Y'
begin
	update @lgh_list
       set total_pay_wo_tolls = total_pay_wo_tolls - (select sum(th_card_toll)
                                                        from toll_history
                                                       where lgh.lgh_number = toll_history.lgh_number)
      from @lgh_list lgh
end
--end of changes for bogus pay
*/
/*JR
update @lgh_list
   set total_pay_full_advance = (select sum(pyd_amount)
							       from paydetail
							      where lgh.lgh_number = paydetail.lgh_number 
							        and CHARINDEX(',' + pyt_itemcode + ',', @ls_100_percent_paytype_list) > 0
									and CHARINDEX(',' + pyt_itemcode + ',', @ls_0_percent_paytype_list) = 0
                                    and pyt_itemcode not in ('CASIAV')
									--(select distinct pyt_itemcode from tollbooth where tb_ident > 0)
)
  from @lgh_list lgh
JR*/
update @lgh_list
   set total_pay_full_advance = (select sum(pyd_amount)
							       from paydetail
							      where lgh.lgh_number = paydetail.lgh_number 
				and 	lgh.asgn_id = paydetail.asgn_id
							        and CHARINDEX(',' + pyt_itemcode + ',', @ls_100_percent_paytype_list) > 0
									and CHARINDEX(',' + pyt_itemcode + ',', @ls_0_percent_paytype_list) = 0
                                    and pyt_itemcode not in (select distinct pyt_itemcode from tollbooth where tb_ident > 0))
  from @lgh_list lgh
print @ls_100_percent_paytype_list
print @ls_0_percent_paytype_list

update @lgh_list
   set total_pay_full_advance = 0.00
 where total_pay_full_advance is null

update @lgh_list
   set total_tolls = 0.00
 where total_tolls is null

update @lgh_list
   set total_pay_wo_tolls = 0.00
 where total_pay_wo_tolls is null

select @rowcounter = 1
select @maxrow = count(*)
  from @lgh_list
while @rowcounter <= @maxrow
begin
	select @temp_advance = convert(int,(@adv_percentage * total_pay_wo_tolls) + total_tolls + total_pay_full_advance)
      from @lgh_list
     where lgh_ident = @rowcounter

	if (convert(int,@temp_advance*100)/100) % @rounding_factor > 0
	begin
		select @temp_advance = convert(int,@temp_advance + (@rounding_factor - ((convert(int,@temp_advance*100)/100) % @rounding_factor)))
	end

	update @lgh_list
	   set expected_advance = @temp_advance
     where lgh_ident = @rowcounter

	select @rowcounter = @rowcounter + 1
end

update @lgh_list
   set previous_advance = (select abs(sum(pyd_amount))
						    from paydetail
							  where lgh.lgh_number = paydetail.lgh_number 
				and 	lgh.asgn_id = paydetail.asgn_id
							    and pyt_itemcode = @ls_advancepaytype)
  from @lgh_list lgh

update @lgh_list
   set previous_advance = 0.00
 where previous_advance is null

delete @lgh_list
where previous_advance >= expected_advance

select 0 as 'status',
	   lgh_number,
	   asgn_type,
	   asgn_id,
	   total_tolls,
	   total_pay_wo_tolls,
	   total_pay_full_advance,
	   expected_advance,
	   previous_advance,
	   expected_advance - previous_advance as 'new_advance',
	   ord_hdrnumber
  from @lgh_list









GO
GRANT EXECUTE ON  [dbo].[d_advance_export_queue_sp] TO [public]
GO
