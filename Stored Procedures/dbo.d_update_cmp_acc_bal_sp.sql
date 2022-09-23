SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_update_cmp_acc_bal_sp    Script Date: 6/1/99 11:54:29 AM ******/
create PROCEDURE [dbo].[d_update_cmp_acc_bal_sp]

@cmp_id		varchar (8),
@update_dt	datetime,
@update_amt	money,
@del_yn		char (1)

AS

UPDATE company SET cmp_acc_balance = (isnull(cmp_acc_balance,0) + @update_amt),
		   cmp_acc_dt = @update_dt
WHERE cmp_id = @cmp_id

if @del_yn = "Y"
   DELETE FROM accessorydetail WHERE cmp_id = @cmp_id and 
	convert(varchar(80), acd_date, 1) <= @update_dt
else
   UPDATE accessorydetail SET acd_processed = "Y" WHERE cmp_id = @cmp_id and
	convert(varchar(8), acd_date, 1) <= @update_dt

Select "1"

RETURN




GO
GRANT EXECUTE ON  [dbo].[d_update_cmp_acc_bal_sp] TO [public]
GO
