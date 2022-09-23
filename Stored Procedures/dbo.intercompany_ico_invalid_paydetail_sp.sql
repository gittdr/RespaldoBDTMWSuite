SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 46682 JJF 20110515
CREATE PROCEDURE [dbo].[intercompany_ico_invalid_paydetail_sp]	(
	@lgh_number int
) 
AS BEGIN
	SELECT	pd.pyt_itemcode, 
			pd.pyd_description,
			'NOCHARGETYPE' AS errtype
			--, pd.asgn_type, pd.asgn_id, pd.pyd_payto, pd.pyd_quantity, pd.pyd_rate, pd.pyd_amount
	FROM	paydetail pd
			INNER JOIN paytype pyt on pd.pyt_itemcode = pyt.pyt_itemcode
	WHERE	pd.lgh_number = @lgh_number
			AND pyt.cht_itemcode = 'UNK'

	UNION
	
	SELECT	'',
			'',
			'NOLGHPAY'
	WHERE NOT EXISTS	(		SELECT	*
								FROM	paydetail pd
										INNER JOIN paytype pyt on pd.pyt_itemcode = pyt.pyt_itemcode
								WHERE	pd.lgh_number = @lgh_number
										AND pyt.pyt_basis = 'LGH'
										AND isnull(pd.pyd_amount, 0) <> 0
						)

			
END
GO
GRANT EXECUTE ON  [dbo].[intercompany_ico_invalid_paydetail_sp] TO [public]
GO
