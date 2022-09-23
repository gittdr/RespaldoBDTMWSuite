SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[link_partorder] @p_lookupby VARCHAR(3), @p_num INT
AS
declare @return integer

	If @p_lookupby = 'PO'
		exec @return = link_partorder_po @p_num
	Else
		exec @return = link_partorder_oh @p_num

GO
GRANT EXECUTE ON  [dbo].[link_partorder] TO [public]
GO
