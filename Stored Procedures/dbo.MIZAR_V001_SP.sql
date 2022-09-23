SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[MIZAR_V001_SP] (
	@pl_ord_hdrnumber int , -- the current order being settled 
	@pl_lgh_number int, -- the current trip segment being settled
	@pl_isprimary int, -- 0 or 1, 1 indicates that the revenue is being requested for linehaul settlement rate
	@ps_asgn_type varchar(6), -- indicates the type of asset, you can put conditional logic to determine rates based on this type
	@ps_asgn_id varchar(13), -- indicates the id of the asset
	@ps_paytype varchar(6), -- the paytype that the application found on the calculated revenue rate
	@pl_tarnum int, -- the tariff number on the rate being used
	@pl_disallowzeropaydetail int out, -- If you set this to 1 and the calc revenue is zero the app will not create a zero paydetail.
	@ps_returnmsg varchar(255) out, -- You should return a message to the application to indicate why the custom calculation failed.
	@pdec_calcrevenue money out, -- return the calculated revenue here. Populate this with -1 if the calculation fails
	@ps_loadstate varchar(3) OUT, -- Return the Load Status
	@pdc_rate decimal OUT -- Return the Rate	
					)
as 
/**
 *
 * COMMENTS:
	'MIZAR'		Mizar Motors, coded by Shampra Marshall PTS 37252 05/25/2007
	08/27/2008 PTS 43641 JSwindell:	proc not returning values.
	09/16/20089 PTS 43641 JSwindell: proc now returns more columns - needs to reflect this here.
**/

select @pdec_calcrevenue = -1
select @ps_returnmsg = 'No custom revenue method is currently supported.Custom calculated revenue methods are added based on customer requested billable Service Requests.'

-- BEGIN MIZAR 
     Begin
      -- PTS 37252 SLM 5/25/2007
	  -- If the Tariff Rate being used is not listed in gi_string1 then calculate it's revenue 
	  -- and calculate the revenue using the Tariff rate from the GI setting. Return the larger revenue.
	  -- If the Tariff Rate being used is the same as the General Info setting, then return the Revenue from Invoice LineHaul.
	  declare @tar_number         int
	  declare @ivd_quantity       int
	  declare @ivd_charge         money
	  declare @alt_ivd_charge     money
      declare @destcity           int
      declare @origincity         int
	  declare @tar_rate           money
	  declare @ivd_rateunit       varchar(6)
	  declare @ivd_unit	          varchar(6)
	  declare @conv_unit	      float
	  declare @last_invoice       int,
	  @tariff_list varchar(250), -- PTS 38880 
	  @ls_source   varchar(250), -- PTS 38880 
      @tariff      int,	         -- PTS 38880 
	  @ll_pos      int           -- PTS 38880 
	
      -- PTS 38880 Get the rate based upon multiple Tariff tables
	  Select @tariff_list = gi_string2 from generalinfo where gi_name ='CalculatedRevenueMethod'
      If Len(@tariff_list) > 0
	  BEGIN
			-- Create a temporary table of all possible Tariffs to choose from
			Set @ls_source = LTrim(@tariff_list)
			Set @ll_pos = CHARINDEX(',', @ls_source)

			create table #temp_tariff(tarindex int identity(1,1), tar_number int)
			Select @pdec_calcrevenue = 0.00
			WHILE @ll_pos > 0 
			Begin
				Set @tariff = Convert(int,LTrim(Left(@ls_source, @ll_pos - 1)))
				IF Len(@tariff)>0 
				begin
					insert #temp_tariff Values (@tariff)

                   -- If this tarriff was used then get the Revenue
				   If EXISTS (select * from invoicedetail 
					  where ord_hdrnumber = @pl_ord_hdrnumber and tar_number = @tariff)

					-- There could be Invoice, and/Credit Memo /or Rebill
					select @pdec_calcrevenue = sum(Isnull(ivh_charge,0.00)) 
						from invoiceheader where ord_hdrnumber = @pl_ord_hdrnumber
				End

				Set @ls_source = LTrim(Substring(@ls_source,@ll_pos + 1, Len(@ls_source)))
				Set @ll_pos = CHARINDEX(',', @ls_source)	
			End

			-- Get the last Tariff
			Set @tariff = convert(int,lTrim(@ls_source))
			IF Len(@tariff)>0 insert #temp_tariff Values (@tariff)

			--Commented out for 38880
			--select @tar_number = gi_integer1 from generalinfo where gi_name ='CalculatedRevenueMethod'
			--Commented out for 38880
			--  If (isnumeric(@tar_number)) = 1
			--  Begin	
			   -- Get the Revenue from Invoice LineHaul.
				--Commented out for 38880
