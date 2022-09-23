SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [dbo].[d_advance_export_sp_JR] @id_operador varchar(13), @unidad varchar(10)
as 

declare @ls_advancepaytype				varchar(6),
        @ls_100_percent_paytype_list	varchar(200),
		@ls_0_percent_paytype_list		varchar(200),
		@V_Mensajeant					varchar(150),
		@V_ope							varchar(13),
		@V_statusMSG					varchar(13)

declare @rowcount						int,
		@rowcounter						int,
		@rounding_factor				int,
		@maxrow							int

declare @adv_percentage					money,
		@temp_advance					money,
		@V_monto_ant					money

declare @lgh_list table (lgh_ident				int identity(1, 1)	not null,
						 lgh_number				int null,
						 asgn_type				char(3) null,
						 asgn_id				varchar(13) null,
						 total_tolls			money null,
						 total_pay_wo_tolls		money null,
						 total_pay_full_advance	money null,
						 expected_advance		money null,
						 previous_advance		money null)

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

insert into @lgh_list (lgh_number, asgn_type, asgn_id)
select a.lgh_number, a.asgn_type, a.asgn_id
  from assetassignment a
  left outer join paydetail pyd on pyd.asgn_type = a.asgn_type and pyd.asgn_id = pyd.asgn_id and a.lgh_number = pyd.lgh_number
 where a.asgn_status in ('STD', 'CMP')
   and a.actg_type in ('A','P')
   and a.asgn_date < getdate()
   and a.asgn_date  > dateadd(wk, -2, getdate())
   and pyd.pyd_status not in ('REL', 'PND', 'XFR')
   and pyd.asgn_id  not in (select mpp_id from driverdocument where drd_doctype = 'TDDE' and drd_default = 'Y')
   and a.asgn_id = @id_operador
 group by a.lgh_number, a.asgn_type, a.asgn_id

select @rowcount = count(*)
  from @lgh_list

if @rowcount < 1
begin
select @V_statusMSG = 'Ok'
	select NULL as 'status',
	   0 as lgh_number,
	   'NON' as asgn_type,
	   'UNKNOWN' as asgn_id,
	   0.00 as total_tolls,
	   0.00 as total_pay_wo_tolls,
	   0.00 as total_pay_full_advance,
	   0.00 as expected_advance,
	   0.00 as previous_advance,
	   0.00 as 'new_advance11',
	   @V_statusMSG as mensaje

	return
end

update @lgh_list
   set total_tolls = (select sum(th_cash_toll)
                        from toll_history
                       where lgh.lgh_number = toll_history.lgh_number)
  from @lgh_list lgh

update @lgh_list
   set total_pay_wo_tolls = (select sum(pyd_amount)
							   from paydetail
							  where lgh.lgh_number = paydetail.lgh_number 
							    and CHARINDEX(',' + pyt_itemcode + ',', @ls_100_percent_paytype_list) = 0
								and pyt_itemcode not in (select distinct pyt_itemcode
														   from tollbooth
														  where tb_ident > 0)
								and CHARINDEX(',' + pyt_itemcode + ',', @ls_0_percent_paytype_list) = 0
                                and pyt_itemcode <> @ls_advancepaytype)
  from @lgh_list lgh
update @lgh_list
   set total_pay_full_advance = (select sum(pyd_amount)
							       from paydetail
							      where lgh.lgh_number = paydetail.lgh_number 
							        and CHARINDEX(',' + pyt_itemcode + ',', @ls_100_percent_paytype_list) > 0
									and CHARINDEX(',' + pyt_itemcode + ',', @ls_0_percent_paytype_list) = 0
                                    and pyt_itemcode not in (select distinct pyt_itemcode from tollbooth where tb_ident > 0))
  from @lgh_list lgh

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
							    and pyt_itemcode = @ls_advancepaytype)
  from @lgh_list lgh

update @lgh_list
   set previous_advance = 0.00
 where previous_advance is null

delete @lgh_list
where previous_advance >= expected_advance


select @V_statusMSG = 'Ok'

select 0 as 'status',
	   lgh_number,
	   asgn_type,
	   asgn_id,
	   total_tolls,
	   total_pay_wo_tolls,
	   total_pay_full_advance as campo7,
	   expected_advance,
	   previous_advance,
	   (expected_advance - previous_advance) as 'new_advance1',
	   @V_statusMSG
  from @lgh_list

					-- Envia la macro de los anticipos
					--select @rowcount = count(*)   from @lgh_list

				If Exists ( Select count(*) From  @lgh_list )
								Begin--4 si hay anticipos
								-- Se declara un curso para ir leyendo la tabla de paso
									DECLARE Anticipo_Cursor CURSOR FOR 
									SELECT asgn_id, (expected_advance - previous_advance)
									FROM @lgh_list 
								
									OPEN Anticipo_Cursor 
									FETCH NEXT FROM Anticipo_Cursor INTO @V_Ope, @V_monto_ant
									WHILE @@FETCH_STATUS = 0 
										BEGIN --5 del cursor Paradas_Cursor 
											SELECT @V_Ope, @V_monto_ant

 											select @V_Mensajeant = '**Proximo Deposito Monto '+ cast(ISNULL(@V_monto_ant,'')AS VARCHAR (10))+'**, Hrs Depositos: 11 AM, 1:00, 4:00 y 6:00 PM '

											-- Insert el mensaje con la descripcion de la parada.
											INSERT Into QSP..EnviaMensajes (cuenta, unidad, macro, mensaje, detmacro)
											Values(5,@unidad, null, @V_Mensajeant,null )

											FETCH NEXT FROM Anticipo_Cursor INTO  @V_Ope, @V_monto_ant
										END -- 5 del cursor Paradas_Cursor 
					

							CLOSE Anticipo_Cursor 
							DEALLOCATE Anticipo_Cursor 
						END -- 4 curso de los anticipos 
						



GO
