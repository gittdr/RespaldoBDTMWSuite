SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_update_ord_refnum_sp] 
			(	
				@ord_hdrnumber int,
				@ord_reftype varchar(6),
				@ord_refnum varchar(30)
			)
AS
set nocount on
	--update referencenumber
	exec transf_update_ref_number 'orderheader', @ord_hdrnumber, @ord_reftype, 64, @ord_refnum

	RETURN 1
set nocount off
GO
GRANT EXECUTE ON  [dbo].[transf_update_ord_refnum_sp] TO [public]
GO
