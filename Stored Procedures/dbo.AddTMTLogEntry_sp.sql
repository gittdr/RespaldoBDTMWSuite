SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/* 08/30/2012 MDH PTS 63733 */

CREATE PROCEDURE [dbo].[AddTMTLogEntry_sp]
(		@tdl_error						char (1) ,
		@tdl_message					varchar (2048) ,
		@tdl_std_message			varchar (100) , 
		@pyd_number					integer,
		@pyd_number_escrow  integer,
		@pyd_number_advance integer,
		@tdl_escrow_deduct	  money, 
		@tdl_advance_amount  money, 
		@tmt_order_id				integer , 
		@tmt_inv_order_num	varchar (12) , 
		@tmt_change_date		datetime , 
		@tmt_drv_id 				varchar (13) , 
		@tmt_trc_number			varchar (13) , 
		@tmt_amount 				money , 
		@tmt_shopid 				varchar (12) , 
		@tmt_description 		varchar (30) , 
		@tmt_rep_reason 		varchar (12)  
) AS
SET NOCOUNT ON
INSERT INTO dbo.tmt_deduction_log
	 (tdl_user						,
		tdl_error					,
		tdl_message				,
		tdl_std_message		,
		pyd_number        ,
		pyd_number_escrow ,
		pyd_number_advance,
		tdl_escrow_deduct	, 
		tdl_advance_amount , 
		tmt_order_id			,
		tmt_inv_order_num	,
		tmt_change_date		,
		tmt_drv_id 				,
		tmt_trc_number		,
		tmt_amount 				,
		tmt_shopid 				,
		tmt_description 	,
		tmt_rep_reason 		)
	VALUES
	 (suser_sname(),
	  @tdl_error					,
	  @tdl_message				,
	  @tdl_std_message		,
	  @pyd_number       ,
		@pyd_number_escrow,
		@pyd_number_advance,
		@tdl_escrow_deduct	 , 
		@tdl_advance_amount , 
	  @tmt_order_id			,
	  @tmt_inv_order_num,
	  @tmt_change_date	,
	  @tmt_drv_id 			,
	  @tmt_trc_number		,
	  @tmt_amount 			,
	  @tmt_shopid 			,
	  @tmt_description 	,
	  @tmt_rep_reason 	)

GO
GRANT EXECUTE ON  [dbo].[AddTMTLogEntry_sp] TO [public]
GO
