SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[canceltrip_create_paydetail_sp]
	(	@lgh_number int,
		@pyt_itemcode varchar(6),
		@pyd_quantity float,
		@pyd_rate money
	)
AS


DECLARE @tmwuser varchar(255) 
DECLARE @pyd_number int


EXEC @pyd_number = getsystemnumber 'PYDNUM', ''   

SELECT TOP 1	asgn_number, 
				asgn_type,
				asgn_id,
				CASE asgn_type
					WHEN 'DRV' THEN 1
					WHEN 'TRC' THEN 2
					WHEN 'TRL' THEN 3
					WHEN 'CAR' THEN 4
				END payorder
INTO	#assetassignment
FROM	assetassignment 
WHERE	lgh_number = @lgh_number
		and assetassignment.actg_type <> 'N'
		
ORDER BY payorder

EXEC	@tmwuser = dbo.gettmwuser_fn

INSERT paydetail	(	pyd_number, 
						pyh_number, 
						lgh_number, 
						asgn_number, 
						asgn_type, 
						asgn_id, 
						ivd_number, 
						pyd_prorap, 
						pyd_payto, 
						pyt_itemcode, 
						pyd_description, 
						pyd_quantity, 
						pyd_rateunit, 
						pyd_unit, 
						pyd_pretax, 
						pyd_glnum, 
						pyd_status, 
						pyh_payperiod, 
						ivd_payrevenue, 
						mov_number, 
						pyd_minus, 
						pyd_workperiod, 
						pyd_sequence, 
						pyd_rate, 
						pyd_amount, 
						pyd_revenueratio, 
						pyd_lessrevenue, 
						pyd_payrevenue, 
						pyd_loadstate, 
						pyd_transdate, 
						pyd_xrefnumber, 
						ord_hdrnumber, 
						pyt_fee1, 
						pyt_fee2, 
						pyd_grossamount, 
						pyd_updatedby, 
						pyd_adj_flag, 
						tar_tarriffnumber, 
						pyd_updatedon, 
						pyd_updsrc, 
						pyd_maxquantity_used, 
						pyd_maxcharge_used, 
						pyd_vendortopay, 
						pyd_gst_flag, 
						pyd_workcycle_status 
					) 
SELECT		@pyd_number, 
			0, 
			@lgh_number, 
			asgn.asgn_number, 
			asgn.asgn_type, 
			asgn.asgn_id, 
			0, 
			'A', 
			asgn.asgn_id, 
			@pyt_itemcode, 
			pyt.pyt_description, 
			@pyd_quantity, 
			pyt_rateunit, 
			pyt_unit, 
			pyt_pretax, 
			pyt_ap_glnum, 
			'HLD', 
			{ts '2049-12-31 23:59:00.000'}, 
			0.0000, 
			lgh.mov_number, 
			1, 
			{ts '2049-12-31 23:59:00.000'}, 
			1, 
			@pyd_rate, 
			@pyd_rate * @pyd_quantity, 
			0.0000, 
			0.0000, 
			0.0000, 
			'NA', 
			lgh.lgh_enddate, 
			0, 
			0, 
			pyt.pyt_fee1, 
			pyt.pyt_fee2, 
			@pyd_rate * @pyd_quantity, 
			@tmwuser, 
			'N', 
			'', 
			getdate(), 
			'M', 
			'N', 
			'N', 
			'UNKNOWN', 
			0, 
			'UNK'
FROM	#assetassignment asgn,
		paytype pyt,
		legheader lgh
WHERE	pyt.pyt_itemcode = @pyt_itemcode
		AND lgh.lgh_number = @lgh_number

		
DROP TABLE #assetassignment


GO
GRANT EXECUTE ON  [dbo].[canceltrip_create_paydetail_sp] TO [public]
GO
