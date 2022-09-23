SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_EDI_Decision_Update]
	@p_OrderHeaderNumber INT,
	@p_OrderDecision CHAR(1)
AS

DECLARE @v_OrdNumber VARCHAR(12), @v_status VARCHAR(6), @v_RetCode int, @ForceCompanyMatchOrderState int, @v_OrdPurpose VARCHAR(1)

SELECT @v_OrdNumber = ord_number, @v_status = ord_status, @v_OrdPurpose = ord_edipurpose 
  FROM orderheader
 WHERE ord_hdrnumber = @p_OrderHeaderNumber

-- INT-99999 JRICH
-- Added check of @v_OrdPurpose
-- Use 'AVL' status when processing @v_OrdPurpose = 'C'  (Cancel)
--

IF ISNULL(@v_OrdNumber,'') = '' RETURN 0

IF @p_OrderDecision = 'A'
	BEGIN
		IF @v_status IN ('PND','AVL')
			if exists(select 1 from stops where ord_hdrnumber = @p_OrderHeaderNumber and cmp_id = 'UNKNOWN')
				if @v_status = 'PND'
					set @ForceCompanyMatchOrderState = 15
				else
					set @ForceCompanyMatchOrderState = 41
		If IsNull(@ForceCompanyMatchOrderState ,0) > 0 AND @v_OrdPurpose <> 'C'    
			EXEC dx_EDI_OrderState_Update @p_OrderHeaderNumber, @ForceCompanyMatchOrderState, 'PND'
		else
			EXEC dx_EDI_OrderState_Update @p_OrderHeaderNumber, 20, 'AVL'
	END

IF @p_OrderDecision = 'D'
	EXEC dx_EDI_OrderState_Update @p_OrderHeaderNumber, 30, 'CAN'

If IsNull(@ForceCompanyMatchOrderState ,0) = 0
	EXEC dx_create_990_from_204 @v_OrdNumber, @p_OrderDecision

RETURN 1

GO
GRANT EXECUTE ON  [dbo].[dx_EDI_Decision_Update] TO [public]
GO
