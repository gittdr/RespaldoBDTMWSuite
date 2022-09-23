SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[completion_order_validation_sp] (@ordnum int, 
			@p_ord_validation_return1 int OUTPUT, @p_ord_validation_return2 int OUTPUT,
			@p_ord_validation_return3 int OUTPUT, @p_ord_validation_return4 int OUTPUT) AS  
Select @p_ord_validation_return1 = 1 ,@p_ord_validation_return2 = 0 
GO
GRANT EXECUTE ON  [dbo].[completion_order_validation_sp] TO [public]
GO