--				   If EXISTS (select * from invoicedetail 
--					  where ord_hdrnumber = @pl_ord_hdrnumber and tar_number = @tar_number)
--
--						-- There could be Invoice, and/Credit Memo /or Rebill
--					select @pdec_calcrevenue = sum(ivh_charge) 
--						from invoiceheader where ord_hdrnumber = @pl_ord_hdrnumber
--
--				   Else
				-- 38880 If the revenue on the Invoice detail did not use one of the tariffs 
				-- in the GI setting then calculate revenue and return the larger revenue

				-- PTS 43641:  REMOVE this IF-Begin/End condition PER LUELLA  8-22-2008 
				--If @pdec_calcrevenue = 0.00
					-- Calculate revenue and compare it with the GI setting
					--Begin

						select @last_invoice =(select max(ivh_hdrnumber) from 
							 invoiceheader where ord_hdrnumber = @pl_ord_hdrnumber)
	 
						 select @destcity     = h.ivh_destcity, 
								@origincity   = h.ivh_origincity,
								@ivd_quantity = h.ivh_totalweight --38880 SLM Get totalweight instead of quantity
						 from invoiceheader h 
						 where h.ivh_hdrnumber = @last_invoice

						select 			
							  @ivd_charge         = d.ivd_charge,
							  --@ivd_quantity       = d.ivd_quantity, //38880 SLM This value should be the weight that's on the order (ivh_totalweight)
							  @ivd_unit           = d.ivd_unit,
							  @ivd_rateunit       = d.ivd_rateunit
	       					from invoicedetail d 
						where ivh_hdrnumber = @last_invoice and d.ivd_type = 'SUB'
			
						 -- 09/16/20089 PTS 43641 JSwindell added 3 tra_* columns because the proc: d_tar_gettariffrate_sp now returns MORE columns.
						 -- Calculate the comparison charge using the alternate rate
	        			 create table #temp_rate(
						  tra_rate       money null,
						  trc_number_row int null,
						  trc_number_col int null,
						  rowseq         int null,
						  colseq         int null,
						  rowval         money null, 
						  colval         money null, 
						  valid_count    int null,
						  tra_rateasflat char(1) null,
						  tra_minqty char(1) null, 
						  tra_minrate money null)

						--38880 Loop through all the Tariffs from the GI setting to find a match
						Declare @min_tarindex int, @lasttarindex int
                        Set @tar_number = 0
                        Set @min_tarindex = 0
						Set @alt_ivd_charge = 0
						Set @lasttarindex = 0

	-- PTS 43641:  The "while 1 = 1" code fails.  replace this with loopcounter. <<start>>
	declare @number_of_tariffs int
	declare @loopcounter int
	set @number_of_tariffs = ( select count(*) from #temp_tariff ) 
	IF @number_of_tariffs > 0 
		begin
			set @loopcounter = 1
		end
	-- PTS 43641: <<end>>

						--While 1=1									-- PTS 43641:  The "while 1 = 1" code fails.  replaced with loopcounter.
						While @loopcounter <= @number_of_tariffs	-- PTS 43641:

						Begin
							select @min_tarindex = min(tarindex) from #temp_tariff where tarindex > @lasttarindex
							select @tar_number = tar_number
								from #temp_tariff 
								where tarindex = @min_tarindex 

							If @tar_number is null Break

							 Insert #temp_rate 
							 Execute d_tar_gettariffrate_sp
 		         				@TarNum        = @tar_number, 
		         				@RowMatchValue = @destcity,
		         				@RowRangeValue = 0, 
		         				@ColMatchValue = @origincity,
		         				@ColRangeValue = 0, 
		         				@dimensions    = 0, 
		         				@order_first_stop_arrivaldate = ''

							select @tar_rate = min(tra_rate) from #temp_rate -- In case of multiple returned rows
							If @tar_rate > 0 
							Begin
								 Select @conv_unit = unc_factor
								 From unitconversion u
								 Where u.unc_from   = @ivd_unit
								 and u.unc_to       = @ivd_rateunit
								 and u.unc_convflag = 'R'

								-- 38880 Commented out
								--Select @alt_ivd_charge = @ivd_quantity * @tar_rate * @conv_unit
								Select @alt_ivd_charge = @ivd_quantity * @tar_rate * .01

								Break -- Rate was found
							End

							Set @lasttarindex = @min_tarindex
							SET @loopcounter = @loopcounter + 1		-- PTS 43641: Added loopcounter.
						End


--						 Select @conv_unit = unc_factor
--						 From unitconversion u
--						 Where u.unc_from   = @ivd_unit
--						 and u.unc_to       = @ivd_rateunit
--						 and u.unc_convflag = 'R'
--
--						-- 38880 Commented out
--						 --Select @alt_ivd_charge = @ivd_quantity * @tar_rate * @conv_unit
--						 Select @alt_ivd_charge = @ivd_quantity * @tar_rate * .01

						 If @ivd_charge > @alt_ivd_charge
							  Select @pdec_calcrevenue = @ivd_charge
						 Else
							  Select @pdec_calcrevenue = @alt_ivd_charge

					-- PTS 43641:  REMOVE this IF-Begin/End condition PER LUELLA  8-22-2008 
					--End --End for Calculate revenue and compare it with the GI setting

			  --End
	    END -- End for Len(tariff_list) > 0
     End
-- END MIZAR MOTORS



GO
GRANT EXECUTE ON  [dbo].[MIZAR_V001_SP] TO [public]
GO
