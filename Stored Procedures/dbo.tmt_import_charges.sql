SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[tmt_import_charges]
@tmt_order_id int, @tmt_inv_order_num varchar (12), @tmt_change_date datetime, @drv_id varchar (12), @trc_number varchar (13), @amount money, @tmt_shopid varchar (12), @tmt_description varchar (30), @tmt_rep_reason varchar (12)
as
declare @asgn_type as varchar (6);
declare @asgn_id as varchar (13);
declare @std_item_escrow as varchar (13), 
@std_item_advance as varchar (13), 
@default_advance as varchar (13),
@std_number_escrow as int, 
@std_number_advance as int, 
@actg_type as char (1), 
@trc_type1 as varchar (6), 
@min_charge as money, 
@temp as varchar (2000), 
@results as varchar (100), 
@pty_shop_charge as varchar (6), 
@ignore_cld_escrow as char (1), 
@pyd_number as int, 
@ref_shopid as varchar (6), 
@ref_InvOrdNum as varchar (6), 
@ref_repreason as varchar (6), 
@ref_orderid as varchar (6), 
@remain as money, 
@escrow_amount as money, 
@advance_amount as money, 
@pyd_number_escrow as int, 
@pyd_number_advance as int, 
@std_number as int, 
@sd_error as varchar (100), 
@std_balance as money, 
@pyt_advance as varchar (12), @error_flag as char (1),
@pty_trc varchar (12)
set nocount on;
-- Load settings. 
select @pty_shop_charge = gi_string1,
       @ignore_cld_escrow = left(gi_string2, 1),
       @pyt_advance = gi_string3, 
       @default_advance = gi_string4, @error_flag = 'N' 
from   generalinfo
where  gi_name = 'TMTImport';
if @pty_shop_charge is null
    begin
        execute dbo.AddTMTLogEntry_sp 'Y', 'No shop charge pay type set up. No pay created.', @results, @pyd_number, @pyd_number_escrow, @pyd_number_advance, @escrow_amount, @advance_amount, @tmt_order_id, @tmt_inv_order_num, @tmt_change_date, @drv_id, @trc_number, @amount, @tmt_shopid, @tmt_description, @tmt_rep_reason;
        return;
    end
if @pyt_advance is null
    begin
        execute dbo.AddTMTLogEntry_sp 'Y', 'No advance pay type. No pay created.', @results, @pyd_number, @pyd_number_escrow, @pyd_number_advance, @escrow_amount, @advance_amount, @tmt_order_id, @tmt_inv_order_num, @tmt_change_date, @drv_id, @trc_number, @amount, @tmt_shopid, @tmt_description, @tmt_rep_reason;
        return;
    end
if @ignore_cld_escrow is null
    select @ignore_cld_escrow = 'N';
select @ref_shopid = gi_string1,
       @ref_InvOrdNum = gi_string2,
       @ref_repreason = gi_string3,
       @ref_orderid = gi_string4
from   generalinfo
where  gi_name = 'TMTImportRefNum';
if LTRIM(@ref_shopid) = ''
    select @ref_shopid = null;
if LTRIM(@ref_invordnum) = ''
    select @ref_InvOrdNum = null;
if LTRIM(@ref_repreason) = ''
    select @ref_repreason = null;
if LTRIM(@ref_orderid) = ''
    select @ref_orderid = null;
-- Check to see that owner / tractor are valid.
select @temp = pto_id
from   payto
where  pto_id = @drv_id;
if @temp is null
    begin
        select @temp = ISNULL(@drv_id, '<NULL>') + ' is not a valid payto.';
        execute dbo.AddTMTLogEntry_sp 'Y', @temp, @results, @pyd_number, @pyd_number_escrow, @pyd_number_advance, @escrow_amount, @advance_amount, @tmt_order_id, @tmt_inv_order_num, @tmt_change_date, @drv_id, @trc_number, @amount, @tmt_shopid, @tmt_description, @tmt_rep_reason;
        return;
    end
