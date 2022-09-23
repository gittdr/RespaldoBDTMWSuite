SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[aprecon_batch_process_sp] as
declare @ll_hdr int,@ll_det int,@ll_count int
declare @ll_lgh int , @ls_equipment varchar(20)
declare @ldec_hdr_amt money, @ldec_det_amt money
declare @ldec_org_det_amt money, @ldec_act_det_amt money

declare @ls_hdr_err varchar(255),@ls_det_err varchar(255)

select @ll_hdr = 0
WHILE 1= 1
BEGIN
	select @ls_hdr_err = ''
	select @ll_hdr = min(header_number) from apreconheader where header_number > @ll_hdr and header_status = 'N'
	IF @ll_hdr is null
		BREAK

	select @ldec_hdr_amt = ap_total_invoice_amount from apreconheader where header_number = @ll_hdr
	select @ldec_det_amt = actual_detail_amount from aprecondetail where header_number = @ll_hdr
	If @ldec_hdr_amt <> @ldec_det_amt 
	BEGIN
		select @ls_hdr_err = 'Header totals do not match with detail totals'
		update apreconheader set err_msg =  @ls_hdr_err	where header_number = @ll_hdr	
	END

	select @ll_det = 0
	WHILE 2 = 2
	BEGIN
		select @ls_det_err = ''
		select @ll_det = min(detail_sequence) from aprecondetail where header_number = @ll_hdr and detail_sequence > @ll_det and detail_status = 'N'
		IF @ll_det is null
			BREAK

		
		SELECT @ll_lgh = lgh_number , @ls_equipment = equipment_number from aprecondetail where header_number =@ll_hdr and detail_sequence = @ll_det
		
		 select @ll_count = count(*)  from legheader where lgh_number = @ll_lgh 
		 If @ll_count = 0 
			 Select @ls_det_err = @ls_det_err + '[Invalid Authorization Number]'
	
		-- 26043 JD equipment number is no longer required for validation 
		-- select @ll_count = count(*)  from legheader where lgh_primary_trailer = @ls_equipment
		-- If @ll_count = 0 
		--	 Select @ls_det_err = @ls_det_err + '[Invalid Equipment#]'
		-- end JD 26043		 

		 select @ll_count = count(*)  from paydetail where lgh_number = @ll_lgh
		 If @ll_count = 0 
			 Select @ls_det_err = @ls_det_err + '[No Pay exists for authorization]'
	
		 select @ll_count = count(*)  from assetassignment, carrier,apreconheader where lgh_number = @ll_lgh and
		 asgn_type = 'CAR' and asgn_id = car_id  and pto_id = vendor_id
		 If @ll_count = 0 
			 select @ls_det_err = @ls_det_err + '[Invalid Vendor ID for this Authorization]'
		 
		 
		 select @ll_count = count(*) from aprecondetail where header_number <> @ll_hdr and lgh_number = @ll_lgh
		 If @ll_count > 0 
			 Select @ls_det_err  = @ls_det_err + '[Authorization number already used]'

		 
		 select @ll_count = count(*)  from paydetail where lgh_number = @ll_lgh and pyd_status = 'HLD'
		 If @ll_count = 0 
			 Select @ls_det_err  = @ls_det_err +  '[Paydetails for this authorization not on hold]'
		 
		 select @ldec_org_det_amt = sum(pyd_amount)  from paydetail where lgh_number = @ll_lgh 	 
		 select @ldec_act_det_amt = actual_detail_amount from aprecondetail where header_number= @ll_hdr and detail_sequence = @ll_det		 
		 If @ldec_org_det_amt < @ldec_act_det_amt
			 Select @ls_det_err  = @ls_det_err +  '[Original/Actual amt. mismatch]'				

		 Update aprecondetail set err_msg = @ls_det_err,original_detail_amount = IsNull(@ldec_org_det_amt,0)
		 where header_number = @ll_hdr and detail_sequence = @ll_det
	END		
	
	IF @ls_hdr_err = '' 
	BEGIN
		SELECT @ll_count = count(*) from aprecondetail where header_number = @ll_hdr and err_msg <> ''
		IF @ll_count = 0 
		BEGIN
			BEGIN TRANSACTION
			update paydetail set pyd_status = 'PND' where lgh_number in (select lgh_number from aprecondetail 
			where header_number = @ll_hdr)
			IF @@error = 0 
			BEGIN
				UPDATE apreconheader set header_status = 'R' where header_number = @ll_hdr
				IF @@error = 0 
				BEGIN
					UPDATE aprecondetail set detail_status = 'R' where header_number =@ll_hdr
					IF @@error = 0
					BEGIN
						select @ll_det = 0
						while 2 = 2
						BEGIN
							select @ll_det = min(detail_sequence) from aprecondetail where header_number = @ll_hdr 
							and detail_sequence > @ll_det and original_detail_amount > actual_detail_amount
							If @ll_det is null
								BREAK
							Select @ldec_det_amt = actual_detail_amount - original_detail_amount ,@ll_lgh = lgh_number
							from aprecondetail where header_number = @ll_hdr and detail_sequence = @ll_det

							exec aprecon_insert_paydetail_sp @pl_lgh = @ll_lgh , @pdec_amount = @ldec_det_amt
							If @@error <> 0 
							BEGIN
								ROLLBACK TRANSACTION
								--RAISERROR ('Could not create adjustment pay for Authorization: %s', 16, 1, @ll_lgh)
								
							END											
						
						END
						
						COMMIT TRANSACTION
					END
					ELSE
						ROLLBACK TRANSACTION
				END
				ELSE
					ROLLBACK TRANSACTION
			END
			ELSE
				ROLLBACK TRANSACTION
			
		END

	END 
		
	
END


GO
GRANT EXECUTE ON  [dbo].[aprecon_batch_process_sp] TO [public]
GO