select @temp = trc_number, @pty_trc = trc_owner
from   tractorprofile
where  trc_number = @trc_number;
if @temp is null
    begin
        select @temp = ISNULL(@trc_number, '<NULL>') + ' is not a valid tractor.';
        execute dbo.AddTMTLogEntry_sp 'Y', @temp, @results, @pyd_number, @pyd_number_escrow, @pyd_number_advance, @escrow_amount, @advance_amount, @tmt_order_id, @tmt_inv_order_num, @tmt_change_date, @drv_id, @trc_number, @amount, @tmt_shopid, @tmt_description, @tmt_rep_reason;
        return;
    end
-- Verify that the tractor's payto is the owner
IF @drv_id <> @pty_trc 
	BEGIN
  select @temp = @trc_number + '''s pay to is ' + ISNULL (@pty_trc, '<NULL>') + ' but we were passed an owner of ' + ISNULL (@drv_id, '');
  execute dbo.AddTMTLogEntry_sp 'Y', @temp, @results, @pyd_number, @pyd_number_escrow, @pyd_number_advance, @escrow_amount, @advance_amount, @tmt_order_id, @tmt_inv_order_num, @tmt_change_date, @drv_id, @trc_number, @amount, @tmt_shopid, @tmt_description, @tmt_rep_reason;
  return;
	END
-- Check to see if the tractor is accounts payable
select @actg_type = trc_actg_type
from   tractorprofile
where  trc_number = @trc_number;
if @actg_type = 'A'
    select @asgn_type = 'TRC',
           @asgn_id = @trc_number;
else
    begin
        execute dbo.AddTMTLogEntry_sp 'Y', 'Tractor is not accounts payable. No pay created.', @results, @pyd_number, @pyd_number_escrow, @pyd_number_advance, @escrow_amount, @advance_amount, @tmt_order_id, @tmt_inv_order_num, @tmt_change_date, @drv_id, @trc_number, @amount, @tmt_shopid, @tmt_description, @tmt_rep_reason;
        return;
    end

select @trc_type1 = trc_type1
from   tractorprofile
where  trc_number = @trc_number;
-- Note: This allows for multiple entries in GI table for TMTImportType for multiple 
-- configurations. 
select @std_item_advance = gi_string2,
       @std_item_escrow = gi_string3,
       @temp = gi_string4
from   generalinfo
where  gi_name = 'TMTImportType'
       and gi_string1 = @trc_type1;
if @@ROWCOUNT = 0
	BEGIN
		SELECT @std_item_advance = NULL, @std_item_escrow = @default_advance, @min_charge = 0
	END
if isnumeric(@temp) = 1
    select @min_charge = cast (@temp as money);
else
    select @min_charge = 500.0;
-- Create negative pay 
execute dbo.createPayDetailForDeduction_sp @asgn_type, @asgn_id, @actg_type, @pty_trc, @pty_shop_charge, @amount, @tmt_description, @pyd_number output;
-- Add reference numbers as needed. 
if @ref_shopid is not null
    execute dbo.AddPayDetailRefNum_sp @pyd_number, @ref_type = @ref_shopid, @ref_number = @tmt_shopid;
if @ref_InvOrdNum is not null
    execute dbo.AddPayDetailRefNum_sp @pyd_number, @ref_type = @ref_InvOrdNum, @ref_number = @tmt_inv_order_num;
if @ref_repreason is not null
    execute dbo.AddPayDetailRefNum_sp @pyd_number, @ref_type = @ref_repreason, @ref_number = @tmt_rep_reason;
select @temp = cast (@tmt_order_id as varchar (30));
if @ref_orderid is not null
    execute dbo.AddPayDetailRefNum_sp @pyd_number, @ref_type = @ref_orderid, @ref_number = @temp;
-- deduct as much as possible from escrow account. 
if @ignore_cld_escrow = 'Y'
    begin
        select top 1 @temp = std_status
        from   standingdeduction
        where  sdm_itemcode = @std_item_escrow
               and asgn_type = 'DRV'
               and asgn_id = @drv_id;
        if @temp = 'CLD'
            begin
                execute dbo.AddTMTLogEntry_sp 'W', 'Warning: Escrow account is closed. Negative pay created.', @results, @pyd_number, @pyd_number_escrow, @pyd_number_advance, @escrow_amount, @advance_amount, @tmt_order_id, @tmt_inv_order_num, @tmt_change_date, @drv_id, @trc_number, @amount, @tmt_shopid, @tmt_description, @tmt_rep_reason;
                return;
            end
    end
if @amount > 0
	begin
		execute dbo.CreatePayDetailForEscrowToMax_sp @asgn_type, @asgn_id, @std_item_escrow, @amount, 'Y', @results output, @remain output, @pyd_number_escrow output;
		if SUBSTRING(@results, 1, 3) = 'BAD'
			begin
				select @temp = 'Error deducting from escrow account.', @error_flag = 'Y'
			end
		ELSE
		Begin
			select @escrow_amount = @amount - @remain;
			-- Check for existing standing deduction if shop charge is big enough.
			if not (@std_item_advance is null
					or @std_item_advance = '')
			   and @amount > @min_charge
			   and @remain > 0
				begin
					select @advance_amount = @remain;
					-- create / add to an advance account for driver.
					select top 1 @std_number = std_number,
								 @temp = std_status
					from   standingdeduction
					where  sdm_itemcode = @std_item_advance
						   and asgn_type = @asgn_type
						   and asgn_id = @asgn_id;
					if @std_number is null
						begin
							-- Create new deduction
							begin try
								execute dbo.sp_standing_deduction_i @asgn_type, @asgn_id, @std_item_advance, @remain, @remain
							end try
							begin catch
								select @sd_error = error_Message();
							end catch
							select @std_number = std_number,
								   @temp = std_status
							from   standingdeduction
							where  sdm_itemcode = @std_item_advance
								   and asgn_type = @asgn_type
								   and asgn_id = @asgn_id;
							if @std_number is null
								begin
									execute dbo.AddTMTLogEntry_sp 'Y', 'Error creating maintenance advance.', @sd_error, @pyd_number, @pyd_number_escrow, @pyd_number_advance, @escrow_amount, @advance_amount, @tmt_order_id, @tmt_inv_order_num, @tmt_change_date, @drv_id, @trc_number, @amount, @tmt_shopid, @tmt_description, @tmt_rep_reason;
									return;
								end
						end
					else
						begin
							-- update existing advance.
							UPDATE standingdeduction 
								set std_status = 'DRN', 
								std_priorbalance = std_balance, 
									std_balance = std_balance + @remain, 
									std_closedate = '2049-12-31 23:59:00',
									std_startbalance = case when std_startbalance < std_balance + @remain then std_balance + @remain else std_startbalance end 
							WHERE std_number = @std_number 
						end 
					-- Create positive pay for advance.
					execute dbo.create_misc_driveradvance_paydetails_std @asgn_type, @asgn_id, 0, @pyt_advance, @advance_amount, 'PND', 0, @std_number, @pyd_number_advance output;
				end
			-- All done. Log results. 
			if @remain > 0
				begin
					select @temp = '$' + cast (@remain as varchar (15));
					select @temp = @temp + ' remain after deducting $' + cast (@escrow_amount as varchar (15)) + ' from escrow account.';
				end
			else
				begin
					select @temp = '$' + cast (@escrow_amount as varchar (15));
					select @temp = @temp + ' deducted from escrow account.';
			end
		end
	end
else
	BEGIN
		select @temp = 'Credit driver ' + CAST (@amount as varchar (10))
	END
execute dbo.AddTMTLogEntry_sp @error_flag, @temp, @results, @pyd_number, @pyd_number_escrow, @pyd_number_advance, @escrow_amount, @advance_amount, @tmt_order_id, @tmt_inv_order_num, @tmt_change_date, @drv_id, @trc_number, @amount, @tmt_shopid, @tmt_description, @tmt_rep_reason;


GO
GRANT EXECUTE ON  [dbo].[tmt_import_charges] TO [public]
GO
